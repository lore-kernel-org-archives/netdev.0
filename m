From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 5/6] [net-next]net: i40e: Clean up of
 cloud filters
Date: Mon, 14 Aug 2017 12:06:45 -0700
Message-ID: <395cdafd-418d-4c14-197d-d9fd7457d3af@intel.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154787996.4135.2478207403613749470.stgit@anamdev.jf.intel.com>
 <d0d01a6f-0a3b-cbc0-4ef6-a1c8af91ba93@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitch.a.williams@intel.com
To: Shannon Nelson <shannon.nelson@oracle.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36615 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750910AbdHNTGr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:06:47 -0400
In-Reply-To: <d0d01a6f-0a3b-cbc0-4ef6-a1c8af91ba93@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/1/2017 12:16 PM, Shannon Nelson wrote:
> On 7/31/2017 5:38 PM, Amritha Nambiar wrote:
>> Introduce the cloud filter datastructure and cleanup of cloud
>> filters associated with the device.
>>
>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
>> ---
>>   drivers/net/ethernet/intel/i40e/i40e.h      |   11 +++++++++++
>>   drivers/net/ethernet/intel/i40e/i40e_main.c |   27 +++++++++++++++++++++++++++
>>   2 files changed, 38 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
>> index 1391e5d..5c0cad5 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e.h
>> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
>> @@ -252,6 +252,14 @@ struct i40e_fdir_filter {
>>   	u32 fd_id;
>>   };
>>   
>> +struct i40e_cloud_filter {
>> +	struct hlist_node cloud_node;
>> +	/* cloud filter input set follows */
>> +	unsigned long cookie;
>> +	/* filter control */
>> +	u16 seid;
>> +};
> 
> This would be cleaner and more readable with the field comments off to 
> the side rather than in line with the fields.

Will fix in the next version of the series.

> 
>> +
>>   #define I40E_ETH_P_LLDP			0x88cc
>>   
>>   #define I40E_DCB_PRIO_TYPE_STRICT	0
>> @@ -419,6 +427,9 @@ struct i40e_pf {
>>   	struct i40e_udp_port_config udp_ports[I40E_MAX_PF_UDP_OFFLOAD_PORTS];
>>   	u16 pending_udp_bitmap;
>>   
>> +	struct hlist_head cloud_filter_list;
>> +	u16 num_cloud_filters;
>> +
>>   	enum i40e_interrupt_policy int_policy;
>>   	u16 rx_itr_default;
>>   	u16 tx_itr_default;
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index fdddd74..93f6fe2 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -6928,6 +6928,29 @@ static void i40e_fdir_filter_exit(struct i40e_pf *pf)
>>   }
>>   
>>   /**
>> + * i40e_cloud_filter_exit - Cleans up the Cloud Filters
>> + * @pf: Pointer to PF
>> + *
>> + * This function destroys the hlist where all the Cloud Filters
>> + * filters were saved.
>> + **/
>> +static void i40e_cloud_filter_exit(struct i40e_pf *pf)
>> +{
>> +	struct i40e_cloud_filter *cfilter;
>> +	struct hlist_node *node;
>> +
>> +	if (hlist_empty(&pf->cloud_filter_list))
>> +		return;
> 
> Is this check really necessary?  Doesn't hlist_for_each_entry_safe() 
> check for this?

That's right. Will fix in the next version of the series.

> 
>> +
>> +	hlist_for_each_entry_safe(cfilter, node,
>> +				  &pf->cloud_filter_list, cloud_node) {
>> +		hlist_del(&cfilter->cloud_node);
>> +		kfree(cfilter);
>> +	}
>> +	pf->num_cloud_filters = 0;
>> +}
>> +
>> +/**
>>    * i40e_close - Disables a network interface
>>    * @netdev: network interface device structure
>>    *
>> @@ -12137,6 +12160,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
>>   			vsi = i40e_vsi_reinit_setup(pf->vsi[pf->lan_vsi]);
>>   		if (!vsi) {
>>   			dev_info(&pf->pdev->dev, "setup of MAIN VSI failed\n");
>> +			i40e_cloud_filter_exit(pf);
>>   			i40e_fdir_teardown(pf);
>>   			return -EAGAIN;
>>   		}
>> @@ -12961,6 +12985,8 @@ static void i40e_remove(struct pci_dev *pdev)
>>   	if (pf->vsi[pf->lan_vsi])
>>   		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
>>   
>> +	i40e_cloud_filter_exit(pf);
>> +
>>   	/* remove attached clients */
>>   	if (pf->flags & I40E_FLAG_IWARP_ENABLED) {
>>   		ret_code = i40e_lan_del_device(pf);
>> @@ -13170,6 +13196,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
>>   
>>   	del_timer_sync(&pf->service_timer);
>>   	cancel_work_sync(&pf->service_task);
>> +	i40e_cloud_filter_exit(pf);
>>   	i40e_fdir_teardown(pf);
>>   
>>   	/* Client close must be called explicitly here because the timer
>>
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@osuosl.org
>> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>>
