From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 2/2] qede: Add slowpath/fastpath support and enable hardware GRO
Date: Fri, 4 Mar 2016 12:35:06 -0500
Message-ID: <1457112906-4307-3-git-send-email-manish.chopra@qlogic.com>
References: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:26922 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbcCDSP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 13:15:28 -0500
In-Reply-To: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures hardware to use GRO and adds support
for fastpath APIs to handle HW aggregated packets.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |   22 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  367 +++++++++++++++++++++++++-
 2 files changed, 388 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 02e17d3..d023251 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -160,6 +160,7 @@ struct qede_dev {
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
 
+	bool gro_disable;
 	struct list_head vlan_list;
 	u16 configured_vlans;
 	u16 non_configured_vlans;
@@ -188,6 +189,24 @@ struct sw_rx_data {
 	unsigned int page_offset;
 };
 
+enum qede_agg_state {
+	QEDE_AGG_STATE_NONE  = 0,
+	QEDE_AGG_STATE_START = 1,
+	QEDE_AGG_STATE_ERROR = 2
+};
+
+struct qede_agg_info {
+	struct sw_rx_data replace_buf;
+	dma_addr_t replace_buf_mapping;
+	struct sw_rx_data start_buf;
+	dma_addr_t start_buf_mapping;
+	struct eth_fast_path_rx_tpa_start_cqe start_cqe;
+	enum qede_agg_state agg_state;
+	struct sk_buff *skb;
+	int frag_id;
+	u16 vlan_tag;
+};
+
 struct qede_rx_queue {
 	__le16			*hw_cons_ptr;
 	struct sw_rx_data	*sw_rx_ring;
@@ -197,6 +216,9 @@ struct qede_rx_queue {
 	struct qed_chain	rx_comp_ring;
 	void __iomem		*hw_rxq_prod_addr;
 
+	/* GRO */
+	struct qede_agg_info	tpa_info[ETH_TPA_MAX_AGGS_NUM];
+
 	int			rx_buf_size;
 	unsigned int		rx_buf_seg_size;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f75f334..5728625 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -866,6 +866,278 @@ static inline void qede_skb_receive(struct qede_dev *edev,
 	napi_gro_receive(&fp->napi, skb);
 }
 
+static void qede_set_gro_params(struct qede_dev *edev,
+				struct sk_buff *skb,
+				struct eth_fast_path_rx_tpa_start_cqe *cqe)
+{
+	u16 parsing_flags = le16_to_cpu(cqe->pars_flags.flags);
+
+	if (((parsing_flags >> PARSING_AND_ERR_FLAGS_L3TYPE_SHIFT) &
+	    PARSING_AND_ERR_FLAGS_L3TYPE_MASK) == 2)
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+	else
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+
+	skb_shinfo(skb)->gso_size = __le16_to_cpu(cqe->len_on_first_bd) -
+					cqe->header_len;
+}
+
+static int qede_fill_frag_skb(struct qede_dev *edev,
+			      struct qede_rx_queue *rxq,
+			      u8 tpa_agg_index,
+			      u16 len_on_bd)
+{
+	struct sw_rx_data *current_bd = &rxq->sw_rx_ring[rxq->sw_rx_cons &
+							 NUM_RX_BDS_MAX];
+	struct qede_agg_info *tpa_info = &rxq->tpa_info[tpa_agg_index];
+	struct sk_buff *skb = tpa_info->skb;
+
+	if (unlikely(tpa_info->agg_state != QEDE_AGG_STATE_START))
+		goto out;
+
+	/* Add one frag and update the appropriate fields in the skb */
+	skb_fill_page_desc(skb, tpa_info->frag_id++,
+			   current_bd->data, current_bd->page_offset,
+			   len_on_bd);
+
+	if (unlikely(qede_realloc_rx_buffer(edev, rxq, current_bd))) {
+		tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
+		goto out;
+	}
+
+	qed_chain_consume(&rxq->rx_bd_ring);
+	rxq->sw_rx_cons++;
+
+	skb->data_len += len_on_bd;
+	skb->truesize += rxq->rx_buf_seg_size;
+	skb->len += len_on_bd;
+
+	return 0;
+
+out:
+	return -ENOMEM;
+}
+
+static void qede_tpa_start(struct qede_dev *edev,
+			   struct qede_rx_queue *rxq,
+			   struct eth_fast_path_rx_tpa_start_cqe *cqe)
+{
+	struct qede_agg_info *tpa_info = &rxq->tpa_info[cqe->tpa_agg_index];
+	struct eth_rx_bd *rx_bd_cons = qed_chain_consume(&rxq->rx_bd_ring);
+	struct eth_rx_bd *rx_bd_prod = qed_chain_produce(&rxq->rx_bd_ring);
+	struct sw_rx_data *replace_buf = &tpa_info->replace_buf;
+	dma_addr_t mapping = tpa_info->replace_buf_mapping;
+	struct sw_rx_data *sw_rx_data_cons;
+	struct sw_rx_data *sw_rx_data_prod;
+	enum pkt_hash_types rxhash_type;
+	u32 rxhash;
+
+	sw_rx_data_cons = &rxq->sw_rx_ring[rxq->sw_rx_cons & NUM_RX_BDS_MAX];
+	sw_rx_data_prod = &rxq->sw_rx_ring[rxq->sw_rx_prod & NUM_RX_BDS_MAX];
+
+	/* Use pre-allocated replacement buffer - we can't release the agg.
+	 * start until its over and we don't want to risk allocation failing
+	 * here, so re-allocate when aggregation will be over.
+	 */
+	dma_unmap_addr_set(sw_rx_data_prod, mapping,
+			   dma_unmap_addr(replace_buf, mapping));
+
+	sw_rx_data_prod->data = replace_buf->data;
+	rx_bd_prod->addr.hi = cpu_to_le32(upper_32_bits(mapping));
+	rx_bd_prod->addr.lo = cpu_to_le32(lower_32_bits(mapping));
+	sw_rx_data_prod->page_offset = replace_buf->page_offset;
+
+	rxq->sw_rx_prod++;
+
+	/* move partial skb from cons to pool (don't unmap yet)
+	 * save mapping, incase we drop the packet later on.
+	 */
+	tpa_info->start_buf = *sw_rx_data_cons;
+	mapping = HILO_U64(le32_to_cpu(rx_bd_cons->addr.hi),
+			   le32_to_cpu(rx_bd_cons->addr.lo));
+
+	tpa_info->start_buf_mapping = mapping;
+	rxq->sw_rx_cons++;
+
+	/* set tpa state to start only if we are able to allocate skb
+	 * for this aggregation, otherwise mark as error and aggregation will
+	 * be dropped
+	 */
+	tpa_info->skb = netdev_alloc_skb(edev->ndev,
+					 le16_to_cpu(cqe->len_on_first_bd));
+	if (unlikely(!tpa_info->skb)) {
+		tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
+		return;
+	}
+
+	skb_put(tpa_info->skb, le16_to_cpu(cqe->len_on_first_bd));
+	memcpy(&tpa_info->start_cqe, cqe, sizeof(tpa_info->start_cqe));
+
+	/* Start filling in the aggregation info */
+	tpa_info->frag_id = 0;
+	tpa_info->agg_state = QEDE_AGG_STATE_START;
+
+	rxhash = qede_get_rxhash(edev, cqe->bitfields,
+				 cqe->rss_hash, &rxhash_type);
+	skb_set_hash(tpa_info->skb, rxhash, rxhash_type);
+	if ((le16_to_cpu(cqe->pars_flags.flags) >>
+	     PARSING_AND_ERR_FLAGS_TAG8021QEXIST_SHIFT) &
+		    PARSING_AND_ERR_FLAGS_TAG8021QEXIST_MASK)
+		tpa_info->vlan_tag = le16_to_cpu(cqe->vlan_tag);
+	else
+		tpa_info->vlan_tag = 0;
+
+	/* This is needed in order to enable forwarding support */
+	qede_set_gro_params(edev, tpa_info->skb, cqe);
+
+	if (likely(cqe->ext_bd_len_list[0]))
+		qede_fill_frag_skb(edev, rxq, cqe->tpa_agg_index,
+				   le16_to_cpu(cqe->ext_bd_len_list[0]));
+
+	if (unlikely(cqe->ext_bd_len_list[1])) {
+		DP_ERR(edev,
+		       "Unlikely - got a TPA aggregation with more than one ext_bd_len_list entry in the TPA start\n");
+		tpa_info->agg_state = QEDE_AGG_STATE_ERROR;
+	}
+}
+
+static void qede_gro_ip_csum(struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *th;
+
+	skb_set_network_header(skb, 0);
+	skb_set_transport_header(skb, sizeof(struct iphdr));
+	th = tcp_hdr(skb);
+
+	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
+				  iph->saddr, iph->daddr, 0);
+
+	tcp_gro_complete(skb);
+}
+
+static void qede_gro_ipv6_csum(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr *th;
+
+	skb_set_network_header(skb, 0);
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+	th = tcp_hdr(skb);
+
+	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
+				  &iph->saddr, &iph->daddr, 0);
+	tcp_gro_complete(skb);
+}
+
+static void qede_gro_receive(struct qede_dev *edev,
+			     struct qede_fastpath *fp,
+			     struct sk_buff *skb,
+			     u16 vlan_tag)
+{
+	if (skb_shinfo(skb)->gso_size) {
+		switch (skb->protocol) {
+		case htons(ETH_P_IP):
+			qede_gro_ip_csum(skb);
+			break;
+		case htons(ETH_P_IPV6):
+			qede_gro_ipv6_csum(skb);
+			break;
+		default:
+			DP_ERR(edev,
+			       "Error: FW GRO supports only IPv4/IPv6, not 0x%04x\n",
+			       ntohs(skb->protocol));
+		}
+	}
+
+	skb_record_rx_queue(skb, fp->rss_id);
+	qede_skb_receive(edev, fp, skb, vlan_tag);
+}
+
+static inline void qede_tpa_cont(struct qede_dev *edev,
+				 struct qede_rx_queue *rxq,
+				 struct eth_fast_path_rx_tpa_cont_cqe *cqe)
+{
+	int i;
+
+	for (i = 0; cqe->len_list[i]; i++)
+		qede_fill_frag_skb(edev, rxq, cqe->tpa_agg_index,
+				   le16_to_cpu(cqe->len_list[i]));
+
+	if (unlikely(i > 1))
+		DP_ERR(edev,
+		       "Strange - TPA cont with more than a single len_list entry\n");
+}
+
+static void qede_tpa_end(struct qede_dev *edev,
+			 struct qede_fastpath *fp,
+			 struct eth_fast_path_rx_tpa_end_cqe *cqe)
+{
+	struct qede_rx_queue *rxq = fp->rxq;
+	struct qede_agg_info *tpa_info;
+	struct sk_buff *skb;
+	int i;
+
+	tpa_info = &rxq->tpa_info[cqe->tpa_agg_index];
+	skb = tpa_info->skb;
+
+	for (i = 0; cqe->len_list[i]; i++)
+		qede_fill_frag_skb(edev, rxq, cqe->tpa_agg_index,
+				   le16_to_cpu(cqe->len_list[i]));
+	if (unlikely(i > 1))
+		DP_ERR(edev,
+		       "Strange - TPA emd with more than a single len_list entry\n");
+
+	if (unlikely(tpa_info->agg_state != QEDE_AGG_STATE_START))
+		goto err;
+
+	/* Sanity */
+	if (unlikely(cqe->num_of_bds != tpa_info->frag_id + 1))
+		DP_ERR(edev,
+		       "Strange - TPA had %02x BDs, but SKB has only %d frags\n",
+		       cqe->num_of_bds, tpa_info->frag_id);
+	if (unlikely(skb->len != le16_to_cpu(cqe->total_packet_len)))
+		DP_ERR(edev,
+		       "Strange - total packet len [cqe] is %4x but SKB has len %04x\n",
+		       le16_to_cpu(cqe->total_packet_len), skb->len);
+
+	memcpy(skb->data,
+	       page_address(tpa_info->start_buf.data) +
+		tpa_info->start_cqe.placement_offset +
+		tpa_info->start_buf.page_offset,
+	       le16_to_cpu(tpa_info->start_cqe.len_on_first_bd));
+
+	/* Recycle [mapped] start buffer for the next replacement */
+	tpa_info->replace_buf = tpa_info->start_buf;
+	tpa_info->replace_buf_mapping = tpa_info->start_buf_mapping;
+
+	/* Finalize the SKB */
+	skb->protocol = eth_type_trans(skb, edev->ndev);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	/* tcp_gro_complete() will copy NAPI_GRO_CB(skb)->count
+	 * to skb_shinfo(skb)->gso_segs
+	 */
+	NAPI_GRO_CB(skb)->count = le16_to_cpu(cqe->num_of_coalesced_segs);
+
+	qede_gro_receive(edev, fp, skb, tpa_info->vlan_tag);
+
+	tpa_info->agg_state = QEDE_AGG_STATE_NONE;
+
+	return;
+err:
+	/* The BD starting the aggregation is still mapped; Re-use it for
+	 * future aggregations [as replacement buffer]
+	 */
+	memcpy(&tpa_info->replace_buf, &tpa_info->start_buf,
+	       sizeof(struct sw_rx_data));
+	tpa_info->replace_buf_mapping = tpa_info->start_buf_mapping;
+	tpa_info->start_buf.data = NULL;
+	tpa_info->agg_state = QEDE_AGG_STATE_NONE;
+	dev_kfree_skb_any(tpa_info->skb);
+	tpa_info->skb = NULL;
+}
+
 static u8 qede_check_csum(u16 flag)
 {
 	u16 csum_flag = 0;
@@ -931,6 +1203,25 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 			goto next_cqe;
 		}
 
+		if (cqe_type != ETH_RX_CQE_TYPE_REGULAR) {
+			switch (cqe_type) {
+			case ETH_RX_CQE_TYPE_TPA_START:
+				qede_tpa_start(edev, rxq,
+					       &cqe->fast_path_tpa_start);
+				goto next_cqe;
+			case ETH_RX_CQE_TYPE_TPA_CONT:
+				qede_tpa_cont(edev, rxq,
+					      &cqe->fast_path_tpa_cont);
+				goto next_cqe;
+			case ETH_RX_CQE_TYPE_TPA_END:
+				qede_tpa_end(edev, fp,
+					     &cqe->fast_path_tpa_end);
+				goto next_rx_only;
+			default:
+				break;
+			}
+		}
+
 		/* Get the data from the SW ring */
 		sw_rx_index = rxq->sw_rx_cons & NUM_RX_BDS_MAX;
 		sw_rx_data = &rxq->sw_rx_ring[sw_rx_index];
@@ -1057,9 +1348,9 @@ static int qede_rx_int(struct qede_fastpath *fp, int budget)
 		qede_skb_receive(edev, fp, skb, le16_to_cpu(fp_cqe->vlan_tag));
 
 		qed_chain_consume(&rxq->rx_bd_ring);
-
 next_rx:
 		rxq->sw_rx_cons++;
+next_rx_only:
 		rx_pkt++;
 
 next_cqe: /* don't consume bd rx buffer */
@@ -1952,9 +2243,31 @@ static void qede_free_rx_buffers(struct qede_dev *edev,
 	}
 }
 
