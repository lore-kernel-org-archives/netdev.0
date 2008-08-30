From: David Fries <david@fries.net>
Subject: [PATCH 1/2] ne.c fix for hibernate and rmmod oops fix
Date: Fri, 29 Aug 2008 21:44:25 -0500
Message-ID: <20080830024425.GA24929@spacedout.fries.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:37598 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbYH3Coc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 22:44:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing the module would cause a kernel oops as platform_driver_probe
failed to detect a device and unregistered the platform driver on
module init, and cleanup_module would unregister the already
unregistered driver.  The suspend and resume functions weren't being
called and the network card didn't function across a suspend to disk
followed by a power cycle.

platform_driver support was added earlier, but without any
platform_device_register* calls I don't think it was being used.  Now
all devices are registered using platform_device_register_simple and
pointers are kept to unregister the ones that the probe failed for or
unregister all devices on module shutdown.

With the devices now registered they are added to the platform driver
and get suspend and resume events.  A call to pnp_stop_dev and
pnp_start_dev now shutsdown and initializes plug and play devices.

netif_device_detach(dev) was added before unregister_netdev(dev) when
removing the region as occationally I would see a race condition where
the device was still being used in unregister_netdev.

Signed-off-by: David Fries <david@fries.net>
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>
---
 drivers/net/ne.c |  260 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 170 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 42443d6..b0bf47e 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -192,8 +192,13 @@ static int __init do_ne_probe(struct net_device *dev)
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
 
@@ -214,11 +219,48 @@ static int __init do_ne_probe(struct net_device *dev)
 	return -ENODEV;
 }
 
+#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
+static struct platform_device *pdev_ne[MAX_NE_CARDS];
+/* 0xbad = bad sig or no reset ack */
+#define BAD 0xbad
+#define BAD_STR "0xbad"
+
+#ifdef MODULE
+static int io[MAX_NE_CARDS];
+static int irq[MAX_NE_CARDS];
+static int bad[MAX_NE_CARDS];
+
+module_param_array(io, int, NULL, 0);
+module_param_array(irq, int, NULL, 0);
+module_param_array(bad, int, NULL, 0);
+MODULE_PARM_DESC(io, "I/O base address(es),required");
+MODULE_PARM_DESC(irq, "IRQ number(s)");
+MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
+MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
+MODULE_LICENSE("GPL");
+#endif /* MODULE */
+
 #ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
-	struct net_device *dev = alloc_eip_netdev();
-	int err;
+	struct net_device *dev;
+	struct platform_device *pdev;
+	struct resource r[2] = {
+		{
+			.name = "io_port",
+			.flags = IORESOURCE_IO},
+		{
+			.name = "irq",
+			.flags = IORESOURCE_IRQ} };
+	/* Find an empty slot. */
+	int this_dev = 0;
+	while (pdev_ne[this_dev]) {
+		if (++this_dev == MAX_NE_CARDS)
+			return ERR_PTR(-ENOMEM);
+	}
+
+	/* Get irq, io from kernel command line */
+	dev = alloc_eip_netdev();
 
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
@@ -226,13 +268,28 @@ struct net_device * __init ne_probe(int unit)
 	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
-	err = do_ne_probe(dev);
-	if (err)
-		goto out;
-	return dev;
-out:
+	r[0].start = dev->base_addr;
+	r[0].end = r[0].start+NE_IO_EXTENT-1;
+
+	if (dev->mem_end == BAD)
+		r[0].name = BAD_STR;
+
+	r[1].start = dev->irq;
+
 	free_netdev(dev);
-	return ERR_PTR(err);
+
+	pdev = platform_device_register_simple(
+		DRV_NAME, unit, r, ARRAY_SIZE(r));
+	if (IS_ERR(pdev))
+		return ERR_CAST(pdev);
+	pdev_ne[this_dev] = pdev;
+
+	/* Why is ne_probe being called before ne_init? */
+	dev = platform_get_drvdata(pdev);
+	if (!dev)
+		return ERR_PTR(-ENODEV);
+
+	return dev;
 }
 #endif
 
@@ -329,7 +386,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	   with an otherwise unused dev->mem_end value of "0xBAD" will
 	   cause the driver to skip these parts of the probe. */
 
-	bad_card = ((dev->base_addr != 0) && (dev->mem_end == 0xbad));
+	bad_card = ((dev->base_addr != 0) && (dev->mem_end == BAD));
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
 
@@ -472,7 +529,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 		outb_p(0x00, ioaddr + EN0_RCNTLO);
 		outb_p(0x00, ioaddr + EN0_RCNTHI);
 		outb_p(E8390_RREAD+E8390_START, ioaddr); /* Trigger it... */
-		mdelay(10);		/* wait 10ms for interrupt to propagate */
+		mdelay(10);	/* wait 10ms for interrupt to propagate */
 		outb_p(0x00, ioaddr + EN0_IMR); 		/* Mask it again. */
 		dev->irq = probe_irq_off(cookie);
 		if (ei_debug > 2)
@@ -807,18 +864,20 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct resource *res;
-	int err, irq;
+	int err, r_irq;
 
 	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
