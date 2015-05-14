From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 09/11] stmmac: convert dwmac-sti to platform driver
Date: Thu, 14 May 2015 12:11:04 +0200
Message-ID: <1431598266-25736-10-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com, srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35311 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932846AbbENKLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:50 -0400
Received: by labbd9 with SMTP id bd9so60511136lab.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:49 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 12 +++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 29 ++++++++++++++++++++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  4 ---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  2 --
 5 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index f103e57e3ac0..f5b9f051337d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -78,6 +78,18 @@ config DWMAC_SOCFPGA
 	  for the stmmac device driver. This driver is used for
 	  arria5 and cyclone5 FPGA SoCs.
 
+config DWMAC_STI
+	tristate "STi GMAC support"
+	default ARCH_STI
+	depends on OF
+	select MFD_SYSCON
+	---help---
+	  Support for ethernet controller on STi SOCs.
+
+	  This selects STi SoC glue layer support for the stmmac
+	  device driver. This driver is used on for the STi series
+	  SOCs GMAC ethernet controller.
+
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 690741d6fc10..f8e5ddba7fd2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -10,9 +10,9 @@ obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
+obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-sunxi.o \
-		       dwmac-sti.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index bb6e2dc61bec..a2e8111c5d14 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -17,6 +17,7 @@
 #include <linux/stmmac.h>
 #include <linux/phy.h>
 #include <linux/mfd/syscon.h>
+#include <linux/module.h>
 #include <linux/regmap.h>
 #include <linux/clk.h>
 #include <linux/of.h>
@@ -351,16 +352,40 @@ static void *sti_dwmac_setup(struct platform_device *pdev)
 	return dwmac;
 }
 
-const struct stmmac_of_data stih4xx_dwmac_data = {
+static const struct stmmac_of_data stih4xx_dwmac_data = {
 	.fix_mac_speed = stih4xx_fix_retime_src,
 	.setup = sti_dwmac_setup,
 	.init = stix4xx_init,
 	.exit = sti_dwmac_exit,
 };
 
-const struct stmmac_of_data stid127_dwmac_data = {
+static const struct stmmac_of_data stid127_dwmac_data = {
 	.fix_mac_speed = stid127_fix_retime_src,
 	.setup = sti_dwmac_setup,
 	.init = stid127_init,
 	.exit = sti_dwmac_exit,
 };
+
+static const struct of_device_id sti_dwmac_match[] = {
+	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
+	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
+	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
+	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, sti_dwmac_match);
+
+static struct platform_driver sti_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "sti-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = sti_dwmac_match,
+	},
+};
+module_platform_driver(sti_dwmac_driver);
+
+MODULE_AUTHOR("Srinivas Kandagatla <srinivas.kandagatla@st.com>");
+MODULE_DESCRIPTION("STMicroelectronics DWMAC Specific Glue layer");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4553b50833ea..21a3a2c05740 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -35,10 +35,6 @@
 static const struct of_device_id stmmac_dt_ids[] = {
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
-	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
-	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
-	{ .compatible = "st,stid127-dwmac", .data = &stid127_dwmac_data},
-	{ .compatible = "st,stih407-dwmac", .data = &stih4xx_dwmac_data},
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 3c8d7088361f..7eb2fa8d97f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -24,7 +24,5 @@ int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
 extern const struct stmmac_of_data sun7i_gmac_data;
-extern const struct stmmac_of_data stih4xx_dwmac_data;
-extern const struct stmmac_of_data stid127_dwmac_data;
 
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
1.8.0
