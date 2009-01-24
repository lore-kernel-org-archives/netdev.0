From: "Stanley.Miao" <stanley.miao@windriver.com>
Subject: [PATCHv2 7/8] arm: convert omap ldp platform to use smsc911x
Date: Sat, 24 Jan 2009 11:38:37 +0800
Message-ID: <1232768317-20483-1-git-send-email-stanley.miao@windriver.com>
References: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Cc: linux@arm.linux.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, steve.glendinning@smsc.com
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44449 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754216AbZAXDaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2009 22:30:01 -0500
In-Reply-To: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from 2.6.29, smc911x isn't maintained anymore. A new driver, smsc911x,
will replace it. so convert omap_ldp to use smsc911x driver.

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
---
 arch/arm/mach-omap2/board-ldp.c             |   47 +++++++++++++++------------
 arch/arm/plat-omap/include/mach/board-ldp.h |    6 +--
 2 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
index aa69727..67c123a 100644
--- a/arch/arm/mach-omap2/board-ldp.c
+++ b/arch/arm/mach-omap2/board-ldp.c
@@ -22,6 +22,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/ads7846.h>
 #include <linux/i2c/twl4030.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -41,55 +42,59 @@
 
 #include "mmc-twl4030.h"
 
-#define SDP3430_SMC91X_CS	3
-
-static struct resource ldp_smc911x_resources[] = {
+static struct resource ldp_smsc911x_resources[] = {
 	[0] = {
-		.start	= OMAP34XX_ETHR_START,
-		.end	= OMAP34XX_ETHR_START + SZ_4K,
 		.flags	= IORESOURCE_MEM,
 	},
 	[1] = {
-		.start	= 0,
-		.end	= 0,
 		.flags	= IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
 	},
 };
 
-static struct platform_device ldp_smc911x_device = {
-	.name		= "smc911x",
+static struct smsc911x_platform_config ldp_smsc911x_config = {
+	.irq_polarity   = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
+	.irq_type       = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
+	.flags          = SMSC911X_USE_32BIT,
+	.phy_interface  = PHY_INTERFACE_MODE_MII,
+};
+
+static struct platform_device ldp_smsc911x_device = {
+	.name		= "smsc911x",
 	.id		= -1,
-	.num_resources	= ARRAY_SIZE(ldp_smc911x_resources),
-	.resource	= ldp_smc911x_resources,
+	.num_resources	= ARRAY_SIZE(ldp_smsc911x_resources),
+	.resource	= ldp_smsc911x_resources,
+	.dev            = {
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
 
 	if (omap_request_gpio(eth_gpio) < 0) {
-		printk(KERN_ERR "Failed to request GPIO%d for smc911x IRQ\n",
+		printk(KERN_ERR "Failed to request GPIO%d for smsc911x IRQ\n",
 				eth_gpio);
 		return;
 	}
@@ -101,7 +106,7 @@ static void __init omap_ldp_init_irq(void)
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
1.5.6.3

