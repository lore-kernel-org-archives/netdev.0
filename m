From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI: MSI: Remove unsafe and unnecessary hardware access
Date: Fri, 15 Oct 2010 13:06:29 -0700
Message-ID: <20101015130629.046d3357@jbarnes-desktop>
References: <1276564403.19104.28.camel@HP1>
	<1276802196.2083.12.camel@achroite.uk.solarflarecom.com>
	<AANLkTi=F19SdRNfhQe_R9sqwqCbFtAUCFu+09KFgzdAK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Michael Chan <mchan@broadcom.com>,
	Matthew Wilcox <matthew@wil.cx>, linux-pci@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Emil S Tantilov <emils.tantilov@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=F19SdRNfhQe_R9sqwqCbFtAUCFu+09KFgzdAK@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2010 11:26:08 -0700
Emil S Tantilov <emils.tantilov@gmail.com> wrote:

> On Thu, Jun 17, 2010 at 12:16 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > During suspend on an SMP system, {read,write}_msi_msg_desc() may be
> > called to mask and unmask interrupts on a device that is already in=
 a
> > reduced power state. =C2=A0At this point memory-mapped registers in=
cluding
> > MSI-X tables are not accessible, and config space may not be fully
> > functional either.
> >
> > While a device is in a reduced power state its interrupts are
> > effectively masked and its MSI(-X) state will be restored when it i=
s
> > brought back to D0. =C2=A0Therefore these functions can simply read=
 and
> > write msi_desc::msg for devices not in D0.
> >
> > Further, read_msi_msg_desc() should only ever be used to update a
> > previously written message, so it can always read msi_desc::msg
> > and never needs to touch the hardware.
> >
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > On Mon, 2010-06-14 at 18:13 -0700, Michael Chan wrote:
> >> I'm debugging the bnx2 driver which doesn't work after suspend/res=
ume if
> >> it is running in MSI-X mode. =C2=A0The problem is that during susp=
end, the
> >> MSI-X vectors are disabled by the following sequence on x86:
> >>
> >> take_cpu_down() -> cpu_disable_common() -> fixup_irqs()
> >>
> >> The MSI-X address/data used to disable the vectors are remembered =
in the
> >> above sequence. During resume, these address/data are then program=
med
> >> back to the device during pci_restore_state(), causing all the vec=
tors
> >> to remain disabled.
> >
> > That's not quite what I see. =C2=A0What I see is that the message i=
s read
> > back from the table *after* the driver's suspend method has been ca=
lled.
> > At this point the device is already in D3 and memory-mapped registe=
rs
> > are not accessible, so we get random bits as the message. =C2=A0At =
least,
> > that's what I see happening with the sfc driver.
> >
> >> Some drivers call free_irq() during suspend and request_irq() duri=
ng
> >> resume, and that should avoid the problem. =C2=A0bnx2 and some oth=
er drivers
> >> do not do that. =C2=A0These drivers rely on pci_restore_state() to=
 restore
