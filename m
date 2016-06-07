From: <thloh@altera.com>
Subject: [PATCH v3 1/1] net: ethernet: Add TSE PCS support to dwmac-socfpga
Date: Mon, 6 Jun 2016 20:01:56 -0700
Message-ID: <1465268516-31480-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tien Hock Loh <thloh@altera.com>
To: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<peppe.cavallaro@st.com>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tien Hock Loh <thloh@altera.com>

This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
the dwmac is set to sgmii

Signed-off-by: Tien Hock Loh <thloh@altera.com>

---
v2:
- Refactored the TSE PCS out from the dwmac-socfpga.c file
- Added binding documentation for TSE PCS sgmii adapter
v3:
- Added missing license header for new source files
- Updated tse_pcs.h include headers
- Standardize if statements
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |   4 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 140 +++++++++--
 drivers/net/ethernet/stmicro/stmmac/tse_pcs.c      | 261 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/tse_pcs.h      |  36 +++
 5 files changed, 419 insertions(+), 24 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.h

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index 3a9d679..2bc39f1 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -15,6 +15,8 @@ Required properties:
 Optional properties:
 altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
 		DWMAC controller is connected emac splitter.
+phy-mode: The phy mode the ethernet operates in
+altr,sgmii_to_sgmii_converter: phandle to the TSE SGMII converter
 
 Example:
 
@@ -28,4 +30,6 @@ gmac0: ethernet@ff700000 {
 	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 	clocks = <&emac_0_clk>;
 	clock-names = "stmmaceth";
+	phy-mode = "sgmii";
+	altr,gmii_to_sgmii_converter = <&sgmii_1_gmii_to_sgmii_converter_0>;
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 73c2715..29c1dee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -6,7 +6,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 
 obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
-		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o
+		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o tse_pcs.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 3f9588e..88fba4e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -27,6 +27,8 @@
 #include "stmmac.h"
 #include "stmmac_platform.h"
 
+#include "tse_pcs.h"
+
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII 0x0
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII 0x1
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
@@ -47,48 +49,60 @@ struct socfpga_dwmac {
 	struct regmap *sys_mgr_base_addr;
 	struct reset_control *stmmac_rst;
 	void __iomem *splitter_base;
+	struct tse_pcs pcs;
 };
 
 static void socfpga_dwmac_fix_mac_speed(void *priv, unsigned int speed)
 {
 	struct socfpga_dwmac *dwmac = (struct socfpga_dwmac *)priv;
 	void __iomem *splitter_base = dwmac->splitter_base;
+	void __iomem *tse_pcs_base = dwmac->pcs.tse_pcs_base;
+	void __iomem *sgmii_adapter_base = dwmac->pcs.sgmii_adapter_base;
+	struct device *dev = dwmac->dev;
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct phy_device *phy_dev = ndev->phydev;
 	u32 val;
 
-	if (!splitter_base)
-		return;
-
-	val = readl(splitter_base + EMAC_SPLITTER_CTRL_REG);
-	val &= ~EMAC_SPLITTER_CTRL_SPEED_MASK;
-
-	switch (speed) {
-	case 1000:
-		val |= EMAC_SPLITTER_CTRL_SPEED_1000;
-		break;
-	case 100:
-		val |= EMAC_SPLITTER_CTRL_SPEED_100;
-		break;
-	case 10:
-		val |= EMAC_SPLITTER_CTRL_SPEED_10;
-		break;
-	default:
-		return;
+	if (splitter_base) {
+		val = readl(splitter_base + EMAC_SPLITTER_CTRL_REG);
+		val &= ~EMAC_SPLITTER_CTRL_SPEED_MASK;
+
+		switch (speed) {
+		case 1000:
+			val |= EMAC_SPLITTER_CTRL_SPEED_1000;
+			break;
+		case 100:
+			val |= EMAC_SPLITTER_CTRL_SPEED_100;
+			break;
+		case 10:
+			val |= EMAC_SPLITTER_CTRL_SPEED_10;
+			break;
+		default:
+			return;
+		}
+		writel(val, splitter_base + EMAC_SPLITTER_CTRL_REG);
 	}
 
-	writel(val, splitter_base + EMAC_SPLITTER_CTRL_REG);
+	if ((tse_pcs_base) && (sgmii_adapter_base))
+		tse_pcs_fix_mac_speed(&dwmac->pcs, phy_dev, speed);
 }
 
-static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *dev)
+static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac,
+				    struct device *dev)
 {
 	struct device_node *np = dev->of_node;
 	struct regmap *sys_mgr_base_addr;
 	u32 reg_offset, reg_shift;
-	int ret;
-	struct device_node *np_splitter;
+	int ret, index;
+	struct device_node *np_splitter = NULL;
+	struct device_node *np_sgmii_adapter = NULL;
+
 	struct resource res_splitter;
+	struct resource res_tse_pcs;
+	struct resource res_sgmii_adapter;
 
 	dwmac->stmmac_rst = devm_reset_control_get(dev,
-						  STMMAC_RESOURCE_NAME);
+						   STMMAC_RESOURCE_NAME);
 	if (IS_ERR(dwmac->stmmac_rst)) {
 		dev_info(dev, "Could not get reset control!\n");
 		if (PTR_ERR(dwmac->stmmac_rst) == -EPROBE_DEFER)
@@ -99,6 +113,7 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 	dwmac->interface = of_get_phy_mode(np);
 
 	sys_mgr_base_addr = syscon_regmap_lookup_by_phandle(np, "altr,sysmgr-syscon");
+
 	if (IS_ERR(sys_mgr_base_addr)) {
 		dev_info(dev, "No sysmgr-syscon node found\n");
 		return PTR_ERR(sys_mgr_base_addr);
@@ -130,6 +145,74 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 		}
 	}
 
