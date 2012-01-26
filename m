From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V5 1/4] CS89x0 : add platform driver support
Date: Thu, 26 Jan 2012 21:46:15 +0100
Message-ID: <1327610775-26893-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	s.hauer@pengutronix.de, davem@davemloft.net, cavokz@gmail.com,
	linux@arm.linux.org.uk, fabio.estevam@freescale.com,
	festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54582 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab2AZUqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:46:49 -0500
Received: by eekc14 with SMTP id c14so323460eek.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:46:47 -0800 (PST)
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
 drivers/net/Space.c                  |    2 +
 drivers/net/ethernet/cirrus/Kconfig  |   19 +++--
 drivers/net/ethernet/cirrus/cs89x0.c |  137 ++++++++++++++++++++++++++++++---
 3 files changed, 137 insertions(+), 21 deletions(-)

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 068c356..88bbd8f 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -190,8 +190,10 @@ static struct devprobe2 isa_probes[] __initdata = {
 	{seeq8005_probe, 0},
 #endif
 #ifdef CONFIG_CS89x0
+#ifndef CONFIG_CS89x0_PLATFORM
  	{cs89x0_probe, 0},
 #endif
+#endif
 #ifdef CONFIG_AT1700
 	{at1700_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 1f8648f..8388e36 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -5,8 +5,7 @@
 config NET_VENDOR_CIRRUS
 	bool "Cirrus devices"
 	default y
-	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
-		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX) || MAC
+	depends on ISA || EISA || ARM || MAC
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
index f328da2..6b3cd24 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -100,9 +100,6 @@
 
 */
 
-/* Always include 'config.h' first in case the user wants to turn on
-   or override something. */
-#include <linux/module.h>
 
 /*
  * Set this to zero to disable DMA code
@@ -131,9 +128,12 @@
 
 */
 
+#include <linux/module.h>
+#include <linux/printk.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/platform_device.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/fcntl.h>
@@ -151,6 +151,7 @@
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
+#include <linux/atomic.h>
 #if ALLOW_DMA
 #include <asm/dma.h>
 #endif
@@ -174,26 +175,32 @@ static char version[] __initdata =
    them to system IRQ numbers. This mapping is card specific and is set to
    the configuration of the Cirrus Eval board for this chip. */
 #if defined(CONFIG_MACH_IXDP2351)
+#define CS89x0_NONISA_IRQ
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_IXDP2X01)
+#define CS89x0_NONISA_IRQ
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #elif defined(CONFIG_MACH_QQ2440)
+#define CS89x0_NONISA_IRQ
 #include <mach/qq2440.h>
 static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
 static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 #elif defined(CONFIG_MACH_MX31ADS)
+#define CS89x0_NONISA_IRQ
 #include <mach/board-mx31ads.h>
 static unsigned int netcard_portlist[] __used __initdata = {
 	PBC_BASE_ADDRESS + PBC_CS8900A_IOBASE + 0x300, 0
 };
 static unsigned cs8900_irq_map[] = {EXPIO_INT_ENET_INT, 0, 0, 0};
 #else
+#ifndef CONFIG_CS89x0_PLATFORM
 static unsigned int netcard_portlist[] __used __initdata =
    { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
 static unsigned int cs8900_irq_map[] = {10,11,12,5};
 #endif
+#endif
 
 #if DEBUGGING
 static unsigned int net_debug = DEBUGGING;
@@ -236,11 +243,16 @@ struct net_local {
 	unsigned char *end_dma_buff;	/* points to the end of the buffer */
 	unsigned char *rx_dma_ptr;	/* points to the next packet  */
 #endif
+#ifdef CONFIG_CS89x0_PLATFORM
+	void __iomem *virt_addr;/* Virtual address for accessing the CS89x0. */
+	unsigned long phys_addr;/* Physical address for accessing the CS89x0. */
+	unsigned long size;	/* Length of CS89x0 memory region. */
+#endif
 };
 
 /* Index to functions, as function prototypes. */
 
-static int cs89x0_probe1(struct net_device *dev, int ioaddr, int modular);
+static int cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular);
 static int net_open(struct net_device *dev);
 static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
