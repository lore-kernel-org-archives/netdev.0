From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 20/25] net/mlx5e: Refactor TX send flow
Date: Mon, 13 Mar 2017 20:31:31 +0200
Message-ID: <1489429896-10781-21-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


prepare of IB link type packets sending.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 237 ++++++++++++++----------
 2 files changed, 141 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 154cab2a301b..b6758d0b93a5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -402,6 +402,10 @@ struct mlx5e_tx_wqe_info {
 	u32 num_bytes;
 	u8  num_wqebbs;
 	u8  num_dma;
+	u16 ds_cnt;
+	u16 ihs;
+	u8 opcode;
+	bool bf;
 };
 
 enum mlx5e_dma_map_type {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index cfb68371c397..22443ce778ff 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -216,94 +216,65 @@ static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs,
 	mlx5e_tx_skb_pull_inline(skb_data, skb_len, cpy2_sz);
 }
 
-static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
+static inline void mlx5n_sq_fill_ctrl_seg_and_send(struct mlx5e_sq *sq,
+						   struct mlx5e_tx_wqe_info *wi,
+						   struct mlx5_wqe_ctrl_seg *cseg,
+						   struct sk_buff *skb, u16 pi)
 {
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
 
-	u16 pi = sq->pc & wq->sz_m1;
-	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-	struct mlx5e_tx_wqe_info *wi   = &sq->db.txq.wqe_info[pi];
+	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | wi->opcode);
+	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | wi->ds_cnt);
 
-	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
-	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
-	struct mlx5_wqe_data_seg *dseg;
+	sq->db.txq.skb[pi] = skb;
 
-	unsigned char *skb_data = skb->data;
-	unsigned int skb_len = skb->len;
-	u8  opcode = MLX5_OPCODE_SEND;
-	dma_addr_t dma_addr = 0;
-	unsigned int num_bytes;
-	bool bf = false;
-	u16 headlen;
-	u16 ds_cnt;
-	u16 ihs;
-	int i;
+	wi->num_wqebbs = DIV_ROUND_UP(wi->ds_cnt, MLX5_SEND_WQEBB_NUM_DS);
+	sq->pc += wi->num_wqebbs;
 
-	memset(wqe, 0, sizeof(*wqe));
+	netdev_tx_sent_queue(sq->txq, wi->num_bytes);
 
-	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
-		eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
-		if (skb->encapsulation) {
-			eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
-					  MLX5_ETH_WQE_L4_INNER_CSUM;
-			sq->stats.csum_partial_inner++;
-		} else {
-			eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
-		}
-	} else
-		sq->stats.csum_none++;
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-	if (sq->cc != sq->prev_cc) {
-		sq->prev_cc = sq->cc;
-		sq->bf_budget = (sq->cc == sq->pc) ? MLX5E_SQ_BF_BUDGET : 0;
+	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
+		netif_tx_stop_queue(sq->txq);
+		sq->stats.stopped++;
 	}
 
-	if (skb_is_gso(skb)) {
-		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
-		opcode       = MLX5_OPCODE_LSO;
+	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
+		int bf_sz = 0;
 
-		if (skb->encapsulation) {
-			ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
-			sq->stats.tso_inner_packets++;
-			sq->stats.tso_inner_bytes += skb->len - ihs;
-		} else {
-			ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
-			sq->stats.tso_packets++;
-			sq->stats.tso_bytes += skb->len - ihs;
-		}
+		if (wi->bf && test_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state))
+			bf_sz = wi->num_wqebbs << 3;
 
-		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * ihs;
-	} else {
-		bf = sq->bf_budget &&
-		     !skb->xmit_more &&
-		     !skb_shinfo(skb)->nr_frags;
-		ihs = mlx5e_get_inline_hdr_size(sq, skb, bf);
-		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
+		mlx5e_tx_notify_hw(sq, cseg, bf_sz);
 	}
 
-	wi->num_bytes = num_bytes;
+	/* fill sq edge with nops to avoid wqe wrap around */
+	while ((sq->pc & wq->sz_m1) > sq->edge)
+		mlx5e_send_nop(sq, false);
 
