From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/14] net/mlx5e: CQ and RQ don't need priv pointer
Date: Mon, 27 Mar 2017 23:49:04 +0300
Message-ID: <20170327204910.20287-9-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44895 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751677AbdC0Ut5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:49:57 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove mlx5e_priv pointer from CQ and RQ structs,
it was needed only to access mdev pointer from priv pointer.

Instead we now pass mdev where needed.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  38 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 181 +++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   3 +-
 4 files changed, 99 insertions(+), 125 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 007f91f54fda..44c454b34754 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -280,7 +280,6 @@ struct mlx5e_cq {
 	struct napi_struct        *napi;
 	struct mlx5_core_cq        mcq;
 	struct mlx5e_channel      *channel;
-	struct mlx5e_priv         *priv;
 
 	/* cqe decompression */
 	struct mlx5_cqe64          title;
@@ -290,6 +289,7 @@ struct mlx5e_cq {
 	u16                        decmprs_wqe_counter;
 
 	/* control */
+	struct mlx5_core_dev      *mdev;
 	struct mlx5_frag_wq_ctrl   wq_ctrl;
 } ____cacheline_aligned_in_smp;
 
@@ -533,7 +533,7 @@ struct mlx5e_rq {
 	u32                    mpwqe_num_strides;
 	u32                    rqn;
 	struct mlx5e_channel  *channel;
-	struct mlx5e_priv     *priv;
+	struct mlx5_core_dev  *mdev;
 	struct mlx5_core_mkey  umr_mkey;
 } ____cacheline_aligned_in_smp;
 
@@ -556,6 +556,8 @@ struct mlx5e_channel {
 
 	/* control */
 	struct mlx5e_priv         *priv;
+	struct mlx5_core_dev      *mdev;
+	struct mlx5e_tstamp       *tstamp;
 	int                        ix;
 	int                        cpu;
 };
@@ -715,22 +717,6 @@ enum {
 	MLX5E_NIC_PRIO
 };
 
-struct mlx5e_profile {
-	void	(*init)(struct mlx5_core_dev *mdev,
-			struct net_device *netdev,
-			const struct mlx5e_profile *profile, void *ppriv);
-	void	(*cleanup)(struct mlx5e_priv *priv);
-	int	(*init_rx)(struct mlx5e_priv *priv);
-	void	(*cleanup_rx)(struct mlx5e_priv *priv);
-	int	(*init_tx)(struct mlx5e_priv *priv);
-	void	(*cleanup_tx)(struct mlx5e_priv *priv);
-	void	(*enable)(struct mlx5e_priv *priv);
-	void	(*disable)(struct mlx5e_priv *priv);
-	void	(*update_stats)(struct mlx5e_priv *priv);
-	int	(*max_nch)(struct mlx5_core_dev *mdev);
-	int	max_tc;
-};
-
 struct mlx5e_priv {
 	/* priv data path fields - start */
 	struct mlx5e_txqsq *txq2sq[MLX5E_MAX_NUM_CHANNELS * MLX5E_MAX_NUM_TC];
@@ -770,6 +756,22 @@ struct mlx5e_priv {
 	void                      *ppriv;
 };
 
+struct mlx5e_profile {
+	void	(*init)(struct mlx5_core_dev *mdev,
+			struct net_device *netdev,
+			const struct mlx5e_profile *profile, void *ppriv);
+	void	(*cleanup)(struct mlx5e_priv *priv);
+	int	(*init_rx)(struct mlx5e_priv *priv);
+	void	(*cleanup_rx)(struct mlx5e_priv *priv);
+	int	(*init_tx)(struct mlx5e_priv *priv);
+	void	(*cleanup_tx)(struct mlx5e_priv *priv);
+	void	(*enable)(struct mlx5e_priv *priv);
+	void	(*disable)(struct mlx5e_priv *priv);
+	void	(*update_stats)(struct mlx5e_priv *priv);
+	int	(*max_nch)(struct mlx5_core_dev *mdev);
+	int	max_tc;
+};
+
 void mlx5e_build_ptys2ethtool_map(void);
 
 u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cf8df1d3275e..a6e09c46440b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -491,11 +491,10 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	kfree(rq->mpwqe.info);
 }
 
-static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv,
+static int mlx5e_create_umr_mkey(struct mlx5_core_dev *mdev,
 				 u64 npages, u8 page_shift,
 				 struct mlx5_core_mkey *umr_mkey)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
 	int inlen = MLX5_ST_SZ_BYTES(create_mkey_in);
 	void *mkc;
 	u32 *in;
@@ -529,12 +528,11 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv,
 	return err;
 }
 
