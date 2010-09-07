From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v3 03/10] omap: add mdio platform devices
Date: Tue,  7 Sep 2010 16:25:35 -0400
Message-ID: <1283891142-15522-4-git-send-email-cyril@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com>
Cc: davem@davemloft.net, khilman@deeprootsystems.com, tony@atomide.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1283891142-15522-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds mdio platform devices on SoCs that have the necessary
hardware.  Clock lookup entries (aliases) have also been added, so that the
MDIO and EMAC drivers can independently enable/disable a shared underlying
clock.  Further, the EMAC MMR region has been split down into separate MDIO
and EMAC regions.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/arm/mach-omap2/board-am3517evm.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-omap2/board-am3517evm.c b/arch/arm/mach-omap2/board-am3517evm.c
index 4d0f585..5dd1b73 100644
--- a/arch/arm/mach-omap2/board-am3517evm.c
+++ b/arch/arm/mach-omap2/board-am3517evm.c
@@ -18,6 +18,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/clk.h>
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
 #include <linux/i2c/pca953x.h>
@@ -41,6 +42,27 @@
 #define AM35XX_EVM_PHY_MASK		(0xF)
 #define AM35XX_EVM_MDIO_FREQUENCY	(1000000)
 
+static struct mdio_platform_data am3517_evm_mdio_pdata = {
+	.bus_freq	= AM35XX_EVM_MDIO_FREQUENCY,
+};
+
+static struct resource am3517_mdio_resources[] = {
+	{
+		.start  = AM35XX_IPSS_EMAC_BASE + AM35XX_EMAC_MDIO_OFFSET,
+		.end    = AM35XX_IPSS_EMAC_BASE + AM35XX_EMAC_MDIO_OFFSET +
+			  SZ_4K - 1,
+		.flags  = IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device am3517_mdio_device = {
+	.name		= "davinci_mdio",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(am3517_mdio_resources),
+	.resource	= am3517_mdio_resources,
+	.dev.platform_data = &am3517_evm_mdio_pdata,
+};
+
 static struct emac_platform_data am3517_evm_emac_pdata = {
 	.phy_mask	= AM35XX_EVM_PHY_MASK,
 	.mdio_max_freq	= AM35XX_EVM_MDIO_FREQUENCY,
@@ -50,7 +72,7 @@ static struct emac_platform_data am3517_evm_emac_pdata = {
 static struct resource am3517_emac_resources[] = {
 	{
 		.start  = AM35XX_IPSS_EMAC_BASE,
-		.end    = AM35XX_IPSS_EMAC_BASE + 0x3FFFF,
+		.end    = AM35XX_IPSS_EMAC_BASE + 0x2FFFF,
 		.flags  = IORESOURCE_MEM,
 	},
 	{
@@ -121,6 +143,9 @@ void am3517_evm_ethernet_init(struct emac_platform_data *pdata)
 	pdata->interrupt_disable	= am3517_disable_ethernet_int;
 	am3517_emac_device.dev.platform_data	= pdata;
 	platform_device_register(&am3517_emac_device);
+	platform_device_register(&am3517_mdio_device);
+	clk_add_alias(NULL, dev_name(&am3517_mdio_device.dev),
+		      NULL, &am3517_emac_device.dev);
 
 	regval = omap_ctrl_readl(AM35XX_CONTROL_IP_SW_RESET);
 	regval = regval & (~(AM35XX_CPGMACSS_SW_RST));
-- 
1.7.0.4

