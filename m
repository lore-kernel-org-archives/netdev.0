From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 18/24 for-2.6.25] DM9000: Fix delays used by EEPROM read and write
Date: Tue, 05 Feb 2008 00:02:17 +0000
Message-ID: <20080205000818.136334068@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58736 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758835AbYBEAIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:24 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-eeprom-rwfix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code was using a delay of 8ms, when it should have been
using the EEPROM status flag from the device to indicate the
EEPROM transaction had finished.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -1051,6 +1051,50 @@ dm9000_rx(struct net_device *dev)
 	} while (rxbyte == DM9000_PKT_RDY);
 }
 
+static unsigned int
+dm9000_read_locked(board_info_t *db, int reg)
+{
+	unsigned long flags;
+	unsigned int ret;
+
+	spin_lock_irqsave(&db->lock, flags);
+	ret = ior(db, reg);
+	spin_unlock_irqrestore(&db->lock, flags);
+
+	return ret;
+}
+
+static int dm9000_wait_eeprom(board_info_t *db)
+{
+	unsigned int status;
+	int timeout = 8;	/* wait max 8msec */
+
+	/* The DM9000 data sheets say we should be able to
+	 * poll the ERRE bit in EPCR to wait for the EEPROM
+	 * operation. From testing several chips, this bit
+	 * does not seem to work. 
+	 *
+	 * We attempt to use the bit, but fall back to the
+	 * timeout (which is why we do not return an error
+	 * on expiry) to say that the EEPROM operation has
+	 * completed.
+	 */
+
+	while (1) {
+		status = dm9000_read_locked(db, DM9000_EPCR);
+
+		if ((status & EPCR_ERRE) == 0)
+			break;
+
+		if (timeout-- < 0) {
+			dev_dbg(db->dev, "timeout waiting EEPROM\n");
+			break;
+		}
+	}
+
+	return 0;
+}
+
 /*
  *  Read a word data from EEPROM
  */
@@ -1068,8 +1112,10 @@ dm9000_read_eeprom(board_info_t *db, int
 
 	spin_unlock_irqrestore(&db->lock, flags);
 
-	mdelay(8);		/* according to the datasheet 200us should be enough,
-				   but it doesn't work */
+	dm9000_wait_eeprom(db);
+
+	/* delay for at-least 150uS */
+	msleep(1);
 
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -1100,7 +1146,9 @@ dm9000_write_eeprom(board_info_t *db, in
 	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
 	spin_unlock_irqrestore(&db->lock, flags);
 
-	mdelay(8);		/* same shit */
+	dm9000_wait_eeprom(db);
+
+	mdelay(1);	/* wait at least 150uS to clear */
 
 	spin_lock_irqsave(&db->lock, flags);
 	iow(db, DM9000_EPCR, 0);

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
