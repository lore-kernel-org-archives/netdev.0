From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/7] net: stmmac: Program RX queue size and flow control
Date: Thu, 9 Mar 2017 21:44:09 +0100
Message-ID: <20170309204409.GG5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-6-thierry.reding@gmail.com>
 <74ee5bff-8893-ebd4-bcf8-bb92c476f581@kapsi.fi>
 <20170309194231.GD5554@ulmo.ba.sec>
 <83aaa3b1-a2d4-8ddd-d31a-2fd6c653e3d1@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="TmwHKJoIRFM7Mu/A"
Cc: Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <83aaa3b1-a2d4-8ddd-d31a-2fd6c653e3d1-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--TmwHKJoIRFM7Mu/A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 09, 2017 at 01:18:11PM -0700, Stephen Warren wrote:
> On 03/09/2017 12:42 PM, Thierry Reding wrote:
> > On Mon, Feb 27, 2017 at 12:09:02PM +0200, Mikko Perttunen wrote:
> > > On 23.02.2017 19:24, Thierry Reding wrote:
> > > > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > > >=20
> > > > Program the receive queue size based on the RX FIFO size and enable
> > > > hardware flow control for large FIFOs.
>=20
> > > > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/dri=
vers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
>=20
> > > > @@ -252,6 +253,44 @@ static void dwmac4_dma_chan_op_mode(void __iom=
em *ioaddr, int txmode,
> > > >  			mtl_rx_op |=3D MTL_OP_MODE_RTC_128;
> > > >  	}
> > > >=20
> > > > +	mtl_rx_op &=3D ~MTL_OP_MODE_RQS_MASK;
> > > > +	mtl_rx_op |=3D rqs << MTL_OP_MODE_RQS_SHIFT;
> > > > +
> > > > +	/* enable flow control only if each channel gets 4 KiB or more FI=
FO */
> > > > +	if (rxfifosz >=3D 4096) {
> > > > +		unsigned int rfd, rfa;
> > > > +
> > > > +		mtl_rx_op |=3D MTL_OP_MODE_EHFC;
> > > > +
> > > > +		switch (rxfifosz) {
> > > > +		case 4096:
> > > > +			rfd =3D 0x03;
> > > > +			rfa =3D 0x01;
> > > > +			break;
> > > > +
> > > > +		case 8192:
> > > > +			rfd =3D 0x06;
> > > > +			rfa =3D 0x0a;
> > > > +			break;
> > > > +
> > > > +		case 16384:
> > > > +			rfd =3D 0x06;
> > > > +			rfa =3D 0x12;
> > > > +			break;
> > > > +
> > > > +		default:
> > > > +			rfd =3D 0x06;
> > > > +			rfa =3D 0x1e;
> > > > +			break;
> > > > +		}
> > >=20
> > > Are these values correct? In the 4096 case, rfd > rfa, in all other c=
ases
> > > the other way around. In any case it would be useful to have a comment
> > > clarifying the thresholds in bytes.
> >=20
> > I'll investigate. To be honest I simply took this from Stephen's U-Boot
> > driver since that's already tested. I trust Stephen, so I didn't bother
> > double-checking.
>=20
> I don't recall for sure, but I think these values came directly from eith=
er
> the upstream kernel (the non-stmmac driver) or NV downstream kernel EQoS
> driver, and I re-used them without investigating. I'm not even sure if the
> outer if() expression is true; these numbers might not even end up being
> used?

Yes they are, and they were even the key to making the STMMAC driver
work on Tegra186. Without programming these fields the driver would fail
to receive any packets.

I noticed that you had comments in the U-Boot driver that I had left out
(most likely because I forgot to add them after cleaning up after the
hacking session). Here's the original extract from U-Boot:

		/*
		 * Set Threshold for Activating Flow Contol space for min 2
		 * frames ie, (1500 * 1) =3D 1500 bytes.
		 *
		 * Set Threshold for Deactivating Flow Contol for space of
		 * min 1 frame (frame size 1500bytes) in receive fifo
		 */
		if (rqs =3D=3D ((4096 / 256) - 1)) {
			/*
			 * This violates the above formula because of FIFO size
			 * limit therefore overflow may occur inspite of this.
			 */
			rfd =3D 0x3;	/* Full-3K */
			rfa =3D 0x1;	/* Full-1.5K */
		} else if (rqs =3D=3D ((8192 / 256) - 1)) {
			rfd =3D 0x6;	/* Full-4K */
			rfa =3D 0xa;	/* Full-6K */
		} else if (rqs =3D=3D ((16384 / 256) - 1)) {
			rfd =3D 0x6;	/* Full-4K */
			rfa =3D 0x12;	/* Full-10K */
		} else {
			rfd =3D 0x6;	/* Full-4K */
			rfa =3D 0x1E;	/* Full-16K */
		}

Two things are strange about this:

	1) the first comment says "2 frames", but the threshold value is
	   clearly just one frame

	2) the first set of rfd/rfa values has a wrong comment, by my
	   understanding: Full-3K should really be Full-2.5K

