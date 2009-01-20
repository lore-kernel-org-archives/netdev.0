From: "Stanley.Miao" <stanley.miao@windriver.com>
Subject: [PATCH repost] OMAP: convert omap ldp platform to use smsc911x
Date: Tue, 20 Jan 2009 15:49:48 +0800
Message-ID: <1232437788-798-1-git-send-email-stanley.miao@windriver.com>
Cc: steve.glendinning@smsc.com, davem@davemloft.net,
	linux-arm-kernel@lists.arm.linux.org.uk, linux@arm.linux.org.uk,
	netdev@vger.kernel.org
To: linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 2.6.29, smc911x isn't maintained anymore. A new driver, smsc911x,
will replace it. so convert omap_ldp to use smsc911x driver.

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
---
 arch/arm/configs/omap_ldp_defconfig         |   24 ++++++++++++-
 arch/arm/mach-omap2/board-ldp.c             |   49 ++++++++++++++++-----------
 arch/arm/plat-omap/include/mach/board-ldp.h |    6 +--
 3 files changed, 53 insertions(+), 26 deletions(-)

diff --git a/arch/arm/configs/omap_ldp_defconfig b/arch/arm/configs/omap_ldp_defconfig
index d88e6d7..64db3b1 100644
--- a/arch/arm/configs/omap_ldp_defconfig
+++ b/arch/arm/configs/omap_ldp_defconfig
@@ -489,14 +489,34 @@ CONFIG_NETDEVICES=y
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
 # CONFIG_VETH is not set
-# CONFIG_PHYLIB is not set
+CONFIG_PHYLIB=y
+
+#
+# MII PHY device drivers
+#
+# CONFIG_MARVELL_PHY is not set
+# CONFIG_DAVICOM_PHY is not set
+# CONFIG_QSEMI_PHY is not set
+# CONFIG_LXT_PHY is not set
+# CONFIG_CICADA_PHY is not set
+# CONFIG_VITESSE_PHY is not set
+CONFIG_SMSC_PHY=y
+# CONFIG_BROADCOM_PHY is not set
+# CONFIG_ICPLUS_PHY is not set
+# CONFIG_REALTEK_PHY is not set
+# CONFIG_NATIONAL_PHY is not set
+# CONFIG_STE10XP is not set
+# CONFIG_LSI_ET1011C_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
 # CONFIG_AX88796 is not set
 # CONFIG_SMC91X is not set
 # CONFIG_DM9000 is not set
 # CONFIG_ENC28J60 is not set
-CONFIG_SMC911X=y
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
index 6592d58..ea00f1b 100644
--- a/arch/arm/mach-omap2/board-ldp.c
+++ b/arch/arm/mach-omap2/board-ldp.c
@@ -23,6 +23,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/ads7846.h>
 #include <linux/i2c/twl4030.h>
+#include <linux/smsc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -44,8 +45,6 @@
 
 #include "mmc-twl4030.h"
 
-
-#define SDP3430_SMC91X_CS	3
 #define CONFIG_DISABLE_HFCLK 1
 
 #define ENABLE_VAUX1_DEDICATED	0x03
@@ -53,10 +52,10 @@
 
 #define TWL4030_MSECURE_GPIO	22
 
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
@@ -66,11 +65,21 @@ static struct resource ldp_smc911x_resources[] = {
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
 
 static int ldp_twl4030_keymap[] = {
@@ -308,34 +317,34 @@ static struct platform_device ldp_lcd_device = {
 };
 
 static struct platform_device *ldp_devices[] __initdata = {
-	&ldp_smc911x_device,
+	&ldp_smsc911x_device,
 	&ldp_lcd_device,
 	&ldp_gpio_keys_device,
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
+	ldp_smsc911x_resources[0].end   = cs_mem_base + 0x100;
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
@@ -348,7 +357,7 @@ static void __init omap_ldp_init_irq(void)
 	omap2_init_common_hw(NULL);
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