@@ -294,6 +306,7 @@ static int __init media_fn(char *str)
 __setup("cs89x0_media=", media_fn);
 
 
+#ifndef CONFIG_CS89x0_PLATFORM
 /* Check for a network adaptor of this type, and return '0' iff one exists.
    If dev->base_addr == 0, probe all likely locations.
    If dev->base_addr == 1, always return failure.
@@ -343,6 +356,7 @@ out:
 	return ERR_PTR(err);
 }
 #endif
+#endif
 
 #if defined(CONFIG_MACH_IXDP2351)
 static u16
@@ -504,7 +518,7 @@ static const struct net_device_ops net_ops = {
  */
 
 static int __init
-cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
+cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 {
 	struct net_local *lp = netdev_priv(dev);
 	static unsigned version_printed;
@@ -537,7 +551,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	/* WTF is going on here? */
 	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
-		printk(KERN_ERR "%s: request_region(0x%x, 0x%x) failed\n",
+		printk(KERN_ERR "%s: request_region(0x%lx, 0x%x) failed\n",
 				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
 		retval = -EBUSY;
 		goto out1;
@@ -549,7 +563,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	   will skip the test for the ADD_PORT. */
 	if (ioaddr & 1) {
 		if (net_debug > 1)
-			printk(KERN_INFO "%s: odd ioaddr 0x%x\n", dev->name, ioaddr);
+			printk(KERN_INFO "%s: odd ioaddr 0x%lx\n", dev->name, ioaddr);
 	        if ((ioaddr & 2) != 2)
 	        	if ((readword(ioaddr & ~3, ADD_PORT) & ADD_MASK) != ADD_SIG) {
 				printk(KERN_ERR "%s: bad signature 0x%x\n",
@@ -560,13 +574,13 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 	}
 
 	ioaddr &= ~3;
-	printk(KERN_DEBUG "PP_addr at %x[%x]: 0x%x\n",
+	printk(KERN_DEBUG "PP_addr at %lx[%x]: 0x%x\n",
 			ioaddr, ADD_PORT, readword(ioaddr, ADD_PORT));
 	writeword(ioaddr, ADD_PORT, PP_ChipID);
 
 	tmp = readword(ioaddr, DATA_PORT);
 	if (tmp != CHIP_EISA_ID_SIG) {
-		printk(KERN_DEBUG "%s: incorrect signature at %x[%x]: 0x%x!="
+		printk(KERN_DEBUG "%s: incorrect signature at %lx[%x]: 0x%x!="
 			CHIP_EISA_ID_SIG_STR "\n",
 			dev->name, ioaddr, DATA_PORT, tmp);
   		retval = -ENODEV;
@@ -736,8 +750,9 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 			dev->irq = i;
 	} else {
 		i = lp->isa_config & INT_NO_MASK;
+#ifndef CONFIG_CS89x0_PLATFORM
 		if (lp->chip_type == CS8900) {
-#ifdef CONFIG_CS89x0_NONISA_IRQ
+#ifdef CS89x0_NONISA_IRQ
 		        i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
@@ -758,6 +773,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 			}
 #endif
 		}
+#endif
 		if (!dev->irq)
 			dev->irq = i;
 	}
@@ -1168,6 +1184,7 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 	int i;
 
 	if (chip_type == CS8900) {
+#ifndef CONFIG_CS89x0_PLATFORM
 		/* Search the mapping table for the corresponding IRQ pin. */
 		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
 			if (cs8900_irq_map[i] == irq)
@@ -1175,6 +1192,10 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 		/* Not found */
 		if (i == ARRAY_SIZE(cs8900_irq_map))
 			i = 3;
+#else
+		/* INTRQ0 pin is used for interrupt generation. */
+		i = 0;
+#endif
 		writereg(dev, PP_CS8900_ISAINT, i);
 	} else {
 		writereg(dev, PP_CS8920_ISAINT, irq);
@@ -1228,7 +1249,7 @@ net_open(struct net_device *dev)
 	}
 	else
 	{
-#ifndef CONFIG_CS89x0_NONISA_IRQ
+#if !defined(CS89x0_NONISA_IRQ) && !defined(CONFIG_CS89x0_PLATFORM)
 		if (((1 << dev->irq) & lp->irq_map) == 0) {
 			printk(KERN_ERR "%s: IRQ %d is not in our map of allowable IRQs, which is %x\n",
                                dev->name, dev->irq, lp->irq_map);
@@ -1746,7 +1767,7 @@ static int set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-#ifdef MODULE
+#if defined(MODULE) && !defined(CONFIG_CS89x0_PLATFORM)
 
 static struct net_device *dev_cs89x0;
 
@@ -1900,7 +1921,97 @@ cleanup_module(void)
 	release_region(dev_cs89x0->base_addr, NETCARD_IO_EXTENT);
 	free_netdev(dev_cs89x0);
 }
-#endif /* MODULE */
+#endif /* MODULE && !CONFIG_CS89x0_PLATFORM */
+
+#ifdef CONFIG_CS89x0_PLATFORM
+static int __init cs89x0_platform_probe(struct platform_device *pdev)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct net_local));
+	struct net_local *lp;
+	struct resource *mem_res;
+	int err;
+
+	if (!dev)
+		return -ENOMEM;
+
+	lp = netdev_priv(dev);
+
+	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	dev->irq = platform_get_irq(pdev, 0);
+	if (mem_res == NULL || dev->irq <= 0) {
+		dev_warn(&dev->dev, "memory/interrupt resource missing.\n");
+		err = -ENXIO;
+		goto free;
+	}
+
+	lp->phys_addr = mem_res->start;
+	lp->size = resource_size(mem_res);
+	if (!request_mem_region(lp->phys_addr, lp->size, DRV_NAME)) {
+		dev_warn(&dev->dev, "request_mem_region() failed.\n");
+		err = -EBUSY;
+		goto free;
+	}
+
+	lp->virt_addr = ioremap(lp->phys_addr, lp->size);
+	if (!lp->virt_addr) {
+		dev_warn(&dev->dev, "ioremap() failed.\n");
+		err = -ENOMEM;
+		goto release;
+	}
+
+	err = cs89x0_probe1(dev, (unsigned long)lp->virt_addr, 0);
+	if (err) {
+		dev_warn(&dev->dev, "no cs8900 or cs8920 detected.\n");
+		goto unmap;
+	}
+
+	platform_set_drvdata(pdev, dev);
+	return 0;
+
+unmap:
+	iounmap(lp->virt_addr);
+release:
+	release_mem_region(lp->phys_addr, lp->size);
+free:
+	free_netdev(dev);
+	return err;
+}
+
+static int cs89x0_platform_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct net_local *lp = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	iounmap(lp->virt_addr);
+	release_mem_region(lp->phys_addr, lp->size);
+	free_netdev(dev);
+	return 0;
+}
+
+static struct platform_driver cs89x0_driver = {
+	.driver	= {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+	.remove	= cs89x0_platform_remove,
+};
+
+static int __init cs89x0_init(void)
+{
+	return platform_driver_probe(&cs89x0_driver, cs89x0_platform_probe);
+}
+
+module_init(cs89x0_init);
+
+static void __exit cs89x0_cleanup(void)
+{
+	platform_driver_unregister(&cs89x0_driver);
+}
+
+module_exit(cs89x0_cleanup);
+
+#endif /* CONFIG_CS89x0_PLATFORM */
 
 /*
  * Local variables:
-- 
1.7.1
