From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 09/11] net/mlx5e: Have a clear separation between different SQ types
Date: Wed,  7 Sep 2016 15:42:30 +0300
Message-ID: <1473252152-11379-10-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45206 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757032AbcIGMmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:54 -0400
In-Reply-To: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make a clear separate between Regular SQ (TXQ) and ICO SQ creation,
destruction and union their mutual information structures.

Don't allocate redundant TXQ skb/wqe_info/dma_fifo arrays for ICO SQ.
And have a different SQ edge for ICO SQ than TXQ SQ, to be more
accurate.

In preparation for XDP TX support.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  23 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 121 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |  28 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |   2 +-
 5 files changed, 118 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 729bae8..b2da9bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -101,6 +101,9 @@
 #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
 #define MLX5E_SQ_BF_BUDGET             16
 
+#define MLX5E_ICOSQ_MAX_WQEBBS \
+	(DIV_ROUND_UP(sizeof(struct mlx5e_umr_wqe), MLX5_SEND_WQE_BB))
+
 #define MLX5E_NUM_MAIN_GROUPS 9
 
 static inline u16 mlx5_min_rx_wqes(int wq_type, u32 wq_size)
@@ -386,6 +389,11 @@ struct mlx5e_ico_wqe_info {
 	u8  num_wqebbs;
 };
 
