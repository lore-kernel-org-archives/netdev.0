From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/12] net/mlx5e: Different SQ types
Date: Sat, 25 Mar 2017 00:52:14 +0300
Message-ID: <20170324215214.25711-13-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35773 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936476AbdCXVwa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:30 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different SQ types (tx, xdp, ico) are growing apart, we separate them
and remove unwanted parts in each one of them, to simplify data path and
utilize data cache.

Remove DB union from SQ structures since it is not needed anymore as we
now have different SQ data type for each SQ.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  99 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 464 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  33 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |  50 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |   2 +-
 5 files changed, 392 insertions(+), 256 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 50f895fa5f31..bace9233dc1f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -319,13 +319,7 @@ struct mlx5e_sq_wqe_info {
 	u8  num_wqebbs;
 };
 
-enum mlx5e_sq_type {
-	MLX5E_SQ_TXQ,
-	MLX5E_SQ_ICO,
-	MLX5E_SQ_XDP
-};
-
-struct mlx5e_sq {
+struct mlx5e_txqsq {
 	/* data path */
 
 	/* dirtied @completion */
@@ -339,18 +333,11 @@ struct mlx5e_sq {
 
 	struct mlx5e_cq            cq;
 
-	/* pointers to per tx element info: write@xmit, read@completion */
-	union {
-		struct {
-			struct sk_buff           **skb;
-			struct mlx5e_sq_dma       *dma_fifo;
-			struct mlx5e_tx_wqe_info  *wqe_info;
-		} txq;
-		struct mlx5e_sq_wqe_info *ico_wqe;
-		struct {
-			struct mlx5e_dma_info     *di;
-			bool                       doorbell;
-		} xdp;
+	/* write@xmit, read@completion */
+	struct {
+		struct sk_buff           **skb;
+		struct mlx5e_sq_dma       *dma_fifo;
+		struct mlx5e_tx_wqe_info  *wqe_info;
 	} db;
 
 	/* read only */
@@ -372,7 +359,67 @@ struct mlx5e_sq {
 	struct mlx5e_channel      *channel;
 	int                        tc;
 	u32                        rate_limit;
-	u8                         type;
+} ____cacheline_aligned_in_smp;
+
+struct mlx5e_xdpsq {
+	/* data path */
+
+	/* dirtied @rx completion */
+	u16                        cc;
+	u16                        pc;
+
+	struct mlx5e_cq            cq;
+
+	/* write@xmit, read@completion */
+	struct {
+		struct mlx5e_dma_info     *di;
+		bool                       doorbell;
+	} db;
+
+	/* read only */
+	struct mlx5_wq_cyc         wq;
+	void __iomem              *uar_map;
+	u32                        sqn;
+	struct device             *pdev;
+	__be32                     mkey_be;
+	u8                         min_inline_mode;
+	unsigned long              state;
+
+	/* control path */
+	struct mlx5_wq_ctrl        wq_ctrl;
+	struct mlx5e_channel      *channel;
+} ____cacheline_aligned_in_smp;
+
+struct mlx5e_icosq {
+	/* data path */
+
+	/* dirtied @completion */
+	u16                        cc;
+
+	/* dirtied @xmit */
+	u16                        pc ____cacheline_aligned_in_smp;
+	u32                        dma_fifo_pc;
+	u16                        prev_cc;
+
+	struct mlx5e_cq            cq;
+
+	/* write@xmit, read@completion */
+	struct {
+		struct mlx5e_sq_wqe_info *ico_wqe;
+	} db;
+
+	/* read only */
+	struct mlx5_wq_cyc         wq;
+	void __iomem              *uar_map;
+	u32                        sqn;
+	u16                        edge;
+	struct device             *pdev;
+	__be32                     mkey_be;
+	unsigned long              state;
+
+	/* control path */
+	struct mlx5_wq_ctrl        wq_ctrl;
+	struct mlx5e_channel      *channel;
 } ____cacheline_aligned_in_smp;
 
 static inline bool
@@ -477,7 +524,7 @@ struct mlx5e_rq {
 
 	/* XDP */
 	struct bpf_prog       *xdp_prog;
-	struct mlx5e_sq        xdpsq;
+	struct mlx5e_xdpsq     xdpsq;
 
 	/* control */
 	struct mlx5_wq_ctrl    wq_ctrl;
@@ -497,8 +544,8 @@ enum channel_flags {
 struct mlx5e_channel {
 	/* data path */
 	struct mlx5e_rq            rq;
-	struct mlx5e_sq            sq[MLX5E_MAX_NUM_TC];
-	struct mlx5e_sq            icosq;   /* internal control operations */
+	struct mlx5e_txqsq         sq[MLX5E_MAX_NUM_TC];
+	struct mlx5e_icosq         icosq;   /* internal control operations */
 	bool                       xdp;
 	struct napi_struct         napi;
 	struct device             *pdev;
@@ -680,7 +727,7 @@ struct mlx5e_profile {
 
 struct mlx5e_priv {
 	/* priv data path fields - start */
-	struct mlx5e_sq            **txq_to_sq_map;
+	struct mlx5e_txqsq         **txq_to_sq_map;
 	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
 	struct bpf_prog *xdp_prog;
 	/* priv data path fields - end */
@@ -731,8 +778,8 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq);
-void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq);
-void mlx5e_free_sq_descs(struct mlx5e_sq *sq);
+void mlx5e_free_txqsq_descs(struct mlx5e_txqsq *sq);
+void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq);
 
 void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 			bool recycle);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index dcc67df54a5c..e849a0fc2653 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -52,7 +52,6 @@ struct mlx5e_sq_param {
 	struct mlx5_wq_param       wq;
 	u16                        max_inline;
 	u8                         min_inline_mode;
-	enum mlx5e_sq_type         type;
 };
 
 struct mlx5e_cq_param {
@@ -402,8 +401,10 @@ static inline int mlx5e_get_wqe_mtt_sz(void)
 		     MLX5_UMR_MTT_ALIGNMENT);
 }
 
-static inline void mlx5e_build_umr_wqe(struct mlx5e_rq *rq, struct mlx5e_sq *sq,
-				       struct mlx5e_umr_wqe *wqe, u16 ix)
+static inline void mlx5e_build_umr_wqe(struct mlx5e_rq *rq,
+				       struct mlx5e_icosq *sq,
+				       struct mlx5e_umr_wqe *wqe,
+				       u16 ix)
 {
 	struct mlx5_wqe_ctrl_seg      *cseg = &wqe->ctrl;
 	struct mlx5_wqe_umr_ctrl_seg *ucseg = &wqe->uctrl;
@@ -845,7 +846,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 			 struct mlx5e_rq_param *param,
 			 struct mlx5e_rq *rq)
 {
-	struct mlx5e_sq *sq = &c->icosq;
+	struct mlx5e_icosq *sq = &c->icosq;
 	u16 pi = sq->pc & sq->wq.sz_m1;
 	struct mlx5e_tx_wqe *nopwqe;
 	int err;
@@ -870,7 +871,6 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	sq->db.ico_wqe[pi].num_wqebbs = 1;
 	nopwqe = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
 	mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nopwqe->ctrl);
-	sq->stats.nop++; /* TODO no need for SQ stats in ico */
 	return 0;
 
 err_destroy_rq:
@@ -893,31 +893,70 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 	mlx5e_free_rq(rq);
 }
 
-static void mlx5e_free_sq_xdp_db(struct mlx5e_sq *sq)
+static void mlx5e_free_xdpsq_db(struct mlx5e_xdpsq *sq)
 {
-	kfree(sq->db.xdp.di);
+	kfree(sq->db.di);
 }
 
-static int mlx5e_alloc_sq_xdp_db(struct mlx5e_sq *sq, int numa)
+static int mlx5e_alloc_xdpsq_db(struct mlx5e_xdpsq *sq, int numa)
 {
 	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
 
-	sq->db.xdp.di = kzalloc_node(sizeof(*sq->db.xdp.di) * wq_sz,
+	sq->db.di = kzalloc_node(sizeof(*sq->db.di) * wq_sz,
 				     GFP_KERNEL, numa);
-	if (!sq->db.xdp.di) {
-		mlx5e_free_sq_xdp_db(sq);
+	if (!sq->db.di) {
+		mlx5e_free_xdpsq_db(sq);
 		return -ENOMEM;
 	}
 
 	return 0;
 }
 
-static void mlx5e_free_sq_ico_db(struct mlx5e_sq *sq)
+static int mlx5e_alloc_xdpsq(struct mlx5e_channel *c,
+			     struct mlx5e_sq_param *param,
+			     struct mlx5e_xdpsq *sq)
+{
+	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
+	struct mlx5e_priv *priv    = c->priv;
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
+
+	sq->pdev      = c->pdev;
+	sq->mkey_be   = c->mkey_be;
+	sq->channel   = c;
+	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
+	sq->min_inline_mode = param->min_inline_mode;
+
+	param->wq.db_numa_node = cpu_to_node(c->cpu);
+	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq, &sq->wq_ctrl);
+	if (err)
+		return err;
+	sq->wq.db = &sq->wq.db[MLX5_SND_DBR];
+
+	err = mlx5e_alloc_xdpsq_db(sq, cpu_to_node(c->cpu));
+	if (err)
+		goto err_sq_wq_destroy;
+
+	return 0;
+
+err_sq_wq_destroy:
+	mlx5_wq_destroy(&sq->wq_ctrl);
+
+	return err;
+}
+
+static void mlx5e_free_xdpsq(struct mlx5e_xdpsq *sq)
+{
+	mlx5e_free_xdpsq_db(sq);
+	mlx5_wq_destroy(&sq->wq_ctrl);
+}
+
+static void mlx5e_free_icosq_db(struct mlx5e_icosq *sq)
 {
 	kfree(sq->db.ico_wqe);
 }
 
-static int mlx5e_alloc_sq_ico_db(struct mlx5e_sq *sq, int numa)
+static int mlx5e_alloc_icosq_db(struct mlx5e_icosq *sq, int numa)
 {
 	u8 wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
 
@@ -929,119 +968,110 @@ static int mlx5e_alloc_sq_ico_db(struct mlx5e_sq *sq, int numa)
 	return 0;
 }
 
-static void mlx5e_free_sq_txq_db(struct mlx5e_sq *sq)
+static int mlx5e_alloc_icosq(struct mlx5e_channel *c,
+			     int tc,
+			     struct mlx5e_sq_param *param,
+			     struct mlx5e_icosq *sq)
 {
-	kfree(sq->db.txq.wqe_info);
-	kfree(sq->db.txq.dma_fifo);
-	kfree(sq->db.txq.skb);
-}
+	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
+	struct mlx5e_priv *priv    = c->priv;
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
 
-static int mlx5e_alloc_sq_txq_db(struct mlx5e_sq *sq, int numa)
-{
-	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
-	int df_sz = wq_sz * MLX5_SEND_WQEBB_NUM_DS;
+	sq->pdev      = c->pdev;
+	sq->mkey_be   = c->mkey_be;
+	sq->channel   = c;
+	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
 
-	sq->db.txq.skb = kzalloc_node(wq_sz * sizeof(*sq->db.txq.skb),
-				      GFP_KERNEL, numa);
-	sq->db.txq.dma_fifo = kzalloc_node(df_sz * sizeof(*sq->db.txq.dma_fifo),
-					   GFP_KERNEL, numa);
-	sq->db.txq.wqe_info = kzalloc_node(wq_sz * sizeof(*sq->db.txq.wqe_info),
-					   GFP_KERNEL, numa);
-	if (!sq->db.txq.skb || !sq->db.txq.dma_fifo || !sq->db.txq.wqe_info) {
-		mlx5e_free_sq_txq_db(sq);
-		return -ENOMEM;
-	}
+	param->wq.db_numa_node = cpu_to_node(c->cpu);
+	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq, &sq->wq_ctrl);
+	if (err)
+		return err;
+	sq->wq.db = &sq->wq.db[MLX5_SND_DBR];
 
-	sq->dma_fifo_mask = df_sz - 1;
+	err = mlx5e_alloc_icosq_db(sq, cpu_to_node(c->cpu));
+	if (err)
+		goto err_sq_wq_destroy;
+
+	sq->edge = (sq->wq.sz_m1 + 1) - MLX5E_ICOSQ_MAX_WQEBBS;
 
 	return 0;
+
+err_sq_wq_destroy:
+	mlx5_wq_destroy(&sq->wq_ctrl);
+
+	return err;
 }
 
-static void mlx5e_free_sq_db(struct mlx5e_sq *sq)
+static void mlx5e_free_icosq(struct mlx5e_icosq *sq)
 {
-	switch (sq->type) {
-	case MLX5E_SQ_TXQ:
-		mlx5e_free_sq_txq_db(sq);
-		break;
-	case MLX5E_SQ_ICO:
-		mlx5e_free_sq_ico_db(sq);
-		break;
-	case MLX5E_SQ_XDP:
-		mlx5e_free_sq_xdp_db(sq);
-		break;
-	}
+	mlx5e_free_icosq_db(sq);
+	mlx5_wq_destroy(&sq->wq_ctrl);
 }
 
-static int mlx5e_alloc_sq_db(struct mlx5e_sq *sq, int numa)
+static void mlx5e_free_txqsq_db(struct mlx5e_txqsq *sq)
 {
-	switch (sq->type) {
-	case MLX5E_SQ_TXQ:
-		return mlx5e_alloc_sq_txq_db(sq, numa);
-	case MLX5E_SQ_ICO:
-		return mlx5e_alloc_sq_ico_db(sq, numa);
-	case MLX5E_SQ_XDP:
-		return mlx5e_alloc_sq_xdp_db(sq, numa);
-	}
-
-	return 0;
+	kfree(sq->db.wqe_info);
+	kfree(sq->db.dma_fifo);
+	kfree(sq->db.skb);
 }
 
-static int mlx5e_sq_get_max_wqebbs(u8 sq_type)
+static int mlx5e_alloc_txqsq_db(struct mlx5e_txqsq *sq, int numa)
 {
-	switch (sq_type) {
-	case MLX5E_SQ_ICO:
-		return MLX5E_ICOSQ_MAX_WQEBBS;
-	case MLX5E_SQ_XDP:
-		return 1;
+	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
+	int df_sz = wq_sz * MLX5_SEND_WQEBB_NUM_DS;
+
+	sq->db.skb = kzalloc_node(wq_sz * sizeof(*sq->db.skb),
+				      GFP_KERNEL, numa);
+	sq->db.dma_fifo = kzalloc_node(df_sz * sizeof(*sq->db.dma_fifo),
+					   GFP_KERNEL, numa);
+	sq->db.wqe_info = kzalloc_node(wq_sz * sizeof(*sq->db.wqe_info),
+					   GFP_KERNEL, numa);
+	if (!sq->db.skb || !sq->db.dma_fifo || !sq->db.wqe_info) {
+		mlx5e_free_txqsq_db(sq);
+		return -ENOMEM;
 	}
-	return MLX5_SEND_WQE_MAX_WQEBBS;
+
+	sq->dma_fifo_mask = df_sz - 1;
+
+	return 0;
 }
 
-static int mlx5e_alloc_sq(struct mlx5e_channel *c,
-			  int tc,
-			  struct mlx5e_sq_param *param,
-			  struct mlx5e_sq *sq)
+static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
+			     int tc,
+			     struct mlx5e_sq_param *param,
+			     struct mlx5e_txqsq *sq)
 {
-	struct mlx5e_priv *priv = c->priv;
+	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
+	struct mlx5e_priv *priv    = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
-
-	void *sqc = param->sqc;
-	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
+	int txq_ix;
 	int err;
 
-	sq->type      = param->type;
 	sq->pdev      = c->pdev;
 	sq->tstamp    = &priv->tstamp;
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
 	sq->tc        = tc;
 	sq->uar_map   = mdev->mlx5e_res.bfreg.map;
+	sq->max_inline      = param->max_inline;
+	sq->min_inline_mode = param->min_inline_mode;
 
 	param->wq.db_numa_node = cpu_to_node(c->cpu);
-
-	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq,
-				 &sq->wq_ctrl);
+	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq, &sq->wq_ctrl);
 	if (err)
 		return err;
+	sq->wq.db    = &sq->wq.db[MLX5_SND_DBR];
 
-	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
-
-	sq->max_inline  = param->max_inline;
-	sq->min_inline_mode = param->min_inline_mode;
-
-	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
+	err = mlx5e_alloc_txqsq_db(sq, cpu_to_node(c->cpu));
 	if (err)
 		goto err_sq_wq_destroy;
 
-	if (sq->type == MLX5E_SQ_TXQ) {
-		int txq_ix;
-
-		txq_ix = c->ix + tc * priv->params.num_channels;
-		sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
-		priv->txq_to_sq_map[txq_ix] = sq;
-	}
+	txq_ix = c->ix + tc * priv->params.num_channels;
+	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
+	priv->txq_to_sq_map[txq_ix] = sq;
 
-	sq->edge = (sq->wq.sz_m1 + 1) - mlx5e_sq_get_max_wqebbs(sq->type);
+	sq->edge = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
 
 	return 0;
 
@@ -1051,9 +1081,9 @@ static int mlx5e_alloc_sq(struct mlx5e_channel *c,
 	return err;
 }
 
-static void mlx5e_free_sq(struct mlx5e_sq *sq)
+static void mlx5e_free_txqsq(struct mlx5e_txqsq *sq)
 {
-	mlx5e_free_sq_db(sq);
+	mlx5e_free_txqsq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
 }
 
@@ -1151,55 +1181,62 @@ static int mlx5e_modify_sq(struct mlx5e_priv *priv,
 	return err;
 }
 
-
 static void mlx5e_destroy_sq(struct mlx5e_priv *priv, u32 sqn)
 {
 	mlx5_core_destroy_sq(priv->mdev, sqn);
 }
 
-static int mlx5e_open_sq(struct mlx5e_channel *c,
-			 int tc,
-			 struct mlx5e_sq_param *param,
-			 struct mlx5e_sq *sq)
+static int mlx5e_create_sq_rdy(struct mlx5e_priv *priv,
+			       struct mlx5e_sq_param *param,
+			       struct mlx5e_create_sq_param *csp,
+			       u32 *sqn)
 {
-	struct mlx5e_create_sq_param csp = {0};
 	struct mlx5e_modify_sq_param msp = {0};
+	int err;
+
+	err = mlx5e_create_sq(priv, param, csp, sqn);
+	if (err)
+		return err;
+
+	msp.curr_state = MLX5_SQC_STATE_RST;
+	msp.next_state = MLX5_SQC_STATE_RDY;
+	err = mlx5e_modify_sq(priv, *sqn, &msp);
+	if (err)
+		mlx5e_destroy_sq(priv, *sqn);
+
+	return err;
+}
+
+static int mlx5e_open_txqsq(struct mlx5e_channel *c,
+			    int tc,
+			    struct mlx5e_sq_param *param,
+			    struct mlx5e_txqsq *sq)
+{
+	struct mlx5e_create_sq_param csp = {};
 	struct mlx5e_priv *priv = c->priv;
 	int err;
 
-	err = mlx5e_alloc_sq(c, tc, param, sq);
+	err = mlx5e_alloc_txqsq(c, tc, param, sq);
 	if (err)
 		return err;
 
-	csp.tisn            = param->type == MLX5E_SQ_ICO ? 0 : priv->tisn[sq->tc];
-	csp.tis_lst_sz      = param->type == MLX5E_SQ_ICO ? 0 : 1;
+	csp.tisn            = priv->tisn[sq->tc];
+	csp.tis_lst_sz      = 1;
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
 	csp.min_inline_mode = sq->min_inline_mode;
-
-	err = mlx5e_create_sq(c->priv, param, &csp, &sq->sqn);
-	if (err)
-		goto err_free_sq;
-
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
-	msp.curr_state = MLX5_SQC_STATE_RST;
-	msp.next_state = MLX5_SQC_STATE_RDY;
-	err = mlx5e_modify_sq(priv, sq->sqn, &msp);
+	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
 	if (err)
-		goto err_destroy_sq;
-
-	if (sq->txq) {
-		netdev_tx_reset_queue(sq->txq);
-		netif_tx_start_queue(sq->txq);
-	}
+		goto err_free_txqsq;
 
+	netdev_tx_reset_queue(sq->txq);
+	netif_tx_start_queue(sq->txq);
 	return 0;
 
-err_destroy_sq:
+err_free_txqsq:
 	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
-	mlx5e_destroy_sq(priv, sq->sqn);
-err_free_sq:
-	mlx5e_free_sq(sq);
+	mlx5e_free_txqsq(sq);
 
 	return err;
 }
@@ -1211,7 +1248,7 @@ static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 	__netif_tx_unlock_bh(txq);
 }
 
-static void mlx5e_close_sq(struct mlx5e_sq *sq)
+static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
@@ -1221,24 +1258,127 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 	/* prevent netif_tx_wake_queue */
 	napi_synchronize(&c->napi);
 
-	if (sq->txq) {
-		netif_tx_disable_queue(sq->txq);
+	netif_tx_disable_queue(sq->txq);
 
-		/* last doorbell out, godspeed .. */
-		if (mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc, 1)) {
-			struct mlx5e_tx_wqe *nop;
+	/* last doorbell out, godspeed .. */
+	if (mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc, 1)) {
+		struct mlx5e_tx_wqe *nop;
 
-			sq->db.txq.skb[(sq->pc & sq->wq.sz_m1)] = NULL;
-			nop = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
-			mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nop->ctrl);
-		}
+		sq->db.skb[(sq->pc & sq->wq.sz_m1)] = NULL;
+		nop = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+		mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nop->ctrl);
 	}
 
 	mlx5e_destroy_sq(priv, sq->sqn);
 	if (sq->rate_limit)
 		mlx5_rl_remove_rate(mdev, sq->rate_limit);