-	if (skb_vlan_tag_present(skb)) {
-		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, ihs, &skb_data,
-				  &skb_len);
-		ihs += VLAN_HLEN;
-	} else {
-		memcpy(eseg->inline_hdr_start, skb_data, ihs);
-		mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
-	}
+	sq->bf_budget = wi->bf ? sq->bf_budget - 1 : 0;
 
-	eseg->inline_hdr_sz = cpu_to_be16(ihs);
+	sq->stats.packets++;
+	sq->stats.bytes += wi->num_bytes;
+}
 
-	ds_cnt  = sizeof(*wqe) / MLX5_SEND_WQE_DS;
-	ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr_start),
-			       MLX5_SEND_WQE_DS);
-	dseg    = (struct mlx5_wqe_data_seg *)cseg + ds_cnt;
+static inline int mlx5n_sq_build_data_seg(struct mlx5e_sq *sq,
+					  struct mlx5e_tx_wqe_info *wi,
+					  struct mlx5_wqe_data_seg *dseg,
+					  struct sk_buff *skb)
+{
+	dma_addr_t dma_addr = 0;
+	u16 headlen;
+	int i;
 
 	wi->num_dma = 0;
 
-	headlen = skb_len - skb->data_len;
+	headlen = skb->len - skb->data_len;
 	if (headlen) {
-		dma_addr = dma_map_single(sq->pdev, skb_data, headlen,
+		dma_addr = dma_map_single(sq->pdev, skb->data, headlen,
 					  DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(sq->pdev, dma_addr)))
 			goto dma_unmap_wqe_err;
@@ -336,57 +307,123 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 		dseg++;
 	}
+	wi->ds_cnt += wi->num_dma;
 
-	ds_cnt += wi->num_dma;
-
-	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
-	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
+	return 0;
 
-	sq->db.txq.skb[pi] = skb;
+dma_unmap_wqe_err:
+	sq->stats.dropped++;
+	mlx5e_dma_unmap_wqe_err(sq, wi->num_dma);
 
-	wi->num_wqebbs = DIV_ROUND_UP(ds_cnt, MLX5_SEND_WQEBB_NUM_DS);
-	sq->pc += wi->num_wqebbs;
+	dev_kfree_skb_any(skb);
+	return -ENOMEM;
+}
 
-	netdev_tx_sent_queue(sq->txq, wi->num_bytes);
+static inline void mlx5n_sq_build_ether_seg(struct mlx5e_sq *sq,
+					    struct mlx5e_tx_wqe_info *wi,
+					    struct mlx5_wqe_eth_seg *eseg,
+					    struct sk_buff *skb)
+{
+	unsigned int num_bytes;
 
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+		eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
+		if (skb->encapsulation) {
+			eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
+					  MLX5_ETH_WQE_L4_INNER_CSUM;
+			sq->stats.csum_partial_inner++;
+		} else {
+			eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
+		}
+			} else {
+				sq->stats.csum_none++;
+			}
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
-		netif_tx_stop_queue(sq->txq);
-		sq->stats.stopped++;
+	if (sq->cc != sq->prev_cc) {
+		sq->prev_cc = sq->cc;
+		sq->bf_budget = (sq->cc == sq->pc) ? MLX5E_SQ_BF_BUDGET : 0;
 	}
 
-	sq->stats.xmit_more += skb->xmit_more;
-	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
-		int bf_sz = 0;
+	wi->opcode = MLX5_OPCODE_SEND;
+	wi->bf = false;
+	wi->ihs = 0;
 
