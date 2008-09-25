From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/4] [ARM] Orion: instantiate the dsa switch driver
Date: Thu, 25 Sep 2008 18:44:21 +0200
Message-ID: <20080925164421.GE25190@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37926 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbYIYQoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 12:44:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds DSA switch instantiation hooks to the orion5x and the
kirkwood ARM SoC platform code, and instantiates the DSA switch
driver on the 88F5181L FXO RD, the 88F5181L GE RD, the 6183 AP GE
RD, and the 88F6281 RD boards.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/arm/mach-kirkwood/common.c              |   35 ++++++++++++++++++++++++++
 arch/arm/mach-kirkwood/common.h              |    2 +
 arch/arm/mach-kirkwood/rd88f6281-setup.c     |   11 ++++++++
 arch/arm/mach-orion5x/common.c               |   35 ++++++++++++++++++++++++++
 arch/arm/mach-orion5x/common.h               |    2 +
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |   11 ++++++++
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |   11 ++++++++
 arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c |   11 ++++++++
 8 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
index c8516e3..507025c 100644
--- a/arch/arm/mach-kirkwood/common.c
+++ b/arch/arm/mach-kirkwood/common.c
@@ -16,6 +16,7 @@
 #include <linux/mv643xx_eth.h>
 #include <linux/ata_platform.h>
 #include <linux/spi/orion_spi.h>
+#include <net/dsa.h>
 #include <asm/page.h>
 #include <asm/timex.h>
 #include <asm/mach/map.h>
