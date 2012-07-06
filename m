From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Fri, 6 Jul 2012 17:26:45 -0400 (EDT)
Message-ID: <2138981415.303377.1341610005571.JavaMail.root@mail.savoirfairelinux.com>
References: <20120706200146.GA11931@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Nancy Lin <nancy.lin@smsc.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:42870 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932123Ab2GFV0s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 17:26:48 -0400
In-Reply-To: <20120706200146.GA11931@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Mail original -----
> De: "Francois Romieu" <romieu@fr.zoreil.com>
> =C3=80: "=C3=89meric Vigier" <emeric.vigier@savoirfairelinux.com>
> Cc: "Steve Glendinning" <steve@shawell.net>, "steve glendinning" <ste=
ve.glendinning@smsc.com>,
> netdev@vger.kernel.org, "Nancy Lin" <nancy.lin@smsc.com>
> Envoy=C3=A9: Vendredi 6 Juillet 2012 16:01:46
> Objet: Re: [PATCH] smsc95xx: support ethtool get_regs
>=20
> =C3=89meric Vigier <emeric.vigier@savoirfairelinux.com> :
> [...]
> > +static int smsc95xx_ethtool_getregslen(struct net_device *dev)
> > +{
> > +	/* all smsc95xx registers plus all phy registers */
> > +	return COE_CR - ID_REV + 1 + 32 * sizeof(u32);
>=20
> I do not see where ID_REV is accounted for in the loops below.
>=20
> s/32 */PHY_SPECIAL */ or s/PHY_SPECIAL/32/ below.

I will go for the second proposal. I love your sed syntax btw :-)

>=20
> I thought PHY registers were 16 bits wide. Moreover they are already
> available through smsc95xx_ioctl().

Yes, there are 16 bits wide according to smsc95xx.h.
But other smsc drivers define 32bit wide PHY regs. I made myself believ=
e that smsc would use the same PHY for each ethernet chip.
So would something like s/32 * sizeof(u32)/PHY_SPECIAL * sizeof(u16)/ s=
olve the issue here?

Concerning the ioctl, I found ethtool much easier to use. And I believe=
 smsc9514 is a very popular chipset, so this could help others debuggin=
g it.

>=20
> > +}
> > +
> > +static void
> > +smsc95xx_ethtool_getregs(struct net_device *netdev, struct
> > ethtool_regs *regs,
> > +			 void *buf)
> > +{
> > +	struct usbnet *dev =3D netdev_priv(netdev);
> > +	unsigned int i, j =3D 0, retval;
>=20
> 	unsigned int i, j, retval;
>=20
> > +	u32 *data =3D buf;
> > +
> > +	netif_dbg(dev, hw, dev->net, "ethtool_getregs\n");
>=20
> The tracing framework does provide almost the same information.

Do you mean LTT? I am not familiar with it, I should have a look.
I remove netif_dbg then.

>=20
> > +
> > +	retval =3D smsc95xx_read_reg(dev, ID_REV, &regs->version);
> > +	if (retval < 0) {
> > +		netdev_warn(dev->net, "REGS: cannot read ID_REV\n");
>=20
> s/dev->net/netdev/ ?

You are right, I also changed smsc95xx_ethtool_getregslen() definition =
to match this syntax.

>=20
>=20
> > +		return;
> > +	}
> > +
> > +	for (i =3D 0; i <=3D COE_CR; i +=3D (sizeof(u32))) {
> > +		retval =3D smsc95xx_read_reg(dev, i, &data[j++]);
>=20
> 	for (i =3D 0, j =3D 0; i <=3D COE_CR; i +=3D sizeof(u32), j++) {
> 		retval =3D smsc95xx_read_reg(dev, i, data + j);

I should change that in previous "for" loop as well I suppose?

>=20
> --
> Ueimor
>=20

Emeric
