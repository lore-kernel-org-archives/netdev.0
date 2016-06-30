From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 09/13] net/mlx5e: Handle RQ flush in error cases
Date: Thu, 30 Jun 2016 17:34:46 +0300
Message-ID: <1467297290-11443-10-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37702 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752392AbcF3OhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:22 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Add a timeout to avoid an infinite loop waiting for RQ's to flush. This
occurs during AER/EEH and will also happen if the device stops posting
completions due to internal error or reset, or if moving the RQ to the
error state fails. Also cleanup posted receive resources when closing
the RQ.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  7 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 16 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 41 +++++++++++++++++++++++
 3 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 244aced..b429591 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -191,6 +191,7 @@ struct mlx5e_tstamp {
 enum {
 	MLX5E_RQ_STATE_POST_WQES_ENABLE,
 	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
+	MLX5E_RQ_STATE_FLUSH_TIMEOUT,
 };
 
 struct mlx5e_cq {
@@ -220,6 +221,8 @@ typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq *rq,
 typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
 				  u16 ix);
 
+typedef void (*mlx5e_fp_dealloc_wqe)(struct mlx5e_rq *rq, u16 ix);
+
 struct mlx5e_dma_info {
 	struct page	*page;
 	dma_addr_t	addr;
@@ -241,6 +244,7 @@ struct mlx5e_rq {
 	struct mlx5e_cq        cq;
 	mlx5e_fp_handle_rx_cqe handle_rx_cqe;
 	mlx5e_fp_alloc_wqe     alloc_wqe;
+	mlx5e_fp_dealloc_wqe   dealloc_wqe;
 
 	unsigned long          state;
 	int                    ix;
@@ -592,12 +596,15 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 void mlx5e_free_tx_descs(struct mlx5e_sq *sq);
+void mlx5e_free_rx_descs(struct mlx5e_rq *rq);
 
 void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
 int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
 int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
+void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix);
+void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix);
 void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq);
 void mlx5e_complete_rx_linear_mpwqe(struct mlx5e_rq *rq,
 				    struct mlx5_cqe64 *cqe,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 38c1286..103feab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -332,6 +332,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		}
 		rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
+		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
 		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
 		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
@@ -347,6 +348,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		}
 		rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
 		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
+		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
 
 		rq->wqe_sz = (priv->params.lro_en) ?
 				priv->params.lro_wqe_sz :
@@ -552,17 +554,25 @@ err_destroy_rq:
 
 static void mlx5e_close_rq(struct mlx5e_rq *rq)
 {
+	int tout = 0;
+	int err;
+
 	clear_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
 
-	mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RDY, MLX5_RQC_STATE_ERR);
-	while (!mlx5_wq_ll_is_empty(&rq->wq))
-		msleep(20);
+	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RDY, MLX5_RQC_STATE_ERR);
+	while (!mlx5_wq_ll_is_empty(&rq->wq) && !err &&
+	       tout++ < MLX5_EN_QP_FLUSH_MAX_ITER)
+		msleep(MLX5_EN_QP_FLUSH_MSLEEP_QUANT);
+
+	if (err || tout == MLX5_EN_QP_FLUSH_MAX_ITER)
+		set_bit(MLX5E_RQ_STATE_FLUSH_TIMEOUT, &rq->state);
 
 	/* avoid destroying rq before mlx5e_poll_rx_cq() is done with it */
 	napi_synchronize(&rq->channel->napi);
 
 	mlx5e_disable_rq(rq);
+	mlx5e_free_rx_descs(rq);
 	mlx5e_destroy_rq(rq);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 022acc2..9f2a16a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -212,6 +212,20 @@ err_free_skb:
 	return -ENOMEM;
 }
 
+void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix)
+{
+	struct sk_buff *skb = rq->skb[ix];
+
+	if (skb) {
+		rq->skb[ix] = NULL;
+		dma_unmap_single(rq->pdev,
+				 *((dma_addr_t *)skb->cb),
+				 rq->wqe_sz,
+				 DMA_FROM_DEVICE);
+		dev_kfree_skb(skb);
+	}
+}
+
 static inline int mlx5e_mpwqe_strides_per_page(struct mlx5e_rq *rq)
 {
 	return rq->mpwqe_num_strides >> MLX5_MPWRQ_WQE_PAGE_ORDER;
@@ -574,6 +588,30 @@ int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	return 0;
 }
 
+void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
+{
+	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+
+	wi->free_wqe(rq, wi);
+}
+
+void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
+{
+	struct mlx5_wq_ll *wq = &rq->wq;
+	struct mlx5e_rx_wqe *wqe;
+	__be16 wqe_ix_be;
+	u16 wqe_ix;
+
+	while (!mlx5_wq_ll_is_empty(wq)) {
+		wqe_ix_be = *wq->tail_next;
+		wqe_ix    = be16_to_cpu(wqe_ix_be);
+		wqe       = mlx5_wq_ll_get_wqe(&rq->wq, wqe_ix);
+		rq->dealloc_wqe(rq, wqe_ix);
+		mlx5_wq_ll_pop(&rq->wq, wqe_ix_be,
+			       &wqe->next.next_wqe_index);
+	}
+}
+
 #define RQ_CANNOT_POST(rq) \
 		(!test_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state) || \
 		 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
@@ -878,6 +916,9 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	int work_done = 0;
 
+	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH_TIMEOUT, &rq->state)))
+		return 0;
+
 	if (cq->decmprs_left)
 		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
 
-- 
2.8.0
