From: <dinguyen@altera.com>
Subject: [PATCH] net: stmmac: Add Altera's SOCFPGA extensions for GMAC
Date: Wed, 5 Feb 2014 18:35:15 -0600
Message-ID: <1391646915-22045-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, Dinh Nguyen <dinguyen@altera.com>,
	"Giuseppe Cavallaro" <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0108.outbound.protection.outlook.com ([157.56.110.108]:36529
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932133AbaBFBL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 20:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

The GMAC controller on Altera's SOCFPGA requires setting the phy mode
in a register that exists in the System Manager. This patch sets those
register through the syscon interface.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>
---
 arch/arm/boot/dts/socfpga.dtsi                     |    6 +-
 arch/arm/boot/dts/socfpga_cyclone5.dtsi            |    6 --
 arch/arm/boot/dts/socfpga_cyclone5_socdk.dts       |   18 ++++
 arch/arm/boot/dts/socfpga_cyclone5_sockit.dts      |   13 +++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |    7 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  104 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    4 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    1 +
 9 files changed, 151 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c

diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 8c4adb7..895257d 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -442,7 +442,7 @@
 				};
 			};
 
-		gmac0: ethernet@ff700000 {
+		gmac0: gmac0@ff700000 {
 			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			reg = <0xff700000 0x2000>;
 			interrupts = <0 115 4>;
@@ -453,7 +453,7 @@
 			status = "disabled";
 		};
 
-		gmac1: ethernet@ff702000 {
+		gmac1: gmac1@ff702000 {
 			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
 			reg = <0xff702000 0x2000>;
 			interrupts = <0 120 4>;
@@ -534,7 +534,7 @@
 		};
 
 		rstmgr@ffd05000 {
-			compatible = "altr,rst-mgr";
+			compatible = "altr,rst-mgr", "syscon";
 			reg = <0xffd05000 0x1000>;
 		};
 
diff --git a/arch/arm/boot/dts/socfpga_cyclone5.dtsi b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
index ca41b0e..454148d 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5.dtsi
+++ b/arch/arm/boot/dts/socfpga_cyclone5.dtsi
@@ -39,12 +39,6 @@
 			};
 		};
 
-		ethernet@ff702000 {
-			phy-mode = "rgmii";
-			phy-addr = <0xffffffff>; /* probe for phy addr */
-			status = "okay";
-		};
-
 		timer0@ffc08000 {
 			clock-frequency = <100000000>;
 		};
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
index 2ee52ab..60d95b9 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socdk.dts
@@ -38,3 +38,21 @@
 		ethernet0 = &gmac1;
 	};
 };
