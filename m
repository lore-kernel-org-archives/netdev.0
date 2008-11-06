From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 6/6] smsc911x: convert realview platforms to use
	smsc911x
Date: Thu, 06 Nov 2008 12:58:50 +0000
Message-ID: <1225976330.16885.13.camel@pc1117.cambridge.arm.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-4-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-5-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-6-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-7-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:54535 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753430AbYKFM7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 07:59:20 -0500
In-Reply-To: <1225881342-3485-7-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-05 at 10:35 +0000, Steve Glendinning wrote:
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  arch/arm/mach-realview/realview_eb.c     |   16 +++++++++++++---
>  arch/arm/mach-realview/realview_pb1176.c |   13 ++++++++++++-
>  arch/arm/mach-realview/realview_pb11mp.c |   13 ++++++++++++-
>  3 files changed, 37 insertions(+), 5 deletions(-)

The dynamic configuration isn't correct but anyway I plan to merge
support for this chip via Russell King together with another patch that
refactored the Ethernet device registration on the RealView platform. I
copy them below for your information/acknowledgement:

-----------------------------------------------------------------------

RealView: Refactor the Ethernet device registration

From: Catalin Marinas <catalin.marinas@arm.com>

This patch moves the Ethernet device registration from individual
realview_*.c files to core.c.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm/mach-realview/core.c            |   15 +++++++++++++++
 arch/arm/mach-realview/core.h            |    1 +
 arch/arm/mach-realview/realview_eb.c     |   18 +++++-------------
 arch/arm/mach-realview/realview_pb1176.c |    9 +--------
 arch/arm/mach-realview/realview_pb11mp.c |    9 +--------
 arch/arm/mach-realview/realview_pba8.c   |    9 +--------
 6 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index 65c39a7..d80208a 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -125,6 +125,21 @@ int realview_flash_register(struct resource *res, u32 num)
 	return platform_device_register(&realview_flash_device);
 }
 
+static struct platform_device realview_eth_device = {
+	.name		= "smc911x",
+	.id		= 0,
+	.num_resources	= 2,
+};
+
+int realview_eth_register(const char *name, struct resource *res)
+{
+	if (name)
+		realview_eth_device.name = name;
+	realview_eth_device.resource = res;
+
+	return platform_device_register(&realview_eth_device);
+}
+
 static struct resource realview_i2c_resource = {
 	.start		= REALVIEW_I2C_BASE,
 	.end		= REALVIEW_I2C_BASE + SZ_4K - 1,
diff --git a/arch/arm/mach-realview/core.h b/arch/arm/mach-realview/core.h
index 3d97a4c..689c368 100644
--- a/arch/arm/mach-realview/core.h
+++ b/arch/arm/mach-realview/core.h
@@ -62,5 +62,6 @@ extern void __iomem *timer3_va_base;
 extern void realview_leds_event(led_event_t ledevt);
 extern void realview_timer_init(unsigned int timer_irq);
 extern int realview_flash_register(struct resource *res, u32 num);
+extern int realview_eth_register(const char *name, struct resource *res);
 
 #endif
diff --git a/arch/arm/mach-realview/realview_eb.c b/arch/arm/mach-realview/realview_eb.c
index 66dc256..e9b7b04 100644
--- a/arch/arm/mach-realview/realview_eb.c
+++ b/arch/arm/mach-realview/realview_eb.c
@@ -242,12 +242,6 @@ static struct resource realview_eb_eth_resources[] = {
 	},
 };
 
-static struct platform_device realview_eb_eth_device = {
-	.id		= 0,
-	.num_resources	= ARRAY_SIZE(realview_eb_eth_resources),
-	.resource	= realview_eb_eth_resources,
-};
-
 /*
  * Detect and register the correct Ethernet device. RealView/EB rev D
  * platforms use the newer SMSC LAN9118 Ethernet chip
@@ -255,21 +249,19 @@ static struct platform_device realview_eb_eth_device = {
 static int eth_device_register(void)
 {
 	void __iomem *eth_addr = ioremap(REALVIEW_EB_ETH_BASE, SZ_4K);
+	const char *name = NULL;
 	u32 idrev;
 
 	if (!eth_addr)
 		return -ENOMEM;
 
 	idrev = readl(eth_addr + 0x50);
-	if ((idrev & 0xFFFF0000) == 0x01180000)
-		/* SMSC LAN9118 chip present */
-		realview_eb_eth_device.name = "smc911x";
-	else
-		/* SMSC 91C111 chip present */
-		realview_eb_eth_device.name = "smc91x";
+	if ((idrev & 0xFFFF0000) != 0x01180000)
+		/* SMSC LAN9118 not present, use LAN91C111 instead */
+		name = "smc91x";
 
 	iounmap(eth_addr);
-	return platform_device_register(&realview_eb_eth_device);
+	return realview_eth_register(name, realview_eb_eth_resources);
 }
 
 static void __init gic_init_irq(void)
diff --git a/arch/arm/mach-realview/realview_pb1176.c b/arch/arm/mach-realview/realview_pb1176.c
index a9fac65..0388ed0 100644
--- a/arch/arm/mach-realview/realview_pb1176.c
+++ b/arch/arm/mach-realview/realview_pb1176.c
@@ -222,13 +222,6 @@ static struct resource realview_pb1176_smsc911x_resources[] = {
 	},
 };
 
