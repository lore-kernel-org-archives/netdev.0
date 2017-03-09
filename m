From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/7] net: stmmac: Program RX queue size and flow control
Date: Thu, 9 Mar 2017 20:44:25 +0100
Message-ID: <20170309194425.GE5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-6-thierry.reding@gmail.com>
 <ea26c03c-6ce0-ff66-dcb5-6f95cdf2caed@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="PGNNI9BzQDUtgA2J"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ea26c03c-6ce0-ff66-dcb5-6f95cdf2caed-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--PGNNI9BzQDUtgA2J
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 02, 2017 at 03:15:12PM +0000, Joao Pinto wrote:
> =C3=80s 5:24 PM de 2/23/2017, Thierry Reding escreveu:
> > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > Program the receive queue size based on the RX FIFO size and enable
> > hardware flow control for large FIFOs.
> >=20
> > Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/dwmac4.h     | 12 +++++++
> >  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c | 43 ++++++++++++++++=
++++++--
> >  2 files changed, 53 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net=
/ethernet/stmicro/stmmac/dwmac4.h
> > index db45134fddf0..9acc1f1252b3 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> > @@ -180,6 +180,7 @@ enum power_event {
> >  #define MTL_OP_MODE_TSF			BIT(1)
> > =20
> >  #define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
> > +#define MTL_OP_MODE_TQS_SHIFT		16
> > =20
> >  #define MTL_OP_MODE_TTC_MASK		0x70
> >  #define MTL_OP_MODE_TTC_SHIFT		4
> > @@ -193,6 +194,17 @@ enum power_event {
> >  #define MTL_OP_MODE_TTC_384		(6 << MTL_OP_MODE_TTC_SHIFT)
> >  #define MTL_OP_MODE_TTC_512		(7 << MTL_OP_MODE_TTC_SHIFT)
> > =20
> > +#define MTL_OP_MODE_RQS_MASK		GENMASK(29, 20)
> > +#define MTL_OP_MODE_RQS_SHIFT		20
> > +
> > +#define MTL_OP_MODE_RFD_MASK		GENMASK(19, 14)
> > +#define MTL_OP_MODE_RFD_SHIFT		14
> > +
> > +#define MTL_OP_MODE_RFA_MASK		GENMASK(13, 8)
> > +#define MTL_OP_MODE_RFA_SHIFT		8
> > +
> > +#define MTL_OP_MODE_EHFC		BIT(7)
> > +
> >  #define MTL_OP_MODE_RTC_MASK		0x18
> >  #define MTL_OP_MODE_RTC_SHIFT		3
> > =20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers=
/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > index 8d249f3b34c8..03d230201960 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > @@ -185,8 +185,9 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr=
, u32 riwt)
> >  }
> > =20
> >  static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
> > -				    int rxmode, u32 channel)
> > +				    int rxmode, u32 channel, int rxfifosz)
> >  {
> > +	unsigned int rqs =3D rxfifosz / 256 - 1;
> >  	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
> > =20
> >  	/* Following code only done for channel 0, other channels not yet
> > @@ -252,6 +253,44 @@ static void dwmac4_dma_chan_op_mode(void __iomem *=
ioaddr, int txmode,
> >  			mtl_rx_op |=3D MTL_OP_MODE_RTC_128;
> >  	}
> > =20
> > +	mtl_rx_op &=3D ~MTL_OP_MODE_RQS_MASK;
> > +	mtl_rx_op |=3D rqs << MTL_OP_MODE_RQS_SHIFT;
> > +
> > +	/* enable flow control only if each channel gets 4 KiB or more FIFO */
> > +	if (rxfifosz >=3D 4096) {
> > +		unsigned int rfd, rfa;
> > +
> > +		mtl_rx_op |=3D MTL_OP_MODE_EHFC;
> > +
> > +		switch (rxfifosz) {
> > +		case 4096:
> > +			rfd =3D 0x03;
> > +			rfa =3D 0x01;
> > +			break;
> > +
> > +		case 8192:
> > +			rfd =3D 0x06;
> > +			rfa =3D 0x0a;
> > +			break;
> > +
> > +		case 16384:
> > +			rfd =3D 0x06;
> > +			rfa =3D 0x12;
> > +			break;
> > +
> > +		default:
> > +			rfd =3D 0x06;
> > +			rfa =3D 0x1e;
> > +			break;
> > +		}
>=20
> Are these RFA and RFD values suitable to any setup using thresholds? Plea=
se
> justify their values in oerder for other developers to understand them.
>=20
> > +
> > +		mtl_rx_op &=3D ~MTL_OP_MODE_RFD_MASK;
> > +		mtl_rx_op |=3D rfd << MTL_OP_MODE_RFD_SHIFT;
> > +
> > +		mtl_rx_op &=3D ~MTL_OP_MODE_RFA_MASK;
> > +		mtl_rx_op |=3D rfa << MTL_OP_MODE_RFA_SHIFT;
> > +	}
> > +
> >  	writel(mtl_rx_op, ioaddr + MTL_CHAN_RX_OP_MODE(channel));
> > =20
> >  	/* Enable MTL RX overflow */
> > @@ -264,7 +303,7 @@ static void dwmac4_dma_operation_mode(void __iomem =
*ioaddr, int txmode,
> >  				      int rxmode, int rxfifosz)
> >  {
> >  	/* Only Channel 0 is actually configured and used */
> > -	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
> > +	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0, rxfifosz);
>=20
> Why not configure tx fifo as well, you already getting it from the featur=
es
> register.

Primarily I'm not initializing TX FIFO here because we don't pass the
size into this function. Secondarily, the default seems to work fine,
and therefore changing it didn't seem relevant.

Thierry

--PGNNI9BzQDUtgA2J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBsJkACgkQ3SOs138+
s6EuPg/9FLtLLJmttOkIblNeIGUtiRaBEaj7zHYAEGvn8KBPzMNngApsBZpL9jjb
JfHkWAfim8FPkuO4I0YDr3HD10WxiXTZiTz/9SbguynwKEkco+wXfo9mi1YDa9D5
cyZ/MNWynatIpcW6ub4toCVJJCUheYJLmOyySm22L3Y1DYYhVrOGoJ+I4ECf1MhI
J2iAnxW806pHbF8EoTmNd/wPcbuPkb/z1s2qcqDR60paikGYOzhxCmlmJcEEJOwP
BxdZga7kxQF601uKrCXX1nu5qfaERMZOupJXSbZRTNz6Q7P1q9/Mf6SL/w/NwrJK
7u38WvlI7+cN4hUhm3G671pG09VECjdV7vz6KvA22OCukLyxnhtZtPY+eRFeOWtW
gOD64hNJR+tLu0XQMu+n+5ohmSBd1qzjbD8mapH2qkH2ze8OLjCeoaZL7nF4fpBj
jxITPy9j9qwYcRMs6u5/i4GseEue7Inj00podXz4sKN98nZ/MfgOspD118ueqwr/
yh3CLRx44SIkHnAjsZtsorTvOCBa/JT8RacRUCnFt3dK/yDkt0LWOQ431n0PwSOw
TqFroqeoqOGLFTKEsN8EGBL/tV+Bz29sVjHPXg0na4P1OwqN/lyqQL4ZqOVNA5oy
ccsI8JT7UAka0ZfMfHTyR5vtr07CZUsqQktQqn0729pwv+V3+w0=
=gBaG
-----END PGP SIGNATURE-----

--PGNNI9BzQDUtgA2J--
