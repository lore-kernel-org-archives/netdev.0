From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 08/24 for-2.6.25] DM9000: Do not sleep with spinlock and IRQs held
Date: Tue, 05 Feb 2008 00:02:07 +0000
Message-ID: <20080205000816.090539437@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58757 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758646AbYBEAI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:28 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-phy-unlocksleep.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy read and write routines call udelay() with the board
lock held, and with the posibility of IRQs being disabled. Since
these delays can be up to 500usec, and are only required as we
have to save the chip's address register. 

To improve the behaviour, hold the lock whilst we are writing
and then restore the state before the delay and then repeat
the process once the delay has happened.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -1130,7 +1130,15 @@ dm9000_phy_read(struct net_device *dev, 
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
 	iow(db, DM9000_EPCR, 0xc);	/* Issue phyxcer read command */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+
 	udelay(100);		/* Wait read complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
 
 	/* The read data keeps on REG_0D & REG_0E */
@@ -1138,7 +1146,6 @@ dm9000_phy_read(struct net_device *dev, 
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
-
 	spin_unlock_irqrestore(&db->lock,flags);
 
 	return ret;
@@ -1167,7 +1174,15 @@ dm9000_phy_write(struct net_device *dev,
 	iow(db, DM9000_EPDRH, ((value >> 8) & 0xff));
 
 	iow(db, DM9000_EPCR, 0xa);	/* Issue phyxcer write command */
+
+	writeb(reg_save, db->io_addr);
+	spin_unlock_irqrestore(&db->lock,flags);
+
 	udelay(500);		/* Wait write complete */
+
+	spin_lock_irqsave(&db->lock,flags);
+	reg_save = readb(db->io_addr);
+
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
 
 	/* restore the previous address */

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