-	mlx5e_free_sq_descs(sq);
-	mlx5e_free_sq(sq);
+	mlx5e_free_txqsq_descs(sq);
+	mlx5e_free_txqsq(sq);
+}
+
+static int mlx5e_open_icosq(struct mlx5e_channel *c,
+			    int tc,
+			    struct mlx5e_sq_param *param,
+			    struct mlx5e_icosq *sq)
+{
+	struct mlx5e_create_sq_param csp = {};
+	int err;
+
+	err = mlx5e_alloc_icosq(c, tc, param, sq);
+	if (err)
+		return err;
+
+	csp.cqn             = sq->cq.mcq.cqn;
+	csp.wq_ctrl         = &sq->wq_ctrl;
+	csp.min_inline_mode = param->min_inline_mode;
+	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
+	if (err)
+		goto err_free_icosq;
+
+	return 0;
+
+err_free_icosq:
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	mlx5e_free_icosq(sq);
+
+	return err;
+}
+
+static void mlx5e_close_icosq(struct mlx5e_icosq *sq)
+{
+	struct mlx5e_channel *c = sq->channel;
+
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	napi_synchronize(&c->napi);
+
+	mlx5e_destroy_sq(c->priv, sq->sqn);
+	mlx5e_free_icosq(sq);
+}
+
+static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
+			    struct mlx5e_sq_param *param,
+			    struct mlx5e_xdpsq *sq)
+{
+	unsigned int ds_cnt = MLX5E_XDP_TX_DS_COUNT;
+	struct mlx5e_create_sq_param csp = {};
+	struct mlx5e_priv *priv = c->priv;
+	unsigned int inline_hdr_sz = 0;
+	int err;
+	int i;
+
+	err = mlx5e_alloc_xdpsq(c, param, sq);
+	if (err)
+		return err;
+
+	csp.tis_lst_sz      = 1;
+	csp.tisn            = priv->tisn[0]; /* tc = 0 */
+	csp.cqn             = sq->cq.mcq.cqn;
+	csp.wq_ctrl         = &sq->wq_ctrl;
+	csp.min_inline_mode = sq->min_inline_mode;
+	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
+	if (err)
+		goto err_free_xdpsq;
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
+
+	return 0;
+
+err_free_xdpsq:
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	mlx5e_free_xdpsq(sq);
+
+	return err;
+}
+
+static void mlx5e_close_xdpsq(struct mlx5e_xdpsq *sq)
+{
+	struct mlx5e_channel *c = sq->channel;
+
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
+	napi_synchronize(&c->napi);
+
+	mlx5e_destroy_sq(c->priv, sq->sqn);
+	mlx5e_free_xdpsq_descs(sq);
+	mlx5e_free_xdpsq(sq);
 }
 
 static int mlx5e_alloc_cq(struct mlx5e_channel *c,
@@ -1426,7 +1566,7 @@ static int mlx5e_open_sqs(struct mlx5e_channel *c,
 	int tc;
 
 	for (tc = 0; tc < c->num_tc; tc++) {
-		err = mlx5e_open_sq(c, tc, &cparam->sq, &c->sq[tc]);
+		err = mlx5e_open_txqsq(c, tc, &cparam->sq, &c->sq[tc]);
 		if (err)
 			goto err_close_sqs;
 	}
@@ -1435,7 +1575,7 @@ static int mlx5e_open_sqs(struct mlx5e_channel *c,
 
 err_close_sqs:
 	for (tc--; tc >= 0; tc--)
-		mlx5e_close_sq(&c->sq[tc]);
+		mlx5e_close_txqsq(&c->sq[tc]);
 
 	return err;
 }
@@ -1445,7 +1585,7 @@ static void mlx5e_close_sqs(struct mlx5e_channel *c)
 	int tc;
 
 	for (tc = 0; tc < c->num_tc; tc++)
-		mlx5e_close_sq(&c->sq[tc]);
+		mlx5e_close_txqsq(&c->sq[tc]);
 }
 
 static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
@@ -1458,7 +1598,7 @@ static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
 }
 
 static int mlx5e_set_sq_maxrate(struct net_device *dev,
-				struct mlx5e_sq *sq, u32 rate)
+				struct mlx5e_txqsq *sq, u32 rate)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1507,7 +1647,7 @@ static int mlx5e_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5e_sq *sq = priv->txq_to_sq_map[index];
+	struct mlx5e_txqsq *sq = priv->txq_to_sq_map[index];
 	int err = 0;
 
 	if (!mlx5_rl_is_supported(mdev)) {
@@ -1542,40 +1682,6 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 		      MLX5E_MAX_NUM_CHANNELS);
 }
 
