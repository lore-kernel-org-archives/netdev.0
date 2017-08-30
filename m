From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Wed, 30 Aug 2017 10:49:13 +0530
Message-ID: <d84fd9c4-d214-1140-09d8-75f2fa64a850@ti.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <thomas.petazzoni@free-electrons.com>, <nadavh@marvell.com>,
        <linux@armlinux.org.uk>, <linux-kernel@vger.kernel.org>,
        <mw@semihalf.com>, <stefanc@marvell.com>,
        <miquel.raynal@free-electrons.com>, <netdev@vger.kernel.org>
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        <davem@davemloft.net>, <andrew@lunn.ch>, <jason@lakedaemon.net>,
        <sebastian.hesselbarth@gmail.com>,
        <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:34658 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdH3FTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 01:19:41 -0400
In-Reply-To: <20170828145725.2539-3-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Antoine,

On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> On the CP110 unit, which can be found on various Marvell platforms such
> as the 7k and 8k (currently), a comphy (common PHYs) hardware block can
> be found. This block provides a number of PHYs which can be used in
> various modes by other controllers (network, SATA ...). These common
> PHYs must be configured for the controllers using them to work correctly
> either at boot time, or when the system runs to switch the mode used.
> This patch adds a driver for this comphy hardware block, providing
> callbacks for the its PHYs so that consumers can configure the modes
> used.
> 
> As of this commit, two modes are supported by the comphy driver: sgmii
> and 10gkr.

