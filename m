From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 07/13] net/mlx5e: Added ICO SQs
Date: Wed, 16 Mar 2016 08:41:15 +0200
Message-ID: <1458110481-18080-8-git-send-email-saeedm@mellanox.com>
References: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38458 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965347AbcCPGnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 02:43:37 -0400
In-Reply-To: <1458110481-18080-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Added ICO (Internal Control Operations) SQ per channel to be used
for driver internal operations such as memory registration for
fragmented memory and nop requests upon ifconfig up.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    7 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  135 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |   55 +++++++++
 4 files changed, 174 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1a61d8a..9e20a5f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -484,6 +484,11 @@ enum {
 	MLX5E_SQ_STATE_BF_ENABLE,
 };
 
+struct mlx5e_ico_wqe_info {
+	u8  opcode;
+	u8  num_wqebbs;
+};
+
 struct mlx5e_sq {
 	/* data path */
 
@@ -525,6 +530,7 @@ struct mlx5e_sq {
 	struct mlx5_uar            uar;
 	struct mlx5e_channel      *channel;
 	int                        tc;
+	struct mlx5e_ico_wqe_info *ico_wqe_info;
 } ____cacheline_aligned_in_smp;
 
 static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
@@ -541,6 +547,7 @@ struct mlx5e_channel {
 	/* data path */
 	struct mlx5e_rq            rq;
 	struct mlx5e_sq            sq[MLX5E_MAX_NUM_TC];
+	struct mlx5e_sq            icosq;   /* internal control operations */
 	struct napi_struct         napi;
 	struct device             *pdev;
 	struct net_device         *netdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 871f3af..0507e46 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -48,6 +48,7 @@ struct mlx5e_sq_param {
 	u32                        sqc[MLX5_ST_SZ_DW(sqc)];
 	struct mlx5_wq_param       wq;
 	u16                        max_inline;
+	bool                       icosq;
 };
 
 struct mlx5e_cq_param {
@@ -59,8 +60,10 @@ struct mlx5e_cq_param {
 struct mlx5e_channel_param {
 	struct mlx5e_rq_param      rq;
 	struct mlx5e_sq_param      sq;
+	struct mlx5e_sq_param      icosq;
 	struct mlx5e_cq_param      rx_cq;
 	struct mlx5e_cq_param      tx_cq;
+	struct mlx5e_cq_param      icosq_cq;
 };
 
 static void mlx5e_update_carrier(struct mlx5e_priv *priv)
@@ -502,6 +505,8 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 			 struct mlx5e_rq_param *param,
 			 struct mlx5e_rq *rq)
 {
+	struct mlx5e_sq *sq = &c->icosq;
+	u16 pi = sq->pc & sq->wq.sz_m1;
 	int err;
 
 	err = mlx5e_create_rq(c, param, rq);
@@ -517,7 +522,10 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 		goto err_disable_rq;
 
 	set_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
-	mlx5e_send_nop(&c->sq[0], true); /* trigger mlx5e_post_rx_wqes() */
+
+	sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_NOP;
+	sq->ico_wqe_info[pi].num_wqebbs = 1;
+	mlx5e_send_nop(sq, true); /* trigger mlx5e_post_rx_wqes() */
 
 	return 0;
 
@@ -583,7 +591,6 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	void *sqc = param->sqc;
 	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
-	int txq_ix;
 	int err;
 
 	err = mlx5_alloc_map_uar(mdev, &sq->uar, true);
@@ -611,8 +618,24 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	txq_ix = c->ix + tc * priv->params.num_channels;
-	sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
+	if (param->icosq) {
+		u8 wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
+
+		sq->ico_wqe_info = kzalloc_node(sizeof(*sq->ico_wqe_info) *
+						wq_sz,
+						GFP_KERNEL,
+						cpu_to_node(c->cpu));
+		if (!sq->ico_wqe_info) {
+			err = -ENOMEM;
+			goto err_free_sq_db;
+		}
+	} else {
+		int txq_ix;
+
+		txq_ix = c->ix + tc * priv->params.num_channels;
+		sq->txq = netdev_get_tx_queue(priv->netdev, txq_ix);
+		priv->txq_to_sq_map[txq_ix] = sq;
+	}
 
 	sq->pdev      = c->pdev;
 	sq->tstamp    = &priv->tstamp;
@@ -621,10 +644,12 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->tc        = tc;
 	sq->edge      = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
 	sq->bf_budget = MLX5E_SQ_BF_BUDGET;
-	priv->txq_to_sq_map[txq_ix] = sq;
 
 	return 0;
 
+err_free_sq_db:
+	mlx5e_free_sq_db(sq);
+
 err_sq_wq_destroy:
 	mlx5_wq_destroy(&sq->wq_ctrl);
 
@@ -639,6 +664,7 @@ static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
 
+	kfree(sq->ico_wqe_info);
 	mlx5e_free_sq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
 	mlx5_unmap_free_uar(priv->mdev, &sq->uar);
@@ -667,10 +693,10 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 
 	memcpy(sqc, param->sqc, sizeof(param->sqc));
 
-	MLX5_SET(sqc,  sqc, tis_num_0,		priv->tisn[sq->tc]);
-	MLX5_SET(sqc,  sqc, cqn,		c->sq[sq->tc].cq.mcq.cqn);
+	MLX5_SET(sqc,  sqc, tis_num_0, param->icosq ? 0 : priv->tisn[sq->tc]);
+	MLX5_SET(sqc,  sqc, cqn,		sq->cq.mcq.cqn);
 	MLX5_SET(sqc,  sqc, state,		MLX5_SQC_STATE_RST);
-	MLX5_SET(sqc,  sqc, tis_lst_sz,		1);
+	MLX5_SET(sqc,  sqc, tis_lst_sz,		param->icosq ? 0 : 1);
 	MLX5_SET(sqc,  sqc, flush_in_error_en,	1);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
@@ -745,9 +771,11 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_disable_sq;
 
-	set_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
-	netdev_tx_reset_queue(sq->txq);
-	netif_tx_start_queue(sq->txq);
+	if (sq->txq) {
+		set_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
+		netdev_tx_reset_queue(sq->txq);
+		netif_tx_start_queue(sq->txq);
+	}
 
 	return 0;
 
@@ -768,15 +796,19 @@ static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 
 static void mlx5e_close_sq(struct mlx5e_sq *sq)
 {
-	clear_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
-	napi_synchronize(&sq->channel->napi); /* prevent netif_tx_wake_queue */
-	netif_tx_disable_queue(sq->txq);
+	if (sq->txq) {
+		clear_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
+		/* prevent netif_tx_wake_queue */
+		napi_synchronize(&sq->channel->napi);
+		netif_tx_disable_queue(sq->txq);
 
-	/* ensure hw is notified of all pending wqes */
-	if (mlx5e_sq_has_room_for(sq, 1))
-		mlx5e_send_nop(sq, true);
+		/* ensure hw is notified of all pending wqes */
+		if (mlx5e_sq_has_room_for(sq, 1))
+			mlx5e_send_nop(sq, true);
+
+		mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR);
+	}
 
-	mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR);
 	while (sq->cc != sq->pc) /* wait till sq is empty */
 		msleep(20);
 
@@ -1030,10 +1062,14 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
-	err = mlx5e_open_tx_cqs(c, cparam);
+	err = mlx5e_open_cq(c, &cparam->icosq_cq, &c->icosq.cq, 0, 0);
 	if (err)
 		goto err_napi_del;
 
+	err = mlx5e_open_tx_cqs(c, cparam);
+	if (err)
+		goto err_close_icosq_cq;
+
 	err = mlx5e_open_cq(c, &cparam->rx_cq, &c->rq.cq,
 			    priv->params.rx_cq_moderation_usec,
 			    priv->params.rx_cq_moderation_pkts);
@@ -1042,10 +1078,14 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 
 	napi_enable(&c->napi);
 
-	err = mlx5e_open_sqs(c, cparam);
+	err = mlx5e_open_sq(c, 0, &cparam->icosq, &c->icosq);
 	if (err)
 		goto err_disable_napi;
 
+	err = mlx5e_open_sqs(c, cparam);
+	if (err)
+		goto err_close_icosq;
+
 	err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
 	if (err)
 		goto err_close_sqs;
@@ -1058,6 +1098,9 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 err_close_sqs:
 	mlx5e_close_sqs(c);
 
+err_close_icosq:
+	mlx5e_close_sq(&c->icosq);
+
 err_disable_napi:
 	napi_disable(&c->napi);
 	mlx5e_close_cq(&c->rq.cq);
@@ -1065,6 +1108,9 @@ err_disable_napi:
 err_close_tx_cqs:
 	mlx5e_close_tx_cqs(c);
 
+err_close_icosq_cq:
+	mlx5e_close_cq(&c->icosq.cq);
+
 err_napi_del:
 	netif_napi_del(&c->napi);
 	napi_hash_del(&c->napi);
@@ -1077,9 +1123,11 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 {
 	mlx5e_close_rq(&c->rq);
 	mlx5e_close_sqs(c);
+	mlx5e_close_sq(&c->icosq);
 	napi_disable(&c->napi);
 	mlx5e_close_cq(&c->rq.cq);
 	mlx5e_close_tx_cqs(c);
+	mlx5e_close_cq(&c->icosq.cq);
 	netif_napi_del(&c->napi);
 
 	napi_hash_del(&c->napi);
@@ -1125,17 +1173,27 @@ static void mlx5e_build_drop_rq_param(struct mlx5e_rq_param *param)
 	MLX5_SET(wq, wq, log_wq_stride,    ilog2(sizeof(struct mlx5e_rx_wqe)));
 }
 
-static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
-				 struct mlx5e_sq_param *param)
+static void mlx5e_build_sq_param_common(struct mlx5e_priv *priv,
+					struct mlx5e_sq_param *param)
 {
 	void *sqc = param->sqc;
 	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
 
-	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
 	MLX5_SET(wq, wq, log_wq_stride, ilog2(MLX5_SEND_WQE_BB));
 	MLX5_SET(wq, wq, pd,            priv->pdn);
 
 	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
+}
+
+static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
+				 struct mlx5e_sq_param *param)
+{
+	void *sqc = param->sqc;
+	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
+
+	mlx5e_build_sq_param_common(priv, param);
+	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
+
 	param->max_inline = priv->params.tx_max_inline;
 }
 
@@ -1172,20 +1230,49 @@ static void mlx5e_build_tx_cq_param(struct mlx5e_priv *priv,
 {
 	void *cqc = param->cqc;
 
-	MLX5_SET(cqc, cqc, log_cq_size,  priv->params.log_sq_size);
+	MLX5_SET(cqc, cqc, log_cq_size, priv->params.log_sq_size);
 
 	mlx5e_build_common_cq_param(priv, param);
 }
 
+static void mlx5e_build_ico_cq_param(struct mlx5e_priv *priv,
+				     struct mlx5e_cq_param *param,
+				     u8 log_wq_size)
+{
+	void *cqc = param->cqc;
+
+	MLX5_SET(cqc, cqc, log_cq_size, log_wq_size);
+
+	mlx5e_build_common_cq_param(priv, param);
+}
+
+static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
+				    struct mlx5e_sq_param *param,
+				    u8 log_wq_size)
+{
+	void *sqc = param->sqc;
+	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
+
+	mlx5e_build_sq_param_common(priv, param);
+
+	MLX5_SET(wq, wq, log_wq_sz, log_wq_size);
+
+	param->icosq = true;
+}
+
 static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 				      struct mlx5e_channel_param *cparam)
 {
+	u8 icosq_log_wq_sz = 0;
+
 	memset(cparam, 0, sizeof(*cparam));
 
 	mlx5e_build_rq_param(priv, &cparam->rq);
 	mlx5e_build_sq_param(priv, &cparam->sq);
+	mlx5e_build_icosq_param(priv, &cparam->icosq, icosq_log_wq_sz);
 	mlx5e_build_rx_cq_param(priv, &cparam->rx_cq);
 	mlx5e_build_tx_cq_param(priv, &cparam->tx_cq);
+	mlx5e_build_ico_cq_param(priv, &cparam->icosq_cq, icosq_log_wq_sz);
 }
 
 static int mlx5e_open_channels(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 1ffc7cb..a8d2935 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -54,6 +54,7 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 
 	sq->skb[pi] = NULL;
 	sq->pc++;
+	sq->stats.nop++;
 
 	if (notify_hw) {
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
@@ -387,7 +388,6 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			wi = &sq->wqe_info[ci];
 
 			if (unlikely(!skb)) { /* nop */
-				sq->stats.nop++;
 				sqcc++;
 				continue;
 			}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 9bb4395..ad624cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -49,6 +49,57 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 	return cqe;
 }
 
+static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
+{
+	struct mlx5_wq_cyc *wq;
+	struct mlx5_cqe64 *cqe;
+	struct mlx5e_sq *sq;
+	u16 sqcc;
+
+	cqe = mlx5e_get_cqe(cq);
+	if (likely(!cqe))
+		return;
+
+	sq = container_of(cq, struct mlx5e_sq, cq);
+	wq = &sq->wq;
+
+	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
+	 * otherwise a cq overrun may occur
+	 */
+	sqcc = sq->cc;
+
+	do {
+		u16 ci = be16_to_cpu(cqe->wqe_counter) & wq->sz_m1;
+		struct mlx5e_ico_wqe_info *icowi = &sq->ico_wqe_info[ci];
+
+		mlx5_cqwq_pop(&cq->wq);
+		sqcc += icowi->num_wqebbs;
+
+		if (unlikely((cqe->op_own >> 4) != MLX5_CQE_REQ)) {
+			WARN_ONCE(true, "mlx5e: Bad OP in ICOSQ CQE: 0x%x\n",
+				  cqe->op_own);
+			break;
+		}
+
+		switch (icowi->opcode) {
+		case MLX5_OPCODE_NOP:
+			break;
+		default:
+			WARN_ONCE(true,
+				  "mlx5e: Bad OPCODE in ICOSQ WQE info: 0x%x\n",
+				  icowi->opcode);
+		}
+
+	} while ((cqe = mlx5e_get_cqe(cq)));
+
+	mlx5_cqwq_update_db_record(&cq->wq);
+
+	/* ensure cq space is freed before enabling more cqes */
+	wmb();
+
+	sq->cc = sqcc;
+}
+
 int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
@@ -64,6 +115,9 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
+
+	mlx5e_poll_ico_cq(&c->icosq.cq);
+
 	busy |= mlx5e_post_rx_wqes(&c->rq);
 
 	if (busy)
@@ -80,6 +134,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	for (i = 0; i < c->num_tc; i++)
 		mlx5e_cq_arm(&c->sq[i].cq);
 	mlx5e_cq_arm(&c->rq.cq);
+	mlx5e_cq_arm(&c->icosq.cq);
 
 	return work_done;
 }
-- 
1.7.1