+
+&gmac1 {
+	phy-mode = "rgmii";
+	snps,phy-addr = <0xffffffff>; /* probe for phy addr */
+
+	rxd0-skew-ps = <0>;
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <2600>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <2000>;
+
+	status = "okay";
+};
+
diff --git a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
index 50b99a2..21e08d1 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_sockit.dts
@@ -33,5 +33,18 @@
 };
 
 &gmac1 {
+	phy-mode = "rgmii";
+	snps,phy-addr = <0xffffffff>; /* probe for phy addr */
+
+	rxd0-skew-ps = <0>;
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <2600>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <2000>;
+
 	status = "okay";
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index e2f202e..6b70706 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -26,6 +26,13 @@ config STMMAC_PLATFORM
 
 	  If unsure, say N.
 
+config DWMAC_SOCFPGA
+	bool "Altera SOCFPGA GMAC support"
+	depends on STMMAC_PLATFORM && ARCH_SOCFPGA
+	default y
+	---help---
+	  Support for Altera's SOCFPGA GMAC ethernet controller.
+
 config DWMAC_SUNXI
 	bool "Allwinner GMAC support"
 	depends on STMMAC_PLATFORM && ARCH_SUNXI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index ecadece..e380ba0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
+stmmac-$(CONFIG_DWMAC_SOCFPGA) += dwmac-socfpga.o
 stmmac-$(CONFIG_DWMAC_SUNXI) += dwmac-sunxi.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
new file mode 100644
index 0000000..13fa90c
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -0,0 +1,104 @@
+/*  Copyright (C) 2014 Altera Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/clk.h>
+#include <linux/mfd/syscon.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/regmap.h>
+#include <linux/stmmac.h>
+
+/* Peripheral Module Reset Register bits */
+#define SOCFPGA_RSTMGR_MODPERRST        0x14
+#define RSTMGR_PERMODRST_EMAC0  0x1
+#define RSTMGR_PERMODRST_EMAC1  0x2
+
+#define SYSMGR_EMACGRP_CTRL_OFFSET 0x60
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII 0x0
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII 0x1
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RMII 0x2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH 2
+#define SYSMGR_EMACGRP_CTRL_PHYSEL_MASK 0x00000003
+
+#define streq(a, b) (strcmp((a), (b)) == 0)
+
+static int socfpga_gmac_init(struct platform_device *pdev, void *priv)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct regmap *sys_mgr_base_addr;
+	struct regmap *rst_mgr_base_addr;
+	int phymode;
+	u32 ctrl, val, shift = 0;
+	u32 rstmask = 0;
+
+	if (of_machine_is_compatible("altr,socfpga-vt"))
+		return 0;
+
+	phymode = of_get_phy_mode(pdev->dev.of_node);
+
+	switch (phymode) {
+	case PHY_INTERFACE_MODE_RGMII:
+		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_RGMII;
+		break;
+	case PHY_INTERFACE_MODE_MII:
+	case PHY_INTERFACE_MODE_GMII:
+		val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
+		break;
+	default:
+		dev_err(&pdev->dev, "bad phy mode %d\n", phymode);
+		return -EINVAL;
+	}
+
+	sys_mgr_base_addr = syscon_regmap_lookup_by_compatible("altr,sys-mgr");
+	if (IS_ERR(sys_mgr_base_addr)) {
+		dev_err(&pdev->dev, "failed to find altr,sys-mgr regmap!\n");
+		return -EINVAL;
+	}
+
+	rst_mgr_base_addr = syscon_regmap_lookup_by_compatible("altr,rst-mgr");
+	if (IS_ERR(rst_mgr_base_addr)) {
+		dev_err(&pdev->dev, "failed to find altr,rst-mgr regmap!\n");
+		return -EINVAL;
+	}
+
+	if (streq(np->name, "gmac0"))
+		rstmask = RSTMGR_PERMODRST_EMAC0;
+	else if (streq(np->name, "gmac1")) {
+		shift = SYSMGR_EMACGRP_CTRL_PHYSEL_WIDTH;
+		rstmask = RSTMGR_PERMODRST_EMAC1;
+	} else {
+		dev_err(&pdev->dev, "Not a valid GMAC!\n");
+		return -EINVAL;
+	}
+
+	regmap_read(sys_mgr_base_addr, SYSMGR_EMACGRP_CTRL_OFFSET, &ctrl);
+	ctrl &= ~(SYSMGR_EMACGRP_CTRL_PHYSEL_MASK << shift);
+	ctrl |= (val << shift);
+
+	regmap_write(sys_mgr_base_addr, SYSMGR_EMACGRP_CTRL_OFFSET, ctrl);
+
+	/* Bring the appropriate GMAC out of reset */
+	regmap_read(rst_mgr_base_addr, SOCFPGA_RSTMGR_MODPERRST, &ctrl);
+	ctrl &= ~(rstmask);
+	regmap_write(rst_mgr_base_addr, SOCFPGA_RSTMGR_MODPERRST, ctrl);
+
+	return 0;
+}
+
+const struct stmmac_of_data socfpga_gmac_data = {
+	.init = socfpga_gmac_init,
+};
+
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index d9af26e..555513d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -133,6 +133,10 @@ bool stmmac_eee_init(struct stmmac_priv *priv);
 #ifdef CONFIG_DWMAC_SUNXI
 extern const struct stmmac_of_data sun7i_gmac_data;
 #endif
+#ifdef CONFIG_DWMAC_SOCFPGA
+extern const struct stmmac_of_data socfpga_gmac_data;
+#endif
+
 extern struct platform_driver stmmac_pltfr_driver;
 static inline int stmmac_register_platform(void)
 {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 5884a7d..001f419 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -33,6 +33,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
 #ifdef CONFIG_DWMAC_SUNXI
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 #endif
+	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data},
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
 	{ .compatible = "snps,dwmac-3.610"},
-- 
1.7.9.5
