From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/15] net/mlx5e: Optimize poll ICOSQ completion queue
Date: Sun, 30 Apr 2017 16:20:12 +0300
Message-ID: <20170430132016.27012-12-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46796 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756819AbdD3NUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:33 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

UMR operations are more frequent and important.
Check them first, and add a compiler branch predictor hint.

According to current design, ICOSQ CQ can contain at most one
pending CQE per napi. Poll function is optimized accordingly.

Performance:
Single-stream packet-rate tested with pktgen.
Packets are dropped in tc level to zoom into driver data-path.
Larger gain is expected for larger packet sizes, as BW is higher
and UMR posts are more frequent.

---------------------------------------------
packet size | before    | after     | gain  |
64B         | 4,092,370 | 4,113,306 |  0.5% |
1024B       | 3,421,435 | 3,633,819 |  6.2% |

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 62 ++++++++++++-----------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 43729ec35dfc..491e83d09b58 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -49,10 +49,40 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 	return cqe;
 }
 
+static inline void mlx5e_poll_ico_single_cqe(struct mlx5e_cq *cq,
+					     struct mlx5e_icosq *sq,
+					     struct mlx5_cqe64 *cqe,
+					     u16 *sqcc)
+{
+	struct mlx5_wq_cyc *wq = &sq->wq;
+	u16 ci = be16_to_cpu(cqe->wqe_counter) & wq->sz_m1;
+	struct mlx5e_sq_wqe_info *icowi = &sq->db.ico_wqe[ci];
+	struct mlx5e_rq *rq = &sq->channel->rq;
+
+	prefetch(rq);
+	mlx5_cqwq_pop(&cq->wq);
+	*sqcc += icowi->num_wqebbs;
+
+	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_REQ)) {
+		WARN_ONCE(true, "mlx5e: Bad OP in ICOSQ CQE: 0x%x\n",
+			  cqe->op_own);
+		return;
+	}
+
+	if (likely(icowi->opcode == MLX5_OPCODE_UMR)) {
+		mlx5e_post_rx_mpwqe(rq);
+		return;
+	}
+
+	if (unlikely(icowi->opcode != MLX5_OPCODE_NOP))
+		WARN_ONCE(true,
+			  "mlx5e: Bad OPCODE in ICOSQ WQE info: 0x%x\n",
+			  icowi->opcode);
+}
+
 static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 {
 	struct mlx5e_icosq *sq = container_of(cq, struct mlx5e_icosq, cq);
-	struct mlx5_wq_cyc *wq;
 	struct mlx5_cqe64 *cqe;
 	u16 sqcc;
 
@@ -63,39 +93,13 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	if (likely(!cqe))
 		return;
 
-	wq = &sq->wq;
-
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
 	 * otherwise a cq overrun may occur
 	 */
 	sqcc = sq->cc;
 
-	do {
-		u16 ci = be16_to_cpu(cqe->wqe_counter) & wq->sz_m1;
-		struct mlx5e_sq_wqe_info *icowi = &sq->db.ico_wqe[ci];
-
-		mlx5_cqwq_pop(&cq->wq);
-		sqcc += icowi->num_wqebbs;
-
-		if (unlikely((cqe->op_own >> 4) != MLX5_CQE_REQ)) {
-			WARN_ONCE(true, "mlx5e: Bad OP in ICOSQ CQE: 0x%x\n",
-				  cqe->op_own);
-			break;
-		}
-
-		switch (icowi->opcode) {
-		case MLX5_OPCODE_NOP:
-			break;
-		case MLX5_OPCODE_UMR:
-			mlx5e_post_rx_mpwqe(&sq->channel->rq);
-			break;
-		default:
-			WARN_ONCE(true,
-				  "mlx5e: Bad OPCODE in ICOSQ WQE info: 0x%x\n",
-				  icowi->opcode);
-		}
-
-	} while ((cqe = mlx5e_get_cqe(cq)));
+	/* by design, there's only a single cqe */
+	mlx5e_poll_ico_single_cqe(cq, sq, cqe, &sqcc);
 
 	mlx5_cqwq_update_db_record(&cq->wq);
 
-- 
2.11.0
