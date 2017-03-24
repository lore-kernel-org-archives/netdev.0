From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/12] net/mlx5e: Proper names for SQ/RQ/CQ functions
Date: Sat, 25 Mar 2017 00:52:12 +0300
Message-ID: <20170324215214.25711-11-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35765 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934739AbdCXVwa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:30 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename mlx5e_{create,destroy}_{sq,rq,cq} to
mlx5e_{alloc,free}_{sq,rq,cq}.

Rename mlx5e_{enable,disable}_{sq,rq,cq} to
mlx5e_{create,destroy}_{sq,rq,cq}.

mlx5e_{enable,disable}_{sq,rq,cq} used to actually create/destroy the SQ
in FW, so we rename them to align the functions names with FW semantics.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 126 +++++++++++-----------
 1 file changed, 63 insertions(+), 63 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7faf2bcccfa6..d03afa535064 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -539,9 +539,9 @@ static int mlx5e_create_rq_umr_mkey(struct mlx5e_rq *rq)
 	return mlx5e_create_umr_mkey(priv, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
 }
 
-static int mlx5e_create_rq(struct mlx5e_channel *c,
-			   struct mlx5e_rq_param *param,
-			   struct mlx5e_rq *rq)
+static int mlx5e_alloc_rq(struct mlx5e_channel *c,
+			  struct mlx5e_rq_param *param,
+			  struct mlx5e_rq *rq)
 {
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -674,7 +674,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	return err;
 }
 
-static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
+static void mlx5e_free_rq(struct mlx5e_rq *rq)
 {
 	int i;
 
@@ -699,7 +699,7 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 	mlx5_wq_destroy(&rq->wq_ctrl);
 }
 
-static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
+static int mlx5e_create_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 {
 	struct mlx5e_priv *priv = rq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -798,7 +798,7 @@ static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
 	return err;
 }
 
-static void mlx5e_disable_rq(struct mlx5e_rq *rq)
+static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 {
 	mlx5_core_destroy_rq(rq->priv->mdev, rq->rqn);
 }
@@ -850,18 +850,18 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	struct mlx5e_tx_wqe *nopwqe;
 	int err;
 
-	err = mlx5e_create_rq(c, param, rq);
+	err = mlx5e_alloc_rq(c, param, rq);
 	if (err)
 		return err;
 
-	err = mlx5e_enable_rq(rq, param);
+	err = mlx5e_create_rq(rq, param);
 	if (err)
-		goto err_destroy_rq;
+		goto err_free_rq;
 
 	set_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RST, MLX5_RQC_STATE_RDY);
 	if (err)
-		goto err_disable_rq;
+		goto err_destroy_rq;
 
 	if (param->am_enabled)
 		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
@@ -873,11 +873,11 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	sq->stats.nop++; /* TODO no need for SQ stats in ico */
 	return 0;
 
-err_disable_rq:
-	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
-	mlx5e_disable_rq(rq);
 err_destroy_rq:
+	clear_bit(MLX5E_RQ_STATE_ENABLED, &rq->state);
 	mlx5e_destroy_rq(rq);
+err_free_rq:
+	mlx5e_free_rq(rq);
 
 	return err;
 }
@@ -888,9 +888,9 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
 	cancel_work_sync(&rq->am.work);
 
-	mlx5e_disable_rq(rq);
-	mlx5e_free_rx_descs(rq);
 	mlx5e_destroy_rq(rq);
+	mlx5e_free_rx_descs(rq);
+	mlx5e_free_rq(rq);
 }
 
 static void mlx5e_free_sq_xdp_db(struct mlx5e_sq *sq)
@@ -997,10 +997,10 @@ static int mlx5e_sq_get_max_wqebbs(u8 sq_type)
 	return MLX5_SEND_WQE_MAX_WQEBBS;
 }
 
-static int mlx5e_create_sq(struct mlx5e_channel *c,
-			   int tc,
-			   struct mlx5e_sq_param *param,
-			   struct mlx5e_sq *sq)
+static int mlx5e_alloc_sq(struct mlx5e_channel *c,
+			  int tc,
+			  struct mlx5e_sq_param *param,
+			  struct mlx5e_sq *sq)
 {
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1051,13 +1051,13 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	return err;
 }
 
-static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
+static void mlx5e_free_sq(struct mlx5e_sq *sq)
 {
 	mlx5e_free_sq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
 }
 
-static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
+static int mlx5e_create_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 {
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
@@ -1139,7 +1139,7 @@ static int mlx5e_modify_sq(struct mlx5e_sq *sq, int curr_state,
 	return err;
 }
 
-static void mlx5e_disable_sq(struct mlx5e_sq *sq)
+static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
 {
 	struct mlx5e_channel *c = sq->channel;
 	struct mlx5e_priv *priv = c->priv;
@@ -1157,19 +1157,19 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 {
 	int err;
 
-	err = mlx5e_create_sq(c, tc, param, sq);
+	err = mlx5e_alloc_sq(c, tc, param, sq);
 	if (err)
 		return err;
 
-	err = mlx5e_enable_sq(sq, param);
+	err = mlx5e_create_sq(sq, param);
 	if (err)
-		goto err_destroy_sq;
+		goto err_free_sq;
 
 	set_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RST, MLX5_SQC_STATE_RDY,
 			      false, 0);
 	if (err)
-		goto err_disable_sq;
+		goto err_destroy_sq;
 
 	if (sq->txq) {
 		netdev_tx_reset_queue(sq->txq);
@@ -1178,11 +1178,11 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 
 	return 0;
 
-err_disable_sq:
-	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
-	mlx5e_disable_sq(sq);
 err_destroy_sq:
+	clear_bit(MLX5E_SQ_STATE_ENABLED, &sq->state);
 	mlx5e_destroy_sq(sq);
+err_free_sq:
+	mlx5e_free_sq(sq);
 
 	return err;
 }
@@ -1213,14 +1213,14 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 		}
 	}
 
