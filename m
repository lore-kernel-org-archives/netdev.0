From: dmitry pervushin <dpervushin@gmail.com>
Subject: [PATCH] dm9000 - fix spinlock issue, updated
Date: Wed, 21 Nov 2007 16:47:53 +0300
Message-ID: <1195652873.4999.8.camel@diimka.pervushin.msk.ru>
Reply-To: dpervushin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, ben@fluff.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:14782 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbXKUNr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 08:47:58 -0500
Received: by ug-out-1314.google.com with SMTP id z38so104875ugc
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 05:47:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below fixes the problem with dm9000_timeout function: it calls
dm9000_init under the spin_lock db->lock, which was going to be acquired
again in dm9000_hash_table. From the other hand, dm9000_hash_table has
to be called with db->lock held

Signed-off-by: dmitry pervushin <dpervushin@gmail.com>
Index: linux/drivers/net/dm9000.c
===================================================================
--- linux.orig/drivers/net/dm9000.c
+++ linux/drivers/net/dm9000.c
@@ -173,6 +173,7 @@ static void dm9000_phy_write(struct net_
 static u16 read_srom_word(board_info_t *, int);
 static void dm9000_rx(struct net_device *);
 static void dm9000_hash_table(struct net_device *);
+static void dm9000_set_multicast(struct net_device *dev);
 
 //#define DM9000_PROGRAM_EEPROM
 #ifdef DM9000_PROGRAM_EEPROM
@@ -556,7 +557,7 @@ dm9000_probe(struct platform_device *pde
 	ndev->tx_timeout         = &dm9000_timeout;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->stop		 = &dm9000_stop;
-	ndev->set_multicast_list = &dm9000_hash_table;
+	ndev->set_multicast_list = &dm9000_set_multicast;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;
 #endif
@@ -620,6 +621,7 @@ static int
 dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long flags;
 
 	PRINTK2("entering dm9000_open\n");
 
@@ -627,8 +629,10 @@ dm9000_open(struct net_device *dev)
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */
+	spin_lock_irqsave(&db->lock, flags);
 	dm9000_reset(db);
 	dm9000_init_dm9000(dev);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	/* Init driver variable */
 	db->dbug_cnt = 0;
@@ -1030,6 +1034,18 @@ cal_CRC(unsigned char *Data, unsigned in
 /*
  *  Set DM9000 multicast address
  */
+
+static void
+dm9000_set_multicast(struct net_device *dev)
+{
+	board_info_t *db = (board_info_t *) dev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&db->lock,flags);
+	dm9000_hash_table(dev);
+	spin_unlock_irqrestore(&db->lock, flags);
+}
+
 static void
 dm9000_hash_table(struct net_device *dev)
 {
@@ -1038,12 +1054,9 @@ dm9000_hash_table(struct net_device *dev
 	int mc_cnt = dev->mc_count;
 	u32 hash_val;
 	u16 i, oft, hash_table[4];
-	unsigned long flags;
 
 	PRINTK2("dm9000_hash_table()\n");
 
-	spin_lock_irqsave(&db->lock,flags);
-
 	for (i = 0, oft = 0x10; i < 6; i++, oft++)
 		iow(db, oft, dev->dev_addr[i]);
 
@@ -1065,8 +1078,6 @@ dm9000_hash_table(struct net_device *dev
 		iow(db, oft++, hash_table[i] & 0xff);
 		iow(db, oft++, (hash_table[i] >> 8) & 0xff);
 	}
-
-	spin_unlock_irqrestore(&db->lock,flags);
 }
 
 
@@ -1155,12 +1166,15 @@ dm9000_drv_resume(struct platform_device
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 	board_info_t *db = (board_info_t *) ndev->priv;
+	unsigned long flags;
 
 	if (ndev) {
 
 		if (netif_running(ndev)) {
+			spin_lock_irqsave(&db->lock, flags);
 			dm9000_reset(db);
 			dm9000_init_dm9000(ndev);
+			spin_unlock_irqrestore(&db->lock, flags);
 
 			netif_device_attach(ndev);
 		}


