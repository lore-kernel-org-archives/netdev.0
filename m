From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 2/8] davinci: add mdio platform devices
Date: Tue,  3 Aug 2010 09:31:47 -0400
Message-ID: <1280842313-3743-3-git-send-email-cyril@ti.com>
References: <1280842313-3743-1-git-send-email-cyril@ti.com>
Cc: nsekhar@ti.com, srk@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:54307 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755652Ab0HCNcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 09:32:09 -0400
In-Reply-To: <1280842313-3743-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds mdio platform devices on SoCs that have the necessary
hardware.  Clock lookup entries (aliases) have also been added, so that the
MDIO and EMAC drivers can independently enable/disable a shared underlying
clock.  Further, the EMAC MMR region has been split down into separate MDIO
and EMAC regions.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 arch/arm/mach-davinci/devices-da8xx.c       |   29 +++++++++++++++++++++++++-
 arch/arm/mach-davinci/dm365.c               |   22 +++++++++++++++++++-
 arch/arm/mach-davinci/dm644x.c              |   22 +++++++++++++++++++-
 arch/arm/mach-davinci/dm646x.c              |   22 +++++++++++++++++++-
 arch/arm/mach-davinci/include/mach/dm365.h  |    1 +
 arch/arm/mach-davinci/include/mach/dm644x.h |    1 +
 arch/arm/mach-davinci/include/mach/dm646x.h |    1 +
 7 files changed, 93 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-davinci/devices-da8xx.c b/arch/arm/mach-davinci/devices-da8xx.c
