From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 12/13] small SONIC fix and cleanup
Date: Sat, 17 Mar 2007 20:08:42 +1100 (EST)
Message-ID: <Pine.LNX.4.64.0703171733330.4875@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loopy.telegraphics.com.au ([202.45.126.152]:36048 "EHLO
	loopy.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933364AbXCQJaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 05:30:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix a potential problem in the timeout handling: don't free the DMA 
buffers before resetting the chip.

Also a trivial cleanup. Bring macsonic and jazzsonic into sync.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

 drivers/net/jazzsonic.c |    4 ++--
 drivers/net/macsonic.c  |   17 ++++++++---------
 drivers/net/sonic.c     |    7 ++++++-
 3 files changed, 16 insertions(+), 12 deletions(-)

Index: linux-2.6.20/drivers/net/jazzsonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/jazzsonic.c	2007-03-05 15:19:48.000000000 +1100
+++ linux-2.6.20/drivers/net/jazzsonic.c	2007-03-05 15:20:51.000000000 +1100
@@ -269,11 +269,11 @@ static int __devexit jazz_sonic_device_r
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local* lp = netdev_priv(dev);
 
-	unregister_netdev (dev);
+	unregister_netdev(dev);
 	dma_free_coherent(lp->device, SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
 	                  lp->descriptors, lp->descriptors_laddr);
 	release_region (dev->base_addr, SONIC_MEM_SIZE);
-	free_netdev (dev);
+	free_netdev(dev);
 
 	return 0;
 }
Index: linux-2.6.20/drivers/net/macsonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/macsonic.c	2007-03-05 15:20:34.000000000 +1100
+++ linux-2.6.20/drivers/net/macsonic.c	2007-03-05 15:20:51.000000000 +1100
@@ -525,7 +525,7 @@ int __init mac_nubus_sonic_probe(struct 
 	return macsonic_init(dev);
 }
 
-static int __init mac_sonic_probe(struct platform_device *device)
+static int __init mac_sonic_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sonic_local *lp;
@@ -537,8 +537,8 @@ static int __init mac_sonic_probe(struct
 		return -ENOMEM;
 
 	lp = netdev_priv(dev);
-	lp->device = &device->dev;
-	SET_NETDEV_DEV(dev, &device->dev);
+	lp->device = &pdev->dev;
+	SET_NETDEV_DEV(dev, &pdev->dev);
  	SET_MODULE_OWNER(dev);
 
 	/* This will catch fatal stuff like -ENOMEM as well as success */
@@ -579,15 +579,15 @@ MODULE_PARM_DESC(sonic_debug, "macsonic 
 
 #include "sonic.c"
 
-static int __devexit mac_sonic_device_remove (struct platform_device *device)
+static int __devexit mac_sonic_device_remove (struct platform_device *pdev)
 {
-	struct net_device *dev = platform_get_drvdata(device);
+	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sonic_local* lp = netdev_priv(dev);
 
-	unregister_netdev (dev);
+	unregister_netdev(dev);
 	dma_free_coherent(lp->device, SIZEOF_SONIC_DESC * SONIC_BUS_SCALE(lp->dma_bitmode),
 	                  lp->descriptors, lp->descriptors_laddr);
-	free_netdev (dev);
+	free_netdev(dev);
 
 	return 0;
 }
@@ -610,9 +610,8 @@ static int __init mac_sonic_init_module(
 	}
 
 	mac_sonic_device = platform_device_alloc(mac_sonic_string, 0);
-	if (!mac_sonic_device) {
+	if (!mac_sonic_device)
 		goto out_unregister;
-	}
 
 	if (platform_device_add(mac_sonic_device)) {
 		platform_device_put(mac_sonic_device);
Index: linux-2.6.20/drivers/net/sonic.c
===================================================================
--- linux-2.6.20.orig/drivers/net/sonic.c	2007-03-05 15:19:48.000000000 +1100
+++ linux-2.6.20/drivers/net/sonic.c	2007-03-05 15:20:51.000000000 +1100
@@ -179,8 +179,13 @@ static void sonic_tx_timeout(struct net_
 {
 	struct sonic_local *lp = netdev_priv(dev);
 	int i;
-	/* Stop the interrupts for this */
+	/*
+	 * put the Sonic into software-reset mode and
+	 * disable all interrupts before releasing DMA buffers
+	 */
 	SONIC_WRITE(SONIC_IMR, 0);
+	SONIC_WRITE(SONIC_ISR, 0x7fff);
+	SONIC_WRITE(SONIC_CMD, SONIC_CR_RST);
 	/* We could resend the original skbs. Easier to re-initialise. */
 	for (i = 0; i < SONIC_NUM_TDS; i++) {
 		if(lp->tx_laddr[i]) {
