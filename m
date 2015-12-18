From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/2] can: sja1000: of: add compatibility with Technologic
 Systems version
Date: Fri, 18 Dec 2015 21:41:47 +0100
Message-ID: <56746F8B.8030008@pengutronix.de>
References: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450469845-12900-2-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Wj1gugVJFwsCROLOSMD10rSdwSOukHfqu"
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1450469845-12900-2-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Wj1gugVJFwsCROLOSMD10rSdwSOukHfqu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/18/2015 09:17 PM, Damien Riegel wrote:
> Technologic Systems provides an IP compatible with the SJA1000,
> instantiated in an FPGA. Because of some bus widths issue, access to
> registers is made through a "window" that works like this:
>=20
>     base + 0x0: address to read/write
>     base + 0x2: 8-bit register value
>=20
> This commit adds a new compatible device, "technologic,sja1000", with
> read and write functions using the window mechanism.
>=20
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> ---
>  drivers/net/can/sja1000/sja1000_platform.c | 30 ++++++++++++++++++++++=
++++++--
>  1 file changed, 28 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index 0552ed4..6cbf251 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -70,6 +70,18 @@ static void sp_write_reg32(const struct sja1000_priv=
 *priv, int reg, u8 val)
>  	iowrite8(val, priv->reg_base + reg * 4);
>  }
> =20
> +static u8 ts4800_read_reg16(const struct sja1000_priv *priv, int reg)
> +{
> +	sp_write_reg16(priv, 0,  reg);
> +	return sp_read_reg16(priv, 2);

This is racy, please add a spinlock.

> +}
> +
> +static void ts4800_write_reg16(const struct sja1000_priv *priv, int re=
g, u8 val)
> +{
> +	sp_write_reg16(priv, 0, reg);
> +	sp_write_reg16(priv, 2, val);

This is racy, too.

Have a look at https://marc.info/?l=3Dlinux-can&m=3D137149497403825&w=3D2=


Marc

> +}
> +
>  static void sp_populate(struct sja1000_priv *priv,
>  			struct sja1000_platform_data *pdata,
>  			unsigned long resource_mem_flags)
> @@ -98,21 +110,34 @@ static void sp_populate(struct sja1000_priv *priv,=

> =20
>  static void sp_populate_of(struct sja1000_priv *priv, struct device_no=
de *of)
>  {
> +	int is_technologic;
>  	int err;
>  	u32 prop;
> =20
> +	is_technologic =3D of_device_is_compatible(of, "technologic,sja1000")=
;
> +
>  	err =3D of_property_read_u32(of, "reg-io-width", &prop);
>  	if (err)
>  		prop =3D 1; /* 8 bit is default */
> =20
> +	if (is_technologic && prop !=3D 2) {
> +		netdev_warn(priv->dev, "forcing reg-io-width to 2\n");
> +		prop =3D 2;
> +	}
> +
>  	switch (prop) {
>  	case 4:
>  		priv->read_reg =3D sp_read_reg32;
>  		priv->write_reg =3D sp_write_reg32;
>  		break;
>  	case 2:
> -		priv->read_reg =3D sp_read_reg16;
> -		priv->write_reg =3D sp_write_reg16;
> +		if (is_technologic) {
> +			priv->read_reg =3D ts4800_read_reg16;
> +			priv->write_reg =3D ts4800_write_reg16;
> +		} else {
> +			priv->read_reg =3D sp_read_reg16;
> +			priv->write_reg =3D sp_write_reg16;
> +		}
>  		break;
>  	case 1:	/* fallthrough */
>  	default:
> @@ -244,6 +269,7 @@ static int sp_remove(struct platform_device *pdev)
> =20
>  static const struct of_device_id sp_of_table[] =3D {
>  	{.compatible =3D "nxp,sja1000"},
> +	{.compatible =3D "technologic,sja1000"},
>  	{},
>  };
>  MODULE_DEVICE_TABLE(of, sp_of_table);
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Wj1gugVJFwsCROLOSMD10rSdwSOukHfqu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWdG+LAAoJEP5prqPJtc/H6HgIAJJk8PsVVPSvp4YLljLs1HfR
KyIZEDkjfuyTkqHtxO4R3tye31l6JWRSkszlJPCma5hG+YBAf6e8IW6AsEVJwFWk
sY+gK55eqx//6JZSnEeVy/nYVZ4VqRegfq1uDO2WgPjw+zifWD52d8Zad0TQWUpH
2+xrRBS6vFOAYknWgECE0y8ODDRtDM9TEI/DmA62YPgkXtr0xAxC4AIHChdmxKZd
8pCrUDoMxenyfQl/JgQPAC1ifdWEgfTcInR3W5/KhTw/7R6gAGi4mmnuoIAGL7eT
EuTJRRV0T8f/v57MgEaFRC4gSGHmhQVpN/dlaQJUalyTd4aNu1A8nR/QhFApa+8=
=alnF
-----END PGP SIGNATURE-----

--Wj1gugVJFwsCROLOSMD10rSdwSOukHfqu--
