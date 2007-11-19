From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 19/22] NET: DM9000: Add platform flag for no attached EEPROM
Date: Mon, 19 Nov 2007 20:39:29 +0000
Message-ID: <20071119204015.990366794@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61675 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751750AbXKSVRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:17:47 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-no-eeprom-flag.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the platform data to specify to the DM9000 driver
that there is no posibility of an attached EEPROM on the
device, so default all reads to 0xff and ignore any
write operations.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -410,6 +410,9 @@ static int dm9000_get_eeprom(struct net_
 	if ((len & 1) != 0 || (offset & 1) != 0)
 		return -EINVAL;
 
+	if (dm->flags & DM9000_PLATF_NO_EEPROM)
+		return -ENOENT;
+
 	ee->magic = DM_EEPROM_MAGIC;
 
 	for (i = 0; i < len; i += 2)
@@ -431,6 +434,9 @@ static int dm9000_set_eeprom(struct net_
 	if ((len & 1) != 0 || (offset & 1) != 0)
 		return -EINVAL;
 
+	if (dm->flags & DM9000_PLATF_NO_EEPROM)
+		return -ENOENT;
+
 	if (ee->magic != DM_EEPROM_MAGIC)
 		return -EINVAL;
 
@@ -1166,6 +1172,12 @@ dm9000_read_eeprom(board_info_t *db, int
 {
 	unsigned long flags;
 
+	if (db->flags & DM9000_PLATF_NO_EEPROM) {
+		to[0] = 0xff;
+		to[1] = 0xff;
+		return;
+	}
+
 	mutex_lock(&db->addr_lock);
 
 	spin_lock_irqsave(&db->lock, flags);
@@ -1200,6 +1212,9 @@ dm9000_write_eeprom(board_info_t *db, in
 {
 	unsigned long flags;
 
+	if (db->flags & DM9000_PLATF_NO_EEPROM)
+		return;
+
 	mutex_lock(&db->addr_lock);
 
 	spin_lock_irqsave(&db->lock, flags);
Index: linux-2.6.23-quilt3/include/linux/dm9000.h
===================================================================
--- linux-2.6.23-quilt3.orig/include/linux/dm9000.h
+++ linux-2.6.23-quilt3/include/linux/dm9000.h
@@ -20,6 +20,7 @@
 #define DM9000_PLATF_16BITONLY	(0x0002)
 #define DM9000_PLATF_32BITONLY	(0x0004)
 #define DM9000_PLATF_EXT_PHY	(0x0008)
+#define DM9000_PLATF_NO_EEPROM	(0x0010)
 
 /* platfrom data for platfrom device structure's platfrom_data field */
 

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
