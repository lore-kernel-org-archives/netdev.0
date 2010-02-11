From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V4] net: emaclite: adding MDIO and phy lib support
Date: Thu, 11 Feb 2010 14:22:26 -0700
Message-ID: <680426f9-4e0f-4840-abad-223bf04ef82d@SG2EHSMHS018.ehs.local>
References: <e9ea9b59-9435-4712-a854-2c46046eb08e@SG2EHSMHS005.ehs.local> <fa686aa41002111316n13ce32bcyc8e5186c4776e1b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jgarzik@pobox.com>, <jwboyer@linux.vnet.ibm.com>,
	<john.williams@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe005.messaging.microsoft.com ([207.46.51.79]:46605 "EHLO
	SG2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756186Ab0BKVXI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 16:23:08 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <fa686aa41002111316n13ce32bcyc8e5186c4776e1b4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of=
 Grant Likely
> Sent: Thursday, February 11, 2010 2:16 PM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; jgarzik@pobox.co=
m; jwboyer@linux.vnet.ibm.com;
> john.williams@petalogix.com; Sadanand Mutyala
> Subject: Re: [PATCH] [V4] net: emaclite: adding MDIO and phy lib supp=
ort
>=20
> On Thu, Feb 11, 2010 at 1:52 PM, John Linn <john.linn@xilinx.com> wro=
te:
> > These changes add MDIO and phy lib support to the driver as the
> > IP core now supports the MDIO bus.
> >
> > The MDIO bus and phy are added as a child to the emaclite in the de=
vice
> > tree as illustrated below.
> >
> > mdio {
> > =A0 =A0 =A0 =A0#address-cells =3D <1>;
> > =A0 =A0 =A0 =A0#size-cells =3D <0>;
> > =A0 =A0 =A0 =A0phy0: phy@7 {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "marvell,88e1111";
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <7>;
> > =A0 =A0 =A0 =A0} ;
> > }
> >
> > Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
> > Signed-off-by: John Linn <john.linn@xilinx.com>
> >
> > ---
> >
> > V2 - updated it for Grant's comments, except I couldn't find any ta=
bs
> > converted to white space issue, let's see if V2 has it also
> >
> > V3 - updated it for Grant's comments, aded mutex release when a tim=
eout
> > happens, and added Grant's acked by.
> >
> > V4 - removed the mutex as I realized the higher layer mdio calls al=
ready
> > use a mutex and there are no internal calls to the driver except in=
 open.
> > Didn't integrate John W comments since releasing mutex wasn't neede=
d.
> > ---
> > =A0drivers/net/Kconfig =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> > =A0drivers/net/xilinx_emaclite.c | =A0381 +++++++++++++++++++++++++=
+++++++++++-----
> > =A02 files changed, 339 insertions(+), 43 deletions(-)
> [...]
> > =A0/**
> > =A0* xemaclite_open - Open the network device
> > =A0* @dev: =A0 =A0 =A0 Pointer to the network device
> > =A0*
> > =A0* This function sets the MAC address, requests an IRQ and enable=
s interrupts
> > =A0* for the Emaclite device and starts the Tx queue.
> > + * It also connects to the phy device, if MDIO is included in Emac=
lite device.
> > =A0*/
> > =A0static int xemaclite_open(struct net_device *dev)
> > =A0{
> > @@ -656,14 +924,50 @@ static int xemaclite_open(struct net_device *=
dev)
> > =A0 =A0 =A0 =A0/* Just to be safe, stop the device first */
> > =A0 =A0 =A0 =A0xemaclite_disable_interrupts(lp);
> >
> > + =A0 =A0 =A0 if (lp->phy_node) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 bmcr;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev =3D of_phy_connect(lp->nd=
ev, lp->phy_node,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0xemaclite_adjust_link, 0,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0PHY_INTERFACE_MODE_MII);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lp->phy_dev) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&lp->ndev->de=
v, "of_phy_connect() failed\n");
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* EmacLite doesn't support giga-bit =
speeds */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->supported &=3D (PHY_BASI=
C_FEATURES);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->phy_dev->advertising =3D lp->phy_=
dev->supported;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Don't advertise 1000BASE-T Full/Ha=
lf duplex speeds */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 xemaclite_mdio_write(lp->mii_bus, lp-=
>phy_dev->addr,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0MII_CTRL1000, 0x00);
>=20
> Wait!  No.  This is wrong.  Sorry, I was all ready to ack this patch,
> but I just realized what was bothering me (and I should have clued
> into it earlier).  The driver cannot assume that the PHY is on an
> xemaclite MDIO bus.  It might be on a GPIO driven MDIO bus.  Or
> something else.  Calling xemaclite_mdio_{write,read} is not the right
> thing to do here.
>=20
> Instead, the driver should call the phy library function
> phy_write(lp->phy_dev, MII_CTRL1000, 0);  The phylib code will route
> it to the correct mdio bus.  It also takes care of grabbing the mutex
> lock.
>=20
> Make this fix, and then I can ack the driver.
>=20

Ok, no worries, one more spin, I'm getting pretty good at spinning it.

Will make those changes to the calls in open, retest and respin.

Thanks,
John

> Cheers,
> g.
>=20
>=20
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.


This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and contain(s) confidential information that may be pro=
prietary, privileged or copyrighted under applicable law. If you are no=
t the intended recipient, do not read, copy, or forward this email mess=
age or any attachments. Delete this email message and any attachments i=
mmediately.