-static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
-			    struct mlx5e_sq_param *param,
-			    struct mlx5e_sq *sq)
-{
-	unsigned int ds_cnt = MLX5E_XDP_TX_DS_COUNT;
-	unsigned int inline_hdr_sz = 0;
-	int err;
-	int i;
-
-	err = mlx5e_open_sq(c, 0, param, sq);
-	if (err)
-		return err;
-
-	if (sq->min_inline_mode != MLX5_INLINE_MODE_NONE) {
-		inline_hdr_sz = MLX5E_XDP_MIN_INLINE;
-		ds_cnt++;
-	}
-
-	/* Pre initialize fixed WQE fields */
-	for (i = 0; i < mlx5_wq_cyc_get_size(&sq->wq); i++) {
-		struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(&sq->wq, i);
-		struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
-		struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
-		struct mlx5_wqe_data_seg *dseg;
-
-		cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | ds_cnt);
-		eseg->inline_hdr.sz = cpu_to_be16(inline_hdr_sz);
-
-		dseg = (struct mlx5_wqe_data_seg *)cseg + (ds_cnt - 1);
-		dseg->lkey = sq->mkey_be;
-	}
-	return 0;
-}
-
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_channel_param *cparam,
 			      struct mlx5e_channel **cp)
@@ -1585,7 +1691,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	struct mlx5e_cq_moder rx_cq_profile;
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
-	struct mlx5e_sq *sq;
 	int err;
 	int i;
 
