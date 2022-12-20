#connects to azure
connect-azaccount

#Searches through resources for unattached NICs, then deletes them. 
$NICS= (Get-AZnetworkinterface)
foreach ($Nic in $NICS)
{
	if ($nic.virtualmachine -eq $null)
	{
	remove-azresource $nic.id -force
	}
}

#Searches through resources for unattached disks, then deletes them.
$Disks = (Get-AZDisk)
foreach ($disk in $disks)
{
	if ($disk.diskstate -eq 'unattached')
	{
	remove-azresource -resourceid $disk.id -force
	}
}

#Gets all images, then gets all images with the nerdio WAP CREATED DATE tag, then sorts them by date. finally, selects the most recent image and deletes the rest
$images= get-azresource -resourcetype microsoft.compute/images
$imagesinorder = $images.tags.WAP_CREATED_DATE | sort-object {$_ -as [DateTime]} -descending
$imagetosave = $imagesinorder[0]
foreach ($image in $images)
{
	if ($image.tags.WAP_CREATED_DATE -ne $imagetosave)
	{
	remove-azresource -resourceid $image.resourceid -force
	}
}