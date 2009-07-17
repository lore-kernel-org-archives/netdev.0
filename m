From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 2/2 v2] MPC52xx FEC: be more conservative when setting
	MII_SPEED register
Date: Fri, 17 Jul 2009 11:47:25 +0200
Message-ID: <20090717094725.GC3150@pengutronix.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de> <1247780546-4426-2-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rQ2U398070+RC21q"
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54895 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934323AbZGQJrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 05:47:31 -0400
Content-Disposition: inline
In-Reply-To: <1247780546-4426-2-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rQ2U398070+RC21q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi Wolfgang,

On Thu, Jul 16, 2009 at 11:42:26PM +0200, Wolfgang Denk wrote:
> This patch adds error checking and prevents clobbering unrelated bits
> (reserved bits or the DIS_PREAMBLE bit) when writing the MII_SPEED
> register on MPC52xx systems.
>=20
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>
> ---
>  drivers/net/fec_mpc52xx.c     |    2 +-
>  drivers/net/fec_mpc52xx_phy.c |   21 ++++++++++++++++++---
>  2 files changed, 19 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index cc78633..b69d440 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -639,7 +639,7 @@ static void mpc52xx_fec_hw_init(struct net_device *de=
v)
>  	/* set phy speed.
>  	 * this can't be done in phy driver, since it needs to be called
>  	 * before fec stuff (even on resume) */
> -	out_be32(&fec->mii_speed, priv->mdio_speed);
> +	clrsetbits_be32(&fec->mii_speed, 0x7E, priv->mdio_speed);
>  }

In the probe-function when mdio_speed is set, there is still the old formula
used. Wouldn't that be better in sync?

> =20
>  /**
> diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
> index 31e6d62..4c33dc5 100644
> --- a/drivers/net/fec_mpc52xx_phy.c
> +++ b/drivers/net/fec_mpc52xx_phy.c
> @@ -70,7 +70,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of,
>  	struct mpc52xx_fec_mdio_priv *priv;
>  	struct resource res =3D {};
>  	int err;
> -	int i;
> +	int i, clock, speed;
> =20
>  	bus =3D mdiobus_alloc();
>  	if (bus =3D=3D NULL)
> @@ -105,8 +105,23 @@ static int mpc52xx_fec_mdio_probe(struct of_device *=
of,
>  	dev_set_drvdata(dev, bus);
> =20
>  	/* set MII speed */
> -	out_be32(&priv->regs->mii_speed,
> -		((mpc5xxx_get_bus_frequency(of->node) >> 20) / 5) << 1);
> +	clock =3D mpc5xxx_get_bus_frequency(of->node);
> +	if (!clock) {
> +		dev_err(&of->dev, "could not determine IPS/IPB clock\n");
> +		goto out_unmap;
> +	}
> +
> +	/* scale for a MII clock <=3D 2.5 MHz */
> +	speed =3D (clock + 2499999) / 2500000;
> +
> +	/* only 6 bits (25:30) available for MII speed */
> +	if (speed > 0x3F) {
> +		speed =3D 0x3F;
> +		dev_err(&of->dev, "MII clock (%d Hz) exceeds max (2.5 MHz)\n",
> +			clock / speed);
> +	}
> +
> +	clrsetbits_be32(&priv->regs->mii_speed, 0x7E, speed << 1);
> =20
>  	err =3D of_mdiobus_register(bus, np);
>  	if (err)
> --=20
> 1.6.0.6
>=20
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--rQ2U398070+RC21q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpgSK0ACgkQD27XaX1/VRuEqACfUu1KMIbgo9Vs36mi5mtEz3KQ
+9QAn0lgUfyMlN6QUa89hRwjV/s5KMWR
=Obfv
-----END PGP SIGNATURE-----

--rQ2U398070+RC21q--