@@ -1632,7 +1737,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	napi_enable(&c->napi);
 
-	err = mlx5e_open_sq(c, 0, &cparam->icosq, &c->icosq);
+	err = mlx5e_open_icosq(c, 0, &cparam->icosq, &c->icosq);
 	if (err)
 		goto err_disable_napi;
 
@@ -1644,7 +1749,8 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		u32 txq_ix = priv->channeltc_to_txq_map[ix][i];
 
 		if (priv->tx_rates[txq_ix]) {
-			sq = priv->txq_to_sq_map[txq_ix];
+			struct mlx5e_txqsq *sq = priv->txq_to_sq_map[txq_ix];
+
 			mlx5e_set_sq_maxrate(priv->netdev, sq,
 					     priv->tx_rates[txq_ix]);
 		}
@@ -1664,13 +1770,13 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	return 0;
 err_close_xdp_sq:
 	if (c->xdp)
-		mlx5e_close_sq(&c->rq.xdpsq);
+		mlx5e_close_xdpsq(&c->rq.xdpsq);
 
 err_close_sqs:
 	mlx5e_close_sqs(c);
 
 err_close_icosq:
-	mlx5e_close_sq(&c->icosq);
+	mlx5e_close_icosq(&c->icosq);
 
 err_disable_napi:
 	napi_disable(&c->napi);
