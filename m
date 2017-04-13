From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 11/16] net/mlx5e: Xmit flow break down
Date: Thu, 13 Apr 2017 06:37:01 +0300
Message-ID: <20170413033706.19016-12-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Break current mlx5e xmit flow into smaller blocks (helper functions)
in order to reuse them for IPoIB SKB transmission.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 199 +++++++++++++---------
 3 files changed, 119 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 23b92ec54e12..25185f8c3562 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -304,6 +304,7 @@ struct mlx5e_cq {
 } ____cacheline_aligned_in_smp;
 
 struct mlx5e_tx_wqe_info {
+	struct sk_buff *skb;
 	u32 num_bytes;
 	u8  num_wqebbs;
 	u8  num_dma;
@@ -345,7 +346,6 @@ struct mlx5e_txqsq {
 
 	/* write@xmit, read@completion */
 	struct {
-		struct sk_buff           **skb;
 		struct mlx5e_sq_dma       *dma_fifo;
 		struct mlx5e_tx_wqe_info  *wqe_info;
 	} db;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index eb657987e9b5..2201b7ea05f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1042,7 +1042,6 @@ static void mlx5e_free_txqsq_db(struct mlx5e_txqsq *sq)
 {
 	kfree(sq->db.wqe_info);
 	kfree(sq->db.dma_fifo);
-	kfree(sq->db.skb);
 }
 
 static int mlx5e_alloc_txqsq_db(struct mlx5e_txqsq *sq, int numa)
@@ -1050,13 +1049,11 @@ static int mlx5e_alloc_txqsq_db(struct mlx5e_txqsq *sq, int numa)
 	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
 	int df_sz = wq_sz * MLX5_SEND_WQEBB_NUM_DS;
 
-	sq->db.skb = kzalloc_node(wq_sz * sizeof(*sq->db.skb),
-				      GFP_KERNEL, numa);
 	sq->db.dma_fifo = kzalloc_node(df_sz * sizeof(*sq->db.dma_fifo),
 					   GFP_KERNEL, numa);
 	sq->db.wqe_info = kzalloc_node(wq_sz * sizeof(*sq->db.wqe_info),
 					   GFP_KERNEL, numa);
-	if (!sq->db.skb || !sq->db.dma_fifo || !sq->db.wqe_info) {
+	if (!sq->db.dma_fifo || !sq->db.wqe_info) {
 		mlx5e_free_txqsq_db(sq);
 		return -ENOMEM;
 	}
@@ -1295,7 +1292,7 @@ static void mlx5e_deactivate_txqsq(struct mlx5e_txqsq *sq)
 	if (mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc, 1)) {
 		struct mlx5e_tx_wqe *nop;
 
-		sq->db.skb[(sq->pc & sq->wq.sz_m1)] = NULL;
+		sq->db.wqe_info[(sq->pc & sq->wq.sz_m1)].skb = NULL;
 		nop = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
 		mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nop->ctrl);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 5bbc313e70c5..ba664a1126cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -177,30 +177,9 @@ static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs,
 	mlx5e_tx_skb_pull_inline(skb_data, skb_len, cpy2_sz);
 }
 
-static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
+static inline void
+mlx5e_txwqe_build_eseg_csum(struct mlx5e_txqsq *sq, struct sk_buff *skb, struct mlx5_wqe_eth_seg *eseg)
 {
-	struct mlx5_wq_cyc       *wq   = &sq->wq;
-
-	u16 pi = sq->pc & wq->sz_m1;
-	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-	struct mlx5e_tx_wqe_info *wi   = &sq->db.wqe_info[pi];
-
-	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
-	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
-	struct mlx5_wqe_data_seg *dseg;
-
-	unsigned char *skb_data = skb->data;
-	unsigned int skb_len = skb->len;
-	u8  opcode = MLX5_OPCODE_SEND;
-	dma_addr_t dma_addr = 0;
-	unsigned int num_bytes;
-	u16 headlen;
-	u16 ds_cnt;
-	u16 ihs;
-	int i;
-
-	memset(wqe, 0, sizeof(*wqe));
-
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
 		if (skb->encapsulation) {
@@ -212,66 +191,51 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
 		}
 	} else
 		sq->stats.csum_none++;
+}
 
