From: David Fries <david@fries.net>
Subject: [PATCH 1/2] [PATCH] ne.c fix rmmod, platform driver improvements
Date: Mon, 8 Sep 2008 21:58:21 -0500
Message-ID: <20080909025821.GA25019@spacedout.fries.net>
References: <20080909025434.GB28469@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Paul Gortmaker <p_gortmaker@yahoo.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:40085 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbYIIDAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 23:00:45 -0400
Content-Disposition: inline
In-Reply-To: <20080909025434.GB28469@spacedout.fries.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Fries <david@fries.net>

Removing the module would cause a kernel oops as platform_driver_probe
failed to detect a device and unregistered the platform driver on
module init, and cleanup_module would unregister the already
unregistered driver.  The suspend and resume functions weren't being
called.

platform_driver support was added earlier, but without any
platform_device_register* calls I don't think it was being used.  Now
all devices are registered using platform_device_register_simple and
pointers are kept to unregister the ones that the probe failed for or
unregister all devices on module shutdown.  init_module no longer
calls ne_init to reduce confusion (and multiple unregister paths that
caused the rmmod oops).  With the devices now registered they are
added to the platform driver and get suspend and resume events.

netif_device_detach(dev) was added before unregister_netdev(dev) when
removing the region as occationally I would see a race condition where
the device was still being used in unregister_netdev.

Signed-off-by: David Fries <david@fries.net>
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>
---
 drivers/net/ne.c |  255 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 146 insertions(+), 109 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 42443d6..2bece66 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -64,6 +64,25 @@ static const char version2[] =
 
 /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
 #define SUPPORT_NE_BAD_CLONES
+/* 0xbad = bad sig or no reset ack */
+#define BAD 0xbad
+
+#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
+static struct platform_device *pdev_ne[MAX_NE_CARDS];
+static int io[MAX_NE_CARDS];
+static int irq[MAX_NE_CARDS];
+static int bad[MAX_NE_CARDS];
+
+#ifdef MODULE
+module_param_array(io, int, NULL, 0);
+module_param_array(irq, int, NULL, 0);
+module_param_array(bad, int, NULL, 0);
+MODULE_PARM_DESC(io, "I/O base address(es),required");
+MODULE_PARM_DESC(irq, "IRQ number(s)");
+MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
+MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
+MODULE_LICENSE("GPL");
+#endif /* MODULE */
 
 /* Do we perform extra sanity checks on stuff ? */
 /* #define NE_SANITY_CHECK */
@@ -74,6 +93,10 @@ static const char version2[] =
 /* Do we have a non std. amount of memory? (in units of 256 byte pages) */
 /* #define PACKETBUF_MEMSIZE	0x40 */
 
+/* This is set up so that no ISA autoprobe takes place. We can't guarantee
+that the ne2k probe is the last 8390 based probe to take place (as it
+is at boot) and so the probe will get confused by any other 8390 cards.
+ISA device autoprobes on a running machine are not recommended anyway. */
 #if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
 /* Do we need a portlist for the ISA auto-probe ? */
 #define NEEDS_PORTLIST
@@ -192,8 +215,13 @@ static int __init do_ne_probe(struct net_device *dev)
 #endif
 
 	/* First check any supplied i/o locations. User knows best. <cough> */
-	if (base_addr > 0x1ff)	/* Check a single specified location. */
-		return ne_probe1(dev, base_addr);
+	if (base_addr > 0x1ff) {	/* Check a single specified location. */
+		int ret = ne_probe1(dev, base_addr);
+		if (ret)
+			printk(KERN_WARNING "ne.c: No NE*000 card found at "
+				"i/o = %#lx\n", base_addr);
+		return ret;
+	}
 	else if (base_addr != 0)	/* Don't probe at all. */
 		return -ENXIO;
 
@@ -214,28 +242,6 @@ static int __init do_ne_probe(struct net_device *dev)
 	return -ENODEV;
 }
 
