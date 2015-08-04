From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5e: Introduce the "Drop RQ"
Date: Tue,  4 Aug 2015 14:05:41 +0300
Message-ID: <1438686347-17370-3-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36444 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933419AbbHDLGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:22 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

RX traffic routed to this RQ will be silently dropped, at the NIC HW
level.

This is in preparation for netdev "light-weight" open/stop flow
change described in previous commit.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 122 ++++++++++++++++++++--
 2 files changed, 114 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index af57912..31e9610 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -217,6 +217,7 @@ struct mlx5e_cq {
 	struct napi_struct        *napi;
 	struct mlx5_core_cq        mcq;
 	struct mlx5e_channel      *channel;
+	struct mlx5e_priv         *priv;
 
 	/* control */
 	struct mlx5_wq_ctrl        wq_ctrl;
@@ -240,6 +241,7 @@ struct mlx5e_rq {
 	struct mlx5_wq_ctrl    wq_ctrl;
 	u32                    rqn;
 	struct mlx5e_channel  *channel;
+	struct mlx5e_priv     *priv;
 } ____cacheline_aligned_in_smp;
 
 struct mlx5e_tx_skb_cb {
@@ -399,6 +401,7 @@ struct mlx5e_priv {
 	u32                        pdn;
 	u32                        tdn;
 	struct mlx5_core_mr        mr;
+	struct mlx5e_rq            drop_rq;
 
 	struct mlx5e_channel     **channel;
 	u32                        tisn[MLX5E_MAX_NUM_TC];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 333c828..baa7a69 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -307,6 +307,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->netdev  = c->netdev;
 	rq->channel = c;
 	rq->ix      = c->ix;
+	rq->priv    = c->priv;
 
 	return 0;
 
@@ -324,8 +325,7 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 
 static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 {
-	struct mlx5e_channel *c = rq->channel;
-	struct mlx5e_priv *priv = c->priv;
+	struct mlx5e_priv *priv = rq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	void *in;
@@ -392,11 +392,7 @@ static int mlx5e_modify_rq(struct mlx5e_rq *rq, int curr_state, int next_state)
 
 static void mlx5e_disable_rq(struct mlx5e_rq *rq)
 {
-	struct mlx5e_channel *c = rq->channel;
-	struct mlx5e_priv *priv = c->priv;
-	struct mlx5_core_dev *mdev = priv->mdev;
-
-	mlx5_core_destroy_rq(mdev, rq->rqn);
+	mlx5_core_destroy_rq(rq->priv->mdev, rq->rqn);
 }
 
 static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
@@ -740,6 +736,7 @@ static int mlx5e_create_cq(struct mlx5e_channel *c,
 	}
 
 	cq->channel = c;
+	cq->priv = priv;
 
 	return 0;
 }
@@ -751,8 +748,7 @@ static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
 
 static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 {
-	struct mlx5e_channel *c = cq->channel;
-	struct mlx5e_priv *priv = c->priv;
+	struct mlx5e_priv *priv = cq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
 
@@ -798,8 +794,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 static void mlx5e_disable_cq(struct mlx5e_cq *cq)
 {
-	struct mlx5e_channel *c = cq->channel;
-	struct mlx5e_priv *priv = c->priv;
+	struct mlx5e_priv *priv = cq->priv;
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	mlx5_core_destroy_cq(mdev, &cq->mcq);
@@ -1119,6 +1114,111 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 	kfree(priv->channel);
 }
 
+static int mlx5e_create_drop_rq(struct mlx5e_priv *priv,
+				struct mlx5e_rq *rq,
+				struct mlx5e_rq_param *param)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	void *rqc = param->rqc;
+	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
+	int err;
+
+	param->wq.db_numa_node = param->wq.buf_numa_node;
+
+	err = mlx5_wq_ll_create(mdev, &param->wq, rqc_wq, &rq->wq,
+				&rq->wq_ctrl);
+	if (err)
+		return err;
+
+	rq->priv = priv;
+
+	return 0;
+}
+
+static int mlx5e_create_drop_cq(struct mlx5e_priv *priv,
+				struct mlx5e_cq *cq,
+				struct mlx5e_cq_param *param)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_cq *mcq = &cq->mcq;
+	int eqn_not_used;
+	int irqn;
+	int err;
+
+	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
+			       &cq->wq_ctrl);
+	if (err)
+		return err;
+
+	mlx5_vector2eqn(mdev, param->eq_ix, &eqn_not_used, &irqn);
+
+	mcq->cqe_sz     = 64;
+	mcq->set_ci_db  = cq->wq_ctrl.db.db;
+	mcq->arm_db     = cq->wq_ctrl.db.db + 1;
+	*mcq->set_ci_db = 0;
+	*mcq->arm_db    = 0;
+	mcq->vector     = param->eq_ix;
+	mcq->comp       = mlx5e_completion_event;
+	mcq->event      = mlx5e_cq_error_event;
+	mcq->irqn       = irqn;
+	mcq->uar        = &priv->cq_uar;
+
+	cq->priv = priv;
+
+	return 0;
+}
+
+static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
+{
+	struct mlx5e_cq_param cq_param;
+	struct mlx5e_rq_param rq_param;
+	struct mlx5e_rq *rq = &priv->drop_rq;
+	struct mlx5e_cq *cq = &priv->drop_rq.cq;
+	int err;
+
+	memset(&cq_param, 0, sizeof(cq_param));
+	memset(&rq_param, 0, sizeof(rq_param));
+	mlx5e_build_rx_cq_param(priv, &cq_param);
+	mlx5e_build_rq_param(priv, &rq_param);
+
+	err = mlx5e_create_drop_cq(priv, cq, &cq_param);
+	if (err)
+		return err;
+
+	err = mlx5e_enable_cq(cq, &cq_param);
+	if (err)
+		goto err_destroy_cq;
+
+	err = mlx5e_create_drop_rq(priv, rq, &rq_param);
+	if (err)
+		goto err_disable_cq;
+
+	err = mlx5e_enable_rq(rq, &rq_param);
+	if (err)
+		goto err_destroy_rq;
+
+	return 0;
+
+err_destroy_rq:
+	mlx5e_destroy_rq(&priv->drop_rq);
+
+err_disable_cq:
+	mlx5e_disable_cq(&priv->drop_rq.cq);
+
+err_destroy_cq:
+	mlx5e_destroy_cq(&priv->drop_rq.cq);
+
+	return err;
+}
+
+static void mlx5e_close_drop_rq(struct mlx5e_priv *priv)
+{
+	mlx5e_disable_rq(&priv->drop_rq);
+	mlx5e_destroy_rq(&priv->drop_rq);
+	mlx5e_disable_cq(&priv->drop_rq.cq);
+	mlx5e_destroy_cq(&priv->drop_rq.cq);
+}
+
 static int mlx5e_open_tis(struct mlx5e_priv *priv, int tc)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
-- 
2.4.3.413.ga5fe668
