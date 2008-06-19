From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/8] bnx2: Optimize fast-path tx and rx work.
Date: Wed, 18 Jun 2008 17:25:27 -0700
Message-ID: <1213835132-5698-4-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3946 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756391AbYFSAXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:48 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add hw_tx_cons_ptr and hw_rx_cons_ptr to speed up the retreival of
the tx and rx consumer index, since the MSI-X and default status
blocks have different structures.

Combine status_blk and status_blk_msix into a union.  We'll only use
one type of status block for each vector.

Separate the code to detect more rx and tx work from the code to
detect link related work.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |  107 ++++++++++++++++++++++++++++++++--------------------
 drivers/net/bnx2.h |    9 +++-
 2 files changed, 72 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4360528..cc70bdb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -624,6 +624,7 @@ static void
 bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	bnx2_free_tx_mem(bp);
 	bnx2_free_rx_mem(bp);
@@ -636,10 +637,11 @@ bnx2_free_mem(struct bnx2 *bp)
 			bp->ctx_blk[i] = NULL;
 		}
 	}
-	if (bp->status_blk) {
+	if (bnapi->status_blk.msi) {
 		pci_free_consistent(bp->pdev, bp->status_stats_size,
-				    bp->status_blk, bp->status_blk_mapping);
-		bp->status_blk = NULL;
+				    bnapi->status_blk.msi,
+				    bp->status_blk_mapping);
+		bnapi->status_blk.msi = NULL;
 		bp->stats_blk = NULL;
 	}
 }
@@ -648,6 +650,8 @@ static int
 bnx2_alloc_mem(struct bnx2 *bp)
 {
 	int i, status_blk_size, err;
+	struct bnx2_napi *bnapi;
+	void *status_blk;
 
 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
@@ -657,27 +661,37 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bp->status_stats_size = status_blk_size +
 				sizeof(struct statistics_block);
 
-	bp->status_blk = pci_alloc_consistent(bp->pdev, bp->status_stats_size,
-					      &bp->status_blk_mapping);
-	if (bp->status_blk == NULL)
+	status_blk = pci_alloc_consistent(bp->pdev, bp->status_stats_size,
+					  &bp->status_blk_mapping);
+	if (status_blk == NULL)
 		goto alloc_mem_err;
 
-	memset(bp->status_blk, 0, bp->status_stats_size);
+	memset(status_blk, 0, bp->status_stats_size);
 
-	bp->bnx2_napi[0].status_blk = bp->status_blk;
+	bnapi = &bp->bnx2_napi[0];
+	bnapi->status_blk.msi = status_blk;
+	bnapi->hw_tx_cons_ptr =
+		&bnapi->status_blk.msi->status_tx_quick_consumer_index0;
+	bnapi->hw_rx_cons_ptr =
+		&bnapi->status_blk.msi->status_rx_quick_consumer_index0;
 	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
 		for (i = 1; i < BNX2_MAX_MSIX_VEC; i++) {
-			struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+			struct status_block_msix *sblk;
+
+			bnapi = &bp->bnx2_napi[i];
 
-			bnapi->status_blk_msix = (void *)
-				((unsigned long) bp->status_blk +
-				 BNX2_SBLK_MSIX_ALIGN_SIZE * i);
+			sblk = (void *) (status_blk +
+					 BNX2_SBLK_MSIX_ALIGN_SIZE * i);
+			bnapi->status_blk.msix = sblk;
+			bnapi->hw_tx_cons_ptr =
+				&sblk->status_tx_quick_consumer_index;
+			bnapi->hw_rx_cons_ptr =
+				&sblk->status_rx_quick_consumer_index;
 			bnapi->int_num = i << 24;
 		}
 	}
 
-	bp->stats_blk = (void *) ((unsigned long) bp->status_blk +
-				  status_blk_size);
+	bp->stats_blk = status_blk + status_blk_size;
 
 	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
 
