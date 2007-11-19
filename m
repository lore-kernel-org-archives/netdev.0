From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 10/22] NET: DM9000: Add ethtool support for reading and writing EEPROM
Date: Mon, 19 Nov 2007 20:39:20 +0000
Message-ID: <20071119204014.385873523@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61686 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752014AbXKSVSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:06 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-ethtool-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ethtool support to access the configuration EEPROM
connected to the DM9000.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -191,7 +191,8 @@ static int dm9000_phy_read(struct net_de
 static void dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg,
 			   int value);
 
-static void dm9000_read_eeprom(board_info_t *, int addr, unsigned char *to);
+static void dm9000_read_eeprom(board_info_t *, int addr, u8 *to);
+static void dm9000_write_eeprom(board_info_t *, int addr, u8 *dp);
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
 
@@ -414,12 +415,65 @@ static u32 dm9000_get_link(struct net_de
 	return mii_link_ok(&dm->mii);
 }
 
+#define DM_EEPROM_MAGIC		(0x444D394B)
+
+static int dm9000_get_eeprom_len(struct net_device *dev)
+{
+	return 128;
+}
+
+static int dm9000_get_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+	int i;
+
+	/* EEPROM access is aligned to two bytes */
+
+	if ((len & 1) != 0 || (offset & 1) != 0)
+		return -EINVAL;
+
+	ee->magic = DM_EEPROM_MAGIC;
+
+	for (i = 0; i < len; i += 2)
+		dm9000_read_eeprom(dm, (offset + i) / 2, data + i);
+
+	return 0;
+}
+
+static int dm9000_set_eeprom(struct net_device *dev,
+			     struct ethtool_eeprom *ee, u8 *data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	int offset = ee->offset;
+	int len = ee->len;
+	int i;
+
+	/* EEPROM access is aligned to two bytes */
+
+	if ((len & 1) != 0 || (offset & 1) != 0)
+		return -EINVAL;
+
+	if (ee->magic != DM_EEPROM_MAGIC)
+		return -EINVAL;
+
+	for (i = 0; i < len; i += 2)
+		dm9000_write_eeprom(dm, (offset + i) / 2, data + i);
+
+	return 0;
+}
+
 static const struct ethtool_ops dm9000_ethtool_ops = {
 	.get_drvinfo		= dm9000_get_drvinfo,
 	.get_settings		= dm9000_get_settings,
 	.set_settings		= dm9000_set_settings,
 	.nway_reset		= dm9000_nway_reset,
 	.get_link		= dm9000_get_link,
+ 	.get_eeprom_len		= dm9000_get_eeprom_len,
+ 	.get_eeprom		= dm9000_get_eeprom,
+ 	.set_eeprom		= dm9000_set_eeprom,
 };
 
 
@@ -1074,7 +1128,7 @@ dm9000_rx(struct net_device *dev)
  *  Read a word data from EEPROM
  */
 static void
-dm9000_read_eeprom(board_info_t *db, int offset, unsigned char *to)
+dm9000_read_eeprom(board_info_t *db, int offset, u8 *to)
 {
 	mutex_lock(&db->addr_lock);
 
@@ -1090,18 +1144,17 @@ dm9000_read_eeprom(board_info_t *db, int
 	mutex_unlock(&db->addr_lock);
 }
 
-#ifdef DM9000_PROGRAM_EEPROM
 /*
  * Write a word data to SROM
  */
 static void
-write_srom_word(board_info_t * db, int offset, u16 val)
+dm9000_write_eeprom(board_info_t *db, int offset, u8 *data)
 {
 	mutex_lock(&db->addr_lock);
 
 	iow(db, DM9000_EPAR, offset);
-	iow(db, DM9000_EPDRH, ((val >> 8) & 0xff));
-	iow(db, DM9000_EPDRL, (val & 0xff));
+	iow(db, DM9000_EPDRH, data[1]);
+	iow(db, DM9000_EPDRL, data[0]);
 	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
 	mdelay(8);		/* same shit */
 	iow(db, DM9000_EPCR, 0);
@@ -1109,6 +1162,7 @@ write_srom_word(board_info_t * db, int o
 	mutex_unlock(&db->addr_lock);
 }
 
+#ifdef DM9000_PROGRAM_EEPROM
 /*
  * Only for development:
  * Here we write static data to the eeprom in case

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
