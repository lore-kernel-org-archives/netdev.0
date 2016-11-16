From: Anand Moon <linux.amoon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable options
Date: Wed, 16 Nov 2016 22:36:09 +0530
Message-ID: <CANAwSgTjG8G0U+A1p7hOKND9rjY4BzZfPgyWWHAEryYkHj_UOw@mail.gmail.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com> <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479220154-25851-2-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 Hi Jerome.

On 15 November 2016 at 19:59, Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> wrote:
> On some platforms, energy efficient ethernet with rtl8211 devices is
> causing issue, like throughput drop or broken link.
>
> This was reported on the OdroidC2 (DWMAC + RTL8211F). While the issue root
> cause is not fully understood yet, disabling EEE advertisement prevent auto
> negotiation from enabling EEE.
>
> This patch provides options to disable 1000T and 100TX EEE advertisement
> individually for the realtek phys supporting this feature.
>
> Reported-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
> Cc: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
> Signed-off-by: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> Tested-by: Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/phy/realtek.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 64 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
> index aadd6e9f54ad..77235fd5faaf 100644
> --- a/drivers/net/phy/realtek.c
> +++ b/drivers/net/phy/realtek.c
> @@ -15,6 +15,12 @@
>   */
>  #include <linux/phy.h>
>  #include <linux/module.h>
> +#include <linux/of.h>
> +
> +struct rtl8211x_phy_priv {
> +       bool eee_1000t_disable;
> +       bool eee_100tx_disable;
> +};
>
>  #define RTL821x_PHYSR          0x11
>  #define RTL821x_PHYSR_DUPLEX   0x2000
> @@ -93,12 +99,44 @@ static int rtl8211f_config_intr(struct phy_device *phydev)
>         return err;
>  }
>
> +static void rtl8211x_clear_eee_adv(struct phy_device *phydev)
> +{
> +       struct rtl8211x_phy_priv *priv = phydev->priv;
> +       u16 val;
> +
> +       if (priv->eee_1000t_disable || priv->eee_100tx_disable) {
> +               val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
> +                                           MDIO_MMD_AN);
> +
> +               if (priv->eee_1000t_disable)
> +                       val &= ~MDIO_AN_EEE_ADV_1000T;
> +               if (priv->eee_100tx_disable)
> +                       val &= ~MDIO_AN_EEE_ADV_100TX;
> +
> +               phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
> +                                      MDIO_MMD_AN, val);
> +       }
> +}
> +
> +static int rtl8211x_config_init(struct phy_device *phydev)
> +{
> +       int ret;
> +
> +       ret = genphy_config_init(phydev);
> +       if (ret < 0)
> +               return ret;
> +
> +       rtl8211x_clear_eee_adv(phydev);
> +
> +       return 0;
> +}
> +
>  static int rtl8211f_config_init(struct phy_device *phydev)
>  {
>         int ret;
>         u16 reg;
>
> -       ret = genphy_config_init(phydev);
> +       ret = rtl8211x_config_init(phydev);
>         if (ret < 0)
>                 return ret;
>
> @@ -115,6 +153,26 @@ static int rtl8211f_config_init(struct phy_device *phydev)
>         return 0;
>  }
>
> +static int rtl8211x_phy_probe(struct phy_device *phydev)
> +{
> +       struct device *dev = &phydev->mdio.dev;
> +       struct device_node *of_node = dev->of_node;
> +       struct rtl8211x_phy_priv *priv;
> +
> +       priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +       if (!priv)
> +               return -ENOMEM;
> +
> +       priv->eee_1000t_disable =
> +               of_property_read_bool(of_node, "realtek,disable-eee-1000t");
> +       priv->eee_100tx_disable =
> +               of_property_read_bool(of_node, "realtek,disable-eee-100tx");
> +
> +       phydev->priv = priv;
> +
> +       return 0;
> +}
> +
>  static struct phy_driver realtek_drvs[] = {
>         {
>                 .phy_id         = 0x00008201,
> @@ -140,7 +198,9 @@ static struct phy_driver realtek_drvs[] = {
>                 .phy_id_mask    = 0x001fffff,
>                 .features       = PHY_GBIT_FEATURES,
>                 .flags          = PHY_HAS_INTERRUPT,
> +               .probe          = &rtl8211x_phy_probe,
>                 .config_aneg    = genphy_config_aneg,
> +               .config_init    = &rtl8211x_config_init,
>                 .read_status    = genphy_read_status,
>                 .ack_interrupt  = rtl821x_ack_interrupt,
>                 .config_intr    = rtl8211e_config_intr,
> @@ -152,7 +212,9 @@ static struct phy_driver realtek_drvs[] = {
>                 .phy_id_mask    = 0x001fffff,
>                 .features       = PHY_GBIT_FEATURES,
>                 .flags          = PHY_HAS_INTERRUPT,
> +               .probe          = &rtl8211x_phy_probe,
>                 .config_aneg    = &genphy_config_aneg,
> +               .config_init    = &rtl8211x_config_init,
>                 .read_status    = &genphy_read_status,
>                 .ack_interrupt  = &rtl821x_ack_interrupt,
>                 .config_intr    = &rtl8211e_config_intr,
> @@ -164,6 +226,7 @@ static struct phy_driver realtek_drvs[] = {
>                 .phy_id_mask    = 0x001fffff,
>                 .features       = PHY_GBIT_FEATURES,
>                 .flags          = PHY_HAS_INTERRUPT,
> +               .probe          = &rtl8211x_phy_probe,
>                 .config_aneg    = &genphy_config_aneg,
>                 .config_init    = &rtl8211f_config_init,
>                 .read_status    = &genphy_read_status,
> --
> 2.7.4
>

How about adding callback functionality for .soft_reset to handle BMCR
where we update the Auto-Negotiation for the phy,
as per the datasheet of the rtl8211f.

-Best Regard
Anand Moon

>
> _______________________________________________
> linux-amlogic mailing list
> linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-amlogic
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
