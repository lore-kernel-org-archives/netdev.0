From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 3/4] drivers/net/fec: Fix dual MAC support on i.MX28
Date: Tue, 22 Mar 2011 09:04:00 +0100
Message-ID: <19848.22512.18596.3017@ipc1.ka-ro>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
	<e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
	<20110322072832.GD28098@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <u.kleine-koenig@pengutronix.de>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:64354 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192Ab1CVIEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:04:04 -0400
In-Reply-To: <20110322072832.GD28098@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Shawn Guo writes:
> Hi Lothar,
>=20
> On Mon, Mar 21, 2011 at 05:37:35PM +0100, Lothar Wa=C3=9Fmann wrote:
> > The variant of the FEC chip found on i.MX28 features two distinct
> > ethernet MACs that both share a single MII interface. When
> > deconfiguring the eth0 interface, the MII interface is currently be=
ing
> > switched off, so that the second MAC won't work any more.
> >=20
> I'm wondering what the use case is you intend to support with this
> patch.
>=20
The patch enables the use of both MACs independently from each other.
Without this patch deconfiguring eth0 would leave eth1 in an unusable
state.

> > Make sure, the first MAC is never disabled when the second FEC devi=
ce
> > is registered.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/fec.c |   38 +++++++++++++++++++++++++++++++++-----
> >  1 files changed, 33 insertions(+), 5 deletions(-)
> >=20
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index 2436db8..3666524 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -82,6 +82,9 @@ static unsigned char macaddr[ETH_ALEN];
> >  module_param_array(macaddr, byte, NULL, 0);
> >  MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> > =20
> > +static int dual_mac;
> > +module_param(dual_mac, int, S_IRUGO);
> > +
>=20
> As you are detecting dual_mac in probe function, is this necessary?
>=20
Not really. I added this is only for debugging.

> >  #if defined(CONFIG_M5272)
> >  /*
> >   * Some hardware gets it MAC address out of local flash memory.
> > @@ -456,6 +459,8 @@ static void
> >  fec_stop(struct net_device *ndev)
> >  {
> >  	struct fec_enet_private *fep =3D netdev_priv(ndev);
> > +	const struct platform_device_id *id_entry =3D
> > +				platform_get_device_id(fep->pdev);
> > =20
> >  	/* We cannot expect a graceful transmit stop without link !!! */
> >  	if (fep->link) {
> > @@ -466,11 +471,22 @@ fec_stop(struct net_device *ndev)
> >  			printk("fec_stop : Graceful transmit stop did not complete !\n"=
);
> >  	}
> > =20
> > -	/* Whack a reset.  We should wait for this. */
> > -	writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
> > -	udelay(10);
> > -	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> > -	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> > +	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && dual_mac &&
> > +		fep->pdev->id =3D=3D 0) {
> > +		/* clear the RDAR/TDAR bits to stop recv/xmit,
> > +		 * but do not reset the controller since the second MAC
> > +		 * may still be using the MII interface and requires ETHER_EN
> > +		 * on the first MAC to be asserted for MII interrupts!
> > +		 */
> > +		writel(0, fep->hwp + FEC_ECNTRL);
> > +		writel(FEC_ECNTRL_ETHER_EN, fep->hwp + FEC_ECNTRL);
> > +	} else {
> > +		/* Whack a reset.  We should wait for this. */
> > +		writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
> > +		udelay(10);
> > +		writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> > +		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> > +	}
> >  }
> > =20
> >  static void
> > @@ -1135,6 +1151,8 @@ static int
> >  fec_enet_open(struct net_device *ndev)
> >  {
> >  	struct fec_enet_private *fep =3D netdev_priv(ndev);
> > +	const struct platform_device_id *id_entry =3D
> > +				platform_get_device_id(fep->pdev);
> >  	int ret;
> > =20
> >  	/* I should reset the ring buffers here, but I don't yet know
> > @@ -1145,6 +1163,14 @@ fec_enet_open(struct net_device *ndev)
> >  	if (ret)
> >  		return ret;
> > =20
> > +	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) &&
> > +		fep->pdev->id =3D=3D 0) {
> > +		/* ETHER_EN on first MAC has to be asserted
> > +		 * in order to generate MII interrupts
> > +		 */
> > +		fec_restart(ndev, 0);
> > +	}
> > +
>=20
> Is this relevant to the use case you intend to support?  Or something
> is broken without these codes?
>=20
Actually this is not necessary any more, since with this patch the
first MAC is not being disabled on close any more. Looks like a single
problem fixed in two different places...

> >  	/* Probe and connect to PHY when open the interface */
> >  	ret =3D fec_enet_mii_probe(ndev);
> >  	if (ret) {
> > @@ -1435,6 +1461,8 @@ fec_probe(struct platform_device *pdev)
> >  	if (ret)
> >  		goto failed_register;
> > =20
> > +	if (pdev->id > 0)
> > +		dual_mac =3D 1;
> >  	return 0;
> > =20
> Blank line above 'return 0;'?
>=20
OK.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