+static void qede_free_sge_mem(struct qede_dev *edev,
+			      struct qede_rx_queue *rxq) {
+	int i;
+
+	if (edev->gro_disable)
+		return;
+
+	for (i = 0; i < ETH_TPA_MAX_AGGS_NUM; i++) {
+		struct qede_agg_info *tpa_info = &rxq->tpa_info[i];
+		struct sw_rx_data *replace_buf = &tpa_info->replace_buf;
+
+		if (replace_buf) {
+			dma_unmap_page(&edev->pdev->dev,
+				       dma_unmap_addr(replace_buf, mapping),
+				       PAGE_SIZE, DMA_FROM_DEVICE);
+			__free_page(replace_buf->data);
+		}
+	}
+}
+
 static void qede_free_mem_rxq(struct qede_dev *edev,
 			      struct qede_rx_queue *rxq)
 {
+	qede_free_sge_mem(edev, rxq);
+
 	/* Free rx buffers */
 	qede_free_rx_buffers(edev, rxq);
 
@@ -2010,6 +2323,53 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 	return 0;
 }
 
+static int qede_alloc_sge_mem(struct qede_dev *edev,
+			      struct qede_rx_queue *rxq)
+{
+	dma_addr_t mapping;
+	int i;
+
+	if (edev->gro_disable)
+		return 0;
+
+	if (edev->ndev->mtu > PAGE_SIZE) {
+		edev->gro_disable = 1;
+		return 0;
+	}
+
+	for (i = 0; i < ETH_TPA_MAX_AGGS_NUM; i++) {
+		struct qede_agg_info *tpa_info = &rxq->tpa_info[i];
+		struct sw_rx_data *replace_buf = &tpa_info->replace_buf;
+
+		replace_buf->data = alloc_pages(GFP_ATOMIC, 0);
+		if (unlikely(!replace_buf->data)) {
+			DP_NOTICE(edev,
+				  "Failed to allocate TPA skb pool [replacement buffer]\n");
+			goto err;
+		}
+
+		mapping = dma_map_page(&edev->pdev->dev, replace_buf->data, 0,
+				       rxq->rx_buf_size, DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&edev->pdev->dev, mapping))) {
+			DP_NOTICE(edev,
+				  "Failed to map TPA replacement buffer\n");
+			goto err;
+		}
+
+		dma_unmap_addr_set(replace_buf, mapping, mapping);
+		tpa_info->replace_buf.page_offset = 0;
+
+		tpa_info->replace_buf_mapping = mapping;
+		tpa_info->agg_state = QEDE_AGG_STATE_NONE;
+	}
+
+	return 0;
+err:
+	qede_free_sge_mem(edev, rxq);
+	edev->gro_disable = 1;
+	return -ENOMEM;
+}
+
 /* This function allocates all memory needed per Rx queue */
 static int qede_alloc_mem_rxq(struct qede_dev *edev,
 			      struct qede_rx_queue *rxq)
@@ -2071,6 +2431,8 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev,
 			  num_allocated);
 	}
 
+	qede_alloc_sge_mem(edev, rxq);
+
 	return 0;
 
 err:
@@ -2233,6 +2595,8 @@ static void qede_init_fp(struct qede_dev *edev)
 		snprintf(fp->name, sizeof(fp->name), "%s-fp-%d",
 			 edev->ndev->name, rss_id);
 	}
+
+	edev->gro_disable = !(edev->ndev->features & NETIF_F_GRO);
 }
 
 static int qede_set_real_num_queues(struct qede_dev *edev)
@@ -2479,6 +2843,7 @@ static int qede_start_queues(struct qede_dev *edev)
 		return -EINVAL;
 	}
 
+	start.gro_enable = !edev->gro_disable;
 	start.mtu = edev->ndev->mtu;
 	start.vport_id = 0;
 	start.drop_ttl0 = true;
-- 
1.7.1
