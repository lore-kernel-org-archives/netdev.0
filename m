From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] [V3] net: emaclite: adding MDIO and phy lib support
Date: Tue, 9 Feb 2010 16:00:04 -0700
Message-ID: <ad1b9321-b7ad-47a6-93ca-ca260ff2a66d@SG2EHSMHS011.ehs.local>
References: <2ea396ca-3014-40f4-86ac-0e9f1aa82b5b@SG2EHSMHS005.ehs.local> <1d3f23371002091430hb550153u602c8e7c010381b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<jgarzik@pobox.com>, <grant.likely@secretlab.ca>,
	<jwboyer@linux.vnet.ibm.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "John Williams" <john.williams@petalogix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe001.messaging.microsoft.com ([207.46.51.75]:38625 "EHLO
	SG2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752320Ab0BIXBB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 18:01:01 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <1d3f23371002091430hb550153u602c8e7c010381b9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: John Williams [mailto:john.williams@petalogix.com]
> Sent: Tuesday, February 09, 2010 3:30 PM
> To: John Linn
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; jgarzik@pobox.co=
m; grant.likely@secretlab.ca;
> jwboyer@linux.vnet.ibm.com; Sadanand Mutyala
> Subject: Re: [PATCH] [V3] net: emaclite: adding MDIO and phy lib supp=
ort
>=20
> Hi John,
>=20
> Sorry If I'm painting bike-sheds here, just one tiny tweak might be i=
n
> order to standardise your mutex_unlock exit path:
>=20
> > +static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, in=
t reg)
> > +{
> > + =A0 =A0 =A0 struct net_local *lp =3D bus->priv;
> > + =A0 =A0 =A0 u32 ctrl_reg;
> > + =A0 =A0 =A0 u32 rc;
> > +
> > + =A0 =A0 =A0 mutex_lock(&lp->mdio_mutex);
> > +
> > + =A0 =A0 =A0 if (xemaclite_mdio_wait(lp)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&lp->mdio_mutex);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> > + =A0 =A0 =A0 }
>=20
> [snip]
>=20
>=20
> > + =A0 =A0 =A0 if (xemaclite_mdio_wait(lp)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&lp->mdio_mutex);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ETIMEDOUT;
> > + =A0 =A0 =A0 }
>=20
> [snip]
>=20
>=20
> > + =A0 =A0 =A0 dev_dbg(&lp->ndev->dev,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "xemaclite_mdio_read(phy_id=3D%i, reg=
=3D%x) =3D=3D %x\n",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id, reg, rc);
> > +
> > + =A0 =A0 =A0 return rc;
>=20
> Can this be better expressed like this:
>=20
> my_func() {
>   mutex_lock()
> ..
>=20
>   if(some error) {
>     rc=3D-ETIMEDOUT;
>     goto out_unlock;
>   }
>   ...
>=20
>   /* success path */
>   rc=3D0;
> ..
> out_unlock:
>   mutex_unlock()
>   return rc;
> }
>=20
>=20
> Is this style still favoured in driver exit paths?

It looks to me like the mutex is not needed in the driver mdio function=
s as there's a mutex in the mdiobus functions already.

Am I wrong about that?

Thanks,
John

=46rom phy/mdio_bus.c

int mdiobus_read(struct mii_bus *bus, int addr, u16 regnum)
{
	int retval;

	BUG_ON(in_interrupt());

	mutex_lock(&bus->mdio_lock);
	retval =3D bus->read(bus, addr, regnum);
	mutex_unlock(&bus->mdio_lock);

	return retval;
}
EXPORT_SYMBOL(mdiobus_read);

int mdiobus_write(struct mii_bus *bus, int addr, u16 regnum, u16 val)
{
	int err;

	BUG_ON(in_interrupt());

	mutex_lock(&bus->mdio_lock);
	err =3D bus->write(bus, addr, regnum, val);
	mutex_unlock(&bus->mdio_lock);

	return err;
}
EXPORT_SYMBOL(mdiobus_write);

>=20
> Thanks,
>=20
> John
> --
> John Williams, PhD, B.Eng, B.IT
> PetaLogix - Linux Solutions for a Reconfigurable World
> w: www.petalogix.com  p: +61-7-30090663  f: +61-7-30090663


This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and contain(s) confidential information that may be pro=
prietary, privileged or copyrighted under applicable law. If you are no=
t the intended recipient, do not read, copy, or forward this email mess=
age or any attachments. Delete this email message and any attachments i=
mmediately.


