From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Thu, 13 Nov 2014 13:56:01 +0100
Message-ID: <5464AA61.4080606@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <54636BD0.2010208@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="kOTqacTIno06t2xEXbdo6q2CNKwmxH1cN"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44936 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933156AbaKMM40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 07:56:26 -0500
In-Reply-To: <54636BD0.2010208@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kOTqacTIno06t2xEXbdo6q2CNKwmxH1cN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/12/2014 03:16 PM, Roger Quadros wrote:
> DRA7 CAN IP suffers from a problem which causes it to be prevented
> from fully turning OFF (i.e. stuck in transition) if the module was
> disabled while there was traffic on the CAN_RX line.
>=20
> To work around this issue we select the SLEEP pin state by default
> on probe and use the DEFAULT pin state on CAN up and back to the
> SLEEP pin state on CAN down.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/can/c_can/c_can.c          | 21 +++++++++++++++++++++
>  drivers/net/can/c_can/c_can.h          |  1 +
>  drivers/net/can/c_can/c_can_platform.c | 20 ++++++++++++++++++++
>  3 files changed, 42 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 8e78bb4..a950eea 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -35,6 +35,7 @@
>  #include <linux/list.h>
>  #include <linux/io.h>
>  #include <linux/pm_runtime.h>
> +#include <linux/pinctrl/consumer.h>
> =20
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> @@ -587,6 +588,21 @@ static int c_can_chip_config(struct net_device *de=
v)
>  	return c_can_set_bittiming(dev);
>  }
> =20
> +/*
> + * Selects the pinctrl state specified in the name.
> + */
> +static void c_can_pinctrl_select_state(struct c_can_priv *priv,
> +				      const char *name)
> +{
> +	if (!IS_ERR(priv->pinctrl)) {

What happens if priv->pinctrl is NULL? This is probably the case with
the c_can_pci driver.

> +		struct pinctrl_state *s;
> +
> +		s =3D pinctrl_lookup_state(priv->pinctrl, name);
> +		if (!IS_ERR(s))
> +			pinctrl_select_state(priv->pinctrl, s);
> +	}
> +}
> +
>  static int c_can_start(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> @@ -603,6 +619,8 @@ static int c_can_start(struct net_device *dev)
> =20
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
> +	/* activate pins */
> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_DEFAULT);
>  	return 0;
>  }
> =20
> @@ -611,6 +629,9 @@ static void c_can_stop(struct net_device *dev)
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
>  	c_can_irq_control(priv, false);
> +
> +	/* deactivate pins */
> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_SLEEP);
>  	priv->can.state =3D CAN_STATE_STOPPED;
>  }
> =20
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index c6715ca..3cedf48 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -210,6 +210,7 @@ struct c_can_priv {
>  	u32 comm_rcv_high;
>  	u32 rxmasked;
>  	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
> +	struct pinctrl *pinctrl;
>  };
> =20
>  struct net_device *alloc_c_can_dev(void);
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index b838c6b..71b9063 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -34,6 +34,7 @@
>  #include <linux/of_device.h>
>  #include <linux/mfd/syscon.h>
>  #include <linux/regmap.h>
> +#include <linux/pinctrl/consumer.h>
> =20
>  #include <linux/can/dev.h>
> =20
> @@ -230,6 +231,7 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	struct clk *clk;
>  	const struct c_can_driver_data *drvdata;
>  	struct device_node *np =3D pdev->dev.of_node;
> +	struct pinctrl *pinctrl;
> =20
>  	match =3D of_match_device(c_can_of_table, &pdev->dev);
>  	if (match) {
> @@ -241,6 +243,23 @@ static int c_can_plat_probe(struct platform_device=
 *pdev)
>  		return -ENODEV;
>  	}
> =20
> +	pinctrl =3D devm_pinctrl_get(&pdev->dev);
> +	if (!IS_ERR(pinctrl)) {
> +		struct pinctrl_state *s;
> +
> +		/* Deactivate pins to prevent DRA7 DCAN IP from being
> +		 * stuck in transition when module is disabled.
> +		 * Pins are activated in c_can_start() and deactivated
> +		 * in c_can_stop()
> +		 */
> +		s =3D pinctrl_lookup_state(pinctrl, PINCTRL_STATE_SLEEP);
> +		if (!IS_ERR(s))
> +			pinctrl_select_state(pinctrl, s);
> +	} else {
> +		dev_warn(&pdev->dev,
> +			 "failed to get pinctrl\n");
> +	}

Can you move the initial setting into c_can.c, register_c_can_dev()
should be a good candidate.

> +
>  	/* get the appropriate clk */
>  	clk =3D devm_clk_get(&pdev->dev, NULL);
>  	if (IS_ERR(clk)) {
> @@ -270,6 +289,7 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	}
> =20
>  	priv =3D netdev_priv(dev);
> +	priv->pinctrl =3D pinctrl;
> =20
>  	switch (drvdata->id) {
>  	case BOSCH_C_CAN:
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--kOTqacTIno06t2xEXbdo6q2CNKwmxH1cN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZKphAAoJECte4hHFiupU5AwP/RZrznaO73ysmRqJuwhUplrk
S25oGtoOGOGsTwwiwmldO6kRBI3q+nyjpDTXqQjM2eOZ1AG+2jE292zd85y+5vZe
d90fh4bEM7pOD8RgHJ3NLysTtjdJiN24Hs1imh3/gI4nPRHAs2jScikN7obUXol1
qwIyHaohgn/XJvMQSn7FtLycPWLhYr6DLpaZYKNqRM/uGOdq/lNu+if7ezi4DAzN
7TsNWxl3YUnr+pqD2l1Xy2DJHaJyz2hVd+AMXMYpwKhSQ/uyohRhe7UBRpagweVN
yLRrBs1HbywZPa7EoLZiIZDhO3GZfO3b2iRhCToeY9roD39oDy2Rdm19JG5AKua/
GDX4rcZPLFNkXSAe/ijbcTztpHbIv4BSwe5iU20VCGXY9CULuJk3e+aetC1hV0Th
sl1OmYiMH9uQYFFGpUg44YJ3wDbKUhHFyscUmvtV4jIb3bojZ+XktVYzxgBqSqLZ
pSf5wUnhjTR2KESvpUeRQ568VZht+sft4aFqy9DJSG9L6yowK3FubUvt2agsUrNU
ZUHrWwTkb241chG4eP4nWJOtN1LLef+lP2gG0eOtS8IEhwwVPd22g/V1TKeFSHEa
Sd1xqMe20Kc05eYoHlksNlrpIFTj+G5GH3okqFVI0BTHNRgZqt8MGKEJws32zFJK
hsokk6M6WcwpmAZMnNGi
=jD25
-----END PGP SIGNATURE-----

--kOTqacTIno06t2xEXbdo6q2CNKwmxH1cN--
