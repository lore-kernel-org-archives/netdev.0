From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 6/6] smsc911x: convert realview platforms to use smsc911x
Date: Wed,  5 Nov 2008 10:35:42 +0000
Message-ID: <1225881342-3485-7-git-send-email-steve.glendinning@smsc.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-4-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-5-git-send-email-steve.glendinning@smsc.com>
 <1225881342-3485-6-git-send-email-steve.glendinning@smsc.com>
Cc: catalin.marinas@arm.com, Bahadir.Balban@arm.com,
	dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:57512 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754315AbYKEKf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:35:56 -0500
In-Reply-To: <1225881342-3485-6-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/arm/mach-realview/realview_eb.c     |   16 +++++++++++++---
 arch/arm/mach-realview/realview_pb1176.c |   13 ++++++++++++-
 arch/arm/mach-realview/realview_pb11mp.c |   13 ++++++++++++-
 3 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-realview/realview_eb.c b/arch/arm/mach-realview/realview_eb.c
index eb829eb..f461844 100644
--- a/arch/arm/mach-realview/realview_eb.c
+++ b/arch/arm/mach-realview/realview_eb.c
@@ -24,6 +24,7 @@
 #include <linux/sysdev.h>
 #include <linux/amba/bus.h>
 #include <linux/io.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/irq.h>
@@ -248,6 +249,13 @@ static struct platform_device realview_eb_eth_device = {
 	.resource	= realview_eb_eth_resources,
 };
 
+static struct smsc911x_platform_config smsc911x_config = {
+	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags = SMSC911X_USE_32BIT,
+	.phy_interface = PHY_INTERFACE_MODE_MII,
+};
+
 /*
  * Detect and register the correct Ethernet device. RealView/EB rev D
  * platforms use the newer SMSC LAN9118 Ethernet chip
@@ -261,12 +269,14 @@ static int eth_device_register(void)
 		return -ENOMEM;
 
 	idrev = readl(eth_addr + 0x50);
-	if ((idrev & 0xFFFF0000) == 0x01180000)
+	if ((idrev & 0xFFFF0000) == 0x01180000) {
 		/* SMSC LAN9118 chip present */
-		realview_eb_eth_device.name = "smc911x";
-	else
+		realview_eb_eth_device.name = "smsc911x";
+		realview_eb_eth_device.dev.platform_data = &smsc911x_config;
+	} else {
 		/* SMSC 91C111 chip present */
 		realview_eb_eth_device.name = "smc91x";
+	}
 
 	iounmap(eth_addr);
 	return platform_device_register(&realview_eb_eth_device);
diff --git a/arch/arm/mach-realview/realview_pb1176.c b/arch/arm/mach-realview/realview_pb1176.c
index cccdb3e..718ab0c 100644
--- a/arch/arm/mach-realview/realview_pb1176.c
+++ b/arch/arm/mach-realview/realview_pb1176.c
@@ -24,6 +24,7 @@
 #include <linux/sysdev.h>
 #include <linux/amba/bus.h>
 #include <linux/io.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/irq.h>
@@ -222,11 +223,21 @@ static struct resource realview_pb1176_smsc911x_resources[] = {
 	},
 };
 
+static struct smsc911x_platform_config smsc911x_config = {
+	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags = SMSC911X_USE_32BIT,
+	.phy_interface = PHY_INTERFACE_MODE_MII,
+};
+
 static struct platform_device realview_pb1176_smsc911x_device = {
-	.name		= "smc911x",
+	.name		= "smsc911x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(realview_pb1176_smsc911x_resources),
 	.resource	= realview_pb1176_smsc911x_resources,
+	.dev = {
+		.platform_data = &smsc911x_config,
+	},
 };
 
 static void __init gic_init_irq(void)
diff --git a/arch/arm/mach-realview/realview_pb11mp.c b/arch/arm/mach-realview/realview_pb11mp.c
index 8b86314..dc042fa 100644
--- a/arch/arm/mach-realview/realview_pb11mp.c
+++ b/arch/arm/mach-realview/realview_pb11mp.c
@@ -24,6 +24,7 @@
 #include <linux/sysdev.h>
 #include <linux/amba/bus.h>
 #include <linux/io.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/irq.h>
@@ -230,11 +231,21 @@ static struct resource realview_pb11mp_smsc911x_resources[] = {
 	},
 };
 
+static struct smsc911x_platform_config smsc911x_config = {
+	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags = SMSC911X_USE_32BIT,
+	.phy_interface = PHY_INTERFACE_MODE_MII,
+};
+
 static struct platform_device realview_pb11mp_smsc911x_device = {
-	.name		= "smc911x",
+	.name		= "smsc911x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(realview_pb11mp_smsc911x_resources),
 	.resource	= realview_pb11mp_smsc911x_resources,
+	.dev = {
+		.platform_data = &smsc911x_config,
+	},
 };
 
 struct resource realview_pb11mp_cf_resources[] = {
-- 
1.5.6.5

