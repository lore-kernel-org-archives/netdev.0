From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 1/5] ne: Add platform_driver
Date: Tue, 01 May 2007 00:27:31 +0900 (JST)
Message-ID: <20070501.002731.104031408.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:54107 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423360AbXD3P13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a platform_driver interface to ne driver.
(Existing legacy ports did not covered by this ne_driver for now)

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/ne.c |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index a5c4199..aef470d 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -51,6 +51,7 @@ static const char version2[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jiffies.h>
+#include <linux/platform_device.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -807,6 +808,87 @@ retry:
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
+#else
+#define ne_drv_suspend NULL
+#define ne_drv_resume NULL
+#endif
+
+static struct platform_driver ne_driver = {
+	.remove		= __exit_p(ne_drv_remove),
+	.suspend	= ne_drv_suspend,
+	.resume		= ne_drv_resume,
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
