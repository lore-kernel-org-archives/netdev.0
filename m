From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 01/11] stmmac: add dwmac glue for NXP 18xx/43xx family
Date: Thu, 14 May 2015 12:10:56 +0200
Message-ID: <1431598266-25736-2-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33393 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbbENKLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:41 -0400
Received: by layy10 with SMTP id y10so60495243lay.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:40 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Ethernet on NXP LPC18xx and LPC43xx using the
dwmac driver. This glue is required to setup phy interface
mode, MII or RMII, on the SoC.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 +-
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 74 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 +
 4 files changed, 78 insertions(+), 1 deletion(-)
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
index 000000000000..be02b6a1475f
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -0,0 +1,74 @@
+/*
+ * DWMAC glue for NXP LPC18xx/LPC43xx Ethernet
+ *
+ * Copyright (C) 2015 Joachim Eastwood <manabian@gmail.com>
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
index 68aec5c460db..1ac7c8a2c631 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -37,6 +37,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
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
