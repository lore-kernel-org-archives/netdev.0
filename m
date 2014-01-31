From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 4/6] can: sja1000: fuse of_platform into platform
Date: Fri, 31 Jan 2014 13:33:40 +0100
Message-ID: <52EB9824.2010703@pengutronix.de>
References: <1391164513-11529-1-git-send-email-florian.vaussard@epfl.ch> <1391164513-11529-5-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mptUCBIa6gwGVlceAM7Lp9l2TC28osW3X"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Vaussard <florian.vaussard@epfl.ch>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391164513-11529-5-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mptUCBIa6gwGVlceAM7Lp9l2TC28osW3X
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/31/2014 11:35 AM, Florian Vaussard wrote:
> The OpenFirmware probe can be merged into the standard platform
> probe to leverage common code.

Good work, as we want to replace the existing driver, I'm quite picky on
this patch, see more comments inline.

Please don't delete of of_platform driver, yet.

> Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
> ---
>  drivers/net/can/sja1000/Kconfig               |  13 +-
>  drivers/net/can/sja1000/Makefile              |   1 -
>  drivers/net/can/sja1000/sja1000_of_platform.c | 218 ------------------=
--------
>  drivers/net/can/sja1000/sja1000_platform.c    | 141 +++++++++++++----
>  4 files changed, 116 insertions(+), 257 deletions(-)
>  delete mode 100644 drivers/net/can/sja1000/sja1000_of_platform.c
[...]

> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index 779679a..96a92a1 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -27,12 +27,16 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/platform/sja1000.h>
>  #include <linux/io.h>
> +#include <linux/of.h>
> +#include <linux/of_irq.h>
> =20
>  #include "sja1000.h"
> =20
>  #define DRV_NAME "sja1000_platform"
> +#define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)

This driver uses "SP" short for sja100_platform as namespace, please
convert.

> =20
>  MODULE_AUTHOR("Sascha Hauer <s.hauer@pengutronix.de>");
> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
>  MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus"=
);
>  MODULE_ALIAS("platform:" DRV_NAME);
>  MODULE_LICENSE("GPL v2");
> @@ -67,24 +71,98 @@ static void sp_write_reg32(const struct sja1000_pri=
v *priv, int reg, u8 val)
>  	iowrite8(val, priv->reg_base + reg * 4);
>  }
> =20
> -static int sp_probe(struct platform_device *pdev)
> +static void sp_populate(struct sja1000_priv *priv,
> +			struct sja1000_platform_data *pdata,
> +			unsigned long resource_mem_flags)
> +{
> +	/* The CAN clock frequency is half the oscillator clock frequency */
> +	priv->can.clock.freq =3D pdata->osc_freq / 2;
> +	priv->ocr =3D pdata->ocr;
> +	priv->cdr =3D pdata->cdr;
> +
> +	switch (resource_mem_flags & IORESOURCE_MEM_TYPE_MASK) {
> +	case IORESOURCE_MEM_32BIT:
> +		priv->read_reg =3D sp_read_reg32;
> +		priv->write_reg =3D sp_write_reg32;
> +		break;
> +	case IORESOURCE_MEM_16BIT:
> +		priv->read_reg =3D sp_read_reg16;
> +		priv->write_reg =3D sp_write_reg16;
> +		break;
> +	case IORESOURCE_MEM_8BIT:
> +	default:
> +		priv->read_reg =3D sp_read_reg8;
> +		priv->write_reg =3D sp_write_reg8;
> +		break;
> +	}
> +}
> +
> +#if defined(CONFIG_OF)

The driver also compiles on systems without CONFIG_OF without these
defines. Please remove.

> +static void sp_populate_of(struct sja1000_priv *priv, struct device_no=
de *of)
>  {
>  	int err;
> +	u32 prop;
> +
> +	priv->read_reg =3D sp_read_reg8;
> +	priv->write_reg =3D sp_write_reg8;
> +
> +	err =3D of_property_read_u32(of, "nxp,external-clock-frequency", &pro=
p);
> +	if (!err)
> +		priv->can.clock.freq =3D prop / 2;
> +	else
> +		priv->can.clock.freq =3D SJA1000_OFP_CAN_CLOCK; /* default */
> +
> +	err =3D of_property_read_u32(of, "nxp,tx-output-mode", &prop);
> +	if (!err)
> +		priv->ocr |=3D prop & OCR_MODE_MASK;
> +	else
> +		priv->ocr |=3D OCR_MODE_NORMAL; /* default */
> +
> +	err =3D of_property_read_u32(of, "nxp,tx-output-config", &prop);
> +	if (!err)
> +		priv->ocr |=3D (prop << OCR_TX_SHIFT) & OCR_TX_MASK;
> +	else
> +		priv->ocr |=3D OCR_TX0_PULLDOWN; /* default */
> +
> +	err =3D of_property_read_u32(of, "nxp,clock-out-frequency", &prop);
> +	if (!err && prop) {
> +		u32 divider =3D priv->can.clock.freq * 2 / prop;
> +
> +		if (divider > 1)
> +			priv->cdr |=3D divider / 2 - 1;
> +		else
> +			priv->cdr |=3D CDR_CLKOUT_MASK;
> +	} else {
> +		priv->cdr |=3D CDR_CLK_OFF; /* default */
> +	}
> +
> +	if (!of_property_read_bool(of, "nxp,no-comparator-bypass"))
> +		priv->cdr |=3D CDR_CBP; /* default */
> +}
> +#else
> +static void sp_populate_of(struct sja1000_priv *priv, device_node *of)=

