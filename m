From: John Linn <John.Linn@xilinx.com>
Subject: RE: phy address in the device tree, vs auto probing
Date: Wed, 10 Feb 2010 09:52:21 -0700
Message-ID: <7d35ae9a-9ac0-46e6-8817-15315e0dcc07@SG2EHSMHS004.ehs.local>
References: <Acqp3tpO+gBYUakZQ7SaeBzVIkh6WA==> <4dfe033d-c308-45e0-9c7e-9fc60c6cad8f@SG2EHSMHS013.ehs.local> <fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Grant Likely" <grant.likely@secretlab.ca>,
	"devicetree-discuss" <devicetree-discuss@lists.ozlabs.org>,
	"netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe005.messaging.microsoft.com ([207.46.51.79]:7784 "EHLO
	SG2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754820Ab0BJQw5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 11:52:57 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <fa686aa41002100843o7a1d4160q8fb01768ad48dcf4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of=
 Grant Likely
> Sent: Wednesday, February 10, 2010 9:44 AM
> To: John Linn; devicetree-discuss; netdev
> Subject: Re: phy address in the device tree, vs auto probing
>=20
> (cc'ing devicetree-discuss and netdev mailing lists)
>=20
> On Tue, Feb 9, 2010 at 4:23 PM, John Linn <John.Linn@xilinx.com> wrot=
e:
> > Hi Grant,
> >
> > I notice that the OF driver for the mdio bus is not doing auto prob=
ing.
> >
> > As we start putting in the phy layer in the emac drivers, the devic=
e
> > trees tend to have the phy address in them, but we're not sure we r=
eally
> > like that.
> >
> > We really think that being able to let the kernel find the phy addr=
ess
> > is a big benefit, otherwise this is one other piece of info the use=
r has
> > to know and get right.
> >
> > Am I missing something here?
>=20
> No, you're not really missing something, but there is an inherent
> complexity in what you're wanting to do.  Like i2c, MDIO is one of
> those busses that is hard to probe reliable.  Some PHYs respond on
> more than one address, and there is no way to determine which MAC a
> PHY is wired up to.  Many PHYs can live on a single MDIO bus.  MACs
> with their own MDIO busses may still get wired to a PHY on a differen=
t
> bus.
>=20
> In the simple case where there is a one:one:one relationship between
> MAC, MDIO bus and PHY, then it should be okay to probe the PHY,
> correct?  The question then must be asked; how does the kernel
> determine that it can use the simple case?  Nobody has yet defined a
> way to describe that in the device tree; mostly because nobody has
> needed to yet.
>=20
> So, it is possible to do what you want, but you need a way to
> *explicitly* ask for that behaviour.  ie, some way to indicate in a
> MAC node which MDIO bus the phy is on, and that the phy needs to be
> probed for.  I think this should only be an option when the MDIO bus
> has only one PHY.  Come up with a proposal and post it to the
> devicetree-discuss mailing list.

Here's a couple ideas. See what everyone thinks as I'm not stuck on eit=
her.

Thanks,
John

1. What if we just don't specific a phy address with a reg property whi=
ch would specify to auto probe it and find the phy as illustrated below=
?


		Ethernet_MAC: ethernet@81000000 {
			#address-cells =3D <1>;
			#size-cells =3D <1>;
			phy-handle =3D <&phy0>;=20
			mdio {
				#address-cells =3D <1>;
				#size-cells =3D <0>;
				phy0: phy@7 {
				} ;=20
			} ;

2. Or a special value (-1 or something not 0 - 31) in the phy address t=
hat specifies to auto probe as illustrated below.

		Ethernet_MAC: ethernet@81000000 {
			#address-cells =3D <1>;
			#size-cells =3D <1>;
			phy-handle =3D <&phy0>;=20
			mdio {
				#address-cells =3D <1>;
				#size-cells =3D <0>;
				phy0: phy@7 {
					reg =3D <-1>;
				} ;=20
			} ;

>=20
> g.
>=20
> >
> > Thanks,
> > John
> >
> >
> > int of_mdiobus_register(struct mii_bus *mdio, struct device_node *n=
p)
> > {
> > =A0 =A0 =A0 =A0struct phy_device *phy;
> > =A0 =A0 =A0 =A0struct device_node *child;
> > =A0 =A0 =A0 =A0int rc, i;
> >
> > =A0 =A0 =A0 =A0/* Mask out all PHYs from auto probing. =A0Instead t=
he PHYs listed
> > in
> > =A0 =A0 =A0 =A0 * the device tree are populated after the bus has b=
een
> > registered */
> > =A0 =A0 =A0 =A0mdio->phy_mask =3D ~0;
> >
> > This email and any attachments are intended for the sole use of the=
 named recipient(s) and
> contain(s) confidential information that may be proprietary, privileg=
ed or copyrighted under
> applicable law. If you are not the intended recipient, do not read, c=
opy, or forward this email
> message or any attachments. Delete this email message and any attachm=
ents immediately.
> >
> >
> >
>=20
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