-static int mlx5e_create_rq_umr_mkey(struct mlx5e_rq *rq)
+static int mlx5e_create_rq_umr_mkey(struct mlx5_core_dev *mdev, struct mlx5e_rq *rq)
 {
-	struct mlx5e_priv *priv = rq->priv;
 	u64 num_mtts = MLX5E_REQUIRED_MTTS(mlx5_wq_ll_get_size(&rq->wq));
 
-	return mlx5e_create_umr_mkey(priv, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
+	return mlx5e_create_umr_mkey(mdev, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
 }
 
 static int mlx5e_alloc_rq(struct mlx5e_channel *c,
@@ -542,8 +540,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			  struct mlx5e_rq_param *rqp,
 			  struct mlx5e_rq *rq)
 {
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 	void *rqc = rqp->rqc;
 	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
 	u32 byte_count;
@@ -567,10 +564,10 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	rq->wq_type = params->rq_wq_type;
 	rq->pdev    = c->pdev;
 	rq->netdev  = c->netdev;
-	rq->tstamp  = &priv->tstamp;
+	rq->tstamp  = c->tstamp;
 	rq->channel = c;
 	rq->ix      = c->ix;
-	rq->priv    = c->priv;
+	rq->mdev    = mdev;
 
 	rq->xdp_prog = params->xdp_prog ? bpf_prog_inc(params->xdp_prog) : NULL;
 	if (IS_ERR(rq->xdp_prog)) {
@@ -589,7 +586,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		if (mlx5e_is_vf_vport_rep(priv)) {
+		if (mlx5e_is_vf_vport_rep(c->priv)) {
 			err = -EINVAL;
 			goto err_rq_wq_destroy;
 		}
@@ -604,7 +601,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		rq->buff.wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
 		byte_count = rq->buff.wqe_sz;
 
-		err = mlx5e_create_rq_umr_mkey(rq);
+		err = mlx5e_create_rq_umr_mkey(mdev, rq);
 		if (err)
 			goto err_rq_wq_destroy;
 		rq->mkey_be = cpu_to_be32(rq->umr_mkey.key);
@@ -621,7 +618,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			goto err_rq_wq_destroy;
 		}
 
-		if (mlx5e_is_vf_vport_rep(priv))
+		if (mlx5e_is_vf_vport_rep(c->priv))
 			rq->handle_rx_cqe = mlx5e_handle_rx_cqe_rep;
 		else
 			rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
@@ -631,7 +628,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 
 		rq->buff.wqe_sz = params->lro_en  ?
 				params->lro_wqe_sz :
-				MLX5E_SW2HW_MTU(priv->netdev->mtu);
+				MLX5E_SW2HW_MTU(c->netdev->mtu);
 		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
@@ -682,7 +679,7 @@ static void mlx5e_free_rq(struct mlx5e_rq *rq)
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		mlx5e_rq_free_mpwqe_info(rq);
-		mlx5_core_destroy_mkey(rq->priv->mdev, &rq->umr_mkey);
+		mlx5_core_destroy_mkey(rq->mdev, &rq->umr_mkey);
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
 		kfree(rq->dma_info);
@@ -700,8 +697,7 @@ static void mlx5e_free_rq(struct mlx5e_rq *rq)
 static int mlx5e_create_rq(struct mlx5e_rq *rq,
 			   struct mlx5e_rq_param *param)
 {
-	struct mlx5e_priv *priv = rq->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = rq->mdev;
 
 	void *in;
 	void *rqc;
@@ -740,8 +736,7 @@ static int mlx5e_modify_rq_state(struct mlx5e_rq *rq, int curr_state,
 				 int next_state)
 {
 	struct mlx5e_channel *c = rq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 
 	void *in;
 	void *rqc;
@@ -768,9 +763,7 @@ static int mlx5e_modify_rq_state(struct mlx5e_rq *rq, int curr_state,
 static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 {
 	struct mlx5e_channel *c = rq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
-
+	struct mlx5_core_dev *mdev = c->mdev;
 	void *in;
 	void *rqc;
 	int inlen;
@@ -798,14 +791,14 @@ static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 
 static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 {
-	mlx5_core_destroy_rq(rq->priv->mdev, rq->rqn);
+	mlx5_core_destroy_rq(rq->mdev, rq->rqn);
 }
 
 static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 {
 	unsigned long exp_time = jiffies + msecs_to_jiffies(20000);
 	struct mlx5e_channel *c = rq->channel;
-	struct mlx5e_priv *priv = c->priv;
+
 	struct mlx5_wq_ll *wq = &rq->wq;
 	u16 min_wqes = mlx5_min_rx_wqes(rq->wq_type, mlx5_wq_ll_get_size(wq));
 
@@ -816,7 +809,7 @@ static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 		msleep(20);
 	}
 
-	netdev_warn(priv->netdev, "Failed to get min RX wqes on RQN[0x%x] wq cur_sz(%d) min_rx_wqes(%d)\n",
+	netdev_warn(c->netdev, "Failed to get min RX wqes on RQN[0x%x] wq cur_sz(%d) min_rx_wqes(%d)\n",
 		    rq->rqn, wq->cur_sz, min_wqes);
 	return -ETIMEDOUT;
 }
@@ -926,8 +919,7 @@ static int mlx5e_alloc_xdpsq(struct mlx5e_channel *c,
 			     struct mlx5e_xdpsq *sq)
 {
 	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
-	struct mlx5e_priv *priv    = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 	int err;
 
 	sq->pdev      = c->pdev;
@@ -982,8 +974,7 @@ static int mlx5e_alloc_icosq(struct mlx5e_channel *c,
 			     struct mlx5e_icosq *sq)
 {
 	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
-	struct mlx5e_priv *priv    = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 	int err;
 
 	sq->pdev      = c->pdev;
@@ -1052,12 +1043,11 @@ static int mlx5e_alloc_txqsq(struct mlx5e_channel *c,
 			     struct mlx5e_txqsq *sq)
 {
 	void *sqc_wq               = MLX5_ADDR_OF(sqc, param->sqc, wq);
-	struct mlx5e_priv *priv    = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 	int err;
 
 	sq->pdev      = c->pdev;
-	sq->tstamp    = &priv->tstamp;
+	sq->tstamp    = c->tstamp;
 	sq->mkey_be   = c->mkey_be;
 	sq->channel   = c;
 	sq->txq_ix    = txq_ix;
@@ -1099,13 +1089,11 @@ struct mlx5e_create_sq_param {
 	u8                          min_inline_mode;
 };
 
-static int mlx5e_create_sq(struct mlx5e_priv *priv,
+static int mlx5e_create_sq(struct mlx5_core_dev *mdev,
 			   struct mlx5e_sq_param *param,
 			   struct mlx5e_create_sq_param *csp,
 			   u32 *sqn)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
-
 	void *in;
 	void *sqc;
 	void *wq;
@@ -1132,7 +1120,7 @@ static int mlx5e_create_sq(struct mlx5e_priv *priv,
 	MLX5_SET(sqc,  sqc, state, MLX5_SQC_STATE_RST);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
-	MLX5_SET(wq,   wq, uar_page,      priv->mdev->mlx5e_res.bfreg.index);
+	MLX5_SET(wq,   wq, uar_page,      mdev->mlx5e_res.bfreg.index);
 	MLX5_SET(wq,   wq, log_wq_pg_sz,  csp->wq_ctrl->buf.page_shift -
 					  MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq, dbr_addr,      csp->wq_ctrl->db.dma);
@@ -1153,12 +1141,9 @@ struct mlx5e_modify_sq_param {
 	int rl_index;
 };
 
-static int mlx5e_modify_sq(struct mlx5e_priv *priv,
-			   u32 sqn,
+static int mlx5e_modify_sq(struct mlx5_core_dev *mdev, u32 sqn,
 			   struct mlx5e_modify_sq_param *p)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
-
 	void *in;
 	void *sqc;
 	int inlen;
@@ -1185,12 +1170,12 @@ static int mlx5e_modify_sq(struct mlx5e_priv *priv,
 	return err;
 }
 
-static void mlx5e_destroy_sq(struct mlx5e_priv *priv, u32 sqn)
+static void mlx5e_destroy_sq(struct mlx5_core_dev *mdev, u32 sqn)
 {
-	mlx5_core_destroy_sq(priv->mdev, sqn);
+	mlx5_core_destroy_sq(mdev, sqn);
 }
 
-static int mlx5e_create_sq_rdy(struct mlx5e_priv *priv,
+static int mlx5e_create_sq_rdy(struct mlx5_core_dev *mdev,
 			       struct mlx5e_sq_param *param,
 			       struct mlx5e_create_sq_param *csp,
 			       u32 *sqn)
@@ -1198,15 +1183,15 @@ static int mlx5e_create_sq_rdy(struct mlx5e_priv *priv,
 	struct mlx5e_modify_sq_param msp = {0};
 	int err;
 
-	err = mlx5e_create_sq(priv, param, csp, sqn);
+	err = mlx5e_create_sq(mdev, param, csp, sqn);
 	if (err)
 		return err;
 
 	msp.curr_state = MLX5_SQC_STATE_RST;
 	msp.next_state = MLX5_SQC_STATE_RDY;
-	err = mlx5e_modify_sq(priv, *sqn, &msp);
+	err = mlx5e_modify_sq(mdev, *sqn, &msp);
 	if (err)
-		mlx5e_destroy_sq(priv, *sqn);
+		mlx5e_destroy_sq(mdev, *sqn);
 
 	return err;
 }
@@ -1215,14 +1200,13 @@ static int mlx5e_set_sq_maxrate(struct net_device *dev,
 				struct mlx5e_txqsq *sq, u32 rate);
 
 static int mlx5e_open_txqsq(struct mlx5e_channel *c,
-			    int tc,
+			    u32 tisn,
 			    int txq_ix,
 			    struct mlx5e_params *params,
 			    struct mlx5e_sq_param *param,
 			    struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_create_sq_param csp = {};
-	struct mlx5e_priv *priv = c->priv;
 	u32 tx_rate;
 	int err;
 
@@ -1230,18 +1214,18 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 	if (err)
 		return err;
 
-	csp.tisn            = priv->tisn[tc];
+	csp.tisn            = tisn;
 	csp.tis_lst_sz      = 1;
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
 	csp.min_inline_mode = sq->min_inline_mode;
-	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
+	err = mlx5e_create_sq_rdy(c->mdev, param, &csp, &sq->sqn);
 	if (err)
 		goto err_free_txqsq;
 
-	tx_rate = priv->tx_rates[sq->txq_ix];
+	tx_rate = c->priv->tx_rates[sq->txq_ix];
 	if (tx_rate)
-		mlx5e_set_sq_maxrate(priv->netdev, sq, tx_rate);
+		mlx5e_set_sq_maxrate(c->netdev, sq, tx_rate);
 
 	return 0;
 
@@ -1254,9 +1238,7 @@ static int mlx5e_open_txqsq(struct mlx5e_channel *c,
 
 static void mlx5e_activate_txqsq(struct mlx5e_txqsq *sq)
 {
-	struct mlx5e_priv *priv = sq->channel->priv;
-
-	sq->txq = netdev_get_tx_queue(priv->netdev, sq->txq_ix);
+	sq->txq = netdev_get_tx_queue(sq->channel->netdev, sq->txq_ix);
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	netdev_tx_reset_queue(sq->txq);
 	netif_tx_start_queue(sq->txq);
@@ -1292,10 +1274,9 @@ static void mlx5e_deactivate_txqsq(struct mlx5e_txqsq *sq)
 static void mlx5e_close_txqsq(struct mlx5e_txqsq *sq)
 {
 	struct mlx5e_channel *c = sq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 
-	mlx5e_destroy_sq(priv, sq->sqn);
+	mlx5e_destroy_sq(mdev, sq->sqn);
 	if (sq->rate_limit)
 		mlx5_rl_remove_rate(mdev, sq->rate_limit);
 	mlx5e_free_txqsq_descs(sq);
@@ -1318,7 +1299,7 @@ static int mlx5e_open_icosq(struct mlx5e_channel *c,
 	csp.wq_ctrl         = &sq->wq_ctrl;
 	csp.min_inline_mode = params->tx_min_inline_mode;
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
-	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
+	err = mlx5e_create_sq_rdy(c->mdev, param, &csp, &sq->sqn);
 	if (err)
 		goto err_free_icosq;
 
@@ -1338,7 +1319,7 @@ static void mlx5e_close_icosq(struct mlx5e_icosq *sq)
 	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	napi_synchronize(&c->napi);
 
-	mlx5e_destroy_sq(c->priv, sq->sqn);
+	mlx5e_destroy_sq(c->mdev, sq->sqn);
 	mlx5e_free_icosq(sq);
 }
 
@@ -1349,7 +1330,6 @@ static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
 {
 	unsigned int ds_cnt = MLX5E_XDP_TX_DS_COUNT;
 	struct mlx5e_create_sq_param csp = {};
-	struct mlx5e_priv *priv = c->priv;
 	unsigned int inline_hdr_sz = 0;
 	int err;
 	int i;
@@ -1359,12 +1339,12 @@ static int mlx5e_open_xdpsq(struct mlx5e_channel *c,
 		return err;
 
 	csp.tis_lst_sz      = 1;
-	csp.tisn            = priv->tisn[0]; /* tc = 0 */
+	csp.tisn            = c->priv->tisn[0]; /* tc = 0 */
 	csp.cqn             = sq->cq.mcq.cqn;
 	csp.wq_ctrl         = &sq->wq_ctrl;
 	csp.min_inline_mode = sq->min_inline_mode;
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
-	err = mlx5e_create_sq_rdy(c->priv, param, &csp, &sq->sqn);
+	err = mlx5e_create_sq_rdy(c->mdev, param, &csp, &sq->sqn);
 	if (err)
 		goto err_free_xdpsq;
 
@@ -1403,7 +1383,7 @@ static void mlx5e_close_xdpsq(struct mlx5e_xdpsq *sq)
 	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	napi_synchronize(&c->napi);
 
-	mlx5e_destroy_sq(c->priv, sq->sqn);
+	mlx5e_destroy_sq(c->mdev, sq->sqn);
 	mlx5e_free_xdpsq_descs(sq);
 	mlx5e_free_xdpsq(sq);
 }
@@ -1412,8 +1392,7 @@ static int mlx5e_alloc_cq(struct mlx5e_channel *c,
 			  struct mlx5e_cq_param *param,
 			  struct mlx5e_cq *cq)
 {
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = c->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
 	int eqn_not_used;
 	unsigned int irqn;
@@ -1450,7 +1429,7 @@ static int mlx5e_alloc_cq(struct mlx5e_channel *c,
 	}
 
 	cq->channel = c;
-	cq->priv = priv;
+	cq->mdev = mdev;
 
 	return 0;
 }
@@ -1462,8 +1441,7 @@ static void mlx5e_free_cq(struct mlx5e_cq *cq)
 
 static int mlx5e_create_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 {
-	struct mlx5e_priv *priv = cq->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_dev *mdev = cq->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
 
 	void *in;
@@ -1509,10 +1487,7 @@ static int mlx5e_create_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
 {
-	struct mlx5e_priv *priv = cq->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
-
-	mlx5_core_destroy_cq(mdev, &cq->mcq);
+	mlx5_core_destroy_cq(cq->mdev, &cq->mcq);
 }
 
 static int mlx5e_open_cq(struct mlx5e_channel *c,
@@ -1520,9 +1495,8 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 			 struct mlx5e_cq_param *param,
 			 struct mlx5e_cq *cq)
 {
+	struct mlx5_core_dev *mdev = c->mdev;
 	int err;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
 
 	err = mlx5e_alloc_cq(c, param, cq);
 	if (err)
@@ -1594,7 +1568,8 @@ static int mlx5e_open_sqs(struct mlx5e_channel *c,
 	for (tc = 0; tc < params->num_tc; tc++) {
 		int txq_ix = c->ix + tc * params->num_channels;
 
-		err = mlx5e_open_txqsq(c, tc, txq_ix, params, &cparam->sq, &c->sq[tc]);
+		err = mlx5e_open_txqsq(c, c->priv->tisn[tc], txq_ix,
+				       params, &cparam->sq, &c->sq[tc]);
 		if (err)
 			goto err_close_sqs;
 	}
@@ -1648,7 +1623,7 @@ static int mlx5e_set_sq_maxrate(struct net_device *dev,
 	msp.next_state = MLX5_SQC_STATE_RDY;
 	msp.rl_index   = rl_index;
 	msp.rl_update  = true;
-	err = mlx5e_modify_sq(priv, sq->sqn, &msp);
+	err = mlx5e_modify_sq(mdev, sq->sqn, &msp);
 	if (err) {
 		netdev_err(dev, "Failed configuring rate %u: %d\n",
 			   rate, err);
@@ -1717,6 +1692,8 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		return -ENOMEM;
 
 	c->priv     = priv;
+	c->mdev     = priv->mdev;
+	c->tstamp   = &priv->tstamp;
 	c->ix       = ix;
 	c->cpu      = cpu;
 	c->pdev     = &priv->mdev->pdev->dev;
@@ -1804,7 +1781,7 @@ static void mlx5e_activate_channel(struct mlx5e_channel *c)
 	for (tc = 0; tc < c->num_tc; tc++)
 		mlx5e_activate_txqsq(&c->sq[tc]);
 	mlx5e_activate_rq(&c->rq);
-	netif_set_xps_queue(c->priv->netdev, get_cpu_mask(c->cpu), c->ix);
+	netif_set_xps_queue(c->netdev, get_cpu_mask(c->cpu), c->ix);
 }
 
 static void mlx5e_deactivate_channel(struct mlx5e_channel *c)
@@ -2631,11 +2608,10 @@ int mlx5e_close(struct net_device *netdev)
 	return err;
 }
 
-static int mlx5e_alloc_drop_rq(struct mlx5e_priv *priv,
+static int mlx5e_alloc_drop_rq(struct mlx5_core_dev *mdev,
 			       struct mlx5e_rq *rq,
 			       struct mlx5e_rq_param *param)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqc = param->rqc;
 	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
 	int err;
@@ -2647,16 +2623,15 @@ static int mlx5e_alloc_drop_rq(struct mlx5e_priv *priv,
 	if (err)
 		return err;
 
-	rq->priv = priv;
+	rq->mdev = mdev;
 
 	return 0;
 }
 
-static int mlx5e_alloc_drop_cq(struct mlx5e_priv *priv,
+static int mlx5e_alloc_drop_cq(struct mlx5_core_dev *mdev,
 			       struct mlx5e_cq *cq,
 			       struct mlx5e_cq_param *param)
 {
-	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
 	int eqn_not_used;
 	unsigned int irqn;
@@ -2679,24 +2654,22 @@ static int mlx5e_alloc_drop_cq(struct mlx5e_priv *priv,
 	mcq->event      = mlx5e_cq_error_event;
 	mcq->irqn       = irqn;
 
-	cq->priv = priv;
+	cq->mdev = mdev;
 
 	return 0;
 }
 
-static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
+static int mlx5e_open_drop_rq(struct mlx5_core_dev *mdev,
+			      struct mlx5e_rq *drop_rq)
 {
-	struct mlx5e_cq_param cq_param;
-	struct mlx5e_rq_param rq_param;
-	struct mlx5e_rq *rq = &priv->drop_rq;
-	struct mlx5e_cq *cq = &priv->drop_rq.cq;
+	struct mlx5e_cq_param cq_param = {};
+	struct mlx5e_rq_param rq_param = {};
+	struct mlx5e_cq *cq = &drop_rq->cq;
 	int err;
 
-	memset(&cq_param, 0, sizeof(cq_param));
-	memset(&rq_param, 0, sizeof(rq_param));
 	mlx5e_build_drop_rq_param(&rq_param);
 
-	err = mlx5e_alloc_drop_cq(priv, cq, &cq_param);
+	err = mlx5e_alloc_drop_cq(mdev, cq, &cq_param);
 	if (err)
 		return err;
 
@@ -2704,34 +2677,34 @@ static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
 	if (err)
 		goto err_free_cq;
 
-	err = mlx5e_alloc_drop_rq(priv, rq, &rq_param);
+	err = mlx5e_alloc_drop_rq(mdev, drop_rq, &rq_param);
 	if (err)
 		goto err_destroy_cq;
 
-	err = mlx5e_create_rq(rq, &rq_param);
+	err = mlx5e_create_rq(drop_rq, &rq_param);
 	if (err)
 		goto err_free_rq;
 
 	return 0;
 
 err_free_rq:
-	mlx5e_free_rq(&priv->drop_rq);
+	mlx5e_free_rq(drop_rq);
 
 err_destroy_cq:
-	mlx5e_destroy_cq(&priv->drop_rq.cq);
+	mlx5e_destroy_cq(cq);
 
 err_free_cq:
-	mlx5e_free_cq(&priv->drop_rq.cq);
+	mlx5e_free_cq(cq);
 
 	return err;
 }
 
-static void mlx5e_close_drop_rq(struct mlx5e_priv *priv)
+static void mlx5e_close_drop_rq(struct mlx5e_rq *drop_rq)
 {
-	mlx5e_destroy_rq(&priv->drop_rq);
-	mlx5e_free_rq(&priv->drop_rq);
-	mlx5e_destroy_cq(&priv->drop_rq.cq);
-	mlx5e_free_cq(&priv->drop_rq.cq);
+	mlx5e_destroy_rq(drop_rq);
+	mlx5e_free_rq(drop_rq);
+	mlx5e_destroy_cq(&drop_rq->cq);
+	mlx5e_free_cq(&drop_rq->cq);
 }
 
 static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
@@ -4151,7 +4124,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	if (err)
 		goto out;
 
-	err = mlx5e_open_drop_rq(priv);
+	err = mlx5e_open_drop_rq(mdev, &priv->drop_rq);
 	if (err) {
 		mlx5_core_err(mdev, "open drop rq failed, %d\n", err);
 		goto err_cleanup_tx;
@@ -4184,7 +4157,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	return 0;
 
 err_close_drop_rq:
-	mlx5e_close_drop_rq(priv);
+	mlx5e_close_drop_rq(&priv->drop_rq);
 
 err_cleanup_tx:
 	profile->cleanup_tx(priv);
@@ -4248,7 +4221,7 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 
 	mlx5e_destroy_q_counter(priv);
 	profile->cleanup_rx(priv);
-	mlx5e_close_drop_rq(priv);
+	mlx5e_close_drop_rq(&priv->drop_rq);
 	profile->cleanup_tx(priv);
 	cancel_delayed_work_sync(&priv->update_stats_work);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
index cbfac06b7ffd..02dd3a95ed8f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
@@ -293,7 +293,7 @@ void mlx5e_rx_am_work(struct work_struct *work)
 	struct mlx5e_rq *rq = container_of(am, struct mlx5e_rq, am);
 	struct mlx5e_cq_moder cur_profile = profile[am->mode][am->profile_ix];
 
-	mlx5_core_modify_cq_moderation(rq->priv->mdev, &rq->cq.mcq,
+	mlx5_core_modify_cq_moderation(rq->mdev, &rq->cq.mcq,
 				       cur_profile.usec, cur_profile.pkts);
 
 	am->state = MLX5E_AM_START_MEASURE;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 3317ef561a75..43729ec35dfc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -164,8 +164,7 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event)
 {
 	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
 	struct mlx5e_channel *c = cq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct net_device *netdev = priv->netdev;
+	struct net_device *netdev = c->netdev;
 
 	netdev_err(netdev, "%s: cqn=0x%.6x event=0x%.2x\n",
 		   __func__, mcq->cqn, event);
-- 
2.11.0
