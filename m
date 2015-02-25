From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: smc91x: use run-time configuration on all ARM machines
Date: Wed, 25 Feb 2015 16:31:57 +0100
Message-ID: <2226303.iMQTNXSl1n@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, Robert Jarzmik <robert.jarzmik@free.fr>,
	Linus Walleij <linus.walleij@linaro.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:57797 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbBYPcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:32:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smc91x driver traditionally gets configured at compile-time
for whichever hardware it runs on. This no longer works on
ARM as we continue to move to building all-in-one kernels.

Most ARM configurations with this driver already use run-time
configuration through DT or through platform_data, but a
few have not been converted yet.

I've checked all ARM boards that use this driver in their
legacy board files, and converted the ones that were using
compile-time configuration in smc91x.h to behave like the
other ones and provide the interrupt polarity along with
the MMIO configuration (width, stride) at platform device
creation time.

In particular, these combinations were previously selectable
in Kconfig but in fact broken:

- sa1100 assabet plus pleb
- msm combined with any other armv6/v7 platform
- pxa-idp combined with any non-DMA pxa variant
- LogicPD PXA270 combined with any other pxa
- nomadik combined with any other armv4/v5 platform,
  e.g. versatile.

None of these seem critical enough to warrant a backport
to stable, but it would be nice to clean this up for good.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
----
I would like the patch to get merged through netdev, after
Robert and/or Linus have verified it on at least some hardware.

There are a few other non-ARM platforms using this driver,
I could do the same patch for those if we want to take
it further.

 arch/arm/mach-msm/board-halibut.c    |   8 ++++-
 arch/arm/mach-msm/board-qsd8x50.c    |   8 ++++-
 arch/arm/mach-pxa/idp.c              |   5 +++
 arch/arm/mach-pxa/lpd270.c           |   8 ++++-
 arch/arm/mach-realview/core.c        |   7 ++++
 arch/arm/mach-realview/realview_eb.c |   2 +-
 arch/arm/mach-sa1100/neponset.c      |   6 ++++
 arch/arm/mach-sa1100/pleb.c          |   7 ++++
 drivers/net/ethernet/smsc/smc91x.c   |   9 +++--
 drivers/net/ethernet/smsc/smc91x.h   | 114 ++----------------------------------------------------------
 10 files changed, 57 insertions(+), 117 deletions(-)

diff --git a/arch/arm/mach-msm/board-halibut.c b/arch/arm/mach-msm/board-halibut.c
index 61bfe584a9d7..fc832040c6e9 100644
--- a/arch/arm/mach-msm/board-halibut.c
+++ b/arch/arm/mach-msm/board-halibut.c
@@ -20,6 +20,7 @@
 #include <linux/input.h>
 #include <linux/io.h>
 #include <linux/delay.h>
+#include <linux/smc91x.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -46,15 +47,20 @@ static struct resource smc91x_resources[] = {
 	[1] = {
 		.start	= MSM_GPIO_TO_INT(49),
 		.end	= MSM_GPIO_TO_INT(49),
-		.flags	= IORESOURCE_IRQ,
+		.flags	= IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
 	},
 };
 
+static struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev.platform_data = &smc91x_platdata,
 };
 
 static struct platform_device *devices[] __initdata = {
diff --git a/arch/arm/mach-msm/board-qsd8x50.c b/arch/arm/mach-msm/board-qsd8x50.c
index 4c748616ef47..10016a3bc698 100644
--- a/arch/arm/mach-msm/board-qsd8x50.c
+++ b/arch/arm/mach-msm/board-qsd8x50.c
@@ -22,6 +22,7 @@
 #include <linux/usb/msm_hsusb.h>
 #include <linux/err.h>
 #include <linux/clkdev.h>
+#include <linux/smc91x.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -49,15 +50,20 @@ static struct resource smc91x_resources[] = {
 		.flags = IORESOURCE_MEM,
 	},
 	[1] = {
-		.flags = IORESOURCE_IRQ,
+		.flags	= IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
 	},
 };
 
