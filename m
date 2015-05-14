From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 05/11] stmmac: convert dwmac-lpc18xx to a platform driver
Date: Thu, 14 May 2015 12:11:00 +0200
Message-ID: <1431598266-25736-6-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36640 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932846AbbENKLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:46 -0400
Received: by lagv1 with SMTP id v1so60438809lag.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:44 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  8 +++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 27 +++++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 -
 5 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index d4ed2ac3829b..aa03e26437e2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -36,6 +36,14 @@ config DWMAC_GENERIC
 	  platform specific code to function or is using platform
 	  data for setup.
 
+config DWMAC_LPC18XX
+	tristate "NXP LPC18xx/43xx DWMAC support"
+	default ARCH_LPC18XX
+	depends on OF
+	select MFD_SYSCON
+	---help---
+	  Support for NXP LPC18xx/43xx DWMAC Ethernet.
+
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 89a353450182..96a3abfc15bb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -6,10 +6,10 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
+obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
 		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
-		       dwmac-lpc18xx.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
index be02b6a1475f..cb888d3ebbdc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c
@@ -9,12 +9,16 @@
  */
 
 #include <linux/mfd/syscon.h>
+#include <linux/module.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 #include <linux/regmap.h>
 #include <linux/stmmac.h>
 
+#include "stmmac_platform.h"
+
 /* Register defines for CREG syscon */
 #define LPC18XX_CREG_CREG6			0x12c
 # define LPC18XX_CREG_CREG6_ETHMODE_MASK	0x7
@@ -67,8 +71,29 @@ static int lpc18xx_dwmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-const struct stmmac_of_data lpc18xx_dwmac_data = {
+static const struct stmmac_of_data lpc18xx_dwmac_data = {
 	.has_gmac = 1,
 	.setup = lpc18xx_dwmac_setup,
 	.init = lpc18xx_dwmac_init,
 };
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
+MODULE_DESCRIPTION("DWMAC glue for LPC18xx/43xx Ethernet");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1777e7124d3e..1fd65e780a05 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -37,7 +37,6 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
 	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
-	{ .compatible = "nxp,lpc1850-dwmac", .data = &lpc18xx_dwmac_data},
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 5be0b101bffd..23d10f6e8846 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -23,7 +23,6 @@ int stmmac_pltfr_probe(struct platform_device *pdev);
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
-extern const struct stmmac_of_data lpc18xx_dwmac_data;
 extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
-- 
1.8.0
