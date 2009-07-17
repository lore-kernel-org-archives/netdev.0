From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 1/2 v4] fs_enet/mii-fec.c: fix MII speed calculation
Date: Fri, 17 Jul 2009 11:33:07 +0200
Message-ID: <20090717093307.GB3150@pengutronix.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de> <1247780546-4426-1-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zx4FCpZtqtKETZ7O"
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58898 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934288AbZGQJdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 05:33:09 -0400
Content-Disposition: inline
In-Reply-To: <1247780546-4426-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zx4FCpZtqtKETZ7O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Jul 16, 2009 at 11:42:25PM +0200, Wolfgang Denk wrote:
> The MII speed calculation was based on the CPU clock (ppc_proc_freq),
> but for MPC512x we must use the bus clock instead.
>=20
> This patch makes it use the correct clock and makes sure we don't
> clobber reserved bits in the MII_SPEED register.
>=20
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Kumar Gala <galak@kernel.crashing.org>
> Cc: <netdev@vger.kernel.org>
>=20
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> ---
>  drivers/net/fs_enet/mii-fec.c |   35 +++++++++++++++++++++++++++++++----
>  1 files changed, 31 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
> index 75a0999..62b2d7a 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -103,11 +103,11 @@ static int fs_enet_fec_mii_reset(struct mii_bus *bu=
s)
>  static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
>                                          const struct of_device_id *match)
>  {
> -	struct device_node *np =3D NULL;
>  	struct resource res;
>  	struct mii_bus *new_bus;
>  	struct fec_info *fec;
> -	int ret =3D -ENOMEM, i;
> +	int (*get_bus_freq)(struct device_node *) =3D match->data;
> +	int ret =3D -ENOMEM, clock, speed;
> =20
>  	new_bus =3D mdiobus_alloc();
>  	if (!new_bus)
> @@ -133,13 +133,34 @@ static int __devinit fs_enet_mdio_probe(struct of_d=
evice *ofdev,
>  	if (!fec->fecp)
>  		goto out_fec;
> =20
> -	fec->mii_speed =3D ((ppc_proc_freq + 4999999) / 5000000) << 1;
> +	if (get_bus_freq) {
> +		clock =3D get_bus_freq(ofdev->node);
> +
> +		if (!clock) {
> +			dev_err(&ofdev->dev, "could not determine IPS/IPB clock\n");
> +			goto out_unmap_regs;
> +		}
> +	} else
> +		clock =3D ppc_proc_freq;
> +
> +	/* scale for a MII clock <=3D 2.5 MHz */
> +	speed =3D (clock + 2499999) / 2500000;
> +
> +	/* only 6 bits (25:30) available for MII speed */
> +	if (speed > 0x3F) {
> +		speed =3D 0x3F;
> +		dev_err(&ofdev->dev,
> +			"MII clock (%d Hz) exceeds max (2.5 MHz)\n",
> +			clock / speed);
> +	}
> +
> +	fec->mii_speed =3D speed << 1;
> =20
>  	setbits32(&fec->fecp->fec_r_cntrl, FEC_RCNTRL_MII_MODE);
>  	setbits32(&fec->fecp->fec_ecntrl, FEC_ECNTRL_PINMUX |
>  	                                  FEC_ECNTRL_ETHER_EN);
>  	out_be32(&fec->fecp->fec_ievent, FEC_ENET_MII);
> -	out_be32(&fec->fecp->fec_mii_speed, fec->mii_speed);
> +	clrsetbits_be32(&fec->fecp->fec_mii_speed, 0x7E, fec->mii_speed);
> =20
>  	new_bus->phy_mask =3D ~0;
>  	new_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> @@ -188,6 +209,12 @@ static struct of_device_id fs_enet_mdio_fec_match[] =
=3D {
>  	{
>  		.compatible =3D "fsl,pq1-fec-mdio",
>  	},
> +#if defined(CONFIG_PPC_MPC512x)
> +	{
> +		.compatible =3D "fsl,mpc5121-fec-mdio",
> +		.data =3D mpc5xxx_get_bus_frequency,
> +	},
> +#endif

Grepping through 'drivers/*' I see that #ifdefing compatible-entries is hig=
hly
uncommon (just 3 hits). I think a guideline would be useful. Most people li=
ke
to avoid #ifdefs at any cost, while I personally think it doesn't spoil
readability too much here. Other opinions?

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--zx4FCpZtqtKETZ7O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpgRVMACgkQD27XaX1/VRuwHACff6FRQtEOLWrJUEVycftxm6DP
q/IAn2bwyoXfCbKvBPJtdVGpQAbscqj5
=Mloe
-----END PGP SIGNATURE-----

--zx4FCpZtqtKETZ7O--