@@ -1697,9 +1803,9 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 {
 	mlx5e_close_rq(&c->rq);
 	if (c->xdp)
-		mlx5e_close_sq(&c->rq.xdpsq);
+		mlx5e_close_xdpsq(&c->rq.xdpsq);
 	mlx5e_close_sqs(c);
-	mlx5e_close_sq(&c->icosq);
+	mlx5e_close_icosq(&c->icosq);
 	napi_disable(&c->napi);
 	if (c->xdp)
 		mlx5e_close_cq(&c->rq.xdpsq.cq);
@@ -1773,7 +1879,6 @@ static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 
 	param->max_inline = priv->params.tx_max_inline;
 	param->min_inline_mode = priv->params.tx_min_inline_mode;
-	param->type = MLX5E_SQ_TXQ;
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
@@ -1846,8 +1951,6 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 
 	MLX5_SET(wq, wq, log_wq_sz, log_wq_size);
 	MLX5_SET(sqc, sqc, reg_umr, MLX5_CAP_ETH(priv->mdev, reg_umr_sq));
-
-	param->type = MLX5E_SQ_ICO;
 }
 
 static void mlx5e_build_xdpsq_param(struct mlx5e_priv *priv,
@@ -1861,7 +1964,6 @@ static void mlx5e_build_xdpsq_param(struct mlx5e_priv *priv,
 
 	param->max_inline = priv->params.tx_max_inline;
 	param->min_inline_mode = priv->params.tx_min_inline_mode;
-	param->type = MLX5E_SQ_XDP;
 }
 
 static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_channel_param *cparam)
