From: "Baicar, Tyler" <tbaicar@codeaurora.org>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: free IRQ when the link is up or
 down
Date: Thu, 3 Nov 2016 09:54:15 -0600
Message-ID: <9e978719-55f0-d3da-a149-046a344bd3c6@codeaurora.org>
References: <1478120896-5907-1-git-send-email-tbaicar@codeaurora.org>
 <36CDDD56DDB4D44E911123902EFC26B06CD48342@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Ruinskiy, Dima" <dima.ruinskiy@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "okaya@codeaurora.org" <okaya@codeaurora.org>,
        "timur@codeaurora.org" <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38998 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756697AbcKCPyS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 11:54:18 -0400
In-Reply-To: <36CDDD56DDB4D44E911123902EFC26B06CD48342@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2016 2:09 AM, Ruinskiy, Dima wrote:
>> -----Original Message-----
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>> Behalf Of Tyler Baicar
>> Sent: Wednesday, 02 November, 2016 23:08
>> To: Kirsher, Jeffrey T; intel-wired-lan@lists.osuosl.org;
>> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> okaya@codeaurora.org; timur@codeaurora.org
>> Cc: Tyler Baicar
>> Subject: [Intel-wired-lan] [PATCH] e1000e: free IRQ when the link is up or
>> down
>>
>> Move IRQ free code so that it will happen regardless of the link state.
>> Currently the e1000e driver only releases its IRQ if the link is up. This is not
>> sufficient because it is possible for a link to go down without releasing the IRQ.
>> A secondary bus reset can cause this case to happen.
>>
>> Signed-off-by: Tyler Baicar <tbaicar@codeaurora.org>
>> ---
>> drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
>> b/drivers/net/ethernet/intel/e1000e/netdev.c
>> index 7017281..36cfcb0 100644
>> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
>> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
>> @@ -4679,12 +4679,13 @@ int e1000e_close(struct net_device *netdev)
>>
>> 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
>> 		e1000e_down(adapter, true);
>> -		e1000_free_irq(adapter);
>>
>> 		/* Link status message must follow this format */
>> 		pr_info("%s NIC Link is Down\n", adapter->netdev->name);
>> 	}
>>
>> +	e1000_free_irq(adapter);
>> +
>> 	napi_disable(&adapter->napi);
>>
>> 	e1000e_free_tx_resources(adapter->tx_ring);
> This is not correct. __E1000_DOWN has nothing to do with link state. It is an internal driver status bit that indicates that device shutdown is in progress.
>
> I would not change this code without checking very carefully the driver state machine. This can cause a whole lot of issues. Did you encounter some particular problem that is resolved by this change?
Hello Dima,

The issue is that when a secondary bus reset occurs the current code 
will not free the IRQ due to this __E1000_DOWN check. If the IRQ isn't 
freed, then later in e1000_remove we run into a kernel bug:

pcieport 0004:00:00.0: PCIe Bus Error: severity=Corrected, type=Physical 
Layer, id=0000(Receiver ID)
pcieport 0004:00:00.0:   device [17cb:0400] error 
status/mask=00000001/00006000
pcieport 0004:00:00.0:    [ 0] Receiver Error         (First)
pcieport 0004:00:00.0: PCIe Bus Error: severity=Uncorrected (Non-Fatal), 
type=Transaction Layer, id=0000(Requester ID)
pcieport 0004:00:00.0:   device [17cb:0400] error 
status/mask=00004000/00400000
pcieport 0004:00:00.0:    [14] Completion Timeout     (First)
ACPI: \_SB_.PCI4: Device has suffered a power fault
kernel BUG at drivers/pci/msi.c:369!

The stack dump is:

free_msi_irqs+0x6c/0x1a8
pci_disable_msi+0xb0/0x148
e1000e_reset_interrupt_capability+0x60/0x78
e1000_remove+0xc8/0x180
pci_device_remove+0x48/0x118
__device_release_driver+0x80/0x108
device_release_driver+0x2c/0x40
pci_stop_bus_device+0xa0/0xb0
pci_stop_bus_device+0x3c/0xb0
pci_stop_root_bus+0x54/0x80
acpi_pci_root_remove+0x28/0x64
acpi_bus_trim+0x6c/0xa4
acpi_device_hotplug+0x19c/0x3f4
acpi_hotplug_work_fn+0x28/0x3c
process_one_work+0x150/0x460
worker_thread+0x50/0x4b8
kthread+0xd4/0xe8
ret_from_fork+0x10/0x50

This bug is hit because the IRQ still has action since it was never 
freed. This patch resolves this issue.

Thanks,
Tyler

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
