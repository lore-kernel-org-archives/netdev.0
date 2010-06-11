From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH] Phytec PCM027: register CAN resources
Date: Fri, 11 Jun 2010 13:46:16 +0200
Message-ID: <1276256776-17068-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Juergen Beisert <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Juergen Beisert <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

applies to current net-next-2.6
(which includes Wolfgang's patche "can: sja1000 platform data fixes")

cheers, Marc


>From 66af2a1778a468610e25403336cc27650fddef2a Mon Sep 17 00:00:00 2001
From: Juergen Beisert <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date: Fri, 11 Jun 2010 13:27:03 +0200
Subject: [PATCH] Phytec PCM027: register CAN resources

This patch adds resources for the SJA1000 platform device.

Signed-off-by: Juergen Beisert <jbe-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 arch/arm/mach-pxa/include/mach/pcm027.h |    2 +-
 arch/arm/mach-pxa/pcm027.c              |   40 ++++++++++++++++++++++++++++++-
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-pxa/include/mach/pcm027.h b/arch/arm/mach-pxa/include/mach/pcm027.h
index 0408326..b65fcc4 100644
--- a/arch/arm/mach-pxa/include/mach/pcm027.h
+++ b/arch/arm/mach-pxa/include/mach/pcm027.h
@@ -49,7 +49,7 @@
 /* CAN controller SJA1000 (unsupported yet) */
 #define PCM027_CAN_IRQ_GPIO	114
 #define PCM027_CAN_IRQ		IRQ_GPIO(PCM027_CAN_IRQ_GPIO)
-#define PCM027_CAN_IRQ_EDGE	IRQ_TYPE_EDGE_FALLING
+#define PCM027_CAN_IRQ_EDGE	IORESOURCE_IRQ_LOWEDGE
 #define PCM027_CAN_PHYS		0x22000000
 #define PCM027_CAN_SIZE		0x100
 
diff --git a/arch/arm/mach-pxa/pcm027.c b/arch/arm/mach-pxa/pcm027.c
index 2190af0..2ef7686 100644
--- a/arch/arm/mach-pxa/pcm027.c
+++ b/arch/arm/mach-pxa/pcm027.c
@@ -26,6 +26,7 @@
 #include <linux/spi/spi.h>
 #include <linux/spi/max7301.h>
 #include <linux/leds.h>
+#include <linux/can/platform/sja1000.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -204,13 +205,50 @@ static struct platform_device pcm027_led_dev = {
 #endif /* CONFIG_LEDS_GPIO */
 
 /*
+ * SJA1000 CAN controller
+ */
+#if defined(CONFIG_CAN_SJA1000_PLATFORM) || defined(CONFIG_CAN_SJA1000_PLATFORM_MODULE)
+static struct resource pcm027_sja1000_resources[] = {
+	[0] = {
+		.start	= PCM027_CAN_PHYS,
+		.end	= PCM027_CAN_PHYS + PCM027_CAN_SIZE - 1,
+		.flags	= IORESOURCE_MEM,
+	},
+	[1] = {
+		.start	= PCM027_CAN_IRQ,
+		.end	= PCM027_CAN_IRQ,
+		.flags	= IORESOURCE_IRQ | PCM027_CAN_IRQ_EDGE,
+	},
+};
+
+static struct sja1000_platform_data pcm027_sja1000_platform_data = {
+	.osc_freq	= 16000000,
+	.ocr		= OCR_TX1_PULLDOWN | OCR_TX0_PUSHPULL,
+	.cdr		= CDR_CBP,
+};
+
+static struct platform_device pcm027_sja1000_device = {
+	.name		= "sja1000_platform",
+	.dev = {
+		.platform_data = &pcm027_sja1000_platform_data,
+	},
+	.num_resources	= ARRAY_SIZE(pcm027_sja1000_resources),
+	.resource	= pcm027_sja1000_resources,
+};
+#endif /* CONFIG_CAN_SJA1000_PLATFORM || CONFIG_CAN_SJA1000_PLATFORM_MODULE */
+
+
+/*
  * declare the available device resources on this board
  */
 static struct platform_device *devices[] __initdata = {
 	&smc91x_device,
 	&pcm027_flash,
 #ifdef CONFIG_LEDS_GPIO
-	&pcm027_led_dev
+	&pcm027_led_dev,
+#endif
+#if defined(CONFIG_CAN_SJA1000_PLATFORM) || defined(CONFIG_CAN_SJA1000_PLATFORM_MODULE)
+	&pcm027_sja1000_device,
 #endif
 };
 
-- 
1.7.1