+enum mlx5e_sq_type {
+	MLX5E_SQ_TXQ,
+	MLX5E_SQ_ICO
+};
+
 struct mlx5e_sq {
 	/* data path */
 
@@ -403,10 +411,15 @@ struct mlx5e_sq {
 
 	struct mlx5e_cq            cq;
 
-	/* pointers to per packet info: write@xmit, read@completion */
-	struct sk_buff           **skb;
-	struct mlx5e_sq_dma       *dma_fifo;
-	struct mlx5e_tx_wqe_info  *wqe_info;
+	/* pointers to per tx element info: write@xmit, read@completion */
+	union {
+		struct {
+			struct sk_buff           **skb;
+			struct mlx5e_sq_dma       *dma_fifo;
+			struct mlx5e_tx_wqe_info  *wqe_info;
+		} txq;
+		struct mlx5e_ico_wqe_info *ico_wqe;
+	} db;
 
 	/* read only */
 	struct mlx5_wq_cyc         wq;
@@ -428,8 +441,8 @@ struct mlx5e_sq {
 	struct mlx5_uar            uar;
 	struct mlx5e_channel      *channel;
 	int                        tc;
-	struct mlx5e_ico_wqe_info *ico_wqe_info;
 	u32                        rate_limit;
+	u8                         type;
 } ____cacheline_aligned_in_smp;
 
 static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index dab8486..8baeb9e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -51,7 +51,7 @@ struct mlx5e_sq_param {
 	struct mlx5_wq_param       wq;
 	u16                        max_inline;
 	u8                         min_inline_mode;
-	bool                       icosq;
+	enum mlx5e_sq_type         type;
 };
 
 struct mlx5e_cq_param {
@@ -742,8 +742,8 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (param->am_enabled)
 		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
 
-	sq->ico_wqe_info[pi].opcode     = MLX5_OPCODE_NOP;
-	sq->ico_wqe_info[pi].num_wqebbs = 1;
+	sq->db.ico_wqe[pi].opcode     = MLX5_OPCODE_NOP;
+	sq->db.ico_wqe[pi].num_wqebbs = 1;
 	mlx5e_send_nop(sq, true); /* trigger mlx5e_post_rx_wqes() */
 
 	return 0;
@@ -767,26 +767,43 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 	mlx5e_destroy_rq(rq);
 }
 
-static void mlx5e_free_sq_db(struct mlx5e_sq *sq)
+static void mlx5e_free_sq_ico_db(struct mlx5e_sq *sq)
 {
-	kfree(sq->wqe_info);
-	kfree(sq->dma_fifo);
-	kfree(sq->skb);
+	kfree(sq->db.ico_wqe);
 }
 
-static int mlx5e_alloc_sq_db(struct mlx5e_sq *sq, int numa)
+static int mlx5e_alloc_sq_ico_db(struct mlx5e_sq *sq, int numa)
+{
+	u8 wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
+
+	sq->db.ico_wqe = kzalloc_node(sizeof(*sq->db.ico_wqe) * wq_sz,
+				      GFP_KERNEL, numa);
+	if (!sq->db.ico_wqe)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void mlx5e_free_sq_txq_db(struct mlx5e_sq *sq)
+{
+	kfree(sq->db.txq.wqe_info);
+	kfree(sq->db.txq.dma_fifo);
+	kfree(sq->db.txq.skb);
+}
+
+static int mlx5e_alloc_sq_txq_db(struct mlx5e_sq *sq, int numa)
 {
 	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
 	int df_sz = wq_sz * MLX5_SEND_WQEBB_NUM_DS;
 
-	sq->skb = kzalloc_node(wq_sz * sizeof(*sq->skb), GFP_KERNEL, numa);
-	sq->dma_fifo = kzalloc_node(df_sz * sizeof(*sq->dma_fifo), GFP_KERNEL,
-				    numa);
-	sq->wqe_info = kzalloc_node(wq_sz * sizeof(*sq->wqe_info), GFP_KERNEL,
-				    numa);
-
-	if (!sq->skb || !sq->dma_fifo || !sq->wqe_info) {
-		mlx5e_free_sq_db(sq);
+	sq->db.txq.skb = kzalloc_node(wq_sz * sizeof(*sq->db.txq.skb),
+				      GFP_KERNEL, numa);
+	sq->db.txq.dma_fifo = kzalloc_node(df_sz * sizeof(*sq->db.txq.dma_fifo),
+					   GFP_KERNEL, numa);
+	sq->db.txq.wqe_info = kzalloc_node(wq_sz * sizeof(*sq->db.txq.wqe_info),
+					   GFP_KERNEL, numa);
+	if (!sq->db.txq.skb || !sq->db.txq.dma_fifo || !sq->db.txq.wqe_info) {
+		mlx5e_free_sq_txq_db(sq);
 		return -ENOMEM;
 	}
 
@@ -795,6 +812,30 @@ static int mlx5e_alloc_sq_db(struct mlx5e_sq *sq, int numa)
 	return 0;
 }
 
+static void mlx5e_free_sq_db(struct mlx5e_sq *sq)
+{
+	switch (sq->type) {
+	case MLX5E_SQ_TXQ:
+		mlx5e_free_sq_txq_db(sq);
+		break;
+	case MLX5E_SQ_ICO:
+		mlx5e_free_sq_ico_db(sq);
+		break;
+	}
+}
+
+static int mlx5e_alloc_sq_db(struct mlx5e_sq *sq, int numa)
+{
+	switch (sq->type) {
+	case MLX5E_SQ_TXQ:
+		return mlx5e_alloc_sq_txq_db(sq, numa);
+	case MLX5E_SQ_ICO:
+		return mlx5e_alloc_sq_ico_db(sq, numa);
+	}
+
+	return 0;
+}
+
 static int mlx5e_create_sq(struct mlx5e_channel *c,
 			   int tc,
 			   struct mlx5e_sq_param *param,
@@ -805,8 +846,16 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	void *sqc = param->sqc;
 	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
+	u16 sq_max_wqebbs;
 	int err;
 
+	sq->type      = param->type;
+	sq->pdev      = c->pdev;
+	sq->tstamp    = &priv->tstamp;
+	sq->mkey_be   = c->mkey_be;
+	sq->channel   = c;
+	sq->tc        = tc;
+
 	err = mlx5_alloc_map_uar(mdev, &sq->uar, !!MLX5_CAP_GEN(mdev, bf));
 	if (err)
 		return err;
@@ -835,18 +884,8 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	if (param->icosq) {
-		u8 wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
-
-		sq->ico_wqe_info = kzalloc_node(sizeof(*sq->ico_wqe_info) *
-						wq_sz,
-						GFP_KERNEL,
-						cpu_to_node(c->cpu));
-		if (!sq->ico_wqe_info) {
-			err = -ENOMEM;
-			goto err_free_sq_db;
-		}
-	} else {
+	sq_max_wqebbs = MLX5_SEND_WQE_MAX_WQEBBS;
+	if (sq->type == MLX5E_SQ_TXQ) {
 		int txq_ix;
 
 		txq_ix = c->ix + tc * priv->params.num_channels;
@@ -854,19 +893,14 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 		priv->txq_to_sq_map[txq_ix] = sq;
 	}
 
-	sq->pdev      = c->pdev;
-	sq->tstamp    = &priv->tstamp;
-	sq->mkey_be   = c->mkey_be;
-	sq->channel   = c;
-	sq->tc        = tc;
-	sq->edge      = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
+	if (sq->type == MLX5E_SQ_ICO)
+		sq_max_wqebbs = MLX5E_ICOSQ_MAX_WQEBBS;
+
+	sq->edge      = (sq->wq.sz_m1 + 1) - sq_max_wqebbs;
 	sq->bf_budget = MLX5E_SQ_BF_BUDGET;
 
 	return 0;
 
-err_free_sq_db:
-	mlx5e_free_sq_db(sq);
-
 err_sq_wq_destroy:
 	mlx5_wq_destroy(&sq->wq_ctrl);
 
@@ -881,7 +915,6 @@ static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
 
-	kfree(sq->ico_wqe_info);
 	mlx5e_free_sq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
 	mlx5_unmap_free_uar(priv->mdev, &sq->uar);
@@ -910,11 +943,12 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 
 	memcpy(sqc, param->sqc, sizeof(param->sqc));
 
-	MLX5_SET(sqc,  sqc, tis_num_0, param->icosq ? 0 : priv->tisn[sq->tc]);
+	MLX5_SET(sqc,  sqc, tis_num_0, param->type == MLX5E_SQ_ICO ?
+				       0 : priv->tisn[sq->tc]);
 	MLX5_SET(sqc,  sqc, cqn,		sq->cq.mcq.cqn);
 	MLX5_SET(sqc,  sqc, min_wqe_inline_mode, sq->min_inline_mode);
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
-	MLX5_SET(sqc,  sqc, tis_lst_sz,		param->icosq ? 0 : 1);
+	MLX5_SET(sqc,  sqc, tis_lst_sz, param->type == MLX5E_SQ_ICO ? 0 : 1);
 	MLX5_SET(sqc,  sqc, flush_in_error_en,	1);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
@@ -1029,8 +1063,10 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 		netif_tx_disable_queue(sq->txq);
 
 		/* last doorbell out, godspeed .. */
-		if (mlx5e_sq_has_room_for(sq, 1))
+		if (mlx5e_sq_has_room_for(sq, 1)) {
+			sq->db.txq.skb[(sq->pc & sq->wq.sz_m1)] = NULL;
 			mlx5e_send_nop(sq, true);
+		}
 	}
 
 	mlx5e_disable_sq(sq);
@@ -1507,6 +1543,7 @@ static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 
 	param->max_inline = priv->params.tx_max_inline;
 	param->min_inline_mode = priv->params.tx_min_inline_mode;
+	param->type = MLX5E_SQ_TXQ;
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
@@ -1580,7 +1617,7 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_sz, log_wq_size);
 	MLX5_SET(sqc, sqc, reg_umr, MLX5_CAP_ETH(priv->mdev, reg_umr_sq));
 
-	param->icosq = true;
+	param->type = MLX5E_SQ_ICO;
 }
 
 static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_channel_param *cparam)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index cde34c8..eb489e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -337,8 +337,8 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_NOP;
-		sq->ico_wqe_info[pi].num_wqebbs = 1;
+		sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_NOP;
+		sq->db.ico_wqe[pi].num_wqebbs = 1;
 		mlx5e_send_nop(sq, true);
 	}
 
@@ -348,8 +348,8 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 		cpu_to_be32((sq->pc << MLX5_WQE_CTRL_WQE_INDEX_SHIFT) |
 			    MLX5_OPCODE_UMR);
 
-	sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_UMR;
-	sq->ico_wqe_info[pi].num_wqebbs = num_wqebbs;
+	sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_UMR;
+	sq->db.ico_wqe[pi].num_wqebbs = num_wqebbs;
 	sq->pc += num_wqebbs;
 	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 988eca9..a728303 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -52,7 +52,6 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_NOP);
 	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | 0x01);
 
