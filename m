From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 07/11] stmmac: convert dwmac-rk to platform driver
Date: Thu, 14 May 2015 12:11:02 +0200
Message-ID: <1431598266-25736-8-git-send-email-manabian@gmail.com>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-rockchip@lists.infradead.org
To: arnd@arndb.de, peppe.cavallaro@st.com, roger.chen@rock-chips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33962 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932858AbbENKLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 06:11:48 -0400
Received: by laat2 with SMTP id t2so60493195laa.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 03:11:46 -0700 (PDT)
In-Reply-To: <1431598266-25736-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert platform glue layer into a proper platform
driver and add it to the build system.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        | 11 +++++++++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 27 +++++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  1 -
 5 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index a5a56217a845..cb984606a819 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -55,6 +55,17 @@ config DWMAC_MESON
 	  the stmmac device driver. This driver is used for Meson6 and
 	  Meson8 SoCs.
 
+config DWMAC_ROCKCHIP
+	tristate "Rockchip dwmac support"
+	default ARCH_ROCKCHIP
+	depends on OF
+	select MFD_SYSCON
+	help
+	  Support for Ethernet controller on Rockchip RK3288 SoC.
+
+	  This selects the Rockchip RK3288 SoC glue layer support for
+	  the stmmac device driver.
+
 endif
 
 config STMMAC_PCI
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 69cc046afd8c..e67dea423324 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -8,9 +8,10 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
 obj-$(CONFIG_DWMAC_LPC18XX)	+= dwmac-lpc18xx.o
 obj-$(CONFIG_DWMAC_MESON)	+= dwmac-meson.o
+obj-$(CONFIG_DWMAC_ROCKCHIP)	+= dwmac-rk.o
 obj-$(CONFIG_DWMAC_GENERIC)	+= dwmac-generic.o
 stmmac-platform-objs:= stmmac_platform.o dwmac-sunxi.o \
-		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o		\
+		       dwmac-sti.o dwmac-socfpga.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 6249a4ec08f0..30e28f0d9a60 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -22,13 +22,17 @@
 #include <linux/phy.h>
 #include <linux/of_net.h>
 #include <linux/gpio.h>
+#include <linux/module.h>
 #include <linux/of_gpio.h>
 #include <linux/of_device.h>
+#include <linux/platform_device.h>
 #include <linux/regulator/consumer.h>
 #include <linux/delay.h>
 #include <linux/mfd/syscon.h>
 #include <linux/regmap.h>
 
+#include "stmmac_platform.h"
+
 struct rk_priv_data {
 	struct platform_device *pdev;
 	int phy_iface;
@@ -428,10 +432,31 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 		dev_err(dev, "unsupported interface %d", bsp_priv->phy_iface);
 }
 
-const struct stmmac_of_data rk3288_gmac_data = {
+static const struct stmmac_of_data rk3288_gmac_data = {
 	.has_gmac = 1,
 	.fix_mac_speed = rk_fix_speed,
 	.setup = rk_gmac_setup,
 	.init = rk_gmac_init,
 	.exit = rk_gmac_exit,
 };
+
+static const struct of_device_id rk_gmac_dwmac_match[] = {
+	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
+	{ }
+};
+MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
+
+static struct platform_driver rk_gmac_dwmac_driver = {
+	.probe  = stmmac_pltfr_probe,
+	.remove = stmmac_pltfr_remove,
+	.driver = {
+		.name           = "rk_gmac-dwmac",
+		.pm		= &stmmac_pltfr_pm_ops,
+		.of_match_table = rk_gmac_dwmac_match,
+	},
+};
+module_platform_driver(rk_gmac_dwmac_driver);
+
+MODULE_AUTHOR("Chen-Zhi (Roger Chen) <roger.chen@rock-chips.com>");
+MODULE_DESCRIPTION("Rockchip RK3288 DWMAC specific glue layer");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index bed31e4db7e3..674f7bd1641a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -34,7 +34,6 @@
 
 static const struct of_device_id stmmac_dt_ids[] = {
 	/* SoC specific glue layers should come before generic bindings */
-	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_gmac_data},
 	{ .compatible = "allwinner,sun7i-a20-gmac", .data = &sun7i_gmac_data},
 	{ .compatible = "st,stih415-dwmac", .data = &stih4xx_dwmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &stih4xx_dwmac_data},
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index be3e137efc55..fff2a885ffd8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -27,6 +27,5 @@ extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
 extern const struct stmmac_of_data stid127_dwmac_data;
 extern const struct stmmac_of_data socfpga_gmac_data;
-extern const struct stmmac_of_data rk3288_gmac_data;
 
 #endif /* __STMMAC_PLATFORM_H__ */
-- 
1.8.0
