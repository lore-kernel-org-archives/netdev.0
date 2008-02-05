From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 05/24 for-2.6.25] DM9000: Pass IRQ flags via platform resources
Date: Tue, 05 Feb 2008 00:02:04 +0000
Message-ID: <20080205000815.373492802@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>,
	Bryan Wu <bryan.wu@analog.com>,
	Alex Landau <landau.alex@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58755 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758597AbYBEAI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:27 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-platdata-irq.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the flags in the IRQ resource to specify the type of
IRQ being requested, so that systems which do not have
level-based interrupts, or change the interrupt in some
other way can specify this without making an #ifdef mess
in the driver.

This is specifically designed to undo the change in commit
4e4fc05a2b6e7bd2e0facd96e0c18dceb34d9349 which hardwires the
type for everyone but blackfin to IRQT_RISING, which breaks
all a number of Simtec boards which use (and setup in the
bootloader) active low IRQs.

Note, although there where originally objections due to
the use of IORESOURCE_IRQ and IRQT_ flags not sharing the
same definition, at least <include/linux/interrupt.h> notes
these are the same.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>
CC: Daniel Mack <daniel@caiaq.de>
CC: Bryan Wu <bryan.wu@analog.com>
CC: Alex Landau <landau.alex@gmail.com>

Index: linux-2.6.24-quilt2/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt2.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt2/drivers/net/dm9000.c
@@ -90,9 +90,9 @@
 #define writesb	outsb
 #define writesw	outsw
 #define writesl	outsl
-#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
+#define DEFAULT_TRIGGER IRQF_TRIGGER_HIGH
 #else
-#define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQT_RISING)
+#define DEFAULT_TRIGGER (0)
 #endif
 
 /*
@@ -614,10 +614,21 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
 	dev_dbg(db->dev, "entering %s\n", __func__);
 
-	if (request_irq(dev->irq, &dm9000_interrupt, DM9000_IRQ_FLAGS, dev->name, dev))
+	/* If there is no IRQ type specified, default to something that
+	 * may work, and tell the user that this is a problem */
+
+	if (irqflags == IRQF_TRIGGER_NONE) {
+		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
+		irqflags = DEFAULT_TRIGGER;
+	}
+	
+	irqflags |= IRQF_SHARED;
+
+	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
