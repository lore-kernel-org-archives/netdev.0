From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 09/22] NET: DM9000: Add mutex to protect access
Date: Mon, 19 Nov 2007 20:39:19 +0000
Message-ID: <20071119204014.228412513@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61662 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751773AbXKSVO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:27 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-lock-eeprom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a mutex to serialise access to the chip functions from
entries such as the ethtool and the MII code. This should
reduce the amount of time the spinlock is held to protect
the address register. 

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -100,6 +100,24 @@ static int watchdog = 5000;
 module_param(watchdog, int, 0400);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
+/* DM9000 register address locking.
+ *
+ * The DM9000 uses an address register to control where data written
+ * to the data register goes. This means that the address register
+ * must be preserved over interrupts or similar calls.
+ *
+ * During interrupt and other critical calls, a spinlock is used to
+ * protect the system, but the calls themselves save the address
+ * in the address register in case they are interrupting another
+ * access to the device.
+ *
+ * For general accesses a lock is provided so that calls which are
+ * allowed to sleep are serialised so that the address register does
+ * not need to be saved. This lock also serves to serialise access
+ * to the EEPROM and PHY access registers which are shared between
+ * these two devices.
+ */
+
 /* Structure/enum declaration ------------------------------- */
 typedef struct board_info {
 
@@ -132,6 +150,8 @@ typedef struct board_info {
 	struct resource *data_req;
 	struct resource *irq_res;
 
+	struct mutex	addr_lock;	/* phy and eeprom access lock */
+
 	struct task_struct *thread;
 	struct net_device_stats stats;
 	spinlock_t lock;
@@ -370,26 +390,16 @@ static void dm9000_get_drvinfo(struct ne
 static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	board_info_t *dm = to_dm9000_board(dev);
-	unsigned long flags;
 
-	spin_lock_irqsave(&dm->lock, flags);
 	mii_ethtool_gset(&dm->mii, cmd);
-	spin_lock_irqsave(&dm->lock, flags);
-
 	return 0;
 }
 
 static int dm9000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	board_info_t *dm = to_dm9000_board(dev);
-	unsigned long flags;
-	int rc;
-
-	spin_lock_irqsave(&dm->lock, flags);
-	rc = mii_ethtool_sset(&dm->mii, cmd);
-	spin_lock_irqsave(&dm->lock, flags);
 
-	return rc;
+	return mii_ethtool_sset(&dm->mii, cmd);
 }
 
 static int dm9000_nway_reset(struct net_device *dev)
@@ -481,6 +491,7 @@ dm9000_probe(struct platform_device *pde
 	db->dev = &pdev->dev;
 
 	spin_lock_init(&db->lock);
+	mutex_init(&db->addr_lock);
 
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
@@ -1063,8 +1074,10 @@ dm9000_rx(struct net_device *dev)
  *  Read a word data from EEPROM
  */
 static void
-dm9000_read_eeprom(board_info_t * db, int offset, unsigned char *to)
+dm9000_read_eeprom(board_info_t *db, int offset, unsigned char *to)
 {
+	mutex_lock(&db->addr_lock);
+
 	iow(db, DM9000_EPAR, offset);
 	iow(db, DM9000_EPCR, EPCR_ERPRR);
 	mdelay(8);		/* according to the datasheet 200us should be enough,
@@ -1073,6 +1086,8 @@ dm9000_read_eeprom(board_info_t * db, in
 
 	to[0] = ior(db, DM9000_EPDRL);
 	to[1] = ior(db, DM9000_EPDRH);
+
+	mutex_unlock(&db->addr_lock);
 }
 
 #ifdef DM9000_PROGRAM_EEPROM
@@ -1082,12 +1097,16 @@ dm9000_read_eeprom(board_info_t * db, in
 static void
 write_srom_word(board_info_t * db, int offset, u16 val)
 {
+	mutex_lock(&db->addr_lock);
+
 	iow(db, DM9000_EPAR, offset);
 	iow(db, DM9000_EPDRH, ((val >> 8) & 0xff));
 	iow(db, DM9000_EPDRL, (val & 0xff));
 	iow(db, DM9000_EPCR, EPCR_WEP | EPCR_ERPRW);
 	mdelay(8);		/* same shit */
 	iow(db, DM9000_EPCR, 0);
+
+	mutex_unlock(&db->addr_lock);
 }
 
 /*
@@ -1195,6 +1214,8 @@ dm9000_phy_read(struct net_device *dev, 
 	unsigned int reg_save;
 	int ret;
 
+	mutex_lock(&db->addr_lock);
+
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
@@ -1222,6 +1243,7 @@ dm9000_phy_read(struct net_device *dev, 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
 
+	mutex_unlock(&db->addr_lock);
 	return ret;
 }
 
@@ -1235,6 +1257,8 @@ dm9000_phy_write(struct net_device *dev,
 	unsigned long flags;
 	unsigned long reg_save;
 
+	mutex_lock(&db->addr_lock);
+
 	spin_lock_irqsave(&db->lock,flags);
 
 	/* Save previous register address */
@@ -1250,7 +1274,7 @@ dm9000_phy_write(struct net_device *dev,
 	iow(db, DM9000_EPCR, 0xa);	/* Issue phyxcer write command */
 
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	dm9000_msleep(db, 1);		/* Wait write complete */
 
@@ -1262,7 +1286,8 @@ dm9000_phy_write(struct net_device *dev,
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
 
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
+	mutex_unlock(&db->addr_lock);
 }
 
 static int

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
