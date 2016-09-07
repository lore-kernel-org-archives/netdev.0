From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 05/11] net/mlx5e: Union RQ RX info per RQ type
Date: Wed,  7 Sep 2016 15:42:26 +0300
Message-ID: <1473252152-11379-6-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45180 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756882AbcIGMmx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:53 -0400
In-Reply-To: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have two types of RX RQs, and they use two separate sets of
info arrays and structures in RX data path function.  Today those
structures are mutually exclusive per RQ type, hence one kind is
allocated on RQ creation according to the RQ type.

For better cache locality and to minimalize the
sizeof(struct mlx5e_rq), in this patch we define them as a union.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 14 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 32 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 10 +++----
 3 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a346112..7dfb34e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -305,9 +305,14 @@ struct mlx5e_rq {
 	/* data path */
 	struct mlx5_wq_ll      wq;
 
-	struct mlx5e_dma_info *dma_info;
-	struct mlx5e_mpw_info *wqe_info;
-	void                  *mtt_no_align;
+	union {
+		struct mlx5e_dma_info *dma_info;
+		struct {
+			struct mlx5e_mpw_info *info;
+			void                  *mtt_no_align;
+			u32                    mtt_offset;
+		} mpwqe;
+	};
 	struct {
 		u8             page_order;
 		u32            wqe_sz;    /* wqe data buffer size */
@@ -327,7 +332,6 @@ struct mlx5e_rq {
 
 	unsigned long          state;
 	int                    ix;
-	u32                    mpwqe_mtt_offset;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
 
@@ -804,7 +808,7 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
 
 static inline u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
 {
-	return rq->mpwqe_mtt_offset +
+	return rq->mpwqe.mtt_offset +
 		wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c9f1dea..9f0f5f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -317,7 +317,7 @@ static inline void mlx5e_build_umr_wqe(struct mlx5e_rq *rq, struct mlx5e_sq *sq,
 	struct mlx5_wqe_ctrl_seg      *cseg = &wqe->ctrl;
 	struct mlx5_wqe_umr_ctrl_seg *ucseg = &wqe->uctrl;
 	struct mlx5_wqe_data_seg      *dseg = &wqe->data;
-	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
 	u8 ds_cnt = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_DS);
 	u32 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq, ix);
 
@@ -345,21 +345,21 @@ static int mlx5e_rq_alloc_mpwqe_info(struct mlx5e_rq *rq,
 	int mtt_alloc = mtt_sz + MLX5_UMR_ALIGN - 1;
 	int i;
 
-	rq->wqe_info = kzalloc_node(wq_sz * sizeof(*rq->wqe_info),
-				    GFP_KERNEL, cpu_to_node(c->cpu));
-	if (!rq->wqe_info)
+	rq->mpwqe.info = kzalloc_node(wq_sz * sizeof(*rq->mpwqe.info),
+				      GFP_KERNEL, cpu_to_node(c->cpu));
+	if (!rq->mpwqe.info)
 		goto err_out;
 
 	/* We allocate more than mtt_sz as we will align the pointer */
-	rq->mtt_no_align = kzalloc_node(mtt_alloc * wq_sz, GFP_KERNEL,
+	rq->mpwqe.mtt_no_align = kzalloc_node(mtt_alloc * wq_sz, GFP_KERNEL,
 					cpu_to_node(c->cpu));
-	if (unlikely(!rq->mtt_no_align))
+	if (unlikely(!rq->mpwqe.mtt_no_align))
 		goto err_free_wqe_info;
 
 	for (i = 0; i < wq_sz; i++) {
-		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
+		struct mlx5e_mpw_info *wi = &rq->mpwqe.info[i];
 
-		wi->umr.mtt = PTR_ALIGN(rq->mtt_no_align + i * mtt_alloc,
+		wi->umr.mtt = PTR_ALIGN(rq->mpwqe.mtt_no_align + i * mtt_alloc,
 					MLX5_UMR_ALIGN);
 		wi->umr.mtt_addr = dma_map_single(c->pdev, wi->umr.mtt, mtt_sz,
 						  PCI_DMA_TODEVICE);
@@ -373,14 +373,14 @@ static int mlx5e_rq_alloc_mpwqe_info(struct mlx5e_rq *rq,
 
 err_unmap_mtts:
 	while (--i >= 0) {
-		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
+		struct mlx5e_mpw_info *wi = &rq->mpwqe.info[i];
 
 		dma_unmap_single(c->pdev, wi->umr.mtt_addr, mtt_sz,
 				 PCI_DMA_TODEVICE);
 	}
-	kfree(rq->mtt_no_align);
+	kfree(rq->mpwqe.mtt_no_align);
 err_free_wqe_info:
-	kfree(rq->wqe_info);
+	kfree(rq->mpwqe.info);
 
 err_out:
 	return -ENOMEM;
@@ -393,13 +393,13 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	int i;
 
 	for (i = 0; i < wq_sz; i++) {
-		struct mlx5e_mpw_info *wi = &rq->wqe_info[i];
+		struct mlx5e_mpw_info *wi = &rq->mpwqe.info[i];
 
 		dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz,
 				 PCI_DMA_TODEVICE);
 	}
-	kfree(rq->mtt_no_align);
-	kfree(rq->wqe_info);
+	kfree(rq->mpwqe.mtt_no_align);
+	kfree(rq->mpwqe.info);
 }
 
 static int mlx5e_create_rq(struct mlx5e_channel *c,
@@ -442,7 +442,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
-		rq->mpwqe_mtt_offset = c->ix *
+		rq->mpwqe.mtt_offset = c->ix *
 			MLX5E_REQUIRED_MTTS(1, BIT(priv->params.log_rq_size));
 
 		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
@@ -656,7 +656,7 @@ static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
 
 	/* UMR WQE (if in progress) is always at wq->head */
 	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
-		mlx5e_free_rx_mpwqe(rq, &rq->wqe_info[wq->head]);
+		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
 
 	while (!mlx5_wq_ll_is_empty(wq)) {
 		wqe_ix_be = *wq->tail_next;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 2f5bc6f..95f9b1e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -328,7 +328,7 @@ mlx5e_copy_skb_header_mpwqe(struct device *pdev,
 
 static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 {
-	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
 	struct mlx5e_sq *sq = &rq->channel->icosq;
 	struct mlx5_wq_cyc *wq = &sq->wq;
 	struct mlx5e_umr_wqe *wqe;
@@ -358,7 +358,7 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 				    struct mlx5e_rx_wqe *wqe,
 				    u16 ix)
 {
-	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
 	u64 dma_offset = (u64)mlx5e_get_wqe_mtt_offset(rq, ix) << PAGE_SHIFT;
 	int pg_strides = mlx5e_mpwqe_strides_per_page(rq);
 	int err;
@@ -412,7 +412,7 @@ void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
 	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
 
 	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state))) {
-		mlx5e_free_rx_mpwqe(rq, &rq->wqe_info[wq->head]);
+		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
 		return;
 	}
 
@@ -438,7 +438,7 @@ int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 
 void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
 {
-	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
 
 	mlx5e_free_rx_mpwqe(rq, wi);
 }
@@ -717,7 +717,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
 	u16 wqe_id         = be16_to_cpu(cqe->wqe_id);
-	struct mlx5e_mpw_info *wi = &rq->wqe_info[wqe_id];
+	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[wqe_id];
 	struct mlx5e_rx_wqe  *wqe = mlx5_wq_ll_get_wqe(&rq->wq, wqe_id);
 	struct sk_buff *skb;
 	u16 cqe_bcnt;
-- 
2.7.4
