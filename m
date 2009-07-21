From: Yu Zhao <yu.zhao@intel.com>
Subject: Re: SRIOV fails with "SR-IOV: bus number out of range"
Date: Tue, 21 Jul 2009 08:58:58 +0800
Message-ID: <4A6512D2.6050808@intel.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77055985C4@nekter> <4A2DFCCC.10506@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD7705640305@nekter> <4A3877EB.7020109@intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD770579029A@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29514 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbZGUBBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2009 21:01:10 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD770579029A@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sivakumar Subramani wrote:
> Hi,
> 
> Our card supports 4 virtual function. And I am getting following error
> message from srio_enable function. Any idea on this error message? I
> have attached the lspci output for reference.

Your BIOS doesn't support SR-IOV. Please contact the vendor for a new 
one. Or plug the device into a PCIe slot that supports ARI Forwarding. 
If neither of the ways are easy for you, use pci=assign-busses to boot 
kernel.

> 
> Thanks,
> ~Siva
> 
> 
> Jul 20 01:11:58 SuSE11 kernel: vxge: Copyright(c) 2002-2009 Neterion Inc
> Jul 20 01:11:58 SuSE11 kernel: vxge: Driver version: 0.0.0.0-svn
> Jul 20 01:11:58 SuSE11 kernel: vxge 0000:03:00.0: PCI INT A -> GSI 16
> (level, low) -> IRQ 16
> Jul 20 01:11:58 SuSE11 kernel: vxge 0000:03:00.0: setting latency timer
> to 64
> Jul 20 01:11:58 SuSE11 kernel: virtfn_bus is 4
> Jul 20 01:11:58 SuSE11 kernel: nr_virtfn is 4
> Jul 20 01:11:58 SuSE11 kernel: dev->bus->subordinate is 3
> Jul 20 01:11:58 SuSE11 kernel: vxge 0000:03:00.0: SR-IOV: bus number out
> of range <<===============================Error
> Jul 20 01:11:58 SuSE11 kernel: eth2: SERIAL NUMBER: SXJ0841025
> Jul 20 01:11:58 SuSE11 kernel: eth2: PART NUMBER: X3110SR0001
> Jul 20 01:11:58 SuSE11 kernel: eth2: Neterion PCIe 10 GbE Adapter,
> single port, SFP+ SR Server Adapter
> Jul 20 01:11:58 SuSE11 kernel: eth2: MAC ADDR: 00:0C:FC:00:B6:B5
> Jul 20 01:11:58 SuSE11 kernel: eth2: Link Width x4
> Jul 20 01:11:58 SuSE11 kernel: eth2: Firmware version : 1.1.0 Date :
> 06/17/2009
> Jul 20 01:11:58 SuSE11 kernel: eth2: Single Root IOV Mode Enabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: 1 Vpath(s) opened
> Jul 20 01:11:58 SuSE11 kernel: eth2: Interrupt type MSI-X
> Jul 20 01:11:58 SuSE11 kernel: eth2: RTH steering disabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: Tx steering disabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: Large receive offload enabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: NAPI enabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: Rx doorbell mode enabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: VLAN tag stripping enabled
> Jul 20 01:11:58 SuSE11 kernel: eth2: Ring blocks : 2
> Jul 20 01:11:58 SuSE11 kernel: eth2: Fifo blocks : 12
> Thanks,
> ~Siva
> 
> -----Original Message-----
> From: Yu Zhao [mailto:yu.zhao@intel.com] 
> Sent: Wednesday, June 17, 2009 10:28 AM
> To: Sivakumar Subramani
> Cc: netdev@vger.kernel.org
> Subject: Re: SRIOV fails with "not enough MMIO resources"
> 
> Sivakumar Subramani wrote:
>> Sorry for the delay in reply. I got the setup back today. The PF BAR4
>> size  is 32M. BAR0 of each VF is 8M. I loading the driver with 4 VFs.
> I
>> am facing this problem, even if I load it with 3 VFs.
> 
> OK, I see the problem. The total VFs supported by your SR-IOV device is 
> 8 (0a:00.0/1) and 16 (09:00.0). And the VF MMIO area is calculated by 
> size of VF BAR multiplied total VFs. Passing 3 or 4 to 
> pci_enable_sriov() can not reduce the VF MMIO area size.
> 
> So please hardcode the total VFs to 4 before you get a BIOS that 
> supports the SR-IOV:
> 
> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
> index b497daa..5ba6da0 100644
> --- a/drivers/pci/iov.c
> +++ b/drivers/pci/iov.c
> @@ -430,6 +430,7 @@ static int sriov_init(struct pci_dev *dev, int pos)
>          if (!total)
>                  return 0;
> 
> +       total = 4;
>          ctrl = 0;
>          list_for_each_entry(pdev, &dev->bus->devices, bus_list)
>                  if (pdev->is_physfn)
> 
> 
>> I have attached the code of sriov_init / sriov_enable /
> quirk_vxge_sriov
>> and the log of the debug statements that I have added in these
> function.
>> Please let you know your comments.
>>
>> </Siva>
>>
>> Thanks,
>> ~Siva
>> -----Original Message-----
>> From: Yu Zhao [mailto:yu.zhao@intel.com] 
>> Sent: Tuesday, June 09, 2009 11:40 AM
>> To: Sreenivasa Honnur
>> Cc: netdev@vger.kernel.org; Sivakumar Subramani
>> Subject: Re: SRIOV fails with "not enough MMIO resources"
>>
>> Sreenivasa Honnur wrote:
>>> Hi,
>>>
>>> I added pci_enable_sriov / pci_disable_sriov in probe and remove
>>> function for Neterion X3100 card to test SRIOV feature. While testing
>> I
>>> got following error.
>>>
>>> Jun 8 00:02:59 bethweidel kernel: vxge: Copyright(c) 2002-2009
>> Neterion
>>> Inc Jun 8 00:02:59 bethweidel kernel: vxge: Driver version:
>>> 2.0.1.17129-k Jun 8 00:02:59 bethweidel kernel: vxge 0000:03:00.0:
> PCI
>>> INT A -> GSI 16 (level, low) -> IRQ 16 Jun 8 00:02:59 bethweidel
>> kernel:
>>> res->parent is ffff88013f129d28 for 2 Jun 8 00:02:59 bethweidel
>> kernel:
>>> res->parent is ffff88013f129d28 for 4 Jun 8 00:02:59 bethweidel
>> kernel:
>>> nres = 2 - iov->nres = 3 Jun 8 00:02:59 bethweidel kernel: vxge
>>> 0000:03:00.0: not enough MMIO resources for SR-IOV ----> ERROR Jun 8
>>> 00:02:59 bethweidel kernel: pci_enable_sriov returned -12 Jun 8
>> 00:02:59
>>> bethweidel kernel: eth2: SERIAL NUMBER: SXC0919196 Jun 8 00:02:59
>>> bethweidel kernel: eth2: PART NUMBER: X3110SR0003
>>>
>>>  
>>>
>>> When I dumped the config space of SRIOV Capability, I found BAR0 of
>> VFs
>>> was not configured by BIOS and it was zero. So I added following
>>> "quirk_vxge_sriov" quirk function to configure the BAR2 of PF as BAR0
>> of
>>> VFs.
>>>
>>> Now lspci shows proper value. But I am still get same error. The code
>>> that dumps this error is as follow. Here I trying to find out the
>> reason
>>> why res->parent is not updated for BAR0 of VF. From the above log, I
>> can
>>> see that Bar2 and BAR4's res->parent are update.
>>>
>>> Any possible reason why res->parent of VF's BAR0 is not updated?
>> Is the size of the PF BAR 4 big enough to cover the VF MMIO area 
>> indicated by VF BAR 0? (size of the PF BAR 4 >= size of VF BAR 0 *
>> NumVFs).
>>
>> Can you please post the whole dmesg? I might be able to root cause the
> 
>> problem after looking at it.
>>
>>> sriov_enable :
>>>
>>> --------------
>>>
>>> nres = 0;
>>>
>>> for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
>>>
>>> res = dev->resource + PCI_IOV_RESOURCES + i;
>>>
>>> if (res->parent) {
>>>
>>> printk("res->parent is %llx for %d \n", res->parent,i );
>>>
>>> nres++;
>>>
>>> }
>>>
>>> }
>>>
>>> printk("nres = %d - iov->nres = %d \n", nres, iov->nres);
>>>
>>> if (nres != iov->nres) {
>>>
>>> dev_err(&dev->dev, "not enough MMIO resources for SR-IOV\n");
>>>
>>> return -ENOMEM;
>>>
>>> }
>>>
>>>  
>>>
>>> quirk_vxge_sriov:
>>>
>>> -----------------
>>>
>>> static void __devinit quirk_vxge_sriov(struct pci_dev *dev) {
>>>
>>> int pos, flags;
>>>
>>> u32 bar, start, size;
>>>
>>> printk("Entering quirk_vxge_sriov ...\n");
>>>
>>> if (PAGE_SIZE > 0x10000) {
>>>
>>> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
>>>
>>> return;
>>>
>>> }
>>>
>>> pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_SRIOV);
>>>
>>> printk("the pos is %d \n", pos);
>>>
>>> if (!pos) {
>>>
>>> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
>>>
>>> return;
>>>
>>> }
>>>
>>> pci_read_config_dword(dev, pos + PCI_SRIOV_BAR, &bar);
>>>
>>> if (bar & PCI_BASE_ADDRESS_MEM_MASK)
>>>
>>> {
>>>
>>> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
>>>
>>> return;
>>>
>>> }
>>>
>>> start = pci_resource_start(dev, 4);
>>>
>>> size = pci_resource_len(dev, 4);
>>>
>>> printk("Bar4 start %llx - size %llx \n", start, size);
>>>
>>> if (!start || size != 0x2000000 || start & (size - 1)) {
>>>
>>> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
>>>
>>> return;
>>>
>>> }
>>>
>>> pci_resource_flags(dev, 4) = 0;
>>>
>>> pci_write_config_dword(dev, PCI_BASE_ADDRESS_4, 0);
>>>
>>> pci_write_config_dword(dev, pos + PCI_SRIOV_BAR, start);
>>>
>>> pci_read_config_dword(dev, pos+PCI_SRIOV_BAR,&bar);
>>>
>>> printk("VF's Bar0 is %llx \n", bar);
>>>
>>> dev_info(&dev->dev, "use Flash Memory Space for SR-IOV BARs\n");
>>>
>>> printk("Exiting quirk_vxge_sriov ...\n"); }
>>>
>>>  
>>>
>>> Thanks,
>>>
>>> ~Siva
>>>
>>>  
>>>
>>>  
>>>
>>>  
>>>
>>>  
>>>
>>>  
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

