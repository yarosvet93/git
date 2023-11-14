$Result = dcdiag.exe /skip:SystemLog
#создаем массив для обьектов
$array = @()
for ($String = 0; $String -lt $Result.length; $String++) {
     # исправляет перенос CrossRefValidation и CrossRefValidation
    if ($Result[$String] -match '^\s{9}.{25}.*test$') {
        $Result[$String] = $Result[$String] + ' ' + $Result[$String + 2].Trim()
    }

    # выбираем строку начала теста
    if ($Result[$String] -match '^\s{6}Starting test: \S+$') {
        $StringStart = $String
    }

     # проверяем строку результата теста
    if ($Result[$String] -match '^\s{9}.{25} (\S+) (\S+) test (\S+)$') {
        # Создаем обьект и массив
        $ResultObject = [PSCustomObject]@{
            Target  = $Matches[1]
            Test    = $Matches[3]
            Result  = $Matches[2] -eq 'passed'
            # записываем вывод от начала теста до конца
            Data    =   $(if ($Matches[2] -ne 'passed') {(-split $Result[($StringStart+2)..($String-2)]) -join ' '})
        }

       $array +=  $ResultObject
    }
}
$return = $array | ConvertTo-Json 
Write-Host $return