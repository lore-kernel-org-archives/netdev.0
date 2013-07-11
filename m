From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2] drivers: net: phy: at803x: LED control via led subsystem
Date: Thu, 11 Jul 2013 13:15:53 +0100
Message-ID: <CAGVrzcbxuogp9umQVEFOfzg64Nb6UWZjHs_5M=bdHceRSFRE4g@mail.gmail.com>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com> <1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:42249 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357Ab3GKMQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 08:16:34 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so7878721pad.28
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 05:16:34 -0700 (PDT)
In-Reply-To: <1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Helmut,

2013/7/11 Helmut Schaa <helmut.schaa@googlemail.com>:
> The AT8035 PHY allows to control the LED PIN behavior from software.
> Expose this functionality by registering an LED device.
>
> Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
> ---
>  drivers/net/phy/Kconfig  |    7 ++++
>  drivers/net/phy/at803x.c |   87 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 94 insertions(+)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 3a316b3..5e855b7 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -19,6 +19,13 @@ config AT803X_PHY
>         ---help---
>           Currently supports the AT8030 and AT8035 model
>
> +config AT803X_LEDS
> +       bool "Enable access to PHY connected LEDs"
> +       depends on AT803X_PHY && LEDS_CLASS
> +       ---help---
> +         Select this to be able to control LEDs connected to the
> +         PHY from userspace
> +
>  config AMD_PHY
>         tristate "Drivers for the AMD PHYs"
>         ---help---
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index ac22283..49ef6306 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -16,6 +16,7 @@
>  #include <linux/string.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
> +#include <linux/leds.h>
>
>  #define AT803X_INTR_ENABLE                     0x12
>  #define AT803X_INTR_STATUS                     0x13
> @@ -31,6 +32,8 @@
>  #define AT803X_DEBUG_DATA                      0x1E
>  #define AT803X_DEBUG_SYSTEM_MODE_CTRL          0x05
>  #define AT803X_DEBUG_RGMII_TX_CLK_DLY          BIT(8)
> +#define AT8035_LED_CTRL                                0x18
> +#define AT8035_LED_CTRL_OFF                    BIT(15)
>
>  MODULE_DESCRIPTION("Atheros 803x PHY driver");
>  MODULE_AUTHOR("Matus Ujhelyi");
> @@ -152,6 +155,86 @@ static int at803x_config_init(struct phy_device *phydev)
>         return 0;
>  }
>
> +#ifdef CONFIG_AT803X_LEDS
> +
> +struct at8035_priv {
> +       struct led_classdev led;
> +       struct phy_device *phydev;
> +       struct work_struct led_work;
> +       bool stop;
> +};
> +
> +static void at8035_led_work(struct work_struct *work)
> +{
> +       struct at8035_priv *priv =
> +               container_of(work, struct at8035_priv, led_work);
> +       struct phy_device *phydev = priv->phydev;
> +       int val;
> +
> +       if (priv->stop)
> +               return;
> +
> +       val = phy_read(phydev, AT8035_LED_CTRL);
> +
> +       if (priv->led.brightness > 0)
> +               phy_write(phydev, AT8035_LED_CTRL, val & ~AT8035_LED_CTRL_OFF);
> +       else
> +               phy_write(phydev, AT8035_LED_CTRL, val | AT8035_LED_CTRL_OFF);
> +}

I do like this and I believe that there is nothing specific that would
prevent you from making software controllable LEDs from being used
with other PHYs. How about you create a small LED class helper that
PHY drivers supporting controllable LEDs can hook into and provide
their own callback and LED name for setting the LED state?

> +
> +static void at8035_led_brightness_set(struct led_classdev *led,
> +                                     enum led_brightness brightness)
> +{
> +       struct at8035_priv *priv = container_of(led, struct at8035_priv, led);
> +
> +       /* MDIO bus can only be used from process context */
> +       if (!priv->stop)
> +               schedule_work(&priv->led_work);

It seems to me that you could remove the stop boolean if you move
led_classdev_unregister upper, provided that it guarantees it will not
schedule the workqueue.
--
Florian