-static struct platform_device realview_pb1176_smsc911x_device = {
-	.name		= "smc911x",
-	.id		= 0,
-	.num_resources	= ARRAY_SIZE(realview_pb1176_smsc911x_resources),
-	.resource	= realview_pb1176_smsc911x_resources,
-};
-
 static void __init gic_init_irq(void)
 {
 	/* ARM1176 DevChip GIC, primary */
@@ -268,7 +261,7 @@ static void __init realview_pb1176_init(void)
 	clk_register(&realview_clcd_clk);
 
 	realview_flash_register(&realview_pb1176_flash_resource, 1);
-	platform_device_register(&realview_pb1176_smsc911x_device);
+	realview_eth_register(NULL, realview_pb1176_smsc911x_resources);
 
 	for (i = 0; i < ARRAY_SIZE(amba_devs); i++) {
 		struct amba_device *d = amba_devs[i];
diff --git a/arch/arm/mach-realview/realview_pb11mp.c b/arch/arm/mach-realview/realview_pb11mp.c
index ba0fb33..3f3f052 100644
--- a/arch/arm/mach-realview/realview_pb11mp.c
+++ b/arch/arm/mach-realview/realview_pb11mp.c
@@ -230,13 +230,6 @@ static struct resource realview_pb11mp_smsc911x_resources[] = {
 	},
 };
 
-static struct platform_device realview_pb11mp_smsc911x_device = {
-	.name		= "smc911x",
-	.id		= 0,
-	.num_resources	= ARRAY_SIZE(realview_pb11mp_smsc911x_resources),
-	.resource	= realview_pb11mp_smsc911x_resources,
-};
-
 struct resource realview_pb11mp_cf_resources[] = {
 	[0] = {
 		.start		= REALVIEW_PB11MP_CF_BASE,
@@ -315,7 +308,7 @@ static void __init realview_pb11mp_init(void)
 
 	realview_flash_register(realview_pb11mp_flash_resource,
 				ARRAY_SIZE(realview_pb11mp_flash_resource));
-	platform_device_register(&realview_pb11mp_smsc911x_device);
+	realview_eth_register(NULL, realview_pb11mp_smsc911x_resources);
 	platform_device_register(&realview_i2c_device);
 	platform_device_register(&realview_pb11mp_cf_device);
 
diff --git a/arch/arm/mach-realview/realview_pba8.c b/arch/arm/mach-realview/realview_pba8.c
index ab718cf..9de8aca 100644
--- a/arch/arm/mach-realview/realview_pba8.c
+++ b/arch/arm/mach-realview/realview_pba8.c
@@ -221,13 +221,6 @@ static struct resource realview_pba8_smsc911x_resources[] = {
 	},
 };
 
-static struct platform_device realview_pba8_smsc911x_device = {
-	.name		= "smc911x",
-	.id		= 0,
-	.num_resources	= ARRAY_SIZE(realview_pba8_smsc911x_resources),
-	.resource	= realview_pba8_smsc911x_resources,
-};
-
 struct resource realview_pba8_cf_resources[] = {
 	[0] = {
 		.start		= REALVIEW_PBA8_CF_BASE,
@@ -282,7 +275,7 @@ static void __init realview_pba8_init(void)
 
 	realview_flash_register(realview_pba8_flash_resource,
 				ARRAY_SIZE(realview_pba8_flash_resource));
-	platform_device_register(&realview_pba8_smsc911x_device);
+	realview_eth_register(NULL, realview_pba8_smsc911x_resources);
 	platform_device_register(&realview_i2c_device);
 	platform_device_register(&realview_pba8_cf_device);
 
-----------------------------------------------------------------------

RealView: Add SMSC LAN9118 Ethernet chip support for RealView

From: Catalin Marinas <catalin.marinas@arm.com>

This patch adds RealView platforms support for the soon to be merged
smsc911x.c Ethernet driver.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steve Glendinning@smsc.com <steve.glendinning@smsc.com>
---
 arch/arm/mach-realview/core.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index d80208a..7905f92 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -28,6 +28,7 @@
 #include <linux/clocksource.h>
 #include <linux/clockchips.h>
 #include <linux/io.h>
+#include <linux/smsc911x.h>
 
 #include <asm/system.h>
 #include <mach/hardware.h>
@@ -125,8 +126,15 @@ int realview_flash_register(struct resource *res, u32 num)
 	return platform_device_register(&realview_flash_device);
 }
 
+static struct smsc911x_platform_config realview_smsc911x_config = {
+	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_HIGH,
+	.irq_type	= SMSC911X_IRQ_TYPE_PUSH_PULL,
+	.flags		= SMSC911X_USE_32BIT,
+	.phy_interface	= PHY_INTERFACE_MODE_MII,
+};
+
 static struct platform_device realview_eth_device = {
-	.name		= "smc911x",
+	.name		= "smsc911x",
 	.id		= 0,
 	.num_resources	= 2,
 };
@@ -136,6 +144,8 @@ int realview_eth_register(const char *name, struct resource *res)
 	if (name)
 		realview_eth_device.name = name;
 	realview_eth_device.resource = res;
+	if (strcmp(realview_eth_device.name, "smsc911x") == 0)
+		realview_eth_device.dev.platform_data = &realview_smsc911x_config;
 
 	return platform_device_register(&realview_eth_device);
 }


-- 
Catalin

