From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 06/11] stmmac: convert dwmac-meson to platform driver
Date: Thu, 14 May 2015 12:11:01 +0200
Message-ID: <1431598266-25736-7-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com, b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:35242 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427AbbENKLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:47 -0400
Received: by labbd9 with SMTP id bd9so60509374lab.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:45 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 11 ++++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 24 +++++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 -
 5 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index aa03e26437e2..a5a56217a845 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -44,6 +44,17 @@ config DWMAC_LPC18XX
 	---help---
 	  Support for NXP LPC18xx/43xx DWMAC Ethernet.
 
+config DWMAC_MESON
+	tristate "Amlogic Meson dwmac support"
+	default ARCH_MESON
+	depends on OF
+	help
+	  Support for Ethernet controller on Amlogic Meson SoCs.
+
+	  This selects the Amlogic Meson SoC glue layer support for
+	  the stmmac device driver. This driver is used for Meson6 and
+	  Meson8 SoCs.
+
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 96a3abfc15bb..69cc046afd8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -7,8 +7,9 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
+obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
-stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
+stmmac-platform-objs:= stmmac_platform.o dwmac-sunxi.o \
 		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
index cca028d632f6..61a324a87d09 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
@@ -15,6 +15,7 @@
 #include <linux/ethtool.h>
 #include <linux/io.h>
 #include <linux/ioport.h>
+#include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/stmmac.h>
 
@@ -63,7 +64,28 @@ static void *meson6_dwmac_setup(struct platform_device *pdev)
 	return dwmac;
 }
 
-const struct stmmac_of_data meson6_dwmac_data = {
+static const struct stmmac_of_data meson6_dwmac_data = {
 	.setup		= meson6_dwmac_setup,
 	.fix_mac_speed	= meson6_dwmac_fix_mac_speed,
 };
+
+static const struct of_device_id meson6_dwmac_match[] = {
+	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, meson6_dwmac_match);
+
+static struct platform_driver meson6_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "meson6-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = meson6_dwmac_match,
+	},
+};
+module_platform_driver(meson6_dwmac_driver);
+
+MODULE_AUTHOR("Beniamino Galvani <b.galvani@gmail.com>");
+MODULE_DESCRIPTION("Amlogic Meson DWMAC glue layer");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 1fd65e780a05..bed31e4db7e3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -35,7 +35,6 @@
 static const struct of_device_id stmmac_dt_ids[] = {
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
-	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 23d10f6e8846..be3e137efc55 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -23,7 +23,6 @@ int stmmac_pltfr_probe(struct platform_device *pdev);
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
-extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
 extern const struct stmmac_of_data stid127_dwmac_data;
-- 
1.8.0
