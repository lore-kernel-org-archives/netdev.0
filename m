From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 07/22] NET: DM9000: Use msleep() instead of udelay()
Date: Mon, 19 Nov 2007 20:39:17 +0000
Message-ID: <20071119204013.911269341@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61688 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752063AbXKSVSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:18:13 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-phy-msleep.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can use sleeping functions when reading and writing the
PHY registers, so let us sleep instead of busy waiting for
the PHY.

Note, this also fixes a bug reading the PHY where only 100uS
was being used instead of 150uS

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -114,6 +114,7 @@ typedef struct board_info {
 	u8 io_mode;		/* 0:word, 2:byte */
 	u8 phy_addr;
 	unsigned int flags;
+	unsigned int in_suspend :1;
 
 	int debug_level;
 
@@ -1174,6 +1175,18 @@ dm9000_hash_table(struct net_device *dev
 
 
 /*
+ * Sleep, either by using msleep() or if we are suspending, then
+ * use mdelay() to sleep.
+ */
+static void dm9000_msleep(board_info_t *db, unsigned int ms)
+{
+	if (db->in_suspend)
+		mdelay(ms);
+	else
+		msleep(ms);
+}
+
+/*
  *   Read a word from phyxcer
  */
 static int
@@ -1197,7 +1210,7 @@ dm9000_phy_read(struct net_device *dev, 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
 
-	udelay(100);		/* Wait read complete */
+	dm9000_msleep(db, 1);		/* Wait read complete */
 
 	spin_lock_irqsave(&db->lock,flags);
 	reg_save = readb(db->io_addr);
@@ -1241,7 +1254,7 @@ dm9000_phy_write(struct net_device *dev,
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
 
-	udelay(500);		/* Wait write complete */
+	dm9000_msleep(db, 1);		/* Wait write complete */
 
 	spin_lock_irqsave(&db->lock,flags);
 	reg_save = readb(db->io_addr);
@@ -1258,8 +1271,12 @@ static int
 dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
+	board_info_t *db;
 
 	if (ndev) {
+		db = (board_info_t *) ndev->priv;
+		db->in_suspend = 1;
+
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
 			dm9000_shutdown(ndev);
@@ -1282,6 +1299,8 @@ dm9000_drv_resume(struct platform_device
 
 			netif_device_attach(ndev);
 		}
+
+		db->in_suspend = 0;
 	}
 	return 0;
 }

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
