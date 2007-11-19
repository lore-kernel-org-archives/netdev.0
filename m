From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 05/22] NET: DM9000: Do not sleep with spinlock and IRQs held
Date: Mon, 19 Nov 2007 20:39:15 +0000
Message-ID: <20071119204013.621364965@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61677 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751949AbXKSVRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:17:54 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-phy-unlocksleep.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The phy read and write routines call udelay() with the board
lock held, and with the posibility of IRQs being disabled. Since
these delays can be up to 500usec, and are only required as we
have to save the chip's address register. 

To improve the behaviour, hold the lock whilst we are writing
and then restore the state before the delay and then repeat
the process once the delay has happened.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -1171,7 +1171,15 @@ dm9000_phy_read(struct net_device *dev, 
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
@@ -1179,7 +1187,6 @@ dm9000_phy_read(struct net_device *dev, 
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
-
 	spin_unlock_irqrestore(&db->lock,flags);
 
 	return ret;
@@ -1208,7 +1215,15 @@ dm9000_phy_write(struct net_device *dev,
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
