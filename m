From: dmitry pervushin <dpervushin@gmail.com>
Subject: [PATCH] dm9000: fix spinlock issue and introduce platform_init
	callback
Date: Tue, 20 Nov 2007 17:43:42 +0300
Message-ID: <1195569822.17808.20.camel@diimka.pervushin.msk.ru>
Reply-To: dpervushin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:31864 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbXKTOnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 09:43:47 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1180722ugc
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 06:43:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey all,

The patch below is intended to fix two problems:
- trying to acquire spinlock twice on timeout condition
- create callback than can be used by platform code to initialize the
chip

Signed-off-by: dmitry pervushin <dpervushin@gmail.com>
Index: linux/drivers/net/dm9000.c
===================================================================
--- linux.orig/drivers/net/dm9000.c
+++ linux/drivers/net/dm9000.c
@@ -335,8 +335,11 @@ static void dm9000_timeout(struct net_de
 
 	netif_stop_queue(dev);
 	dm9000_reset(db);
+	spin_unlock_irqrestore(&db->lock,flags);
+
 	dm9000_init_dm9000(dev);
 	/* We can accept TX packets again */
+	spin_lock_irqsave(&db->lock,flags);
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
 
@@ -526,6 +529,8 @@ dm9000_probe(struct platform_device *pde
 			db->dumpblk = pdata->dumpblk;
 	}
 
+ 	if (pdata && pdata->platform_init)
+ 			pdata->platform_init(pdev);
 	dm9000_reset(db);
 
 	/* try two times, DM9000 sometimes gets the first read wrong */
@@ -1155,10 +1160,13 @@ dm9000_drv_resume(struct platform_device
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 	board_info_t *db = (board_info_t *) ndev->priv;
+ 	struct dm9000_plat_data *pdata = dev->dev.platform_data;
 
 	if (ndev) {
 
 		if (netif_running(ndev)) {
+ 			if (pdata && pdata->platform_init)
+         	                pdata->platform_init(dev);
 			dm9000_reset(db);
 			dm9000_init_dm9000(ndev);
 
Index: linux/include/linux/dm9000.h
===================================================================
--- linux.orig/include/linux/dm9000.h
+++ linux/include/linux/dm9000.h
@@ -30,6 +30,9 @@ struct dm9000_plat_data {
 	void	(*inblk)(void __iomem *reg, void *data, int len);
 	void	(*outblk)(void __iomem *reg, void *data, int len);
 	void	(*dumpblk)(void __iomem *reg, int len);
+
+	/* platform init, if any */
+	void 	(*platform_init)(void *);
 };
 
 #endif /* __DM9000_PLATFORM_DATA */


