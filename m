From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Fri, 13 May 2016 00:41:47 +0300
Message-ID: <4363f9c0-d447-5fc1-3ac9-382a172a7087@cogentembedded.com>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel@pengutronix.de, "Andrew F . Davis" <afd@ti.com>,
	Nishanth Menon <nm@ti.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:32804 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbcELVl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 17:41:56 -0400
Received: by mail-lb0-f175.google.com with SMTP id jj5so17162531lbc.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 14:41:56 -0700 (PDT)
In-Reply-To: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2016 01:00 PM, Uwe Kleine-K=C3=B6nig wrote:

> The framework only asserts (for now) that the reset gpio is not activ=
e.
>
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> ---
>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
>  drivers/net/phy/phy_device.c                  | 8 ++++++++
>  2 files changed, 11 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Document=
ation/devicetree/bindings/net/phy.txt
> index bc1c3c8bf8fa..c00a9a894547 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -35,6 +35,8 @@ Optional Properties:
>  - broken-turn-around: If set, indicates the PHY device does not corr=
ectly
>    release the turn around line low at the end of a MDIO transaction.
>
> +- reset-gpios: Reference to a GPIO used to reset the phy.
> +
>  Example:
>
>  ethernet-phy@0 {
> @@ -42,4 +44,5 @@ ethernet-phy@0 {
>  	interrupt-parent =3D <40000>;
>  	interrupts =3D <35 1>;
>  	reg =3D <0>;
> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
 >  };

    OK, the example has PHY ID specified in the "compatible" prop. It's=
 a=20
vital detail, you should mention it somewhere...

> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_devic=
e.c
> index e551f3a89cfd..7d666ab47271 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
[...]
> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
>  	int err =3D 0;
> +	struct gpio_descs *reset_gpios;
>
>  	phydev->drv =3D phydrv;
>
> +	/* take phy out of reset */
> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
> +						    GPIOD_OUT_LOW);
> +	if (IS_ERR(reset_gpios))
> +		return PTR_ERR(reset_gpios);
> +

    It would have been logical to assert back the reset GPIO in phy_rem=
ove(),=20
no? Also, you'd need to store the GPIO permanently somewhere...

MBR, Sergei