@@ -3237,7 +3339,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 	netdev_err(dev, "TX timeout detected\n");
 
 	for (i = 0; i < priv->params.num_channels * priv->params.num_tc; i++) {
-		struct mlx5e_sq *sq = priv->txq_to_sq_map[i];
+		struct mlx5e_txqsq *sq = priv->txq_to_sq_map[i];
 
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 141dcc486063..3ecbe8c2d5e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -331,7 +331,7 @@ mlx5e_copy_skb_header_mpwqe(struct device *pdev,
 static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 {
 	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
-	struct mlx5e_sq *sq = &rq->channel->icosq;
+	struct mlx5e_icosq *sq = &rq->channel->icosq;
 	struct mlx5_wq_cyc *wq = &sq->wq;
 	struct mlx5e_umr_wqe *wqe;
 	u8 num_wqebbs = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_BB);
@@ -342,7 +342,6 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 		sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_NOP;
 		sq->db.ico_wqe[pi].num_wqebbs = 1;
 		mlx5e_post_nop(wq, sq->sqn, &sq->pc);
-		sq->stats.nop++;
 	}
 
 	wqe = mlx5_wq_cyc_get_wqe(wq, pi);
@@ -638,7 +637,7 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 	mlx5e_build_rx_skb(cqe, cqe_bcnt, rq, skb);
 }
 
