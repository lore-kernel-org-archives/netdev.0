From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 1/3] can: sja1000: of: add per-compatible init hook
Date: Tue, 12 Jan 2016 08:52:06 +0100
Message-ID: <5694B0A6.8070200@pengutronix.de>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450978973-30417-2-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="naRjn88JRnC0hHffL8jXfvtJjNburcrok"
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1450978973-30417-2-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--naRjn88JRnC0hHffL8jXfvtJjNburcrok
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/24/2015 06:42 PM, Damien Riegel wrote:
> This commit adds the capability to allocate and init private data
> embedded in the sja1000_priv structure on a per-compatible basis. The
> device node is passed as a parameter of the init callback to allow
> parsing of custom device tree properties.
>=20
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> ---
>  drivers/net/can/sja1000/sja1000_platform.c | 39 ++++++++++++++++++++++=
++++++--
>  1 file changed, 37 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index 0552ed4..e0572d0 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -40,6 +40,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on=
 the platform bus");
>  MODULE_ALIAS("platform:" DRV_NAME);
>  MODULE_LICENSE("GPL v2");
> =20
> +struct sja1000_of_data {
> +	size_t  priv_sz;
> +	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
> +};
> +
>  static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
>  {
>  	return ioread8(priv->reg_base + reg);
> @@ -154,7 +159,8 @@ static void sp_populate_of(struct sja1000_priv *pri=
v, struct device_node *of)
>  		priv->cdr |=3D CDR_CBP; /* default */
>  }
> =20
> -static int sp_probe(struct platform_device *pdev)
> +static int __sp_probe(struct platform_device *pdev,
> +		      const struct sja1000_of_data *of_data)
>  {
>  	int err, irq =3D 0;
>  	void __iomem *addr;
> @@ -163,6 +169,7 @@ static int sp_probe(struct platform_device *pdev)
>  	struct resource *res_mem, *res_irq =3D NULL;
>  	struct sja1000_platform_data *pdata;
>  	struct device_node *of =3D pdev->dev.of_node;
> +	size_t priv_sz =3D of_data ? of_data->priv_sz : 0;
> =20
>  	pdata =3D dev_get_platdata(&pdev->dev);
>  	if (!pdata && !of) {
> @@ -191,7 +198,7 @@ static int sp_probe(struct platform_device *pdev)
>  	if (!irq && !res_irq)
>  		return -ENODEV;
> =20
> -	dev =3D alloc_sja1000dev(0);
> +	dev =3D alloc_sja1000dev(priv_sz);
>  	if (!dev)
>  		return -ENOMEM;
>  	priv =3D netdev_priv(dev);
> @@ -213,6 +220,12 @@ static int sp_probe(struct platform_device *pdev)
>  	else
>  		sp_populate(priv, pdata, res_mem->flags);
> =20
> +	if (of_data && of_data->init) {
> +		err =3D of_data->init(priv, of);
> +		if (err)
> +			goto exit_free;
> +	}
> +
>  	platform_set_drvdata(pdev, dev);
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> =20
> @@ -248,6 +261,28 @@ static const struct of_device_id sp_of_table[] =3D=
 {
>  };
>  MODULE_DEVICE_TABLE(of, sp_of_table);
> =20
> +static const struct sja1000_of_data *sp_get_of_data(struct device_node=
 *of)
> +{
> +	const struct of_device_id *id;
> +
> +	if (!of)
> +		return NULL;
> +
> +	id =3D of_match_node(sp_of_table, of);
> +	if (!id)
> +		return NULL;
> +
> +	return id->data;
> +}
> +
> +static int sp_probe(struct platform_device *pdev)
> +{
> +	struct device_node *of =3D pdev->dev.of_node;
> +	const struct sja1000_of_data *of_data =3D sp_get_of_data(of);
> +
> +	return __sp_probe(pdev, of_data);
> +}

Please merge these two into the original sp_probe function, as there
already is a test for pdev->dev.of_node.

> +
>  static struct platform_driver sp_driver =3D {
>  	.probe =3D sp_probe,
>  	.remove =3D sp_remove,
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--naRjn88JRnC0hHffL8jXfvtJjNburcrok
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWlLCmAAoJEP5prqPJtc/HRK8IAKO5ENAFViCQ324Lt5uJoVJa
xluynsyyiHYImtPT62TIXl3BWK1Q5p6kCXdKvzgfTY7/Z8rC7fW+3Ei/x+pSOPUY
0Z1hvnIP0C0d+9i2y5qYdxz+nDIVubQzE3oj/2+UZz1gAUGYVw1yXpAjRELfRZzq
N6vNZ0Z8rX+4+G8e+pQPUijnSUMOjW1BiocMeozLU+KqacubxuSsj83h8/FBbx3C
aQssU2WLUg1sae3W6UQTKGYyIO8YqPdNYWbx5ZYMV4yh0eWthmDACHD47GldO4TR
rbC2MgQW+8B2s2tSE174sXrbqHrRgM+QMuGReE6BiXXMmqUWjIZcjsOL05EbdFk=
=V4a9
-----END PGP SIGNATURE-----

--naRjn88JRnC0hHffL8jXfvtJjNburcrok--
