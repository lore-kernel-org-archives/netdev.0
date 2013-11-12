From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 08/10] net: stmmac:sti: Add STi SOC glue driver.
Date: Tue, 12 Nov 2013 13:53:03 +0000
Message-ID: <1384264383-7653-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

STi series SOCs have a glue layer on top of the synopsis gmac IP, this
glue layer needs to be configured before the gmac driver starts using
the IP.

This patch adds a platform driver for the glue layer which configures
the IP before stmmac driver takes over.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../devicetree/bindings/net/sti-dwmac.txt          |   45 +++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  294 ++++++++++++++++++++
 3 files changed, 340 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c

diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Documentation/devicetree/bindings/net/sti-dwmac.txt
new file mode 100644
index 0000000..5431d9d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
@@ -0,0 +1,45 @@
+STMicroelectronics SoC DWMAC controller
+
+The device node has following properties.
+
+Required properties:
+ - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac" or
+   "st,stid127-dwmac".
+ - reg		: Offset of the glue configuration register map in system
+   configuration regmap pointed by st,syscon property and size.
+ - st,syscon	: Should be phandle to system configuration node which
+   encompases this glue registers.
+ - st,tx-retime-src: This specifies which clk is wired up to the mac for
+   retimeing tx lines. This is totally board dependent and can take one of the
+   posssible values from "txclk", "clk_125", "phyclk" or "clkgen".
+
+Optional properties:
+ - resets	: phandle pointing to the system reset controller with correct
+   reset line index for ethernet reset.
+
+Sub-nodes:
+The dwmac core should be added as subnode to STMicroelectronics dwmac glue.
+- dwmac :	The binding details of dwmac can be found in
+  Documentation/devicetree/bindings/net/stmmac.txt
+
+Example:
+
+ethernet0: ethernet0{
+	#address-cells = <1>;
+	#size-cells = <1>;
+	compatible		= "st,stih415-dwmac";
+	reg			= <0x148 0x4>;
+	resets			= <&softreset STIH415_ETH0_SOFTRESET>;
+	st,syscon		= <&syscfg_rear>;
+	st,tx-retime-src	= "clk_125";
+	ranges;
+
+	dwmac0:dwmac@fe810000 {
+		device_type 	= "network";
+		compatible	= "snps,dwmac", "snps,dwmac-3.610";
+		reg 		= <0xfe810000 0x8000>;
+		interrupts 	= <0 147 0>;
+		interrupt-names = "macirq";
+		...
+	};
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 356a9dd..32db223 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
+stmmac-$(CONFIG_ARCH_STI) += dwmac-sti.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
new file mode 100644
index 0000000..34cfa96
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -0,0 +1,294 @@
+/**
+ * dwmac-sti.c - STMicroelectronics DWMAC Specific Glue layer
+ *
+ * Copyright (C) 2003-2013 STMicroelectronics (R&D) Limited
+ * Author: Srinivas Kandagatla <srinivas.kandagatla@st.com>
+ *
+ * Inspired by drivers/usb/dwc3/dwc3-exynos.c
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
+#include <linux/reset.h>
+#include <linux/clk.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+
+#define BITS_MASK(lsb, msb)	((BIT(msb - lsb + 1) - 1) << lsb)
+
+#define TX_RETIME_SRC_MASK		BITS_MASK(6, 8)
+#define ETH_SEL_TX_RETIME_CLK		BIT(8)
+#define ETH_SEL_INTERNAL_NOTEXT_PHYCLK	BIT(7)
+#define ETH_SEL_TXCLK_NOT_CLK125	BIT(6)
+
+#define ENMII_MASK			BITS_MASK(5, 5)
+#define ENMII				BIT(5)
+
+/**
+ * 3 bits [4:2]
+ *	000-GMII/MII
+ *	001-RGMII
+ *	010-SGMII
+ *	100-RMII
+*/
+#define MII_PHY_SEL_MASK		BITS_MASK(2, 4)
+#define ETH_PHY_SEL_RMII		BIT(4)
+#define ETH_PHY_SEL_SGMII		BIT(3)
+#define ETH_PHY_SEL_RGMII		BIT(2)
+#define ETH_PHY_SEL_GMII		0x0
+#define ETH_PHY_SEL_MII			0x0
+
+struct sti_dwmac {
+	int	interface;
+	int	tx_retime_src;
+	int	reg;
+	struct	device *dev;
+	struct	regmap *regmap;
+	struct	device_node *dwmac_np;
+	struct	reset_control *rstc;
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
+	TX_RETIME_SRC_NA,
+	TX_RETIME_SRC_TXCLK,
+	TX_RETIME_SRC_MII_CLK_125,
+	TX_RETIME_SRC_PHYCLK,
+	TX_RETIME_SRC_CLKGEN,
+};
+
+static const char * const tx_retime_srcs[] = {
+	[TX_RETIME_SRC_NA]		= "",
+	[TX_RETIME_SRC_TXCLK]		= "txclk",
+	[TX_RETIME_SRC_MII_CLK_125]	= "clk_125",
+	[TX_RETIME_SRC_PHYCLK]		= "phyclk",
+	[TX_RETIME_SRC_CLKGEN]		= "clkgen",
+};
+
+/**
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
+static u32 tx_retime_val[] = {
+	[TX_RETIME_SRC_TXCLK]		= ETH_SEL_TXCLK_NOT_CLK125,
+	[TX_RETIME_SRC_MII_CLK_125]	= 0x0,
+	[TX_RETIME_SRC_PHYCLK]		= ETH_SEL_TX_RETIME_CLK,
+	[TX_RETIME_SRC_CLKGEN]		= ETH_SEL_TX_RETIME_CLK |
+					 ETH_SEL_INTERNAL_NOTEXT_PHYCLK,
+};
+
+static int sti_get_tx_retime_src(struct device_node *np)
+{
+	const char *rs;
+	int err, i;
+
+	err = of_property_read_string(np, "st,tx-retime-src", &rs);
+	if (err < 0)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(tx_retime_srcs); i++)
+		if (!strcasecmp(rs, tx_retime_srcs[i]))
+			return i;
+
+	return -EINVAL;
+}
+
+static int sti_dwmac_parse_data(struct sti_dwmac *dwmac, struct device *dev)
+{
+	struct resource res;
+	struct device_node *np	= dev->of_node;
+	struct device_node *stmmac_np;
+	struct regmap	*regmap;
+	int tx_retime_src;
+
+	stmmac_np = of_get_next_available_child(np, NULL);
+	if (!stmmac_np) {
+		dev_info(dev, "No dwmac node found\n");
+		return -EINVAL;
+	}
+
+	if (!of_device_is_compatible(stmmac_np, "snps,dwmac")) {
+		dev_info(dev, "dwmac node isn't compatible with snps,dwmac\n");
+		return -EINVAL;
+	}
+
+	dwmac->interface = of_get_phy_mode(stmmac_np);
+	of_node_put(stmmac_np);
+
+	if (of_address_to_resource(np, 0, &res))
+		return -EINVAL;
+
+	regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
+	if (IS_ERR(regmap))
+		return PTR_ERR(regmap);
+
+	tx_retime_src = sti_get_tx_retime_src(np);
+	if (tx_retime_src <= 0)
+		return tx_retime_src;
+
+	dwmac->tx_retime_src = tx_retime_src;
+	dwmac->regmap = regmap;
+	dwmac->dwmac_np = stmmac_np;
+	dwmac->reg = res.start;
+	dwmac->dev = dev;
+	dwmac->rstc = reset_control_get(dev, NULL);
+
+	if (IS_ERR(dwmac->rstc))
+		dwmac->rstc = NULL;
+
+	return 0;
+}
+
+static int sti_dwmac_setup(struct sti_dwmac *dwmac)
+{
+	struct regmap	*regmap = dwmac->regmap;
+	int tx_retime_src	= dwmac->tx_retime_src;
+	int iface		= dwmac->interface;
+	int reg			= dwmac->reg;
+	u32 val;
+
+	regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK,
+					phy_intf_sels[iface]);
+
+	val = (iface == PHY_INTERFACE_MODE_REVMII) ? 0 : ENMII;
+	regmap_update_bits(regmap, reg, ENMII_MASK, val);
+
+	regmap_update_bits(regmap, reg, TX_RETIME_SRC_MASK,
+				tx_retime_val[tx_retime_src]);
+
+	/* Enable the IP */
+	if (dwmac->rstc)
+		reset_control_deassert(dwmac->rstc);
+
+	return 0;
+}
+
+static int sti_dwmac_probe(struct platform_device *pdev)
+{
+	struct device		*dev = &pdev->dev;
+	struct device_node	*node = dev->of_node;
+	int			ret = -ENOMEM;
+	struct sti_dwmac	*dwmac;
+
+	dwmac = devm_kzalloc(dev, sizeof(*dwmac), GFP_KERNEL);
+
+	if (!dwmac)
+		return -ENOMEM;
+
+	ret = sti_dwmac_parse_data(dwmac, dev);
+	if (ret) {
+		dev_err(dev, "Unable to parse OF data\n");
+		return ret;
+	}
+
+	ret = sti_dwmac_setup(dwmac);
+	if (ret) {
+		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
+		return ret;
+	}
+
+	if (node) {
+		ret = of_platform_populate(node, NULL, NULL, dev);
+		if (ret) {
+			dev_err(dev, "failed to add dwmac core\n");
+			return ret;
+		}
+	} else {
+		dev_err(dev, "no device node, failed to add dwmac core\n");
+		return -ENODEV;
+	}
+
+	platform_set_drvdata(pdev, dwmac);
+
+	return 0;
+}
+
+static int sti_dwmac_remove(struct platform_device *pdev)
+{
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int sti_dwmac_suspend(struct device *dev)
+{
+	struct sti_dwmac *dwmac = dev_get_drvdata(dev);
+
+	if (!device_child_may_wakeup(dev))
+		reset_control_assert(dwmac->rstc);
+
+	return 0;
+}
+
+static int sti_dwmac_resume(struct device *dev)
+{
+	struct sti_dwmac *dwmac = dev_get_drvdata(dev);
+
+	if (!device_child_may_wakeup(dev))
+		sti_dwmac_setup(dwmac);
+
+	return 0;
+}
+
+static SIMPLE_DEV_PM_OPS(sti_dwmac_pm_ops, sti_dwmac_suspend, sti_dwmac_resume);
+#endif
+
+static const struct of_device_id sti_dwmac_match[] = {
+	{ .compatible = "st,stih415-dwmac" },
+	{ .compatible = "st,stih416-dwmac" },
+	{ .compatible = "st,stid127-dwmac" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, sti_dwmac_match);
+
+static struct platform_driver sti_dwmac_driver = {
+	.probe		= sti_dwmac_probe,
+	.remove		= sti_dwmac_remove,
+	.driver		= {
+		.name	= "sti-dwmac",
+		.of_match_table = of_match_ptr(sti_dwmac_match),
+#ifdef CONFIG_PM
+		.pm     = &sti_dwmac_pm_ops,
+#endif
+	},
+};
+
+module_platform_driver(sti_dwmac_driver);
+
+MODULE_ALIAS("platform:sti-dwmac");
+MODULE_AUTHOR("Srinivas Kandagatla <srinivas.kandagatla@st.com>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("STMicroelectronics DWMAC Glue Layer");
-- 
1.7.6.5