-	sq->skb[pi] = NULL;
 	sq->pc++;
 	sq->stats.nop++;
 
@@ -82,15 +81,15 @@ static inline void mlx5e_dma_push(struct mlx5e_sq *sq,
 				  u32 size,
 				  enum mlx5e_dma_map_type map_type)
 {
-	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr = addr;
-	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size = size;
-	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].type = map_type;
+	sq->db.txq.dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr = addr;
+	sq->db.txq.dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size = size;
+	sq->db.txq.dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].type = map_type;
 	sq->dma_fifo_pc++;
 }
 
 static inline struct mlx5e_sq_dma *mlx5e_dma_get(struct mlx5e_sq *sq, u32 i)
 {
-	return &sq->dma_fifo[i & sq->dma_fifo_mask];
+	return &sq->db.txq.dma_fifo[i & sq->dma_fifo_mask];
 }
 
 static void mlx5e_dma_unmap_wqe_err(struct mlx5e_sq *sq, u8 num_dma)
@@ -221,7 +220,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	u16 pi = sq->pc & wq->sz_m1;
 	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-	struct mlx5e_tx_wqe_info *wi   = &sq->wqe_info[pi];
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.txq.wqe_info[pi];
 
 	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
@@ -341,7 +340,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
 	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
-	sq->skb[pi] = skb;
+	sq->db.txq.skb[pi] = skb;
 
 	wi->num_wqebbs = DIV_ROUND_UP(ds_cnt, MLX5_SEND_WQEBB_NUM_DS);
 	sq->pc += wi->num_wqebbs;
