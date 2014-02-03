From: <srinivas.kandagatla@st.com>
Subject: [PATCH v1 1/3] net: stmmac:sti: Add STi SOC glue driver.
Date: Mon, 3 Feb 2014 12:01:08 +0000
Message-ID: <1391428868-27245-1-git-send-email-srinivas.kandagatla@st.com>
References: <1391428787-27143-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Russell King <linux@arm.linux.org.uk>, kernel@stlinux.com,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Srinivas Kandagatla <srinivas.kandagatla@st.com>, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, Stuart Menefy <stuart.menefy@st.com>,
 Rob Herring <robh+dt@kernel.org>, Rob Landley <rob@landley.net>,
 Kumar Gala <galak@codeaurora.org>, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1391428787-27143-1-git-send-email-srinivas.kandagatla@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

STi series SOCs have a glue layer on top of the synopsis gmac IP, this
glue layer needs to be configured before the gmac driver starts using
the IP.

This patch adds a support to this glue layer which is configured via
stmmac setup, init, exit callbacks.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../devicetree/bindings/net/sti-dwmac.txt          |   58 ++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  331 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    5 +
 6 files changed, 409 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c

diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Documentation/devicetree/bindings/net/sti-dwmac.txt
new file mode 100644
index 0000000..3dd3d0b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
@@ -0,0 +1,58 @@
+STMicroelectronics SoC DWMAC glue layer controller
+
+The device node has following properties.
+
+Required properties:
+ - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac" or
+   "st,stid127-dwmac".
+ - reg		: Offset of the glue configuration register map in system
+   configuration regmap pointed by st,syscon property and size.
+
+ - reg-names	: Should be "sti-ethconf".
+
+ - st,syscon	: Should be phandle to system configuration node which
+   encompases this glue registers.
+
+ - st,tx-retime-src: On STi Parts for Giga bit speeds, 125Mhz clocks can be
+   wired up in from different sources. One via TXCLK pin and other via CLK_125
+   pin. This wiring is totally board dependent. However the retiming glue
+   logic should be configured accordingly. Possible values for this property
+
+	   "txclk" - if 125Mhz clock is wired up via txclk line.
+	   "clk_125" - if 125Mhz clock is wired up via clk_125 line.
+
+   This property is only valid for Giga bit setup( GMII, RGMII), and it is
+   un-used for non-giga bit (MII and RMII) setups. Also note that internal
+   clockgen can not generate stable 125Mhz clock.
+
+ - st,ext-phyclk: This boolean property indicates who is generating the clock
+  for tx and rx. This property is only valid for RMII case where the clock can
+  be generated from the MAC or PHY.
+
+ - clock-names: should be "sti-ethclk".
+ - clocks: Should point to ethernet clockgen which can generate phyclk.
+
+
+Example:
+
+ethernet0: dwmac@fe810000 {
+	device_type 	= "network";
+	compatible	= "st,stih416-dwmac", "snps,dwmac", "snps,dwmac-3.710";
+	reg 		= <0xfe810000 0x8000>, <0x8bc 0x4>;
+	reg-names	= "stmmaceth", "sti-ethconf";
+	interrupts	= <0 133 0>, <0 134 0>, <0 135 0>;
+	interrupt-names	= "macirq", "eth_wake_irq", "eth_lpi";
+	phy-mode	= "mii";
+
+	st,syscon	= <&syscfg_rear>;
+
+	snps,pbl 	= <32>;
+	snps,mixed-burst;
+
+	resets		= <&softreset STIH416_ETH0_SOFTRESET>;
+	reset-names	= "stmmaceth";
+	pinctrl-0	= <&pinctrl_mii0>;
+	pinctrl-names 	= "default";
+	clocks		= <&CLK_S_GMAC0_PHY>;
+	clock-names	= "stmmaceth";
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index e2f202e..f2d7c70 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -37,6 +37,17 @@ config DWMAC_SUNXI
 	  stmmac device driver. This driver is used for A20/A31
 	  GMAC 	  ethernet controller.
 
+config DWMAC_STI
+	bool "STi GMAC support"
+	depends on STMMAC_PLATFORM && ARCH_STI
+	default y
+	---help---
+	  Support for ethernet controller on STi SOCs.
+
+	  This selects STi SoC glue layer support for the stmmac
+	  device driver. This driver is used on for the STi series
+	  SOCs GMAC ethernet controller.
+
 config STMMAC_PCI
 	bool "STMMAC PCI bus support"
 	depends on STMMAC_ETH && PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index ecadece..dcef287 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -2,6 +2,7 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
+stmmac-$(CONFIG_DWMAC_STI) += dwmac-sti.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
new file mode 100644
index 0000000..d87584cb
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -0,0 +1,331 @@
+/**
+ * dwmac-sti.c - STMicroelectronics DWMAC Specific Glue layer
+ *
+ * Copyright (C) 2003-2014 STMicroelectronics (R&D) Limited
+ * Author: Srinivas Kandagatla <srinivas.kandagatla@st.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/platform_device.h>
+#include <linux/stmmac.h>
+#include <linux/phy.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
+#include <linux/clk.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+
+/**
+ *			STi GMAC glue logic.
+ *			--------------------
+ *
+ *		 _
+ *		|  \
+ *	--------|0  \ ETH_SEL_INTERNAL_NOTEXT_PHYCLK
+ * phyclk	|    |___________________________________________
+ *		|    |	|			(phyclk-in)
+ *	--------|1  /	|
+ * int-clk	|_ /	|
+ *			|	 _
+ *			|	|  \
+ *			|_______|0  \ ETH_SEL_TX_RETIME_CLK
+ *				|    |___________________________
+ *				|    |		(tx-retime-clk)
+ *			 _______|1  /
+ *			|	|_ /
+ *		 _	|
+ *		|  \	|
+ *	--------|0  \	|
+ * clk_125	|    |__|
+ *		|    |	ETH_SEL_TXCLK_NOT_CLK125
+ *	--------|1  /
+ * txclk	|_ /
+ *
+ *
+ * ETH_SEL_INTERNAL_NOTEXT_PHYCLK is valid only for RMII where PHY can
+ * generate 50MHz clock or MAC can generate it.
+ * This bit is configured by "st,ext-phyclk" property.
+ *
+ * ETH_SEL_TXCLK_NOT_CLK125 is only valid for gigabit modes, where the 125Mhz
+ * clock either comes from clk-125 pin or txclk pin. This configuration is
+ * totally driven by the board wiring. This bit is configured by
+ * "st,tx-retime-src" property.
+ *
+ * TXCLK configuration is different for different phy interface modes
+ * and changes according to link speed in modes like RGMII.
+ *
+ * Below table summarizes the clock requirement and clock sources for
+ * supported phy interface modes with link speeds.
+ * ________________________________________________
+ *|  PHY_MODE	| 1000 Mbit Link | 100 Mbit Link   |
+ * ------------------------------------------------
+ *|	MII	|	n/a	 |	25Mhz	   |
+ *|		|		 |	txclk	   |
+ * ------------------------------------------------
+ *|	GMII	|     125Mhz	 |	25Mhz	   |
+ *|		|  clk-125/txclk |	txclk	   |
+ * ------------------------------------------------
+ *|	RGMII	|     125Mhz	 |	25Mhz	   |
+ *|		|  clk-125/txclk |	clkgen     |
+ * ------------------------------------------------
+ *|	RMII	|	n/a	 |	25Mhz	   |
+ *|		|		 |clkgen/phyclk-in |
+ * ------------------------------------------------
+ *
+ * TX lines are always retimed with a clk, which can vary depending
+ * on the board configuration. Below is the table of these bits
+ * in eth configuration register depending on source of retime clk.
+ *
+ *---------------------------------------------------------------
+ * src	 | tx_rt_clk	| int_not_ext_phyclk	| txclk_n_clk125|
+ *---------------------------------------------------------------
+ * txclk |	0	|	n/a		|	1	|
+ *---------------------------------------------------------------
+ * ck_125|	0	|	n/a		|	0	|
+ *---------------------------------------------------------------
+ * phyclk|	1	|	0		|	n/a	|
+ *---------------------------------------------------------------
+ * clkgen|	1	|	1		|	n/a	|
+ *---------------------------------------------------------------
+ */
+
+ /* Register definition */
+
+ /* 3 bits [8:6]
+ *  [6:6]	ETH_SEL_TXCLK_NOT_CLK125
+ *  [7:7]	ETH_SEL_INTERNAL_NOTEXT_PHYCLK
+ *  [8:8]	ETH_SEL_TX_RETIME_CLK
+ *
+ */
+
+#define TX_RETIME_SRC_MASK		GENMASK(8, 6)
+#define ETH_SEL_TX_RETIME_CLK		BIT(8)
+#define ETH_SEL_INTERNAL_NOTEXT_PHYCLK	BIT(7)
+#define ETH_SEL_TXCLK_NOT_CLK125	BIT(6)
+
+#define ENMII_MASK			GENMASK(5, 5)
+#define ENMII				BIT(5)
+
+/**
+ * 3 bits [4:2]
+ *	000-GMII/MII
+ *	001-RGMII
+ *	010-SGMII
+ *	100-RMII
+*/
+#define MII_PHY_SEL_MASK		GENMASK(4, 2)
+#define ETH_PHY_SEL_RMII		BIT(4)
+#define ETH_PHY_SEL_SGMII		BIT(3)
+#define ETH_PHY_SEL_RGMII		BIT(2)
+#define ETH_PHY_SEL_GMII		0x0
+#define ETH_PHY_SEL_MII			0x0
+
+#define IS_PHY_IF_MODE_RGMII(iface)	(iface == PHY_INTERFACE_MODE_RGMII || \
+			iface == PHY_INTERFACE_MODE_RGMII_ID || \
+			iface == PHY_INTERFACE_MODE_RGMII_RXID || \
+			iface == PHY_INTERFACE_MODE_RGMII_TXID)
+
+#define IS_PHY_IF_MODE_GBIT(iface)	(IS_PHY_IF_MODE_RGMII(iface) || \
+			iface == PHY_INTERFACE_MODE_GMII)
+
+struct sti_dwmac {
+	int	interface;
+	bool	ext_phyclk;
+	bool	is_tx_retime_src_clk_125;
+	struct clk *clk;
+	int	reg;
+	struct	device *dev;
+	struct	regmap *regmap;
+};
+
+static u32 phy_intf_sels[] = {
+	[PHY_INTERFACE_MODE_MII]	= ETH_PHY_SEL_MII,
+	[PHY_INTERFACE_MODE_GMII]	= ETH_PHY_SEL_GMII,
+	[PHY_INTERFACE_MODE_RGMII]	= ETH_PHY_SEL_RGMII,
+	[PHY_INTERFACE_MODE_RGMII_ID]	= ETH_PHY_SEL_RGMII,
+	[PHY_INTERFACE_MODE_SGMII]	= ETH_PHY_SEL_SGMII,
+	[PHY_INTERFACE_MODE_RMII]	= ETH_PHY_SEL_RMII,
+};
+
+enum {
+	TX_RETIME_SRC_NA = 0,
+	TX_RETIME_SRC_TXCLK = 1,
+	TX_RETIME_SRC_CLK_125,
+	TX_RETIME_SRC_PHYCLK,
+	TX_RETIME_SRC_CLKGEN,
+};
+
+static const char * const tx_retime_srcs[] = {
+	[TX_RETIME_SRC_NA]		= "",
+	[TX_RETIME_SRC_TXCLK]		= "txclk",
+	[TX_RETIME_SRC_CLK_125]		= "clk_125",
+	[TX_RETIME_SRC_PHYCLK]		= "phyclk",
+	[TX_RETIME_SRC_CLKGEN]		= "clkgen",
+};
+
+static u32 tx_retime_val[] = {
+	[TX_RETIME_SRC_TXCLK]	= ETH_SEL_TXCLK_NOT_CLK125,
+	[TX_RETIME_SRC_CLK_125]	= 0x0,
+	[TX_RETIME_SRC_PHYCLK]	= ETH_SEL_TX_RETIME_CLK,
+	[TX_RETIME_SRC_CLKGEN]	= ETH_SEL_TX_RETIME_CLK |
+				ETH_SEL_INTERNAL_NOTEXT_PHYCLK,
+};
+
+static void setup_retime_src(struct sti_dwmac *dwmac, u32 spd)
+{
+	u32 src = 0, freq = 0;
+
+	if (spd == SPEED_100) {
+		if (dwmac->interface == PHY_INTERFACE_MODE_MII ||
+			dwmac->interface == PHY_INTERFACE_MODE_GMII) {
+				src = TX_RETIME_SRC_TXCLK;
+		} else if (dwmac->interface == PHY_INTERFACE_MODE_RMII) {
+			if (dwmac->ext_phyclk) {
+				src = TX_RETIME_SRC_PHYCLK;
+			} else {
+				src = TX_RETIME_SRC_CLKGEN;
+				freq = 50000000;
+			}
+
+		} else if (IS_PHY_IF_MODE_RGMII(dwmac->interface)) {
+			src = TX_RETIME_SRC_CLKGEN;
+			freq = 25000000;
+		}
+
+		if (src == TX_RETIME_SRC_CLKGEN && dwmac->clk)
+			clk_set_rate(dwmac->clk, freq);
+
+	} else if (spd == SPEED_1000) {
+		if (dwmac->is_tx_retime_src_clk_125)
+			src = TX_RETIME_SRC_CLK_125;
+		else
+			src = TX_RETIME_SRC_TXCLK;
+	}
+
+	regmap_update_bits(dwmac->regmap, dwmac->reg,
+				TX_RETIME_SRC_MASK, tx_retime_val[src]);
+}
+
+static void sti_dwmac_exit(struct platform_device *pdev, void *priv)
+{
+	struct sti_dwmac *dwmac = priv;
+
+	if (dwmac->clk)
+		clk_disable_unprepare(dwmac->clk);
+}
+
+static void sti_fix_mac_speed(void *priv, unsigned int spd)
+{
+	struct sti_dwmac *dwmac = priv;
+	setup_retime_src(dwmac, spd);
+	return;
+}
+
+static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
+		struct platform_device *pdev)
+{
+	struct resource *res;
+	struct device *dev	= &pdev->dev;
+	struct device_node *np	= dev->of_node;
+	struct regmap	*regmap;
+	int err;
+
+	if (!np)
+		return -EINVAL;
+
+	res = platform_get_resource_byname(pdev,
+				IORESOURCE_MEM, "sti-ethconf");
+	if (!res)
+		return -ENODATA;
+
+	regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
+	if (IS_ERR(regmap))
+		return PTR_ERR(regmap);
+
+	dwmac->dev = dev;
+	dwmac->interface = of_get_phy_mode(np);
+	dwmac->regmap = regmap;
+	dwmac->reg = res->start;
+	dwmac->ext_phyclk = of_property_read_bool(np, "st,ext-phyclk");
+
+	dwmac->is_tx_retime_src_clk_125 = false;
+
+	if (IS_PHY_IF_MODE_GBIT(dwmac->interface)) {
+		const char *rs;
+		err = of_property_read_string(np, "st,tx-retime-src", &rs);
+		if (err < 0) {
+			dev_err(dev, "st,tx-retime-src not specified\n");
+			return err;
+		}
+
+		if (!strcasecmp(rs, "clk_125"))
+			dwmac->is_tx_retime_src_clk_125 = true;
+
+	}
+
+	dwmac->clk = devm_clk_get(dev, "sti-ethclk");
+
+	if (IS_ERR(dwmac->clk))
+		dwmac->clk = NULL;
+
+	return 0;
+}
+
+static int sti_dwmac_init(struct platform_device *pdev, void *priv)
+{
+	struct sti_dwmac *dwmac = priv;
+	struct regmap *regmap = dwmac->regmap;
+	int iface = dwmac->interface;
+	u32 reg = dwmac->reg;
+	u32 val, spd;
+
+	if (dwmac->clk)
+		clk_prepare_enable(dwmac->clk);
+
+	regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK,
+					phy_intf_sels[iface]);
+
+	val = (iface == PHY_INTERFACE_MODE_REVMII) ? 0 : ENMII;
+	regmap_update_bits(regmap, reg, ENMII_MASK, val);
+
+	if (IS_PHY_IF_MODE_GBIT(iface))
+		spd = SPEED_1000;
+	else
+		spd = SPEED_100;
+
+	setup_retime_src(dwmac, spd);
+
+	return 0;
+}
+
+static void *sti_dwmac_setup(struct platform_device *pdev)
+{
+	struct sti_dwmac	*dwmac;
+	int ret;
+
+	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return ERR_PTR(-ENOMEM);
+
+	ret = sti_dwmac_parse_data(dwmac, pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "Unable to parse OF data\n");
+		return ERR_PTR(ret);
+	}
+
+	return dwmac;
+}
+
+const struct stmmac_of_data sti_gmac_data = {
+	.fix_mac_speed = sti_fix_mac_speed,
+	.setup = sti_dwmac_setup,
+	.init = sti_dwmac_init,
+	.exit = sti_dwmac_exit,
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index d9af26e..f9e60d7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -133,6 +133,9 @@ bool stmmac_eee_init(struct stmmac_priv *priv);
 #ifdef CONFIG_DWMAC_SUNXI
 extern const struct stmmac_of_data sun7i_gmac_data;
 #endif
+#ifdef CONFIG_DWMAC_STI
+extern const struct stmmac_of_data sti_gmac_data;
+#endif
 extern struct platform_driver stmmac_pltfr_driver;
 static inline int stmmac_register_platform(void)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 5884a7d..c61bc72b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -33,6 +33,11 @@ static const struct of_device_id stmmac_dt_ids[] = {
 #ifdef CONFIG_DWMAC_SUNXI
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 #endif
+#ifdef CONFIG_DWMAC_STI
+	{ .compatible = "st,stih415-dwmac", .data = &sti_gmac_data},
+	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
+	{ .compatible = "st,stih127-dwmac", .data = &sti_gmac_data},
+#endif
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
-- 
1.7.9.5