-#ifndef MODULE
-struct net_device * __init ne_probe(int unit)
-{
-	struct net_device *dev = alloc_eip_netdev();
-	int err;
-
-	if (!dev)
-		return ERR_PTR(-ENOMEM);
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-
-	err = do_ne_probe(dev);
-	if (err)
-		goto out;
-	return dev;
-out:
-	free_netdev(dev);
-	return ERR_PTR(err);
-}
-#endif
-
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
 	int i;
@@ -329,7 +335,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	   with an otherwise unused dev->mem_end value of "0xBAD" will
 	   cause the driver to skip these parts of the probe. */
 
-	bad_card = ((dev->base_addr != 0) && (dev->mem_end == 0xbad));
+	bad_card = ((dev->base_addr != 0) && (dev->mem_end == BAD));
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
 
@@ -806,39 +812,65 @@ retry:
 static int __init ne_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
-	struct resource *res;
-	int err, irq;
-
-	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
-	irq = platform_get_irq(pdev, 0);
-	if (!res || irq < 0)
-		return -ENODEV;
+	int err, this_dev = pdev->id;
 
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
-	dev->irq = irq;
-	dev->base_addr = res->start;
+	dev->base_addr = io[this_dev];
+	dev->irq = irq[this_dev];
+	dev->mem_end = bad[this_dev];
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
 		return err;
 	}
 	platform_set_drvdata(pdev, dev);
+	/* Update with any values found by probing. */
+	io[this_dev] = dev->base_addr;
+	irq[this_dev] = dev->irq;
 	return 0;
 }
 
-static int __exit ne_drv_remove(struct platform_device *pdev)
+static int ne_drv_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, NE_IO_EXTENT);
-	free_netdev(dev);
+	if (dev) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		netif_device_detach(dev);
+		unregister_netdev(dev);
+		if (idev)
+			pnp_device_detach(idev);
+		/* Careful ne_drv_remove can be called twice, once from
+		 * the platform_driver.remove and again when the
+		 * platform_device is being removed.
+		 */
+		ei_status.priv = 0;
+		free_irq(dev->irq, dev);
+		release_region(dev->base_addr, NE_IO_EXTENT);
+		free_netdev(dev);
+		platform_set_drvdata(pdev, NULL);
+	}
 	return 0;
 }
 
