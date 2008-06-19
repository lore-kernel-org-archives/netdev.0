From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/8] bnx2: Put tx ring variables in a separate struct.
Date: Wed, 18 Jun 2008 17:25:25 -0700
Message-ID: <1213835132-5698-2-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3775 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401AbYFSAXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:45 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for multi-ring support, tx ring variables are now put
in a separate bnx2_tx_ring_info struct.  Multi tx ring will not be
enabled until it is fully supported by the stack.  Only 1 tx ring
will be used at the moment.

The functions to allocate/free tx memory and to initialize tx rings
are now modified to handle multiple rings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |  294 ++++++++++++++++++++++++++++++++--------------------
 drivers/net/bnx2.h |   34 +++---
 2 files changed, 199 insertions(+), 129 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2c52d2c..61f2b4f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -226,7 +226,7 @@ static struct flash_spec flash_5709 = {
 
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
-static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_napi *bnapi)
+static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
 	u32 diff;
 
@@ -235,7 +235,7 @@ static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_napi *bnapi)
 	/* The ring uses 256 indices for 255 entries, one of them
 	 * needs to be skipped.
 	 */
-	diff = bp->tx_prod - bnapi->tx_cons;
+	diff = txr->tx_prod - txr->tx_cons;
 	if (unlikely(diff >= TX_DESC_CNT)) {
 		diff &= 0xffff;
 		if (diff == TX_DESC_CNT)
@@ -496,10 +496,54 @@ bnx2_netif_start(struct bnx2 *bp)
 }
 
 static void
+bnx2_free_tx_mem(struct bnx2 *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->num_tx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+
+		if (txr->tx_desc_ring) {
+			pci_free_consistent(bp->pdev, TXBD_RING_SIZE,
+					    txr->tx_desc_ring,
+					    txr->tx_desc_mapping);
+			txr->tx_desc_ring = NULL;
+		}
+		kfree(txr->tx_buf_ring);
+		txr->tx_buf_ring = NULL;
+	}
+}
+
+static int
+bnx2_alloc_tx_mem(struct bnx2 *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->num_tx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+
+		txr->tx_buf_ring = kzalloc(SW_TXBD_RING_SIZE, GFP_KERNEL);
+		if (txr->tx_buf_ring == NULL)
+			return -ENOMEM;
+
+		txr->tx_desc_ring =
+			pci_alloc_consistent(bp->pdev, TXBD_RING_SIZE,
+					     &txr->tx_desc_mapping);
+		if (txr->tx_desc_ring == NULL)
+			return -ENOMEM;
+	}
+	return 0;
+}
+
+static void
 bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
 
