From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 39/45] bna: RX Path Changes
Date: Mon, 18 Jul 2011 01:22:59 -0700
Message-ID: <1310977385-5268-29-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48277 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754209Ab1GRIZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:10 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Disable and enable interrupts from the same polling context to prevent
   reordering in Rx path.
 - Set coalescing timer to 0 within bnad_poll_cq().
 - Move preempt_disable()/preempt_enable() calls from bnad_poll_cq() to
   bnad_napi_poll_rx() and bnad_poll().
 - Add Rx NAPI debug counters.
 - Add macros to drop skb and return, to unmap skb. Check and drop illegal
   skbs in transmit path.
 - Check for single frame TSO skbs and send them out as non-TSO.
 - Put memory barrier after bna_txq_prod_indx_doorbell()
 - Add tx_skb sounters for dropped frames in transmit path.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |  325 ++++++++++++++++++++++++------------------------
 drivers/net/bna/bnad.h |   36 +++++-
 2 files changed, 199 insertions(+), 162 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index f6b7401..d4de429 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -73,6 +73,36 @@ do {								\
 
 #define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
 
+#define BNAD_DROP_AND_RETURN(_counter)	\
+{ \
+	dev_kfree_skb(skb); \
+	BNAD_UPDATE_CTR(bnad, _counter); \
+	return NETDEV_TX_OK; \
+}
+
+#define BNAD_DROP_AND_RETURN_IF(_condition, _counter)	\
+if (unlikely(_condition)) { \
+	BNAD_DROP_AND_RETURN(_counter); \
+}
+
+#define BNAD_PCI_UNMAP_SKB(_pdev, _array, _index, _depth, _skb, _frag) \
+{ \
+	int j; \
+	(_array)[_index].skb = NULL; \
+	dma_unmap_single(_pdev, dma_unmap_addr(&(_array)[_index], dma_addr), \
+			skb_headlen(_skb), DMA_TO_DEVICE); \
+	dma_unmap_addr_set(&(_array)[_index], dma_addr, 0); \
+	BNA_QE_INDX_ADD(_index, 1, _depth); \
+	for (j = 0; j < (_frag); j++) { \
+		prefetch(&(_array)[(_index) + 1]); \
+		dma_unmap_page(_pdev, dma_unmap_addr(&(_array)[_index], \
+						     dma_addr), \
+			  skb_shinfo(_skb)->frags[j].size, DMA_TO_DEVICE); \
+		dma_unmap_addr_set(&(_array)[_index], dma_addr, 0); \
+		BNA_QE_INDX_ADD(_index, 1, _depth); \
+	} \
+}
+
 /*
  * Reinitialize completions in CQ, once Rx is taken down
  */
@@ -168,7 +198,6 @@ bnad_free_txbufs(struct bnad *bnad,
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb;
-	int i;
 
 	/*
 	 * Just return if TX is stopped. This check is useful
@@ -198,26 +227,10 @@ bnad_free_txbufs(struct bnad *bnad,
 		sent_bytes += skb->len;
 		wis -= BNA_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
 
-		dma_unmap_single(&bnad->pcidev->dev,
-				 dma_unmap_addr(&unmap_array[unmap_cons],
-						dma_addr), skb_headlen(skb),
-				 DMA_TO_DEVICE);
-		dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
-		BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
+		BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev, unmap_array, unmap_cons,
+				   unmap_q->q_depth, skb,
+				   skb_shinfo(skb)->nr_frags);
 
-		prefetch(&unmap_array[unmap_cons + 1]);
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			prefetch(&unmap_array[unmap_cons + 1]);
-
-			dma_unmap_page(&bnad->pcidev->dev,
-				       dma_unmap_addr(&unmap_array[unmap_cons],
-						      dma_addr),
-				       skb_shinfo(skb)->frags[i].size,
-				       DMA_TO_DEVICE);
-			dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
-					   0);
-			BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
-		}
 		dev_kfree_skb_any(skb);
 	}
 
@@ -388,10 +401,9 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 	BNA_RXQ_QPGE_PTR_GET(unmap_prod, rcb->sw_qpt, rxent, wi_range);
 
 	while (to_alloc--) {
-		if (!wi_range) {
+		if (!wi_range)
 			BNA_RXQ_QPGE_PTR_GET(unmap_prod, rcb->sw_qpt, rxent,
 					     wi_range);
-		}
 		skb = netdev_alloc_skb_ip_align(bnad->netdev,
 						rcb->rxq->buffer_size);
 		if (unlikely(!skb)) {
@@ -449,13 +461,10 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
 	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
 
-	preempt_disable();
-
 	set_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
 
 	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)) {
 		clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
-		preempt_enable();
 		return 0;
 	}
 
@@ -521,15 +530,13 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		      (flags & BNA_CQ_EF_L4_CKSUM_OK)))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
-			skb_checksum_none_assert(skb);
+			skb->ip_summed = CHECKSUM_NONE;
 
 		rcb->rxq->rx_packets++;
 		rcb->rxq->rx_bytes += skb->len;
 		skb->protocol = eth_type_trans(skb, bnad->netdev);
 
 		if (bnad->vlan_grp && (flags & BNA_CQ_EF_VLAN)) {
-			struct bnad_rx_ctrl *rx_ctrl =
-				(struct bnad_rx_ctrl *)ccb->ctrl;
 			if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 				vlan_gro_receive(&rx_ctrl->napi, bnad->vlan_grp,
 						ntohs(cmpl->vlan_tag), skb);
@@ -539,8 +546,6 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 							 ntohs(cmpl->vlan_tag));
 
 		} else { /* Not VLAN tagged/stripped */
-			struct bnad_rx_ctrl *rx_ctrl =
-				(struct bnad_rx_ctrl *)ccb->ctrl;
 			if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 				napi_gro_receive(&rx_ctrl->napi, skb);
 			else
@@ -554,7 +559,8 @@ next:
 
 	BNA_QE_INDX_ADD(ccb->producer_index, wis, ccb->q_depth);
 
-	rx_ctrl->pkts_to_ack += packets;
+	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
+		bna_ib_ack_disable_irq(ccb->i_dbell, packets);
 
 	bnad_refill_rxq(bnad, ccb->rcb[0]);
 	if (ccb->rcb[1])
@@ -562,43 +568,19 @@ next:
 
 	clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
 
-	preempt_enable();
-
 	return packets;
 }
 
 static void
-bnad_disable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
-{
-	if (unlikely(!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-		return;
-
-	bna_ib_coalescing_timer_set(ccb->i_dbell, 0);
-	bna_ib_ack(ccb->i_dbell, 0);
-}
-
-static void
-bnad_enable_rx_irq(struct bnad *bnad, struct bna_ccb *ccb)
-{
-	unsigned long flags;
-
-	/* Because of polling context */
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bnad_enable_rx_irq_unsafe(ccb);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-}
-
-static void
 bnad_netif_rx_schedule_poll(struct bnad *bnad, struct bna_ccb *ccb)
 {
 	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
 	struct napi_struct *napi = &rx_ctrl->napi;
 
 	if (likely(napi_schedule_prep(napi))) {
-		bnad_disable_rx_irq(bnad, ccb);
 		__napi_schedule(napi);
+		rx_ctrl->rx_schedule++;
 	}
-	BNAD_UPDATE_CTR(bnad, netif_rx_schedule);
 }
 
 /* MSIX Rx Path Handler */
@@ -606,10 +588,11 @@ static irqreturn_t
 bnad_msix_rx(int irq, void *data)
 {
 	struct bna_ccb *ccb = (struct bna_ccb *)data;
-	struct bnad *bnad = ccb->bnad;
 
-	if (ccb)
-		bnad_netif_rx_schedule_poll(bnad, ccb);
+	if (ccb) {
+		((struct bnad_rx_ctrl *)(ccb->ctrl))->rx_intr_ctr++;
+		bnad_netif_rx_schedule_poll(ccb->bnad, ccb);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -1056,8 +1039,6 @@ bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 		if (!ccb)
 			continue;
 
-		rx_ctrl->pkts_to_ack += 0;
-
 		bnad_cq_cmpl_init(bnad, ccb);
 
 		for (j = 0; j < BNAD_MAX_RXQ_PER_RXP; j++) {
@@ -1680,27 +1661,30 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct bnad_rx_ctrl *rx_ctrl =
 		container_of(napi, struct bnad_rx_ctrl, napi);
-	struct bna_ccb *ccb;
-	struct bnad *bnad;
+	struct bnad *bnad = rx_ctrl->bnad;
 	int rcvd = 0;
+	preempt_disable();
 
-	ccb = rx_ctrl->ccb;
-
-	bnad = ccb->bnad;
+	rx_ctrl->rx_poll_ctr++;
 
 	if (!netif_carrier_ok(bnad->netdev))
 		goto poll_exit;
 
-	rcvd = bnad_poll_cq(bnad, ccb, budget);
-	if (rcvd == budget)
+	rcvd = bnad_poll_cq(bnad, rx_ctrl->ccb, budget);
+	if (rcvd >= budget) {
+		preempt_enable();
 		return rcvd;
-
+	}
 poll_exit:
-	napi_complete((napi));
+	napi_complete(napi);
+
+	rx_ctrl->rx_complete++;
 
-	BNAD_UPDATE_CTR(bnad, netif_rx_complete);
+	preempt_enable();
+
+	if (rx_ctrl->ccb)
+		bnad_enable_rx_irq_unsafe(rx_ctrl->ccb);
 
-	bnad_enable_rx_irq(bnad, ccb);
 	return rcvd;
 }
 
@@ -1729,9 +1713,6 @@ bnad_napi_enable(struct bnad *bnad, u32 rx_id)
 	for (i = 0; i <	bnad->num_rxp_per_rx; i++) {
 		rx_ctrl = &bnad->rx_info[rx_id].rx_ctrl[i];
 
-		netif_napi_add(bnad->netdev, &rx_ctrl->napi,
-			       bnad_napi_poll_rx, 64);
-
 		napi_enable(&rx_ctrl->napi);
 	}
 }
@@ -1907,20 +1888,14 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	struct bna_rx_config *rx_config = &bnad->rx_config[rx_id];
 	struct bna_res_info *res_info = &bnad->rx_res_info[rx_id].res_info[0];
 	unsigned long flags;
-	int dim_timer_del = 0;
 
 	if (!rx_info->rx)
 		return;
 
-	if (0 == rx_id) {
-		spin_lock_irqsave(&bnad->bna_lock, flags);
-		dim_timer_del = bnad_dim_timer_running(bnad);
-		if (dim_timer_del)
-			clear_bit(BNAD_RF_DIM_TIMER_RUNNING, &bnad->run_flags);
-		spin_unlock_irqrestore(&bnad->bna_lock, flags);
-		if (dim_timer_del)
-			del_timer_sync(&bnad->dim_timer);
-	}
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	if (0 == rx_id)
+		bnad_dim_timer_stop(bnad, flags);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	init_completion(&bnad->bnad_completions.rx_comp);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -2429,12 +2404,11 @@ bnad_enable_msix(struct bnad *bnad)
 
 		spin_lock_irqsave(&bnad->bna_lock, flags);
 		/* ret = #of vectors that we got */
-		bnad_q_num_adjust(bnad, ret, 0);
+		bnad_q_num_adjust(bnad, (ret - BNAD_MAILBOX_MSIX_VECTORS) / 2,
+			(ret - BNAD_MAILBOX_MSIX_VECTORS) / 2);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-		bnad->msix_num = (bnad->num_tx * bnad->num_txq_per_tx)
-			+ (bnad->num_rx
-			* bnad->num_rxp_per_rx) +
+		bnad->msix_num = BNAD_NUM_TXQ + BNAD_NUM_RXP +
 			 BNAD_MAILBOX_MSIX_VECTORS;
 
 		if (bnad->msix_num > ret)
@@ -2591,16 +2565,16 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	u32		unmap_prod, wis, wis_used, wi_range;
 	u32		vectors, vect_id, i, acked;
 	int			err;
+	unsigned int		len;
 
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
 	u16	flags;
 
-	if (unlikely
-	    (skb->len <= ETH_HLEN || skb->len > BFI_TX_MAX_DATA_PER_PKT)) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
+	BNAD_DROP_AND_RETURN_IF(skb->len <= ETH_HLEN, tx_skb_too_short);
+	BNAD_DROP_AND_RETURN_IF(skb_headlen(skb) > BFI_TX_MAX_DATA_PER_VECTOR,
+				tx_skb_headlen_too_long);
+	BNAD_DROP_AND_RETURN_IF(skb_headlen(skb) == 0, tx_skb_headlen_zero);
 
 	txq_id = skb_get_queue_mapping(skb);
 
@@ -2611,16 +2585,13 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * Takes care of the Tx that is scheduled between clearing the flag
 	 * and the netif_stop_all_queue() call.
 	 */
-	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
+	BNAD_DROP_AND_RETURN_IF(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags),
+				tx_skb_stopping);
 
 	vectors = 1 + skb_shinfo(skb)->nr_frags;
-	if (vectors > BFI_TX_MAX_VECTORS_PER_PKT) {
-		dev_kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
+	BNAD_DROP_AND_RETURN_IF(vectors > BFI_TX_MAX_VECTORS_PER_PKT,
+				tx_skb_max_vectors);
+
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
 	acked = 0;
 	if (unlikely(wis > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
@@ -2656,8 +2627,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	unmap_prod = unmap_q->producer_index;
-	wis_used = 1;
-	vect_id = 0;
 	flags = 0;
 
 	txq_prod = tcb->producer_index;
@@ -2665,9 +2634,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	BUG_ON(!(wi_range <= tcb->q_depth));
 	txqent->hdr.wi.reserved = 0;
 	txqent->hdr.wi.num_vectors = vectors;
-	txqent->hdr.wi.opcode =
-		htons((skb_is_gso(skb) ? BNA_TXQ_WI_SEND_LSO :
-		       BNA_TXQ_WI_SEND));
 
 	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = (u16) vlan_tx_tag_get(skb);
@@ -2683,62 +2649,74 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	txqent->hdr.wi.vlan_tag = htons(vlan_tag);
 
 	if (skb_is_gso(skb)) {
-		err = bnad_tso_prepare(bnad, skb);
-		if (err) {
-			dev_kfree_skb(skb);
-			return NETDEV_TX_OK;
+		BNAD_DROP_AND_RETURN_IF(skb_is_gso(skb) > netdev->mtu,
+					tx_skb_mss_too_long);
+		if (unlikely((skb_is_gso(skb) + skb_transport_offset(skb) +
+			      tcp_hdrlen(skb)) >= skb->len)) {
+			txqent->hdr.wi.opcode =
+				__constant_htons(BNA_TXQ_WI_SEND);
+			txqent->hdr.wi.lso_mss = 0;
+			BNAD_UPDATE_CTR(bnad, tx_skb_tso_too_short);
+		} else {
+			txqent->hdr.wi.opcode =
+				__constant_htons(BNA_TXQ_WI_SEND_LSO);
+			txqent->hdr.wi.lso_mss = htons(skb_is_gso(skb));
 		}
-		txqent->hdr.wi.lso_mss = htons(skb_is_gso(skb));
+
+		err = bnad_tso_prepare(bnad, skb);
+		BNAD_DROP_AND_RETURN_IF(err, tx_skb_tso_prepare);
 		flags |= (BNA_TXQ_WI_CF_IP_CKSUM | BNA_TXQ_WI_CF_TCP_CKSUM);
 		txqent->hdr.wi.l4_hdr_size_n_offset =
 			htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
 			      (tcp_hdrlen(skb) >> 2,
 			       skb_transport_offset(skb)));
-	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		u8 proto = 0;
-
+	} else {
+		txqent->hdr.wi.opcode =	__constant_htons(BNA_TXQ_WI_SEND);
 		txqent->hdr.wi.lso_mss = 0;
 
-		if (skb->protocol == htons(ETH_P_IP))
-			proto = ip_hdr(skb)->protocol;
-		else if (skb->protocol == htons(ETH_P_IPV6)) {
-			/* nexthdr may not be TCP immediately. */
-			proto = ipv6_hdr(skb)->nexthdr;
-		}
-		if (proto == IPPROTO_TCP) {
-			flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
-			txqent->hdr.wi.l4_hdr_size_n_offset =
-				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
-				      (0, skb_transport_offset(skb)));
-
-			BNAD_UPDATE_CTR(bnad, tcpcsum_offload);
+		BNAD_DROP_AND_RETURN_IF(skb->len > (netdev->mtu + ETH_HLEN),
+					tx_skb_non_tso_too_long);
 
-			BUG_ON(!(skb_headlen(skb) >=
-				skb_transport_offset(skb) + tcp_hdrlen(skb)));
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			u8 proto = 0;
 
-		} else if (proto == IPPROTO_UDP) {
-			flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
-			txqent->hdr.wi.l4_hdr_size_n_offset =
-				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
-				      (0, skb_transport_offset(skb)));
-
-			BNAD_UPDATE_CTR(bnad, udpcsum_offload);
-
-			BUG_ON(!(skb_headlen(skb) >=
-				   skb_transport_offset(skb) +
-				   sizeof(struct udphdr)));
-		} else {
-			err = skb_checksum_help(skb);
-			BNAD_UPDATE_CTR(bnad, csum_help);
-			if (err) {
-				dev_kfree_skb(skb);
-				BNAD_UPDATE_CTR(bnad, csum_help_err);
-				return NETDEV_TX_OK;
+			if (skb->protocol == __constant_htons(ETH_P_IP))
+				proto = ip_hdr(skb)->protocol;
+			else if (skb->protocol ==
+				 __constant_htons(ETH_P_IPV6)) {
+				/* nexthdr may not be TCP immediately. */
+				proto = ipv6_hdr(skb)->nexthdr;
 			}
+			if (proto == IPPROTO_TCP) {
+				flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
+				txqent->hdr.wi.l4_hdr_size_n_offset =
+					htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+					      (0, skb_transport_offset(skb)));
+
+				BNAD_UPDATE_CTR(bnad, tcpcsum_offload);
+
+				BNAD_DROP_AND_RETURN_IF(skb_headlen(skb) <
+					    skb_transport_offset(skb) +
+					    tcp_hdrlen(skb), tx_skb_tcp_hdr);
+
+			} else if (proto == IPPROTO_UDP) {
+				flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
+				txqent->hdr.wi.l4_hdr_size_n_offset =
+					htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+					      (0, skb_transport_offset(skb)));
+
+				BNAD_UPDATE_CTR(bnad, udpcsum_offload);
+				BNAD_DROP_AND_RETURN_IF(skb_headlen(skb) <
+					    skb_transport_offset(skb) +
+					    sizeof(struct udphdr),
+							tx_skb_udp_hdr);
+
+			} else {
+				BNAD_DROP_AND_RETURN(tx_skb_csum_err);
+			}
+		} else {
+			txqent->hdr.wi.l4_hdr_size_n_offset = 0;
 		}
-	} else {
-		txqent->hdr.wi.lso_mss = 0;
-		txqent->hdr.wi.l4_hdr_size_n_offset = 0;
 	}
 
 	txqent->hdr.wi.flags = htons(flags);
@@ -2746,20 +2724,36 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	txqent->hdr.wi.frame_length = htonl(skb->len);
 
 	unmap_q->unmap_array[unmap_prod].skb = skb;
-	BUG_ON(!(skb_headlen(skb) <= BFI_TX_MAX_DATA_PER_VECTOR));
-	txqent->vector[vect_id].length = htons(skb_headlen(skb));
+	len = skb_headlen(skb);
+	txqent->vector[0].length = htons(len);
 	dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
 				  skb_headlen(skb), DMA_TO_DEVICE);
 	dma_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
 			   dma_addr);
 
-	BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
+	BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[0].host_addr);
 	BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
 
