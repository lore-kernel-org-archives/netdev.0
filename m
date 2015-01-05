From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: support TX batching using skb->xmit_more flag
Date: Mon, 5 Jan 2015 05:48:34 -0500
Message-ID: <1420454914-9516-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:30182 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbbAEKqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 05:46:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses skb->xmit_more flag to batch TX requests.
TX is flushed either when xmit_more is false or there is
no more space in the TXQ.

Skyhawk-R and BEx chips require an even number of wrbs to be posted.
So, when a batch of TX requests is accumulated, the last header wrb
may need to be fixed with an extra dummy wrb.

This patch refactors be_xmit() routine as a sequence of be_xmit_enqueue()
and be_xmit_flush() calls. The Tx completion code is also
updated to be able to unmap/free a batch of skbs rather than a single
skb.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |   4 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   2 -
 drivers/net/ethernet/emulex/benet/be_hw.h      |   5 +
 drivers/net/ethernet/emulex/benet/be_main.c    | 244 +++++++++++++------------
 4 files changed, 136 insertions(+), 119 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 712e7f8..9fa2569 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -243,7 +243,6 @@ struct be_tx_stats {
 	u64 tx_bytes;
 	u64 tx_pkts;
 	u64 tx_reqs;
-	u64 tx_wrbs;
 	u64 tx_compl;
 	ulong tx_jiffies;
 	u32 tx_stops;
@@ -266,6 +265,9 @@ struct be_tx_obj {
 	/* Remember the skbs that were transmitted */
 	struct sk_buff *sent_skb_list[TX_Q_LEN];
 	struct be_tx_stats stats;
+	u16 pend_wrb_cnt;	/* Number of WRBs yet to be given to HW */
+	u16 last_req_wrb_cnt;	/* wrb cnt of the last req in the Q */
+	u16 last_req_hdr;	/* index of the last req's hdr-wrb */
 } ____cacheline_aligned_in_smp;
 
 /* Struct to remember the pages posted for rx frags */
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 73a500c..32c53bc 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -193,8 +193,6 @@ static const struct be_ethtool_stat et_tx_stats[] = {
 	{DRVSTAT_TX_INFO(tx_pkts)},
 	/* Number of skbs queued for trasmission by the driver */
 	{DRVSTAT_TX_INFO(tx_reqs)},
-	/* Number of TX work request blocks DMAed to HW */
-	{DRVSTAT_TX_INFO(tx_wrbs)},
 	/* Number of times the TX queue was stopped due to lack
 	 * of spaces in the TXQ.
 	 */
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 295ee08..6d7b3a4 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -311,6 +311,11 @@ struct amap_eth_hdr_wrb {
 	u8 vlan_tag[16];
 } __packed;
 
+#define TX_HDR_WRB_COMPL		1		/* word 2 */
+#define TX_HDR_WRB_EVT			(1 << 1)	/* word 2 */
+#define TX_HDR_WRB_NUM_SHIFT		13		/* word 2: bits 13:17 */
+#define TX_HDR_WRB_NUM_MASK		0x1F		/* word 2: bits 13:17 */
+
 struct be_eth_hdr_wrb {
 	u32 dw[4];
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 41a0a54..37a26b0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -662,41 +662,22 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 		netif_carrier_off(netdev);
 }
 
-static void be_tx_stats_update(struct be_tx_obj *txo,
-			       u32 wrb_cnt, u32 copied, u32 gso_segs,
-			       bool stopped)
+static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
 {
 	struct be_tx_stats *stats = tx_stats(txo);
 
 	u64_stats_update_begin(&stats->sync);
 	stats->tx_reqs++;
-	stats->tx_wrbs += wrb_cnt;
-	stats->tx_bytes += copied;
-	stats->tx_pkts += (gso_segs ? gso_segs : 1);
-	if (stopped)
-		stats->tx_stops++;
+	stats->tx_bytes += skb->len;
+	stats->tx_pkts += (skb_shinfo(skb)->gso_segs ? : 1);
 	u64_stats_update_end(&stats->sync);
 }
 
-/* Determine number of WRB entries needed to xmit data in an skb */
-static u32 wrb_cnt_for_skb(struct be_adapter *adapter, struct sk_buff *skb,
-			   bool *dummy)
+/* Returns number of WRBs needed for the skb */
+static u32 skb_wrb_cnt(struct sk_buff *skb)
 {
-	int cnt = (skb->len > skb->data_len);
-
-	cnt += skb_shinfo(skb)->nr_frags;
-
-	/* to account for hdr wrb */
-	cnt++;
-	if (lancer_chip(adapter) || !(cnt & 1)) {
-		*dummy = false;
-	} else {
-		/* add a dummy to make it an even num */
-		cnt++;
-		*dummy = true;
-	}
-	BUG_ON(cnt > BE_MAX_TX_FRAG_COUNT);
-	return cnt;
+	/* +1 for the header wrb */
+	return 1 + (skb_headlen(skb) ? 1 : 0) + skb_shinfo(skb)->nr_frags;
 }
 
 static inline void wrb_fill(struct be_eth_wrb *wrb, u64 addr, int len)
@@ -770,11 +751,14 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		SET_TX_WRB_HDR_BITS(vlan_tag, hdr, vlan_tag);
 	}
 
-	/* To skip HW VLAN tagging: evt = 1, compl = 0 */
-	SET_TX_WRB_HDR_BITS(complete, hdr, !skip_hw_vlan);
-	SET_TX_WRB_HDR_BITS(event, hdr, 1);
 	SET_TX_WRB_HDR_BITS(num_wrb, hdr, wrb_cnt);
 	SET_TX_WRB_HDR_BITS(len, hdr, len);
+
+	/* Hack to skip HW VLAN tagging needs evt = 1, compl = 0
+	 * When this hack is not needed, the evt bit is set while ringing DB
+	 */
+	if (skip_hw_vlan)
+		SET_TX_WRB_HDR_BITS(event, hdr, 1);
 }
 
 static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
