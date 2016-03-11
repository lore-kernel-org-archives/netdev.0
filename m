From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/13] net/mlx5e: Use function pointers for RX data path handling
Date: Fri, 11 Mar 2016 15:39:46 +0200
Message-ID: <1457703594-9482-6-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33235 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753255AbcCKNlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:41:03 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In preparation for Striding RQ feature, which will need its own
RX handlers.
This patch does not change any functionality.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   33 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   74 +++++++++++----------
 3 files changed, 62 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f4bf470..c70ec84 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -72,6 +72,17 @@
 #define MLX5E_SQ_BF_BUDGET             16
 
 #define MLX5E_NUM_MAIN_GROUPS 9
+#define MLX5E_NET_IP_ALIGN 2
+
+struct mlx5e_tx_wqe {
+	struct mlx5_wqe_ctrl_seg ctrl;
+	struct mlx5_wqe_eth_seg  eth;
+};
+
+struct mlx5e_rx_wqe {
+	struct mlx5_wqe_srq_next_seg  next;
+	struct mlx5_wqe_data_seg      data;
+};
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
@@ -357,6 +368,12 @@ struct mlx5e_cq {
 	struct mlx5_wq_ctrl        wq_ctrl;
 } ____cacheline_aligned_in_smp;
 
+struct mlx5e_rq;
+typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq *rq,
+				       struct mlx5_cqe64 *cqe);
+typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
+				  u16 ix);
+
 struct mlx5e_rq {
 	/* data path */
 	struct mlx5_wq_ll      wq;
@@ -368,6 +385,8 @@ struct mlx5e_rq {
 	struct mlx5e_tstamp   *tstamp;
 	struct mlx5e_rq_stats  stats;
 	struct mlx5e_cq        cq;
+	mlx5e_fp_handle_rx_cqe handle_rx_cqe;
+	mlx5e_fp_alloc_wqe     alloc_wqe;
 
 	unsigned long          state;
 	int                    ix;
@@ -588,18 +607,6 @@ struct mlx5e_priv {
 	u16 q_counter;
 };
 
-#define MLX5E_NET_IP_ALIGN 2
-
-struct mlx5e_tx_wqe {
-	struct mlx5_wqe_ctrl_seg ctrl;
-	struct mlx5_wqe_eth_seg  eth;
-};
-
-struct mlx5e_rx_wqe {
-	struct mlx5_wqe_srq_next_seg  next;
-	struct mlx5_wqe_data_seg      data;
-};
-
 enum mlx5e_link_mode {
 	MLX5E_1000BASE_CX_SGMII	 = 0,
 	MLX5E_1000BASE_KX	 = 1,
@@ -642,7 +649,9 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
+void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
+int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9b58ef6..23ba12c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -357,6 +357,8 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 			cpu_to_be32(byte_count | MLX5_HW_START_PADDING);
 	}
 
+	rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
+	rq->alloc_wqe = mlx5e_alloc_rx_wqe;
 	rq->pdev    = c->pdev;
 	rq->netdev  = c->netdev;
 	rq->tstamp  = &priv->tstamp;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 58d4e2f..d7ccced 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -42,8 +42,7 @@ static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 	return tstamp->hwtstamp_config.rx_filter == HWTSTAMP_FILTER_ALL;
 }
 
-static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
-				     struct mlx5e_rx_wqe *wqe, u16 ix)
+int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 {
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
@@ -87,7 +86,7 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 	while (!mlx5_wq_ll_is_full(wq)) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
-		if (unlikely(mlx5e_alloc_rx_wqe(rq, wqe, wq->head)))
+		if (unlikely(rq->alloc_wqe(rq, wqe, wq->head)))
 			break;
 
 		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
@@ -229,50 +228,55 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	skb->mark = be32_to_cpu(cqe->sop_drop_qpn) & MLX5E_TC_FLOW_ID_MASK;
 }
 
+void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+{
+	struct mlx5e_rx_wqe *wqe;
+	struct sk_buff *skb;
+	__be16 wqe_counter_be;
+	u16 wqe_counter;
+
+	wqe_counter_be = cqe->wqe_counter;
+	wqe_counter    = be16_to_cpu(wqe_counter_be);
+	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
+	skb            = rq->skb[wqe_counter];
+	prefetch(skb->data);
+	rq->skb[wqe_counter] = NULL;
+
+	dma_unmap_single(rq->pdev,
+			 *((dma_addr_t *)skb->cb),
+			 rq->wqe_sz,
+			 DMA_FROM_DEVICE);
+
+	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
+		rq->stats.wqe_err++;
+		dev_kfree_skb(skb);
+		goto wq_ll_pop;
+	}
+
+	mlx5e_build_rx_skb(cqe, rq, skb);
+	rq->stats.packets++;
+	rq->stats.bytes += be32_to_cpu(cqe->byte_cnt);
+	napi_gro_receive(rq->cq.napi, skb);
+
+wq_ll_pop:
+	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
+		       &wqe->next.next_wqe_index);
+}
+
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	int work_done;
 
 	for (work_done = 0; work_done < budget; work_done++) {
-		struct mlx5e_rx_wqe *wqe;
-		struct mlx5_cqe64 *cqe;
-		struct sk_buff *skb;
-		__be16 wqe_counter_be;
-		u16 wqe_counter;
+		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
 
-		cqe = mlx5e_get_cqe(cq);
 		if (!cqe)
 			break;
 
 		mlx5_cqwq_pop(&cq->wq);
 
-		wqe_counter_be = cqe->wqe_counter;
-		wqe_counter    = be16_to_cpu(wqe_counter_be);
-		wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
-		skb            = rq->skb[wqe_counter];
-		prefetch(skb->data);
-		rq->skb[wqe_counter] = NULL;
-
-		dma_unmap_single(rq->pdev,
-				 *((dma_addr_t *)skb->cb),
-				 rq->wqe_sz,
-				 DMA_FROM_DEVICE);
-
-		if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
-			rq->stats.wqe_err++;
-			dev_kfree_skb(skb);
-			goto wq_ll_pop;
-		}
-
-		mlx5e_build_rx_skb(cqe, rq, skb);
-		rq->stats.packets++;
-		rq->stats.bytes += be32_to_cpu(cqe->byte_cnt);
-		napi_gro_receive(cq->napi, skb);
-
-wq_ll_pop:
-		mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
-			       &wqe->next.next_wqe_index);
+		rq->handle_rx_cqe(rq, cqe);
 	}
 
 	mlx5_cqwq_update_db_record(&cq->wq);
-- 
1.7.1
