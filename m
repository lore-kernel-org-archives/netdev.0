From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 09/24 for-2.6.25] DM9000: Use msleep() instead of udelay()
Date: Tue, 05 Feb 2008 00:02:08 +0000
Message-ID: <20080205000816.292587302@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58751 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756827AbYBEAI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:27 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-phy-msleep.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use sleeping functions when reading and writing the
PHY registers, so let us sleep instead of busy waiting for
the PHY.

Note, this also fixes a bug reading the PHY where only 100uS
was being used instead of 150uS

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -116,6 +116,7 @@ typedef struct board_info {
 	u8 io_mode;		/* 0:word, 2:byte */
 	u8 phy_addr;
 	unsigned int flags;
+	unsigned int in_suspend :1;
 
 	int debug_level;
 
@@ -1111,6 +1112,18 @@ dm9000_hash_table(struct net_device *dev
 
 
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
@@ -1134,7 +1147,7 @@ dm9000_phy_read(struct net_device *dev, 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
 
-	udelay(100);		/* Wait read complete */
+	dm9000_msleep(db, 1);		/* Wait read complete */
 
 	spin_lock_irqsave(&db->lock,flags);
 	reg_save = readb(db->io_addr);
@@ -1178,7 +1191,7 @@ dm9000_phy_write(struct net_device *dev,
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock,flags);
 
-	udelay(500);		/* Wait write complete */
+	dm9000_msleep(db, 1);		/* Wait write complete */
 
 	spin_lock_irqsave(&db->lock,flags);
 	reg_save = readb(db->io_addr);
@@ -1195,8 +1208,12 @@ static int
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
@@ -1219,6 +1236,8 @@ dm9000_drv_resume(struct platform_device
 
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
