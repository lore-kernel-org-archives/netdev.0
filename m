From: David Fries <david@fries.net>
Subject: Re: [PATCH] ne.c fix for hibernate and rmmod oops fix]
Date: Sun, 31 Aug 2008 15:47:56 -0500
Message-ID: <20080831204756.GA30598@spacedout.fries.net>
Reply-To: 20080830.235226.108118828.anemo@mba.ocn.ne.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SpacedOut.fries.net ([67.64.210.234]:60030 "EHLO
	SpacedOut.fries.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbYHaUr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 16:47:58 -0400
Received: from SpacedOut.fries.net (david@localhost [127.0.0.1])
	by SpacedOut.fries.net (8.13.8/8.13.8/Debian-3) with ESMTP id m7VKlvTY030612
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 31 Aug 2008 15:47:57 -0500
Received: (from david@localhost)
	by SpacedOut.fries.net (8.13.8/8.13.8/Submit) id m7VKlvx3030611
	for netdev@vger.kernel.org; Sun, 31 Aug 2008 15:47:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 30, 2008 at 11:52:26PM +0900, Atsushi Nemoto wrote:

This patch is the changes since [PATCH 1/2], if it looks good I'll
submit the git changeset next.

> The name "cleanup_module" is special.  I think this should not be used
> outside #ifdef MODULE.  Please rename it something like
> ne_cleanup_module() and make it static.  Or just use ne_exit().

I created ne_add_devices to register the platform devices now in one
place and ne_probe and init_module call it.

> Thanks.  You killed two .name and there are still two .name in ne_probe.

No more cleanup_module, just ne_exit.

I moved the BAD #define and module parameters up to the top of the
file, it's a better place for it.  ne_probe was moved down to the rest
of the module initialization code.

ne_init will now remove unused devices added by ne_probe.

-- 
David Fries <david@fries.net>
http://fries.net/~david/ (PGP encryption key available)


diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index ef4df0e..7980cf0 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -64,6 +64,27 @@ static const char version2[] =
 
 /* Do we support clones that don't adhere to 14,15 of the SAprom ? */
 #define SUPPORT_NE_BAD_CLONES
+/* 0xbad = bad sig or no reset ack */
+#define BAD 0xbad
+#define BAD_STR "0xbad"
+
+#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
+static struct platform_device *pdev_ne[MAX_NE_CARDS];
+
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
@@ -162,7 +183,6 @@ static void ne_block_input(struct net_device *dev, int count,
 static void ne_block_output(struct net_device *dev, const int count,
 		const unsigned char *buf, const int start_page);
 
-
 /*  Probe for various non-shared-memory ethercards.
 
    NEx000-clone boards have a Station Address PROM (SAPROM) in the packet
@@ -219,80 +239,6 @@ static int __init do_ne_probe(struct net_device *dev)
 	return -ENODEV;
 }
 
-#define MAX_NE_CARDS	4	/* Max number of NE cards per module */
-static struct platform_device *pdev_ne[MAX_NE_CARDS];
-/* 0xbad = bad sig or no reset ack */
-#define BAD 0xbad
-#define BAD_STR "0xbad"
-
-#ifdef MODULE
-static int io[MAX_NE_CARDS];
-static int irq[MAX_NE_CARDS];
-static int bad[MAX_NE_CARDS];
-
-module_param_array(io, int, NULL, 0);
-module_param_array(irq, int, NULL, 0);
-module_param_array(bad, int, NULL, 0);
-MODULE_PARM_DESC(io, "I/O base address(es),required");
-MODULE_PARM_DESC(irq, "IRQ number(s)");
-MODULE_PARM_DESC(bad, "Accept card(s) with bad signatures");
-MODULE_DESCRIPTION("NE1000/NE2000 ISA/PnP Ethernet driver");
-MODULE_LICENSE("GPL");
-#endif /* MODULE */
-
-#ifndef MODULE
-struct net_device * __init ne_probe(int unit)
-{
-	struct net_device *dev;
-	struct platform_device *pdev;
-	struct resource r[2] = {
-		{
-			.name = "io_port",
-			.flags = IORESOURCE_IO},
-		{
-			.name = "irq",
-			.flags = IORESOURCE_IRQ} };
-	/* Find an empty slot. */
-	int this_dev = 0;
-	while (pdev_ne[this_dev]) {
-		if (++this_dev == MAX_NE_CARDS)
-			return ERR_PTR(-ENOMEM);
-	}
-
-	/* Get irq, io from kernel command line */
-	dev = alloc_eip_netdev();
-
-	if (!dev)
-		return ERR_PTR(-ENOMEM);
-
-	sprintf(dev->name, "eth%d", unit);
-	netdev_boot_setup_check(dev);
-
-	r[0].start = dev->base_addr;
-	r[0].end = r[0].start+NE_IO_EXTENT-1;
-
-	if (dev->mem_end == BAD)
-		r[0].name = BAD_STR;
-
-	r[1].start = dev->irq;
-
-	free_netdev(dev);
-
-	pdev = platform_device_register_simple(
-		DRV_NAME, unit, r, ARRAY_SIZE(r));
-	if (IS_ERR(pdev))
-		return ERR_CAST(pdev);
-	pdev_ne[this_dev] = pdev;
-
-	/* Why is ne_probe being called before ne_init? */
-	dev = platform_get_drvdata(pdev);
-	if (!dev)
-		return ERR_PTR(-ENODEV);
-
-	return dev;
-}
-#endif
-
 static int __init ne_probe_isapnp(struct net_device *dev)
 {
 	int i;
@@ -969,16 +915,16 @@ static struct platform_driver ne_driver = {
 	},
 };
 
-#ifdef MODULE
-
 /* This is set up so that no ISA autoprobe takes place. We can't guarantee
 that the ne2k probe is the last 8390 based probe to take place (as it
 is at boot) and so the probe will get confused by any other 8390 cards.
 ISA device autoprobes on a running machine are not recommended anyway. */
 
-int __init init_module(void)
+/* Register platform devices for each non-zero io[] (and one 0 io for probe
+ * or pnp probing), then probe to see if we found any.
+ */
+static void __init ne_add_devices(void)
 {
-	int retval;
 	int this_dev;
 	int probed_zero = 0;
 	struct platform_device *pdev;
@@ -998,6 +944,8 @@ int __init init_module(void)
 				continue;
 			probed_zero = 1;
 		}
+		if (pdev_ne[this_dev])
+			continue;
 		if (bad[this_dev] == BAD)
 			r[0].name = BAD_STR;
 		pdev = platform_device_register_simple(
@@ -1006,14 +954,16 @@ int __init init_module(void)
 			continue;
 		pdev_ne[this_dev] = pdev;
 	}
+}
 
-	/* Need to find out if any devices are found, if not the driver
-	 * has been unregistered, so re-register it for suspend and
-	 * resume notifications and because cleanup_module unregisters it.
-	 */
+#ifdef MODULE
+int __init init_module()
+{
+	int retval;
+	ne_add_devices();
 	retval = platform_driver_probe(&ne_driver, ne_drv_probe);
 	if (retval) {
-		if (io[this_dev] == 0)
+		if (io[0] == 0)
 			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\""
 				" value(s) for ISA cards.\n");
 		ne_loop_rm_unreg(1);
@@ -1022,24 +972,61 @@ int __init init_module(void)
 
 	/* Unregister unused platform_devices. */
 	ne_loop_rm_unreg(0);
+	return retval;
+}
+#else /* MODULE */
+static int __init ne_init(void)
+{
+	int retval = platform_driver_probe(&ne_driver, ne_drv_probe);
 
+	/* Unregister unused platform_devices. */
+	ne_loop_rm_unreg(0);
 	return retval;
 }
-#endif /* MODULE */
+module_init(ne_init);
 
-static void __exit ne_exit(void)
+struct net_device * __init ne_probe(int unit)
 {
-	platform_driver_unregister(&ne_driver);
+	int this_dev;
+	struct net_device *dev;
+	struct platform_device *pdev;
 
-	ne_loop_rm_unreg(1);
+	/* Find an empty slot. */
+	this_dev = 0;
+	while (pdev_ne[this_dev] || io[this_dev]) {
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
+
+	io[this_dev] = dev->base_addr;
+	irq[this_dev] = dev->irq;
+	bad[this_dev] = dev->mem_end;
+
+	free_netdev(dev);
+
+	ne_add_devices();
+
+	/* return the first device found */
+	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++)
+		if ((pdev = pdev_ne[this_dev]) &&
+			(dev = platform_get_drvdata(pdev)))
+			return dev;
+
+	return ERR_PTR(-ENODEV);
 }
+#endif /* MODULE */
 
-#ifndef MODULE
-static int __init ne_init(void)
+static void __exit ne_exit(void)
 {
-	return platform_driver_probe(&ne_driver, ne_drv_probe);
+	platform_driver_unregister(&ne_driver);
+	ne_loop_rm_unreg(1);
 }
-
-module_init(ne_init);
-#endif
-module_exit(ne_cleanup);
+module_exit(ne_exit);
