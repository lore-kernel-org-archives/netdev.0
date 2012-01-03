From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH 1/4] CS89x0 : add platform driver support
Date: Tue,  3 Jan 2012 23:12:09 +0100
Message-ID: <1325628732-14535-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, jaccon.bastiaansen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51206 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab2ACWMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:12:42 -0500
Received: by eekc4 with SMTP id c4so16247808eek.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 14:12:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CS89x0 ethernet controller is used on a number of evaluation
boards, such as the MX31ADS. The current driver has memory address and
IRQ settings for each board on which this controller is used. Driver
updates are therefore required to support other boards that also use
the CS89x0. To avoid these driver updates, a better mechanism
(platform driver support) is added to communicate the board dependent
settings to the driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/Space.c                  |    4 +
 drivers/net/ethernet/cirrus/Kconfig  |   19 +++---
 drivers/net/ethernet/cirrus/cs89x0.c |  112 ++++++++++++++++++++++++++++++----
 3 files changed, 115 insertions(+), 20 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 068c356..83897e2 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -190,8 +190,12 @@ static struct devprobe2 isa_probes[] __initdata = {
 	{seeq8005_probe, 0},
 #endif
 #ifdef CONFIG_CS89x0
+#if !defined(CONFIG_CS89x0_PLATFORM) || defined(CONFIG_MACH_IXDP2351) || \
+	defined(CONFIG_ARCH_IXDP2X01) || defined(CONFIG_MACH_QQ2440) ||  \
+	defined(CONFIG_MACH_MX31ADS)
  	{cs89x0_probe, 0},
 #endif
+#endif
 #ifdef CONFIG_AT1700
 	{at1700_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 1f8648f..3784b1b 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -5,8 +5,7 @@
 config NET_VENDOR_CIRRUS
 	bool "Cirrus devices"
 	default y
-	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
-		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX) || MAC
+	depends on ISA || EISA || ARM || (ARM && ARCH_EP93XX) || MAC
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -21,8 +20,7 @@ if NET_VENDOR_CIRRUS
 
 config CS89x0
 	tristate "CS89x0 support"
-	depends on (ISA || EISA || MACH_IXDP2351 \
-		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
+	depends on ISA || EISA || ARM
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards. If you have a
 	  network (Ethernet) card of this type, say Y and read the
@@ -33,10 +31,15 @@ config CS89x0
 	  To compile this driver as a module, choose M here. The module
 	  will be called cs89x0.
 
-config CS89x0_NONISA_IRQ
-	def_bool y
-	depends on CS89x0 != n
-	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
+config CS89x0_PLATFORM
+	bool "CS89x0 platform driver support"
+	depends on CS89x0
+	help
+	  Say Y to compile the cs89x0 driver as a platform driver. This
+	  makes this driver suitable for use on certain evaluation boards
+	  such as the iMX21ADS.
+
+	  If you are unsure, say N.
 
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index f328da2..903ef22 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -100,9 +100,6 @@
 
 */
 
-/* Always include 'config.h' first in case the user wants to turn on
-   or override something. */
-#include <linux/module.h>
 
 /*
  * Set this to zero to disable DMA code
@@ -131,9 +128,14 @@
 
 */
 
+#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/printk.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/platform_device.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
@@ -151,6 +153,9 @@
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
+#ifdef CONFIG_CS89x0_PLATFORM
+#include <linux/atomic.h>
+#endif
 #if ALLOW_DMA
 #include <asm/dma.h>
 #endif
@@ -173,6 +178,7 @@ static char version[] __initdata =
 /* The cs8900 has 4 IRQ pins, software selectable. cs8900_irq_map maps
    them to system IRQ numbers. This mapping is card specific and is set to
    the configuration of the Cirrus Eval board for this chip. */
+#if defined(CONFIG_CS89x0_PLATFORM)
 #if defined(CONFIG_MACH_IXDP2351)
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
@@ -188,7 +194,17 @@ static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 static unsigned int netcard_portlist[] __used __initdata = {
 	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
 };
-static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
+static unsigned int cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
+#else
+/*
+ * Counter for the number of CS89x0 platform device instances, which is needed
+ * because this driver currently supports only one CS89x0 platform device
+ * instance.
+ */
+static atomic_t platform_dev_cnt = ATOMIC_INIT(0);
+static unsigned int cs8900_irq_map[] = {0, 0, 0, 0};
+static unsigned int netcard_portlist[] __used __initdata = {0, 0};
+#endif
 #else
 static unsigned int netcard_portlist[] __used __initdata =
    { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
@@ -737,7 +753,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	} else {
 		i = lp->isa_config & INT_NO_MASK;
 		if (lp->chip_type == CS8900) {
-#ifdef CONFIG_CS89x0_NONISA_IRQ
+#ifdef CONFIG_CS89x0_PLATFORM
 		        i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
@@ -954,10 +970,10 @@ skip_this_frame:
 static void __init reset_chip(struct net_device *dev)
 {
 #if !defined(CONFIG_MACH_MX31ADS)
-#if !defined(CS89x0_NONISA_IRQ)
+#if !defined(CONFIG_CS89x0_PLATFORM)
 	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
-#endif /* CS89x0_NONISA_IRQ */
+#endif /* CONFIG_CS89x0_PLATFORM */
 	int reset_start_time;
 
 	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
@@ -965,7 +981,7 @@ static void __init reset_chip(struct net_device *dev)
 	/* wait 30 ms */
 	msleep(30);
 
-#if !defined(CS89x0_NONISA_IRQ)
+#if !defined(CONFIG_CS89x0_PLATFORM)
 	if (lp->chip_type != CS8900) {
 		/* Hardware problem requires PNP registers to be reconfigured after a reset */
 		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAINT);
@@ -976,7 +992,7 @@ static void __init reset_chip(struct net_device *dev)
 		outb((dev->mem_start >> 16) & 0xff, ioaddr + DATA_PORT);
 		outb((dev->mem_start >> 8) & 0xff,   ioaddr + DATA_PORT + 1);
 	}
-#endif /* CS89x0_NONISA_IRQ */
+#endif /* CONFIG_CS89x0_PLATFORM */
 
 	/* Wait until the chip is reset */
 	reset_start_time = jiffies;
@@ -1228,7 +1244,7 @@ net_open(struct net_device *dev)
 	}
 	else
 	{
-#ifndef CONFIG_CS89x0_NONISA_IRQ
+#ifndef CONFIG_CS89x0_PLATFORM
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
                                dev->name, dev->irq, lp->irq_map);
@@ -1746,7 +1762,7 @@ static int set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-#ifdef MODULE
+#if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)
 
 static struct net_device *dev_cs89x0;
 
@@ -1900,7 +1916,78 @@ cleanup_module(void)
 	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
 	free_netdev(dev_cs89x0);
 }
-#endif /* MODULE */
+#endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
+
+#ifdef CONFIG_CS89x0_PLATFORM
+static int cs89x0_platform_probe(struct platform_device *pdev)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	struct resource *mem_res;
+	struct resource *irq_res;
+	int err;
+
+	if (!dev)
+		return -ENODEV;
+
+	if (atomic_inc_return(&platform_dev_cnt) != 1)
+		return -EBUSY;
+
+	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (mem_res == NULL || irq_res == NULL) {
+		pr_warning("memory and/or interrupt resource missing.\n");
+		err = -ENOENT;
+		goto out;
+	}
+
+	cs8900_irq_map[0] = irq_res->start;
+	err = cs89x0_probe1(dev, mem_res->start, 0);
+	if (err) {
+		pr_warning("no cs8900 or cs8920 detected.\n");
+		goto out;
+	}
+
+	platform_set_drvdata(pdev, dev);
+	return 0;
+
+out:
+	free_netdev(dev);
+	return err;
+}
+
+static int cs89x0_platform_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_driver cs89x0_platform_driver = {
+	.driver = {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE
+	},
+	.probe	= cs89x0_platform_probe,
+	.remove	= cs89x0_platform_remove
+};
+
+static int __init cs89x0_init(void)
+{
+	return platform_driver_register(&cs89x0_platform_driver);
+}
+
+module_init(cs89x0_init);
+
+static void __exit cs89x0_cleanup(void)
+{
+	platform_driver_unregister(&cs89x0_platform_driver);
+}
+
+module_exit(cs89x0_cleanup);
+
+#endif /* CONFIG_CS89x0_PLATFORM */
 
 /*
  * Local variables:
@@ -1911,3 +1998,4 @@ cleanup_module(void)
  * End:
  *
  */
+
-- 
1.7.1
