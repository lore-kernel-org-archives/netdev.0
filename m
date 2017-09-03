From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/17] net/mlx5e: NAPI busy-poll when UMR post is in progress
Date: Sun,  3 Sep 2017 07:21:06 +0300
Message-ID: <20170903042117.28923-7-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60016 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751071AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

If a UMR post is in progress, it means that there's a missing
WQE in RQ, and that a completion will be shortly available in
ICO SQ completion queue. Prefer busy-poll to handle it as soon
as possible.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index fb3b83609aea..8af6577b7501 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -456,17 +456,16 @@ void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
 	mlx5e_free_rx_mpwqe(rq, wi);
 }
 
-#define RQ_CANNOT_POST(rq) \
-	(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state) || \
-	 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
-
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 {
 	struct mlx5_wq_ll *wq = &rq->wq;
 
-	if (unlikely(RQ_CANNOT_POST(rq)))
+	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
 		return false;
 
+	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
+		return true;
+
 	while (!mlx5_wq_ll_is_full(wq)) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 		int err;
-- 
2.13.0
