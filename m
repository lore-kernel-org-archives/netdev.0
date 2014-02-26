From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Wed, 26 Feb 2014 14:20:43 -0800
Message-ID: <CAGVrzcbUShzdYgEgHJiG8gL11+1DANiJpAk3PL5=jKASqXAyGg@mail.gmail.com>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel <linux-kernel@lists.codethink.co.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42696 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaBZWVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:21:24 -0500
In-Reply-To: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-02-26 3:48 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:

[snip]

> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 5a8993b..0c9e434 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -148,15 +148,52 @@ static int ks8737_config_intr(struct phy_device *phydev)
>         return rc < 0 ? rc : 0;
>  }
>
> +static int kszphy_setup_led(struct phy_device *phydev,
> +                           unsigned int reg, unsigned int shift)
> +{
> +
> +       struct device *dev = &phydev->dev;
> +       struct device_node *of_node = dev->of_node;
> +       int rc, temp;
> +       u32 val;
> +
> +       if (!of_node && dev->parent->of_node)
> +               of_node = dev->parent->of_node;
> +
> +       if (of_property_read_u32(of_node, "micrel,led-mode", &val))
> +               return 0;

This breaks non-OF configuration because of_read_property_read_u32()
will return -ENOSYS, so you skip the LED register configuration
entirely, is that intended?

> +
> +       temp = phy_read(phydev, reg);
> +       if (temp < 0)
> +               return temp;
> +
> +       temp &= 3 << shift;

The compiler cannot verify that we are not overflowing, you might want
to make sure that shift <= 14 (just in case)

> +       temp |= val << shift;
> +       rc = phy_write(phydev, reg, temp);
> +
> +       return rc < 0 ? rc : 0;

You could have;

             return phy_write(phydev, reg, temp);

> +}
> +
>  static int kszphy_config_init(struct phy_device *phydev)
>  {
>         return 0;
>  }
>
> +static int kszphy_config_init_led8041(struct phy_device *phydev)
> +{
> +       /* single led control, register 0x1e bits 15..14 */
> +       return kszphy_setup_led(phydev, 0x1e, 14);
> +}
> +
>  static int ksz8021_config_init(struct phy_device *phydev)
>  {
> -       int rc;
>         const u16 val = KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE;
> +       int rc;
> +
> +       rc = kszphy_setup_led(phydev, 0x1f, 4);
> +       if (rc)
> +               dev_err(&phydev->dev, "failed to set led mode\n");
> +
>         phy_write(phydev, MII_KSZPHY_OMSO, val);
>         rc = ksz_config_flags(phydev);
>         return rc < 0 ? rc : 0;
> @@ -166,6 +203,10 @@ static int ks8051_config_init(struct phy_device *phydev)
>  {
>         int rc;
>
> +       rc = kszphy_setup_led(phydev, 0x1f, 4);
> +       if (rc)
> +               dev_err(&phydev->dev, "failed to set led mode\n");
> +
>         rc = ksz_config_flags(phydev);
>         return rc < 0 ? rc : 0;
>  }
> @@ -327,7 +368,7 @@ static struct phy_driver ksphy_driver[] = {
>         .features       = (PHY_BASIC_FEATURES | SUPPORTED_Pause
>                                 | SUPPORTED_Asym_Pause),
>         .flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -       .config_init    = kszphy_config_init,
> +       .config_init    = kszphy_config_init_led8041,
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .ack_interrupt  = kszphy_ack_interrupt,
> @@ -342,7 +383,7 @@ static struct phy_driver ksphy_driver[] = {
>         .features       = PHY_BASIC_FEATURES |
>                           SUPPORTED_Pause | SUPPORTED_Asym_Pause,
>         .flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -       .config_init    = kszphy_config_init,
> +       .config_init    = kszphy_config_init_led8041,
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .ack_interrupt  = kszphy_ack_interrupt,
> @@ -371,7 +412,7 @@ static struct phy_driver ksphy_driver[] = {
>         .phy_id_mask    = 0x00ffffff,
>         .features       = (PHY_BASIC_FEATURES | SUPPORTED_Pause),
>         .flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -       .config_init    = kszphy_config_init,
> +       .config_init    = kszphy_config_init_led8041,
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .ack_interrupt  = kszphy_ack_interrupt,
> --
> 1.8.5.3
>



-- 
Florian
