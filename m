From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH RFC 2/2] stmac: add dwmac glue for NXP 18xx/43xx family
Date: Thu,  7 May 2015 20:19:25 +0200
Message-ID: <1431022765-30715-3-git-send-email-manabian@gmail.com>
References: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:36604 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbEGSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:19:34 -0400
Received: by lagv1 with SMTP id v1so36763418lag.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:19:33 -0700 (PDT)
In-Reply-To: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using the dwmac on NXP LPC18xx and
LPC43xx devices.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 98 ++++++++++++++++++++++
 2 files changed, 99 insertions(+)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index f35e2bcde55f..560642a44134 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -7,6 +7,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 # ordering matters; keep stmmac_platform.o at the bottom
 obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
 stmmac-platform-objs:= \
+		dwmac-lpc18xx.o		\
 		dwmac-meson.o		\
 		dwmac-rk.o		\
 		dwmac-socfpga.o		\
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
new file mode 100644
index 000000000000..ed9ec45cb5ac
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -0,0 +1,98 @@
+/*
+ * STMAC glue for NXP LPC18xx/LPC43xx Ethernet
+ *
+ * Copyright (C) 2015 Joachim Eastwood <manabian@gmail.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/mfd/syscon.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/regmap.h>
+#include <linux/stmmac.h>
+
+#include "stmmac_platform.h"
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
+		dev_err(&pdev->dev, "syscon lookup failed\n");
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
+		dev_err(&pdev->dev, "only MII and RMII mode supported\n");
+		return -EINVAL;
+	}
+
+	regmap_update_bits(dwmac->reg, LPC18XX_CREG_CREG6,
+			   LPC18XX_CREG_CREG6_ETHMODE_MASK, ethmode);
+
+	return 0;
+}
+
+static const struct stmmac_of_data lpc18xx_dwmac_data = {
+	.has_gmac = 1,
+	.setup = lpc18xx_dwmac_setup,
+	.init = lpc18xx_dwmac_init,
+};
+
+static const struct of_device_id lpc18xx_dwmac_match[] = {
+	{ .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, lpc18xx_dwmac_match);
+
+static struct platform_driver lpc18xx_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "lpc18xx-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = lpc18xx_dwmac_match,
+	},
+};
+module_platform_driver(lpc18xx_dwmac_driver);
+
+MODULE_AUTHOR("Joachim Eastwood <manabian@gmail.com>");
+MODULE_DESCRIPTION("Driver for Ethernet on LPC18xx/43xx");
+MODULE_LICENSE("GPL v2");
-- 
1.8.0
