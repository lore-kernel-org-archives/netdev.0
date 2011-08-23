From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next,v4 04/12] bna: TX Path and RX Path Changes
Date: Tue, 23 Aug 2011 10:56:00 -0700
Message-ID: <1314122168-14314-5-git-send-email-rmody@brocade.com>
References: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47469 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab1HWR4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 13:56:34 -0400
In-Reply-To: <1314122168-14314-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Add BNAD_PCI_UNMAP_SKB macro to unmap skb from transmit path. Add more
   checks for illegal skbs in transmit path. Add tx_skb counters for dropped
   skbs.
 - Disable and enable interrupts from the same polling context to prevent
   reordering in Rx path.
 - Add Rx NAPI debug counters.
 - Make NAPI budget check more generic.
 - Add a macro bnad_dim_timer_stop for DIM(Dynamic Interrupt Moderation)
   timer stop.
 - Handle reduced MSI-X vectors case in bnad_enable_msix.
 - Check for single frame TSO skbs and send them out as non-TSO.
 - Put memory barrier after bna_txq_prod_indx_doorbell().

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |  262 +++++++++++++++++++------------
 drivers/net/ethernet/brocade/bna/bnad.h |   35 ++++-
 2 files changed, 198 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 095eac9..492ad45 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -74,6 +74,24 @@ do {								\
 
 #define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
 
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
@@ -169,7 +187,6 @@ bnad_free_txbufs(struct bnad *bnad,
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff		*skb;
-	int i;
 
 	/*
 	 * Just return if TX is stopped. This check is useful
@@ -195,32 +212,14 @@ bnad_free_txbufs(struct bnad *bnad,
 	while (wis) {
 		skb = unmap_array[unmap_cons].skb;
 
-		unmap_array[unmap_cons].skb = NULL;
-
 		sent_packets++;
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
 
@@ -536,7 +535,8 @@ next:
 	BNA_QE_INDX_ADD(ccb->producer_index, wis, ccb->q_depth);
 
 	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-		bna_ib_ack(ccb->i_dbell, packets);
+		bna_ib_ack_disable_irq(ccb->i_dbell, packets);
+
 	bnad_refill_rxq(bnad, ccb->rcb[0]);
 	if (ccb->rcb[1])
 		bnad_refill_rxq(bnad, ccb->rcb[1]);
@@ -574,10 +574,9 @@ bnad_netif_rx_schedule_poll(struct bnad *bnad, struct bna_ccb *ccb)
 	struct napi_struct *napi = &rx_ctrl->napi;
 
 	if (likely(napi_schedule_prep(napi))) {
-		bnad_disable_rx_irq(bnad, ccb);
 		__napi_schedule(napi);
+		rx_ctrl->rx_schedule++;
 	}
-	BNAD_UPDATE_CTR(bnad, netif_rx_schedule);
 }
 
 /* MSIX Rx Path Handler */
@@ -586,8 +585,10 @@ bnad_msix_rx(int irq, void *data)
 {
 	struct bna_ccb *ccb = (struct bna_ccb *)data;
 
-	if (ccb)
+	if (ccb) {
+		((struct bnad_rx_ctrl *)(ccb->ctrl))->rx_intr_ctr++;
 		bnad_netif_rx_schedule_poll(ccb->bnad, ccb);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -1656,22 +1657,23 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 	struct bnad *bnad = rx_ctrl->bnad;
 	int rcvd = 0;
 
+	rx_ctrl->rx_poll_ctr++;
 
 	if (!netif_carrier_ok(bnad->netdev))
 		goto poll_exit;
 
 	rcvd = bnad_poll_cq(bnad, rx_ctrl->ccb, budget);
-	if (rcvd == budget)
+	if (rcvd >= budget)
 		return rcvd;
 
 poll_exit:
 	napi_complete((napi));
 
-	BNAD_UPDATE_CTR(bnad, netif_rx_complete);
-
+	rx_ctrl->rx_complete++;
 
 	if (rx_ctrl->ccb)
-		bnad_enable_rx_irq(bnad, rx_ctrl->ccb);
+		bnad_enable_rx_irq_unsafe(rx_ctrl->ccb);
+
 	return rcvd;
 }
 
@@ -1875,20 +1877,14 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
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
@@ -2382,12 +2378,11 @@ bnad_enable_msix(struct bnad *bnad)
 
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
@@ -2544,15 +2539,27 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	u32		unmap_prod, wis, wis_used, wi_range;
 	u32		vectors, vect_id, i, acked;
 	int			err;
+	unsigned int		len;
+	u32				gso_size;
 
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
 	u16	flags;
 
-	if (unlikely
-	    (skb->len <= ETH_HLEN || skb->len > BFI_TX_MAX_DATA_PER_PKT)) {
+	if (unlikely(skb->len <= ETH_HLEN)) {
 		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_too_short);
+		return NETDEV_TX_OK;
+	}
+	if (unlikely(skb_headlen(skb) > BFI_TX_MAX_DATA_PER_VECTOR)) {
+		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_headlen_too_long);
+		return NETDEV_TX_OK;
+	}
+	if (unlikely(skb_headlen(skb) == 0)) {
+		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_headlen_zero);
 		return NETDEV_TX_OK;
 	}
 
@@ -2562,12 +2569,14 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 */
 	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))) {
 		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_stopping);
 		return NETDEV_TX_OK;
 	}
 
 	vectors = 1 + skb_shinfo(skb)->nr_frags;
