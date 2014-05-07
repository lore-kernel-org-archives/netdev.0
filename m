From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 2/2] ARM: i.MX6: Add OF configuration support for ksz9031
Date: Wed, 7 May 2014 10:31:45 -0700
Message-ID: <CAGVrzcb6MP-LMrQDmeP8EcpN9y_RZe=_3hTYP6zZD_U5cJgdHw@mail.gmail.com>
References: <1399362017-25787-1-git-send-email-hchaumette@adeneo-embedded.com> <1399362017-25787-3-git-send-email-hchaumette@adeneo-embedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Randy Dunlap <rdunlap@infradead.org>, xobs@kosagi.com,
	David Miller <davem@davemloft.net>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1399362017-25787-3-git-send-email-hchaumette@adeneo-embedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-05-06 0:40 GMT-07:00 Hubert Chaumette <hchaumette@adeneo-embedded.com>:
> Adds support for ksz9031 PAD skew configuration over devicetree.
>
> Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/micrel.c | 106 ++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 105 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index d849684..bc7c7d2 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -283,6 +283,110 @@ static int ksz9021_config_init(struct phy_device *phydev)
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
> +static int ksz9031_of_load_skew_values(struct phy_device *phydev,
> +                                      struct device_node *of_node,
> +                                      u16 reg, size_t field_sz,
> +                                      char *field[], u8 numfields)
> +{
> +       int val[4] = {-1, -2, -3, -4};
> +       int matches = 0;
> +       u16 mask;
> +       u16 maxval;
> +       u16 newval;
> +       int i;
> +
> +       for (i = 0; i < numfields; i++)
> +               if (!of_property_read_u32(of_node, field[i], val + i))
> +                       matches++;
> +
> +       if (!matches)
> +               return 0;
> +
> +       if (matches < numfields)
> +               newval = ksz9031_extended_read(phydev, OP_DATA, 2, reg);
> +       else
> +               newval = 0;
> +
> +       maxval = (field_sz == 4) ? 0xf : 0x1f;
> +       for (i = 0; i < numfields; i++)
> +               if (val[i] != -(i + 1)) {
> +                       mask = 0xffff;
> +                       mask ^= maxval << (field_sz * i);
> +                       newval = (newval & mask) |
> +                               (((val[i] / KSZ9031_PS_TO_REG) & maxval)
> +                                       << (field_sz * i));
> +               }
> +
> +       return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
> +}
> +
> +static int ksz9031_config_init(struct phy_device *phydev)
> +{
> +       struct device *dev = &phydev->dev;
> +       struct device_node *of_node = dev->of_node;
> +       char *clk_skews[2] = {"rxc-skew-ps", "txc-skew-ps"};
> +       char *rx_data_skews[4] = {
> +               "rxd0-skew-ps", "rxd1-skew-ps",
> +               "rxd2-skew-ps", "rxd3-skew-ps"
> +       };
> +       char *tx_data_skews[4] = {
> +               "txd0-skew-ps", "txd1-skew-ps",
> +               "txd2-skew-ps", "txd3-skew-ps"
> +       };
> +       char *control_skews[2] = {"txen-skew-ps", "rxdv-skew-ps"};
> +
> +       if (!of_node && dev->parent->of_node)
> +               of_node = dev->parent->of_node;
> +
> +       if (of_node) {
> +               ksz9031_of_load_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_CLK_PAD_SKEW, 5,
> +                               clk_skews, 2);
> +
> +               ksz9031_of_load_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_CONTROL_PAD_SKEW, 4,
> +                               control_skews, 2);
> +
> +               ksz9031_of_load_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_RX_DATA_PAD_SKEW, 4,
> +                               rx_data_skews, 4);
> +
> +               ksz9031_of_load_skew_values(phydev, of_node,
> +                               MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
> +                               tx_data_skews, 4);
> +       }
> +       return 0;
> +}
> +
>  #define KSZ8873MLL_GLOBAL_CONTROL_4    0x06
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX     (1 << 6)
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED      (1 << 4)
> @@ -469,7 +573,7 @@ static struct phy_driver ksphy_driver[] = {
>         .features       = (PHY_GBIT_FEATURES | SUPPORTED_Pause
>                                 | SUPPORTED_Asym_Pause),
>         .flags          = PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -       .config_init    = kszphy_config_init,
> +       .config_init    = ksz9031_config_init,
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .ack_interrupt  = kszphy_ack_interrupt,
> --
> 2.0.0.rc0
>



-- 
Florian