+static struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT,
+};
+
 static struct platform_device smc91x_device = {
 	.name           = "smc91x",
 	.id             = 0,
 	.num_resources  = ARRAY_SIZE(smc91x_resources),
 	.resource       = smc91x_resources,
+	.dev.platform_data = &smc91x_platdata,
 };
 
 static int __init msm_init_smc91x(void)
diff --git a/arch/arm/mach-pxa/idp.c b/arch/arm/mach-pxa/idp.c
index 343c4e3a7c5d..7d8eab857a93 100644
--- a/arch/arm/mach-pxa/idp.c
+++ b/arch/arm/mach-pxa/idp.c
@@ -81,11 +81,16 @@ static struct resource smc91x_resources[] = {
 	}
 };
 
+static struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_32BIT | SMC91X_USE_DMA | SMC91X_NOWAIT,
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev.platform_data = &smc91x_platdata,
 };
 
 static void idp_backlight_power(int on)
diff --git a/arch/arm/mach-pxa/lpd270.c b/arch/arm/mach-pxa/lpd270.c
index ad777b353bd5..28da319d389f 100644
--- a/arch/arm/mach-pxa/lpd270.c
+++ b/arch/arm/mach-pxa/lpd270.c
@@ -24,6 +24,7 @@
 #include <linux/mtd/mtd.h>
 #include <linux/mtd/partitions.h>
 #include <linux/pwm_backlight.h>
+#include <linux/smc91x.h>
 
 #include <asm/types.h>
 #include <asm/setup.h>
@@ -189,15 +190,20 @@ static struct resource smc91x_resources[] = {
 	[1] = {
 		.start	= LPD270_ETHERNET_IRQ,
 		.end	= LPD270_ETHERNET_IRQ,
-		.flags	= IORESOURCE_IRQ,
+		.flags	= IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE,
 	},
 };
 
+struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT;
+};
+
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev.platform_data = &smc91x_platdata,
 };
 
 static struct resource lpd270_flash_resources[] = {
diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index 850e506926df..c309593abdb2 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -28,6 +28,7 @@
 #include <linux/platform_data/video-clcd-versatile.h>
 #include <linux/io.h>
 #include <linux/smsc911x.h>
+#include <linux/smc91x.h>
 #include <linux/ata_platform.h>
 #include <linux/amba/mmci.h>
 #include <linux/gfp.h>
@@ -94,6 +95,10 @@ static struct smsc911x_platform_config smsc911x_config = {
 	.phy_interface	= PHY_INTERFACE_MODE_MII,
 };
 
+static struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_32BIT | SMC91X_NOWAIT,
+};
+
 static struct platform_device realview_eth_device = {
 	.name		= "smsc911x",
 	.id		= 0,
@@ -107,6 +112,8 @@ int realview_eth_register(const char *name, struct resource *res)
 	realview_eth_device.resource = res;
 	if (strcmp(realview_eth_device.name, "smsc911x") == 0)
 		realview_eth_device.dev.platform_data = &smsc911x_config;
+	else
+		realview_eth_device.dev.platform_data = &smc91x_platdata;
 
 	return platform_device_register(&realview_eth_device);
 }
diff --git a/arch/arm/mach-realview/realview_eb.c b/arch/arm/mach-realview/realview_eb.c
index 64c88d657f9e..b3869cbbcc68 100644
--- a/arch/arm/mach-realview/realview_eb.c
+++ b/arch/arm/mach-realview/realview_eb.c
@@ -234,7 +234,7 @@ static struct resource realview_eb_eth_resources[] = {
 	[1] = {
 		.start		= IRQ_EB_ETH,
 		.end		= IRQ_EB_ETH,
-		.flags		= IORESOURCE_IRQ,
+		.flags		= IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHEDGE,
 	},
 };
 
