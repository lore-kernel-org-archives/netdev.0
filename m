From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/16] net/mlx5: Make get_cqe routine not ethernet-specific
Date: Tue, 27 Jun 2017 17:28:45 +0300
Message-ID: <20170627142856.9448-6-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50482 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752660AbdF0OaK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:10 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Move mlx5e_get_cqe routine to wq.h and rename it to
mlx5_cqwq_get_cqe.

This allows it to be used by other CQ users outside of the
ethernet driver code.

A later patch in this patchset will make use of it from
FPGA code for the FPGA high-speed connection.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 19 +------------------
 drivers/net/ethernet/mellanox/mlx5/core/wq.h      | 17 +++++++++++++++++
 5 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index eef0a50e2388..f93f44d1d1cf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -833,7 +833,6 @@ void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix);
 void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix);
 void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq);
 void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi);
-struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_rx_am(struct mlx5e_rq *rq);
 void mlx5e_rx_am_work(struct work_struct *work);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 5f3c138c948d..574a96279340 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -996,7 +996,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
 
 	for (; work_done < budget; work_done++) {
-		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
+		struct mlx5_cqe64 *cqe = mlx5_cqwq_get_cqe(&cq->wq);
 
 		if (!cqe)
 			break;
@@ -1050,7 +1050,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 		u16 wqe_counter;
 		bool last_wqe;
 
-		cqe = mlx5e_get_cqe(cq);
+		cqe = mlx5_cqwq_get_cqe(&cq->wq);
 		if (!cqe)
 			break;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 0433d69429f3..ccec3b00e17c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -409,7 +409,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 		u16 wqe_counter;
 		bool last_wqe;
 
-		cqe = mlx5e_get_cqe(cq);
+		cqe = mlx5_cqwq_get_cqe(&cq->wq);
 		if (!cqe)
 			break;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 5ca6714e3e02..92db28a9ed43 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -32,23 +32,6 @@
 
 #include "en.h"
 
-struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
-{
-	struct mlx5_cqwq *wq = &cq->wq;
-	u32 ci = mlx5_cqwq_get_ci(wq);
-	struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
-	u8 cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
-	u8 sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
-
-	if (cqe_ownership_bit != sw_ownership_val)
-		return NULL;
-
-	/* ensure cqe content is read after cqe ownership bit */
-	dma_rmb();
-
-	return cqe;
-}
-
 static inline void mlx5e_poll_ico_single_cqe(struct mlx5e_cq *cq,
 					     struct mlx5e_icosq *sq,
 					     struct mlx5_cqe64 *cqe,
@@ -89,7 +72,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return;
 
-	cqe = mlx5e_get_cqe(cq);
+	cqe = mlx5_cqwq_get_cqe(&cq->wq);
 	if (likely(!cqe))
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
index d8afed898c31..9ded5d40ce6b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
@@ -34,6 +34,7 @@
 #define __MLX5_WQ_H__
 
 #include <linux/mlx5/mlx5_ifc.h>
+#include <linux/mlx5/cq.h>
 
 struct mlx5_wq_param {
 	int		linear;
@@ -146,6 +147,22 @@ static inline void mlx5_cqwq_update_db_record(struct mlx5_cqwq *wq)
 	*wq->db = cpu_to_be32(wq->cc & 0xffffff);
 }
 
+static inline struct mlx5_cqe64 *mlx5_cqwq_get_cqe(struct mlx5_cqwq *wq)
+{
+	u32 ci = mlx5_cqwq_get_ci(wq);
+	struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
+	u8 cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
+	u8 sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
+
+	if (cqe_ownership_bit != sw_ownership_val)
+		return NULL;
+
+	/* ensure cqe content is read after cqe ownership bit */
+	dma_rmb();
+
+	return cqe;
+}
+
 static inline int mlx5_wq_ll_is_full(struct mlx5_wq_ll *wq)
 {
 	return wq->cur_sz == wq->sz_m1;
-- 
2.11.0