+	vect_id = 0;
+	wis_used = 1;
+
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
 		u16		size = frag->size;
 
+		if (unlikely(size == 0)) {
+			unmap_prod = unmap_q->producer_index;
+			prefetch(&unmap_q->unmap_array[unmap_prod + 1]);
+
+			BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev,
+					   unmap_q->unmap_array,
+					   unmap_prod, unmap_q->q_depth, skb,
+					   i);
+			BNAD_DROP_AND_RETURN(tx_skb_frag_zero);
+		}
+
+		len += size;
+
 		if (++vect_id == BFI_TX_MAX_VECTORS_PER_WI) {
 			vect_id = 0;
 			if (--wi_range)
@@ -2770,10 +2764,10 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 				wis_used = 0;
 				BNA_TXQ_QPGE_PTR_GET(txq_prod, tcb->sw_qpt,
 						     txqent, wi_range);
-				BUG_ON(!(wi_range <= tcb->q_depth));
 			}
 			wis_used++;
-			txqent->hdr.wi_ext.opcode = htons(BNA_TXQ_WI_EXTENSION);
+			txqent->hdr.wi_ext.opcode =
+				__constant_htons(BNA_TXQ_WI_EXTENSION);
 		}
 
 		BUG_ON(!(size <= BFI_TX_MAX_DATA_PER_VECTOR));