@@ -794,22 +778,24 @@ static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 	}
 }
 
-static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
-			struct sk_buff *skb, u32 wrb_cnt, bool dummy_wrb,
-			bool skip_hw_vlan)
+/* Returns the number of WRBs used up by the skb */
+static u32 be_xmit_enqueue(struct be_adapter *adapter, struct be_tx_obj *txo,
+			   struct sk_buff *skb, bool skip_hw_vlan)
 {
-	dma_addr_t busaddr;
-	int i, copied = 0;
+	u32 i, copied = 0, wrb_cnt = skb_wrb_cnt(skb);
 	struct device *dev = &adapter->pdev->dev;
-	struct sk_buff *first_skb = skb;
-	struct be_eth_wrb *wrb;
+	struct be_queue_info *txq = &txo->q;
 	struct be_eth_hdr_wrb *hdr;
 	bool map_single = false;
-	u16 map_head;
+	struct be_eth_wrb *wrb;
+	dma_addr_t busaddr;
+	u16 head = txq->head;
 
 	hdr = queue_head_node(txq);
+	wrb_fill_hdr(adapter, hdr, skb, wrb_cnt, skb->len, skip_hw_vlan);
+	be_dws_cpu_to_le(hdr, sizeof(*hdr));
+
 	queue_head_inc(txq);
-	map_head = txq->head;
 
 	if (skb->len > skb->data_len) {
 		int len = skb_headlen(skb);
@@ -839,19 +825,23 @@ static int make_tx_wrbs(struct be_adapter *adapter, struct be_queue_info *txq,
 		copied += skb_frag_size(frag);
 	}
 
-	if (dummy_wrb) {
-		wrb = queue_head_node(txq);
-		wrb_fill(wrb, 0, 0);
-		be_dws_cpu_to_le(wrb, sizeof(*wrb));
-		queue_head_inc(txq);
-	}
+	BUG_ON(txo->sent_skb_list[head]);
+	txo->sent_skb_list[head] = skb;
+	txo->last_req_hdr = head;
+	atomic_add(wrb_cnt, &txq->used);
+	txo->last_req_wrb_cnt = wrb_cnt;
+	txo->pend_wrb_cnt += wrb_cnt;
 
-	wrb_fill_hdr(adapter, hdr, first_skb, wrb_cnt, copied, skip_hw_vlan);
-	be_dws_cpu_to_le(hdr, sizeof(*hdr));
+	be_tx_stats_update(txo, skb);
+	return wrb_cnt;
 
-	return copied;
 dma_err:
-	txq->head = map_head;
+	/* Bring the queue back to the state it was in before this
+	 * routine was invoked.
+	 */
+	txq->head = head;
+	/* skip the first wrb (hdr); it's not mapped */
+	queue_head_inc(txq);
 	while (copied) {
 		wrb = queue_head_node(txq);
 		unmap_tx_frag(dev, wrb, map_single);
@@ -860,6 +850,7 @@ dma_err:
 		adapter->drv_stats.dma_map_errors++;
 		queue_head_inc(txq);
 	}
+	txq->head = head;
 	return 0;
 }
 
@@ -1030,52 +1021,64 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	return skb;
 }
 