-	if (skb_is_gso(skb)) {
-		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
-		opcode       = MLX5_OPCODE_LSO;
+static inline u16
+mlx5e_txwqe_build_eseg_gso(struct mlx5e_txqsq *sq, struct sk_buff *skb,
+			   struct mlx5_wqe_eth_seg *eseg, unsigned int *num_bytes)
+{
+	u16 ihs;
 
-		if (skb->encapsulation) {
-			ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
-			sq->stats.tso_inner_packets++;
-			sq->stats.tso_inner_bytes += skb->len - ihs;
-		} else {
-			ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
-			sq->stats.tso_packets++;
-			sq->stats.tso_bytes += skb->len - ihs;
-		}
+	eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
 
-		sq->stats.packets += skb_shinfo(skb)->gso_segs;
-		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
+	if (skb->encapsulation) {
+		ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
+		sq->stats.tso_inner_packets++;
+		sq->stats.tso_inner_bytes += skb->len - ihs;
 	} else {
-		ihs = mlx5e_calc_min_inline(sq->min_inline_mode, skb);
-		sq->stats.packets++;
-		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+		ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		sq->stats.tso_packets++;
+		sq->stats.tso_bytes += skb->len - ihs;
 	}
 
-	sq->stats.bytes += num_bytes;
-	wi->num_bytes = num_bytes;
-
-	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
-	if (ihs) {
-		if (skb_vlan_tag_present(skb)) {
-			mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data, &skb_len);
-			ihs += VLAN_HLEN;
-		} else {
-			memcpy(eseg->inline_hdr.start, skb_data, ihs);
-			mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
-		}
-		eseg->inline_hdr.sz = cpu_to_be16(ihs);
-		ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start), MLX5_SEND_WQE_DS);
-	} else if (skb_vlan_tag_present(skb)) {
-		eseg->insert.type = cpu_to_be16(MLX5_ETH_WQE_INSERT_VLAN);
-		eseg->insert.vlan_tci = cpu_to_be16(skb_vlan_tag_get(skb));
-	}
-
-	dseg = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
+	*num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
+	return ihs;
+}
 
-	wi->num_dma = 0;
+static inline int
+mlx5e_txwqe_build_dsegs(struct mlx5e_txqsq *sq, struct sk_buff *skb,
+			unsigned char *skb_data, u16 headlen,
+			struct mlx5_wqe_data_seg *dseg)
+{
+	dma_addr_t dma_addr = 0;
+	u8 num_dma          = 0;
+	int i;
 
-	headlen = skb_len - skb->data_len;
 	if (headlen) {
 		dma_addr = dma_map_single(sq->pdev, skb_data, headlen,
 					  DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
-			goto dma_unmap_wqe_err;
+			return -ENOMEM;
 
 		dseg->addr       = cpu_to_be64(dma_addr);
 		dseg->lkey       = sq->mkey_be;
 		dseg->byte_count = cpu_to_be32(headlen);
 
 		mlx5e_dma_push(sq, dma_addr, headlen, MLX5E_DMA_MAP_SINGLE);
-		wi->num_dma++;
-
+		num_dma++;
 		dseg++;
 	}
 
@@ -280,51 +244,120 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
 		int fsz = skb_frag_size(frag);
 
 		dma_addr = skb_frag_dma_map(sq->pdev, frag, 0, fsz,
-					    DMA_TO_DEVICE);
+				     DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
-			goto dma_unmap_wqe_err;
+			return -ENOMEM;
 
 		dseg->addr       = cpu_to_be64(dma_addr);
 		dseg->lkey       = sq->mkey_be;
 		dseg->byte_count = cpu_to_be32(fsz);
 
 		mlx5e_dma_push(sq, dma_addr, fsz, MLX5E_DMA_MAP_PAGE);
-		wi->num_dma++;
-
+		num_dma++;
 		dseg++;
 	}
 
-	ds_cnt += wi->num_dma;
-
-	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
-	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
+	return num_dma;
+}
 