The encoding of these values is essentially:

	threshold =3D full - (1K + value * 0.5K)

Here's my updated version from the kernel driver:

		/*
		 * Set Threshold for Activating Flow Control to min 2 frames,
		 * i.e. 1500 * 2 =3D 3000 bytes.
		 *
		 * Set Threshold for Deactivating Flow Control to min 1 frame,
		 * i.e. 1500 bytes.
		 */
		switch (rxfifosz) {
		case 4096:
			/*
			 * This violates the above formula because of FIFO size
			 * limit therefore overflow may occur in spite of this.
			 */
			rfd =3D 0x03; /* Full-2.5K */
			rfa =3D 0x01; /* Full-1.5K */
			break;

		case 8192:
			rfd =3D 0x06; /* Full-4K */
			rfa =3D 0x0a; /* Full-6K */
			break;

		case 16384:
			rfd =3D 0x06; /* Full-4K */
			rfa =3D 0x12; /* Full-10K */
			break;

		default:
			rfd =3D 0x06; /* Full-4K */
			rfa =3D 0x1e; /* Full-16K */
			break;
		}

As best as I can tell these values are within the constraints given in
the TRM and they also make sense to me for the purposes they're used
for.

Thierry

--TmwHKJoIRFM7Mu/A
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBvpYACgkQ3SOs138+
s6Gryg/8DOM5OWEz57fxP/P6nyKSWX0RAg2xW9EQXsBb1FiloixLOQCEvLW8X+m0
UFZH1MLR71LqJSSzvD1ltEaUbeUQBu7fnFnXHu1s39Sh/KO8Z9V6UlNVQTLYNSfX
q0EEuPT69a8/gR6FITRB5/9VfDWV5x6cAphJPkCv8DXILa90jn3tMY+fqSM8vmtL
7hCp03Vok3PkEq/xO1CoVZpxnuXnMpUskjd0RxhwwDp7QFo0vItSSCwnkW46c1WL
J0prHK86ud4UhhDpUrzspYBw+almyo+efqlkv+GWhQvDl/dwbOWMhxna6rsjUPZs
G9B7rJteocWaZs8QIp0p2JV9apF32zZF5KB/Nh3d8BqaQ8rLGkgrSWbrDBrrFEMs
n0sbBcnaLFU3BNJ2tW8m3tjOQ6pdN7OZSkDATyg34xcNlUppNz1TYrqn9Jj3VCW8
dlbCrkXxePgTZwi0hPMbUHEqgCqtfLun4edmxPP47u/6ZoPATzAs0tGOEJ2ancQu
RIT2G5h02JNsu/+zrNpdA2hPtgJta6gAjJhp1oM3Ylp717TLigEP+JTDNBukoT+H
PAZHHWup+FWkZdlboNj2WRcwlm8YjzRRXz7MTIDxj+jKOY5yDmauhOBW4yaV0vDN
qIEU6gEGygpQ7tI7t/JuTFK1QBZPjxogDsysovht8mBf0Dv96uY=
=xtmq
-----END PGP SIGNATURE-----

--TmwHKJoIRFM7Mu/A--
