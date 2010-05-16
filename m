From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] dm9000: fix "BUG: spinlock recursion"
Date: Sun, 16 May 2010 13:06:47 +0300
Message-ID: <1274004407-12323-1-git-send-email-baruch@tkos.co.il>
Cc: Baruch Siach <baruch@tkos.co.il>, stable@kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:40338 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296Ab0EPLAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 May 2010 07:00:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dm9000_set_rx_csum and dm9000_hash_table are called from atomic context (in
dm9000_init_dm9000), and from non-atomic context (via ethtool_ops and
net_device_ops respectively). This causes a spinlock recursion BUG. Fix this by
renaming these functions to *_unlocked for the atomic context, and make the
original functions locking wrappers for use in the non-atomic context.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
Cc: stable@kernel.org
Cc: Sascha Hauer <s.hauer@pengutronix.de>
Cc: Ben Dooks <ben-linux@fluff.org>
---
 drivers/net/dm9000.c |   38 +++++++++++++++++++++++++++-----------
 1 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 7f9960f..3556b2c 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -476,17 +476,13 @@ static uint32_t dm9000_get_rx_csum(struct net_device *dev)
 	return dm->rx_csum;
 }
 
-static int dm9000_set_rx_csum(struct net_device *dev, uint32_t data)
+static int dm9000_set_rx_csum_unlocked(struct net_device *dev, uint32_t data)
 {
 	board_info_t *dm = to_dm9000_board(dev);
-	unsigned long flags;
 
 	if (dm->can_csum) {
 		dm->rx_csum = data;
-
-		spin_lock_irqsave(&dm->lock, flags);
 		iow(dm, DM9000_RCSR, dm->rx_csum ? RCSR_CSUM : 0);
-		spin_unlock_irqrestore(&dm->lock, flags);
 
 		return 0;
 	}
@@ -494,6 +490,19 @@ static int dm9000_set_rx_csum(struct net_device *dev, uint32_t data)
 	return -EOPNOTSUPP;
 }
 
+static int dm9000_set_rx_csum(struct net_device *dev, uint32_t data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&dm->lock, flags);
+	ret = dm9000_set_rx_csum_unlocked(dev, data);
+	spin_unlock_irqrestore(&dm->lock, flags);
+
+	return ret;
+}
+
 static int dm9000_set_tx_csum(struct net_device *dev, uint32_t data)
 {
 	board_info_t *dm = to_dm9000_board(dev);
@@ -722,7 +731,7 @@ static unsigned char dm9000_type_to_char(enum dm9000_type type)
  *  Set DM9000 multicast address
  */
 static void
-dm9000_hash_table(struct net_device *dev)
+dm9000_hash_table_unlocked(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr;
@@ -730,12 +739,9 @@ dm9000_hash_table(struct net_device *dev)
 	u32 hash_val;
 	u16 hash_table[4];
 	u8 rcr = RCR_DIS_LONG | RCR_DIS_CRC | RCR_RXEN;
-	unsigned long flags;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
 
-	spin_lock_irqsave(&db->lock, flags);
-
 	for (i = 0, oft = DM9000_PAR; i < 6; i++, oft++)
 		iow(db, oft, dev->dev_addr[i]);
 
@@ -765,6 +771,16 @@ dm9000_hash_table(struct net_device *dev)
 	}
 
 	iow(db, DM9000_RCR, rcr);
+}
+
+static void
+dm9000_hash_table(struct net_device *dev)
+{
+	board_info_t *db = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&db->lock, flags);
+	dm9000_hash_table_unlocked(dev);
 	spin_unlock_irqrestore(&db->lock, flags);
 }
 
@@ -784,7 +800,7 @@ dm9000_init_dm9000(struct net_device *dev)
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */
 
 	/* Checksum mode */
-	dm9000_set_rx_csum(dev, db->rx_csum);
+	dm9000_set_rx_csum_unlocked(dev, db->rx_csum);
 
 	/* GPIO0 on pre-activate PHY */
 	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
@@ -811,7 +827,7 @@ dm9000_init_dm9000(struct net_device *dev)
 	iow(db, DM9000_ISR, ISR_CLR_STATUS); /* Clear interrupt status */
 
 	/* Set address filter table */
-	dm9000_hash_table(dev);
+	dm9000_hash_table_unlocked(dev);
 
 	imr = IMR_PAR | IMR_PTM | IMR_PRM;
 	if (db->type != TYPE_DM9000E)
-- 
1.7.1