@@ -367,8 +366,10 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	}
 
 	/* fill sq edge with nops to avoid wqe wrap around */
-	while ((sq->pc & wq->sz_m1) > sq->edge)
+	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
+		sq->db.txq.skb[pi] = NULL;
 		mlx5e_send_nop(sq, false);
+	}
 
 	if (bf)
 		sq->bf_budget--;
@@ -442,8 +443,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			last_wqe = (sqcc == wqe_counter);
 
 			ci = sqcc & sq->wq.sz_m1;
-			skb = sq->skb[ci];
-			wi = &sq->wqe_info[ci];
+			skb = sq->db.txq.skb[ci];
+			wi = &sq->db.txq.wqe_info[ci];
 
 			if (unlikely(!skb)) { /* nop */
 				sqcc++;
@@ -499,10 +500,13 @@ void mlx5e_free_tx_descs(struct mlx5e_sq *sq)
 	u16 ci;
 	int i;
 
+	if (sq->type != MLX5E_SQ_TXQ)
+		return;
+
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
-		skb = sq->skb[ci];
-		wi = &sq->wqe_info[ci];
+		skb = sq->db.txq.skb[ci];
+		wi = &sq->db.txq.wqe_info[ci];
 
 		if (!skb) { /* nop */
 			sq->cc++;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 08d8b0c..47cd561 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -72,7 +72,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 
 	do {
 		u16 ci = be16_to_cpu(cqe->wqe_counter) & wq->sz_m1;
-		struct mlx5e_ico_wqe_info *icowi = &sq->ico_wqe_info[ci];
+		struct mlx5e_ico_wqe_info *icowi = &sq->db.ico_wqe[ci];
 
 		mlx5_cqwq_pop(&cq->wq);
 		sqcc += icowi->num_wqebbs;
-- 
2.7.4
