From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 23 Dec 2011 18:29:52 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF22286646E087@ORSMSX102.amr.corp.intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <20111223130148.GB27206@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37478 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab1LWS3z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 13:29:55 -0500
In-Reply-To: <20111223130148.GB27206@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Francois Romieu [mailto:romieu@fr.zoreil.com]
>Sent: Friday, December 23, 2011 5:02 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com; Waskiewicz Jr, Peter P
>Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
>
>Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
>> From: Don Skidmore <donald.c.skidmore@intel.com>
>>
>> Some of our adapters have thermal data available, this patch exports
>this
>> data via a read-only sysfs interface.  More patches will follow that
>will
>> contain additional information to be exported.
>>
>> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
>> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/ixgbe/Makefile      |    2 +-
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    4 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |    2 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    6 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |  305
>++++++++++++++++++++++++
>[...]
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>> index 7720721..1a3810e 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>> @@ -2137,6 +2137,8 @@ static struct ixgbe_mac_operations mac_ops_82599
>= {
>>  	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
>>  	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
>>  	.release_swfw_sync      = &ixgbe_release_swfw_sync,
>> +	.get_thermal_sensor_data = &ixgbe_get_thermal_sensor_data_generic,
>> +	.init_thermal_sensor_thresh =
>&ixgbe_init_thermal_sensor_thresh_generic,
>
>.get_thermal_sensor_data and .init_thermal_sensor_thresh do not seem to
>be read anywhere.
>
>>
>>  };
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index e27e4d1..b5cef7e 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -7717,6 +7717,10 @@ static int __devinit ixgbe_probe(struct pci_dev
>*pdev,
>>
>>  	e_dev_info("Intel(R) 10 Gigabit Network Connection\n");
>>  	cards_found++;
>> +
>> +	if (ixgbe_sysfs_init(adapter))
>> +		e_err(probe, "failed to allocate sysfs resources\n");
>> +
>>  	return 0;
>>
>>  err_register:
>> @@ -7764,6 +7768,8 @@ static void __devexit ixgbe_remove(struct
>pci_dev *pdev)
>>  	}
>>
>>  #endif
>> +	ixgbe_sysfs_exit(adapter);
>> +
>>  #ifdef IXGBE_FCOE
>>  	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
>>  		ixgbe_cleanup_fcoe(adapter);
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
>b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
>> new file mode 100644
>> index 0000000..db818ae
>> --- /dev/null
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
>[...]
>> +static void ixgbe_del_adapter(struct ixgbe_adapter *adapter)
>
>Please name it ixgbe_sysfs_del_adapter or anything better.
>
>> +{
>> +	int i;
>> +
>> +	if (adapter == NULL)
>> +		return;
>> +
>> +	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
>> +		if (adapter->therm_kobj[i] == NULL)
>> +			continue;
>> +		sysfs_remove_group(adapter->therm_kobj[i],
>&therm_attr_group);
>> +		kobject_put(adapter->therm_kobj[i]);
>> +	}
>> +	if (adapter->info_kobj != NULL)
>> +		kobject_put(adapter->info_kobj);
>> +}
>> +
>> +/* called from ixgbe_main.c */
>> +void ixgbe_sysfs_exit(struct ixgbe_adapter *adapter)
>> +{
>> +	ixgbe_del_adapter(adapter);
>> +}
>> +
>> +/* called from ixgbe_main.c */
>> +int ixgbe_sysfs_init(struct ixgbe_adapter *adapter)
>> +{
>> +	struct net_device *netdev;
>> +	int rc = 0;
>> +	int i;
>> +	char buf[16];
>> +
>> +	if (adapter == NULL)
>> +		goto err;
>
>ixgbe_sysfs_init is only used in ixgbe_probe at a place where adapter
>can
>not be NULL.
>
>> +	netdev = adapter->netdev;
>> +	if (netdev == NULL)
>> +		goto err;
>
>netdev can not be NULL.
>
>> +
>> +	adapter->info_kobj = NULL;
>> +	for (i = 0; i < IXGBE_MAX_SENSORS; i++)
>> +		adapter->therm_kobj[i] = NULL;
>> +
>> +	/* create info kobj and attribute listings in kobj */
>> +	adapter->info_kobj = kobject_create_and_add("info",
>> +					&(netdev->dev.kobj));
>
>Remove comment and parenthesis. Everything can fit in a single line.
>
>> +	if (adapter->info_kobj == NULL)
>> +		goto err;
>> +
>> +	/* Don't create thermal subkobjs if no data present */
>> +	if (ixgbe_thermal_present(adapter->info_kobj) != true)
>> +		goto exit;
>> +
>> +	for (i = 0; i < IXGBE_MAX_SENSORS; i++) {
>
>'buf' ought to be declared here.
>
>> +
>> +		/*
>> +		 * Likewise only create individual kobjs that have
>> +		 * meaningful data.
>> +		 */
>> +		if (adapter->hw.mac.thermal_sensor_data.sensor[i].location
>== 0)
>> +			continue;
>> +
>> +		/* directory named after sensor offset */
>> +		snprintf(buf, sizeof(buf), "sensor_%d", i);
>> +		adapter->therm_kobj[i] =
>> +			kobject_create_and_add(buf, adapter->info_kobj);
>> +		if (adapter->therm_kobj[i] == NULL)
>> +			goto err;
>> +		if (sysfs_create_group(adapter->therm_kobj[i],
>> +				       &therm_attr_group))
>> +			goto err;
>> +	}
>> +
>> +	goto exit;
>> +
>> +err:
>> +	ixgbe_del_adapter(adapter);
>> +	rc = -1;
>> +exit:
>> +	return rc;
>> +}
>> +
>> --
>> 1.7.7.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


I like all your suggestions and will do the clean up.

Thanks again for the great review. :)

-Don Skidmore <donald.c.skidmore@intel.com>