+static void be_xmit_flush(struct be_adapter *adapter, struct be_tx_obj *txo)
+{
+	struct be_queue_info *txq = &txo->q;
+	struct be_eth_hdr_wrb *hdr = queue_index_node(txq, txo->last_req_hdr);
+
+	/* Mark the last request eventable if it hasn't been marked already */
+	if (!(hdr->dw[2] & cpu_to_le32(TX_HDR_WRB_EVT)))
+		hdr->dw[2] |= cpu_to_le32(TX_HDR_WRB_EVT | TX_HDR_WRB_COMPL);
+
+	/* compose a dummy wrb if there are odd set of wrbs to notify */
+	if (!lancer_chip(adapter) && (txo->pend_wrb_cnt & 1)) {
+		wrb_fill(queue_head_node(txq), 0, 0);
+		queue_head_inc(txq);
+		atomic_inc(&txq->used);
+		txo->pend_wrb_cnt++;
+		hdr->dw[2] &= ~cpu_to_le32(TX_HDR_WRB_NUM_MASK <<
+					   TX_HDR_WRB_NUM_SHIFT);
+		hdr->dw[2] |= cpu_to_le32((txo->last_req_wrb_cnt + 1) <<
+					  TX_HDR_WRB_NUM_SHIFT);
+	}
+	be_txq_notify(adapter, txo, txo->pend_wrb_cnt);
+	txo->pend_wrb_cnt = 0;
+}
+
 static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
+	bool skip_hw_vlan = false, flush = !skb->xmit_more;
 	struct be_adapter *adapter = netdev_priv(netdev);
-	struct be_tx_obj *txo = &adapter->tx_obj[skb_get_queue_mapping(skb)];
+	u16 q_idx = skb_get_queue_mapping(skb);
+	struct be_tx_obj *txo = &adapter->tx_obj[q_idx];
 	struct be_queue_info *txq = &txo->q;
-	bool dummy_wrb, stopped = false;
-	u32 wrb_cnt = 0, copied = 0;
-	bool skip_hw_vlan = false;
-	u32 start = txq->head;
+	u16 wrb_cnt;
 
 	skb = be_xmit_workarounds(adapter, skb, &skip_hw_vlan);
-	if (!skb) {
-		tx_stats(txo)->tx_drv_drops++;
-		return NETDEV_TX_OK;
-	}
+	if (unlikely(!skb))
+		goto drop;
 
-	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
-
-	copied = make_tx_wrbs(adapter, txq, skb, wrb_cnt, dummy_wrb,
-			      skip_hw_vlan);
-	if (copied) {
-		int gso_segs = skb_shinfo(skb)->gso_segs;
-
-		/* record the sent skb in the sent_skb table */
-		BUG_ON(txo->sent_skb_list[start]);
-		txo->sent_skb_list[start] = skb;
-
-		/* Ensure txq has space for the next skb; Else stop the queue
-		 * *BEFORE* ringing the tx doorbell, so that we serialze the
-		 * tx compls of the current transmit which'll wake up the queue
-		 */
-		atomic_add(wrb_cnt, &txq->used);
-		if ((BE_MAX_TX_FRAG_COUNT + atomic_read(&txq->used)) >=
-								txq->len) {
-			netif_stop_subqueue(netdev, skb_get_queue_mapping(skb));
-			stopped = true;
-		}
-
-		be_txq_notify(adapter, txo, wrb_cnt);
-
-		be_tx_stats_update(txo, wrb_cnt, copied, gso_segs, stopped);
-	} else {
-		txq->head = start;
-		tx_stats(txo)->tx_drv_drops++;
+	wrb_cnt = be_xmit_enqueue(adapter, txo, skb, skip_hw_vlan);
+	if (unlikely(!wrb_cnt)) {
 		dev_kfree_skb_any(skb);
+		goto drop;
 	}
+
+	if ((atomic_read(&txq->used) + BE_MAX_TX_FRAG_COUNT) >= txq->len) {
+		netif_stop_subqueue(netdev, q_idx);
+		tx_stats(txo)->tx_stops++;
+	}
+
+	if (flush || __netif_subqueue_stopped(netdev, q_idx))
+		be_xmit_flush(adapter, txo);
+
+	return NETDEV_TX_OK;
+drop:
+	tx_stats(txo)->tx_drv_drops++;
+	/* Flush the already enqueued tx requests */
+	if (flush && txo->pend_wrb_cnt)
+		be_xmit_flush(adapter, txo);
+
 	return NETDEV_TX_OK;
 }
 
