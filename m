From: <thloh@altera.com>
Subject: [PATCH v7 1/1] net: ethernet: Add TSE PCS support to dwmac-socfpga
Date: Thu, 7 Jul 2016 20:23:30 -0700
Message-ID: <1467948210-21325-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tien Hock Loh <thloh@altera.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<dinguyen@opensource.altera.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<cnphoon@altera.com>, <thloh85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:18112
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751220AbcGHGMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 02:12:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tien Hock Loh <thloh@altera.com>

This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
the dwmac is set to sgmii.

Signed-off-by: Tien Hock Loh <thloh@altera.com>
Acked-by: Rob Herring <robh@kernel.org>

---
v2:
- Refactored the TSE PCS out from the dwmac-socfpga.c file
- Added binding documentation for TSE PCS sgmii adapter
v3:
- Added missing license header for new source files
- Updated tse_pcs.h include headers
- Standardize if statements
v4:
- Reset SGMII adapter on speed change
- Do not enable SGMII adapter if speed is not supported
- On init, if PCS reset fails, do not enable adapter
v5:
- Fixed devicetree binding property name using _ instead of -
v6:
- Fixed a problem where driver build broken if driver is set as module
v7:
- Fixed code style (don't break variable declaration with empty lines)
- Removed unnecessary parenthesis
---
 .../devicetree/bindings/net/socfpga-dwmac.txt      |  19 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   3 +-
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 274 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h |  36 +++
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 140 +++++++++--
 5 files changed, 450 insertions(+), 22 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index 72d82d6..2e68a3c 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -17,9 +17,26 @@ Required properties:
 Optional properties:
 altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
 		DWMAC controller is connected emac splitter.
+phy-mode: The phy mode the ethernet operates in
+altr,sgmii-to-sgmii-converter: phandle to the TSE SGMII converter
+
+This device node has additional phandle dependency, the sgmii converter:
+
+Required properties:
+ - compatible	: Should be altr,gmii-to-sgmii-2.0
+ - reg-names	: Should be "eth_tse_control_port"
 
 Example:
 
+gmii_to_sgmii_converter: phy@0x100000240 {
+	compatible = "altr,gmii-to-sgmii-2.0";
+	reg = <0x00000001 0x00000240 0x00000008>,
+		<0x00000001 0x00000200 0x00000040>;
+	reg-names = "eth_tse_control_port";
+	clocks = <&sgmii_1_clk_0 &emac1 1 &sgmii_clk_125 &sgmii_clk_125>;
+	clock-names = "tse_pcs_ref_clk_clock_connection", "tse_rx_cdr_refclk";
+};
+
 gmac0: ethernet@ff700000 {
 	compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 	altr,sysmgr-syscon = <&sysmgr 0x60 0>;
@@ -30,4 +47,6 @@ gmac0: ethernet@ff700000 {
 	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 	clocks = <&emac_0_clk>;
 	clock-names = "stmmaceth";
+	phy-mode = "sgmii";
+	altr,gmii-to-sgmii-converter = <&gmii_to_sgmii_converter>;
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 0fb362d..44b630c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -11,11 +11,12 @@ obj-$(CONFIG_DWMAC_IPQ806X)	+= dwmac-ipq806x.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
-obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
+obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-altr-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
 obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o
+dwmac-altr-socfpga-objs := altr_tse_pcs.o dwmac-socfpga.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
new file mode 100644
index 0000000..2920e2e
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
@@ -0,0 +1,274 @@
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
+#include "altr_tse_pcs.h"
+
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII	0
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII		BIT(1)
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII		BIT(2)
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH		2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK			GENMASK(1, 0)
+
+#define TSE_PCS_CONTROL_AN_EN_MASK			BIT(12)
+#define TSE_PCS_CONTROL_REG				0x00
+#define TSE_PCS_CONTROL_RESTART_AN_MASK			BIT(9)
+#define TSE_PCS_IF_MODE_REG				0x28
+#define TSE_PCS_LINK_TIMER_0_REG			0x24
+#define TSE_PCS_LINK_TIMER_1_REG			0x26
+#define TSE_PCS_SIZE					0x40
+#define TSE_PCS_STATUS_AN_COMPLETED_MASK		BIT(5)
+#define TSE_PCS_STATUS_LINK_MASK			0x0004
+#define TSE_PCS_STATUS_REG				0x02
+#define TSE_PCS_SGMII_SPEED_1000			BIT(3)
+#define TSE_PCS_SGMII_SPEED_100				BIT(2)
+#define TSE_PCS_SGMII_SPEED_10				0x0
+#define TSE_PCS_SW_RST_MASK				0x8000
+#define TSE_PCS_PARTNER_ABILITY_REG			0x0A
+#define TSE_PCS_PARTNER_DUPLEX_FULL			0x1000
+#define TSE_PCS_PARTNER_DUPLEX_HALF			0x0000
+#define TSE_PCS_PARTNER_DUPLEX_MASK			0x1000
+#define TSE_PCS_PARTNER_SPEED_MASK			GENMASK(11, 10)
+#define TSE_PCS_PARTNER_SPEED_1000			BIT(11)
+#define TSE_PCS_PARTNER_SPEED_100			BIT(10)
+#define TSE_PCS_PARTNER_SPEED_10			0x0000
+#define TSE_PCS_PARTNER_SPEED_1000			BIT(11)
+#define TSE_PCS_PARTNER_SPEED_100			BIT(10)
+#define TSE_PCS_PARTNER_SPEED_10			0x0000
+#define TSE_PCS_SGMII_SPEED_MASK			GENMASK(3, 2)
+#define TSE_PCS_SGMII_LINK_TIMER_0			0x0D40
+#define TSE_PCS_SGMII_LINK_TIMER_1			0x0003
+#define TSE_PCS_SW_RESET_TIMEOUT			100
+#define TSE_PCS_USE_SGMII_AN_MASK			BIT(2)
+#define TSE_PCS_USE_SGMII_ENA				BIT(1)
+
+#define SGMII_ADAPTER_CTRL_REG				0x00
+#define SGMII_ADAPTER_DISABLE				0x0001
+#define SGMII_ADAPTER_ENABLE				0x0000
+
+#define AUTONEGO_LINK_TIMER				20
+
+static int tse_pcs_reset(void __iomem *base, struct tse_pcs *pcs)
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
+	if (counter >= TSE_PCS_SW_RESET_TIMEOUT) {
+		dev_err(pcs->dev, "PCS could not get out of sw reset\n");
+		return -ETIMEDOUT;
+	}
+
+	return 0;
+}
+
+int tse_pcs_init(void __iomem *base, struct tse_pcs *pcs)
+{
+	int ret = 0;
+
+	writew(TSE_PCS_USE_SGMII_ENA, base + TSE_PCS_IF_MODE_REG);
+
+	writew(TSE_PCS_SGMII_LINK_TIMER_0, base + TSE_PCS_LINK_TIMER_0_REG);
+	writew(TSE_PCS_SGMII_LINK_TIMER_1, base + TSE_PCS_LINK_TIMER_1_REG);
+
+	ret = tse_pcs_reset(base, pcs);
+	if (ret == 0)
+		writew(SGMII_ADAPTER_ENABLE,
+		       pcs->sgmii_adapter_base + SGMII_ADAPTER_CTRL_REG);
+
+	return ret;
+}
+
+static void pcs_link_timer_callback(unsigned long data)
+{
+	u16 val = 0;
+	struct tse_pcs *pcs = (struct tse_pcs *)data;
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+
+	val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
+	val &= TSE_PCS_STATUS_LINK_MASK;
+
+	if (val != 0) {
+		dev_dbg(pcs->dev, "Adapter: Link is established\n");
+		writew(SGMII_ADAPTER_ENABLE,
+		       sgmii_adapter_base + SGMII_ADAPTER_CTRL_REG);
+	} else {
+		mod_timer(&pcs->aneg_link_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
+	}
+}
+
+static void auto_nego_timer_callback(unsigned long data)
+{
+	u16 val = 0;
+	u16 speed = 0;
+	u16 duplex = 0;
+	struct tse_pcs *pcs = (struct tse_pcs *)data;
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+
+	val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
+	val &= TSE_PCS_STATUS_AN_COMPLETED_MASK;
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
+		if (duplex == TSE_PCS_PARTNER_DUPLEX_FULL &&
+		    (speed == TSE_PCS_PARTNER_SPEED_10 ||
+		     speed == TSE_PCS_PARTNER_SPEED_100 ||
+		     speed == TSE_PCS_PARTNER_SPEED_1000))
+			writew(SGMII_ADAPTER_ENABLE,
+			       sgmii_adapter_base + SGMII_ADAPTER_CTRL_REG);
+	} else {
+		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
+		val |= TSE_PCS_CONTROL_RESTART_AN_MASK;
+		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
+
+		tse_pcs_reset(tse_pcs_base, pcs);
+		mod_timer(&pcs->aneg_link_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
+	}
+}
+
+static void aneg_link_timer_callback(unsigned long data)
+{
+	struct tse_pcs *pcs = (struct tse_pcs *)data;
+
+	if (pcs->autoneg == AUTONEG_ENABLE)
+		auto_nego_timer_callback(data);
+	else if (pcs->autoneg == AUTONEG_DISABLE)
+		pcs_link_timer_callback(data);
+}
+
+void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
+			   unsigned int speed)
+{
+	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
+	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
+	u32 val;
+
+	writew(SGMII_ADAPTER_ENABLE,
+	       sgmii_adapter_base + SGMII_ADAPTER_CTRL_REG);
+
+	pcs->autoneg = phy_dev->autoneg;
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
+
+		tse_pcs_reset(tse_pcs_base, pcs);
+
+		setup_timer(&pcs->aneg_link_timer,
+			    aneg_link_timer_callback, (unsigned long)pcs);
+		mod_timer(&pcs->aneg_link_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
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
+		setup_timer(&pcs->aneg_link_timer,
+			    aneg_link_timer_callback, (unsigned long)pcs);
+		mod_timer(&pcs->aneg_link_timer, jiffies +
+			  msecs_to_jiffies(AUTONEGO_LINK_TIMER));
+	}
+}
diff --git a/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h
new file mode 100644
index 0000000..2f58824
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h
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
+	struct timer_list aneg_link_timer;
+	int autoneg;
+};
+
+int tse_pcs_init(void __iomem *base, struct tse_pcs *pcs);
+void tse_pcs_fix_mac_speed(struct tse_pcs *pcs, struct phy_device *phy_dev,
+			   unsigned int speed);
+
+#endif /* __TSE_PCS_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index f13499f..4bee2f9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -27,6 +27,11 @@
 #include "stmmac.h"
 #include "stmmac_platform.h"
 
+#include "altr_tse_pcs.h"
+
+#define SGMII_ADAPTER_CTRL_REG                          0x00
+#define SGMII_ADAPTER_DISABLE                           0x0001
+
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII 0x0
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII 0x1
 #define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
@@ -52,35 +57,46 @@ struct socfpga_dwmac {
 	struct reset_control *stmmac_rst;
 	void __iomem *splitter_base;
 	bool f2h_ptp_ref_clk;
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
+	if ((tse_pcs_base) && (sgmii_adapter_base))
+		writew(SGMII_ADAPTER_DISABLE,
+		       sgmii_adapter_base + SGMII_ADAPTER_CTRL_REG);
+
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
+	if (tse_pcs_base && sgmii_adapter_base)
+		tse_pcs_fix_mac_speed(&dwmac->pcs, phy_dev, speed);
 }
 
 static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *dev)