-	mlx5e_disable_sq(sq);
-	mlx5e_free_sq_descs(sq);
 	mlx5e_destroy_sq(sq);
+	mlx5e_free_sq_descs(sq);
+	mlx5e_free_sq(sq);
 }
 
-static int mlx5e_create_cq(struct mlx5e_channel *c,
-			   struct mlx5e_cq_param *param,
-			   struct mlx5e_cq *cq)
+static int mlx5e_alloc_cq(struct mlx5e_channel *c,
+			  struct mlx5e_cq_param *param,
+			  struct mlx5e_cq *cq)
 {
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1265,12 +1265,12 @@ static int mlx5e_create_cq(struct mlx5e_channel *c,
 	return 0;
 }
 
-static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
+static void mlx5e_free_cq(struct mlx5e_cq *cq)
 {
 	mlx5_cqwq_destroy(&cq->wq_ctrl);
 }
 
-static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
+static int mlx5e_create_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 {
 	struct mlx5e_priv *priv = cq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1317,7 +1317,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 	return 0;
 }
 
-static void mlx5e_disable_cq(struct mlx5e_cq *cq)
+static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
 {
 	struct mlx5e_priv *priv = cq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -1334,13 +1334,13 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 	struct mlx5e_priv *priv = c->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
-	err = mlx5e_create_cq(c, param, cq);
+	err = mlx5e_alloc_cq(c, param, cq);
 	if (err)
 		return err;
 
-	err = mlx5e_enable_cq(cq, param);
+	err = mlx5e_create_cq(cq, param);
 	if (err)
-		goto err_destroy_cq;
+		goto err_free_cq;
 
 	if (MLX5_CAP_GEN(mdev, cq_moderation))
 		mlx5_core_modify_cq_moderation(mdev, &cq->mcq,
@@ -1348,16 +1348,16 @@ static int mlx5e_open_cq(struct mlx5e_channel *c,
 					       moderation.pkts);
 	return 0;
 
-err_destroy_cq:
-	mlx5e_destroy_cq(cq);
+err_free_cq:
+	mlx5e_free_cq(cq);
 
 	return err;
 }
 
 static void mlx5e_close_cq(struct mlx5e_cq *cq)
 {
-	mlx5e_disable_cq(cq);
 	mlx5e_destroy_cq(cq);
+	mlx5e_free_cq(cq);
 }
 
 static int mlx5e_get_cpu(struct mlx5e_priv *priv, int ix)
@@ -2422,9 +2422,9 @@ int mlx5e_close(struct net_device *netdev)
 	return err;
 }
 
-static int mlx5e_create_drop_rq(struct mlx5e_priv *priv,
-				struct mlx5e_rq *rq,
-				struct mlx5e_rq_param *param)
+static int mlx5e_alloc_drop_rq(struct mlx5e_priv *priv,
+			       struct mlx5e_rq *rq,
+			       struct mlx5e_rq_param *param)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	void *rqc = param->rqc;
@@ -2443,9 +2443,9 @@ static int mlx5e_create_drop_rq(struct mlx5e_priv *priv,
 	return 0;
 }
 
-static int mlx5e_create_drop_cq(struct mlx5e_priv *priv,
-				struct mlx5e_cq *cq,
-				struct mlx5e_cq_param *param)
+static int mlx5e_alloc_drop_cq(struct mlx5e_priv *priv,
+			       struct mlx5e_cq *cq,
+			       struct mlx5e_cq_param *param)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
@@ -2487,42 +2487,42 @@ static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
 	memset(&rq_param, 0, sizeof(rq_param));
 	mlx5e_build_drop_rq_param(&rq_param);
 
-	err = mlx5e_create_drop_cq(priv, cq, &cq_param);
+	err = mlx5e_alloc_drop_cq(priv, cq, &cq_param);
 	if (err)
 		return err;
 
-	err = mlx5e_enable_cq(cq, &cq_param);
+	err = mlx5e_create_cq(cq, &cq_param);
 	if (err)
-		goto err_destroy_cq;
+		goto err_free_cq;
 
-	err = mlx5e_create_drop_rq(priv, rq, &rq_param);
+	err = mlx5e_alloc_drop_rq(priv, rq, &rq_param);
 	if (err)
-		goto err_disable_cq;
+		goto err_destroy_cq;
 
-	err = mlx5e_enable_rq(rq, &rq_param);
+	err = mlx5e_create_rq(rq, &rq_param);
 	if (err)
-		goto err_destroy_rq;
+		goto err_free_rq;
 
 	return 0;
 
-err_destroy_rq:
-	mlx5e_destroy_rq(&priv->drop_rq);
-
-err_disable_cq:
-	mlx5e_disable_cq(&priv->drop_rq.cq);
+err_free_rq:
+	mlx5e_free_rq(&priv->drop_rq);
 
 err_destroy_cq:
 	mlx5e_destroy_cq(&priv->drop_rq.cq);
 
+err_free_cq:
+	mlx5e_free_cq(&priv->drop_rq.cq);
+
 	return err;
 }
 
 static void mlx5e_close_drop_rq(struct mlx5e_priv *priv)
 {
-	mlx5e_disable_rq(&priv->drop_rq);
 	mlx5e_destroy_rq(&priv->drop_rq);
-	mlx5e_disable_cq(&priv->drop_rq.cq);
+	mlx5e_free_rq(&priv->drop_rq);
 	mlx5e_destroy_cq(&priv->drop_rq.cq);
+	mlx5e_free_cq(&priv->drop_rq.cq);
 }
 
 static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
-- 
2.11.0
