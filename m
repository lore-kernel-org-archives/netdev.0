From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2: Save statistics during reset.
Date: Sun, 17 Jan 2010 09:30:44 -0800
Message-ID: <1263749444-17072-2-git-send-email-mchan@broadcom.com>
References: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1519 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552Ab0AQRW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 12:22:27 -0500
In-Reply-To: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MTU changes, ring size changes, etc cause the chip to be reset and the
statisctics flushed.  To keep track of the accumulated statistics, we
add code to save the whole statistics block before reset.  We also
modify the macros and statistics functions to return the sum of the
saved and current counters.

Based on original patch by Breno Leitao <leitao@linux.vnet.ibm.com>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   64 +++++++++++++++++++++++++++++++++++++++++++++------
 drivers/net/bnx2.h |    1 +
 2 files changed, 57 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 47fb508..d83512d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6231,6 +6231,8 @@ bnx2_open(struct net_device *dev)
 
 	atomic_set(&bp->intr_sem, 0);
 
+	memset(bp->temp_stats_blk, 0, sizeof(struct statistics_block));
+
 	bnx2_enable_int(bp);
 
 	if (bp->flags & BNX2_FLAG_USING_MSI) {
@@ -6542,6 +6544,30 @@ bnx2_close(struct net_device *dev)
 	return 0;
 }
 
+static void
+bnx2_save_stats(struct bnx2 *bp)
+{
+	u32 *hw_stats = (u32 *) bp->stats_blk;
+	u32 *temp_stats = (u32 *) bp->temp_stats_blk;
+	int i;
+
+	/* The 1st 10 counters are 64-bit counters */
+	for (i = 0; i < 20; i += 2) {
+		u32 hi;
+		u64 lo;
+
+		hi = *(temp_stats + i) + *(hw_stats + i);
+		lo = *(temp_stats + i + 1) + *(hw_stats + i + 1);
+		if (lo > 0xffffffff)
+			hi++;
+		*(temp_stats + i) = hi;
+		*(temp_stats + i + 1) = lo & 0xffffffff;
+	}
+
+	for ( ; i < sizeof(struct statistics_block) / 4; i++)
+		*(temp_stats + i) = *(temp_stats + i) + *(hw_stats + i);
+}
+
 #define GET_64BIT_NET_STATS64(ctr)				\
 	(unsigned long) ((unsigned long) (ctr##_hi) << 32) +	\
 	(unsigned long) (ctr##_lo)
@@ -6551,14 +6577,17 @@ bnx2_close(struct net_device *dev)
 
 #if (BITS_PER_LONG == 64)
 #define GET_64BIT_NET_STATS(ctr)				\
-	GET_64BIT_NET_STATS64(bp->stats_blk->ctr)
+	GET_64BIT_NET_STATS64(bp->stats_blk->ctr) +		\
+	GET_64BIT_NET_STATS64(bp->temp_stats_blk->ctr)
 #else
 #define GET_64BIT_NET_STATS(ctr)				\
-	GET_64BIT_NET_STATS32(bp->stats_blk->ctr)
+	GET_64BIT_NET_STATS32(bp->stats_blk->ctr) +		\
+	GET_64BIT_NET_STATS32(bp->temp_stats_blk->ctr)
 #endif
 
 #define GET_32BIT_NET_STATS(ctr)				\
-	(unsigned long) (bp->stats_blk->ctr)
+	(unsigned long) (bp->stats_blk->ctr +			\
+			 bp->temp_stats_blk->ctr)
 
 static struct net_device_stats *
 bnx2_get_stats(struct net_device *dev)
@@ -7089,6 +7118,9 @@ static int
 bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 {
 	if (netif_running(bp->dev)) {
+		/* Reset will erase chipset stats; save them */
+		bnx2_save_stats(bp);
+
 		bnx2_netif_stop(bp);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 		bnx2_free_skbs(bp);
@@ -7433,6 +7465,7 @@ bnx2_get_ethtool_stats(struct net_device *dev,
 	struct bnx2 *bp = netdev_priv(dev);
 	int i;
 	u32 *hw_stats = (u32 *) bp->stats_blk;
+	u32 *temp_stats = (u32 *) bp->temp_stats_blk;
 	u8 *stats_len_arr = NULL;
 
 	if (hw_stats == NULL) {
@@ -7449,21 +7482,26 @@ bnx2_get_ethtool_stats(struct net_device *dev,
 		stats_len_arr = bnx2_5708_stats_len_arr;
 
 	for (i = 0; i < BNX2_NUM_STATS; i++) {
+		unsigned long offset;
+
 		if (stats_len_arr[i] == 0) {
 			/* skip this counter */
 			buf[i] = 0;
 			continue;
 		}
+
+		offset = bnx2_stats_offset_arr[i];
 		if (stats_len_arr[i] == 4) {
 			/* 4-byte counter */
-			buf[i] = (u64)
-				*(hw_stats + bnx2_stats_offset_arr[i]);
+			buf[i] = (u64) *(hw_stats + offset) +
+				 *(temp_stats + offset);
 			continue;
 		}
 		/* 8-byte counter */
-		buf[i] = (((u64) *(hw_stats +
-					bnx2_stats_offset_arr[i])) << 32) +
-				*(hw_stats + bnx2_stats_offset_arr[i] + 1);
+		buf[i] = (((u64) *(hw_stats + offset)) << 32) +
+			 *(hw_stats + offset + 1) +
+			 (((u64) *(temp_stats + offset)) << 32) +
+			 *(temp_stats + offset + 1);
 	}
 }
 
@@ -7831,6 +7869,14 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->flags = 0;
 	bp->phy_flags = 0;
 
+	bp->temp_stats_blk =
+		kzalloc(sizeof(struct statistics_block), GFP_KERNEL);
+
+	if (bp->temp_stats_blk == NULL) {
+		rc = -ENOMEM;
+		goto err_out;
+	}
+
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device(pdev);
 	if (rc) {
@@ -8352,6 +8398,8 @@ bnx2_remove_one(struct pci_dev *pdev)
 	if (bp->regview)
 		iounmap(bp->regview);
 
+	kfree(bp->temp_stats_blk);
+
 	free_netdev(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 939dc44..b860fbb 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6851,6 +6851,7 @@ struct bnx2 {
 	dma_addr_t		status_blk_mapping;
 
 	struct statistics_block	*stats_blk;
+	struct statistics_block	*temp_stats_blk;
 	dma_addr_t		stats_blk_mapping;
 
 	int			ctx_pages;
-- 
1.6.4.GIT


