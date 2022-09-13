# ManagedIdentityPermission.ps1
# Adds Graph.SendMail permission to an existing app with PowerShell
# Christoph Wilfing, Toni Pohl, atwork.at, September 2022

#Requires -module Microsoft.Graph.Applications
Import-Module Microsoft.Graph.Applications

# objectID of the Managed Identnity you want to give permission
$SpObjectID = '<appid>'
$GraphPermission = 'Mail.Send'

# Connect to the Microsoft Graph
Connect-MgGraph -ContextScope Process

# Find your Service Principal
$SP = Get-MgServicePrincipal -ServicePrincipalId $SpObjectID
$SP | fl

# find the SP for the Graph API: Get all service principals from the directory filtered
$GraphApi = Get-MgServicePrincipal -Filter "AppID eq '00000003-0000-0000-c000-000000000000'"
$GraphApi | fl

# find the permission to add to our ServicePrincipal
$Approle = $GraphApi | `
    Select-Object -ExpandProperty approles | `
    Where-Object { $_.value -like $GraphPermission }
$Approle

# Create a new object with the desired permissions
$params = @{
    PrincipalId = $SpObjectID
    ResourceId  = $GraphApi.Id
    AppRoleId   = $Approle.Id
}
$params

# add the role
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $SpObjectID -BodyParameter $params

# Check the app permissions.
