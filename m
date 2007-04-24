From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/3] ne: Add platform_driver
Date: Wed, 25 Apr 2007 01:54:50 +0900 (JST)
Message-ID: <20070425.015450.25909765.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Currently ne.c has some codes to support RBTX49XX boards but it is not
complete.  Instead of adding more hacks to fix it, this patch add an
generic platform_driver interface to the driver and let RBTX49XX use
it.  This is a first step.

* Add platform_driver interface to ne driver.
  (Existing legacy ports did not covered by this ne_driver for now)
* Make ioaddr 'unsigned long'.
* Move a printk down to show dev->name assigned in register_netdev.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/ne.c |  103 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 95 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index a5c4199..b8a181f 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -51,6 +51,7 @@ static const char version2[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jiffies.h>
+#include <linux/platform_device.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -146,7 +147,7 @@ bad_clone_list[] __initdata = {
 #  define DCR_VAL 0x49
 #endif
 
-static int ne_probe1(struct net_device *dev, int ioaddr);
+static int ne_probe1(struct net_device *dev, unsigned long ioaddr);
 static int ne_probe_isapnp(struct net_device *dev);
 
 static int ne_open(struct net_device *dev);
@@ -184,7 +185,7 @@ static void ne_block_output(struct net_device *dev, const int count,
 
 static int __init do_ne_probe(struct net_device *dev)
 {
-	unsigned int base_addr = dev->base_addr;
+	unsigned long base_addr = dev->base_addr;
 #ifndef MODULE
 	int orig_irq = dev->irq;
 #endif
@@ -285,7 +286,7 @@ static int __init ne_probe_isapnp(struct net_device *dev)
 	return -ENODEV;
 }
 
-static int __init ne_probe1(struct net_device *dev, int ioaddr)
+static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 {
 	int i;
 	unsigned char SA_prom[32];
@@ -324,7 +325,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(KERN_INFO "%s" KERN_INFO "%s", version1, version2);
 
-	printk(KERN_INFO "NE*000 ethercard probe at %#3x:", ioaddr);
+	printk(KERN_INFO "NE*000 ethercard probe at %#3lx:", ioaddr);
 
 	/* A user with a poor card that fails to ack the reset, or that
 	   does not have a valid 0x57,0x57 signature can still use this
@@ -516,8 +517,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	}
 #endif
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
-		dev->name, name, ioaddr, dev->irq);
+	printk("\n");
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -547,6 +547,8 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	ret = register_netdev(dev);
 	if (ret)
 		goto out_irq;
+	printk(KERN_INFO "%s: %s found at %#lx, using IRQ %d.\n",
+	       dev->name, name, ioaddr, dev->irq);
 	return 0;
 
 out_irq:
@@ -807,6 +809,86 @@ retry:
 	return;
 }
 
+static int __init ne_drv_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct resource *res;
+	int err, irq;
+
+	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	irq = platform_get_irq(pdev, 0);
+	if (!res || irq < 0)
+		return -ENODEV;
+
+	dev = alloc_ei_netdev();
+	if (!dev)
+		return -ENOMEM;
+	dev->irq = irq;
+	dev->base_addr = res->start;
+	err = do_ne_probe(dev);
+	if (err) {
+		free_netdev(dev);
+		return err;
+	}
+	platform_set_drvdata(pdev, dev);
+	return 0;
+}
+
+static int __exit ne_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, NE_IO_EXTENT);
+	free_netdev(dev);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		netif_device_detach(dev);
+	return 0;
+}
+
+static int ne_drv_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev)) {
+		ne_reset_8390(dev);
+		NS8390_init(dev, 1);
+		netif_device_attach(dev);
+	}
+	return 0;
+}
+#endif
+
+static struct platform_driver ne_driver = {
+	.remove		= __exit_p(ne_drv_remove),
+#ifdef CONFIG_PM
+	.suspend	= ne_drv_suspend,
+	.resume		= ne_drv_resume,
+#endif
+	.driver		= {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init ne_init(void)
+{
+	return platform_driver_probe(&ne_driver, ne_drv_probe);
+}
+
+static void __exit ne_exit(void)
+{
+	platform_driver_unregister(&ne_driver);
+}
 
 #ifdef MODULE
 #define MAX_NE_CARDS	4	/* Max number of NE cards per module */
@@ -832,6 +914,7 @@ ISA device autoprobes on a running machine are not recommended anyway. */
 int __init init_module(void)
 {
 	int this_dev, found = 0;
+	int plat_found = !ne_init();
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
 		struct net_device *dev = alloc_ei_netdev();
@@ -845,7 +928,7 @@ int __init init_module(void)
 			continue;
 		}
 		free_netdev(dev);
-		if (found)
+		if (found || plat_found)
 			break;
 		if (io[this_dev] != 0)
 			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
@@ -853,7 +936,7 @@ int __init init_module(void)
 			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
 		return -ENXIO;
 	}
-	if (found)
+	if (found || plat_found)
 		return 0;
 	return -ENODEV;
 }
@@ -871,6 +954,7 @@ void __exit cleanup_module(void)
 {
 	int this_dev;
 
+	ne_exit();
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
 		struct net_device *dev = dev_ne[this_dev];
 		if (dev) {
@@ -880,4 +964,7 @@ void __exit cleanup_module(void)
 		}
 	}
 }
+#else /* MODULE */
+module_init(ne_init);
+module_exit(ne_exit);
 #endif /* MODULE */
