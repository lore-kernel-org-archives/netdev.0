From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 07/10] arm: convert omap ldp platform to use smsc911x
Date: Tue, 27 Jan 2009 16:51:15 +0000
Message-ID: <1233075077-17205-8-git-send-email-steve.glendinning@smsc.com>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-2-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-3-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-4-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-5-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-6-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-7-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:53200 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756142AbZA0QvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:51:24 -0500
In-Reply-To: <1233075077-17205-7-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from 2.6.29, smc911x isn't maintained anymore. A new driver, smsc911x,
will replace it. so convert omap_ldp to use smsc911x driver.

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 arch/arm/mach-omap2/board-ldp.c             |   49 ++++++++++++++++-----------
 arch/arm/plat-omap/include/mach/board-ldp.h |    6 +--
 2 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
index f6a1345..68208a7 100644
--- a/arch/arm/mach-omap2/board-ldp.c
+++ b/arch/arm/mach-omap2/board-ldp.c
@@ -22,6 +22,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/ads7846.h>
 #include <linux/i2c/twl4030.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -41,12 +42,10 @@
 
 #include "mmc-twl4030.h"
 
-#define SDP3430_SMC91X_CS	3
-
-static struct resource ldp_smc911x_resources[] = {
+static struct resource ldp_smsc911x_resources[] = {
 	[0] = {
-		.start	= OMAP34XX_ETHR_START,
-		.end	= OMAP34XX_ETHR_START + SZ_4K,
+		.start	= 0,
+		.end	= 0,
 		.flags	= IORESOURCE_MEM,
 	},
 	[1] = {
@@ -56,40 +55,50 @@ static struct resource ldp_smc911x_resources[] = {
 	},
 };
 
-static struct platform_device ldp_smc911x_device = {
-	.name		= "smc911x",
+static struct smsc911x_platform_config ldp_smsc911x_config = {
+	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags		= SMSC911X_USE_32BIT,
+	.phy_interface	= PHY_INTERFACE_MODE_MII,
+};
+
+static struct platform_device ldp_smsc911x_device = {
+	.name		= "smsc911x",
 	.id		= -1,
-	.num_resources	= ARRAY_SIZE(ldp_smc911x_resources),
-	.resource	= ldp_smc911x_resources,
+	.num_resources	= ARRAY_SIZE(ldp_smsc911x_resources),
+	.resource	= ldp_smsc911x_resources,
+	.dev		= {
+		.platform_data = &ldp_smsc911x_config,
+	},
 };
 
 static struct platform_device *ldp_devices[] __initdata = {
-	&ldp_smc911x_device,
+	&ldp_smsc911x_device,
 };
 
-static inline void __init ldp_init_smc911x(void)
+static inline void __init ldp_init_smsc911x(void)
 {
 	int eth_cs;
 	unsigned long cs_mem_base;
 	int eth_gpio = 0;
 
-	eth_cs = LDP_SMC911X_CS;
+	eth_cs = LDP_SMSC911X_CS;
 
 	if (gpmc_cs_request(eth_cs, SZ_16M, &cs_mem_base) < 0) {
-		printk(KERN_ERR "Failed to request GPMC mem for smc911x\n");
+		printk(KERN_ERR "Failed to request GPMC mem for smsc911x\n");
 		return;
 	}
 
-	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
-	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
+	ldp_smsc911x_resources[0].start = cs_mem_base + 0x0;
+	ldp_smsc911x_resources[0].end   = cs_mem_base + 0xff;
 	udelay(100);
 
-	eth_gpio = LDP_SMC911X_GPIO;
+	eth_gpio = LDP_SMSC911X_GPIO;
 
-	ldp_smc911x_resources[1].start = OMAP_GPIO_IRQ(eth_gpio);
+	ldp_smsc911x_resources[1].start = OMAP_GPIO_IRQ(eth_gpio);
 
-	if (gpio_request(eth_gpio, "smc911x irq") < 0) {
-		printk(KERN_ERR "Failed to request GPIO%d for smc911x IRQ\n",
+	if (gpio_request(eth_gpio, "smsc911x irq") < 0) {
+		printk(KERN_ERR "Failed to request GPIO%d for smsc911x IRQ\n",
 				eth_gpio);
 		return;
 	}
@@ -101,7 +110,7 @@ static void __init omap_ldp_init_irq(void)
 	omap2_init_common_hw();
 	omap_init_irq();
 	omap_gpio_init();
-	ldp_init_smc911x();
+	ldp_init_smsc911x();
 }
 
 static struct omap_uart_config ldp_uart_config __initdata = {
diff --git a/arch/arm/plat-omap/include/mach/board-ldp.h b/arch/arm/plat-omap/include/mach/board-ldp.h
index f233996..81ac2b8 100644
--- a/arch/arm/plat-omap/include/mach/board-ldp.h
+++ b/arch/arm/plat-omap/include/mach/board-ldp.h
@@ -32,8 +32,6 @@
 extern void twl4030_bci_battery_init(void);
 
 #define TWL4030_IRQNUM		INT_34XX_SYS_NIRQ
-#define LDP_SMC911X_CS         1
-#define LDP_SMC911X_GPIO       152
-#define DEBUG_BASE             0x08000000
-#define OMAP34XX_ETHR_START    DEBUG_BASE
+#define LDP_SMSC911X_CS		1
+#define LDP_SMSC911X_GPIO	152
 #endif /* __ASM_ARCH_OMAP_LDP_H */
-- 
1.6.0.6

