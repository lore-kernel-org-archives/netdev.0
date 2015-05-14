From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 08/11] stmmac: convert dwmac-socfpga to platform driver
Date: Thu, 14 May 2015 12:11:03 +0200
Message-ID: <1431598266-25736-9-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com,
	dinguyen@opensource.altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:35289 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932490AbbENKLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:49 -0400
Received: by labbd9 with SMTP id bd9so60510589lab.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:47 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig         | 12 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile        |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 21 ++++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c   |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h   |  1 -
 5 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index cb984606a819..f103e57e3ac0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -66,6 +66,18 @@ config DWMAC_ROCKCHIP
 	  This selects the Rockchip RK3288 SoC glue layer support for
 	  the stmmac device driver.
 
+config DWMAC_SOCFPGA
+	tristate "SOCFPGA dwmac support"
+	default ARCH_SOCFPGA
+	depends on OF
+	select MFD_SYSCON
+	help
+	  Support for ethernet controller on Altera SOCFPGA
+
+	  This selects the Altera SOCFPGA SoC glue layer support
+	  for the stmmac device driver. This driver is used for
+	  arria5 and cyclone5 FPGA SoCs.
+
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index e67dea423324..690741d6fc10 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -9,9 +9,10 @@ obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
+obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-sunxi.o \
-		       dwmac-sti.o dwmac-socfpga.o
+		       dwmac-sti.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 5a36bd2c7837..8141c5b844ae 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -257,9 +257,28 @@ static int socfpga_dwmac_init(struct platform_device *pdev, void *priv)
 	return ret;
 }
 
-const struct stmmac_of_data socfpga_gmac_data = {
+static const struct stmmac_of_data socfpga_gmac_data = {
 	.setup = socfpga_dwmac_probe,
 	.init = socfpga_dwmac_init,
 	.exit = socfpga_dwmac_exit,
 	.fix_mac_speed = socfpga_dwmac_fix_mac_speed,
 };
+
+static const struct of_device_id socfpga_dwmac_match[] = {
+	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, socfpga_dwmac_match);
+
+static struct platform_driver socfpga_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "socfpga-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = socfpga_dwmac_match,
+	},
+};
+module_platform_driver(socfpga_dwmac_driver);
+
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 674f7bd1641a..4553b50833ea 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -39,7 +39,6 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
 	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
-	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index fff2a885ffd8..3c8d7088361f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -26,6 +26,5 @@ extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
 extern const struct stmmac_of_data stid127_dwmac_data;
-extern const struct stmmac_of_data socfpga_gmac_data;
 
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
1.8.0
