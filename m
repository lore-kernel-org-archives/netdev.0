From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Tue, 2 May 2017 14:49:01 +0800
Message-ID: <357cd058-09b3-345c-0461-45f1bea03d96@huawei.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        "Asit K Mallick" <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Ashok Raj <ashok.raj@intel.com>,
        "Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Mark Rutland" <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        "Gabriele Paoloni" <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <netdev@vger.kernel.org>,
To: Casey Leedom <leedom@chelsio.com>,
        Bjorn Helgaas <helgaas@kernel.org>, <leedom@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5907 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdEBGtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 02:49:51 -0400
In-Reply-To: <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi, Casey:

On 2017/5/2 7:13, Casey Leedom wrote:
> The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING indicates that the Relaxed
> Ordering Attribute should not be used on Transaction Layer Packets destined
> for the PCIe End Node so flagged.  Initially flagged this way are Intel
> E5-26xx Root Complex Ports which suffer from a Flow Control Credit
> Performance Problem and AMD A1100 ARM ("SEATTLE") Root Complex Ports which
> don't obey PCIe 3.0 ordering rules which can lead to Data Corruption.
> ---
>  drivers/pci/quirks.c | 38 ++++++++++++++++++++++++++++++++++++++
>  include/linux/pci.h  |  2 ++
>  2 files changed, 40 insertions(+)
> 
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index f754453..4ae78b3 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -3979,6 +3979,44 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
>  			      quirk_tw686x_class);
>  
>  /*
> + * Some devices have problems with Transaction Layer Packets with the Relaxed
> + * Ordering Attribute set.  Such devices should mark themselves and other
> + * Device Drivers should check before sending TLPs with RO set.
> + */
> +static void quirk_relaxedordering_disable(struct pci_dev *dev)
> +{
> +	dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
> +}
> +
> +/*
> + * Intel E5-26xx Root Complex has a Flow Control Credit issue which can
> + * cause performance problems with Upstream Transaction Layer Packets with
> + * Relaxed Ordering set.
> + */
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f02, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f04, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f08, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +
> +/*
> + * The AMD ARM A1100 (AKA "SEATTLE") SoC has a bug in its PCIe Root Complex
> + * where Upstream Transaction Layer Packets with the Relaxed Ordering
> + * Attribute clear are allowed to bypass earlier TLPs with Relaxed Ordering
> + * set.  This is a violation of the PCIe 3.0 Transaction Ordering Rules
> + * outlined in Section 2.4.1 (PCI Express(r) Base Specification Revision 3.0
> + * November 10, 2010).  As a result, on this platform we can't use Relaxed
> + * Ordering for Upstream TLPs.
> + */
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a00, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a01, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a02, PCI_CLASS_NOT_DEFINED, 8,
> +			      quirk_relaxedordering_disable);
> +
> +/*
>   * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
>   * values for the Attribute as were supplied in the header of the
>   * corresponding Request, except as explicitly allowed when IDO is used."
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index eb3da1a..6764f66 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -178,6 +178,8 @@ enum pci_dev_flags {
>  	PCI_DEV_FLAGS_NO_PM_RESET = (__force pci_dev_flags_t) (1 << 7),
>  	/* Get VPD from function 0 VPD */
>  	PCI_DEV_FLAGS_VPD_REF_F0 = (__force pci_dev_flags_t) (1 << 8),
> +	/* Don't use Relaxed Ordering for TLPs directed at this device */
> +	PCI_DEV_FLAGS_NO_RELAXED_ORDERING = (__force pci_dev_flags_t) (1 << 9),
>  };

What about add a new general func to check the RO for several drivers to use them ?

just like:

#define pci_dev_support_relaxed_ordering(struct pci_dev *root) \
	(!(root->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING))

Thanks
Ding

>  
>  enum pci_irq_reroute_variant {
> 