-	irq = platform_get_irq(pdev, 0);
-	if (!res || irq < 0)
+	r_irq = platform_get_irq(pdev, 0);
+	if (!res || r_irq < 0)
 		return -ENODEV;
 
 	dev = alloc_eip_netdev();
 	if (!dev)
 		return -ENOMEM;
-	dev->irq = irq;
+	dev->irq = r_irq;
 	dev->base_addr = res->start;
+	if (!strcmp(res->name, BAD_STR))
+		dev->mem_end = BAD;
 	err = do_ne_probe(dev);
 	if (err) {
 		free_netdev(dev);
@@ -828,24 +887,56 @@ static int __init ne_drv_probe(struct platform_device *pdev)
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
 	struct net_device *dev = platform_get_drvdata(pdev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
 		netif_device_detach(dev);
+		if (idev)
+			pnp_stop_dev(idev);
+	}
 	return 0;
 }
 
@@ -854,6 +945,9 @@ static int ne_drv_resume(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (netif_running(dev)) {
+		struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
+		if (idev)
+			pnp_start_dev(idev);
 		ne_reset_8390(dev);
 		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
@@ -866,7 +960,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 #endif
 
 static struct platform_driver ne_driver = {
-	.remove		= __exit_p(ne_drv_remove),
+	.remove		= ne_drv_remove,
 	.suspend	= ne_drv_suspend,
 	.resume		= ne_drv_resume,
 	.driver		= {
@@ -875,31 +969,7 @@ static struct platform_driver ne_driver = {
 	},
 };
 
-static int __init ne_init(void)
-{
-	return platform_driver_probe(&ne_driver, ne_drv_probe);
-}
-
-static void __exit ne_exit(void)
-{
-	platform_driver_unregister(&ne_driver);
-}
-
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
 
 /* This is set up so that no ISA autoprobe takes place. We can't guarantee
 that the ne2k probe is the last 8390 based probe to take place (as it
@@ -908,58 +978,68 @@ ISA device autoprobes on a running machine are not recommended anyway. */
 
 int __init init_module(void)
 {
-	int this_dev, found = 0;
-	int plat_found = !ne_init();
+	int retval;
+	int this_dev;
+	int probed_zero = 0;
+	struct platform_device *pdev;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = alloc_eip_netdev();
-		if (!dev)
-			break;
-		dev->irq = irq[this_dev];
-		dev->mem_end = bad[this_dev];
-		dev->base_addr = io[this_dev];
-		if (do_ne_probe(dev) == 0) {
-			dev_ne[found++] = dev;
-			continue;
+		struct resource r[2] = {
+			{
+				.start = io[this_dev],
+				.end = io[this_dev]+NE_IO_EXTENT-1,
+				.flags = IORESOURCE_IO},
+			{
+				.start = irq[this_dev],
+				.flags = IORESOURCE_IRQ} };
+		/* probe zero once */
+		if (io[this_dev] == 0) {
+			if (probed_zero)
+				continue;
+			probed_zero = 1;
 		}
-		free_netdev(dev);
-		if (found || plat_found)
-			break;
-		if (io[this_dev] != 0)
-			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
-		else
-			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
-		return -ENXIO;
+		if (bad[this_dev] == BAD)
+			r[0].name = BAD_STR;
+		pdev = platform_device_register_simple(
+			DRV_NAME, this_dev, r, ARRAY_SIZE(r));
+		if (IS_ERR(pdev))
+			continue;
+		pdev_ne[this_dev] = pdev;
 	}
-	if (found || plat_found)
-		return 0;
-	return -ENODEV;
-}
 
-static void cleanup_card(struct net_device *dev)
-{
-	struct pnp_dev *idev = (struct pnp_dev *)ei_status.priv;
-	if (idev)
-		pnp_device_detach(idev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, NE_IO_EXTENT);
+	/* Need to find out if any devices are found, if not the driver
+	 * has been unregistered, so re-register it for suspend and
+	 * resume notifications and because cleanup_module unregisters it.
+	 */
+	retval = platform_driver_probe(&ne_driver, ne_drv_probe);
+	if (retval) {
+		if (io[this_dev] == 0)
+			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\""
+				" value(s) for ISA cards.\n");
+		ne_loop_rm_unreg(1);
+		return retval;
+	}
+
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
+
+	return retval;
 }
+#endif /* MODULE */
 
 void __exit cleanup_module(void)
 {
-	int this_dev;
+	platform_driver_unregister(&ne_driver);
 
-	ne_exit();
-	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = dev_ne[this_dev];
-		if (dev) {
-			unregister_netdev(dev);
-			cleanup_card(dev);
-			free_netdev(dev);
-		}
-	}
+	ne_loop_rm_unreg(1);
+}
+
+#ifndef MODULE
+static int __init ne_init(void)
+{
+	return platform_driver_probe(&ne_driver, ne_drv_probe);
 }
-#else /* MODULE */
+
 module_init(ne_init);
-module_exit(ne_exit);
-#endif /* MODULE */
+module_exit(cleanup_module);
+#endif
-- 
1.4.4.4

