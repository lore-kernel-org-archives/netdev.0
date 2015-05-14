From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 10/11] stmmac: convert dwmac-sunxi to platform driver
Date: Thu, 14 May 2015 12:11:05 +0200
Message-ID: <1431598266-25736-11-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com, wens@csie.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:35336 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932836AbbENKLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:52 -0400
Received: by labbd9 with SMTP id bd9so60511770lab.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:50 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 10 +++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 25 +++++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  2 --
 5 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index f5b9f051337d..731e0453a7d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -90,6 +90,16 @@ config DWMAC_STI
 	  device driver. This driver is used on for the STi series
 	  SOCs GMAC ethernet controller.
 
+config DWMAC_SUNXI
+	tristate "Allwinner GMAC support"
+	default ARCH_SUNXI
+	depends on OF
+	---help---
+	  Support for Allwinner A20/A31 GMAC ethernet controllers.
+
+	  This selects Allwinner SoC glue layer support for the
+	  stmmac device driver. This driver is used for A20/A31
+	  GMAC ethernet controller.
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index f8e5ddba7fd2..92e714a48367 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -11,8 +11,9 @@ obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
 obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_SOCFPGA)	+= dwmac-socfpga.o
 obj-$(CONFIG_DWMAC_STI)		+= dwmac-sti.o
+obj-$(CONFIG_DWMAC_SUNXI)	+= dwmac-sunxi.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
-stmmac-platform-objs:= stmmac_platform.o dwmac-sunxi.o \
+stmmac-platform-objs:= stmmac_platform.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
index c5ea9ab75b03..15048ca39759 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c
@@ -18,7 +18,9 @@
 
 #include <linux/stmmac.h>
 #include <linux/clk.h>
+#include <linux/module.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
 #include <linux/of_net.h>
 #include <linux/regulator/consumer.h>
 
@@ -132,7 +134,7 @@ static void sun7i_fix_speed(void *priv, unsigned int speed)
 
 /* of_data specifying hardware features and callbacks.
  * hardware features were copied from Allwinner drivers. */
-const struct stmmac_of_data sun7i_gmac_data = {
+static const struct stmmac_of_data sun7i_gmac_data = {
 	.has_gmac = 1,
 	.tx_coe = 1,
 	.fix_mac_speed = sun7i_fix_speed,
@@ -140,3 +142,24 @@ const struct stmmac_of_data sun7i_gmac_data = {
 	.init = sun7i_gmac_init,
 	.exit = sun7i_gmac_exit,
 };
+
+static const struct of_device_id sun7i_dwmac_match[] = {
+	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, sun7i_dwmac_match);
+
+static struct platform_driver sun7i_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "sun7i-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = sun7i_dwmac_match,
+	},
+};
+module_platform_driver(sun7i_dwmac_driver);
+
+MODULE_AUTHOR("Chen-Yu Tsai <wens@csie.org>");
+MODULE_DESCRIPTION("Allwinner sunxi DWMAC specific glue layer");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 21a3a2c05740..e3a3c2bff86e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -34,7 +34,6 @@
 
 static const struct of_device_id stmmac_dt_ids[] = {
 	/* SoC specific glue layers should come before generic bindings */
-	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 7eb2fa8d97f3..71da86d7bd00 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -23,6 +23,4 @@ int stmmac_pltfr_probe(struct platform_device *pdev);
 int stmmac_pltfr_remove(struct platform_device *pdev);
 extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
 
-extern const struct stmmac_of_data sun7i_gmac_data;
-
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
1.8.0