+	np_sgmii_adapter = of_parse_phandle(np,
+					    "altr,gmii_to_sgmii_converter", 0);
+	if (np_sgmii_adapter) {
+		index = of_property_match_string(np_sgmii_adapter, "reg-names",
+						 "hps_emac_interface_splitter_avalon_slave");
+
+		if (index >= 0) {
+			if (of_address_to_resource(np_sgmii_adapter, index,
+						   &res_splitter)) {
+				dev_err(dev, "%s: ERROR: missing emac splitter address\n",
+					__func__);
+				return -EINVAL;
+			}
+
+			dwmac->splitter_base = devm_ioremap_resource(
+				dev, &res_splitter);
+
+			if (IS_ERR(dwmac->splitter_base)) {
+				dev_err(dev, "%s: ERROR: failed mapping emac splitter\n",
+					__func__);
+				return PTR_ERR(dwmac->splitter_base);
+			}
+		}
+
+		index = of_property_match_string(np_sgmii_adapter, "reg-names",
+						 "gmii_to_sgmii_adapter_avalon_slave");
+
+		if (index >= 0) {
+			if (of_address_to_resource(np_sgmii_adapter, index,
+						   &res_sgmii_adapter)) {
+				dev_err(dev,
+					"%s: ERROR: failed mapping adapter\n",
+					__func__);
+				return -EINVAL;
+			}
+
+			dwmac->pcs.sgmii_adapter_base =
+			devm_ioremap_resource(dev, &res_sgmii_adapter);
+
+			if (IS_ERR(dwmac->pcs.sgmii_adapter_base)) {
+				dev_err(dev, "%s: failed to mapping adapter\n",
+					__func__);
+				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+			}
+		}
+
+		index = of_property_match_string(np_sgmii_adapter, "reg-names",
+						 "eth_tse_control_port");
+
+		if (index >= 0) {
+			if (of_address_to_resource(np_sgmii_adapter, index,
+						   &res_tse_pcs)) {
+				dev_err(dev,
+					"%s: ERROR: failed mapping tse control port\n",
+					__func__);
+				return -EINVAL;
+			}
+
+			dwmac->pcs.tse_pcs_base = devm_ioremap_resource(
+			dev, &res_tse_pcs);
+
+			if (IS_ERR(dwmac->pcs.tse_pcs_base)) {
+				dev_err(dev, "%s: ERROR: failed mapping tse control port\n",
+					__func__);
+				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+			}
+		}
+	}
 	dwmac->reg_offset = reg_offset;
 	dwmac->reg_shift = reg_shift;
 	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
