From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 1/2] stmac: add dwmac glue for NXP 18xx/43xx family
Date: Sat,  2 May 2015 18:40:41 +0200
Message-ID: <1430584842-23408-2-git-send-email-manabian@gmail.com>
References: <1430584842-23408-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35265 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbEBQls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 12:41:48 -0400
Received: by labbd9 with SMTP id bd9so80829073lab.2
        for <netdev@vger.kernel.org>; Sat, 02 May 2015 09:41:46 -0700 (PDT)
In-Reply-To: <1430584842-23408-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using the dwmac on NXP LPC18xx and
LPC43xx devices.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 +-
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 76 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 +
 4 files changed, 80 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 73c2715a27f3..5c165d8d7004 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -6,7 +6,8 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 
 obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
-		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o
+		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
+		       dwmac-lpc18xx.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
new file mode 100644
index 000000000000..f59c9006dbdd
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -0,0 +1,76 @@
+/*
+ * STMAC glue for NXP LPC18xx/LPC43xx Ethernet
+ *
+ * Copyright (C) 2015 Joachim Eastwood <manabian@gmail.com>
+ *
+ * Based on dwmac-sunxi.c, Copyright (C) 2013 Chen-Yu Tsai
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/mfd/syscon.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/regmap.h>
+#include <linux/stmmac.h>
+
+/* Register defines for CREG syscon */
+#define LPC18XX_CREG_CREG6			0x12c
+# define LPC18XX_CREG_CREG6_ETHMODE_MASK	0x7
+# define LPC18XX_CREG_CREG6_ETHMODE_MII		0x0
+# define LPC18XX_CREG_CREG6_ETHMODE_RMII	0x4
+
+struct lpc18xx_dwmac_priv_data {
+	struct regmap *reg;
+	int interface;
+};
+
+static void *lpc18xx_dwmac_setup(struct platform_device *pdev)
+{
+	struct lpc18xx_dwmac_priv_data *dwmac;
+
+	dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
+	if (!dwmac)
+		return ERR_PTR(-ENOMEM);
+
+	dwmac->interface = of_get_phy_mode(pdev->dev.of_node);
+	if (dwmac->interface < 0)
+		return ERR_PTR(dwmac->interface);
+
+	dwmac->reg = syscon_regmap_lookup_by_compatible("nxp,lpc1850-creg");
+	if (IS_ERR(dwmac->reg)) {
+		dev_err(&pdev->dev, "Syscon lookup failed\n");
+		return dwmac->reg;
+	}
+
+	return dwmac;
+}
+
+static int lpc18xx_dwmac_init(struct platform_device *pdev, void *priv)
+{
+	struct lpc18xx_dwmac_priv_data *dwmac = priv;
+	u8 ethmode;
+
+	if (dwmac->interface == PHY_INTERFACE_MODE_MII) {
+		ethmode = LPC18XX_CREG_CREG6_ETHMODE_MII;
+	} else if (dwmac->interface == PHY_INTERFACE_MODE_RMII) {
+		ethmode = LPC18XX_CREG_CREG6_ETHMODE_RMII;
+	} else {
+		dev_err(&pdev->dev, "Only MII and RMII mode supported\n");
+		return -EINVAL;
+	}
+
+	regmap_update_bits(dwmac->reg, LPC18XX_CREG_CREG6,
+			   LPC18XX_CREG_CREG6_ETHMODE_MASK, ethmode);
+
+	return 0;
+}
+
+const struct stmmac_of_data lpc18xx_dwmac_data = {
+	.has_gmac = 1,
+	.setup = lpc18xx_dwmac_setup,
+	.init = lpc18xx_dwmac_init,
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 705bbdf93940..1e7f70e1ff63 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -36,6 +36,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
 	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
+	{ .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data},
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 093eb99e5ffd..59fe8fb46a48 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -19,6 +19,7 @@
 #ifndef __STMMAC_PLATFORM_H__
 #define __STMMAC_PLATFORM_H__
 
+extern const struct stmmac_of_data lpc18xx_dwmac_data;
 extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
-- 
1.8.0
