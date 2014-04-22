From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] ARM: i.MX6: Add OF configuration support for ksz9031
Date: Tue, 22 Apr 2014 09:10:31 -0700
Message-ID: <CAGVrzcZbN+XP5kLb=cEL__+T9W8AY2ZWCtdZCMk9YUwo1r8Cnw@mail.gmail.com>
References: <1398181748-6500-1-git-send-email-hchaumette@adeneo-embedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:65066 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490AbaDVQLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 12:11:13 -0400
In-Reply-To: <1398181748-6500-1-git-send-email-hchaumette@adeneo-embedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-22 8:49 GMT-07:00 Hubert Chaumette <hchaumette@adeneo-embedded.com>:
> Adds support for ksz9031 PAD skew configuration over devicetree.
>
> Changes since v1:
> - Removed ksz9021 and ksz9031 fixup deletions from arch/arm/mach-imx/mach-imx6q.c

You should probably update the existing binding document in
Documentation/devicetree/bindings/net/micrel-ksz9021.txt to cover the
KSZ9031 PHY too.

>
> Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
> ---
>  drivers/net/phy/micrel.c | 185 ++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 184 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 5a8993b..df56b26 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -242,6 +242,189 @@ static int ksz9021_config_init(struct phy_device *phydev)
>         return 0;
>  }
>
> +#define MII_KSZ9031RN_MMD_CTRL_REG     0x0d
> +#define MII_KSZ9031RN_MMD_REGDATA_REG  0x0e
> +#define OP_DATA                                1
> +#define KSZ9031_PS_TO_REG              60
> +
> +/* Extended registers */
> +#define MII_KSZ9031RN_CONTROL_PAD_SKEW 4
> +#define MII_KSZ9031RN_RX_DATA_PAD_SKEW 5
> +#define MII_KSZ9031RN_TX_DATA_PAD_SKEW 6
> +#define MII_KSZ9031RN_CLK_PAD_SKEW     8
> +
> +static int ksz9031_extended_write(struct phy_device *phydev,
> +                                 u8 mode, u32 dev_addr, u32 regnum, u16 val)
> +{
> +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
> +       phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
> +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14) | dev_addr);
> +       return phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, val);
> +}
> +
> +static int ksz9031_extended_read(struct phy_device *phydev,
> +                                u8 mode, u32 dev_addr, u32 regnum)
> +{
> +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
> +       phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
> +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14) | dev_addr);
> +       return phy_read(phydev, MII_KSZ9031RN_MMD_REGDATA_REG);
> +}
> +
> +/* Two 5-bit fields register */
> +static int ksz9031_load_clk_skew_values(struct phy_device *phydev,
> +                                       struct device_node *of_node,
> +                                       char *field1, char *field2)
> +{
> +       int val1 = -1;
> +       int val2 = -2;
> +       int newval;
> +       int matches = 0;
> +
> +       if (!of_property_read_u32(of_node, field1, &val1))
> +               matches++;
> +
> +       if (!of_property_read_u32(of_node, field2, &val2))
> +               matches++;
> +
> +       if (!matches)
> +               return 0;
> +
> +       if (matches < 2)
> +               newval = ksz9031_extended_read(phydev, OP_DATA, 2,
> +                               MII_KSZ9031RN_CLK_PAD_SKEW);
> +       else
> +               newval = 0;
> +
> +       if (val1 != -1)
> +               newval = (newval & 0xffe0) |
> +                        ((val1 / KSZ9031_PS_TO_REG) & 0x1f);
> +
> +       if (val2 != -2)
> +               newval = (newval & 0xfc1f) |
> +                        (((val2 / KSZ9031_PS_TO_REG) & 0x1f) << 5);
> +
> +       return ksz9031_extended_write(phydev, OP_DATA, 2,
> +                       MII_KSZ9031RN_CLK_PAD_SKEW, newval);
> +}
> +
> +/* Four 4-bit fields register */
> +static int ksz9031_load_data_skew_values(struct phy_device *phydev,
> +                                        struct device_node *of_node, u16 reg,
> +                                        char *field1, char *field2,
> +                                        char *field3, char *field4)
> +{
> +       int val1 = -1;
> +       int val2 = -2;
> +       int val3 = -3;
> +       int val4 = -4;
> +       int newval;
> +       int matches = 0;
> +
> +       if (!of_property_read_u32(of_node, field1, &val1))
> +               matches++;
> +
> +       if (!of_property_read_u32(of_node, field2, &val2))
> +               matches++;
> +
> +       if (!of_property_read_u32(of_node, field3, &val3))
> +               matches++;
> +
> +       if (!of_property_read_u32(of_node, field4, &val4))
> +               matches++;
> +
> +       if (!matches)
> +               return 0;
> +
> +       if (matches < 4)
> +               newval = ksz9031_extended_read(phydev, OP_DATA, 2, reg);
> +       else
> +               newval = 0;
> +
> +       if (val1 != -1)
> +               newval = (newval & 0xfff0) |
> +                        (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
> +
> +       if (val2 != -2)
> +               newval = (newval & 0xff0f) |
> +                        (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
> +
> +       if (val3 != -3)
> +               newval = (newval & 0xf0ff) |
> +                        (((val3 / KSZ9031_PS_TO_REG) & 0xf) << 8);
> +
> +       if (val4 != -4)
> +               newval = (newval & 0x0fff) |
> +                        (((val4 / KSZ9031_PS_TO_REG) & 0xf) << 12);

How about something like this:

for (i = 0; i < 4; i++) {
            if (val[i] != -i) {
                    mask = 0xffff;
                    mask <<= (0 << (i * 4));
                    newval = (newval & mask) |
                           (((val[i] / KSZ9031_PS_TO_REG) & 0xf) << (i *4);
            }
}

Such that you could factor ksz9031_load_ctrl_skew_values() and
ksz9031_load_data_skew_values() to specify the number of matches they
should have?

> +
> +       return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
> +}
> +
> +/* Two 4-bit fields register */
> +static int ksz9031_load_ctrl_skew_values(struct phy_device *phydev,
> +                                        struct device_node *of_node,
> +                                        char *field1, char *field2)
> +{
> +       int val1 = -1;
> +       int val2 = -2;
> +       int newval;
> +       int matches = 0;
> +
> +       if (!of_property_read_u32(of_node, field1, &val1))
> +               matches++;
> +
> +       if (!of_property_read_u32(of_node, field2, &val2))
> +               matches++;
> +
> +       if (!matches)
> +               return 0;
> +
> +       if (matches < 2)
> +               newval = ksz9031_extended_read(phydev, OP_DATA, 2,
> +                               MII_KSZ9031RN_CONTROL_PAD_SKEW);
> +       else
> +               newval = 0;
> +
> +       if (val1 != -1)
> +               newval = (newval & 0xfff0) |
> +                        (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
> +
> +       if (val2 != -2)
> +               newval = (newval & 0xff0f) |
> +                        (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
> +
> +       return ksz9031_extended_write(phydev, OP_DATA, 2,
> +                       MII_KSZ9031RN_CONTROL_PAD_SKEW, newval);
> +}
> +
> +static int ksz9031_config_init(struct phy_device *phydev)
> +{
> +       struct device *dev = &phydev->dev;
> +       struct device_node *of_node = dev->of_node;
> +
> +       if (!of_node && dev->parent->of_node)
> +               of_node = dev->parent->of_node;
> +
> +       if (of_node) {
> +               ksz9031_load_clk_skew_values(phydev, of_node,
> +                               "rxc-skew-ps", "txc-skew-ps");
> +
> +               ksz9031_load_data_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_RX_DATA_PAD_SKEW,
> +                               "rxd0-skew-ps", "rxd1-skew-ps",
> +                               "rxd2-skew-ps", "rxd3-skew-ps");
> +
> +               ksz9031_load_data_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_TX_DATA_PAD_SKEW,
> +                               "txd0-skew-ps", "txd1-skew-ps",
> +                               "txd2-skew-ps", "txd3-skew-ps");
> +
> +               ksz9031_load_ctrl_skew_values(phydev, of_node,
> +                               "txen-skew-ps", "rxdv-skew-ps");
> +       }
> +       return 0;
> +}
> +
>  #define KSZ8873MLL_GLOBAL_CONTROL_4    0x06
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX     (1 << 6)
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED      (1 << 4)
> @@ -428,7 +611,7 @@ static struct phy_driver ksphy_driver[] = {
>         .features       = (PHY_GBIT_FEATURES | SUPPORTED_Pause
>                                 | SUPPORTED_Asym_Pause),
>         .flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -       .config_init    = kszphy_config_init,
> +       .config_init    = ksz9031_config_init,
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .ack_interrupt  = kszphy_ack_interrupt,
> --
> 1.9.2
>



-- 
Florian
