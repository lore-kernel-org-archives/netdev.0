From: Andrew Ruder <andrew.ruder@elecsyscorp.com>
Subject: [PATCH 6/6] dm9000: avoid sleeping in dm9000_timeout callback
Date: Wed,  4 Jun 2014 17:28:49 -0500
Message-ID: <770572506d1d2b64a5616e0ae6438cf32cf5a28a.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
Cc: Andrew Ruder <andrew.ruder@elecsyscorp.com>,
	Joseph CHANG <josright123@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new1-smtp.messagingengine.com ([66.111.4.221]:50410 "EHLO
	new1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbaFDWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:37:57 -0400
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 171424C3
	for <netdev@vger.kernel.org>; Wed,  4 Jun 2014 18:29:16 -0400 (EDT)
In-Reply-To: <cover.1401920320.git.andrew.ruder@elecsyscorp.com>
In-Reply-To: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
References: <cover.1401920694.git.andrew.ruder@elecsyscorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the DM9000B, dm9000_msleep() is called during the dm9000_timeout()
routine.  Since dm9000_timeout() holds the main spinlock through the
entire routine, mdelay() needs to be used rather than msleep().
Furthermore, the mutex_lock()/mutex_unlock() should be avoided so as to
not sleep with spinlocks held.

Signed-off-by: Andrew Ruder <andrew.ruder@elecsyscorp.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index eb9b704..785afa5 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -109,6 +109,7 @@ typedef struct board_info {
 	u8		imr_all;
 
 	unsigned int	flags;
+	unsigned int	in_timeout:1;
 	unsigned int	in_suspend:1;
 	unsigned int	wake_supported:1;
 
@@ -273,7 +274,7 @@ static void dm9000_dumpblk_32bit(void __iomem *reg, int count)
  */
 static void dm9000_msleep(board_info_t *db, unsigned int ms)
 {
-	if (db->in_suspend)
+	if (db->in_suspend || db->in_timeout)
 		mdelay(ms);
 	else
 		msleep(ms);
@@ -334,7 +335,8 @@ dm9000_phy_write(struct net_device *dev,
 	unsigned long reg_save;
 
 	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
-	mutex_lock(&db->addr_lock);
+	if (!db->in_timeout)
+		mutex_lock(&db->addr_lock);
 
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -365,7 +367,8 @@ dm9000_phy_write(struct net_device *dev,
 	writeb(reg_save, db->io_addr);
 
 	spin_unlock_irqrestore(&db->lock, flags);
-	mutex_unlock(&db->addr_lock);
+	if (!db->in_timeout)
+		mutex_unlock(&db->addr_lock);
 }
 
 /* dm9000_set_io
@@ -971,6 +974,7 @@ static void dm9000_timeout(struct net_device *dev)
 
 	/* Save previous register address */
 	spin_lock_irqsave(&db->lock, flags);
+	db->in_timeout = 1;
 	reg_save = readb(db->io_addr);
 
 	netif_stop_queue(dev);
@@ -982,6 +986,7 @@ static void dm9000_timeout(struct net_device *dev)
 
 	/* Restore previous register address */
 	writeb(reg_save, db->io_addr);
+	db->in_timeout = 0;
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
-- 
1.9.0.rc3.12.gbc97e2d
