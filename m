From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/9][BNX2]: Move tx indexes into bnx2_napi struct.
Date: Thu, 20 Dec 2007 12:32:10 -0800
Message-ID: <1198182730.9163.30.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4987 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbXLTTra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:47:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Move tx indexes into bnx2_napi struct.

Tx related fields used in NAPI polling are moved from the main
bnx2 struct to the bnx2_napi struct.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3f754e6..0300a75 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -226,7 +226,7 @@ static struct flash_spec flash_5709 = {
 
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
-static inline u32 bnx2_tx_avail(struct bnx2 *bp)
+static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
 	u32 diff;
 
@@ -235,7 +235,7 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp)
 	/* The ring uses 256 indices for 255 entries, one of them
 	 * needs to be skipped.
 	 */
-	diff = bp->tx_prod - bp->tx_cons;
+	diff = bp->tx_prod - bnapi->tx_cons;
 	if (unlikely(diff >= TX_DESC_CNT)) {
 		diff &= 0xffff;
 		if (diff == TX_DESC_CNT)
@@ -2358,7 +2358,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 	int tx_free_bd = 0;
 
 	hw_cons = bnx2_get_hw_tx_cons(bnapi);
-	sw_cons = bp->tx_cons;
+	sw_cons = bnapi->tx_cons;
 
 	while (sw_cons != hw_cons) {
 		struct sw_bd *tx_buf;
@@ -2412,8 +2412,8 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 		hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	}
 
-	bp->hw_tx_cons = hw_cons;
-	bp->tx_cons = sw_cons;
+	bnapi->hw_tx_cons = hw_cons;
+	bnapi->tx_cons = sw_cons;
 	/* Need to make the tx_cons update visible to bnx2_start_xmit()
 	 * before checking for netif_queue_stopped().  Without the
 	 * memory barrier, there is a small possibility that bnx2_start_xmit()
@@ -2422,10 +2422,10 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 	smp_mb();
 
 	if (unlikely(netif_queue_stopped(bp->dev)) &&
-		     (bnx2_tx_avail(bp) > bp->tx_wake_thresh)) {
+		     (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh)) {
 		netif_tx_lock(bp->dev);
 		if ((netif_queue_stopped(bp->dev)) &&
-		    (bnx2_tx_avail(bp) > bp->tx_wake_thresh))
+		    (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh))
 			netif_wake_queue(bp->dev);
 		netif_tx_unlock(bp->dev);
 	}
@@ -2846,7 +2846,7 @@ bnx2_has_work(struct bnx2_napi *bnapi)
 	struct status_block *sblk = bp->status_blk;
 
 	if ((bnx2_get_hw_rx_cons(bnapi) != bp->rx_cons) ||
-	    (bnx2_get_hw_tx_cons(bnapi) != bp->hw_tx_cons))
+	    (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons))
 		return 1;
 
 	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
@@ -2876,7 +2876,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 		REG_RD(bp, BNX2_HC_COMMAND);
 	}
 
-	if (bnx2_get_hw_tx_cons(bnapi) != bp->hw_tx_cons)
+	if (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons)
 		bnx2_tx_int(bp, bnapi);
 
 	if (bnx2_get_hw_rx_cons(bnapi) != bp->rx_cons)
@@ -4381,6 +4381,7 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 {
 	struct tx_bd *txbd;
 	u32 cid;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi;
 
 	bp->tx_wake_thresh = bp->tx_ring_size / 2;
 
@@ -4390,8 +4391,8 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 	txbd->tx_bd_haddr_lo = (u64) bp->tx_desc_mapping & 0xffffffff;
 
 	bp->tx_prod = 0;
-	bp->tx_cons = 0;
-	bp->hw_tx_cons = 0;
+	bnapi->tx_cons = 0;
+	bnapi->hw_tx_cons = 0;
 	bp->tx_prod_bseq = 0;
 
 	cid = TX_CID;
@@ -5440,8 +5441,10 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi;
 
-	if (unlikely(bnx2_tx_avail(bp) < (skb_shinfo(skb)->nr_frags + 1))) {
+	if (unlikely(bnx2_tx_avail(bp, bnapi) <
+	    (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
 		printk(KERN_ERR PFX "%s: BUG! Tx ring full when queue awake!\n",
 			dev->name);
@@ -5556,9 +5559,9 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bp->tx_prod = prod;
 	dev->trans_start = jiffies;
 
-	if (unlikely(bnx2_tx_avail(bp) <= MAX_SKB_FRAGS)) {
+	if (unlikely(bnx2_tx_avail(bp, bnapi) <= MAX_SKB_FRAGS)) {
 		netif_stop_queue(dev);
-		if (bnx2_tx_avail(bp) > bp->tx_wake_thresh)
+		if (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh)
 			netif_wake_queue(dev);
 	}
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 345b6db..958fdda 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6509,6 +6509,9 @@ struct bnx2_napi {
 	struct status_block	*status_blk;
 	u32 			last_status_idx;
 	u32			int_num;
+
+	u16			tx_cons;
+	u16			hw_tx_cons;
 };
 
 struct bnx2 {
@@ -6539,9 +6542,6 @@ struct bnx2 {
 	u32		tx_bidx_addr;
 	u32		tx_bseq_addr;
 
-	u16		tx_cons __attribute__((aligned(L1_CACHE_BYTES)));
-	u16		hw_tx_cons;
-
 	struct bnx2_napi	bnx2_napi;
 
 #ifdef BCM_VLAN