+/* Remove unused devices or all if true. */
+static void ne_loop_rm_unreg(int all)
+{
+	int this_dev;
+	struct platform_device *pdev;
+	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
+		pdev = pdev_ne[this_dev];
+		/* No network device == unused */
+		if (pdev && (!platform_get_drvdata(pdev) || all)) {
+			ne_drv_remove(pdev);
+			platform_device_unregister(pdev);
+			pdev_ne[this_dev] = NULL;
+		}
+	}
+}
+
 #ifdef CONFIG_PM
 static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
 {
@@ -866,7 +898,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 #endif
 
 static struct platform_driver ne_driver = {
-	.remove		= __exit_p(ne_drv_remove),
+	.remove		= ne_drv_remove,
 	.suspend	= ne_drv_suspend,
 	.resume		= ne_drv_resume,
 	.driver		= {
@@ -875,91 +907,96 @@ static struct platform_driver ne_driver = {
 	},
 };
 
-static int __init ne_init(void)
+static void __init ne_add_devices(void)
 {
-	return platform_driver_probe(&ne_driver, ne_drv_probe);
-}
+	int this_dev;
+	struct platform_device *pdev;
 
-static void __exit ne_exit(void)
-{
-	platform_driver_unregister(&ne_driver);
+	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
+		if (pdev_ne[this_dev])
+			continue;
+		pdev = platform_device_register_simple(
+			DRV_NAME, this_dev, NULL, 0);
+		if (IS_ERR(pdev))
+			continue;
+		pdev_ne[this_dev] = pdev;
+	}
 }
 
 #ifdef MODULE
-#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct net_device *dev_ne[MAX_NE_CARDS];
-static int io[MAX_NE_CARDS];
-static int irq[MAX_NE_CARDS];
-static int bad[MAX_NE_CARDS];	/* 0xbad = bad sig or no reset ack */
-
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
-module_param_array(bad, int, NULL, 0);
-MODULE_PARM_DESC(io, "I/O base address(es),required");
-MODULE_PARM_DESC(irq, "IRQ number(s)");
-MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
-MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
-MODULE_LICENSE("GPL");
-
-/* This is set up so that no ISA autoprobe takes place. We can't guarantee
-that the ne2k probe is the last 8390 based probe to take place (as it
-is at boot) and so the probe will get confused by any other 8390 cards.
-ISA device autoprobes on a running machine are not recommended anyway. */
-
-int __init init_module(void)
+int __init init_module()
 {
-	int this_dev, found = 0;
-	int plat_found = !ne_init();
-
-	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_eip_netdev();
-		if (!dev)
-			break;
-		dev->irq = irq[this_dev];
-		dev->mem_end = bad[this_dev];
-		dev->base_addr = io[this_dev];
-		if (do_ne_probe(dev) == 0) {
-			dev_ne[found++] = dev;
-			continue;
-		}
-		free_netdev(dev);
-		if (found || plat_found)
-			break;
-		if (io[this_dev] != 0)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
-		else
-			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
-		return -ENXIO;
+	int retval;
+	ne_add_devices();
+	retval = platform_driver_probe(&ne_driver, ne_drv_probe);
+	if (retval) {
+		if (io[0] == 0)
+			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\""
+				" value(s) for ISA cards.\n");
+		ne_loop_rm_unreg(1);
+		return retval;
 	}
-	if (found || plat_found)
-		return 0;
-	return -ENODEV;
-}
 
-static void cleanup_card(struct net_device *dev)
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
+	return retval;
+}
+#else /* MODULE */
+static int __init ne_init(void)
 {
-	struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
-	if (idev)
-		pnp_device_detach(idev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, NE_IO_EXTENT);
+	int retval = platform_driver_probe(&ne_driver, ne_drv_probe);
+
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
+	return retval;
 }
+module_init(ne_init);
 
-void __exit cleanup_module(void)
+struct net_device * __init ne_probe(int unit)
 {
 	int this_dev;
+	struct net_device *dev;
+
+	/* Find an empty slot, that is no net_device and zero io port. */
+	this_dev = 0;
+	while ((pdev_ne[this_dev] && platform_get_drvdata(pdev_ne[this_dev])) ||
+		io[this_dev]) {
+		if (++this_dev == MAX_NE_CARDS)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	/* Get irq, io from kernel command line */
+	dev = alloc_eip_netdev();
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	sprintf(dev->name, "eth%d", unit);
+	netdev_boot_setup_check(dev);
 
-	ne_exit();
+	io[this_dev] = dev->base_addr;
+	irq[this_dev] = dev->irq;
+	bad[this_dev] = dev->mem_end;
+
+	free_netdev(dev);
+
+	ne_add_devices();
+
+	/* return the first device found */
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = dev_ne[this_dev];
-		if (dev) {
-			unregister_netdev(dev);
-			cleanup_card(dev);
-			free_netdev(dev);
+		if (pdev_ne[this_dev]) {
+			dev = platform_get_drvdata(pdev_ne[this_dev]);
+			if (dev)
+				return dev;
 		}
 	}
+
+	return ERR_PTR(-ENODEV);
 }
-#else /* MODULE */
-module_init(ne_init);
-module_exit(ne_exit);
 #endif /* MODULE */
+
+static void __exit ne_exit(void)
+{
+	platform_driver_unregister(&ne_driver);
+	ne_loop_rm_unreg(1);
+}
+module_exit(ne_exit);
-- 
1.4.4.4
