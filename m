From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v8 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Sat, 5 Aug 2017 14:28:43 +0800
Message-ID: <c91556e4-a0e3-d553-adba-431049504a7d__21233.8076359176$1501915339$gmane$org@huawei.com>
References: <1501767889-7772-1-git-send-email-dingtianhong@huawei.com>
 <1501767889-7772-2-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB1600F5F2E2C4A5A7C5449896C8B60@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Casey Leedom <leedom@chelsio.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:11258 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdHEGmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 02:42:05 -0400
In-Reply-To: <MWHPR12MB1600F5F2E2C4A5A7C5449896C8B60@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/8/5 5:06, Casey Leedom wrote:
> | From: Ding Tianhong <dingtianhong@huawei.com>
> | Sent: Thursday, August 3, 2017 6:44 AM
> |
> | diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> | index 6967c6b..1e1cdbe 100644
> | --- a/drivers/pci/quirks.c
> | +++ b/drivers/pci/quirks.c
> | @@ -4016,6 +4016,44 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
> |                                quirk_tw686x_class);
> |
> |  /*
> | + * Some devices have problems with Transaction Layer Packets with the Relaxed
> | + * Ordering Attribute set.  Such devices should mark themselves and other
> | + * Device Drivers should check before sending TLPs with RO set.
> | + */
> | +static void quirk_relaxedordering_disable(struct pci_dev *dev)
> | +{
> | +       dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
> | +}
> | +
> | +/*
> | + * Intel E5-26xx Root Complex has a Flow Control Credit issue which can
> | + * cause performance problems with Upstream Transaction Layer Packets with
> | + * Relaxed Ordering set.
> | + */
> | +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f02, PCI_CLASS_NOT_DEFINED, 8,
> | +                             quirk_relaxedordering_disable);
> | +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f04, PCI_CLASS_NOT_DEFINED, 8,
> | +                             quirk_relaxedordering_disable);
> | +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f08, PCI_CLASS_NOT_DEFINED, 8,
> | +                             quirk_relaxedordering_disable);
> | + ...
> 
> It looks like this is missing the set of Root Complex IDs that were noted in
> the document to which Patrick Cramer sent us a reference:
> 
> https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-architectures-optimization-manual.pdf
> 
> In section 3.9.1 we have:
> 
>     3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
>           and Toward MMIO Regions (P2P)
> 
>     In order to maximize performance for PCIe devices in the processors
>     listed in Table 3-6 below, the soft- ware should determine whether the
>     accesses are toward coherent memory (system memory) or toward MMIO
>     regions (P2P access to other devices). If the access is toward MMIO
>     region, then software can command HW to set the RO bit in the TLP
>     header, as this would allow hardware to achieve maximum throughput for
>     these types of accesses. For accesses toward coherent memory, software
>     can command HW to clear the RO bit in the TLP header (no RO), as this
>     would allow hardware to achieve maximum throughput for these types of
>     accesses.
> 
>     Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
>                PCIe Performance
> 
>     Processor                            CPU RP Device IDs
> 
>     Intel Xeon processors based on       6F01H-6F0EH
>     Broadwell microarchitecture
> 
>     Intel Xeon processors based on       2F01H-2F0EH
>     Haswell microarchitecture
> 
> The PCI Device IDs you have there are the first ones that I guessed at
> having the performance problem with Relaxed Ordering.  We now apparently
> have a complete list from Intel.
> 
> I don't want to phrase this as a "NAK" because you've gone around the
> mulberry bush a bunch of times already.  So maybe just go with what you've
> got in version 8 of your patch and then do a follow on patch to complete the
> table?
> 
Casey:

Thanks for the good catch, I found that the Ashok has notice this 3 month before, I am so sorry to
miss it, it was really a long discussion for this problem, but don't worry, It is not a big work to fix it,
I will send the v9 version. :)

Ding

> Casey
> .
> 
