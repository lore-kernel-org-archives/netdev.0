From: Guennadi Liakhovetski <lg@denx.de>
Subject: [PATCH] [ARM] pcm037: add support for the on-board LAN9217 network
 controller
Date: Sat, 18 Oct 2008 23:02:34 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810182257270.30019@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:46675 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751031AbYJRVCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 17:02:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc911x now also supports LAN921{5,7,8} network controllers.

Signed-off-by: Guennadi Liakhovetski <lg@denx.de>
Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---

This patch shall be merged through the ARM tree, however, as you see, it 
also modifies drivers/net/Kconfig. The easiest for me would be if just I 
could get an Acked-by for it. Otherwise, please tell me what you would 
prefer - split it into two? Another thing - after a recent cs89x0 
discussion, is it a good idea to add another ARM SoC type to the depends 
list, or maybe just switch it to "ARM || SUPERH" or something totally 
different? 

 arch/arm/mach-mx3/pcm037.c |   37 +++++++++++++++++++++++++++++++++++++
 drivers/net/Kconfig        |    2 +-
 2 files changed, 38 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-mx3/pcm037.c b/arch/arm/mach-mx3/pcm037.c
index 11fda95..5660000 100644
--- a/arch/arm/mach-mx3/pcm037.c
+++ b/arch/arm/mach-mx3/pcm037.c
@@ -22,6 +22,9 @@
 #include <linux/platform_device.h>
 #include <linux/mtd/physmap.h>
 #include <linux/memory.h>
+#include <linux/interrupt.h>
+#include <linux/gpio.h>
+#include <linux/smc911x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -59,8 +62,37 @@ static struct imxuart_platform_data uart_pdata = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
 
+static struct resource smc911x_resources[] = {
+	[0] = {
+		.start		= CS1_BASE_ADDR + 0x300,
+		.end		= CS1_BASE_ADDR + 0x300 + SZ_64K - 1,
+		.flags		= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
+		.end		= IOMUX_TO_IRQ(MX31_PIN_GPIO3_1),
+		.flags		= IORESOURCE_IRQ,
+	},
+};
+
+static struct smc911x_platdata smc911x_info = {
+	.flags		= SMC911X_USE_32BIT,
+	.irq_flags	= IRQF_SHARED | IRQF_TRIGGER_LOW,
+};
+
+static struct platform_device pcm037_eth = {
+	.name		= "smc911x",
+	.id		= -1,
+	.num_resources	= ARRAY_SIZE(smc911x_resources),
+	.resource	= smc911x_resources,
+	.dev		= {
+		.platform_data = &smc911x_info,
+	},
+};
+
 static struct platform_device *devices[] __initdata = {
 	&pcm037_flash,
+	&pcm037_eth,
 };
 
 /*
@@ -81,6 +113,11 @@ static void __init mxc_board_init(void)
 	mxc_iomux_mode(MX31_PIN_CSPI3_MISO__TXD3);
 
 	mxc_register_device(&mxc_uart_device2, &uart_pdata);
+
+	/* SMSC9215 IRQ pin */
+	mxc_iomux_mode(IOMUX_MODE(MX31_PIN_GPIO3_1, IOMUX_CONFIG_GPIO));
+	if (!gpio_request(MX31_PIN_GPIO3_1, "pcm037-eth"))
+		gpio_direction_input(MX31_PIN_GPIO3_1);
 }
 
 /*
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1d8af33..86cf212 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -960,7 +960,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SUPERH
+	depends on ARCH_PXA || ARCH_MX3 || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-- 
1.5.6.5