-static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
+static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_xdpsq *sq)
 {
 	struct mlx5_wq_cyc *wq = &sq->wq;
 	struct mlx5e_tx_wqe *wqe;
@@ -653,9 +652,9 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 					struct mlx5e_dma_info *di,
 					const struct xdp_buff *xdp)
 {
-	struct mlx5e_sq          *sq   = &rq->xdpsq;
+	struct mlx5e_xdpsq       *sq   = &rq->xdpsq;
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
-	u16                      pi    = sq->pc & wq->sz_m1;
+	u16                       pi   = sq->pc & wq->sz_m1;
 	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
 
 	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
@@ -676,10 +675,10 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	}
 
 	if (unlikely(!mlx5e_wqc_has_room_for(wq, sq->cc, sq->pc, 1))) {
-		if (sq->db.xdp.doorbell) {
+		if (sq->db.doorbell) {
 			/* SQ is full, ring doorbell */
 			mlx5e_xmit_xdp_doorbell(sq);
-			sq->db.xdp.doorbell = false;
+			sq->db.doorbell = false;
 		}
 		rq->stats.xdp_tx_full++;
 		mlx5e_page_release(rq, di, true);
@@ -707,10 +706,10 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_SEND);
 
-	sq->db.xdp.di[pi] = *di;
+	sq->db.di[pi] = *di;
 	sq->pc++;
 
-	sq->db.xdp.doorbell = true;
+	sq->db.doorbell = true;
 	rq->stats.xdp_tx++;
 	return true;
 }
@@ -944,7 +943,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
-	struct mlx5e_sq *xdpsq = &rq->xdpsq;
+	struct mlx5e_xdpsq *xdpsq = &rq->xdpsq;
 	int work_done = 0;
 
 	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
@@ -971,9 +970,9 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		rq->handle_rx_cqe(rq, cqe);
 	}
 
-	if (xdpsq->db.xdp.doorbell) {
+	if (xdpsq->db.doorbell) {
 		mlx5e_xmit_xdp_doorbell(xdpsq);
-		xdpsq->db.xdp.doorbell = false;
+		xdpsq->db.doorbell = false;
 	}
 
 	mlx5_cqwq_update_db_record(&cq->wq);
@@ -986,12 +985,12 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 
 bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 {
-	struct mlx5e_sq *sq;
+	struct mlx5e_xdpsq *sq;
 	struct mlx5e_rq *rq;
 	u16 sqcc;
 	int i;
 
-	sq = container_of(cq, struct mlx5e_sq, cq);
+	sq = container_of(cq, struct mlx5e_xdpsq, cq);
 
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
@@ -1023,7 +1022,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 			last_wqe = (sqcc == wqe_counter);
 
 			ci = sqcc & sq->wq.sz_m1;
-			di = &sq->db.xdp.di[ci];
+			di = &sq->db.di[ci];
 
 			sqcc++;
 			/* Recycle RX page */
@@ -1040,7 +1039,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 	return (i == MLX5E_TX_CQ_POLL_BUDGET);
 }
 
-void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
+void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq)
 {
 	struct mlx5e_rq *rq = container_of(sq, struct mlx5e_rq, xdpsq);
 	struct mlx5e_dma_info *di;
@@ -1048,7 +1047,7 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
 
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
-		di = &sq->db.xdp.di[ci];
+		di = &sq->db.di[ci];
 		sq->cc++;
 
 		mlx5e_page_release(rq, di, false);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 897eaea6f51f..20f71b55651e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -53,25 +53,25 @@ static inline void mlx5e_tx_dma_unmap(struct device *pdev,
 	}
 }
 
