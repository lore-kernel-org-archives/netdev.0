From: Eric Miao <eric.y.miao@gmail.com>
Subject: [PATCH 08/10] pxa: make mainstone to use the new smc91x platform data
Date: Tue, 24 Jun 2008 17:47:45 +0800
Message-ID: <1214300867-15495-9-git-send-email-eric.y.miao@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.marvell.com ([65.219.4.2]:44708 "EHLO maili.marvell.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753270AbYFXJrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 05:47:40 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Miao <eric.miao@marvell.com>

Signed-off-by: Eric Miao <eric.miao@marvell.com>
---
 arch/arm/mach-pxa/mainstone.c |    9 +++++++++
 drivers/net/smc91x.h          |   33 +++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/arch/arm/mach-pxa/mainstone.c b/arch/arm/mach-pxa/mainstone.c
index 5b145fa..7135c68 100644
--- a/arch/arm/mach-pxa/mainstone.c
+++ b/arch/arm/mach-pxa/mainstone.c
@@ -26,6 +26,7 @@
 #include <linux/input.h>
 #include <linux/gpio_keys.h>
 #include <linux/pwm_backlight.h>
+#include <linux/smc91x.h>
 
 #include <asm/types.h>
 #include <asm/setup.h>
@@ -240,11 +241,19 @@ static struct resource smc91x_resources[] = {
 	}
 };
 
+static struct smc91x_platdata mainstone_smc91x_info = {
+	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
+		  SMC91X_NOWAIT | SMC91X_USE_DMA,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev		= {
+		.platform_data = &mainstone_smc91x_info,
+	},
 };
 
 static int mst_audio_startup(struct snd_pcm_substream *substream, void *priv)
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 95ee9ed..3d03284 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -40,22 +40,44 @@
  * Define your architecture specific bus configuration parameters here.
  */
 
-#if	defined(CONFIG_ARCH_LUBBOCK)
+#if defined(CONFIG_ARCH_LUBBOCK) ||\
+    defined(CONFIG_MACH_MAINSTONE)
 
-/* We can only do 16-bit reads and writes in the static memory space. */
-#define SMC_CAN_USE_8BIT	0
+#include <asm/mach-types.h>
+
+/* Now the bus width is specified in the platform data
+ * pretend here to support all I/O access types
+ */
+#define SMC_CAN_USE_8BIT	1
 #define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
+#define SMC_CAN_USE_32BIT	1
 #define SMC_NOWAIT		1
 
 #define SMC_IO_SHIFT		smc_io_shift
 
+#define SMC_inb(a, r)		readb((a) + (r))
 #define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_inl(a, r)		readl((a) + (r))
+#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_outl(v, a, r)	writel(v, (a) + (r))
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
+#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
+/* We actually can't write halfwords properly if not word aligned */
+static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
+{
+	if (machine_is_mainstone() && reg & 2) {
+		unsigned int v = val << 16;
+		v |= readl(ioaddr + (reg & ~2)) & 0xffff;
+		writel(v, ioaddr + (reg & ~2));
+	} else {
+		writew(val, ioaddr + reg);
+	}
+}
+
 #elif defined(CONFIG_BLACKFIN)
 
 #define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
@@ -194,7 +216,6 @@
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 
 #elif	defined(CONFIG_ARCH_INNOKOM) || \
-	defined(CONFIG_MACH_MAINSTONE) || \
 	defined(CONFIG_ARCH_PXA_IDP) || \
 	defined(CONFIG_ARCH_RAMSES) || \
 	defined(CONFIG_ARCH_PCM027)
-- 
1.5.4.3

