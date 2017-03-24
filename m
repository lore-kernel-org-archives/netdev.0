From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/12] net/mlx5e: Optimize XDP frame xmit
Date: Sat, 25 Mar 2017 00:52:10 +0300
Message-ID: <20170324215214.25711-9-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35762 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936489AbdCXVwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:35 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP SQ has a fixed size WQE (MLX5E_XDP_TX_WQEBBS = 1) and only posts
one kind of WQE (MLX5_OPCODE_SEND),

Also we initialize SQ descriptors static fields once on open_xdpsq,
rather than every time on critical path.

Optimize the code in light of those facts and add a prefetch of the TX
descriptor first thing in the xdp xmit function.

Performance improvement:
System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

Test case              Before     Now        improvement
---------------------------------------------------------------
XDP TX   (1 core)      13Mpps    13.7Mpps       5%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 43 +++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 41 ++++++---------------
 3 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5e4ae94c9f6a..f02d2cb8d148 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -116,12 +116,8 @@
 	(DIV_ROUND_UP(sizeof(struct mlx5e_umr_wqe), MLX5_SEND_WQE_BB))
 
 #define MLX5E_XDP_MIN_INLINE (ETH_HLEN + VLAN_HLEN)
-#define MLX5E_XDP_IHS_DS_COUNT \
-	DIV_ROUND_UP(MLX5E_XDP_MIN_INLINE - 2, MLX5_SEND_WQE_DS)
 #define MLX5E_XDP_TX_DS_COUNT \
 	((sizeof(struct mlx5e_tx_wqe) / MLX5_SEND_WQE_DS) + 1 /* SG DS */)
-#define MLX5E_XDP_TX_WQEBBS \
-	DIV_ROUND_UP(MLX5E_XDP_TX_DS_COUNT, MLX5_SEND_WQEBB_NUM_DS)
 
 #define MLX5E_NUM_MAIN_GROUPS 9
 
@@ -352,7 +348,6 @@ struct mlx5e_sq {
 		} txq;
 		struct mlx5e_sq_wqe_info *ico_wqe;
 		struct {
-			struct mlx5e_sq_wqe_info  *wqe_info;
 			struct mlx5e_dma_info     *di;
 			bool                       doorbell;
 		} xdp;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 210033187bfe..d39ee6669b8e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -894,7 +894,6 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 static void mlx5e_free_sq_xdp_db(struct mlx5e_sq *sq)
 {
 	kfree(sq->db.xdp.di);
-	kfree(sq->db.xdp.wqe_info);
 }
 
 static int mlx5e_alloc_sq_xdp_db(struct mlx5e_sq *sq, int numa)
@@ -903,9 +902,7 @@ static int mlx5e_alloc_sq_xdp_db(struct mlx5e_sq *sq, int numa)
 
 	sq->db.xdp.di = kzalloc_node(sizeof(*sq->db.xdp.di) * wq_sz,
 				     GFP_KERNEL, numa);
-	sq->db.xdp.wqe_info = kzalloc_node(sizeof(*sq->db.xdp.wqe_info) * wq_sz,
-					   GFP_KERNEL, numa);
-	if (!sq->db.xdp.di || !sq->db.xdp.wqe_info) {
+	if (!sq->db.xdp.di) {
 		mlx5e_free_sq_xdp_db(sq);
 		return -ENOMEM;
 	}
@@ -993,7 +990,7 @@ static int mlx5e_sq_get_max_wqebbs(u8 sq_type)
 	case MLX5E_SQ_ICO:
 		return MLX5E_ICOSQ_MAX_WQEBBS;
 	case MLX5E_SQ_XDP:
-		return MLX5E_XDP_TX_WQEBBS;
+		return 1;
 	}
 	return MLX5_SEND_WQE_MAX_WQEBBS;
 }
@@ -1513,6 +1510,40 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 		      MLX5E_MAX_NUM_CHANNELS);
 }
 
+static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
+			    struct mlx5e_sq_param *param,
+			    struct mlx5e_sq *sq)
+{
+	unsigned int ds_cnt = MLX5E_XDP_TX_DS_COUNT;
+	unsigned int inline_hdr_sz = 0;
+	int err;
+	int i;
+
+	err = mlx5e_open_sq(c, 0, param, sq);
+	if (err)
+		return err;
+
+	if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {
+		inline_hdr_sz = MLX5E_XDP_MIN_INLINE;
+		ds_cnt++;
+	}
+
+	/* Pre initialize fixed WQE fields */
+	for (i = 0; i < mlx5_wq_cyc_get_size(&sq->wq); i++) {
+		struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(&sq->wq, i);
+		struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
+		struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
+		struct mlx5_wqe_data_seg *dseg;
+
+		cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | ds_cnt);
+		eseg->inline_hdr.sz = cpu_to_be16(inline_hdr_sz);
+
+		dseg = (struct mlx5_wqe_data_seg *)cseg + (ds_cnt - 1);
+		dseg->lkey = sq->mkey_be;
+	}
+	return 0;
+}
+
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
@@ -1587,7 +1618,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		}
 	}
 
