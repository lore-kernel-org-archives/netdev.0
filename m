From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 6/7] net/mlx5e: Reuse alloc cq code for all CQs allocation
Date: Fri,  7 Apr 2017 21:26:55 +0300
Message-ID: <20170407182656.6734-7-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47256 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756049AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Reuse the code for mlx5e_alloc_cq and mlx5e_alloc_drop_cq, as they
have a similar flow.

Prior to this patch, the CQEs in the "drop CQ" were not initialized,
fixed
it with the shared flow of alloc CQ.  This is not a critical bug as the
RQ connected to this CQ never moved to RTS, but still better to have
this right.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 59 +++++++++--------------
 1 file changed, 23 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b57a6e72cc86..57844ffca37f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1419,21 +1419,16 @@ static void mlx5e_close_xdpsq(struct mlx5e_xdpsq *sq)
 	mlx5e_free_xdpsq(sq);
 }
 
-static int mlx5e_alloc_cq(struct mlx5e_channel *c,
-			  struct mlx5e_cq_param *param,
-			  struct mlx5e_cq *cq)
+static int mlx5e_alloc_cq_common(struct mlx5_core_dev *mdev,
+				 struct mlx5e_cq_param *param,
+				 struct mlx5e_cq *cq)
 {
-	struct mlx5_core_dev *mdev = c->mdev;
 	struct mlx5_core_cq *mcq = &cq->mcq;
 	int eqn_not_used;
 	unsigned int irqn;
 	int err;
 	u32 i;
 
-	param->wq.buf_numa_node = cpu_to_node(c->cpu);
-	param->wq.db_numa_node  = cpu_to_node(c->cpu);
-	param->eq_ix   = c->ix;
-
 	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
 			       &cq->wq_ctrl);
 	if (err)
@@ -1441,8 +1436,6 @@ static int mlx5e_alloc_cq(struct mlx5e_channel *c,
 
 	mlx5_vector2eqn(mdev, param->eq_ix, &eqn_not_used, &irqn);
 
-	cq->napi        = &c->napi;
-
 	mcq->cqe_sz     = 64;
 	mcq->set_ci_db  = cq->wq_ctrl.db.db;
 	mcq->arm_db     = cq->wq_ctrl.db.db + 1;
@@ -1459,12 +1452,30 @@ static int mlx5e_alloc_cq(struct mlx5e_channel *c,
 		cqe->op_own = 0xf1;
 	}
 
-	cq->channel = c;
 	cq->mdev = mdev;
 
 	return 0;
 }
 
+static int mlx5e_alloc_cq(struct mlx5e_channel *c,
+			  struct mlx5e_cq_param *param,
+			  struct mlx5e_cq *cq)
+{
+	struct mlx5_core_dev *mdev = c->priv->mdev;
+	int err;
+
+	param->wq.buf_numa_node = cpu_to_node(c->cpu);
+	param->wq.db_numa_node  = cpu_to_node(c->cpu);
+	param->eq_ix   = c->ix;
+
+	err = mlx5e_alloc_cq_common(mdev, param, cq);
+
+	cq->napi    = &c->napi;
+	cq->channel = c;
+
+	return err;
+}
+
 static void mlx5e_free_cq(struct mlx5e_cq *cq)
 {
 	mlx5_cqwq_destroy(&cq->wq_ctrl);
@@ -2697,31 +2708,7 @@ static int mlx5e_alloc_drop_cq(struct mlx5_core_dev *mdev,
 			       struct mlx5e_cq *cq,
 			       struct mlx5e_cq_param *param)
 {
-	struct mlx5_core_cq *mcq = &cq->mcq;
-	int eqn_not_used;
-	unsigned int irqn;
-	int err;
-
-	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
-			       &cq->wq_ctrl);
-	if (err)
-		return err;
-
-	mlx5_vector2eqn(mdev, param->eq_ix, &eqn_not_used, &irqn);
-
-	mcq->cqe_sz     = 64;
-	mcq->set_ci_db  = cq->wq_ctrl.db.db;
-	mcq->arm_db     = cq->wq_ctrl.db.db + 1;
-	*mcq->set_ci_db = 0;
-	*mcq->arm_db    = 0;
-	mcq->vector     = param->eq_ix;
-	mcq->comp       = mlx5e_completion_event;
-	mcq->event      = mlx5e_cq_error_event;
-	mcq->irqn       = irqn;
-
-	cq->mdev = mdev;
-
-	return 0;
+	return mlx5e_alloc_cq_common(mdev, param, cq);
 }
 
 static int mlx5e_open_drop_rq(struct mlx5_core_dev *mdev,
-- 
2.11.0
