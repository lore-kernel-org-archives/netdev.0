From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 16/17] tg3: Move per-int tx members to a per-int struct
Date: Fri, 28 Aug 2009 17:03:21 -0700
Message-ID: <1251585293.29708@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2837 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbZH2WfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the tx_prod, tx_cons, tx_pending, tx_ring, and
tx_buffers transmit ring device members to a per-interrupt structure.
It also adds a new transmit producer mailbox member (prodmbox) and
converts the code to use it rather than a preprocessor constant.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |  150 +++++++++++++++++++++++++++-------------------------
 drivers/net/tg3.h |   15 +++---
 2 files changed, 86 insertions(+), 79 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 939574c..e36b0b2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -136,7 +136,7 @@
 #define TG3_RX_JMB_MAP_SZ		TG3_RX_DMA_TO_MAP_SZ(TG3_RX_JMB_DMA_SZ)
 
 /* minimum number of free TX descriptors required to wake up TX process */
-#define TG3_TX_WAKEUP_THRESH(tp)		((tp)->tx_pending / 4)
+#define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
 
 #define TG3_RAW_IP_ALIGN 2
 
@@ -656,7 +656,7 @@ static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 			work_exists = 1;
 	}
 	/* check for RX/TX work to do */
-	if (sblk->idx[0].tx_consumer != tp->tx_cons ||
+	if (sblk->idx[0].tx_consumer != tnapi->tx_cons ||
 	    sblk->idx[0].rx_producer != tnapi->rx_rcb_ptr)
 		work_exists = 1;
 
@@ -4269,11 +4269,11 @@ static void tg3_tx_recover(struct tg3 *tp)
 	spin_unlock(&tp->lock);
 }
 
-static inline u32 tg3_tx_avail(struct tg3 *tp)
+static inline u32 tg3_tx_avail(struct tg3_napi *tnapi)
 {
 	smp_mb();
-	return (tp->tx_pending -
-		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
+	return tnapi->tx_pending -
+	       ((tnapi->tx_prod - tnapi->tx_cons) & (TG3_TX_RING_SIZE - 1));
 }
 
 /* Tigon3 never reports partial packet sends.  So we do not
@@ -4284,10 +4284,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
 {
 	struct tg3 *tp = tnapi->tp;
 	u32 hw_idx = tnapi->hw_status->idx[0].tx_consumer;
-	u32 sw_idx = tp->tx_cons;
+	u32 sw_idx = tnapi->tx_cons;
 
 	while (sw_idx != hw_idx) {
-		struct tx_ring_info *ri = &tp->tx_buffers[sw_idx];
+		struct tx_ring_info *ri = &tnapi->tx_buffers[sw_idx];
 		struct sk_buff *skb = ri->skb;
 		int i, tx_bug = 0;
 
@@ -4303,7 +4303,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		sw_idx = NEXT_TX(sw_idx);
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			ri = &tp->tx_buffers[sw_idx];
+			ri = &tnapi->tx_buffers[sw_idx];
 			if (unlikely(ri->skb != NULL || sw_idx == hw_idx))
 				tx_bug = 1;
 			sw_idx = NEXT_TX(sw_idx);
@@ -4317,7 +4317,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 		}
 	}
 
-	tp->tx_cons = sw_idx;
+	tnapi->tx_cons = sw_idx;
 
 	/* Need to make the tx_cons update visible to tg3_start_xmit()
 	 * before checking for netif_queue_stopped().  Without the
@@ -4327,10 +4327,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	smp_mb();
 
 	if (unlikely(netif_queue_stopped(tp->dev) &&
-		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
+		     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
 		netif_tx_lock(tp->dev);
 		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
+		    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
 			netif_wake_queue(tp->dev);
 		netif_tx_unlock(tp->dev);
 	}
@@ -4668,7 +4668,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	}
 
 	/* run TX completion thread */
-	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
+	if (tnapi->hw_status->idx[0].tx_consumer != tnapi->tx_cons) {
 		tg3_tx(tnapi);
 		if (unlikely(tp->tg3_flags & TG3_FLAG_TX_RECOVERY_PENDING))
 			return work_done;
@@ -5044,13 +5044,14 @@ static inline int tg3_40bit_overflow_test(struct tg3 *tp, dma_addr_t mapping,
 #endif
 }
 
-static void tg3_set_txd(struct tg3 *, int, dma_addr_t, int, u32, u32);
+static void tg3_set_txd(struct tg3_napi *, int, dma_addr_t, int, u32, u32);
 
 /* Workaround 4GB and 40-bit hardware DMA bugs. */
 static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 				       u32 last_plus_one, u32 *start,
 				       u32 base_flags, u32 mss)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
 	struct sk_buff *new_skb;
 	dma_addr_t new_addr = 0;
 	u32 entry = *start;
@@ -5085,7 +5086,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 			dev_kfree_skb(new_skb);
 			new_skb = NULL;
 		} else {
-			tg3_set_txd(tp, entry, new_addr, new_skb->len,
+			tg3_set_txd(tnapi, entry, new_addr, new_skb->len,
 				    base_flags, 1 | (mss << 1));
 			*start = NEXT_TX(entry);
 		}
@@ -5094,11 +5095,10 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 	/* Now clean up the sw ring entries. */
 	i = 0;
 	while (entry != last_plus_one) {
-		if (i == 0) {
-			tp->tx_buffers[entry].skb = new_skb;
-		} else {
-			tp->tx_buffers[entry].skb = NULL;
-		}
+		if (i == 0)
+			tnapi->tx_buffers[entry].skb = new_skb;
+		else
+			tnapi->tx_buffers[entry].skb = NULL;
 		entry = NEXT_TX(entry);
 		i++;
 	}
@@ -5109,11 +5109,11 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 	return ret;
 }
 
