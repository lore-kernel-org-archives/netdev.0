From: Yu Zhao <yu.zhao@intel.com>
Subject: Re: SRIOV fails with "not enough MMIO resources"
Date: Tue, 09 Jun 2009 14:10:20 +0800
Message-ID: <4A2DFCCC.10506@intel.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77055985C4@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55683 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719AbZFIGMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 02:12:40 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77055985C4@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> Hi,
> 
> I added pci_enable_sriov / pci_disable_sriov in probe and remove
> function for Neterion X3100 card to test SRIOV feature. While testing I
> got following error.
> 
> Jun 8 00:02:59 bethweidel kernel: vxge: Copyright(c) 2002-2009 Neterion
> Inc Jun 8 00:02:59 bethweidel kernel: vxge: Driver version:
> 2.0.1.17129-k Jun 8 00:02:59 bethweidel kernel: vxge 0000:03:00.0: PCI
> INT A -> GSI 16 (level, low) -> IRQ 16 Jun 8 00:02:59 bethweidel kernel:
> res->parent is ffff88013f129d28 for 2 Jun 8 00:02:59 bethweidel kernel:
> res->parent is ffff88013f129d28 for 4 Jun 8 00:02:59 bethweidel kernel:
> nres = 2 - iov->nres = 3 Jun 8 00:02:59 bethweidel kernel: vxge
> 0000:03:00.0: not enough MMIO resources for SR-IOV ----> ERROR Jun 8
> 00:02:59 bethweidel kernel: pci_enable_sriov returned -12 Jun 8 00:02:59
> bethweidel kernel: eth2: SERIAL NUMBER: SXC0919196 Jun 8 00:02:59
> bethweidel kernel: eth2: PART NUMBER: X3110SR0003
> 
>  
> 
> When I dumped the config space of SRIOV Capability, I found BAR0 of VFs
> was not configured by BIOS and it was zero. So I added following
> "quirk_vxge_sriov" quirk function to configure the BAR2 of PF as BAR0 of
> VFs.
> 
> Now lspci shows proper value. But I am still get same error. The code
> that dumps this error is as follow. Here I trying to find out the reason
> why res->parent is not updated for BAR0 of VF. From the above log, I can
> see that Bar2 and BAR4's res->parent are update.
> 
> Any possible reason why res->parent of VF's BAR0 is not updated?

Is the size of the PF BAR 4 big enough to cover the VF MMIO area 
indicated by VF BAR 0? (size of the PF BAR 4 >= size of VF BAR 0 * NumVFs).

Can you please post the whole dmesg? I might be able to root cause the 
problem after looking at it.

> 
> sriov_enable :
> 
> --------------
> 
> nres = 0;
> 
> for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
> 
> res = dev->resource + PCI_IOV_RESOURCES + i;
> 
> if (res->parent) {
> 
> printk("res->parent is %llx for %d \n", res->parent,i );
> 
> nres++;
> 
> }
> 
> }
> 
> printk("nres = %d - iov->nres = %d \n", nres, iov->nres);
> 
> if (nres != iov->nres) {
> 
> dev_err(&dev->dev, "not enough MMIO resources for SR-IOV\n");
> 
> return -ENOMEM;
> 
> }
> 
>  
> 
> quirk_vxge_sriov:
> 
> -----------------
> 
> static void __devinit quirk_vxge_sriov(struct pci_dev *dev) {
> 
> int pos, flags;
> 
> u32 bar, start, size;
> 
> printk("Entering quirk_vxge_sriov ...\n");
> 
> if (PAGE_SIZE > 0x10000) {
> 
> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
> 
> return;
> 
> }
> 
> pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_SRIOV);
> 
> printk("the pos is %d \n", pos);
> 
> if (!pos) {
> 
> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
> 
> return;
> 
> }
> 
> pci_read_config_dword(dev, pos + PCI_SRIOV_BAR, &bar);
> 
> if (bar & PCI_BASE_ADDRESS_MEM_MASK)
> 
> {
> 
> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
> 
> return;
> 
> }
> 
> start = pci_resource_start(dev, 4);
> 
> size = pci_resource_len(dev, 4);
> 
> printk("Bar4 start %llx - size %llx \n", start, size);
> 
> if (!start || size != 0x2000000 || start & (size - 1)) {
> 
> printk("Returning quirk_vxge_sriov @%d \n", __LINE__);
> 
> return;
> 
> }
> 
> pci_resource_flags(dev, 4) = 0;
> 
> pci_write_config_dword(dev, PCI_BASE_ADDRESS_4, 0);
> 
> pci_write_config_dword(dev, pos + PCI_SRIOV_BAR, start);
> 
> pci_read_config_dword(dev, pos+PCI_SRIOV_BAR,&bar);
> 
> printk("VF's Bar0 is %llx \n", bar);
> 
> dev_info(&dev->dev, "use Flash Memory Space for SR-IOV BARs\n");
> 
> printk("Exiting quirk_vxge_sriov ...\n"); }
> 
>  
> 
> Thanks,
> 
> ~Siva
> 
>  
> 
>  
> 
>  
> 
>  
> 
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

