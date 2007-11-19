From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 08/22] NET: DM9000: Remove barely used SROM array read.
Date: Mon, 19 Nov 2007 20:39:18 +0000
Message-ID: <20071119204014.071339248@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61679 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751949AbXKSVR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:17:58 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-remove-srom-read.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The srom array in the board data is only being used in the device probe
routines. The probe also only uses the first 6 bytes of an array
we spend 512ms reading 128 bytes from. Change to reading the
MAC area directly to the MAC address structure.

As a side product, we rename the read_srom_word to dm9000_read_eeprom
to bring it into line with the rest of the driver. No change is made
to the delay in this function, which will be dealt with in a later
patch.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>


Index: linux-2.6.23-quilt5/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt5.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt5/drivers/net/dm9000.c
@@ -134,7 +134,6 @@ typedef struct board_info {
 
 	struct task_struct *thread;
 	struct net_device_stats stats;
-	unsigned char srom[128];
 	spinlock_t lock;
 
 	struct mii_if_info mii;
@@ -171,7 +170,8 @@ static irqreturn_t dm9000_interrupt(int,
 static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused, int reg);
 static void dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg,
 			   int value);
-static u16 read_srom_word(board_info_t *, int);
+
+static void dm9000_read_eeprom(board_info_t *, int addr, unsigned char *to);
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
 
@@ -638,13 +638,9 @@ dm9000_probe(struct platform_device *pde
 	db->mii.mdio_read    = dm9000_phy_read;
 	db->mii.mdio_write   = dm9000_phy_write;
 
-	/* Read SROM content */
-	for (i = 0; i < 64; i++)
-		((u16 *) db->srom)[i] = read_srom_word(db, i);
-
-	/* Set Node Address */
-	for (i = 0; i < 6; i++)
-		ndev->dev_addr[i] = db->srom[i];
+	/* try reading the node address from the attached EEPROM */
+	for (i = 0; i < 6; i += 2)
+		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
@@ -1064,17 +1060,19 @@ dm9000_rx(struct net_device *dev)
 }
 
 /*
- *  Read a word data from SROM
+ *  Read a word data from EEPROM
  */
-static u16
-read_srom_word(board_info_t * db, int offset)
+static void
+dm9000_read_eeprom(board_info_t * db, int offset, unsigned char *to)
 {
 	iow(db, DM9000_EPAR, offset);
 	iow(db, DM9000_EPCR, EPCR_ERPRR);
 	mdelay(8);		/* according to the datasheet 200us should be enough,
 				   but it doesn't work */
 	iow(db, DM9000_EPCR, 0x0);
-	return (ior(db, DM9000_EPDRL) + (ior(db, DM9000_EPDRH) << 8));
+
+	to[0] = ior(db, DM9000_EPDRL);
+	to[1] = ior(db, DM9000_EPDRH);
 }
 
 #ifdef DM9000_PROGRAM_EEPROM

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