@@ -88,9 +104,12 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 	struct device_node *np = dev->of_node;
 	struct regmap *sys_mgr_base_addr;
 	u32 reg_offset, reg_shift;
-	int ret;
-	struct device_node *np_splitter;
+	int ret, index;
+	struct device_node *np_splitter = NULL;
+	struct device_node *np_sgmii_adapter = NULL;
 	struct resource res_splitter;
+	struct resource res_tse_pcs;
+	struct resource res_sgmii_adapter;
 
 	dwmac->interface = of_get_phy_mode(np);
 
@@ -128,6 +147,77 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
 		}
 	}
 
+	np_sgmii_adapter = of_parse_phandle(np,
+					    "altr,gmii-to-sgmii-converter", 0);
+	if (np_sgmii_adapter) {
+		index = of_property_match_string(np_sgmii_adapter, "reg-names",
+						 "hps_emac_interface_splitter_avalon_slave");
+
+		if (index >= 0) {
+			if (of_address_to_resource(np_sgmii_adapter, index,
+						   &res_splitter)) {
+				dev_err(dev,
+					"%s: ERROR: missing emac splitter address\n",
+					__func__);
+				return -EINVAL;
+			}
+
+			dwmac->splitter_base =
+			    devm_ioremap_resource(dev, &res_splitter);
+
+			if (IS_ERR(dwmac->splitter_base)) {
+				dev_err(dev,
+					"%s: ERROR: failed mapping emac splitter\n",
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
+			    devm_ioremap_resource(dev, &res_sgmii_adapter);
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
+			dwmac->pcs.tse_pcs_base =
+			    devm_ioremap_resource(dev, &res_tse_pcs);
+
+			if (IS_ERR(dwmac->pcs.tse_pcs_base)) {
+				dev_err(dev,
+					"%s: ERROR: failed mapping tse control port\n",
+					__func__);
+				return PTR_ERR(dwmac->pcs.sgmii_adapter_base);
+			}
+		}
+	}
 	dwmac->reg_offset = reg_offset;
 	dwmac->reg_shift = reg_shift;
 	dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
@@ -151,6 +241,7 @@ static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
 		break;
 	case PHY_INTERFACE_MODE_MII:
 	case PHY_INTERFACE_MODE_GMII:
+	case PHY_INTERFACE_MODE_SGMII:
 		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
 		break;
 	default:
@@ -191,6 +282,12 @@ static int socfpga_dwmac_set_phy_mode(struct socfpga_dwmac *dwmac)
 	 */
 	if (dwmac->stmmac_rst)
 		reset_control_deassert(dwmac->stmmac_rst);
+	if (phymode == PHY_INTERFACE_MODE_SGMII) {
+		if (tse_pcs_init(dwmac->pcs.tse_pcs_base, &dwmac->pcs) != 0) {
+			dev_err(dwmac->dev, "Unable to initialize TSE PCS");
+			return -EINVAL;
+		}
+	}
 
 	return 0;
 }
@@ -225,6 +322,7 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+
 	if (!ret) {
 		struct net_device *ndev = platform_get_drvdata(pdev);
 		struct stmmac_priv *stpriv = netdev_priv(ndev);
-- 
1.7.11.GIT
