From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/7] net: stmmac: Program RX queue size and flow control
Date: Thu, 9 Mar 2017 20:42:31 +0100
Message-ID: <20170309194231.GD5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-6-thierry.reding@gmail.com>
 <74ee5bff-8893-ebd4-bcf8-bb92c476f581@kapsi.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="AbQceqfdZEv+FvjW"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <74ee5bff-8893-ebd4-bcf8-bb92c476f581-/1wQRMveznE@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--AbQceqfdZEv+FvjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27, 2017 at 12:09:02PM +0200, Mikko Perttunen wrote:
> On 23.02.2017 19:24, Thierry Reding wrote:
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
> >=20
> >  #define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
> > +#define MTL_OP_MODE_TQS_SHIFT		16
> >=20
> >  #define MTL_OP_MODE_TTC_MASK		0x70
> >  #define MTL_OP_MODE_TTC_SHIFT		4
> > @@ -193,6 +194,17 @@ enum power_event {
> >  #define MTL_OP_MODE_TTC_384		(6 << MTL_OP_MODE_TTC_SHIFT)
> >  #define MTL_OP_MODE_TTC_512		(7 << MTL_OP_MODE_TTC_SHIFT)
> >=20
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
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers=
/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > index 8d249f3b34c8..03d230201960 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > @@ -185,8 +185,9 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr=
, u32 riwt)
> >  }
> >=20
> >  static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
> > -				    int rxmode, u32 channel)
> > +				    int rxmode, u32 channel, int rxfifosz)
> >  {
> > +	unsigned int rqs =3D rxfifosz / 256 - 1;
> >  	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
> >=20
> >  	/* Following code only done for channel 0, other channels not yet
> > @@ -252,6 +253,44 @@ static void dwmac4_dma_chan_op_mode(void __iomem *=
ioaddr, int txmode,
> >  			mtl_rx_op |=3D MTL_OP_MODE_RTC_128;
> >  	}
> >=20
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
> Are these values correct? In the 4096 case, rfd > rfa, in all other cases
> the other way around. In any case it would be useful to have a comment
> clarifying the thresholds in bytes.

I'll investigate. To be honest I simply took this from Stephen's U-Boot
driver since that's already tested. I trust Stephen, so I didn't bother
double-checking.

Thierry

--AbQceqfdZEv+FvjW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBsCYACgkQ3SOs138+
s6FXmQ//TIyqR2VPdsNK/q7yePkbJv84qhX34+UMPhvcaC+FpGMEDdETDeHjgu/M
dichSjPP70oq+Gxoxj+NkBzlObYRTSTqKkzQ3KAbYWPmbfdVrJUnHvK28k626+ku
2OjhEF3EwHADG8AvLUyTJXo4e/WjEhmiL2ohqCyKMXtDbpFprjEb/IgtZczso7aD
/spauHSKIY3x/mEwRzeLycHE8Iq3o+Nserf44w/dWGSoZdNTeswvXalxu4c9NWd3
p8RGH1kLeE0PvF7zunIPSeKpMcS+wTXGHJyIqarMae4G8DtQBengbMOULAaSF6yQ
8aAerPhOpO+I1FOFtvSfsXqM8Qx63r4FQGxPExQShlqxG4QAi6aCysziEICiJ7hR
Fu7jovALhQa8FMchuXNPrzRPDMnNZvgcxnqlMuyDu3ZwjakefWjtmH5HnaFpYV4t
NPLaXEZO11vO4HIEz23ftN+v6oQjvs+xnFs6RfsoZYSVQuv/tctcubuFQa5TU5vm
NKcAJpYulI6eR9DeV9ZVcsY/jZUDXyh3jglBp/5prATEN1M1t9HE9uZlb/Ja+50I
GvoJwtHvGZoBndtqxnwC6qTsQj85lfW/ska0QKQavOlUShXGZPPm0S1D+s2UL8H0
0vgKMFWk/axvOH9glR8ZHZo6y3m8dZVyfE3xnmGQcP5wehaLWSg=
=ZX0h
-----END PGP SIGNATURE-----

--AbQceqfdZEv+FvjW--
