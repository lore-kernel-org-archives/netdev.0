From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 04/11] stmmac: add a generic dwmac driver
Date: Thu, 14 May 2015 12:10:59 +0200
Message-ID: <1431598266-25736-5-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:33895 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932836AbbENKLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:45 -0400
Received: by laat2 with SMTP id t2so60491310laa.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:43 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a new driver around the generic device tree match strings
in the stmmac platform code. This driver is intended to be used
by all platforms that doesn't require any platform specific code
to function or is using platform data.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 +++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  4 ++-
 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 39 ++++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  5 ---
 4 files changed, 54 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 7d3af190be55..d4ed2ac3829b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -26,6 +26,18 @@ config STMMAC_PLATFORM
 
 	  If unsure, say N.
 
+if STMMAC_PLATFORM
+
+config DWMAC_GENERIC
+	tristate "Generic driver for DWMAC"
+	default STMMAC_PLATFORM
+	---help---
+	  Generic DWMAC driver for platforms that don't require any
+	  platform specific code to function or is using platform
+	  data for setup.
+
+endif
+
 config STMMAC_PCI
 	tristate "STMMAC PCI bus support"
 	depends on STMMAC_ETH && PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 5c165d8d7004..89a353450182 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -4,7 +4,9 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
 	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o $(stmmac-y)
 
-obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
+# Ordering matters. Generic driver must be last.
+obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
+obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
 		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
 		       dwmac-lpc18xx.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
new file mode 100644
index 000000000000..fb9623744e41
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -0,0 +1,39 @@
+/*
+ * Generic DWMAC platform driver
+ *
+ * Copyright (C) 2015 Joachim Eastwood <manabian@gmail.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/platform_device.h>
+
+#include "stmmac_platform.h"
+
+static const struct of_device_id dwmac_generic_match[] = {
+	{ .compatible = "st,spear600-gmac"},
+	{ .compatible = "snps,dwmac-3.610"},
+	{ .compatible = "snps,dwmac-3.70a"},
+	{ .compatible = "snps,dwmac-3.710"},
+	{ .compatible = "snps,dwmac"},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, dwmac_generic_match);
+
+static struct platform_driver dwmac_generic_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "dwmac-generic",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = of_match_ptr(dwmac_generic_match),
+	},
+};
+module_platform_driver(dwmac_generic_driver);
+
+MODULE_DESCRIPTION("Generic dwmac driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 0d1f1ec96bc0..1777e7124d3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -43,11 +43,6 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
 	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
-	{ .compatible = "st,spear600-gmac"},
-	{ .compatible = "snps,dwmac-3.610"},
-	{ .compatible = "snps,dwmac-3.70a"},
-	{ .compatible = "snps,dwmac-3.710"},
-	{ .compatible = "snps,dwmac"},
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
-- 
1.8.0
