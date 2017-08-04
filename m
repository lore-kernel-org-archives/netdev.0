From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v8 1/4] PCI: Add new PCIe Fabric End Node flag,
  PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Fri, 4 Aug 2017 21:06:15 +0000
Message-ID: <MWHPR12MB1600F5F2E2C4A5A7C5449896C8B60__43192.09729224$1501880798$gmane$org@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1501767889-7772-1-git-send-email-dingtianhong@huawei.com>,<1501767889-7772-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Ding Tianhong <dingtianhong@huawei.com>,
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
        "catalin.marinas@arm.com" <catalin.marinas@a
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0094.outbound.protection.outlook.com ([104.47.42.94]:56995
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751268AbdHDVGU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 17:06:20 -0400
In-Reply-To: <1501767889-7772-2-git-send-email-dingtianhong@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Ding Tianhong <dingtianhong@huawei.com>
| Sent: Thursday, August 3, 2017 6:44 AM
|
| diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
| index 6967c6b..1e1cdbe 100644
| --- a/drivers/pci/quirks.c
| +++ b/drivers/pci/quirks.c
| @@ -4016,6 +4016,44 @@ static void quirk_tw686x_class(struct pci_dev *pde=
v)
|                                quirk_tw686x_class);
|
|  /*
| + * Some devices have problems with Transaction Layer Packets with the Re=
laxed
| + * Ordering Attribute set.  Such devices should mark themselves and othe=
r
| + * Device Drivers should check before sending TLPs with RO set.
| + */
| +static void quirk_relaxedordering_disable(struct pci_dev *dev)
| +{
| +       dev->dev_flags |=3D PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
| +}
| +
| +/*
| + * Intel E5-26xx Root Complex has a Flow Control Credit issue which can
| + * cause performance problems with Upstream Transaction Layer Packets wi=
th
| + * Relaxed Ordering set.
| + */
| +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f02, PCI_CLASS_NOT=
_DEFINED, 8,
| +                             quirk_relaxedordering_disable);
| +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f04, PCI_CLASS_NOT=
_DEFINED, 8,
| +                             quirk_relaxedordering_disable);
| +DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f08, PCI_CLASS_NOT=
_DEFINED, 8,
| +                             quirk_relaxedordering_disable);
| + ...

It looks like this is missing the set of Root Complex IDs that were noted i=
n
the document to which Patrick Cramer sent us a reference:

https://software.intel.com/sites/default/files/managed/9e/bc/64-ia-32-archi=
tectures-optimization-manual.pdf

In section 3.9.1 we have:

    3.9.1 Optimizing PCIe Performance for Accesses Toward Coherent Memory
          and Toward MMIO Regions (P2P)

    In order to maximize performance for PCIe devices in the processors
    listed in Table 3-6 below, the soft- ware should determine whether the
    accesses are toward coherent memory (system memory) or toward MMIO
    regions (P2P access to other devices). If the access is toward MMIO
    region, then software can command HW to set the RO bit in the TLP
    header, as this would allow hardware to achieve maximum throughput for
    these types of accesses. For accesses toward coherent memory, software
    can command HW to clear the RO bit in the TLP header (no RO), as this
    would allow hardware to achieve maximum throughput for these types of
    accesses.

    Table 3-6. Intel Processor CPU RP Device IDs for Processors Optimizing
               PCIe Performance

    Processor                            CPU RP Device IDs

    Intel Xeon processors based on       6F01H-6F0EH
    Broadwell microarchitecture

    Intel Xeon processors based on       2F01H-2F0EH
    Haswell microarchitecture

The PCI Device IDs you have there are the first ones that I guessed at
having the performance problem with Relaxed Ordering.  We now apparently
have a complete list from Intel.

I don't want to phrase this as a "NAK" because you've gone around the
mulberry bush a bunch of times already.  So maybe just go with what you've
got in version 8 of your patch and then do a follow on patch to complete th=
e
table?

Casey=