-	err = c->xdp ? mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
+	err = c->xdp ? mlx5e_open_xdpsq(c, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
 	if (err)
 		goto err_close_sqs;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 040074f36313..1b50c54614ac 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -641,7 +641,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
 {
 	struct mlx5_wq_cyc *wq = &sq->wq;
 	struct mlx5e_tx_wqe *wqe;
-	u16 pi = (sq->pc - MLX5E_XDP_TX_WQEBBS) & wq->sz_m1; /* last pi */
+	u16 pi = (sq->pc - 1) & wq->sz_m1; /* last pi */
 
 	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
 
@@ -657,17 +657,17 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
 	u16                      pi    = sq->pc & wq->sz_m1;
 	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-	struct mlx5e_sq_wqe_info *wi   = &sq->db.xdp.wqe_info[pi];
 
 	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
 	struct mlx5_wqe_data_seg *dseg;
-	u8 ds_cnt = MLX5E_XDP_TX_DS_COUNT;
 
 	ptrdiff_t data_offset = xdp->data - xdp->data_hard_start;
 	dma_addr_t dma_addr  = di->addr + data_offset;
 	unsigned int dma_len = xdp->data_end - xdp->data;
 
+	prefetchw(wqe);
+
 	if (unlikely(dma_len < MLX5E_XDP_MIN_INLINE ||
 		     MLX5E_SW2HW_MTU(rq->netdev->mtu) < dma_len)) {
 		rq->stats.xdp_drop++;
@@ -675,7 +675,7 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		return false;
 	}
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
+	if (unlikely(!mlx5e_sq_has_room_for(sq, 1))) {
 		if (sq->db.xdp.doorbell) {
 			/* SQ is full, ring doorbell */
 			mlx5e_xmit_xdp_doorbell(sq);
@@ -686,35 +686,29 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		return false;
 	}
 
-	dma_sync_single_for_device(sq->pdev, dma_addr, dma_len,
-				   PCI_DMA_TODEVICE);
+	dma_sync_single_for_device(sq->pdev, dma_addr, dma_len, PCI_DMA_TODEVICE);
 
-	memset(wqe, 0, sizeof(*wqe));
+	cseg->fm_ce_se = 0;
 
 	dseg = (struct mlx5_wqe_data_seg *)eseg + 1;
+
 	/* copy the inline part if required */
 	if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {
 		memcpy(eseg->inline_hdr.start, xdp->data, MLX5E_XDP_MIN_INLINE);
 		eseg->inline_hdr.sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
 		dma_len  -= MLX5E_XDP_MIN_INLINE;
 		dma_addr += MLX5E_XDP_MIN_INLINE;
-
-		ds_cnt   += MLX5E_XDP_IHS_DS_COUNT;
 		dseg++;
 	}
 
 	/* write the dma part */
 	dseg->addr       = cpu_to_be64(dma_addr);
 	dseg->byte_count = cpu_to_be32(dma_len);
-	dseg->lkey       = sq->mkey_be;
 
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_SEND);
-	cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
 	sq->db.xdp.di[pi] = *di;
-	wi->opcode     = MLX5_OPCODE_SEND;
-	wi->num_wqebbs = MLX5E_XDP_TX_WQEBBS;
-	sq->pc += MLX5E_XDP_TX_WQEBBS;
+	sq->pc++;
 
 	sq->db.xdp.doorbell = true;
 	rq->stats.xdp_tx++;
@@ -1023,7 +1017,6 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 		wqe_counter = be16_to_cpu(cqe->wqe_counter);
 
 		do {
-			struct mlx5e_sq_wqe_info *wi;
 			struct mlx5e_dma_info *di;
 			u16 ci;
 
@@ -1031,14 +1024,8 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 
 			ci = sqcc & sq->wq.sz_m1;
 			di = &sq->db.xdp.di[ci];
-			wi = &sq->db.xdp.wqe_info[ci];
-
-			if (unlikely(wi->opcode == MLX5_OPCODE_NOP)) {
-				sqcc++;
-				continue;
-			}
 
-			sqcc += wi->num_wqebbs;
+			sqcc++;
 			/* Recycle RX page */
 			mlx5e_page_release(rq, di, true);
 		} while (!last_wqe);
@@ -1056,21 +1043,13 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
 {
 	struct mlx5e_rq *rq = container_of(sq, struct mlx5e_rq, xdpsq);
-	struct mlx5e_sq_wqe_info *wi;
 	struct mlx5e_dma_info *di;
 	u16 ci;
 
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
 		di = &sq->db.xdp.di[ci];
-		wi = &sq->db.xdp.wqe_info[ci];
-
-		if (wi->opcode == MLX5_OPCODE_NOP) {
-			sq->cc++;
-			continue;
-		}
-
-		sq->cc += wi->num_wqebbs;
+		sq->cc++;
 
 		mlx5e_page_release(rq, di, false);
 	}
-- 
2.11.0