> >> the MSI-X vectors to the same working state before suspend.
> >>
> >> What's the right way to fix this? =C2=A0Thanks.
> >
> > This is my attempt, which works for sfc. =C2=A0See if it works for =
bnx2.
> >
> > Ben.
> >
> > =C2=A0drivers/pci/msi.c | =C2=A0 34 +++++++++++--------------------=
---
> > =C2=A01 files changed, 11 insertions(+), 23 deletions(-)
> >
> > diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> > index 77b68ea..03f04dc 100644
> > --- a/drivers/pci/msi.c
> > +++ b/drivers/pci/msi.c
> > @@ -196,30 +196,15 @@ void unmask_msi_irq(unsigned int irq)
> > =C2=A0void read_msi_msg_desc(struct irq_desc *desc, struct msi_msg =
*msg)
> > =C2=A0{
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct msi_desc *entry =3D get_irq_desc_=
msi(desc);
> > - =C2=A0 =C2=A0 =C2=A0 if (entry->msi_attrib.is_msix) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void __iomem *ba=
se =3D entry->mask_base +
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 entry->msi_attrib.entry_nr * PCI_MSIX_ENTRY_SIZE;
> >
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 msg->address_lo =
=3D readl(base + PCI_MSIX_ENTRY_LOWER_ADDR);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 msg->address_hi =
=3D readl(base + PCI_MSIX_ENTRY_UPPER_ADDR);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 msg->data =3D re=
adl(base + PCI_MSIX_ENTRY_DATA);
> > - =C2=A0 =C2=A0 =C2=A0 } else {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pci_dev *=
dev =3D entry->dev;
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int pos =3D entr=
y->msi_attrib.pos;
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u16 data;
> > + =C2=A0 =C2=A0 =C2=A0 /* We do not touch the hardware (which may n=
ot even be
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* accessible at the moment) but return=
 the last message
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* written. =C2=A0Assert that this is v=
alid, assuming that
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* valid messages are not all-zeroes. *=
/
> > + =C2=A0 =C2=A0 =C2=A0 BUG_ON(!(entry->msg.address_hi | entry->msg.=
address_lo |
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0entry->msg=
=2Edata));
> >
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pci_read_config_=
dword(dev, msi_lower_address_reg(pos),
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &msg=
->address_lo);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (entry->msi_a=
ttrib.is_64) {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pci_read_config_dword(dev, msi_upper_address_reg(pos),
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 &msg->address_hi);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pci_read_config_word(dev, msi_data_reg(pos, 1), &data);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 msg->address_hi =3D 0;
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pci_read_config_word(dev, msi_data_reg(pos, 0), &data);
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 msg->data =3D da=
ta;
> > - =C2=A0 =C2=A0 =C2=A0 }
> > + =C2=A0 =C2=A0 =C2=A0 *msg =3D entry->msg;
> > =C2=A0}
> >
> > =C2=A0void read_msi_msg(unsigned int irq, struct msi_msg *msg)
> > @@ -232,7 +217,10 @@ void read_msi_msg(unsigned int irq, struct msi=
_msg *msg)
> > =C2=A0void write_msi_msg_desc(struct irq_desc *desc, struct msi_msg=
 *msg)
> > =C2=A0{
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct msi_desc *entry =3D get_irq_desc_=
msi(desc);
> > - =C2=A0 =C2=A0 =C2=A0 if (entry->msi_attrib.is_msix) {
> > +
> > + =C2=A0 =C2=A0 =C2=A0 if (entry->dev->current_state !=3D PCI_D0) {
>=20
> This check exposed a problem in ixgb (patch is on the way) where
> pci_disable_device() was not being called in ixgb_remove(). As a
> result the current_state was set to PCI_UNKNOWN and the interface
> failed to work on subsequent load of the driver.
>=20
> Even though the problem was in ixgb, it made me wonder about this
> check as the presumption here (low power state) may not always be
> true. Like in the case of unloading a driver, which sets
> dev->current_state to PCI_UNKNOWN which is not a representation of th=
e
> _real_ state of the device (actual state could be D0).
>=20
> BTW - quick search shows other drivers that could potentially suffer
> the faith of ixgb due to lack of pci_disable_device() call on removal=
=2E

Yeah we just ran into this in the DRM layer as well; which does a
pci_enable_device but never calls _disable, so we're stuck with
potentially stale state.

I came up with the below to address that, but really I don't like the
idea of nested pci_enable_device() calls at all.  But I haven't looked
at the latest Wireless USB stuff to see if those drivers still rely on
it.

--=20
Jesse Barnes, Intel Open Source Technology Center

diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
index 7fa3cbd..37facc1 100644
--- a/drivers/pci/pci.c
+++ b/drivers/pci/pci.c
@@ -994,6 +994,18 @@ static int __pci_enable_device_flags(struct pci_de=
v *dev,
 	int err;
 	int i, bars =3D 0;
=20
+	/*
+	 * Power state could be unknown at this point, either due to a fresh
+	 * boot or a device removal call.  So get the current power state
+	 * so that things like MSI message writing will behave as expected
+	 * (e.g. if the device really is in D0 at enable time).
+	 */
+	if (dev->pm_cap) {
+		u16 pmcsr;
+		pci_read_config_word(dev, dev->pm_cap + PCI_PM_CTRL, &pmcsr);
+		dev->current_state =3D (pmcsr & PCI_PM_CTRL_STATE_MASK);
+	}
+
 	if (atomic_add_return(1, &dev->enable_cnt) > 1)
 		return 0;		/* already enabled */
=20
