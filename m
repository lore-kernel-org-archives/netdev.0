From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 4/5] qede: Add support for ingress headroom
Date: Fri, 7 Apr 2017 11:05:00 +0300
Message-ID: <1491552301-23953-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43373 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754150AbdDGIG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:27 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver currently doesn't support any headroom; The only 'available'
space it has in the head of the buffer is due to the placement
offset.
In order to allow [later] support of XDP adjustment of headroom,
modify the the ingress flow to properly handle a scenario where
the packets would have such.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      | 13 ++++++++-----
 drivers/net/ethernet/qlogic/qede/qede_fp.c   | 23 +++++++++++++----------
 drivers/net/ethernet/qlogic/qede/qede_main.c |  5 +++--
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 7ab2201..5e7ad25 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -313,21 +313,24 @@ struct qede_rx_queue {
 	u8 data_direction;
 	u8 rxq_id;
 
+	/* Used once per each NAPI run */
+	u16 num_rx_buffers;
+
+	u16 rx_headroom;
+
 	u32 rx_buf_size;
 	u32 rx_buf_seg_size;
 
-	u64 rcv_pkts;
-
 	struct sw_rx_data *sw_rx_ring;
 	struct qed_chain rx_bd_ring;
 	struct qed_chain rx_comp_ring ____cacheline_aligned;
 
-	/* Used once per each NAPI run */
-	u16 num_rx_buffers;
-
 	/* GRO */
 	struct qede_agg_info tpa_info[ETH_TPA_MAX_AGGS_NUM];
 
+	/* Used once per each NAPI run */
+	u64 rcv_pkts;
+
 	u64 rx_hw_errors;
 	u64 rx_alloc_errors;
 	u64 rx_ip_frags;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index c61cfcf..e382d4b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -87,7 +87,8 @@ int qede_alloc_rx_buffer(struct qede_rx_queue *rxq, bool allow_lazy)
 	rx_bd = (struct eth_rx_bd *)qed_chain_produce(&rxq->rx_bd_ring);
 	WARN_ON(!rx_bd);
 	rx_bd->addr.hi = cpu_to_le32(upper_32_bits(mapping));
-	rx_bd->addr.lo = cpu_to_le32(lower_32_bits(mapping));
+	rx_bd->addr.lo = cpu_to_le32(lower_32_bits(mapping) +
+				     rxq->rx_headroom);
 
 	rxq->sw_rx_prod++;
 	rxq->filled_buffers++;
@@ -509,7 +510,8 @@ static inline void qede_reuse_page(struct qede_rx_queue *rxq,
 	new_mapping = curr_prod->mapping + curr_prod->page_offset;
 
 	rx_bd_prod->addr.hi = cpu_to_le32(upper_32_bits(new_mapping));
-	rx_bd_prod->addr.lo = cpu_to_le32(lower_32_bits(new_mapping));
+	rx_bd_prod->addr.lo = cpu_to_le32(lower_32_bits(new_mapping) +
+					  rxq->rx_headroom);
 
 	rxq->sw_rx_prod++;
 	curr_cons->data = NULL;
@@ -991,13 +993,14 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 			struct qede_rx_queue *rxq,
 			struct bpf_prog *prog,
 			struct sw_rx_data *bd,
-			struct eth_fast_path_rx_reg_cqe *cqe)
+			struct eth_fast_path_rx_reg_cqe *cqe,
+			u16 data_offset)
 {
 	u16 len = le16_to_cpu(cqe->len_on_first_bd);
 	struct xdp_buff xdp;
 	enum xdp_action act;
 
-	xdp.data = page_address(bd->data) + cqe->placement_offset;
+	xdp.data = page_address(bd->data) + data_offset;
 	xdp.data_end = xdp.data + len;
 
 	/* Queues always have a full reset currently, so for the time
@@ -1026,7 +1029,7 @@ static bool qede_rx_xdp(struct qede_dev *edev,
 		/* Now if there's a transmission problem, we'd still have to
 		 * throw current buffer, as replacement was already allocated.
 		 */
-		if (qede_xdp_xmit(edev, fp, bd, cqe->placement_offset, len)) {
+		if (qede_xdp_xmit(edev, fp, bd, data_offset, len)) {
 			dma_unmap_page(rxq->dev, bd->mapping,
 				       PAGE_SIZE, DMA_BIDIRECTIONAL);
 			__free_page(bd->data);
@@ -1053,7 +1056,7 @@ static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 					    struct sw_rx_data *bd, u16 len,
 					    u16 pad)
 {
-	unsigned int offset = bd->page_offset;
+	unsigned int offset = bd->page_offset + pad;
 	struct skb_frag_struct *frag;
 	struct page *page = bd->data;
 	unsigned int pull_len;
@@ -1070,7 +1073,7 @@ static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 	 */
 	if (len + pad <= edev->rx_copybreak) {
 		memcpy(skb_put(skb, len),
-		       page_address(page) + pad + offset, len);
+		       page_address(page) + offset, len);
 		qede_reuse_page(rxq, bd);
 		goto out;
 	}
@@ -1078,7 +1081,7 @@ static struct sk_buff *qede_rx_allocate_skb(struct qede_dev *edev,
 	frag = &skb_shinfo(skb)->frags[0];
 
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-			page, pad + offset, len, rxq->rx_buf_seg_size);
+			page, offset, len, rxq->rx_buf_seg_size);
 
 	va = skb_frag_address(frag);
 	pull_len = eth_get_headlen(va, QEDE_RX_HDR_SIZE);
@@ -1224,11 +1227,11 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 
 	fp_cqe = &cqe->fast_path_regular;
 	len = le16_to_cpu(fp_cqe->len_on_first_bd);
-	pad = fp_cqe->placement_offset;
+	pad = fp_cqe->placement_offset + rxq->rx_headroom;
 
 	/* Run eBPF program if one is attached */
 	if (xdp_prog)
-		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe))
+		if (!qede_rx_xdp(edev, fp, rxq, xdp_prog, bd, fp_cqe, pad))
 			return 0;
 
 	/* If this is an error packet then drop it */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index fa62c37..91c3078 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1188,8 +1188,9 @@ static int qede_alloc_mem_rxq(struct qede_dev *edev, struct qede_rx_queue *rxq)
 
 	rxq->rx_buf_size = NET_IP_ALIGN + ETH_OVERHEAD + edev->ndev->mtu;
 
-	if (rxq->rx_buf_size > PAGE_SIZE)
-		rxq->rx_buf_size = PAGE_SIZE;
+	/* Make sure that the headroom and  payload fit in a single page */
+	if (rxq->rx_buf_size + rxq->rx_headroom > PAGE_SIZE)
+		rxq->rx_buf_size = PAGE_SIZE - rxq->rx_headroom;
 
 	/* Segment size to spilt a page in multiple equal parts,
 	 * unless XDP is used in which case we'd use the entire page.
-- 
1.9.3