@@ -2515,7 +2529,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 static int
 bnx2_phy_event_is_set(struct bnx2 *bp, struct bnx2_napi *bnapi, u32 event)
 {
-	struct status_block *sblk = bnapi->status_blk;
+	struct status_block *sblk = bnapi->status_blk.msi;
 	u32 new_link_state, old_link_state;
 	int is_set = 1;
 
@@ -2551,11 +2565,9 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 {
 	u16 cons;
 
-	if (bnapi->int_num == 0)
-		cons = bnapi->status_blk->status_tx_quick_consumer_index0;
-	else
-		cons = bnapi->status_blk_msix->status_tx_quick_consumer_index;
-
+	/* Tell compiler that status block fields can change. */
+	barrier();
+	cons = *bnapi->hw_tx_cons_ptr;
 	if (unlikely((cons & MAX_TX_DESC_CNT) == MAX_TX_DESC_CNT))
 		cons++;
 	return cons;
@@ -2822,11 +2834,9 @@ bnx2_get_hw_rx_cons(struct bnx2_napi *bnapi)
 {
 	u16 cons;
 
-	if (bnapi->int_num == 0)
-		cons = bnapi->status_blk->status_rx_quick_consumer_index0;
-	else
-		cons = bnapi->status_blk_msix->status_rx_quick_consumer_index;
-
+	/* Tell compiler that status block fields can change. */
+	barrier();
+	cons = *bnapi->hw_rx_cons_ptr;
 	if (unlikely((cons & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT))
 		cons++;
 	return cons;
@@ -2990,7 +3000,7 @@ bnx2_msi(int irq, void *dev_instance)
 	struct bnx2 *bp = netdev_priv(dev);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
-	prefetch(bnapi->status_blk);
+	prefetch(bnapi->status_blk.msi);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
 		BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
@@ -3011,7 +3021,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	struct bnx2 *bp = netdev_priv(dev);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
-	prefetch(bnapi->status_blk);
+	prefetch(bnapi->status_blk.msi);
 
 	/* Return here if interrupt is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
@@ -3028,7 +3038,7 @@ bnx2_interrupt(int irq, void *dev_instance)
 	struct net_device *dev = dev_instance;
 	struct bnx2 *bp = netdev_priv(dev);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
-	struct status_block *sblk = bnapi->status_blk;
+	struct status_block *sblk = bnapi->status_blk.msi;
 
 	/* When using INTx, it is possible for the interrupt to arrive
 	 * at the CPU before the status block posted prior to the
@@ -3069,7 +3079,7 @@ bnx2_tx_msix(int irq, void *dev_instance)
 	struct bnx2 *bp = netdev_priv(dev);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[BNX2_TX_VEC];
 
-	prefetch(bnapi->status_blk_msix);
+	prefetch(bnapi->status_blk.msix);
 
 	/* Return here if interrupt is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
@@ -3079,19 +3089,28 @@ bnx2_tx_msix(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-#define STATUS_ATTN_EVENTS	(STATUS_ATTN_BITS_LINK_STATE | \
-				 STATUS_ATTN_BITS_TIMER_ABORT)
-
 static inline int
-bnx2_has_work(struct bnx2_napi *bnapi)
+bnx2_has_fast_work(struct bnx2_napi *bnapi)
 {
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
-	struct status_block *sblk = bnapi->status_blk;
 
 	if ((bnx2_get_hw_rx_cons(bnapi) != rxr->rx_cons) ||
 	    (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons))
 		return 1;
+	return 0;
+}
+
+#define STATUS_ATTN_EVENTS	(STATUS_ATTN_BITS_LINK_STATE | \
+				 STATUS_ATTN_BITS_TIMER_ABORT)
+
+static inline int
+bnx2_has_work(struct bnx2_napi *bnapi)
+{
+	struct status_block *sblk = bnapi->status_blk.msi;
+
+	if (bnx2_has_fast_work(bnapi))
+		return 1;
 
 	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
 	    (sblk->status_attn_bits_ack & STATUS_ATTN_EVENTS))
@@ -3106,7 +3125,7 @@ static int bnx2_tx_poll(struct napi_struct *napi, int budget)
 	struct bnx2 *bp = bnapi->bp;
 	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	int work_done = 0;
-	struct status_block_msix *sblk = bnapi->status_blk_msix;
+	struct status_block_msix *sblk = bnapi->status_blk.msix;
 
 	do {
 		work_done += bnx2_tx_int(bp, bnapi, budget - work_done);
@@ -3124,12 +3143,9 @@ static int bnx2_tx_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
-			  int work_done, int budget)
+static int bnx2_poll_link(struct bnx2 *bp, struct bnx2_napi *bnapi)
 {
-	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
-	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
-	struct status_block *sblk = bnapi->status_blk;
+	struct status_block *sblk = bnapi->status_blk.msi;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
 
@@ -3145,6 +3161,13 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 		       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
 		REG_RD(bp, BNX2_HC_COMMAND);
 	}
+}
+
+static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
+			  int work_done, int budget)
+{
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+	struct bnx2_rx_ring_info *rxr = &bnapi->rx_ring;
 
 	if (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons)
 		bnx2_tx_int(bp, bnapi, 0);
@@ -3160,9 +3183,11 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
 	struct bnx2 *bp = bnapi->bp;
 	int work_done = 0;
-	struct status_block *sblk = bnapi->status_blk;
+	struct status_block *sblk = bnapi->status_blk.msi;
 
 	while (1) {
+		bnx2_poll_link(bp, bnapi);
+
 		work_done = bnx2_poll_work(bp, bnapi, work_done, budget);
 
 		if (unlikely(work_done >= budget))
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1c5ce80..362bef6 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6609,8 +6609,12 @@ struct bnx2_rx_ring_info {
 struct bnx2_napi {
 	struct napi_struct	napi		____cacheline_aligned;
 	struct bnx2		*bp;
-	struct status_block	*status_blk;
-	struct status_block_msix	*status_blk_msix;
+	union {
+		struct status_block		*msi;
+		struct status_block_msix	*msix;
+	} status_blk;
+	u16			*hw_tx_cons_ptr;
+	u16			*hw_rx_cons_ptr;
 	u32 			last_status_idx;
 	u32			int_num;
 
@@ -6759,7 +6763,6 @@ struct bnx2 {
 
 	u32			stats_ticks;
 
-	struct status_block	*status_blk;
 	dma_addr_t		status_blk_mapping;
 
 	struct statistics_block	*stats_blk;
-- 
1.5.5.GIT



