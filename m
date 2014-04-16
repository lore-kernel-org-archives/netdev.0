From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] ARM: i.MX6: Add OF configuration support for ksz9031
Date: Wed, 16 Apr 2014 16:03:25 +0800
Message-ID: <20140416080322.GA11602@dragon>
References: <1397466496-24750-1-git-send-email-hchaumette@adeneo-embedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <kernel@pengutronix.de>,
	<linux@arm.linux.org.uk>, <f.fainelli@gmail.com>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<agust@denx.de>
To: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397466496-24750-1-git-send-email-hchaumette@adeneo-embedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 14, 2014 at 11:08:16AM +0200, Hubert Chaumette wrote:
> - Adds support for ksz9031 PAD skew configuration over devicetree
> - Removes hard-coded pad skew configuration for imx6q-sabrelite, now redundant
>   with arch/arm/boot/dts/imx6qdl-sabrelite.dtsi
> 
> Tested on congatec conga-QEVAL board with conga-QMX6 module.
> 
> This patch is based on Anatolij Gustschin's patch from
> http://www.spinics.net/lists/arm-kernel/msg319771.html
> 
> Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
> ---
>  arch/arm/mach-imx/mach-imx6q.c |  45 ----------
>  drivers/net/phy/micrel.c       | 185 ++++++++++++++++++++++++++++++++++++++++-

You should probably leave mach-imx6q.c unchanged, because dropping the
phy fix-up from there may break old DTBs.  And the changes on micrel.c
should be submitted to net maintainer.

Shawn

