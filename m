From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/12] net/mlx5e: Remove mlx5e_cq.sqrq back-pointer
Date: Wed, 17 Jun 2015 18:26:27 +0300
Message-ID: <1434554789-13758-11-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54010 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756553AbbFQP1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:27:17 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Use container_of() instead.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 2 +-
 5 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1706979..3d23bd6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -208,7 +208,6 @@ enum cq_flags {
 struct mlx5e_cq {
 	/* data path - accessed per cqe */
 	struct mlx5_cqwq           wq;
-	void                      *sqrq;
 	unsigned long              flags;
 
 	/* data path - accessed per napi poll */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 45dc8c2..40206da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -853,8 +853,6 @@ static int mlx5e_open_tx_cqs(struct mlx5e_channel *c,
 				    priv->params.tx_cq_moderation_pkts);
 		if (err)
 			goto err_close_tx_cqs;
-
-		c->sq[tc].cq.sqrq = &c->sq[tc];
 	}
 
 	return 0;
@@ -946,7 +944,6 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			    priv->params.rx_cq_moderation_pkts);
 	if (err)
 		goto err_close_tx_cqs;
-	c->rq.cq.sqrq = &c->rq;
 
 	napi_enable(&c->napi);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 06e7c74..4a25957 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -191,7 +191,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 
 bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
-	struct mlx5e_rq *rq = cq->sqrq;
+	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	int i;
 
 	/* avoid accessing cq (dma coherent memory) if not needed */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 67493ab..c789619 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -266,7 +266,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 	if (!test_and_clear_bit(MLX5E_CQ_HAS_CQES, &cq->flags))
 		return false;
 
-	sq = cq->sqrq;
+	sq = container_of(cq, struct mlx5e_sq, cq);
 
 	npkts = 0;
 	nbytes = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 9f31572..8f7cbac 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -62,7 +62,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	busy |= mlx5e_poll_rx_cq(&c->rq.cq, budget);
 
-	busy |= mlx5e_post_rx_wqes(c->rq.cq.sqrq);
+	busy |= mlx5e_post_rx_wqes(&c->rq);
 
 	for (i = 0; i < c->num_tc; i++)
 		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
-- 
2.3.7
