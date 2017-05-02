From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Tue, 2 May 2017 09:53:29 -0700
Message-ID: <20170502165329.GB26406@linux.intel.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Leedom <leedom@chelsio.com>,
        Bjorn Helgaas <helgaas@kernel.org>, leedom@gmail.com,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49424 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751146AbdEBQxa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 12:53:30 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 09:39:34AM -0700, Alexander Duyck wrote:
> On Mon, May 1, 2017 at 4:13 PM, Casey Leedom <leedom@chelsio.com> wrote:
> > The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING indicates that the Relaxed
> > Ordering Attribute should not be used on Transaction Layer Packets destined
> > for the PCIe End Node so flagged.  Initially flagged this way are Intel
> > E5-26xx Root Complex Ports which suffer from a Flow Control Credit
> > Performance Problem and AMD A1100 ARM ("SEATTLE") Root Complex Ports which
> > don't obey PCIe 3.0 ordering rules which can lead to Data Corruption.
> 
> So this is a good first step though might I suggest one other change.
> 
> We may want to add logic to the core PCIe code that clears the "Enable
> Relaxed Ordering" bit in the device control register for all devices
> hanging off of this root complex. Assuming the devices conform to the
> PCIe spec doing that should disable relaxed ordering in a device
> agnostic way that then enables us at a driver level to just enable the
> feature always without having to perform any checks for your flag. We
> could probably do that as a part of probing the PCIe interfaces
> hanging off of these devices.

I suppose you don't want to turn off RO completely on the device. When
traffic is targetted to mmio for peer to peer reasons RO has performance
upside. The specific issue with these root ports indicate limitation using 
RO for traffic targetting coherent memory.

> 
> > ---
> >  drivers/pci/quirks.c | 38 ++++++++++++++++++++++++++++++++++++++
> >  include/linux/pci.h  |  2 ++
> >  2 files changed, 40 insertions(+)
> >
> > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> > index f754453..4ae78b3 100644
> > --- a/drivers/pci/quirks.c
> > +++ b/drivers/pci/quirks.c
> > @@ -3979,6 +3979,44 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
> >                               quirk_tw686x_class);
> >
> >  /*
> > + * Some devices have problems with Transaction Layer Packets with the Relaxed
> > + * Ordering Attribute set.  Such devices should mark themselves and other
> > + * Device Drivers should check before sending TLPs with RO set.
> > + */
> > +static void quirk_relaxedordering_disable(struct pci_dev *dev)
> > +{
> > +       dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
> > +}
> > +
> > +/*
> > + * Intel E5-26xx Root Complex has a Flow Control Credit issue which can
> > + * cause performance problems with Upstream Transaction Layer Packets with
> > + * Relaxed Ordering set.
> > + */
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f02, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f04, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x8086, 0x6f08, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +
> > +/*
> > + * The AMD ARM A1100 (AKA "SEATTLE") SoC has a bug in its PCIe Root Complex
> > + * where Upstream Transaction Layer Packets with the Relaxed Ordering
> > + * Attribute clear are allowed to bypass earlier TLPs with Relaxed Ordering
> > + * set.  This is a violation of the PCIe 3.0 Transaction Ordering Rules
> > + * outlined in Section 2.4.1 (PCI Express(r) Base Specification Revision 3.0
> > + * November 10, 2010).  As a result, on this platform we can't use Relaxed
> > + * Ordering for Upstream TLPs.
> > + */
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a00, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a01, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +DECLARE_PCI_FIXUP_CLASS_EARLY(0x1022, 0x1a02, PCI_CLASS_NOT_DEFINED, 8,
> > +                             quirk_relaxedordering_disable);
> > +
> > +/*
> >   * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
> >   * values for the Attribute as were supplied in the header of the
> >   * corresponding Request, except as explicitly allowed when IDO is used."
> > diff --git a/include/linux/pci.h b/include/linux/pci.h
> > index eb3da1a..6764f66 100644
> > --- a/include/linux/pci.h
> > +++ b/include/linux/pci.h
> > @@ -178,6 +178,8 @@ enum pci_dev_flags {
> >         PCI_DEV_FLAGS_NO_PM_RESET = (__force pci_dev_flags_t) (1 << 7),
> >         /* Get VPD from function 0 VPD */
> >         PCI_DEV_FLAGS_VPD_REF_F0 = (__force pci_dev_flags_t) (1 << 8),
> > +       /* Don't use Relaxed Ordering for TLPs directed at this device */
> > +       PCI_DEV_FLAGS_NO_RELAXED_ORDERING = (__force pci_dev_flags_t) (1 << 9),
> >  };
> >
> >  enum pci_irq_reroute_variant {
> > --
> > 1.9.1
> >