diff --git a/arch/arm/mach-sa1100/neponset.c b/arch/arm/mach-sa1100/neponset.c
index 169262e3040d..7b0cd3172354 100644
--- a/arch/arm/mach-sa1100/neponset.c
+++ b/arch/arm/mach-sa1100/neponset.c
@@ -12,6 +12,7 @@
 #include <linux/pm.h>
 #include <linux/serial_core.h>
 #include <linux/slab.h>
+#include <linux/smc91x.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/map.h>
@@ -258,12 +259,17 @@ static int neponset_probe(struct platform_device *dev)
 			0x02000000, "smc91x-attrib"),
 		{ .flags = IORESOURCE_IRQ },
 	};
+	struct smc91x_platdata smc91x_platdata = {
+		.flags = SMC91X_USE_8BIT | SMC91X_IO_SHIFT_2 | SMC91X_NOWAIT,
+	};
 	struct platform_device_info smc91x_devinfo = {
 		.parent = &dev->dev,
 		.name = "smc91x",
 		.id = 0,
 		.res = smc91x_resources,
 		.num_res = ARRAY_SIZE(smc91x_resources),
+		.data = &smc91c_platdata,
+		.size_data = sizeof(smc91c_platdata),
 	};
 	int ret, irq;
 
diff --git a/arch/arm/mach-sa1100/pleb.c b/arch/arm/mach-sa1100/pleb.c
index 091261878eff..696fd0fe4806 100644
--- a/arch/arm/mach-sa1100/pleb.c
+++ b/arch/arm/mach-sa1100/pleb.c
@@ -11,6 +11,7 @@
 #include <linux/irq.h>
 #include <linux/io.h>
 #include <linux/mtd/partitions.h>
+#include <linux/smc91x.h>
 
 #include <mach/hardware.h>
 #include <asm/setup.h>
@@ -43,12 +44,18 @@ static struct resource smc91x_resources[] = {
 #endif
 };
 
