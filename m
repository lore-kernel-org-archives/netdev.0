From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: preserve
 MII/RMII setting in fec_stop()
Date: Wed, 7 Dec 2011 11:42:28 +0100
Message-ID: <20191.17172.493079.722098@ipc1.ka-ro>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	<d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323163127.git.LW@KARO-electronics.de>
	<20111207094146.GG5550@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207094146.GG5550@S2100-06.ap.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Shawn Guo writes:
> On Tue, Dec 06, 2011 at 11:27:14AM +0100, Lothar Wa=C3=9Fmann wrote:
> > Additionally to setting the ETHER_EN bit in FEC_ECNTRL the MII/RMII
> > setting in FEC_R_CNTRL needs to be preserved to keep the MII interf=
ace
>=20
> s/MII/RMII?  From what I see from imx28 and imx6q RM, the reset state
> for this setting is MII mode.
>=20
> > functional.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec.c |    5 ++++-
> >  1 files changed, 4 insertions(+), 1 deletions(-)
>=20
> I assume this is fixing a problem you are seeing on imx28 only.
> Do you see the problem on imx53/51?
>=20
No. i.MX53 uses the RMII gasket which is not affected by resetting the
controller. And imMX51 does not support RMII at all.

> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/eth=
ernet/freescale/fec.c
> > index 11534b9..ab0afb5 100644
> > --- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -515,6 +515,7 @@ fec_stop(struct net_device *ndev)
> >  	struct fec_enet_private *fep =3D netdev_priv(ndev);
> >  	const struct platform_device_id *id_entry =3D
> >  				platform_get_device_id(fep->pdev);
> > +	u32 rmii_mode =3D readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
>=20
> This bit is only available on ENET (imx28 and imx6q).  Do we want to
> do the same thing for FEC (imx25/27/35/51/53)?
>=20
No. AFAICT that's not necessary there.

> >  	/* We cannot expect a graceful transmit stop without link !!! */
> >  	if (fep->link) {
> > @@ -531,8 +532,10 @@ fec_stop(struct net_device *ndev)
> >  	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
> > =20
> >  	/* We have to keep ENET enabled to have MII interrupt stay workin=
g */
> > -	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
> > +	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
> >  		writel(2, fep->hwp + FEC_ECNTRL);
> > +		writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
> > +	}
> >  }
>=20
> On imx6q, we have two bits, bit 6 and 8 of FEC_R_CNTRL, to select MII
> interface among MII, RMII and RGMII modes.  I'm not sure if we will
> run into the same problem for RGMII mode.  What's your test setup?
> I would try to reproduce it here.
>=20
I'm using a TX28 which has the Ethernet PHY connected in RMII
mode. You should see the problem, if you unplug the ethernet cable on
a configured link. Without this patch the kernel will not detect when
the cable is plugged back in.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
