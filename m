From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/3] can: mcp251x: Add device tree support
Date: Wed, 13 Nov 2013 10:16:43 +0100
Message-ID: <5283437B.3010309@pengutronix.de>
References: <1384332341-15363-1-git-send-email-shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Sn3KamJA7DWVC7vNtH7rnPrnLeUplxJVN"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1384332341-15363-1-git-send-email-shc_work@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Sn3KamJA7DWVC7vNtH7rnPrnLeUplxJVN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2013 09:45 AM, Alexander Shiyan wrote:
> This patch adds Device Tree support to the Microchip MCP251X driver.
>=20
> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> ---
>  .../bindings/net/can/microchip,mcp251x.txt         | 25 ++++++++++
>  drivers/net/can/mcp251x.c                          | 57 ++++++++++++++=
++------
>  2 files changed, 66 insertions(+), 16 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/can/microchip=
,mcp251x.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/microchip,mcp251=
x.txt b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt
> new file mode 100644
> index 0000000..06d95ee
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/microchip,mcp251x.txt
> @@ -0,0 +1,25 @@
> +* Microchip MCP251X device tree bindings
> +
> +Registers a Microchip MCP251X stand-alone CAN controller connected to =
SPI bus.
> +
> +Required properties:
> + - compatible: Should be one of the following:
> +   - "microchip,mcp2510" for MCP2510.
> +   - "microchip,mcp2515" for MCP2515.
> + - reg: SPI chip select.
> + - clocks: The clock feeding the CAN controller.
> + - interrupt-parent: The parent interrupt controller.
> + - interrupts: Should contain IRQ line for the CAN controller.
> +
> +Optional properties:
> + - vdd-supply: Regulator that powers the CAN controller.
> + - xceiver-supply: Regulator that powers the CAN transceiver.
> +
> +Example:
> +	can0: can@1 {
> +		compatible =3D "microchip,mcp2515";
> +		reg =3D <1>;
> +		clocks =3D <&clk24m>;
> +		interrupt-parent =3D <&gpio4>;
> +		interrupts =3D <13 0x2>;
> +	};
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index 8e133aa..9aa2822 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -60,6 +60,8 @@
>  #include <linux/kernel.h>
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
>  #include <linux/platform_device.h>
>  #include <linux/slab.h>
>  #include <linux/spi/spi.h>
> @@ -987,10 +989,38 @@ static const struct net_device_ops mcp251x_netdev=
_ops =3D {
>  	.ndo_start_xmit =3D mcp251x_hard_start_xmit,
>  };
> =20
> +static struct of_device_id mcp251x_of_match[] =3D {
> +	{
> +		.compatible	=3D "microchip,mcp2510",
> +		.data		=3D (void *)CAN_MCP251X_MCP2510,
> +	},
> +	{
> +		.compatible	=3D "microchip,mcp2515",
> +		.data		=3D (void *)CAN_MCP251X_MCP2515,
> +	},
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, mcp251x_of_match);
> +
> +static const struct spi_device_id mcp251x_id_table[] =3D {
> +	{
> +		.name		=3D "mcp2510",
> +		.driver_data	=3D (kernel_ulong_t)CAN_MCP251X_MCP2510,
> +	},
> +	{
> +		.name		=3D "mcp2515",
> +		.driver_data	=3D (kernel_ulong_t)CAN_MCP251X_MCP2515,
> +	},
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(spi, mcp251x_id_table);
> +
>  static int mcp251x_can_probe(struct spi_device *spi)
>  {
>  	struct net_device *net;
>  	struct mcp251x_priv *priv;
> +	const struct of_device_id *of_id =3D of_match_device(mcp251x_of_match=
,
> +							   &spi->dev);
>  	int ret;
> =20
>  	/* Allocate can/net device */
> @@ -1017,7 +1047,10 @@ static int mcp251x_can_probe(struct spi_device *=
spi)
>  	priv->can.clock.freq =3D clk_get_rate(priv->clk) / 2;
>  	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES |
>  		CAN_CTRLMODE_LOOPBACK | CAN_CTRLMODE_LISTENONLY;
> -	priv->model =3D spi_get_device_id(spi)->driver_data;
> +	if (of_id)
> +		priv->model =3D (enum mcp251x_model)of_id->data;
> +	else
> +		priv->model =3D spi_get_device_id(spi)->driver_data;
>  	priv->net =3D net;
> =20
>  	priv->power =3D devm_regulator_get(&spi->dev, "vdd");
> @@ -1198,24 +1231,16 @@ static int mcp251x_can_resume(struct device *de=
v)
>  static SIMPLE_DEV_PM_OPS(mcp251x_can_pm_ops, mcp251x_can_suspend,
>  	mcp251x_can_resume);
> =20
> -static const struct spi_device_id mcp251x_id_table[] =3D {
> -	{ "mcp2510",	CAN_MCP251X_MCP2510 },
> -	{ "mcp2515",	CAN_MCP251X_MCP2515 },
> -	{ },
> -};
> -
> -MODULE_DEVICE_TABLE(spi, mcp251x_id_table);
> -
>  static struct spi_driver mcp251x_can_driver =3D {
>  	.driver =3D {
> -		.name =3D DEVICE_NAME,
> -		.owner =3D THIS_MODULE,
> -		.pm =3D &mcp251x_can_pm_ops,
> +		.name		=3D DEVICE_NAME,
> +		.owner		=3D THIS_MODULE,
> +		.of_match_table	=3D of_match_ptr(mcp251x_of_match),
> +		.pm		=3D &mcp251x_can_pm_ops,
>  	},
> -
> -	.id_table =3D mcp251x_id_table,
> -	.probe =3D mcp251x_can_probe,
> -	.remove =3D mcp251x_can_remove,
> +	.id_table	=3D mcp251x_id_table,
> +	.probe		=3D mcp251x_can_probe,
> +	.remove		=3D mcp251x_can_remove,

Please don't reformat this. I personally don't like alignment here, as
it tends to be to short if another member is added to the struct.

Looks good otherwise, please add my:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

>  };
>  module_spi_driver(mcp251x_can_driver);
> =20
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Sn3KamJA7DWVC7vNtH7rnPrnLeUplxJVN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKDQ3sACgkQjTAFq1RaXHMKJACfcbugTbCbWLfYwA/UrRGxm2oh
bL4An1KB0TvzuaTY11TCFhkcioo2VupY
=R436
-----END PGP SIGNATURE-----

--Sn3KamJA7DWVC7vNtH7rnPrnLeUplxJVN--