> +{
> +}
> +#endif
> +
> +static int sp_probe(struct platform_device *pdev)
> +{
> +	int err, irq =3D 0;
>  	void __iomem *addr;
>  	struct net_device *dev;
>  	struct sja1000_priv *priv;
> -	struct resource *res_mem, *res_irq;
> +	struct resource *res_mem, *res_irq =3D 0;

Please use NULL to initialize pointers.

>  	struct sja1000_platform_data *pdata;
> +	struct device_node *of =3D pdev->dev.of_node;
> =20
>  	pdata =3D dev_get_platdata(&pdev->dev);
> -	if (!pdata) {
> +	if (!pdata && !of) {
>  		dev_err(&pdev->dev, "No platform data provided!\n");
>  		return -ENODEV;
>  	}
> =20
>  	res_mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	res_irq =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> -	if (!res_mem || !res_irq)
> +	if (!res_mem)
>  		return -ENODEV;
> =20
>  	if (!devm_request_mem_region(&pdev->dev, res_mem->start,
> @@ -96,36 +174,34 @@ static int sp_probe(struct platform_device *pdev)
>  	if (!addr)
>  		return -ENOMEM;
> =20
> +	if (of)
> +		irq =3D irq_of_parse_and_map(of, 0);
> +	else
> +		res_irq =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +
> +	if (!irq && !res_irq)
> +		return -ENODEV;
> +
>  	dev =3D alloc_sja1000dev(0);
>  	if (!dev)
>  		return -ENOMEM;
>  	priv =3D netdev_priv(dev);
> =20
> -	dev->irq =3D res_irq->start;
> -	priv->irq_flags =3D res_irq->flags & IRQF_TRIGGER_MASK;
> -	if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
> -		priv->irq_flags |=3D IRQF_SHARED;
> +	if (res_irq) {
> +		irq =3D res_irq->start;
> +		priv->irq_flags =3D res_irq->flags & IRQF_TRIGGER_MASK;
> +		if (res_irq->flags & IORESOURCE_IRQ_SHAREABLE)
> +			priv->irq_flags |=3D IRQF_SHARED;
> +	} else
> +		priv->irq_flags =3D IRQF_SHARED;

Please add { } for else, too.

> +
> +	dev->irq =3D irq;
>  	priv->reg_base =3D addr;
> -	/* The CAN clock frequency is half the oscillator clock frequency */
> -	priv->can.clock.freq =3D pdata->osc_freq / 2;
> -	priv->ocr =3D pdata->ocr;
> -	priv->cdr =3D pdata->cdr;
> =20
> -	switch (res_mem->flags & IORESOURCE_MEM_TYPE_MASK) {
> -	case IORESOURCE_MEM_32BIT:
> -		priv->read_reg =3D sp_read_reg32;
> -		priv->write_reg =3D sp_write_reg32;
> -		break;
> -	case IORESOURCE_MEM_16BIT:
> -		priv->read_reg =3D sp_read_reg16;
> -		priv->write_reg =3D sp_write_reg16;
> -		break;
> -	case IORESOURCE_MEM_8BIT:
> -	default:
> -		priv->read_reg =3D sp_read_reg8;
> -		priv->write_reg =3D sp_write_reg8;
> -		break;
> -	}
> +	if (of)
> +		sp_populate_of(priv, of);
> +	else
> +		sp_populate(priv, pdata, res_mem->flags);
> =20
>  	platform_set_drvdata(pdev, dev);
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> @@ -156,12 +232,21 @@ static int sp_remove(struct platform_device *pdev=
)
>  	return 0;
>  }
> =20
> +#if defined(CONFIG_OF)

Please remove the ifdef.

> +static struct of_device_id sja1000_ofp_table[] =3D {

Please rename into sp_of_table or something similar.

> +	{.compatible =3D "nxp,sja1000"},
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
> +#endif
> +
>  static struct platform_driver sp_driver =3D {
>  	.probe =3D sp_probe,
>  	.remove =3D sp_remove,
>  	.driver =3D {
>  		.name =3D DRV_NAME,
>  		.owner =3D THIS_MODULE,
> +		.of_match_table =3D of_match_ptr(sja1000_ofp_table),

The of_match_ptr is not needed anymore, please remove.

>  	},
>  };
> =20
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mptUCBIa6gwGVlceAM7Lp9l2TC28osW3X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlLrmCQACgkQjTAFq1RaXHPm0ACfb8GYdfVkHSA0A3+DiXCsnWVQ
dlQAoIrlD1aNOIyN35NHGL2MBgJmgPPq
=cIg2
-----END PGP SIGNATURE-----

--mptUCBIa6gwGVlceAM7Lp9l2TC28osW3X--