Have one more minor comment in addition to my previous comments..
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/phy/marvell/Kconfig                  |  10 +
>  drivers/phy/marvell/Makefile                 |   1 +
>  drivers/phy/marvell/phy-mvebu-cp110-comphy.c | 656 +++++++++++++++++++++++++++
>  3 files changed, 667 insertions(+)
>  create mode 100644 drivers/phy/marvell/phy-mvebu-cp110-comphy.c
> 
> diff --git a/drivers/phy/marvell/Kconfig b/drivers/phy/marvell/Kconfig
> index 048d8893bc2e..26755f3d1a9a 100644
> --- a/drivers/phy/marvell/Kconfig
> +++ b/drivers/phy/marvell/Kconfig
> @@ -21,6 +21,16 @@ config PHY_BERLIN_USB
>  	help
>  	  Enable this to support the USB PHY on Marvell Berlin SoCs.
>  
> +config PHY_MVEBU_CP110_COMPHY
> +	tristate "Marvell CP110 comphy driver"
> +	depends on ARCH_MVEBU && OF
> +	select GENERIC_PHY
> +	help
> +	  This driver allows to control the comphy, an hardware block providing
> +	  shared serdes PHYs on Marvell Armada 7k/8k (in the CP110). Its serdes
> +	  lanes can be used by various controllers (Ethernet, sata, usb,
> +	  PCIe...).
> +
>  config PHY_MVEBU_SATA
>  	def_bool y
>  	depends on ARCH_DOVE || MACH_DOVE || MACH_KIRKWOOD
> diff --git a/drivers/phy/marvell/Makefile b/drivers/phy/marvell/Makefile
> index 3fc188f59118..0cf6a7cbaf9f 100644
> --- a/drivers/phy/marvell/Makefile
> +++ b/drivers/phy/marvell/Makefile
> @@ -1,6 +1,7 @@
>  obj-$(CONFIG_ARMADA375_USBCLUSTER_PHY)	+= phy-armada375-usb2.o
>  obj-$(CONFIG_PHY_BERLIN_SATA)		+= phy-berlin-sata.o
>  obj-$(CONFIG_PHY_BERLIN_USB)		+= phy-berlin-usb.o
> +obj-$(CONFIG_PHY_MVEBU_CP110_COMPHY)	+= phy-mvebu-cp110-comphy.o
>  obj-$(CONFIG_PHY_MVEBU_SATA)		+= phy-mvebu-sata.o
>  obj-$(CONFIG_PHY_PXA_28NM_HSIC)		+= phy-pxa-28nm-hsic.o
>  obj-$(CONFIG_PHY_PXA_28NM_USB2)		+= phy-pxa-28nm-usb2.o
> diff --git a/drivers/phy/marvell/phy-mvebu-cp110-comphy.c b/drivers/phy/marvell/phy-mvebu-cp110-comphy.c
> new file mode 100644
> index 000000000000..41556e790856
> --- /dev/null
> +++ b/drivers/phy/marvell/phy-mvebu-cp110-comphy.c
> @@ -0,0 +1,656 @@
> +/*
> + * Copyright (C) 2017 Marvell
> + *
> + * Antoine Tenart <antoine.tenart@free-electrons.com>
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/io.h>
> +#include <linux/iopoll.h>
> +#include <linux/mfd/syscon.h>
> +#include <linux/module.h>
> +#include <linux/phy/phy.h>
> +#include <linux/platform_device.h>
> +#include <linux/regmap.h>
> +
> +/* Relative to priv->base */
> +#define MVEBU_COMPHY_SERDES_CFG0(n)		(0x0 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_SERDES_CFG0_PU_PLL	BIT(1)
> +#define     MVEBU_COMPHY_SERDES_CFG0_GEN_RX(n)	((n) << 3)
> +#define     MVEBU_COMPHY_SERDES_CFG0_GEN_TX(n)	((n) << 7)
> +#define     MVEBU_COMPHY_SERDES_CFG0_PU_RX	BIT(11)
> +#define     MVEBU_COMPHY_SERDES_CFG0_PU_TX	BIT(12)
> +#define     MVEBU_COMPHY_SERDES_CFG0_HALF_BUS	BIT(14)
> +#define MVEBU_COMPHY_SERDES_CFG1(n)		(0x4 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_SERDES_CFG1_RESET	BIT(3)
> +#define     MVEBU_COMPHY_SERDES_CFG1_RX_INIT	BIT(4)
> +#define     MVEBU_COMPHY_SERDES_CFG1_CORE_RESET	BIT(5)
> +#define     MVEBU_COMPHY_SERDES_CFG1_RF_RESET	BIT(6)
> +#define MVEBU_COMPHY_SERDES_CFG2(n)		(0x8 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_SERDES_CFG2_DFE_EN	BIT(4)
> +#define MVEBU_COMPHY_SERDES_STATUS0(n)		(0x18 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY	BIT(2)
> +#define     MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY	BIT(3)
> +#define     MVEBU_COMPHY_SERDES_STATUS0_RX_INIT		BIT(4)
> +#define MVEBU_COMPHY_PWRPLL_CTRL(n)		(0x804 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(n)	((n) << 0)
> +#define     MVEBU_COMPHY_PWRPLL_PHY_MODE(n)	((n) << 5)
> +#define MVEBU_COMPHY_IMP_CAL(n)			(0x80c + (n) * 0x1000)
> +#define     MVEBU_COMPHY_IMP_CAL_TX_EXT(n)	((n) << 10)
> +#define     MVEBU_COMPHY_IMP_CAL_TX_EXT_EN	BIT(15)
> +#define MVEBU_COMPHY_DFE_RES(n)			(0x81c + (n) * 0x1000)
> +#define     MVEBU_COMPHY_DFE_RES_FORCE_GEN_TBL	BIT(15)
> +#define MVEBU_COMPHY_COEF(n)			(0x828 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_COEF_DFE_EN		BIT(14)
> +#define     MVEBU_COMPHY_COEF_DFE_CTRL		BIT(15)
> +#define MVEBU_COMPHY_GEN1_S0(n)			(0x834 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_GEN1_S0_TX_AMP(n)	((n) << 1)
> +#define     MVEBU_COMPHY_GEN1_S0_TX_EMPH(n)	((n) << 7)
> +#define MVEBU_COMPHY_GEN1_S1(n)			(0x838 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_PI(n)	((n) << 0)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_PF(n)	((n) << 3)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_FI(n)	((n) << 6)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_FF(n)	((n) << 8)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_DFE_EN	BIT(10)
> +#define     MVEBU_COMPHY_GEN1_S1_RX_DIV(n)	((n) << 11)
> +#define MVEBU_COMPHY_GEN1_S2(n)			(0x8f4 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_GEN1_S2_TX_EMPH(n)	((n) << 0)
> +#define     MVEBU_COMPHY_GEN1_S2_TX_EMPH_EN	BIT(4)
> +#define MVEBU_COMPHY_LOOPBACK(n)		(0x88c + (n) * 0x1000)
> +#define     MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(n)	((n) << 1)
> +#define MVEBU_COMPHY_VDD_CAL0(n)		(0x908 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_VDD_CAL0_CONT_MODE	BIT(15)
> +#define MVEBU_COMPHY_EXT_SELV(n)		(0x914 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_EXT_SELV_RX_SAMPL(n)	((n) << 5)
> +#define MVEBU_COMPHY_MISC_CTRL0(n)		(0x93c + (n) * 0x1000)
> +#define     MVEBU_COMPHY_MISC_CTRL0_ICP_FORCE	BIT(5)
> +#define     MVEBU_COMPHY_MISC_CTRL0_REFCLK_SEL	BIT(10)
> +#define MVEBU_COMPHY_RX_CTRL1(n)		(0x940 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL	BIT(11)
> +#define     MVEBU_COMPHY_RX_CTRL1_CLK8T_EN	BIT(12)
> +#define MVEBU_COMPHY_SPEED_DIV(n)		(0x954 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_SPEED_DIV_TX_FORCE	BIT(7)
> +#define MVEBU_SP_CALIB(n)			(0x96c + (n) * 0x1000)
> +#define     MVEBU_SP_CALIB_SAMPLER(n)		((n) << 8)
> +#define     MVEBU_SP_CALIB_SAMPLER_EN		BIT(12)
> +#define MVEBU_COMPHY_TX_SLEW_RATE(n)		(0x974 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_TX_SLEW_RATE_EMPH(n)	((n) << 5)
> +#define     MVEBU_COMPHY_TX_SLEW_RATE_SLC(n)	((n) << 10)
> +#define MVEBU_COMPHY_DLT_CTRL(n)		(0x984 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN	BIT(2)
> +#define MVEBU_COMPHY_FRAME_DETECT0(n)		(0xa14 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_FRAME_DETECT0_PATN(n)	((n) << 7)
> +#define MVEBU_COMPHY_FRAME_DETECT3(n)		(0xa20 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_FRAME_DETECT3_LOST_TIMEOUT_EN	BIT(12)
> +#define MVEBU_COMPHY_DME(n)			(0xa28 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_DME_ETH_MODE		BIT(7)
> +#define MVEBU_COMPHY_TRAINING0(n)		(0xa68 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_TRAINING0_P2P_HOLD	BIT(15)
> +#define MVEBU_COMPHY_TRAINING5(n)		(0xaa4 + (n) * 0x1000)
> +#define	    MVEBU_COMPHY_TRAINING5_RX_TIMER(n)	((n) << 0)
> +#define MVEBU_COMPHY_TX_TRAIN_PRESET(n)		(0xb1c + (n) * 0x1000)
> +#define     MVEBU_COMPHY_TX_TRAIN_PRESET_16B_AUTO_EN	BIT(8)
> +#define     MVEBU_COMPHY_TX_TRAIN_PRESET_PRBS11		BIT(9)
> +#define MVEBU_COMPHY_GEN1_S3(n)			(0xc40 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_GEN1_S3_FBCK_SEL	BIT(9)
> +#define MVEBU_COMPHY_GEN1_S4(n)			(0xc44 + (n) * 0x1000)
> +#define	    MVEBU_COMPHY_GEN1_S4_DFE_RES(n)	((n) << 8)
> +#define MVEBU_COMPHY_TX_PRESET(n)		(0xc68 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_TX_PRESET_INDEX(n)	((n) << 0)
> +#define MVEBU_COMPHY_GEN1_S5(n)			(0xd38 + (n) * 0x1000)
> +#define     MVEBU_COMPHY_GEN1_S5_ICP(n)		((n) << 0)
> +
> +/* Relative to priv->regmap */
> +#define MVEBU_COMPHY_CONF1(n)			(0x1000 + (n) * 0x28)
> +#define     MVEBU_COMPHY_CONF1_PWRUP		BIT(1)
> +#define     MVEBU_COMPHY_CONF1_USB_PCIE		BIT(2)	/* 0: Ethernet/SATA */
> +#define MVEBU_COMPHY_CONF6(n)			(0x1014 + (n) * 0x28)
> +#define     MVEBU_COMPHY_CONF6_40B		BIT(18)
> +#define MVEBU_COMPHY_SELECTOR			0x1140
> +#define     MVEBU_COMPHY_SELECTOR_PHY(n)	((n) * 0x4)
> +
> +#define MVEBU_COMPHY_LANES	6
> +#define MVEBU_COMPHY_PORTS	3
> +
> +struct mvebu_comhy_conf {
> +	enum phy_mode mode;
> +	unsigned lane;
> +	unsigned port;
> +	u32 mux;
> +};
> +
> +#define MVEBU_COMPHY_CONF(_lane, _port, _mode, _mux)	\
> +	{						\
> +		.lane = _lane,				\
> +		.port = _port,				\
> +		.mode = _mode,				\
> +		.mux = _mux,				\
> +	}
> +
> +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] = {
> +	/* lane 0 */
> +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> +	/* lane 1 */
> +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> +	/* lane 2 */
> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> +	/* lane 3 */
> +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> +	/* lane 4 */
> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> +	/* lane 5 */
> +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> +};
> +
> +struct mvebu_comphy_priv {
> +	void __iomem *base;
> +	struct regmap *regmap;
> +	struct device *dev;
> +	struct phy *phys[MVEBU_COMPHY_LANES];
> +	int modes[MVEBU_COMPHY_LANES];
> +};
> +
> +struct mvebu_comphy_lane {
> +	struct mvebu_comphy_priv *priv;
> +	struct device_node *of_node;
> +	unsigned id;
> +	enum phy_mode mode;
> +	int port;
> +};
> +
> +static int mvebu_comphy_get_mux(int lane, int port, enum phy_mode mode)
> +{
> +	int i, n = ARRAY_SIZE(mvebu_comphy_cp110_modes);
> +
> +	/* Unused PHY mux value is 0x0 */
> +	if (mode == PHY_MODE_INVALID)
> +		return 0;
> +
> +	for (i = 0; i < n; i++) {
> +		if (mvebu_comphy_cp110_modes[i].lane == lane &&
> +		    mvebu_comphy_cp110_modes[i].port == port &&
> +		    mvebu_comphy_cp110_modes[i].mode == mode)
> +			break;
> +	}
> +
> +	if (i == n)
> +		return -EINVAL;
> +
> +	return mvebu_comphy_cp110_modes[i].mux;
> +}
> +
> +static void mvebu_comphy_ethernet_init_reset(struct mvebu_comphy_lane *lane,
> +					     enum phy_mode mode)
> +{
> +	struct mvebu_comphy_priv *priv = lane->priv;
> +	u32 val;
> +
> +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), &val);
> +	val &= ~MVEBU_COMPHY_CONF1_USB_PCIE;
> +	val |= MVEBU_COMPHY_CONF1_PWRUP;
> +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), val);
> +
> +	/* Select baud rates and PLLs */
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> +	val &= ~(MVEBU_COMPHY_SERDES_CFG0_PU_PLL |
> +		 MVEBU_COMPHY_SERDES_CFG0_PU_RX |
> +		 MVEBU_COMPHY_SERDES_CFG0_PU_TX |
> +		 MVEBU_COMPHY_SERDES_CFG0_HALF_BUS |
> +		 MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0xf) |
> +		 MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0xf));
> +	if (mode == PHY_MODE_10GKR)
> +		val |= MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0xe) |
> +		       MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0xe);
> +	else if (mode == PHY_MODE_SGMII)
> +		val |= MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0x6) |
> +		       MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0x6) |
> +		       MVEBU_COMPHY_SERDES_CFG0_HALF_BUS;
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> +
> +	/* reset */
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +	val &= ~(MVEBU_COMPHY_SERDES_CFG1_RESET |
> +		 MVEBU_COMPHY_SERDES_CFG1_CORE_RESET |
> +		 MVEBU_COMPHY_SERDES_CFG1_RF_RESET);
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +
> +	/* de-assert reset */
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +	val |= MVEBU_COMPHY_SERDES_CFG1_RESET |
> +	       MVEBU_COMPHY_SERDES_CFG1_CORE_RESET;
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +
> +	/* wait until clocks are ready */
> +	mdelay(1);
> +
> +	/* exlicitly disable 40B, the bits isn't clear on reset */
> +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF6(lane->id), &val);
> +	val &= ~MVEBU_COMPHY_CONF6_40B;
> +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF6(lane->id), val);
> +
> +	/* refclk selection */
> +	val = readl(priv->base + MVEBU_COMPHY_MISC_CTRL0(lane->id));
> +	val &= ~MVEBU_COMPHY_MISC_CTRL0_REFCLK_SEL;
> +	if (mode == PHY_MODE_10GKR)
> +		val |= MVEBU_COMPHY_MISC_CTRL0_ICP_FORCE;
> +	writel(val, priv->base + MVEBU_COMPHY_MISC_CTRL0(lane->id));
> +
> +	/* power and pll selection */
> +	val = readl(priv->base + MVEBU_COMPHY_PWRPLL_CTRL(lane->id));
> +	val &= ~(MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(0x1f) |
> +		 MVEBU_COMPHY_PWRPLL_PHY_MODE(0x7));
> +	val |= MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(0x1) |
> +	       MVEBU_COMPHY_PWRPLL_PHY_MODE(0x4);
> +	writel(val, priv->base + MVEBU_COMPHY_PWRPLL_CTRL(lane->id));
> +
> +	val = readl(priv->base + MVEBU_COMPHY_LOOPBACK(lane->id));
> +	val &= ~MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(0x7);
> +	val |= MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(0x1);
> +	writel(val, priv->base + MVEBU_COMPHY_LOOPBACK(lane->id));
> +}
> +
> +static int mvebu_comphy_init_plls(struct mvebu_comphy_lane *lane,
> +				  enum phy_mode mode)
> +{
> +	struct mvebu_comphy_priv *priv = lane->priv;
> +	u32 val;
> +
> +	/* SERDES external config */
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> +	val |= MVEBU_COMPHY_SERDES_CFG0_PU_PLL |
> +	       MVEBU_COMPHY_SERDES_CFG0_PU_RX |
> +	       MVEBU_COMPHY_SERDES_CFG0_PU_TX;
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> +
> +	/* check rx/tx pll */
> +	readl_poll_timeout(priv->base + MVEBU_COMPHY_SERDES_STATUS0(lane->id),
> +			   val,
> +			   val & (MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY |
> +				  MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY),
> +			   1000, 150000);
> +	if (!(val & (MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY |
> +		     MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY)))
> +		return -ETIMEDOUT;
> +
> +	/* rx init */
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +	val |= MVEBU_COMPHY_SERDES_CFG1_RX_INIT;
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +
> +	/* check rx */
> +	readl_poll_timeout(priv->base + MVEBU_COMPHY_SERDES_STATUS0(lane->id),
> +			   val, val & MVEBU_COMPHY_SERDES_STATUS0_RX_INIT,
> +			   1000, 10000);
> +	if (!(val & MVEBU_COMPHY_SERDES_STATUS0_RX_INIT))
> +		return -ETIMEDOUT;
> +
> +	val = readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +	val &= ~MVEBU_COMPHY_SERDES_CFG1_RX_INIT;
> +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> +
> +	return 0;
> +}
> +
> +static int mvebu_comphy_set_mode_sgmii(struct phy *phy, enum phy_mode mode)

