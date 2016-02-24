From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/7] net/mlx5e: Remove wrong poll CQ optimization
Date: Wed, 24 Feb 2016 13:18:47 +0200
Message-ID: <1456312733-22091-2-git-send-email-saeedm@mellanox.com>
References: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44388 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756979AbcBXLTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 06:19:49 -0500
In-Reply-To: <1456312733-22091-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

With the MLX5E_CQ_HAS_CQES optimization flag, the following buggy
flow might occur:
- Suppose RX is always busy, TX has a single packet every second.
- We poll a single TX cqe and clear its flag.
- We never arm it again as RX is always busy.
- TX CQ flag is never changed, and new TX cqes are not polled.

We revert this optimization.

Fixes: e586b3b0baee ('net/mlx5: Ethernet Datapath files')
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    5 -----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |    7 -------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |   10 +---------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    1 -
 4 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index aac071a..614a602 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -304,14 +304,9 @@ enum {
 	MLX5E_RQ_STATE_POST_WQES_ENABLE,
 };
 
-enum cq_flags {
-	MLX5E_CQ_HAS_CQES = 1,
-};
-
 struct mlx5e_cq {
 	/* data path - accessed per cqe */
 	struct mlx5_cqwq           wq;
-	unsigned long              flags;
 
 	/* data path - accessed per napi poll */
 	struct napi_struct        *napi;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index dd959d9..3fd6a58 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -230,10 +230,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	int work_done;
 
-	/* avoid accessing cq (dma coherent memory) if not needed */
-	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
-		return 0;
-
 	for (work_done = 0; work_done < budget; work_done++) {
 		struct mlx5e_rx_wqe *wqe;
 		struct mlx5_cqe64 *cqe;
@@ -279,8 +275,5 @@ wq_ll_pop:
 	/* ensure cq space is freed before enabling more cqes */
 	wmb();
 
-	if (work_done == budget)
-		set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
-
 	return work_done;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 2c3fba0..2beea8c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -335,10 +335,6 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 	u16 sqcc;
 	int i;
 
-	/* avoid accessing cq (dma coherent memory) if not needed */
-	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
-		return false;
-
 	sq = container_of(cq, struct mlx5e_sq, cq);
 
 	npkts = 0;
@@ -422,10 +418,6 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 				netif_tx_wake_queue(sq->txq);
 				sq->stats.wake++;
 	}
-	if (i == MLX5E_TX_CQ_POLL_BUDGET) {
-		set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
-		return true;
-	}
 
-	return false;
+	return (i == MLX5E_TX_CQ_POLL_BUDGET);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 4ac8d71..66d51a7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -88,7 +88,6 @@ void mlx5e_completion_event(struct mlx5_core_cq *mcq)
 {
 	struct mlx5e_cq *cq = container_of(mcq, struct mlx5e_cq, mcq);
 
-	set_bit(MLX5E_CQ_HAS_CQES, &cq->flags);
 	set_bit(MLX5E_CHANNEL_NAPI_SCHED, &cq->channel->flags);
 	barrier();
 	napi_schedule(cq->napi);
-- 
1.7.1