@@ -153,6 +236,7 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 		break;
 	case PHY_INTERFACE_MODE_MII:
 	case PHY_INTERFACE_MODE_GMII:
+	case PHY_INTERFACE_MODE_SGMII:
 		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
 		break;
 	default:
@@ -172,6 +256,10 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac *dwmac)
 	ctrl |= val << reg_shift;
 
 	regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
+
+	if (phymode == PHY_INTERFACE_MODE_SGMII)
+		tse_pcs_init(dwmac->pcs.tse_pcs_base, &dwmac->pcs);
+
 	return 0;
 }
 
@@ -191,6 +279,12 @@ static void *socfpga_dwmac_probe(struct platform_device *pdev)
 		return ERR_PTR(ret);
 	}
 
+	ret = socfpga_dwmac_setup(dwmac);
+	if (ret) {
+		dev_err(dev, "couldn't setup SoC glue (%d)\n", ret);
+		return ERR_PTR(ret);
+	}
+
 	return dwmac;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/tse_pcs.c
new file mode 100644
index 0000000..1989bd1
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/tse_pcs.c
@@ -0,0 +1,261 @@
+/* Copyright Altera Corporation (C) 2016. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, version 2,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * Author: Tien Hock Loh <thloh@altera.com>
+ */
+
+#include <linux/mfd/syscon.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/regmap.h>
+#include <linux/reset.h>
+#include <linux/stmmac.h>
+
+#include "stmmac.h"
+#include "stmmac_platform.h"
+#include "tse_pcs.h"
+
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII 0x0
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII 0x1
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH 2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK 0x00000003
+
+#define EMAC_SPLITTER_CTRL_REG			0x0
+#define EMAC_SPLITTER_CTRL_SPEED_MASK		0x3
+#define EMAC_SPLITTER_CTRL_SPEED_10		0x2
+#define EMAC_SPLITTER_CTRL_SPEED_100		0x3
+#define EMAC_SPLITTER_CTRL_SPEED_1000		0x0
+
+#define TSE_PCS_CONTROL_AN_EN_MASK			0x1000
+#define TSE_PCS_CONTROL_REG				0x00
+#define TSE_PCS_CONTROL_RESTART_AN_MASK		0x0200
+#define TSE_PCS_IF_MODE_REG				0x28
+#define TSE_PCS_LINK_TIMER_0_REG			0x24
+#define TSE_PCS_LINK_TIMER_1_REG			0x26
+#define TSE_PCS_SIZE					0x40
+#define TSE_PCS_STATUS_AN_COMPLETED_MASK		0x0020
+#define TSE_PCS_STATUS_LINK_MASK			0x0004
+#define TSE_PCS_STATUS_REG				0x02
+#define TSE_PCS_SGMII_SPEED_1000			0x8
+#define TSE_PCS_SGMII_SPEED_100			0x4
+#define TSE_PCS_SGMII_SPEED_10				0x0
+#define TSE_PCS_SW_RST_MASK				0x8000
+#define TSE_PCS_PARTNER_ABILITY_REG			0x0A
+#define TSE_PCS_PARTNER_DUPLEX_FULL			0x1000
+#define TSE_PCS_PARTNER_DUPLEX_HALF			0x0000
+#define TSE_PCS_PARTNER_DUPLEX_MASK			0x1000
+#define TSE_PCS_PARTNER_SPEED_MASK			0x0c00
+#define TSE_PCS_PARTNER_SPEED_1000			0x0800
+#define TSE_PCS_PARTNER_SPEED_100			0x0400
+#define TSE_PCS_PARTNER_SPEED_10			0x0000
+#define TSE_PCS_PARTNER_SPEED_1000			0x0800
+#define TSE_PCS_PARTNER_SPEED_100			0x0400
+#define TSE_PCS_PARTNER_SPEED_10			0x0000
+#define TSE_PCS_SGMII_SPEED_MASK			0x000C
+#define TSE_PCS_SGMII_LINK_TIMER_0			0x0D40
+#define TSE_PCS_SGMII_LINK_TIMER_1			0x0003
+#define TSE_PCS_SW_RESET_TIMEOUT			100
+#define TSE_PCS_USE_SGMII_AN_MASK			0x0002
+
+#define SGMII_ADAPTER_CTRL_REG				0x00
+#define SGMII_ADAPTER_DISABLE				0x0001
+#define SGMII_ADAPTER_ENABLE				0x0000
+#define LINK_TIMER					20
+#define AUTONEGO_TIMER					20
+
+static void config_tx_buffer(u16 data, void __iomem *base)
+{
+	writew(data, base + SGMII_ADAPTER_CTRL_REG);
+}
+
+static void tse_pcs_reset(void __iomem *base, struct tse_pcs *pcs)
+{
+	int counter = 0;
+	u16 val;
+
+	val = readw(base + TSE_PCS_CONTROL_REG);
+	val |= TSE_PCS_SW_RST_MASK;
+	writew(val, base + TSE_PCS_CONTROL_REG);
+
+	while (counter < TSE_PCS_SW_RESET_TIMEOUT) {
+		val = readw(base + TSE_PCS_CONTROL_REG);
+		val &= TSE_PCS_SW_RST_MASK;
+		if (val == 0)
+			break;
+		counter++;
+		udelay(1);
+	}
+	if (counter >= TSE_PCS_SW_RESET_TIMEOUT)
+		dev_err(pcs->dev, "PCS could not get out of sw reset\n");
+}
+
+void tse_pcs_init(void __iomem *base, struct tse_pcs *pcs)
+{
+	writew(0x0001, base + TSE_PCS_IF_MODE_REG);
+
+	writew(TSE_PCS_SGMII_LINK_TIMER_0, base + TSE_PCS_LINK_TIMER_0_REG);
+	writew(TSE_PCS_SGMII_LINK_TIMER_1, base + TSE_PCS_LINK_TIMER_1_REG);
+
+	tse_pcs_reset(base, pcs);
+	config_tx_buffer(SGMII_ADAPTER_ENABLE,
+			 pcs->sgmii_adapter_base);
+}
+
+static void pcs_link_timer_callback(unsigned long data)
+{
+	u16 val = 0;
+
+	struct tse_pcs *pcs = (struct tse_pcs *)data;
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+
+	val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
+	val &=  TSE_PCS_STATUS_LINK_MASK;
+
+	if (val != 0) {
+		dev_dbg(pcs->dev, "Adapter: Link is established\n");
+		config_tx_buffer(SGMII_ADAPTER_ENABLE, sgmii_adapter_base);
+	} else {
+		mod_timer(&pcs->link_timer, jiffies +
+				msecs_to_jiffies(LINK_TIMER));
+	}
+}
+
+static void auto_nego_timer_callback(unsigned long data)
+{
+	u16 val = 0;
+	u16 speed = 0;
+	u16 duplex = 0;
+
+	struct tse_pcs *pcs = (struct tse_pcs *)data;
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+
+	val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
+	val &=  TSE_PCS_STATUS_AN_COMPLETED_MASK;
+
+	if (val != 0) {
+		dev_dbg(pcs->dev, "Adapter: Auto Negotiation is completed\n");
+		val = readw(tse_pcs_base + TSE_PCS_PARTNER_ABILITY_REG);
+		speed = val & TSE_PCS_PARTNER_SPEED_MASK;
+		duplex = val & TSE_PCS_PARTNER_DUPLEX_MASK;
+
+		if (speed == TSE_PCS_PARTNER_SPEED_10 &&
+		    duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
+			dev_dbg(pcs->dev,
+				"Adapter: Link Partner is Up - 10/Full\n");
+		else if (speed == TSE_PCS_PARTNER_SPEED_100 &&
+			 duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
+			dev_dbg(pcs->dev,
+				"Adapter: Link Partner is Up - 100/Full\n");
+		else if (speed == TSE_PCS_PARTNER_SPEED_1000 &&
+			 duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
+			dev_dbg(pcs->dev,
+				"Adapter: Link Partner is Up - 1000/Full\n");
+		else if (speed == TSE_PCS_PARTNER_SPEED_10 &&
+			 duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
+			dev_err(pcs->dev,
+				"Adapter does not support Half Duplex\n");
+		else if (speed == TSE_PCS_PARTNER_SPEED_100 &&
+			 duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
+			dev_err(pcs->dev,
+				"Adapter does not support Half Duplex\n");
+		else if (speed == TSE_PCS_PARTNER_SPEED_1000 &&
+			 duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
+			dev_err(pcs->dev,
+				"Adapter does not support Half Duplex\n");
+		else
+			dev_err(pcs->dev,
+				"Adapter: Invalid Partner Speed and Duplex\n");
+
+		config_tx_buffer(SGMII_ADAPTER_ENABLE, sgmii_adapter_base);
+	} else {
+		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
+		val |= TSE_PCS_CONTROL_RESTART_AN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
+
+		tse_pcs_reset(tse_pcs_base, pcs);
+		mod_timer(&pcs->an_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_TIMER));
+	}
+}
+
+void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
+			   unsigned int speed)
+{
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+	u32 val;
+
+	config_tx_buffer(SGMII_ADAPTER_DISABLE, sgmii_adapter_base);
+
+	if (phy_dev->autoneg == AUTONEG_ENABLE) {
+		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
+		val |= TSE_PCS_CONTROL_AN_EN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
+
+		val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
+		val |= TSE_PCS_USE_SGMII_AN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
+
+		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
+		val |= TSE_PCS_CONTROL_RESTART_AN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
+
+		tse_pcs_reset(tse_pcs_base, pcs);
+
+		setup_timer(&pcs->an_timer,
+			    auto_nego_timer_callback,
+			    (unsigned long)pcs);
+		mod_timer(&pcs->an_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_TIMER));
+	} else if (phy_dev->autoneg == AUTONEG_DISABLE) {
+		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
+		val &= ~TSE_PCS_CONTROL_AN_EN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
+
+		val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
+		val &= ~TSE_PCS_USE_SGMII_AN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
+
+		val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
+		val &= ~TSE_PCS_SGMII_SPEED_MASK;
+
+		switch (speed) {
+		case 1000:
+			val |= TSE_PCS_SGMII_SPEED_1000;
+			break;
+		case 100:
+			val |= TSE_PCS_SGMII_SPEED_100;
+			break;
+		case 10:
+			val |= TSE_PCS_SGMII_SPEED_10;
+			break;
+		default:
+			return;
+		}
+		writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
+
+		tse_pcs_reset(tse_pcs_base, pcs);
+
+		setup_timer(&pcs->link_timer,
+			    pcs_link_timer_callback,
+					(unsigned long)pcs);
+		mod_timer(&pcs->link_timer, jiffies +
+			  msecs_to_jiffies(LINK_TIMER));
+	}
+}
diff --git a/drivers/net/ethernet/stmicro/stmmac/tse_pcs.h b/drivers/net/ethernet/stmicro/stmmac/tse_pcs.h
new file mode 100644
index 0000000..e3d4511
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/tse_pcs.h
@@ -0,0 +1,36 @@
+/* Copyright Altera Corporation (C) 2016. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, version 2,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * Author: Tien Hock Loh <thloh@altera.com>
+ */
+
+#ifndef __TSE_PCS_H__
+#define __TSE_PCS_H__
+
+#include <linux/phy.h>
+#include <linux/timer.h>
+
+struct tse_pcs {
+	struct device *dev;
+	void __iomem *tse_pcs_base;
+	void __iomem *sgmii_adapter_base;
+	struct timer_list an_timer;
+	struct timer_list link_timer;
+};
+
+void tse_pcs_init(void __iomem *base, struct tse_pcs *pcs);
+void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
+			   unsigned int speed);
+
+#endif /* __TSE_PCS_H__ */
-- 
1.7.11.GIT
