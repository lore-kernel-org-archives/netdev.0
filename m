From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/17] net/mlx5e: Reorganize struct mlx5e_rq
Date: Sun,  3 Sep 2017 07:21:01 +0300
Message-ID: <20170903042117.28923-2-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59964 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750827AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Bring fast-path fields together, and combine RX WQE mutual
exclusive fields into a union.

Page-reuse and XDP are mutually exclusive and cannot be used at
the same time.
Use a union to combine their footprints.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 16 +++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 13 ++++++-------
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 6c2abeccfa5a..d964db286c95 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -527,20 +527,24 @@ struct mlx5e_rq {
 		struct {
 			struct mlx5e_wqe_frag_info *frag_info;
 			u32 frag_sz;	/* max possible skb frag_sz */
-			bool page_reuse;
-			bool xdp_xmit;
+			union {
+				bool page_reuse;
+				bool xdp_xmit;
+			};
 		} wqe;
 		struct {
 			struct mlx5e_mpw_info *info;
 			void                  *mtt_no_align;
+			u16                    stride_sz;
+			u16                    num_strides;
 		} mpwqe;
 	};
 	struct {
-		u8             page_order;
 		u32            wqe_sz;    /* wqe data buffer size */
+		u16            headroom;
+		u8             page_order;
 		u8             map_dir;   /* dma map direction */
 	} buff;
-	__be32                 mkey_be;
 
 	struct device         *pdev;
 	struct net_device     *netdev;
@@ -555,7 +559,6 @@ struct mlx5e_rq {
 
 	unsigned long          state;
 	int                    ix;
-	u16                    rx_headroom;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
 
@@ -565,9 +568,8 @@ struct mlx5e_rq {
 
 	/* control */
 	struct mlx5_wq_ctrl    wq_ctrl;
+	__be32                 mkey_be;
 	u8                     wq_type;
-	u32                    mpwqe_stride_sz;
-	u32                    mpwqe_num_strides;
 	u32                    rqn;
 	struct mlx5e_channel  *channel;
 	struct mlx5_core_dev  *mdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 85841e24c65b..94761d0e1b33 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -593,7 +593,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	}
 
 	rq->buff.map_dir = rq->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
-	rq->rx_headroom = params->rq_headroom;
+	rq->buff.headroom = params->rq_headroom;
 
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
@@ -615,10 +615,10 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			goto err_rq_wq_destroy;
 		}
 
-		rq->mpwqe_stride_sz = BIT(params->mpwqe_log_stride_sz);
-		rq->mpwqe_num_strides = BIT(params->mpwqe_log_num_strides);
+		rq->mpwqe.stride_sz = BIT(params->mpwqe_log_stride_sz);
+		rq->mpwqe.num_strides = BIT(params->mpwqe_log_num_strides);
 
-		rq->buff.wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
+		rq->buff.wqe_sz = rq->mpwqe.stride_sz * rq->mpwqe.num_strides;
 		byte_count = rq->buff.wqe_sz;
 
 		err = mlx5e_create_rq_umr_mkey(mdev, rq);
@@ -665,7 +665,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
-		rq->wqe.frag_sz = MLX5_SKB_FRAG_SZ(rq->rx_headroom + byte_count);
+		rq->wqe.frag_sz = MLX5_SKB_FRAG_SZ(rq->buff.headroom + byte_count);
 		npages = DIV_ROUND_UP(rq->wqe.frag_sz, PAGE_SIZE);
 		rq->buff.page_order = order_base_2(npages);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index be8197a75a63..1b50f1e7e48a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -263,8 +263,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 		wi->offset = 0;
 	}
 
-	wqe->data.addr = cpu_to_be64(wi->di.addr + wi->offset +
-				     rq->rx_headroom);
+	wqe->data.addr = cpu_to_be64(wi->di.addr + wi->offset + rq->buff.headroom);
 	return 0;
 }
 
@@ -296,7 +295,7 @@ void mlx5e_dealloc_rx_wqe(struct mlx5e_rq *rq, u16 ix)
 
 static inline int mlx5e_mpwqe_strides_per_page(struct mlx5e_rq *rq)
 {
-	return rq->mpwqe_num_strides >> MLX5_MPWRQ_WQE_PAGE_ORDER;
+	return rq->mpwqe.num_strides >> MLX5_MPWRQ_WQE_PAGE_ORDER;
 }
 
 static inline void mlx5e_add_skb_frag_mpwqe(struct mlx5e_rq *rq,
@@ -305,7 +304,7 @@ static inline void mlx5e_add_skb_frag_mpwqe(struct mlx5e_rq *rq,
 					    u32 page_idx, u32 frag_offset,
 					    u32 len)
 {
-	unsigned int truesize =	ALIGN(len, rq->mpwqe_stride_sz);
+	unsigned int truesize = ALIGN(len, rq->mpwqe.stride_sz);
 
 	dma_sync_single_for_cpu(rq->pdev,
 				wi->umr.dma_info[page_idx].addr + frag_offset,
@@ -776,9 +775,9 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 			     struct mlx5e_wqe_frag_info *wi, u32 cqe_bcnt)
 {
 	struct mlx5e_dma_info *di = &wi->di;
+	u16 rx_headroom = rq->buff.headroom;
 	struct sk_buff *skb;
 	void *va, *data;
-	u16 rx_headroom = rq->rx_headroom;
 	bool consumed;
 	u32 frag_size;
 
@@ -911,7 +910,7 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
 					   struct sk_buff *skb)
 {
 	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
-	u32 wqe_offset     = stride_ix * rq->mpwqe_stride_sz;
+	u32 wqe_offset     = stride_ix * rq->mpwqe.stride_sz;
 	u32 head_offset    = wqe_offset & (PAGE_SIZE - 1);
 	u32 page_idx       = wqe_offset >> PAGE_SHIFT;
 	u32 head_page_idx  = page_idx;
@@ -979,7 +978,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	napi_gro_receive(rq->cq.napi, skb);
 
 mpwrq_cqe_out:
-	if (likely(wi->consumed_strides < rq->mpwqe_num_strides))
+	if (likely(wi->consumed_strides < rq->mpwqe.num_strides))
 		return;
 
 	mlx5e_free_rx_mpwqe(rq, wi);
-- 
2.13.0