-	sq->db.skb[pi] = skb;
+static inline void
+mlx5e_txwqe_complete(struct mlx5e_txqsq *sq, struct sk_buff *skb,
+		     u8 opcode, u16 ds_cnt, u32 num_bytes, u8 num_dma,
+		     struct mlx5e_tx_wqe_info *wi, struct mlx5_wqe_ctrl_seg *cseg)
+{
+	struct mlx5_wq_cyc *wq = &sq->wq;
+	u16 pi;
 
+	wi->num_bytes = num_bytes;
+	wi->num_dma = num_dma;
 	wi->num_wqebbs = DIV_ROUND_UP(ds_cnt, MLX5_SEND_WQEBB_NUM_DS);
-	sq->pc += wi->num_wqebbs;
+	wi->skb = skb;
 
-	netdev_tx_sent_queue(sq->txq, wi->num_bytes);
+	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
+	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
+
+	netdev_tx_sent_queue(sq->txq, num_bytes);
 
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-	if (unlikely(!mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc,
-					     MLX5E_SQ_STOP_ROOM))) {
+	sq->pc += wi->num_wqebbs;
+	if (unlikely(!mlx5e_wqc_has_room_for(wq, sq->cc, sq->pc, MLX5E_SQ_STOP_ROOM))) {
 		netif_tx_stop_queue(sq->txq);
 		sq->stats.stopped++;
 	}
 
-	sq->stats.xmit_more += skb->xmit_more;
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq))
 		mlx5e_notify_hw(wq, sq->pc, sq->uar_map, cseg);
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->db.skb[pi] = NULL;
-		mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+		sq->db.wqe_info[pi].skb = NULL;
+		mlx5e_post_nop(wq, sq->sqn, &sq->pc);
 		sq->stats.nop++;
 	}
+}
+
+static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
+{
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+
+	u16 pi = sq->pc & wq->sz_m1;
+	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.wqe_info[pi];
+
+	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
+	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
+
+	unsigned char *skb_data = skb->data;
+	unsigned int skb_len = skb->len;
+	u8  opcode = MLX5_OPCODE_SEND;
+	unsigned int num_bytes;
+	int num_dma;
+	u16 headlen;
+	u16 ds_cnt;
+	u16 ihs;
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	mlx5e_txwqe_build_eseg_csum(sq, skb, eseg);
+
+	if (skb_is_gso(skb)) {
+		opcode = MLX5_OPCODE_LSO;
+		ihs = mlx5e_txwqe_build_eseg_gso(sq, skb, eseg, &num_bytes);
+		sq->stats.packets += skb_shinfo(skb)->gso_segs;
+	} else {
+		ihs = mlx5e_calc_min_inline(sq->min_inline_mode, skb);
+		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+		sq->stats.packets++;
+	}
+	sq->stats.bytes += num_bytes;
+	sq->stats.xmit_more += skb->xmit_more;
+
+	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
+	if (ihs) {
+		if (skb_vlan_tag_present(skb)) {
+			mlx5e_insert_vlan(eseg->inline_hdr.start, skb, ihs, &skb_data, &skb_len);
+			ihs += VLAN_HLEN;
+		} else {
+			memcpy(eseg->inline_hdr.start, skb_data, ihs);
+			mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
+		}
+		eseg->inline_hdr.sz = cpu_to_be16(ihs);
+		ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start), MLX5_SEND_WQE_DS);
+	} else if (skb_vlan_tag_present(skb)) {
+		eseg->insert.type = cpu_to_be16(MLX5_ETH_WQE_INSERT_VLAN);
+		eseg->insert.vlan_tci = cpu_to_be16(skb_vlan_tag_get(skb));
+	}
+
+	headlen = skb_len - skb->data_len;
+	num_dma = mlx5e_txwqe_build_dsegs(sq, skb, skb_data, headlen,
+					  (struct mlx5_wqe_data_seg *)cseg + ds_cnt);
+	if (unlikely(num_dma < 0))
+		goto dma_unmap_wqe_err;
+
+	mlx5e_txwqe_complete(sq, skb, opcode, ds_cnt + num_dma,
+			     num_bytes, num_dma, wi, cseg);
 
 	return NETDEV_TX_OK;
 
@@ -392,8 +425,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			last_wqe = (sqcc == wqe_counter);
 
 			ci = sqcc & sq->wq.sz_m1;
-			skb = sq->db.skb[ci];
 			wi = &sq->db.wqe_info[ci];
+			skb = wi->skb;
 
 			if (unlikely(!skb)) { /* nop */
 				sqcc++;
@@ -451,8 +484,8 @@ void mlx5e_free_txqsq_descs(struct mlx5e_txqsq *sq)
 
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
-		skb = sq->db.skb[ci];
 		wi = &sq->db.wqe_info[ci];
+		skb = wi->skb;
 
 		if (!skb) { /* nop */
 			sq->cc++;
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