index 8cda729..c673e2a 100644
--- a/arch/arm/mach-davinci/devices-da8xx.c
+++ b/arch/arm/mach-davinci/devices-da8xx.c
@@ -341,7 +341,7 @@ int __init da8xx_register_watchdog(void)
 static struct resource da8xx_emac_resources[] = {
 	{
 		.start	= DA8XX_EMAC_CPPI_PORT_BASE,
-		.end	= DA8XX_EMAC_CPPI_PORT_BASE + 0x5000 - 1,
+		.end	= DA8XX_EMAC_CPPI_PORT_BASE + SZ_16K - 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	{
@@ -385,9 +385,34 @@ static struct platform_device da8xx_emac_device = {
 	.resource	= da8xx_emac_resources,
 };
 
+static struct resource da8xx_mdio_resources[] = {
+	{
+		.start	= DA8XX_EMAC_MDIO_BASE,
+		.end	= DA8XX_EMAC_MDIO_BASE + SZ_4K - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device da8xx_mdio_device = {
+	.name		= "davinci_mdio",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(da8xx_mdio_resources),
+	.resource	= da8xx_mdio_resources,
+};
+
 int __init da8xx_register_emac(void)
 {
-	return platform_device_register(&da8xx_emac_device);
+	int ret;
+
+	ret = platform_device_register(&da8xx_mdio_device);
+	if (ret < 0)
+		return ret;
+	ret = platform_device_register(&da8xx_emac_device);
+	if (ret < 0)
+		return ret;
+	ret = clk_add_alias(NULL, dev_name(&da8xx_mdio_device.dev),
+			    NULL, &da8xx_emac_device.dev);
+	return ret;
 }
 
 static struct resource da830_mcasp1_resources[] = {
diff --git a/arch/arm/mach-davinci/dm365.c b/arch/arm/mach-davinci/dm365.c
index 652f4b6..4a58f03 100644
--- a/arch/arm/mach-davinci/dm365.c
+++ b/arch/arm/mach-davinci/dm365.c
@@ -699,7 +699,7 @@ static struct emac_platform_data dm365_emac_pdata = {
 static struct resource dm365_emac_resources[] = {
 	{
 		.start	= DM365_EMAC_BASE,
-		.end	= DM365_EMAC_BASE + 0x47ff,
+		.end	= DM365_EMAC_BASE + SZ_16K - 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	{
@@ -734,6 +734,21 @@ static struct platform_device dm365_emac_device = {
 	.resource	= dm365_emac_resources,
 };
 
+static struct resource dm365_mdio_resources[] = {
+	{
+		.start	= DM365_EMAC_MDIO_BASE,
+		.end	= DM365_EMAC_MDIO_BASE + SZ_4K - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device dm365_mdio_device = {
+	.name		= "davinci_mdio",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(dm365_mdio_resources),
+	.resource	= dm365_mdio_resources,
+};
+
 static u8 dm365_default_priorities[DAVINCI_N_AINTC_IRQ] = {
 	[IRQ_VDINT0]			= 2,
 	[IRQ_VDINT1]			= 6,
@@ -1218,7 +1233,12 @@ static int __init dm365_init_devices(void)
 
 	davinci_cfg_reg(DM365_INT_EDMA_CC);
 	platform_device_register(&dm365_edma_device);
+
+	platform_device_register(&dm365_mdio_device);
 	platform_device_register(&dm365_emac_device);
+	clk_add_alias(NULL, dev_name(&dm365_mdio_device.dev),
+		      NULL, &dm365_emac_device.dev);
+
 	/* Add isif clock alias */
 	clk_add_alias("master", dm365_isif_dev.name, "vpss_master", NULL);
 	platform_device_register(&dm365_vpss_device);
diff --git a/arch/arm/mach-davinci/dm644x.c b/arch/arm/mach-davinci/dm644x.c
index 7ad1520..2673723 100644
--- a/arch/arm/mach-davinci/dm644x.c
+++ b/arch/arm/mach-davinci/dm644x.c
@@ -330,7 +330,7 @@ static struct emac_platform_data dm644x_emac_pdata = {
 static struct resource dm644x_emac_resources[] = {
 	{
 		.start	= DM644X_EMAC_BASE,
-		.end	= DM644X_EMAC_BASE + 0x47ff,
+		.end	= DM644X_EMAC_BASE + SZ_16K - 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	{
@@ -350,6 +350,21 @@ static struct platform_device dm644x_emac_device = {
        .resource	= dm644x_emac_resources,
 };
 
+static struct resource dm644x_mdio_resources[] = {
+	{
+		.start	= DM644X_EMAC_MDIO_BASE,
+		.end	= DM644X_EMAC_MDIO_BASE + SZ_4K - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device dm644x_mdio_device = {
+       .name		= "davinci_mdio",
+       .id		= 0,
+       .num_resources	= ARRAY_SIZE(dm644x_mdio_resources),
+       .resource	= dm644x_mdio_resources,
+};
+
 /*
  * Device specific mux setup
  *
@@ -775,7 +790,12 @@ static int __init dm644x_init_devices(void)
 	clk_add_alias("master", dm644x_ccdc_dev.name, "vpss_master", NULL);
 	clk_add_alias("slave", dm644x_ccdc_dev.name, "vpss_slave", NULL);
 	platform_device_register(&dm644x_edma_device);
+
+	platform_device_register(&dm644x_mdio_device);
 	platform_device_register(&dm644x_emac_device);
+	clk_add_alias(NULL, dev_name(&dm644x_mdio_device.dev),
+		      NULL, &dm644x_emac_device.dev);
+
 	platform_device_register(&dm644x_vpss_device);
 	platform_device_register(&dm644x_ccdc_dev);
 	platform_device_register(&vpfe_capture_dev);
diff --git a/arch/arm/mach-davinci/dm646x.c b/arch/arm/mach-davinci/dm646x.c
index 9404565..4e90511 100644
--- a/arch/arm/mach-davinci/dm646x.c
+++ b/arch/arm/mach-davinci/dm646x.c
@@ -366,7 +366,7 @@ static struct emac_platform_data dm646x_emac_pdata = {
 static struct resource dm646x_emac_resources[] = {
 	{
 		.start	= DM646X_EMAC_BASE,
-		.end	= DM646X_EMAC_BASE + 0x47ff,
+		.end	= DM646X_EMAC_BASE + SZ_16K - 1,
 		.flags	= IORESOURCE_MEM,
 	},
 	{
@@ -401,6 +401,21 @@ static struct platform_device dm646x_emac_device = {
 	.resource	= dm646x_emac_resources,
 };
 
+static struct resource dm646x_mdio_resources[] = {
+	{
+		.start	= DM646X_EMAC_MDIO_BASE,
+		.end	= DM646X_EMAC_MDIO_BASE + SZ_4K - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+};
+
+static struct platform_device dm646x_mdio_device = {
+	.name		= "davinci_mdio",
+	.id		= 0,
+	.num_resources	= ARRAY_SIZE(dm646x_mdio_resources),
+	.resource	= dm646x_mdio_resources,
+};
+
 /*
  * Device specific mux setup
  *
@@ -889,7 +904,12 @@ static int __init dm646x_init_devices(void)
 		return 0;
 
 	platform_device_register(&dm646x_edma_device);
+
+	platform_device_register(&dm646x_mdio_device);
 	platform_device_register(&dm646x_emac_device);
+	clk_add_alias(NULL, dev_name(&dm646x_mdio_device.dev),
+		      NULL, &dm646x_emac_device.dev);
+
 	return 0;
 }
 postcore_initcall(dm646x_init_devices);
diff --git a/arch/arm/mach-davinci/include/mach/dm365.h b/arch/arm/mach-davinci/include/mach/dm365.h
index ea5df3b..dbb5052 100644
--- a/arch/arm/mach-davinci/include/mach/dm365.h
+++ b/arch/arm/mach-davinci/include/mach/dm365.h
@@ -21,6 +21,7 @@
 #include <media/davinci/vpfe_capture.h>
 
 #define DM365_EMAC_BASE			(0x01D07000)
+#define DM365_EMAC_MDIO_BASE		(DM365_EMAC_BASE + 0x4000)
 #define DM365_EMAC_CNTRL_OFFSET		(0x0000)
 #define DM365_EMAC_CNTRL_MOD_OFFSET	(0x3000)
 #define DM365_EMAC_CNTRL_RAM_OFFSET	(0x1000)
diff --git a/arch/arm/mach-davinci/include/mach/dm644x.h b/arch/arm/mach-davinci/include/mach/dm644x.h
index 6fca568..5159117 100644
--- a/arch/arm/mach-davinci/include/mach/dm644x.h
+++ b/arch/arm/mach-davinci/include/mach/dm644x.h
@@ -28,6 +28,7 @@
 #include <media/davinci/vpfe_capture.h>
 
 #define DM644X_EMAC_BASE		(0x01C80000)
+#define DM644X_EMAC_MDIO_BASE		(DM644X_EMAC_BASE + 0x4000)
 #define DM644X_EMAC_CNTRL_OFFSET	(0x0000)
 #define DM644X_EMAC_CNTRL_MOD_OFFSET	(0x1000)
 #define DM644X_EMAC_CNTRL_RAM_OFFSET	(0x2000)
diff --git a/arch/arm/mach-davinci/include/mach/dm646x.h b/arch/arm/mach-davinci/include/mach/dm646x.h
index add6f79..fc2bdd0 100644
--- a/arch/arm/mach-davinci/include/mach/dm646x.h
+++ b/arch/arm/mach-davinci/include/mach/dm646x.h
@@ -19,6 +19,7 @@
 #include <linux/davinci_emac.h>
 
 #define DM646X_EMAC_BASE		(0x01C80000)
+#define DM646X_EMAC_MDIO_BASE		(DM646X_EMAC_BASE + 0x4000)
 #define DM646X_EMAC_CNTRL_OFFSET	(0x0000)
 #define DM646X_EMAC_CNTRL_MOD_OFFSET	(0x1000)
 #define DM646X_EMAC_CNTRL_RAM_OFFSET	(0x2000)
-- 
1.7.0.4

