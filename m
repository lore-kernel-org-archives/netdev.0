From: Don Dutile <ddutile@redhat.com>
Subject: Re: [PATCH 5/5] ixgbe: add driver set_max_vfs support
Date: Wed, 03 Oct 2012 15:02:35 -0400
Message-ID: <506C8BCB.4080402@redhat.com>
References: <506C3B11.9010009@redhat.com> <1349286695-26713-1-git-send-email-yinghai@kernel.org> <1349286695-26713-6-git-send-email-yinghai@kernel.org> <506C8837.5070902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	yuvalmin@broadcom.com, bhutchings@solarflare.com,
	gregory.v.rose@intel.com, davem@davemloft.net--no-chain-reply-to,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116Ab2JCTCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 15:02:36 -0400
In-Reply-To: <506C8837.5070902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2012 02:47 PM, Alexander Duyck wrote:
> On 10/03/2012 10:51 AM, Yinghai Lu wrote:
>> Need ixgbe guys to close the loop to use set_max_vfs instead
>> kernel parameters.
>>
>> Signed-off-by: Yinghai Lu<yinghai@kernel.org>
>> Cc: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg<jesse.brandeburg@intel.com>
>> Cc: Greg Rose<gregory.v.rose@intel.com>
>> Cc: "David S. Miller"<davem@davemloft.net>
>> Cc: John Fastabend<john.r.fastabend@intel.com>
>> Cc: e1000-devel@lists.sourceforge.net
>> Cc: netdev@vger.kernel.org
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 +
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   44 +++++++++++++++++++-----
>>   2 files changed, 37 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> index b9623e9..d39d975 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> @@ -558,6 +558,8 @@ struct ixgbe_adapter {
>>   	u32 interrupt_event;
>>   	u32 led_reg;
>>
>> +	struct ixgbe_info *ixgbe_info;
>> +
>>   #ifdef CONFIG_IXGBE_PTP
>>   	struct ptp_clock *ptp_clock;
>>   	struct ptp_clock_info ptp_caps;
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index ee61819..1c097c7 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -129,13 +129,6 @@ static struct notifier_block dca_notifier = {
>>   };
>>   #endif
>>
>> -#ifdef CONFIG_PCI_IOV
>> -static unsigned int max_vfs;
>> -module_param(max_vfs, uint, 0);
>> -MODULE_PARM_DESC(max_vfs,
>> -		 "Maximum number of virtual functions to allocate per physical function - default is zero and maximum value is 63");
>> -#endif /* CONFIG_PCI_IOV */
>> -
>>   static unsigned int allow_unsupported_sfp;
>>   module_param(allow_unsupported_sfp, uint, 0);
>>   MODULE_PARM_DESC(allow_unsupported_sfp,
>> @@ -4496,7 +4489,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
>>   #ifdef CONFIG_PCI_IOV
>>   	/* assign number of SR-IOV VFs */
>>   	if (hw->mac.type != ixgbe_mac_82598EB)
>> -		adapter->num_vfs = (max_vfs>  63) ? 0 : max_vfs;
>> +		adapter->num_vfs = min_t(int, pdev->max_vfs, 63);
>>
>>   #endif
>>   	/* enable itr by default in dynamic mode */
>> @@ -7220,8 +7213,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
>>
>>   #ifdef CONFIG_PCI_IOV
>>   	ixgbe_enable_sriov(adapter, ii);
>> -
>>   #endif
>> +	adapter->ixgbe_info = ii;
>> +
>>   	netdev->features = NETIF_F_SG |
>>   			   NETIF_F_IP_CSUM |
>>   			   NETIF_F_IPV6_CSUM |
>> @@ -7683,11 +7677,43 @@ static const struct pci_error_handlers ixgbe_err_handler = {
>>   	.resume = ixgbe_io_resume,
>>   };
>>
>> +static void ixgbe_set_max_vfs(struct pci_dev *pdev)
>> +{
>> +#ifdef CONFIG_PCI_IOV
>> +	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
>> +	struct ixgbe_hw *hw =&adapter->hw;
>> +	int num_vfs = 0;
>> +
>> +	/* assign number of SR-IOV VFs */
>> +	if (hw->mac.type != ixgbe_mac_82598EB)
>> +		num_vfs = min_t(int, pdev->max_vfs, 63);
>> +
>> +	/* no change */
>> +	if (adapter->num_vfs == num_vfs)
>> +		return;
>> +
>> +	if (!num_vfs) {
>> +		/* disable sriov */
>> +		ixgbe_disable_sriov(adapter);
>> +		adapter->num_vfs = 0;
>> +	} else if (!adapter->num_vfs&&  num_vfs) {
>> +		/* enable sriov */
>> +		adapter->num_vfs = num_vfs;
>> +		ixgbe_enable_sriov(adapter, adapter->ixgbe_info);
>> +	} else {
>> +		/* increase or decrease */
>> +	}
>> +
>> +	pdev->max_vfs = adapter->num_vfs;
>> +#endif
>> +}
>> +
>>   static struct pci_driver ixgbe_driver = {
>>   	.name     = ixgbe_driver_name,
>>   	.id_table = ixgbe_pci_tbl,
>>   	.probe    = ixgbe_probe,
>>   	.remove   = __devexit_p(ixgbe_remove),
>> +	.set_max_vfs = ixgbe_set_max_vfs,
>>   #ifdef CONFIG_PM
>>   	.suspend  = ixgbe_suspend,
>>   	.resume   = ixgbe_resume,
>
> The ixgbe_set_max_vfs function has several issues.  The two big ones are
> that this function assumes it can just enable/disable SR-IOV without any
> other changes being necessary which is not the case.  I would recommend
> looking at ixgbe_setup_tc for how to do this properly.  Secondly is the
> fact that this code will change the PF network device and as such
> sections of the code should be called with the RTNL lock held.  In
> addition I believe you have to disable SR-IOV before enabling it again
> with a different number of VFs.
>
> Below is a link to one of the early patches for igb when we were first
> introducing SR-IOV, and the in-driver sysfs value had been rejected.  I
> figure it might be useful as it was also using sysfs to enable/disable
> VFs.  It however doesn't have the correct locking on changing the queues
> and as such will likely throw an error if you were to implement it the
> same way now:
> http://lists.openwall.net/netdev/2009/04/08/34
>
> Thanks,
>
> Alex

Alex,
Thanks for patch set pointer.
When I started to work on the ixgbe example use based on the RFC set I posted,
I ran into the problem you outlined -- the PF uses/consumes all the queues &
MSI intrs when sriov not enabled at driver load time, which required
more network shutdown logic that I'm not familiar with... So, I was going
to defer to Greg to work that magic. :)
Greg: assume the 2 callback function interface in the RFC patch set I sent,
       (primarily, just the include/linux/pci.h changes), and you can make the
       necessary drivers mods from there.  In the meantime, I'll make the changes
       to my original/v1 RFC to reflect the changes that GKH & Yinghai recommended/implemented
       for sysfs attribute creation & removal in a v2 posting.
       The end result is that the current module parameter setting for max_vfs should
       continue to work, and the sysfs interface will work when those pieces are provided.

-Don