>  2 files changed, 184 insertions(+), 46 deletions(-)
> 
> diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
> index 76e5db4..21ad961 100644
> --- a/arch/arm/mach-imx/mach-imx6q.c
> +++ b/arch/arm/mach-imx/mach-imx6q.c
> @@ -39,47 +39,6 @@
>  #include "cpuidle.h"
>  #include "hardware.h"
>  
> -/* For imx6q sabrelite board: set KSZ9021RN RGMII pad skew */
> -static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> -{
> -	if (IS_BUILTIN(CONFIG_PHYLIB)) {
> -		/* min rx data delay */
> -		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW);
> -		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> -
> -		/* max rx/tx clock delay, min rx/tx control delay */
> -		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> -		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
> -		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> -			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> -	}
> -
> -	return 0;
> -}
> -
> -static void mmd_write_reg(struct phy_device *dev, int device, int reg, int val)
> -{
> -	phy_write(dev, 0x0d, device);
> -	phy_write(dev, 0x0e, reg);
> -	phy_write(dev, 0x0d, (1 << 14) | device);
> -	phy_write(dev, 0x0e, val);
> -}
> -
> -static int ksz9031rn_phy_fixup(struct phy_device *dev)
> -{
> -	/*
> -	 * min rx data delay, max rx/tx clock delay,
> -	 * min rx/tx control delay
> -	 */
> -	mmd_write_reg(dev, 2, 4, 0);
> -	mmd_write_reg(dev, 2, 5, 0);
> -	mmd_write_reg(dev, 2, 8, 0x003ff);
> -
> -	return 0;
> -}
> -
>  /*
>   * fixup for PLX PEX8909 bridge to configure GPIO1-7 as output High
>   * as they are used for slots1-7 PERST#
> @@ -169,10 +128,6 @@ static int ar8035_phy_fixup(struct phy_device *dev)
>  static void __init imx6q_enet_phy_init(void)
>  {
>  	if (IS_BUILTIN(CONFIG_PHYLIB)) {
> -		phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
> -				ksz9021rn_phy_fixup);
> -		phy_register_fixup_for_uid(PHY_ID_KSZ9031, MICREL_PHY_ID_MASK,
> -				ksz9031rn_phy_fixup);
>  		phy_register_fixup_for_uid(PHY_ID_AR8031, 0xffffffff,
>  				ar8031_phy_fixup);
>  		phy_register_fixup_for_uid(PHY_ID_AR8035, 0xffffffef,
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 5a8993b..df56b26 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -242,6 +242,189 @@ static int ksz9021_config_init(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +#define MII_KSZ9031RN_MMD_CTRL_REG	0x0d
> +#define MII_KSZ9031RN_MMD_REGDATA_REG	0x0e
> +#define OP_DATA				1
> +#define KSZ9031_PS_TO_REG		60
> +
> +/* Extended registers */
> +#define MII_KSZ9031RN_CONTROL_PAD_SKEW	4
> +#define MII_KSZ9031RN_RX_DATA_PAD_SKEW	5
> +#define MII_KSZ9031RN_TX_DATA_PAD_SKEW	6
> +#define MII_KSZ9031RN_CLK_PAD_SKEW	8
> +
> +static int ksz9031_extended_write(struct phy_device *phydev,
> +				  u8 mode, u32 dev_addr, u32 regnum, u16 val)
> +{
> +	phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
> +	phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
> +	phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14) | dev_addr);
> +	return phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, val);
> +}
> +
> +static int ksz9031_extended_read(struct phy_device *phydev,
> +				 u8 mode, u32 dev_addr, u32 regnum)
> +{
> +	phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
> +	phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
> +	phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14) | dev_addr);
> +	return phy_read(phydev, MII_KSZ9031RN_MMD_REGDATA_REG);
> +}
> +
> +/* Two 5-bit fields register */
> +static int ksz9031_load_clk_skew_values(struct phy_device *phydev,
> +					struct device_node *of_node,
> +					char *field1, char *field2)
> +{
> +	int val1 = -1;
> +	int val2 = -2;
> +	int newval;
> +	int matches = 0;
> +
> +	if (!of_property_read_u32(of_node, field1, &val1))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field2, &val2))
> +		matches++;
> +
> +	if (!matches)
> +		return 0;
> +
> +	if (matches < 2)
> +		newval = ksz9031_extended_read(phydev, OP_DATA, 2,
> +				MII_KSZ9031RN_CLK_PAD_SKEW);
> +	else
> +		newval = 0;
> +
> +	if (val1 != -1)
> +		newval = (newval & 0xffe0) |
> +			 ((val1 / KSZ9031_PS_TO_REG) & 0x1f);
> +
> +	if (val2 != -2)
> +		newval = (newval & 0xfc1f) |
> +			 (((val2 / KSZ9031_PS_TO_REG) & 0x1f) << 5);
> +
> +	return ksz9031_extended_write(phydev, OP_DATA, 2,
> +			MII_KSZ9031RN_CLK_PAD_SKEW, newval);
> +}
> +
> +/* Four 4-bit fields register */
> +static int ksz9031_load_data_skew_values(struct phy_device *phydev,
> +					 struct device_node *of_node, u16 reg,
> +					 char *field1, char *field2,
> +					 char *field3, char *field4)
> +{
> +	int val1 = -1;
> +	int val2 = -2;
> +	int val3 = -3;
> +	int val4 = -4;
> +	int newval;
> +	int matches = 0;
> +
> +	if (!of_property_read_u32(of_node, field1, &val1))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field2, &val2))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field3, &val3))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field4, &val4))
> +		matches++;
> +
> +	if (!matches)
> +		return 0;
> +
> +	if (matches < 4)
> +		newval = ksz9031_extended_read(phydev, OP_DATA, 2, reg);
> +	else
> +		newval = 0;
> +
> +	if (val1 != -1)
> +		newval = (newval & 0xfff0) |
> +			 (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
> +
> +	if (val2 != -2)
> +		newval = (newval & 0xff0f) |
> +			 (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
> +
> +	if (val3 != -3)
> +		newval = (newval & 0xf0ff) |
> +			 (((val3 / KSZ9031_PS_TO_REG) & 0xf) << 8);
> +
> +	if (val4 != -4)
> +		newval = (newval & 0x0fff) |
> +			 (((val4 / KSZ9031_PS_TO_REG) & 0xf) << 12);
> +
> +	return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
> +}
> +
> +/* Two 4-bit fields register */
> +static int ksz9031_load_ctrl_skew_values(struct phy_device *phydev,
> +					 struct device_node *of_node,
> +					 char *field1, char *field2)
> +{
> +	int val1 = -1;
> +	int val2 = -2;
> +	int newval;
> +	int matches = 0;
> +
> +	if (!of_property_read_u32(of_node, field1, &val1))
> +		matches++;
> +
> +	if (!of_property_read_u32(of_node, field2, &val2))
> +		matches++;
> +
> +	if (!matches)
> +		return 0;
> +
> +	if (matches < 2)
> +		newval = ksz9031_extended_read(phydev, OP_DATA, 2,
> +				MII_KSZ9031RN_CONTROL_PAD_SKEW);
> +	else
> +		newval = 0;
> +
> +	if (val1 != -1)
> +		newval = (newval & 0xfff0) |
> +			 (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0);
> +
> +	if (val2 != -2)
> +		newval = (newval & 0xff0f) |
> +			 (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4);
> +
> +	return ksz9031_extended_write(phydev, OP_DATA, 2,
> +			MII_KSZ9031RN_CONTROL_PAD_SKEW, newval);
> +}
> +
> +static int ksz9031_config_init(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->dev;
> +	struct device_node *of_node = dev->of_node;
> +
> +	if (!of_node && dev->parent->of_node)
> +		of_node = dev->parent->of_node;
> +
> +	if (of_node) {
> +		ksz9031_load_clk_skew_values(phydev, of_node,
> +				"rxc-skew-ps", "txc-skew-ps");
> +
> +		ksz9031_load_data_skew_values(phydev, of_node,
> +				MII_KSZ9031RN_RX_DATA_PAD_SKEW,
> +				"rxd0-skew-ps", "rxd1-skew-ps",
> +				"rxd2-skew-ps", "rxd3-skew-ps");
> +
> +		ksz9031_load_data_skew_values(phydev, of_node,
> +				MII_KSZ9031RN_TX_DATA_PAD_SKEW,
> +				"txd0-skew-ps", "txd1-skew-ps",
> +				"txd2-skew-ps", "txd3-skew-ps");
> +
> +		ksz9031_load_ctrl_skew_values(phydev, of_node,
> +				"txen-skew-ps", "rxdv-skew-ps");
> +	}
> +	return 0;
> +}
> +
>  #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	(1 << 6)
>  #define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	(1 << 4)
> @@ -428,7 +611,7 @@ static struct phy_driver ksphy_driver[] = {
>  	.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause
>  				| SUPPORTED_Asym_Pause),
>  	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
> -	.config_init	= kszphy_config_init,
> +	.config_init	= ksz9031_config_init,
>  	.config_aneg	= genphy_config_aneg,
>  	.read_status	= genphy_read_status,
>  	.ack_interrupt	= kszphy_ack_interrupt,
> -- 
> 1.9.1
> 