-	if (vectors > BFI_TX_MAX_VECTORS_PER_PKT) {
+	if (unlikely(vectors > BFI_TX_MAX_VECTORS_PER_PKT)) {
 		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_max_vectors);
 		return NETDEV_TX_OK;
 	}
 	wis = BNA_TXQ_WI_NEEDED(vectors);	/* 4 vectors per work item */
@@ -2605,8 +2614,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	unmap_prod = unmap_q->producer_index;
-	wis_used = 1;
-	vect_id = 0;
 	flags = 0;
 
 	txq_prod = tcb->producer_index;
@@ -2614,9 +2621,6 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	BUG_ON(!(wi_range <= tcb->q_depth));
 	txqent->hdr.wi.reserved = 0;
 	txqent->hdr.wi.num_vectors = vectors;
-	txqent->hdr.wi.opcode =
-		htons((skb_is_gso(skb) ? BNA_TXQ_WI_SEND_LSO :
-		       BNA_TXQ_WI_SEND));
 
 	if (vlan_tx_tag_present(skb)) {
 		vlan_tag = (u16) vlan_tx_tag_get(skb);
@@ -2630,63 +2634,94 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	txqent->hdr.wi.vlan_tag = htons(vlan_tag);
 
+	gso_size = skb_shinfo(skb)->gso_size;
+
 	if (skb_is_gso(skb)) {
+		if (unlikely(gso_size > netdev->mtu)) {
+			dev_kfree_skb(skb);
+			BNAD_UPDATE_CTR(bnad, tx_skb_mss_too_long);
+			return NETDEV_TX_OK;
+		}
+		if (unlikely((gso_size + skb_transport_offset(skb) +
+			tcp_hdrlen(skb)) >= skb->len)) {
+			txqent->hdr.wi.opcode =
+				__constant_htons(BNA_TXQ_WI_SEND);
+			txqent->hdr.wi.lso_mss = 0;
+			BNAD_UPDATE_CTR(bnad, tx_skb_tso_too_short);
+		} else {
+			txqent->hdr.wi.opcode =
+				__constant_htons(BNA_TXQ_WI_SEND_LSO);
+			txqent->hdr.wi.lso_mss = htons(gso_size);
+		}
+
 		err = bnad_tso_prepare(bnad, skb);
-		if (err) {
+		if (unlikely(err)) {
 			dev_kfree_skb(skb);
+			BNAD_UPDATE_CTR(bnad, tx_skb_tso_prepare);
 			return NETDEV_TX_OK;
 		}
-		txqent->hdr.wi.lso_mss = htons(skb_is_gso(skb));
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
+		if (unlikely(skb->len > (netdev->mtu + ETH_HLEN))) {
+			dev_kfree_skb(skb);
+			BNAD_UPDATE_CTR(bnad, tx_skb_non_tso_too_long);
+			return NETDEV_TX_OK;
 		}
-		if (proto == IPPROTO_TCP) {
-			flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
-			txqent->hdr.wi.l4_hdr_size_n_offset =
-				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
-				      (0, skb_transport_offset(skb)));
-
-			BNAD_UPDATE_CTR(bnad, tcpcsum_offload);
-
-			BUG_ON(!(skb_headlen(skb) >=
-				skb_transport_offset(skb) + tcp_hdrlen(skb)));
 
-		} else if (proto == IPPROTO_UDP) {
-			flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
-			txqent->hdr.wi.l4_hdr_size_n_offset =
-				htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
-				      (0, skb_transport_offset(skb)));
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			u8 proto = 0;
 
-			BNAD_UPDATE_CTR(bnad, udpcsum_offload);
+			if (skb->protocol == __constant_htons(ETH_P_IP))
+				proto = ip_hdr(skb)->protocol;
+			else if (skb->protocol ==
+				 __constant_htons(ETH_P_IPV6)) {
+				/* nexthdr may not be TCP immediately. */
+				proto = ipv6_hdr(skb)->nexthdr;
+			}
+			if (proto == IPPROTO_TCP) {
+				flags |= BNA_TXQ_WI_CF_TCP_CKSUM;
+				txqent->hdr.wi.l4_hdr_size_n_offset =
+					htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+					      (0, skb_transport_offset(skb)));
+
+				BNAD_UPDATE_CTR(bnad, tcpcsum_offload);
+
+				if (unlikely(skb_headlen(skb) <
+				skb_transport_offset(skb) + tcp_hdrlen(skb))) {
+					dev_kfree_skb(skb);
+					BNAD_UPDATE_CTR(bnad, tx_skb_tcp_hdr);
+					return NETDEV_TX_OK;
+				}
 
-			BUG_ON(!(skb_headlen(skb) >=
-				   skb_transport_offset(skb) +
-				   sizeof(struct udphdr)));
-		} else {
-			err = skb_checksum_help(skb);
-			BNAD_UPDATE_CTR(bnad, csum_help);
-			if (err) {
+			} else if (proto == IPPROTO_UDP) {
+				flags |= BNA_TXQ_WI_CF_UDP_CKSUM;
+				txqent->hdr.wi.l4_hdr_size_n_offset =
+					htons(BNA_TXQ_WI_L4_HDR_N_OFFSET
+					      (0, skb_transport_offset(skb)));
+
+				BNAD_UPDATE_CTR(bnad, udpcsum_offload);
+				if (unlikely(skb_headlen(skb) <
+				    skb_transport_offset(skb) +
+				    sizeof(struct udphdr))) {
+					dev_kfree_skb(skb);
+					BNAD_UPDATE_CTR(bnad, tx_skb_udp_hdr);
+					return NETDEV_TX_OK;
+				}
+			} else {
 				dev_kfree_skb(skb);
-				BNAD_UPDATE_CTR(bnad, csum_help_err);
+				BNAD_UPDATE_CTR(bnad, tx_skb_csum_err);
 				return NETDEV_TX_OK;
 			}
+		} else {
+			txqent->hdr.wi.l4_hdr_size_n_offset = 0;
 		}
-	} else {
-		txqent->hdr.wi.lso_mss = 0;
-		txqent->hdr.wi.l4_hdr_size_n_offset = 0;
 	}
 
 	txqent->hdr.wi.flags = htons(flags);