-static void tg3_set_txd(struct tg3 *tp, int entry,
+static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
 			dma_addr_t mapping, int len, u32 flags,
 			u32 mss_and_is_end)
 {
-	struct tg3_tx_buffer_desc *txd = &tp->tx_ring[entry];
+	struct tg3_tx_buffer_desc *txd = &tnapi->tx_ring[entry];
 	int is_end = (mss_and_is_end & 0x1);
 	u32 mss = (mss_and_is_end >> 1);
 	u32 vlan_tag = 0;
@@ -5141,6 +5141,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, entry, base_flags, mss;
 	struct skb_shared_info *sp;
 	dma_addr_t mapping;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	len = skb_headlen(skb);
 
@@ -5149,7 +5150,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+	if (unlikely(tg3_tx_avail(tnapi) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 
@@ -5160,7 +5161,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	entry = tp->tx_prod;
+	entry = tnapi->tx_prod;
 	base_flags = 0;
 	mss = 0;
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
@@ -5208,9 +5209,9 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	mapping = sp->dma_head;
 
-	tp->tx_buffers[entry].skb = skb;
+	tnapi->tx_buffers[entry].skb = skb;
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
+	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 
 	entry = NEXT_TX(entry);
@@ -5225,9 +5226,9 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			len = frag->size;
 			mapping = sp->dma_maps[i];
-			tp->tx_buffers[entry].skb = NULL;
+			tnapi->tx_buffers[entry].skb = NULL;
 
-			tg3_set_txd(tp, entry, mapping, len,
+			tg3_set_txd(tnapi, entry, mapping, len,
 				    base_flags, (i == last) | (mss << 1));
 
 			entry = NEXT_TX(entry);
@@ -5235,12 +5236,12 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+	tw32_tx_mbox(tnapi->prodmbox, entry);
 
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
+	tnapi->tx_prod = entry;
+	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
+		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
 			netif_wake_queue(tp->dev);
 	}
 
@@ -5258,11 +5259,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *, struct net_device *);
 static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 {
 	struct sk_buff *segs, *nskb;
+	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
+	if (unlikely(tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)) {
 		netif_stop_queue(tp->dev);
-		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
+		if (tg3_tx_avail(&tp->napi[0]) <= frag_cnt_est)
 			return NETDEV_TX_BUSY;
 
 		netif_wake_queue(tp->dev);
@@ -5295,6 +5297,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	struct skb_shared_info *sp;
 	int would_hit_hwbug;
 	dma_addr_t mapping;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	len = skb_headlen(skb);
 
@@ -5303,7 +5306,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+	if (unlikely(tg3_tx_avail(tnapi) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 
@@ -5314,7 +5317,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	entry = tp->tx_prod;
+	entry = tnapi->tx_prod;
 	base_flags = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
@@ -5384,7 +5387,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
 	mapping = sp->dma_head;
 
-	tp->tx_buffers[entry].skb = skb;
+	tnapi->tx_buffers[entry].skb = skb;
 
 	would_hit_hwbug = 0;
 
@@ -5393,7 +5396,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	else if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	tg3_set_txd(tp, entry, mapping, len, base_flags,
+	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 
 	entry = NEXT_TX(entry);
@@ -5409,7 +5412,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			len = frag->size;
 			mapping = sp->dma_maps[i];
 
-			tp->tx_buffers[entry].skb = NULL;
+			tnapi->tx_buffers[entry].skb = NULL;
 
 			if (tg3_4g_overflow_test(mapping, len))
 				would_hit_hwbug = 1;
@@ -5418,10 +5421,10 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 				would_hit_hwbug = 1;
 
 			if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
-				tg3_set_txd(tp, entry, mapping, len,
+				tg3_set_txd(tnapi, entry, mapping, len,
 					    base_flags, (i == last)|(mss << 1));
 			else
-				tg3_set_txd(tp, entry, mapping, len,
+				tg3_set_txd(tnapi, entry, mapping, len,
 					    base_flags, (i == last));
 
 			entry = NEXT_TX(entry);
@@ -5446,12 +5449,12 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+	tw32_tx_mbox(MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW, entry);
 
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
+	tnapi->tx_prod = entry;
+	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
 		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
+		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
 			netif_wake_queue(tp->dev);
 	}
 
@@ -5522,8 +5525,8 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 static void tg3_rx_prodring_free(struct tg3 *tp,
 				 struct tg3_rx_prodring_set *tpr)
 {
-	struct ring_info *rxp;
 	int i;
+	struct ring_info *rxp;
 
 	for (i = 0; i < TG3_RX_RING_SIZE; i++) {
 		rxp = &tpr->rx_std_buffers[i];
@@ -5710,13 +5713,14 @@ err_out:
  */
 static void tg3_free_rings(struct tg3 *tp)
 {
+	struct tg3_napi *tnapi = &tp->napi[0];
 	int i;
 
 	for (i = 0; i < TG3_TX_RING_SIZE; ) {
 		struct tx_ring_info *txp;
 		struct sk_buff *skb;
 
-		txp = &tp->tx_buffers[i];
+		txp = &tnapi->tx_buffers[i];
 		skb = txp->skb;
 
 		if (skb == NULL) {
@@ -5751,7 +5755,7 @@ static int tg3_init_rings(struct tg3 *tp)
 	tg3_free_rings(tp);
 
 	/* Zero out all descriptors. */
-	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
+	memset(tnapi->tx_ring, 0, TG3_TX_RING_BYTES);
 
 	tnapi->rx_rcb_ptr = 0;
 	memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
@@ -5767,12 +5771,12 @@ static void tg3_free_consistent(struct tg3 *tp)
 {
 	struct tg3_napi *tnapi = &tp->napi[0];
 
-	kfree(tp->tx_buffers);
-	tp->tx_buffers = NULL;
-	if (tp->tx_ring) {
+	kfree(tnapi->tx_buffers);
+	tnapi->tx_buffers = NULL;
+	if (tnapi->tx_ring) {
 		pci_free_consistent(tp->pdev, TG3_TX_RING_BYTES,
-			tp->tx_ring, tp->tx_desc_mapping);
-		tp->tx_ring = NULL;
+			tnapi->tx_ring, tnapi->tx_desc_mapping);
+		tnapi->tx_ring = NULL;
 	}
 	if (tnapi->rx_rcb) {
 		pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
@@ -5804,14 +5808,14 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 	if (tg3_rx_prodring_init(tp, &tp->prodring[0]))
 		return -ENOMEM;
 
-	tp->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
-				 TG3_TX_RING_SIZE, GFP_KERNEL);
-	if (!tp->tx_buffers)
+	tnapi->tx_buffers = kzalloc(sizeof(struct tx_ring_info) *
+				    TG3_TX_RING_SIZE, GFP_KERNEL);
+	if (!tnapi->tx_buffers)
 		goto err_out;
 
-	tp->tx_ring = pci_alloc_consistent(tp->pdev, TG3_TX_RING_BYTES,
-					   &tp->tx_desc_mapping);
-	if (!tp->tx_ring)
+	tnapi->tx_ring = pci_alloc_consistent(tp->pdev, TG3_TX_RING_BYTES,
+					      &tnapi->tx_desc_mapping);
+	if (!tnapi->tx_ring)
 		goto err_out;
 
 	tnapi->hw_status = pci_alloc_consistent(tp->pdev,
@@ -7094,13 +7098,15 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 				      BDINFO_FLAGS_DISABLED);
 	}
 
-	tp->tx_prod = 0;
-	tp->tx_cons = 0;
-	tw32_mailbox(MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW, 0);
+	tp->napi[0].tx_prod = 0;
+	tp->napi[0].tx_cons = 0;
 	tw32_tx_mbox(MAILBOX_SNDNIC_PROD_IDX_0 + TG3_64BIT_REG_LOW, 0);
 
+	val = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
+	tw32_mailbox(val, 0);
+
 	tg3_set_bdinfo(tp, NIC_SRAM_SEND_RCB,
-		       tp->tx_desc_mapping,
+		       tp->napi[0].tx_desc_mapping,
 		       (TG3_TX_RING_SIZE <<
 			BDINFO_FLAGS_MAXLEN_SHIFT),
 		       NIC_SRAM_TX_BUFFER_DESC);
@@ -9093,7 +9099,7 @@ static void tg3_get_ringparam(struct net_device *dev, struct ethtool_ringparam *
 	else
 		ering->rx_jumbo_pending = 0;
 
-	ering->tx_pending = tp->tx_pending;
+	ering->tx_pending = tp->napi[0].tx_pending;
 }
 
 static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
@@ -9123,7 +9129,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	    tp->rx_pending > 63)
 		tp->rx_pending = 63;
 	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
-	tp->tx_pending = ering->tx_pending;
+	tp->napi[0].tx_pending = ering->tx_pending;
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -9928,14 +9934,13 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	num_pkts = 0;
 
-	tg3_set_txd(tp, tp->tx_prod, map, tx_len, 0, 1);
+	tg3_set_txd(tnapi, tnapi->tx_prod, map, tx_len, 0, 1);
 
-	tp->tx_prod++;
+	tnapi->tx_prod++;
 	num_pkts++;
 
-	tw32_tx_mbox(MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW,
-		     tp->tx_prod);
-	tr32_mailbox(MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW);
+	tw32_tx_mbox(tnapi->prodmbox, tnapi->tx_prod);
+	tr32_mailbox(tnapi->prodmbox);
 
 	udelay(10);
 
@@ -9948,7 +9953,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 		tx_idx = tnapi->hw_status->idx[0].tx_consumer;
 		rx_idx = rnapi->hw_status->idx[0].rx_producer;
-		if ((tx_idx == tp->tx_prod) &&
+		if ((tx_idx == tnapi->tx_prod) &&
 		    (rx_idx == (rx_start_idx + num_pkts)))
 			break;
 	}
@@ -9956,7 +9961,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	pci_unmap_single(tp->pdev, map, tx_len, PCI_DMA_TODEVICE);
 	dev_kfree_skb(skb);
 
-	if (tx_idx != tp->tx_prod)
+	if (tx_idx != tnapi->tx_prod)
 		goto out;
 
 	if (rx_idx != rx_start_idx + num_pkts)
@@ -13415,11 +13420,12 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
-	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
 
 	tp->napi[0].tp = tp;
 	tp->napi[0].int_mbox = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
 	tp->napi[0].consmbox = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
+	tp->napi[0].prodmbox = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
+	tp->napi[0].tx_pending = TG3_DEF_TX_RING_PENDING;
 	netif_napi_add(dev, &tp->napi[0].napi, tg3_poll, 64);
 	dev->ethtool_ops = &tg3_ethtool_ops;
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index b91ac29..a816b2c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2497,13 +2497,21 @@ struct tg3_napi {
 	u32				last_tag;
 	u32				last_irq_tag;
 	u32				int_mbox;
+	u32				tx_prod;
+	u32				tx_cons;
+	u32				tx_pending;
+	u32				prodmbox;
+
 	u32				consmbox;
 	u32				rx_rcb_ptr;
 
 	struct tg3_rx_buffer_desc	*rx_rcb;
+	struct tg3_tx_buffer_desc	*tx_ring;
+	struct tx_ring_info		*tx_buffers;
 
 	dma_addr_t			status_mapping;
 	dma_addr_t			rx_rcb_mapping;
+	dma_addr_t			tx_desc_mapping;
 };
 
 struct tg3 {
@@ -2563,13 +2571,6 @@ struct tg3 {
 	/* begin "tx thread" cacheline section */
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
-	u32				tx_prod;
-	u32				tx_cons;
-	u32				tx_pending;
-
-	struct tg3_tx_buffer_desc	*tx_ring;
-	struct tx_ring_info		*tx_buffers;
-	dma_addr_t			tx_desc_mapping;
 
 	/* begin "rx thread" cacheline section */
 	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
-- 
1.6.3.3