@@ -152,6 +153,40 @@ void __init kirkwood_ge00_init(struct mv643xx_eth_platform_data *eth_data)
 
 
 /*****************************************************************************
+ * Ethernet switch
+ ****************************************************************************/
+static struct resource kirkwood_switch_resources[] = {
+	{
+		.start	= 0,
+		.end	= 0,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device kirkwood_switch_device = {
+	.name		= "dsa",
+	.id		= 0,
+	.num_resources	= 0,
+	.resource	= kirkwood_switch_resources,
+};
+
+void __init kirkwood_ge00_switch_init(struct dsa_platform_data *d, int irq)
+{
+	if (irq != NO_IRQ) {
+		kirkwood_switch_resources[0].start = irq;
+		kirkwood_switch_resources[0].end = irq;
+		kirkwood_switch_device.num_resources = 1;
+	}
+
+	d->mii_bus = &kirkwood_ge00_shared.dev;
+	d->netdev = &kirkwood_ge00.dev;
+	kirkwood_switch_device.dev.platform_data = d;
+
+	platform_device_register(&kirkwood_switch_device);
+}
+
+
+/*****************************************************************************
  * SoC RTC
  ****************************************************************************/
 static struct resource kirkwood_rtc_resource = {
diff --git a/arch/arm/mach-kirkwood/common.h b/arch/arm/mach-kirkwood/common.h
index 8fa0f6a..5774632 100644
--- a/arch/arm/mach-kirkwood/common.h
+++ b/arch/arm/mach-kirkwood/common.h
@@ -11,6 +11,7 @@
 #ifndef __ARCH_KIRKWOOD_COMMON_H
 #define __ARCH_KIRKWOOD_COMMON_H
 
+struct dsa_platform_data;
 struct mv643xx_eth_platform_data;
 struct mv_sata_platform_data;
 
@@ -29,6 +30,7 @@ void kirkwood_pcie_id(u32 *dev, u32 *rev);
 
 void kirkwood_ehci_init(void);
 void kirkwood_ge00_init(struct mv643xx_eth_platform_data *eth_data);
+void kirkwood_ge00_switch_init(struct dsa_platform_data *d, int irq);
 void kirkwood_pcie_init(void);
 void kirkwood_rtc_init(void);
 void kirkwood_sata_init(struct mv_sata_platform_data *sata_data);
diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index f785093..175054a 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -19,6 +19,7 @@
 #include <linux/ata_platform.h>
 #include <linux/mv643xx_eth.h>
 #include <linux/ethtool.h>
+#include <net/dsa.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/pci.h>
@@ -74,6 +75,15 @@ static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
+static struct dsa_platform_data rd88f6281_switch_data = {
+	.port_names[0]	= "lan1",
+	.port_names[1]	= "lan2",
+	.port_names[2]	= "lan3",
+	.port_names[3]	= "lan4",
+	.port_names[4]	= "wan",
+	.port_names[5]	= "cpu",
+};
+
 static struct mv_sata_platform_data rd88f6281_sata_data = {
 	.n_ports	= 2,
 };
@@ -87,6 +97,7 @@ static void __init rd88f6281_init(void)
 
 	kirkwood_ehci_init();
 	kirkwood_ge00_init(&rd88f6281_ge00_data);
+	kirkwood_ge00_switch_init(&rd88f6281_switch_data, NO_IRQ);
 	kirkwood_rtc_init();
 	kirkwood_sata_init(&rd88f6281_sata_data);
 	kirkwood_uart0_init();
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 9625ef5..a2f917e 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -19,6 +19,7 @@
 #include <linux/mv643xx_i2c.h>
 #include <linux/ata_platform.h>
 #include <linux/spi/orion_spi.h>
+#include <net/dsa.h>
 #include <asm/page.h>
 #include <asm/setup.h>
 #include <asm/timex.h>
@@ -198,6 +199,40 @@ void __init orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data)
 
 
 /*****************************************************************************
+ * Ethernet switch
+ ****************************************************************************/
+static struct resource orion5x_switch_resources[] = {
+	{
+		.start	= 0,
+		.end	= 0,
+		.flags	= IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device orion5x_switch_device = {
+	.name		= "dsa",
+	.id		= 0,
+	.num_resources	= 0,
+	.resource	= orion5x_switch_resources,
+};
+
+void __init orion5x_eth_switch_init(struct dsa_platform_data *d, int irq)
+{
+	if (irq != NO_IRQ) {
+		orion5x_switch_resources[0].start = irq;
+		orion5x_switch_resources[0].end = irq;
+		orion5x_switch_device.num_resources = 1;
+	}
+
+	d->mii_bus = &orion5x_eth_shared.dev;
+	d->netdev = &orion5x_eth.dev;
+	orion5x_switch_device.dev.platform_data = d;
+
+	platform_device_register(&orion5x_switch_device);
+}
+
+
+/*****************************************************************************
  * I2C
  ****************************************************************************/
 static struct mv64xxx_i2c_pdata orion5x_i2c_pdata = {
diff --git a/arch/arm/mach-orion5x/common.h b/arch/arm/mach-orion5x/common.h
index 1f8b2da..a000c7c 100644
--- a/arch/arm/mach-orion5x/common.h
+++ b/arch/arm/mach-orion5x/common.h
@@ -1,6 +1,7 @@
 #ifndef __ARCH_ORION5X_COMMON_H
 #define __ARCH_ORION5X_COMMON_H
 
+struct dsa_platform_data;
 struct mv643xx_eth_platform_data;
 struct mv_sata_platform_data;
 
@@ -29,6 +30,7 @@ void orion5x_setup_pcie_wa_win(u32 base, u32 size);
 void orion5x_ehci0_init(void);
 void orion5x_ehci1_init(void);
 void orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data);
+void orion5x_eth_switch_init(struct dsa_platform_data *d, int irq);
 void orion5x_i2c_init(void);
 void orion5x_sata_init(struct mv_sata_platform_data *sata_data);
 void orion5x_spi_init(void);
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index 500cdad..15f5323 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -16,6 +16,7 @@
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
 #include <linux/ethtool.h>
+#include <net/dsa.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/leds.h>
@@ -93,6 +94,15 @@ static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
+static struct dsa_platform_data rd88f5181l_fxo_switch_data = {
+	.port_names[0]	= "lan2",
+	.port_names[1]	= "lan1",
+	.port_names[2]	= "wan",
+	.port_names[3]	= "cpu",
+	.port_names[5]	= "lan4",
+	.port_names[7]	= "lan3",
+};
+
 static void __init rd88f5181l_fxo_init(void)
 {
 	/*
@@ -107,6 +117,7 @@ static void __init rd88f5181l_fxo_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_fxo_eth_data);
+	orion5x_eth_switch_init(&rd88f5181l_fxo_switch_data, NO_IRQ);
 	orion5x_uart0_init();
 
 	orion5x_setup_dev_boot_win(RD88F5181L_FXO_NOR_BOOT_BASE,
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index ebde814..8ad3934 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -17,6 +17,7 @@
 #include <linux/mv643xx_eth.h>
 #include <linux/ethtool.h>
 #include <linux/i2c.h>
+#include <net/dsa.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/leds.h>
@@ -94,6 +95,15 @@ static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
+static struct dsa_platform_data rd88f5181l_ge_switch_data = {
+	.port_names[0]	= "lan2",
+	.port_names[1]	= "lan1",
+	.port_names[2]	= "wan",
+	.port_names[3]	= "cpu",
+	.port_names[5]	= "lan4",
+	.port_names[7]	= "lan3",
+};
+
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
 	I2C_BOARD_INFO("ds1338", 0x68),
 };
@@ -112,6 +122,7 @@ static void __init rd88f5181l_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f5181l_ge_eth_data);
+	orion5x_eth_switch_init(&rd88f5181l_ge_switch_data, gpio_to_irq(8));
 	orion5x_i2c_init();
 	orion5x_uart0_init();
 
diff --git a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
index 40e0495..262e25e 100644
--- a/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c
@@ -19,6 +19,7 @@
 #include <linux/spi/orion_spi.h>
 #include <linux/spi/flash.h>
 #include <linux/ethtool.h>
+#include <net/dsa.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/leds.h>
@@ -34,6 +35,15 @@ static struct mv643xx_eth_platform_data rd88f6183ap_ge_eth_data = {
 	.duplex		= DUPLEX_FULL,
 };
 
+static struct dsa_platform_data rd88f6183ap_ge_switch_data = {
+	.port_names[0]	= "lan1",
+	.port_names[1]	= "lan2",
+	.port_names[2]	= "lan3",
+	.port_names[3]	= "lan4",
+	.port_names[4]	= "wan",
+	.port_names[5]	= "cpu",
+};
+
 static struct mtd_partition rd88f6183ap_ge_partitions[] = {
 	{
 		.name	= "kernel",
@@ -79,6 +89,7 @@ static void __init rd88f6183ap_ge_init(void)
 	 */
 	orion5x_ehci0_init();
 	orion5x_eth_init(&rd88f6183ap_ge_eth_data);
+	orion5x_eth_switch_init(&rd88f6183ap_ge_switch_data, gpio_to_irq(3));
 	spi_register_board_info(rd88f6183ap_ge_spi_slave_info,
 				ARRAY_SIZE(rd88f6183ap_ge_spi_slave_info));
 	orion5x_spi_init();
-- 
1.5.6.4
