From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 17/22] NET: DM9000: Remove cal_CRC() and use ether_crc_le instead
Date: Mon, 19 Nov 2007 20:39:27 +0000
Message-ID: <20071119204015.650715145@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61651 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751536AbXKSVOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:07 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-cleanup-removecrc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the cal_CRC as this is basically wrappering the
ether_crc_le function, and is only being used by the
multicast hash table functions.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -1221,24 +1221,6 @@ dm9000_write_eeprom(board_info_t *db, in
 }
 
 /*
- *  Calculate the CRC valude of the Rx packet
- *  flag = 1 : return the reverse CRC (for the received packet CRC)
- *         0 : return the normal CRC (for Hash Table index)
- */
-
-static unsigned long
-cal_CRC(unsigned char *Data, unsigned int Len, u8 flag)
-{
-
-       u32 crc = ether_crc_le(Len, Data);
-
-       if (flag)
-               return ~crc;
-
-       return crc;
-}
-
-/*
  *  Set DM9000 multicast address
  */
 static void
@@ -1247,15 +1229,16 @@ dm9000_hash_table(struct net_device *dev
 	board_info_t *db = (board_info_t *) dev->priv;
 	struct dev_mc_list *mcptr = dev->mc_list;
 	int mc_cnt = dev->mc_count;
+	int i, oft;
 	u32 hash_val;
-	u16 i, oft, hash_table[4];
+	u16 hash_table[4];
 	unsigned long flags;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 
-	for (i = 0, oft = 0x10; i < 6; i++, oft++)
+	for (i = 0, oft = DM9000_PAR; i < 6; i++, oft++)
 		iow(db, oft, dev->dev_addr[i]);
 
 	/* Clear Hash Table */
@@ -1267,17 +1250,17 @@ dm9000_hash_table(struct net_device *dev
 
 	/* the multicast address in Hash Table : 64 bits */
 	for (i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
-		hash_val = cal_CRC((char *) mcptr->dmi_addr, 6, 0) & 0x3f;
+		hash_val = ether_crc_le(6, mcptr->dmi_addr) & 0x3f;
 		hash_table[hash_val / 16] |= (u16) 1 << (hash_val % 16);
 	}
 
 	/* Write the hash table to MAC MD table */
-	for (i = 0, oft = 0x16; i < 4; i++) {
-		iow(db, oft++, hash_table[i] & 0xff);
-		iow(db, oft++, (hash_table[i] >> 8) & 0xff);
+	for (i = 0, oft = DM9000_MAR; i < 4; i++) {
+		iow(db, oft++, hash_table[i]);
+		iow(db, oft++, hash_table[i] >> 8);
 	}
 
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
 }
 
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