+static struct smc91x_platdata smc91x_platdata = {
+	.flags = SMC91X_USE_16BIT | SMC91X_NOWAIT,
+};
 
 static struct platform_device smc91x_device = {
 	.name		= "smc91x",
 	.id		= 0,
 	.num_resources	= ARRAY_SIZE(smc91x_resources),
 	.resource	= smc91x_resources,
+	.dev = {
+		.platform_data  = &smc91c_platdata,
+	},
 };
 
 static struct platform_device *devices[] __initdata = {
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index fa3f193b5f4d..f4700d4c9c77 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -91,6 +91,10 @@ static const char version[] =
 
 #include "smc91x.h"
 
+#if defined(CONFIG_ASSABET_NEPONSET)
+#include <mach/neponset.h>
+#endif
+
 #ifndef SMC_NOWAIT
 # define SMC_NOWAIT		0
 #endif
@@ -2355,8 +2359,9 @@ static int smc_drv_probe(struct platform_device *pdev)
 	ret = smc_request_attrib(pdev, ndev);
 	if (ret)
 		goto out_release_io;
-#if defined(CONFIG_ASSABET_NEPONSET) && !defined(CONFIG_SA1100_PLEB)
-	neponset_ncr_set(NCR_ENET_OSC_EN);
+#if defined(CONFIG_ASSABET_NEPONSET)
+	if (machine_is_assabet() && machine_has_neponset())
+		neponset_ncr_set(NCR_ENET_OSC_EN);
 #endif
 	platform_set_drvdata(pdev, ndev);
 	ret = smc_enable_device(pdev);
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index be67baf5f677..3a18501d1068 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -39,14 +39,7 @@
  * Define your architecture specific bus configuration parameters here.
  */
 
-#if defined(CONFIG_ARCH_LUBBOCK) ||\
-    defined(CONFIG_MACH_MAINSTONE) ||\
-    defined(CONFIG_MACH_ZYLONITE) ||\
-    defined(CONFIG_MACH_LITTLETON) ||\
-    defined(CONFIG_MACH_ZYLONITE2) ||\
-    defined(CONFIG_ARCH_VIPER) ||\
-    defined(CONFIG_MACH_STARGATE2) ||\
-    defined(CONFIG_ARCH_VERSATILE)
+#if defined(CONFIG_ARM)
 
 #include <asm/mach-types.h>
 
@@ -74,95 +67,8 @@
 /* We actually can't write halfwords properly if not word aligned */
 static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 {
-	if ((machine_is_mainstone() || machine_is_stargate2()) && reg & 2) {
-		unsigned int v = val << 16;
-		v |= readl(ioaddr + (reg & ~2)) & 0xffff;
-		writel(v, ioaddr + (reg & ~2));
-	} else {
-		writew(val, ioaddr + reg);
-	}
-}
-
-#elif defined(CONFIG_SA1100_PLEB)
-/* We can only do 16-bit reads and writes in the static memory space. */
-#define SMC_CAN_USE_8BIT	1
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
-#define SMC_NOWAIT		1
-
-#define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_insb(a, r, p, l)	readsb((a) + (r), p, (l))
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
-#define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, (l))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-
-#define SMC_IRQ_FLAGS		(-1)
-
-#elif defined(CONFIG_SA1100_ASSABET)
-
-#include <mach/neponset.h>
-
-/* We can only do 8-bit reads and writes in the static memory space. */
-#define SMC_CAN_USE_8BIT	1
-#define SMC_CAN_USE_16BIT	0
-#define SMC_CAN_USE_32BIT	0
-#define SMC_NOWAIT		1
-
-/* The first two address lines aren't connected... */
-#define SMC_IO_SHIFT		2
-
-#define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
-#define SMC_insb(a, r, p, l)	readsb((a) + (r), p, (l))
-#define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, (l))
-#define SMC_IRQ_FLAGS		(-1)	/* from resource */
-
-#elif	defined(CONFIG_MACH_LOGICPD_PXA270) ||	\
-	defined(CONFIG_MACH_NOMADIK_8815NHK)
-
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-#define SMC_IO_SHIFT		0
-#define SMC_NOWAIT		1
-
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-
-#elif	defined(CONFIG_ARCH_INNOKOM) || \
-	defined(CONFIG_ARCH_PXA_IDP) || \
-	defined(CONFIG_ARCH_RAMSES) || \
-	defined(CONFIG_ARCH_PCM027)
-
-#define SMC_CAN_USE_8BIT	1
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	1
-#define SMC_IO_SHIFT		0
-#define SMC_NOWAIT		1
-#define SMC_USE_PXA_DMA		1
-
-#define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_inl(a, r)		readl((a) + (r))
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
-#define SMC_outl(v, a, r)	writel(v, (a) + (r))
-#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
-#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-#define SMC_IRQ_FLAGS		(-1)	/* from resource */
-
-/* We actually can't write halfwords properly if not word aligned */
-static inline void
-SMC_outw(u16 val, void __iomem *ioaddr, int reg)
-{
-	if (reg & 2) {
+	if ((machine_is_mainstone() || machine_is_stargate2() ||
+	     machine_is_pxa_idp()) && reg & 2) {
 		unsigned int v = val << 16;
 		v |= readl(ioaddr + (reg & ~2)) & 0xffff;
 		writel(v, ioaddr + (reg & ~2));
@@ -237,20 +143,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define RPC_LSA_DEFAULT         RPC_LED_100_10
 #define RPC_LSB_DEFAULT         RPC_LED_TX_RX
 
-#elif defined(CONFIG_ARCH_MSM)
-
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-#define SMC_NOWAIT		1
-
-#define SMC_inw(a, r)		readw((a) + (r))
-#define SMC_outw(v, a, r)	writew(v, (a) + (r))
-#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-
-#define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
-
 #elif defined(CONFIG_COLDFIRE)
 
 #define SMC_CAN_USE_8BIT	0
