From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 10/11] net/mlx5e: Pop cq outside mlx5e_get_cqe
Date: Tue, 23 Jun 2015 17:14:21 +0300
Message-ID: <1435068862-26488-11-git-send-email-ogerlitz@mellanox.com>
References: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41189 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933905AbbFWOPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:15:02 -0400
In-Reply-To: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Separate between mlx5e_get_cqe() and mlx5_cqwq_pop(), this helps for
better code readability and better CQ buffer management.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 2 --
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 4a25957..760b3ef 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -209,6 +209,8 @@ bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		if (!cqe)
 			break;
 
+		mlx5_cqwq_pop(&cq->wq);
+
 		wqe_counter_be = cqe->wqe_counter;
 		wqe_counter    = be16_to_cpu(wqe_counter_be);
 		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index c789619..03f28f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -288,6 +288,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 		if (!cqe)
 			break;
 
+		mlx5_cqwq_pop(&cq->wq);
+
 		wqe_counter = be16_to_cpu(cqe->wqe_counter);
 
 		do {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index bf6b27b..2c7cb67 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -43,8 +43,6 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 	if (cqe_ownership_bit != sw_ownership_val)
 		return NULL;
 
-	mlx5_cqwq_pop(wq);
-
 	/* ensure cqe content is read after cqe ownership bit */
 	rmb();
 
-- 
2.3.7