@@ -2694,20 +2729,38 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
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
+			dev_kfree_skb(skb);
+			BNAD_UPDATE_CTR(bnad, tx_skb_frag_zero);
+			return NETDEV_TX_OK;
+		}
+
+		len += size;
+
 		if (++vect_id == BFI_TX_MAX_VECTORS_PER_WI) {
 			vect_id = 0;
 			if (--wi_range)
@@ -2718,10 +2771,10 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
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
@@ -2734,6 +2787,18 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
 	}
 
+	if (unlikely(len != skb->len)) {
+		unmap_prod = unmap_q->producer_index;
+		prefetch(&unmap_q->unmap_array[unmap_prod + 1]);
+
+		BNAD_PCI_UNMAP_SKB(&bnad->pcidev->dev, unmap_q->unmap_array,
+				   unmap_prod, unmap_q->q_depth, skb,
+				   skb_shinfo(skb)->nr_frags);
+		dev_kfree_skb(skb);
+		BNAD_UPDATE_CTR(bnad, tx_skb_len_mismatch);
+		return NETDEV_TX_OK;
+	}
+
 	unmap_q->producer_index = unmap_prod;
 	BNA_QE_INDX_ADD(txq_prod, wis_used, tcb->q_depth);
 	tcb->producer_index = txq_prod;
@@ -2744,6 +2809,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 
 	bna_txq_prod_indx_doorbell(tcb);
+	smp_mb();
 
 	if ((u16) (*tcb->hw_consumer_index) != tcb->consumer_index)
 		tasklet_schedule(&bnad->tx_free_tasklet);
@@ -2810,6 +2876,9 @@ bnad_set_rx_mode(struct net_device *netdev)
 		}
 	}
 
+	if (bnad->rx_info[0].rx == NULL)
+		goto unlock;
+
 	bna_rx_mode_set(bnad->rx_info[0].rx, new_mask, valid_mask, NULL);
 
 	if (!netdev_mc_empty(netdev)) {
@@ -2962,12 +3031,9 @@ bnad_netpoll(struct net_device *netdev)
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
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 60c2e9d..8a31882 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -56,6 +56,11 @@ struct bnad_rx_ctrl {
 	struct bnad *bnad;
 	unsigned long  flags;
 	struct napi_struct	napi;
+	u64		rx_intr_ctr;
+	u64		rx_poll_ctr;
+	u64		rx_schedule;
+	u64		rx_keep_poll;
+	u64		rx_complete;
 };
 
 #define BNAD_RXMODE_PROMISC_DEFAULT	BNA_RXMODE_PROMISC
@@ -148,6 +153,20 @@ struct bnad_drv_stats {
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
@@ -346,7 +365,7 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 
 #define bnad_enable_rx_irq_unsafe(_ccb)			\
 {							\
-	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))) {\
+	if (likely(test_bit(BNAD_RXQ_STARTED, &(_ccb)->rcb[0]->flags))) {\
 		bna_ib_coalescing_timer_set((_ccb)->i_dbell,	\
 			(_ccb)->rx_coalescing_timeo);		\
 		bna_ib_ack((_ccb)->i_dbell, 0);			\
@@ -356,5 +375,19 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
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

