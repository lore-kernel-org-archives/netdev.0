From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 13/22] NET: DM9000: Ensure spinlock held whilst accessing EEPROM registers
Date: Mon, 19 Nov 2007 20:39:23 +0000
Message-ID: <20071119204014.879467427@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61664 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751807AbXKSVO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:29 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-spinlock-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ensure we hold the spinlock whilst the registers and being
modified even though we hold the overall lock. This should
protect against an interrupt happening whilst we are using
the device.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -1139,17 +1139,29 @@ dm9000_rx(struct net_device *dev)
 static void
 dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
 {
+	unsigned long flags;
+
 	mutex_lock(&db->addr_lock);
 
+	spin_lock_irqsave(&db->lock, flags);
+
 	iow(db, DM9000_EPAR, offset);
 	iow(db, DM9000_EPCR, EPCR_ERPRR);
+
+	spin_unlock_irqrestore(&db->lock, flags);
+
 	mdelay(8);		/* according to the datasheet 200us should be enough,
 				   but it doesn't work */
+
+	spin_lock_irqsave(&db->lock, flags);
+
 	iow(db, DM9000_EPCR, 0x0);
 
 	to[0] = ior(db, DM9000_EPDRL);
 	to[1] = ior(db, DM9000_EPDRH);
 
+	spin_unlock_irqrestore(&db->lock, flags);
+
 	mutex_unlock(&db->addr_lock);
 }
 
@@ -1159,14 +1171,22 @@ dm9000_read_eeprom(board_info_t *db, int
 static void
 dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 {
+	unsigned long flags;
+
 	mutex_lock(&db->addr_lock);
 
+	spin_lock_irqsave(&db->lock, flags);
 	iow(db, DM9000_EPAR, offset);
 	iow(db, DM9000_EPDRH, data[1]);
 	iow(db, DM9000_EPDRL, data[0]);
 	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
+	spin_unlock_irqrestore(&db->lock, flags);
+
 	mdelay(8);		/* same shit */
+
+	spin_lock_irqsave(&db->lock, flags);
 	iow(db, DM9000_EPCR, 0);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	mutex_unlock(&db->addr_lock);
 }

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
