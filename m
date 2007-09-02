From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: [PATCH] remove setup of platform device from jazzsonic.c
Date: Sun, 2 Sep 2007 10:41:01 +0200
Message-ID: <20070902084101.GA12461@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:58246 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755287AbXIBJtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 05:49:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


remove setup platform device from jazzsonic, which is done in arch code now

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 75f6f44..435060a 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -45,7 +45,6 @@
 #include <asm/jazzdma.h>
 
 static char jazz_sonic_string[] = "jazzsonic";
-static struct platform_device *jazz_sonic_device;
 
 #define SONIC_MEM_SIZE	0x100
 
@@ -70,14 +69,6 @@ static unsigned int sonic_debug = 1;
 #endif
 
 /*
- * Base address and interrupt of the SONIC controller on JAZZ boards
- */
-static struct {
-	unsigned int port;
-	unsigned int irq;
-} sonic_portlist[] = { {JAZZ_ETHERNET_BASE, JAZZ_ETHERNET_IRQ}, {0, 0}};
-
-/*
  * We cannot use station (ethernet) address prefixes to detect the
  * sonic controller since these are board manufacturer depended.
  * So we check for known Silicon Revision IDs instead.
@@ -215,13 +206,12 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
+	struct resource *res;
 	int err = 0;
 	int i;
 
-	/*
-	 * Don't probe if we're not running on a Jazz board.
-	 */
-	if (mips_machgroup != MACH_GROUP_JAZZ)
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
 		return -ENODEV;
 
 	dev = alloc_etherdev(sizeof(struct sonic_local));
@@ -235,20 +225,9 @@ static int __init jazz_sonic_probe(struct platform_device *pdev)
 
 	netdev_boot_setup_check(dev);
 
-	if (dev->base_addr >= KSEG0) { /* Check a single specified location. */
-		err = sonic_probe1(dev);
-	} else if (dev->base_addr != 0) { /* Don't probe at all. */
-		err = -ENXIO;
-	} else {
-		for (i = 0; sonic_portlist[i].port; i++) {
-			dev->base_addr = sonic_portlist[i].port;
-			dev->irq = sonic_portlist[i].irq;
-			if (sonic_probe1(dev) == 0)
-				break;
-		}
-		if (!sonic_portlist[i].port)
-			err = -ENODEV;
-	}
+	dev->base_addr = res->start;
+	dev->irq = platform_get_irq(pdev, 0);
+	err = sonic_probe1(dev);
 	if (err)
 		goto out;
 	err = register_netdev(dev);
@@ -303,38 +282,12 @@ static struct platform_driver jazz_sonic_driver = {
 
 static int __init jazz_sonic_init_module(void)
 {
-	int err;
-
-	if ((err = platform_driver_register(&jazz_sonic_driver))) {
-		printk(KERN_ERR "Driver registration failed\n");
-		return err;
-	}
-
-	jazz_sonic_device = platform_device_alloc(jazz_sonic_string, 0);
-	if (!jazz_sonic_device)
-		goto out_unregister;
-
-	if (platform_device_add(jazz_sonic_device)) {
-		platform_device_put(jazz_sonic_device);
-		jazz_sonic_device = NULL;
-	}
-
-	return 0;
-
-out_unregister:
-	platform_driver_unregister(&jazz_sonic_driver);
-
-	return -ENOMEM;
+	return platform_driver_register(&jazz_sonic_driver);
 }
 
 static void __exit jazz_sonic_cleanup_module(void)
 {
 	platform_driver_unregister(&jazz_sonic_driver);
-
-	if (jazz_sonic_device) {
-		platform_device_unregister(jazz_sonic_device);
-		jazz_sonic_device = NULL;
-	}
 }
 
 module_init(jazz_sonic_init_module);
-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