@@ -2786,6 +2780,16 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
 	}
 
+	if (unlikely(len != skb->len)) {
+		unmap_prod = unmap_q->producer_index;
+		prefetch(&unmap_q->unmap_array[unmap_prod + 1]);
+
+		BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev, unmap_q->unmap_array,
+				   unmap_prod, unmap_q->q_depth, skb,
+				   skb_shinfo(skb)->nr_frags);
+		BNAD_DROP_AND_RETURN(tx_skb_len_mismatch);
+	}
+
 	unmap_q->producer_index = unmap_prod;
 	BNA_QE_INDX_ADD(txq_prod, wis_used, tcb->q_depth);
 	tcb->producer_index = txq_prod;
@@ -2796,6 +2800,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 
 	bna_txq_prod_indx_doorbell(tcb);
+	smp_mb();
 
 	if ((u16) (*tcb->hw_consumer_index) != tcb->consumer_index)
 		tasklet_schedule(&bnad->tx_free_tasklet);
@@ -2906,6 +2911,9 @@ bnad_set_rx_mode(struct net_device *netdev)
 		}
 	}
 
+	if (bnad->rx_info[0].rx == NULL)
+		goto unlock;
+
 	bna_rx_mode_set(bnad->rx_info[0].rx, new_mask, valid_mask, NULL);
 
 	if (!netdev_mc_empty(netdev)) {
@@ -3067,12 +3075,9 @@ bnad_netpoll(struct net_device *netdev)
 				continue;
 			for (j = 0; j < bnad->num_rxp_per_rx; j++) {
 				rx_ctrl = &rx_info->rx_ctrl[j];
-				if (rx_ctrl->ccb) {
-					bnad_disable_rx_irq(bnad,
-							    rx_ctrl->ccb);
+				if (rx_ctrl->ccb)
 					bnad_netif_rx_schedule_poll(bnad,
 							    rx_ctrl->ccb);
-				}
 			}
 		}
 	}
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 7f0648d..02c6342 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -54,7 +54,11 @@ struct bnad_rx_ctrl {
 	struct bnad *bnad;
 	unsigned long  flags;
 	struct napi_struct	napi;
-	u16			pkts_to_ack;
+	u64		rx_intr_ctr;
+	u64		rx_poll_ctr;
+	u64		rx_schedule;
+	u64		rx_keep_poll;
+	u64		rx_complete;
 };
 
 #define BNAD_RXMODE_PROMISC_DEFAULT	BNA_RXMODE_PROMISC
