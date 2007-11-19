From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 03/22] NET: DM9000: Pass IRQ flags via platform data
Date: Mon, 19 Nov 2007 20:39:13 +0000
Message-ID: <20071119204013.239356937@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61687 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752030AbXKSVSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:08 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-platdata-irq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the platform data to pass modifications to the flags
passed to request_irq() to alter the behaviour of the IRQ.

This can be used to specify IRQ type for the platform the
DM9000 is connected to.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.22-quilt6/drivers/net/dm9000.c
===================================================================
--- linux-2.6.22-quilt6.orig/drivers/net/dm9000.c	2007-08-20 18:26:22.000000000 +0100
+++ linux-2.6.22-quilt6/drivers/net/dm9000.c	2007-08-20 18:37:54.000000000 +0100
@@ -89,9 +89,6 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
-#else
-#define DM9000_IRQ_FLAGS	IRQF_SHARED
 #endif
 
 /*
@@ -124,6 +121,8 @@ typedef struct board_info {
 
 	struct device	*dev;	     /* parent device */
 
+	struct dm9000_plat_data *platdata;
+
 	struct resource	*addr_res;   /* resources found */
 	struct resource *data_res;
 	struct resource	*addr_req;   /* resources requested */
@@ -496,9 +495,11 @@ dm9000_probe(struct platform_device *pde
 
 	/* check to see if anything is being over-ridden */
 	if (pdata != NULL) {
+		db->platdata = pdata;
+
 		/* check to see if the driver wants to over-ride the
 		 * default IO width */
-
+	      
 		if (pdata->flags & DM9000_PLATF_8BITONLY)
 			dm9000_set_io(db, 1);
 
@@ -619,10 +620,14 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long irqflags = IRQF_SHARED;
 
 	dev_dbg(db->dev, "entering %s\n", __func__);
 
-	if (request_irq(dev->irq, &dm9000_interrupt, DM9000_IRQ_FLAGS, dev->name, dev))
+	if (db->platdata)
+		irqflags |= db->platdata->irqflags;
+
+	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */
Index: linux-2.6.22-quilt6/include/linux/dm9000.h
===================================================================
--- linux-2.6.22-quilt6.orig/include/linux/dm9000.h	2007-08-20 18:19:04.000000000 +0100
+++ linux-2.6.22-quilt6/include/linux/dm9000.h	2007-08-20 18:28:37.000000000 +0100
@@ -25,6 +25,7 @@
 
 struct dm9000_plat_data {
 	unsigned int	flags;
+	unsigned long	irqflags;	/* to pass to request_irq() */
 
 	/* allow replacement IO routines */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
