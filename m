From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/17] net/mlx5e: Non-atomic indicator for ring enabled state
Date: Sun,  3 Sep 2017 07:21:09 +0300
Message-ID: <20170903042117.28923-10-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60064 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751196AbdICEWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:13 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Rings enabled state change occurs in control path only, and is always
followed by a napi_sychronize(), so that following NAPIs read the
new value. This read does not need to be atomic.

The RQ auto-moderation bit is not set/cleared in data-path.
No need for atomic read, a regular read operation is sufficient.
In RQ creation time as well, there's no multiple threads trying
to access it yet, hence a regular read can be used.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 4 ++--
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ce8b4f648757..0c4f1f30085a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -295,6 +295,8 @@ enum {
 	MLX5E_RQ_STATE_AM,
 };
 
+#define MLX5E_TEST_BIT(state, nr) (state & BIT(nr))
+
 struct mlx5e_cq {
 	/* data path - accessed per cqe */
 	struct mlx5_cqwq           wq;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5aa4681f7c3c..411fb68794bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -929,7 +929,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 		goto err_destroy_rq;
 
 	if (params->rx_am_enabled)
-		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
+		c->rq.state |= BIT(MLX5E_RQ_STATE_AM);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 9d9c13ae6b83..a5522c3992a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -424,7 +424,7 @@ void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
 
 	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
 
-	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state))) {
+	if (unlikely(!MLX5E_TEST_BIT(rq->state, MLX5E_RQ_STATE_ENABLED))) {
 		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
 		return;
 	}
@@ -461,7 +461,7 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 	struct mlx5_wq_ll *wq = &rq->wq;
 	int err;
 
-	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
+	if (unlikely(!MLX5E_TEST_BIT(rq->state, MLX5E_RQ_STATE_ENABLED)))
 		return false;
 
 	if (mlx5_wq_ll_is_full(wq))
@@ -983,7 +983,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	struct mlx5_cqe64 *cqe;
 	int work_done = 0;
 
-	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
+	if (unlikely(!MLX5E_TEST_BIT(rq->state, MLX5E_RQ_STATE_ENABLED)))
 		return 0;
 
 	if (cq->decmprs_left)
@@ -1031,7 +1031,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 
 	sq = container_of(cq, struct mlx5e_xdpsq, cq);
 
-	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
+	if (unlikely(!MLX5E_TEST_BIT(sq->state, MLX5E_SQ_STATE_ENABLED)))
 		return false;
 
 	cqe = mlx5_cqwq_get_cqe(&cq->wq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 80d2121643ee..fee43e40fa16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -403,7 +403,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 
 	sq = container_of(cq, struct mlx5e_txqsq, cq);
 
-	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
+	if (unlikely(!MLX5E_TEST_BIT(sq->state, MLX5E_SQ_STATE_ENABLED)))
 		return false;
 
 	cqe = mlx5_cqwq_get_cqe(&cq->wq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 92db28a9ed43..7311b937e434 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -69,7 +69,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	struct mlx5_cqe64 *cqe;
 	u16 sqcc;
 
-	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
+	if (unlikely(!MLX5E_TEST_BIT(sq->state, MLX5E_SQ_STATE_ENABLED)))
 		return;
 
 	cqe = mlx5_cqwq_get_cqe(&cq->wq);
@@ -129,7 +129,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	for (i = 0; i < c->num_tc; i++)
 		mlx5e_cq_arm(&c->sq[i].cq);
 
-	if (test_bit(MLX5E_RQ_STATE_AM, &c->rq.state))
+	if (MLX5E_TEST_BIT(c->rq.state, MLX5E_RQ_STATE_AM))
 		mlx5e_rx_am(&c->rq);
 
 	mlx5e_cq_arm(&c->rq.cq);
-- 
2.13.0
