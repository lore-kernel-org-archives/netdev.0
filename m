From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 16/22] NET: DM9000: Fix delays used by EEPROM read and write
Date: Mon, 19 Nov 2007 20:39:26 +0000
Message-ID: <20071119204015.505334566@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61682 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751996AbXKSVSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:00 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-eeprom-rwfix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code was using a delay of 8ms, when it should have been
using the EEPROM status flag from the device to indicate the
EEPROM transaction had finished.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -1114,6 +1114,50 @@ dm9000_rx(struct net_device *dev)
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
@@ -1131,8 +1175,10 @@ dm9000_read_eeprom(board_info_t *db, int
 
 	spin_unlock_irqrestore(&db->lock, flags);
 
-	mdelay(8);		/* according to the datasheet 200us should be enough,
-				   but it doesn't work */
+	dm9000_wait_eeprom(db);
+
+	/* delay for at-least 150uS */
+	msleep(1);
 
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -1163,7 +1209,9 @@ dm9000_write_eeprom(board_info_t *db, in
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
