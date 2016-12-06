From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 6/6] net/mlx5e: Change the SQ/RQ operational state to positive logic
Date: Tue,  6 Dec 2016 17:32:48 +0200
Message-ID: <1481038368-29677-7-git-send-email-saeedm@mellanox.com>
References: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55466 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752871AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
In-Reply-To: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

When using the negative logic (i.e. FLUSH state), after the RQ/SQ reopen
we will have a time interval that the RQ/SQ is not really ready and the
state indicates that its not in FLUSH state because the initial SQ/RQ struct
memory starts as zeros.
Now we changed the state to indicate if the SQ/RQ is opened and we will
set the READY state after finishing preparing all the SQ/RQ resources.

Fixes: 6e8dd6d6f4bd ("net/mlx5e: Don't wait for SQ completions on close")
Fixes: f2fde18c52a7 ("net/mlx5e: Don't wait for RQ completions on close")
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 14 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |  4 ++--
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7a43502..71382df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -241,7 +241,7 @@ struct mlx5e_tstamp {
 };
 
 enum {
-	MLX5E_RQ_STATE_FLUSH,
+	MLX5E_RQ_STATE_ENABLED,
 	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
 	MLX5E_RQ_STATE_AM,
 };
@@ -394,7 +394,7 @@ struct mlx5e_sq_dma {
 };
 
 enum {
-	MLX5E_SQ_STATE_FLUSH,
+	MLX5E_SQ_STATE_ENABLED,
 	MLX5E_SQ_STATE_BF_ENABLE,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5bf7f86..246d98e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -759,6 +759,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_rq;
 
+	set_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RST, MLX5_RQC_STATE_RDY);
 	if (err)
 		goto err_disable_rq;
@@ -773,6 +774,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	return 0;
 
 err_disable_rq:
+	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	mlx5e_disable_rq(rq);
 err_destroy_rq:
 	mlx5e_destroy_rq(rq);
@@ -782,7 +784,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 
 static void mlx5e_close_rq(struct mlx5e_rq *rq)
 {
-	set_bit(MLX5E_RQ_STATE_FLUSH, &rq->state);
+	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
 	cancel_work_sync(&rq->am.work);
 
@@ -1082,6 +1084,7 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_sq;
 
+	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RST, MLX5_SQC_STATE_RDY,
 			      false, 0);
 	if (err)
@@ -1095,6 +1098,7 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 	return 0;
 
 err_disable_sq:
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	mlx5e_disable_sq(sq);
 err_destroy_sq:
 	mlx5e_destroy_sq(sq);
@@ -1111,7 +1115,7 @@ static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 
 static void mlx5e_close_sq(struct mlx5e_sq *sq)
 {
-	set_bit(MLX5E_SQ_STATE_FLUSH, &sq->state);
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	/* prevent netif_tx_wake_queue */
 	napi_synchronize(&sq->channel->napi);
 
@@ -3091,7 +3095,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
 		sched_work = true;
-		set_bit(MLX5E_SQ_STATE_FLUSH, &sq->state);
+		clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 		netdev_err(dev, "TX timeout on queue: %d, SQ: 0x%x, CQ: 0x%x, SQ Cons: 0x%x SQ Prod: 0x%x\n",
 			   i, sq->sqn, sq->cq.mcq.cqn, sq->cc, sq->pc);
 	}
@@ -3146,13 +3150,13 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	for (i = 0; i < priv->params.num_channels; i++) {
 		struct mlx5e_channel *c = priv->channel[i];
 
-		set_bit(MLX5E_RQ_STATE_FLUSH, &c->rq.state);
+		clear_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
 		napi_synchronize(&c->napi);
 		/* prevent mlx5e_poll_rx_cq from accessing rq->xdp_prog */
 
 		old_prog = xchg(&c->rq.xdp_prog, prog);
 
-		clear_bit(MLX5E_RQ_STATE_FLUSH, &c->rq.state);
+		set_bit(MLX5E_RQ_STATE_ENABLED, &c->rq.state);
 		/* napi_schedule in case we have missed anything */
 		set_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
 		napi_schedule(&c->napi);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index e9abb6d..33495d8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -412,7 +412,7 @@ void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
 
 	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
 
-	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state))) {
+	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state))) {
 		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
 		return;
 	}
@@ -445,7 +445,7 @@ void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
 }
 
 #define RQ_CANNOT_POST(rq) \
-	(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state) || \
+	(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state) || \
 	 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
 
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
@@ -924,7 +924,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	struct mlx5e_sq *xdp_sq = &rq->channel->xdp_sq;
 	int work_done = 0;
 
-	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state)))
+	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
 		return 0;
 
 	if (cq->decmprs_left)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 70a7173..cfb6837 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -409,7 +409,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 
 	sq = container_of(cq, struct mlx5e_sq, cq);
 
-	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
+	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
 
 	npkts = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 5703f19..e5c12a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -56,7 +56,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	struct mlx5_cqe64 *cqe;
 	u16 sqcc;
 
-	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
+	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return;
 
 	cqe = mlx5e_get_cqe(cq);
@@ -113,7 +113,7 @@ static inline bool mlx5e_poll_xdp_tx_cq(struct mlx5e_cq *cq)
 
 	sq = container_of(cq, struct mlx5e_sq, cq);
 
-	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
+	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
 
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
-- 
2.7.4