the mode need not be passed as argument here since this function is only for
sgmii mode.
> +{
> +	struct mvebu_comphy_lane *lane = phy_get_drvdata(phy);
> +	struct mvebu_comphy_priv *priv = lane->priv;
> +	u32 val;
> +
> +	mvebu_comphy_ethernet_init_reset(lane, mode);
> +
> +	val = readl(priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> +	val &= ~MVEBU_COMPHY_RX_CTRL1_CLK8T_EN;
> +	val |= MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL;
> +	writel(val, priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> +
> +	val = readl(priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> +	val &= ~MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN;
> +	writel(val, priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> +
> +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), &val);
> +	val &= ~MVEBU_COMPHY_CONF1_USB_PCIE;
> +	val |= MVEBU_COMPHY_CONF1_PWRUP;
> +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), val);
> +
> +	val = readl(priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> +	val &= ~MVEBU_COMPHY_GEN1_S0_TX_EMPH(0xf);
> +	val |= MVEBU_COMPHY_GEN1_S0_TX_EMPH(0x1);
> +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> +
> +	return mvebu_comphy_init_plls(lane, mode);
> +}
> +
> +static int mvebu_comphy_set_mode_10gkr(struct phy *phy, enum phy_mode mode)

same here..

Thanks
Kishon
