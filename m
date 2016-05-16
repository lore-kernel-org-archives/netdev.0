From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Mon, 16 May 2016 10:33:59 -0500
Message-ID: <20160516153359.GA20923@rob-hp-laptop>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, kernel@pengutronix.de,
	"Andrew F . Davis" <afd@ti.com>, Nishanth Menon <nm@ti.com>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41397 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbcEPPeE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 11:34:04 -0400
Content-Disposition: inline
In-Reply-To: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 12:00:33PM +0200, Uwe Kleine-K=F6nig wrote:
> The framework only asserts (for now) that the reset gpio is not activ=
e.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> ---
>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
>  drivers/net/phy/phy_device.c                  | 8 ++++++++
>  2 files changed, 11 insertions(+)
>=20
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Document=
ation/devicetree/bindings/net/phy.txt
> index bc1c3c8bf8fa..c00a9a894547 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -35,6 +35,8 @@ Optional Properties:
>  - broken-turn-around: If set, indicates the PHY device does not corr=
ectly
>    release the turn around line low at the end of a MDIO transaction.
> =20
> +- reset-gpios: Reference to a GPIO used to reset the phy.
> +

And also active mode flag should be specified.

>  Example:
> =20
>  ethernet-phy@0 {
> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>  	interrupt-parent =3D <40000>;
>  	interrupts =3D <35 1>;
>  	reg =3D <0>;
> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
>  };
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index e551f3a89cfd..7d666ab47271 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -34,6 +34,7 @@
>  #include <linux/io.h>
>  #include <linux/uaccess.h>
>  #include <linux/of.h>
> +#include <linux/gpio/consumer.h>
> =20
>  #include <asm/irq.h>
> =20
> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
>  	int err =3D 0;
> +	struct gpio_descs *reset_gpios;
> =20
>  	phydev->drv =3D phydrv;
> =20
> +	/* take phy out of reset */
> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
> +						    GPIOD_OUT_LOW);
> +	if (IS_ERR(reset_gpios))
> +		return PTR_ERR(reset_gpios);
> +
>  	/* Disable the interrupt if the PHY doesn't support it
>  	 * but the interrupt is still a valid one
>  	 */
> --=20
> 2.8.0.rc3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