@@ -1959,32 +1962,34 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 static u16 be_tx_compl_process(struct be_adapter *adapter,
 			       struct be_tx_obj *txo, u16 last_index)
 {
-	struct be_queue_info *txq = &txo->q;
-	struct be_eth_wrb *wrb;
 	struct sk_buff **sent_skbs = txo->sent_skb_list;
-	struct sk_buff *sent_skb;
-	u16 cur_index, num_wrbs = 1; /* account for hdr wrb */
-	bool unmap_skb_hdr = true;
-
-	sent_skb = sent_skbs[txq->tail];
-	BUG_ON(!sent_skb);
-	sent_skbs[txq->tail] = NULL;
-
-	/* skip header wrb */
-	queue_tail_inc(txq);
+	struct be_queue_info *txq = &txo->q;
+	u16 frag_index, num_wrbs = 0;
+	struct sk_buff *skb = NULL;
+	bool unmap_skb_hdr = false;
+	struct be_eth_wrb *wrb;
 
 	do {
-		cur_index = txq->tail;
+		if (sent_skbs[txq->tail]) {
+			/* Free skb from prev req */
+			if (skb)
+				dev_consume_skb_any(skb);
+			skb = sent_skbs[txq->tail];
+			sent_skbs[txq->tail] = NULL;
+			queue_tail_inc(txq);  /* skip hdr wrb */
+			num_wrbs++;
+			unmap_skb_hdr = true;
+		}
 		wrb = queue_tail_node(txq);
+		frag_index = txq->tail;
 		unmap_tx_frag(&adapter->pdev->dev, wrb,
-			      (unmap_skb_hdr && skb_headlen(sent_skb)));
+			      (unmap_skb_hdr && skb_headlen(skb)));
 		unmap_skb_hdr = false;
-
-		num_wrbs++;
 		queue_tail_inc(txq);
-	} while (cur_index != last_index);
+		num_wrbs++;
+	} while (frag_index != last_index);
+	dev_consume_skb_any(skb);
 
-	dev_consume_skb_any(sent_skb);
 	return num_wrbs;
 }
 
@@ -2068,12 +2073,11 @@ static void be_rx_cq_clean(struct be_rx_obj *rxo)
 
 static void be_tx_compl_clean(struct be_adapter *adapter)
 {
+	u16 end_idx, notified_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
+	struct device *dev = &adapter->pdev->dev;
 	struct be_tx_obj *txo;
 	struct be_queue_info *txq;
 	struct be_eth_tx_compl *txcp;
-	u16 end_idx, cmpl = 0, timeo = 0, num_wrbs = 0;
-	struct sk_buff *sent_skb;
-	bool dummy_wrb;
 	int i, pending_txqs;
 
 	/* Stop polling for compls when HW has been silent for 10ms */
@@ -2095,7 +2099,7 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 				atomic_sub(num_wrbs, &txq->used);
 				timeo = 0;
 			}
-			if (atomic_read(&txq->used) == 0)
+			if (atomic_read(&txq->used) == txo->pend_wrb_cnt)
 				pending_txqs--;
 		}
 
@@ -2105,21 +2109,29 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 		mdelay(1);
 	} while (true);
 
+	/* Free enqueued TX that was never notified to HW */
 	for_all_tx_queues(adapter, txo, i) {
 		txq = &txo->q;
-		if (atomic_read(&txq->used))
-			dev_err(&adapter->pdev->dev, "%d pending tx-compls\n",
-				atomic_read(&txq->used));
 
-		/* free posted tx for which compls will never arrive */
-		while (atomic_read(&txq->used)) {
-			sent_skb = txo->sent_skb_list[txq->tail];
+		if (atomic_read(&txq->used)) {
+			dev_info(dev, "txq%d: cleaning %d pending tx-wrbs\n",
+				 i, atomic_read(&txq->used));
+			notified_idx = txq->tail;
 			end_idx = txq->tail;
-			num_wrbs = wrb_cnt_for_skb(adapter, sent_skb,
-						   &dummy_wrb);
-			index_adv(&end_idx, num_wrbs - 1, txq->len);
+			index_adv(&end_idx, atomic_read(&txq->used) - 1,
+				  txq->len);
+			/* Use the tx-compl process logic to handle requests
+			 * that were not sent to the HW.
+			 */
 			num_wrbs = be_tx_compl_process(adapter, txo, end_idx);
 			atomic_sub(num_wrbs, &txq->used);
+			BUG_ON(atomic_read(&txq->used));
+			txo->pend_wrb_cnt = 0;
+			/* Since hw was never notified of these requests,
+			 * reset TXQ indices
+			 */
+			txq->head = notified_idx;
+			txq->tail = notified_idx;
 		}
 	}
 }
-- 
2.2.0