+	bnx2_free_tx_mem(bp);
+
 	for (i = 0; i < bp->ctx_pages; i++) {
 		if (bp->ctx_blk[i]) {
 			pci_free_consistent(bp->pdev, BCM_PAGE_SIZE,
@@ -514,13 +558,6 @@ bnx2_free_mem(struct bnx2 *bp)
 		bp->status_blk = NULL;
 		bp->stats_blk = NULL;
 	}
-	if (bp->tx_desc_ring) {
-		pci_free_consistent(bp->pdev, TXBD_RING_SIZE,
-				    bp->tx_desc_ring, bp->tx_desc_mapping);
-		bp->tx_desc_ring = NULL;
-	}
-	kfree(bp->tx_buf_ring);
-	bp->tx_buf_ring = NULL;
 	for (i = 0; i < bp->rx_max_ring; i++) {
 		if (bp->rx_desc_ring[i])
 			pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
@@ -545,16 +582,7 @@ bnx2_free_mem(struct bnx2 *bp)
 static int
 bnx2_alloc_mem(struct bnx2 *bp)
 {
-	int i, status_blk_size;
-
-	bp->tx_buf_ring = kzalloc(SW_TXBD_RING_SIZE, GFP_KERNEL);
-	if (bp->tx_buf_ring == NULL)
-		return -ENOMEM;
-
-	bp->tx_desc_ring = pci_alloc_consistent(bp->pdev, TXBD_RING_SIZE,
-						&bp->tx_desc_mapping);
-	if (bp->tx_desc_ring == NULL)
-		goto alloc_mem_err;
+	int i, status_blk_size, err;
 
 	bp->rx_buf_ring = vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
 	if (bp->rx_buf_ring == NULL)
@@ -634,6 +662,11 @@ bnx2_alloc_mem(struct bnx2 *bp)
 				goto alloc_mem_err;
 		}
 	}
+
+	err = bnx2_alloc_tx_mem(bp);
+	if (err)
+		goto alloc_mem_err;
+
 	return 0;
 
 alloc_mem_err:
@@ -2483,11 +2516,12 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 static int
 bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 {
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	u16 hw_cons, sw_cons, sw_ring_cons;
 	int tx_pkt = 0;
 
 	hw_cons = bnx2_get_hw_tx_cons(bnapi);
-	sw_cons = bnapi->tx_cons;
+	sw_cons = txr->tx_cons;
 
 	while (sw_cons != hw_cons) {
 		struct sw_bd *tx_buf;
@@ -2496,7 +2530,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		sw_ring_cons = TX_RING_IDX(sw_cons);
 
-		tx_buf = &bp->tx_buf_ring[sw_ring_cons];
+		tx_buf = &txr->tx_buf_ring[sw_ring_cons];
 		skb = tx_buf->skb;
 
 		/* partial BD completions possible with TSO packets */
@@ -2526,7 +2560,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 			pci_unmap_page(bp->pdev,
 				pci_unmap_addr(
-					&bp->tx_buf_ring[TX_RING_IDX(sw_cons)],
+					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
 				       	mapping),
 				skb_shinfo(skb)->frags[i].size,
 				PCI_DMA_TODEVICE);
@@ -2542,8 +2576,8 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	}
 
-	bnapi->hw_tx_cons = hw_cons;
-	bnapi->tx_cons = sw_cons;
+	txr->hw_tx_cons = hw_cons;
+	txr->tx_cons = sw_cons;
 	/* Need to make the tx_cons update visible to bnx2_start_xmit()
 	 * before checking for netif_queue_stopped().  Without the
 	 * memory barrier, there is a small possibility that bnx2_start_xmit()
@@ -2552,10 +2586,10 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	smp_mb();
 
 	if (unlikely(netif_queue_stopped(bp->dev)) &&
-		     (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh)) {
+		     (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)) {
 		netif_tx_lock(bp->dev);
 		if ((netif_queue_stopped(bp->dev)) &&
-		    (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh))
+		    (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh))
 			netif_wake_queue(bp->dev);
 		netif_tx_unlock(bp->dev);
 	}
@@ -2997,10 +3031,11 @@ bnx2_tx_msix(int irq, void *dev_instance)
 static inline int
 bnx2_has_work(struct bnx2_napi *bnapi)
 {
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	struct status_block *sblk = bnapi->status_blk;
 
 	if ((bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons) ||
-	    (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons))
+	    (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons))
 		return 1;
 
 	if ((sblk->status_attn_bits & STATUS_ATTN_EVENTS) !=
@@ -3014,6 +3049,7 @@ static int bnx2_tx_poll(struct napi_struct *napi, int budget)
 {
 	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
 	struct bnx2 *bp = bnapi->bp;
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	int work_done = 0;
 	struct status_block_msix *sblk = bnapi->status_blk_msix;
 
@@ -3024,7 +3060,7 @@ static int bnx2_tx_poll(struct napi_struct *napi, int budget)
 
 		bnapi->last_status_idx = sblk->status_idx;
 		rmb();
-	} while (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons);
+	} while (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons);
 
 	netif_rx_complete(bp->dev, napi);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
@@ -3036,6 +3072,7 @@ static int bnx2_tx_poll(struct napi_struct *napi, int budget)
 static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 			  int work_done, int budget)
 {
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 	struct status_block *sblk = bnapi->status_blk;
 	u32 status_attn_bits = sblk->status_attn_bits;
 	u32 status_attn_bits_ack = sblk->status_attn_bits_ack;
@@ -3053,7 +3090,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 		REG_RD(bp, BNX2_HC_COMMAND);
 	}
 
-	if (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons)
+	if (bnx2_get_hw_tx_cons(bnapi) != txr->hw_tx_cons)
 		bnx2_tx_int(bp, bnapi, 0);
 
 	if (bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons)
@@ -4494,13 +4531,15 @@ static void
 bnx2_clear_ring_states(struct bnx2 *bp)
 {
 	struct bnx2_napi *bnapi;
+	struct bnx2_tx_ring_info *txr;
 	int i;
 
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		bnapi = &bp->bnx2_napi[i];
+		txr = &bnapi->tx_ring;
 
-		bnapi->tx_cons = 0;
-		bnapi->hw_tx_cons = 0;
+		txr->tx_cons = 0;
+		txr->hw_tx_cons = 0;
 		bnapi->rx_prod_bseq = 0;
 		bnapi->rx_prod = 0;
 		bnapi->rx_cons = 0;
@@ -4510,7 +4549,7 @@ bnx2_clear_ring_states(struct bnx2 *bp)
 }
 
 static void
-bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
+bnx2_init_tx_context(struct bnx2 *bp, u32 cid, struct bnx2_tx_ring_info *txr)
 {
 	u32 val, offset0, offset1, offset2, offset3;
 	u32 cid_addr = GET_CID_ADDR(cid);
@@ -4532,43 +4571,43 @@ bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
 	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
 	bnx2_ctx_wr(bp, cid_addr, offset1, val);
 
-	val = (u64) bp->tx_desc_mapping >> 32;
+	val = (u64) txr->tx_desc_mapping >> 32;
 	bnx2_ctx_wr(bp, cid_addr, offset2, val);
 
-	val = (u64) bp->tx_desc_mapping & 0xffffffff;
+	val = (u64) txr->tx_desc_mapping & 0xffffffff;
 	bnx2_ctx_wr(bp, cid_addr, offset3, val);
 }
 
 static void
-bnx2_init_tx_ring(struct bnx2 *bp)
+bnx2_init_tx_ring(struct bnx2 *bp, int ring_num)
 {
 	struct tx_bd *txbd;
 	u32 cid = TX_CID;
 	struct bnx2_napi *bnapi;
+	struct bnx2_tx_ring_info *txr;
 
-	bp->tx_vec = 0;
-	if (bp->flags & BNX2_FLAG_USING_MSIX) {
-		cid = TX_TSS_CID;
-		bp->tx_vec = BNX2_TX_VEC;
-		REG_WR(bp, BNX2_TSCH_TSS_CFG, BNX2_TX_INT_NUM |
-		       (TX_TSS_CID << 7));
-	}
-	bnapi = &bp->bnx2_napi[bp->tx_vec];
+	bnapi = &bp->bnx2_napi[ring_num];
+	txr = &bnapi->tx_ring;
+
+	if (ring_num == 0)
+		cid = TX_CID;
+	else
+		cid = TX_TSS_CID + ring_num - 1;
 
 	bp->tx_wake_thresh = bp->tx_ring_size / 2;
 
-	txbd = &bp->tx_desc_ring[MAX_TX_DESC_CNT];
+	txbd = &txr->tx_desc_ring[MAX_TX_DESC_CNT];
 
-	txbd->tx_bd_haddr_hi = (u64) bp->tx_desc_mapping >> 32;
-	txbd->tx_bd_haddr_lo = (u64) bp->tx_desc_mapping & 0xffffffff;
+	txbd->tx_bd_haddr_hi = (u64) txr->tx_desc_mapping >> 32;
+	txbd->tx_bd_haddr_lo = (u64) txr->tx_desc_mapping & 0xffffffff;
 
-	bp->tx_prod = 0;
-	bp->tx_prod_bseq = 0;
+	txr->tx_prod = 0;
+	txr->tx_prod_bseq = 0;
 
-	bp->tx_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BIDX;
-	bp->tx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BSEQ;
+	txr->tx_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BIDX;
+	txr->tx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BSEQ;
 
-	bnx2_init_tx_context(bp, cid);
+	bnx2_init_tx_context(bp, cid, txr);
 }
 
 static void
@@ -4665,6 +4704,24 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bnapi->rx_prod_bseq);
 }
 
+static void
+bnx2_init_all_rings(struct bnx2 *bp)
+{
+	int i;
+
+	bnx2_clear_ring_states(bp);
+
+	REG_WR(bp, BNX2_TSCH_TSS_CFG, 0);
+	for (i = 0; i < bp->num_tx_rings; i++)
+		bnx2_init_tx_ring(bp, i);
+
+	if (bp->num_tx_rings > 1)
+		REG_WR(bp, BNX2_TSCH_TSS_CFG, ((bp->num_tx_rings - 1) << 24) |
+		       (TX_TSS_CID << 7));
+
+	bnx2_init_rx_ring(bp);
+}
+
 static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 {
 	u32 max, num_rings = 1;
@@ -4728,36 +4785,42 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 {
 	int i;
 
-	if (bp->tx_buf_ring == NULL)
-		return;
-
-	for (i = 0; i < TX_DESC_CNT; ) {
-		struct sw_bd *tx_buf = &bp->tx_buf_ring[i];
-		struct sk_buff *skb = tx_buf->skb;
-		int j, last;
+	for (i = 0; i < bp->num_tx_rings; i++) {
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
+		int j;
 
-		if (skb == NULL) {
-			i++;
+		if (txr->tx_buf_ring == NULL)
 			continue;
-		}
 
-		pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+		for (j = 0; j < TX_DESC_CNT; ) {
+			struct sw_bd *tx_buf = &txr->tx_buf_ring[j];
+			struct sk_buff *skb = tx_buf->skb;
+			int k, last;
+
+			if (skb == NULL) {
+				j++;
+				continue;
+			}
+
+			pci_unmap_single(bp->pdev,
+					 pci_unmap_addr(tx_buf, mapping),
 			skb_headlen(skb), PCI_DMA_TODEVICE);
 
-		tx_buf->skb = NULL;
+			tx_buf->skb = NULL;
 
-		last = skb_shinfo(skb)->nr_frags;
-		for (j = 0; j < last; j++) {
-			tx_buf = &bp->tx_buf_ring[i + j + 1];
-			pci_unmap_page(bp->pdev,
-				pci_unmap_addr(tx_buf, mapping),
-				skb_shinfo(skb)->frags[j].size,
-				PCI_DMA_TODEVICE);
+			last = skb_shinfo(skb)->nr_frags;
+			for (k = 0; k < last; k++) {
+				tx_buf = &txr->tx_buf_ring[j + k + 1];
+				pci_unmap_page(bp->pdev,
+					pci_unmap_addr(tx_buf, mapping),
+					skb_shinfo(skb)->frags[j].size,
+					PCI_DMA_TODEVICE);
+			}
+			dev_kfree_skb(skb);
+			j += k + 1;
 		}
-		dev_kfree_skb(skb);
-		i += j + 1;
 	}
-
 }
 
 static void
@@ -4806,9 +4869,7 @@ bnx2_reset_nic(struct bnx2 *bp, u32 reset_code)
 	if ((rc = bnx2_init_chip(bp)) != 0)
 		return rc;
 
-	bnx2_clear_ring_states(bp);
-	bnx2_init_tx_ring(bp);
-	bnx2_init_rx_ring(bp);
+	bnx2_init_all_rings(bp);
 	return 0;
 }
 
@@ -5081,11 +5142,11 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	struct l2_fhdr *rx_hdr;
 	int ret = -ENODEV;
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0], *tx_napi;
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 
 	tx_napi = bnapi;
-	if (bp->flags & BNX2_FLAG_USING_MSIX)
-		tx_napi = &bp->bnx2_napi[BNX2_TX_VEC];
 
+	txr = &tx_napi->tx_ring;
 	if (loopback_mode == BNX2_MAC_LOOPBACK) {
 		bp->loopback = MAC_LOOPBACK;
 		bnx2_set_mac_loopback(bp);
@@ -5123,7 +5184,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 
 	num_pkts = 0;
 
-	txbd = &bp->tx_desc_ring[TX_RING_IDX(bp->tx_prod)];
+	txbd = &txr->tx_desc_ring[TX_RING_IDX(txr->tx_prod)];
 
 	txbd->tx_bd_haddr_hi = (u64) map >> 32;
 	txbd->tx_bd_haddr_lo = (u64) map & 0xffffffff;
@@ -5131,11 +5192,11 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	txbd->tx_bd_vlan_tag_flags = TX_BD_FLAGS_START | TX_BD_FLAGS_END;
 
 	num_pkts++;
-	bp->tx_prod = NEXT_TX_BD(bp->tx_prod);
-	bp->tx_prod_bseq += pkt_size;
+	txr->tx_prod = NEXT_TX_BD(txr->tx_prod);
+	txr->tx_prod_bseq += pkt_size;
 
-	REG_WR16(bp, bp->tx_bidx_addr, bp->tx_prod);
-	REG_WR(bp, bp->tx_bseq_addr, bp->tx_prod_bseq);
+	REG_WR16(bp, txr->tx_bidx_addr, txr->tx_prod);
+	REG_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
 
 	udelay(100);
 
@@ -5149,7 +5210,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
 	dev_kfree_skb(skb);
 
-	if (bnx2_get_hw_tx_cons(tx_napi) != bp->tx_prod)
+	if (bnx2_get_hw_tx_cons(tx_napi) != txr->tx_prod)
 		goto loopback_test_done;
 
 	rx_idx = bnx2_get_hw_rx_cons(bnapi);
@@ -5527,20 +5588,18 @@ bnx2_enable_msix(struct bnx2 *bp)
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		msix_ent[i].entry = i;
 		msix_ent[i].vector = 0;
+
+		strcpy(bp->irq_tbl[i].name, bp->dev->name);
+		if (i == 0)
+			bp->irq_tbl[i].handler = bnx2_msi_1shot;
+		else
+			bp->irq_tbl[i].handler = bnx2_tx_msix;
 	}
 
 	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
 	if (rc != 0)
 		return;
 
-	bp->irq_tbl[BNX2_BASE_VEC].handler = bnx2_msi_1shot;
-	bp->irq_tbl[BNX2_TX_VEC].handler = bnx2_tx_msix;
-
-	strcpy(bp->irq_tbl[BNX2_BASE_VEC].name, bp->dev->name);
-	strcat(bp->irq_tbl[BNX2_BASE_VEC].name, "-base");
-	strcpy(bp->irq_tbl[BNX2_TX_VEC].name, bp->dev->name);
-	strcat(bp->irq_tbl[BNX2_TX_VEC].name, "-tx");
-
 	bp->irq_nvecs = BNX2_MAX_MSIX_VEC;
 	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
@@ -5571,6 +5630,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 			bp->irq_tbl[0].vector = bp->pdev->irq;
 		}
 	}
+	bp->num_tx_rings = 1;
 }
 
 /* Called with rtnl_lock */
@@ -5585,12 +5645,15 @@ bnx2_open(struct net_device *dev)
 	bnx2_set_power_state(bp, PCI_D0);
 	bnx2_disable_int(bp);
 
+	bnx2_setup_int_mode(bp, disable_msi);
+	bnx2_napi_enable(bp);
 	rc = bnx2_alloc_mem(bp);
-	if (rc)
+	if (rc) {
+		bnx2_napi_disable(bp);
+		bnx2_free_mem(bp);
 		return rc;
+	}
 
-	bnx2_setup_int_mode(bp, disable_msi);
-	bnx2_napi_enable(bp);
 	rc = bnx2_request_irq(bp);
 
 	if (rc) {
@@ -5711,9 +5774,10 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[bp->tx_vec];
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
 
-	if (unlikely(bnx2_tx_avail(bp, bnapi) <
+	if (unlikely(bnx2_tx_avail(bp, txr) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
 		printk(KERN_ERR PFX "%s: BUG! Tx ring full when queue awake!\n",
@@ -5722,7 +5786,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 	len = skb_headlen(skb);
-	prod = bp->tx_prod;
+	prod = txr->tx_prod;
 	ring_prod = TX_RING_IDX(prod);
 
 	vlan_tag_flags = 0;
@@ -5784,11 +5848,11 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
-	tx_buf = &bp->tx_buf_ring[ring_prod];
+	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
 	pci_unmap_addr_set(tx_buf, mapping, mapping);
 
-	txbd = &bp->tx_desc_ring[ring_prod];
+	txbd = &txr->tx_desc_ring[ring_prod];
 
 	txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
 	txbd->tx_bd_haddr_lo = (u64) mapping & 0xffffffff;
@@ -5802,12 +5866,12 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		prod = NEXT_TX_BD(prod);
 		ring_prod = TX_RING_IDX(prod);
-		txbd = &bp->tx_desc_ring[ring_prod];
+		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
 		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
 			len, PCI_DMA_TODEVICE);
-		pci_unmap_addr_set(&bp->tx_buf_ring[ring_prod],
+		pci_unmap_addr_set(&txr->tx_buf_ring[ring_prod],
 				mapping, mapping);
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
@@ -5819,19 +5883,19 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txbd->tx_bd_vlan_tag_flags |= TX_BD_FLAGS_END;
 
 	prod = NEXT_TX_BD(prod);
-	bp->tx_prod_bseq += skb->len;
+	txr->tx_prod_bseq += skb->len;
 
-	REG_WR16(bp, bp->tx_bidx_addr, prod);
-	REG_WR(bp, bp->tx_bseq_addr, bp->tx_prod_bseq);
+	REG_WR16(bp, txr->tx_bidx_addr, prod);
+	REG_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
 
 	mmiowb();
 
-	bp->tx_prod = prod;
+	txr->tx_prod = prod;
 	dev->trans_start = jiffies;
 
-	if (unlikely(bnx2_tx_avail(bp, bnapi) <= MAX_SKB_FRAGS)) {
+	if (unlikely(bnx2_tx_avail(bp, txr) <= MAX_SKB_FRAGS)) {
 		netif_stop_queue(dev);
-		if (bnx2_tx_avail(bp, bnapi) > bp->tx_wake_thresh)
+		if (bnx2_tx_avail(bp, txr) > bp->tx_wake_thresh)
 			netif_wake_queue(dev);
 	}
 
@@ -7390,15 +7454,19 @@ static void __devinit
 bnx2_init_napi(struct bnx2 *bp)
 {
 	int i;
-	struct bnx2_napi *bnapi;
 
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
-		bnapi = &bp->bnx2_napi[i];
+		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+		int (*poll)(struct napi_struct *, int);
+
+		if (i == 0)
+			poll = bnx2_poll;
+		else
+			poll = bnx2_tx_poll;
+
+		netif_napi_add(bp->dev, &bp->bnx2_napi[i].napi, poll, 64);
 		bnapi->bp = bp;
 	}
-	netif_napi_add(bp->dev, &bp->bnx2_napi[0].napi, bnx2_poll, 64);
-	netif_napi_add(bp->dev, &bp->bnx2_napi[BNX2_TX_VEC].napi, bnx2_tx_poll,
-		       64);
 }
 
 static int __devinit
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index be7ccb5..e4f0fb4 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6569,6 +6569,21 @@ struct bnx2_irq {
 	char		name[16];
 };
 
+struct bnx2_tx_ring_info {
+	u32			tx_prod_bseq;
+	u16			tx_prod;
+	u32			tx_bidx_addr;
+	u32			tx_bseq_addr;
+
+	struct tx_bd		*tx_desc_ring;
+	struct sw_bd		*tx_buf_ring;
+
+	u16			tx_cons;
+	u16			hw_tx_cons;
+
+	dma_addr_t		tx_desc_mapping;
+};
+
 struct bnx2_napi {
 	struct napi_struct	napi		____cacheline_aligned;
 	struct bnx2		*bp;
@@ -6577,9 +6592,6 @@ struct bnx2_napi {
 	u32 			last_status_idx;
 	u32			int_num;
 
-	u16			tx_cons;
-	u16			hw_tx_cons;
-
 	u32			rx_prod_bseq;
 	u16			rx_prod;
 	u16			rx_cons;
@@ -6587,6 +6599,7 @@ struct bnx2_napi {
 	u16			rx_pg_prod;
 	u16			rx_pg_cons;
 
+	struct bnx2_tx_ring_info	tx_ring;
 };
 
 struct bnx2 {
@@ -6614,14 +6627,6 @@ struct bnx2 {
 					 BNX2_FLAG_USING_MSIX)
 #define BNX2_FLAG_JUMBO_BROKEN		0x00000800
 
-	/* Put tx producer and consumer fields in separate cache lines. */
-
-	u32		tx_prod_bseq __attribute__((aligned(L1_CACHE_BYTES)));
-	u16		tx_prod;
-	u8		tx_vec;
-	u32		tx_bidx_addr;
-	u32		tx_bseq_addr;
-
 	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
 #ifdef BCM_VLAN
@@ -6643,8 +6648,6 @@ struct bnx2 {
 	struct rx_bd		*rx_pg_desc_ring[MAX_RX_PG_RINGS];
 
 	/* TX constants */
-	struct tx_bd	*tx_desc_ring;
-	struct sw_bd	*tx_buf_ring;
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
 
@@ -6722,9 +6725,6 @@ struct bnx2 {
 	u16			fw_wr_seq;
 	u16			fw_drv_pulse_wr_seq;
 
-	dma_addr_t		tx_desc_mapping;
-
-
 	int			rx_max_ring;
 	int			rx_ring_size;
 	dma_addr_t		rx_desc_mapping[MAX_RX_RINGS];
@@ -6812,6 +6812,8 @@ struct bnx2 {
 
 	struct bnx2_irq		irq_tbl[BNX2_MAX_MSIX_VEC];
 	int			irq_nvecs;
+
+	u8			num_tx_rings;
 };
 
 #define REG_RD(bp, offset)					\
-- 
1.5.5.GIT