@@ -150,6 +154,20 @@ struct bnad_drv_stats {
 	u64		udpcsum_offload;
 	u64		csum_help;
 	u64		csum_help_err;
+	u64		tx_skb_too_short;
+	u64		tx_skb_stopping;
+	u64		tx_skb_max_vectors;
+	u64		tx_skb_mss_too_long;
+	u64		tx_skb_tso_too_short;
+	u64		tx_skb_tso_prepare;
+	u64		tx_skb_non_tso_too_long;
+	u64		tx_skb_tcp_hdr;
+	u64		tx_skb_udp_hdr;
+	u64		tx_skb_csum_err;
+	u64		tx_skb_headlen_too_long;
+	u64		tx_skb_headlen_zero;
+	u64		tx_skb_frag_zero;
+	u64		tx_skb_len_mismatch;
 
 	u64		hw_stats_updates;
 	u64		netif_rx_schedule;
@@ -357,7 +375,7 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 
 #define bnad_enable_rx_irq_unsafe(_ccb)			\
 {							\
-	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))) {\
+	if (likely(test_bit(BNAD_RXQ_STARTED, &(_ccb)->rcb[0]->flags))) {\
 		bna_ib_coalescing_timer_set((_ccb)->i_dbell,	\
 			(_ccb)->rx_coalescing_timeo);		\
 		bna_ib_ack((_ccb)->i_dbell, 0);			\
@@ -367,5 +385,19 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 #define bnad_dim_timer_running(_bnad)				\
 	(((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED) &&		\
 	(test_bit(BNAD_RF_DIM_TIMER_RUNNING, &((_bnad)->run_flags))))
+#define bnad_dim_timer_stop(_bnad, _flags)		\
+do {							\
+	int to_del = 0;					\
+							\
+	if ((_bnad)->cfg_flags & BNAD_CF_DIM_ENABLED &&	\
+	    test_bit(BNAD_RF_DIM_TIMER_RUNNING, &(_bnad)->run_flags)) {\
+		clear_bit(BNAD_RF_DIM_TIMER_RUNNING, &(_bnad)->run_flags);\
+		to_del = 1;				\
+	}						\
+	spin_unlock_irqrestore(&(_bnad)->bna_lock, (_flags));	\
+	if (to_del)					\
+		del_timer_sync(&(_bnad)->dim_timer);	\
+	spin_lock_irqsave(&(_bnad)->bna_lock, (_flags));\
+} while (0)
 
 #endif /* __BNAD_H__ */
-- 
1.7.1