-static inline void mlx5e_dma_push(struct mlx5e_sq *sq,
+static inline void mlx5e_dma_push(struct mlx5e_txqsq *sq,
 				  dma_addr_t addr,
 				  u32 size,
 				  enum mlx5e_dma_map_type map_type)
 {
 	u32 i = sq->dma_fifo_pc & sq->dma_fifo_mask;
 
-	sq->db.txq.dma_fifo[i].addr = addr;
-	sq->db.txq.dma_fifo[i].size = size;
-	sq->db.txq.dma_fifo[i].type = map_type;
+	sq->db.dma_fifo[i].addr = addr;
+	sq->db.dma_fifo[i].size = size;
+	sq->db.dma_fifo[i].type = map_type;
 	sq->dma_fifo_pc++;
 }
 
-static inline struct mlx5e_sq_dma *mlx5e_dma_get(struct mlx5e_sq *sq, u32 i)
+static inline struct mlx5e_sq_dma *mlx5e_dma_get(struct mlx5e_txqsq *sq, u32 i)
 {
-	return &sq->db.txq.dma_fifo[i & sq->dma_fifo_mask];
+	return &sq->db.dma_fifo[i & sq->dma_fifo_mask];
 }
 
-static void mlx5e_dma_unmap_wqe_err(struct mlx5e_sq *sq, u8 num_dma)
+static void mlx5e_dma_unmap_wqe_err(struct mlx5e_txqsq *sq, u8 num_dma)
 {
 	int i;
 
@@ -176,13 +176,13 @@ static inline void mlx5e_insert_vlan(void *start, struct sk_buff *skb, u16 ihs,
 	mlx5e_tx_skb_pull_inline(skb_data, skb_len, cpy2_sz);
 }
 
-static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
+static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb)
 {
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
 
 	u16 pi = sq->pc & wq->sz_m1;
 	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-	struct mlx5e_tx_wqe_info *wi   = &sq->db.txq.wqe_info[pi];
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.wqe_info[pi];
 
 	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
 	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
@@ -298,7 +298,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
 	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
 
-	sq->db.txq.skb[pi] = skb;
+	sq->db.skb[pi] = skb;
 
 	wi->num_wqebbs = DIV_ROUND_UP(ds_cnt, MLX5_SEND_WQEBB_NUM_DS);
 	sq->pc += wi->num_wqebbs;
@@ -320,7 +320,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->db.txq.skb[pi] = NULL;
+		sq->db.skb[pi] = NULL;
 		mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
 		sq->stats.nop++;
 	}
@@ -339,21 +339,21 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5e_sq *sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
+	struct mlx5e_txqsq *sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
 
 	return mlx5e_sq_xmit(sq, skb);
 }
 
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
-	struct mlx5e_sq *sq;
+	struct mlx5e_txqsq *sq;
 	u32 dma_fifo_cc;
 	u32 nbytes;
 	u16 npkts;
 	u16 sqcc;
 	int i;
 
-	sq = container_of(cq, struct mlx5e_sq, cq);
+	sq = container_of(cq, struct mlx5e_txqsq, cq);
 
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
@@ -391,8 +391,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			last_wqe = (sqcc == wqe_counter);
 
 			ci = sqcc & sq->wq.sz_m1;
-			skb = sq->db.txq.skb[ci];
-			wi = &sq->db.txq.wqe_info[ci];
+			skb = sq->db.skb[ci];
+			wi = &sq->db.wqe_info[ci];
 
 			if (unlikely(!skb)) { /* nop */
 				sqcc++;
@@ -441,7 +441,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	return (i == MLX5E_TX_CQ_POLL_BUDGET);
 }
 
-static void mlx5e_free_txq_sq_descs(struct mlx5e_sq *sq)
+void mlx5e_free_txqsq_descs(struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_tx_wqe_info *wi;
 	struct sk_buff *skb;
@@ -450,8 +450,8 @@ static void mlx5e_free_txq_sq_descs(struct mlx5e_sq *sq)
 
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
-		skb = sq->db.txq.skb[ci];
-		wi = &sq->db.txq.wqe_info[ci];
+		skb = sq->db.skb[ci];
+		wi = &sq->db.wqe_info[ci];
 
 		if (!skb) { /* nop */
 			sq->cc++;
@@ -469,15 +469,3 @@ static void mlx5e_free_txq_sq_descs(struct mlx5e_sq *sq)
 		sq->cc += wi->num_wqebbs;
 	}
 }
-
-void mlx5e_free_sq_descs(struct mlx5e_sq *sq)
-{
-	switch (sq->type) {
-	case MLX5E_SQ_TXQ:
-		mlx5e_free_txq_sq_descs(sq);
-		break;
-	case MLX5E_SQ_XDP:
-		mlx5e_free_xdpsq_descs(sq);
-		break;
-	}
-}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index c880022bb21a..3317ef561a75 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -51,7 +51,7 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 
 static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 {
-	struct mlx5e_sq *sq = container_of(cq, struct mlx5e_sq, cq);
+	struct mlx5e_icosq *sq = container_of(cq, struct mlx5e_icosq, cq);
 	struct mlx5_wq_cyc *wq;
 	struct mlx5_cqe64 *cqe;
 	u16 sqcc;
-- 
2.11.0
