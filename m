From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4] can: sja1000: fix endian on arm
Date: Thu, 11 Apr 2013 21:38:58 +0200
Message-ID: <51671152.3010100@pengutronix.de>
References: <1365428932.5760.52.camel@lovely>  <5162CCB5.3000605@pengutronix.de> <1365705884.4136.5.camel@mars>  <51670532.5060101@pengutronix.de>  <1365706413.4136.15.camel@mars>  <1365707697.4136.26.camel@mars>  <51670D3E.1020808@pengutronix.de> <1365708777.4136.29.camel@mars>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2DPEEBDFGTNTKSSOKJEUD"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Andreas Larsson <andreas@gaisler.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Bill Pemberton <wfp5p@virginia.edu>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Mack <daniel@zonque.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1365708777.4136.29.camel@mars>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2DPEEBDFGTNTKSSOKJEUD
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 04/11/2013 09:32 PM, Christoph Fritz wrote:
> To get correct endian on arm cpus while reading device tree properties,=

> this patch replaces of_get_property() with of_property_read_u32().
>=20
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> ---
>  drivers/net/can/sja1000/sja1000_of_platform.c |   31 ++++++++++++-----=
--------
>  1 file changed, 15 insertions(+), 16 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/ne=
t/can/sja1000/sja1000_of_platform.c
> index 6433b81..d023707 100644
> --- a/drivers/net/can/sja1000/sja1000_of_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_of_platform.c
> @@ -96,8 +96,8 @@ static int sja1000_ofp_probe(struct platform_device *=
ofdev)
>  	struct net_device *dev;
>  	struct sja1000_priv *priv;
>  	struct resource res;
> -	const u32 *prop;
> -	int err, irq, res_size, prop_size;
> +	u32 prop;
> +	int err, irq, res_size;
>  	void __iomem *base;
> =20
>  	err =3D of_address_to_resource(np, 0, &res);
> @@ -138,27 +138,27 @@ static int sja1000_ofp_probe(struct platform_devi=
ce *ofdev)
>  	priv->read_reg =3D sja1000_ofp_read_reg;
>  	priv->write_reg =3D sja1000_ofp_write_reg;
> =20
> -	prop =3D of_get_property(np, "nxp,external-clock-frequency", &prop_si=
ze);
> -	if (prop && (prop_size =3D=3D  sizeof(u32)))
> -		priv->can.clock.freq =3D *prop / 2;
> +	err =3D of_property_read_u32(np, "nxp,external-clock-frequency", &pro=
p);
> +	if (!err && prop !=3D 0)
> +		priv->can.clock.freq =3D prop / 2;

No need to check for prop !=3D 0 here....

>  	else
>  		priv->can.clock.freq =3D SJA1000_OFP_CAN_CLOCK; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,tx-output-mode", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)))
> -		priv->ocr |=3D *prop & OCR_MODE_MASK;
> +	err =3D of_property_read_u32(np, "nxp,tx-output-mode", &prop);
> +	if (!err)
> +		priv->ocr |=3D prop & OCR_MODE_MASK;
>  	else
>  		priv->ocr |=3D OCR_MODE_NORMAL; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,tx-output-config", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)))
> -		priv->ocr |=3D (*prop << OCR_TX_SHIFT) & OCR_TX_MASK;
> +	err =3D of_property_read_u32(np, "nxp,tx-output-config", &prop);
> +	if (!err)
> +		priv->ocr |=3D (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
>  	else
>  		priv->ocr |=3D OCR_TX0_PULLDOWN; /* default */
> =20
> -	prop =3D of_get_property(np, "nxp,clock-out-frequency", &prop_size);
> -	if (prop && (prop_size =3D=3D sizeof(u32)) && *prop) {
> -		u32 divider =3D priv->can.clock.freq * 2 / *prop;
> +	err =3D of_property_read_u32(np, "nxp,clock-out-frequency", &prop);
> +	if (!err) {
> +		u32 divider =3D priv->can.clock.freq * 2 / prop;

=2E...but here, because of the possibility of devide-by-zero.

> =20
>  		if (divider > 1)
>  			priv->cdr |=3D divider / 2 - 1;
> @@ -168,8 +168,7 @@ static int sja1000_ofp_probe(struct platform_device=
 *ofdev)
>  		priv->cdr |=3D CDR_CLK_OFF; /* default */
>  	}
> =20
> -	prop =3D of_get_property(np, "nxp,no-comparator-bypass", NULL);
> -	if (!prop)
> +	if (!of_property_read_bool(np, "nxp,no-comparator-bypass"))
>  		priv->cdr |=3D CDR_CBP; /* default */
> =20
>  	priv->irq_flags =3D IRQF_SHARED;

No need to resend, I'll fix it while applying.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2DPEEBDFGTNTKSSOKJEUD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlFnEVIACgkQjTAFq1RaXHNP5ACfU55n0D+7oXgB0qUS+Hy7vKmU
mHIAniwjmmPR4pzMOWqbwWz5X+siG/cT
=omDT
-----END PGP SIGNATURE-----

------enig2DPEEBDFGTNTKSSOKJEUD--