-		if (bf && test_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state))
-			bf_sz = wi->num_wqebbs << 3;
+	if (skb_is_gso(skb)) {
+		eseg->mss    = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		wi->opcode      = MLX5_OPCODE_LSO;
 
-		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, &wqe->ctrl, bf_sz);
+		if (skb->encapsulation) {
+			wi->ihs = skb_inner_transport_offset(skb) + inner_tcp_hdrlen(skb);
+			sq->stats.tso_inner_packets++;
+			sq->stats.tso_inner_bytes += skb->len - wi->ihs;
+		} else {
+			wi->ihs = skb_transport_offset(skb) + tcp_hdrlen(skb);
+			sq->stats.tso_packets++;
+			sq->stats.tso_bytes += skb->len - wi->ihs;
+		}
+
+		num_bytes = skb->len + (skb_shinfo(skb)->gso_segs - 1) * wi->ihs;
+	} else {
+		wi->bf = sq->bf_budget &&
+		     !skb->xmit_more &&
+		     !skb_shinfo(skb)->nr_frags;
+		wi->ihs = mlx5e_get_inline_hdr_size(sq, skb, wi->bf);
+		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
 	}
 
-	/* fill sq edge with nops to avoid wqe wrap around */
-	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->db.txq.skb[pi] = NULL;
-		mlx5e_send_nop(sq, false);
+	wi->num_bytes = num_bytes;
+
+	if (skb_vlan_tag_present(skb)) {
+		mlx5e_insert_vlan(eseg->inline_hdr_start, skb, wi->ihs, &skb->data,
+				  &skb->len);
+		wi->ihs += VLAN_HLEN;
+	} else {
+		memcpy(eseg->inline_hdr_start, skb->data, wi->ihs);
+		mlx5e_tx_skb_pull_inline(&skb->data, &skb->len, wi->ihs);
 	}
 
-	if (bf)
-		sq->bf_budget--;
+	eseg->inline_hdr_sz = cpu_to_be16(wi->ihs);
+}
 
-	sq->stats.packets++;
-	sq->stats.bytes += num_bytes;
-	return NETDEV_TX_OK;
+static inline void mlx5n_sq_build_datagram_seg(struct mlx5e_sq *sq,
+					       struct mlx5_wqe_datagram_seg *dseg,
+					       struct mlx5_av *av, u32 dqpn, u32 dqkey,
+					       struct sk_buff *skb)
+{
+	memcpy(&dseg->av, av, sizeof(struct mlx5_av));
+	dseg->av.dqp_dct = cpu_to_be32(dqpn | MLX5_EXTENDED_UD_AV);
+	dseg->av.key.qkey.qkey = cpu_to_be32(dqkey);
+}
 
-dma_unmap_wqe_err:
-	sq->stats.dropped++;
-	mlx5e_dma_unmap_wqe_err(sq, wi->num_dma);
+static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
+{
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+	u16                      pi    = sq->pc & wq->sz_m1;
+	void                     *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.txq.wqe_info[pi];
 
-	dev_kfree_skb_any(skb);
+	struct mlx5_wqe_ctrl_seg *ctrl_seg = wqe;
+	struct mlx5_wqe_eth_seg  *ether_seg =
+		wqe + sizeof(struct mlx5_wqe_ctrl_seg);
+	struct mlx5_wqe_data_seg *data_seg;
+
+	memset(wqe, 0, sizeof(struct mlx5_wqe_ctrl_seg) +
+	       sizeof(struct mlx5_wqe_eth_seg));
+
+	mlx5n_sq_build_ether_seg(sq, wi, ether_seg, skb);
+
+	wi->ds_cnt  = (sizeof(struct mlx5_wqe_ctrl_seg) +
+			sizeof(struct mlx5_wqe_eth_seg)) / MLX5_SEND_WQE_DS;
+	wi->ds_cnt += DIV_ROUND_UP(wi->ihs - sizeof(ether_seg->inline_hdr_start),
+			MLX5_SEND_WQE_DS);
+	data_seg = (struct mlx5_wqe_data_seg *)ctrl_seg + wi->ds_cnt;
+
+	if (mlx5n_sq_build_data_seg(sq, wi, data_seg, skb) < 0)
+		goto out;
+
+	mlx5n_sq_fill_ctrl_seg_and_send(sq, wi, ctrl_seg, skb, pi);
 
+out:
 	return NETDEV_TX_OK;
 }
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
