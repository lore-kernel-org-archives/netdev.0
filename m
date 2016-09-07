From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 02/11] net/mlx5e: Introduce API for RX mapped pages
Date: Wed,  7 Sep 2016 15:42:23 +0300
Message-ID: <1473252152-11379-3-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45158 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756591AbcIGMmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:52 -0400
In-Reply-To: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Manage the allocation and deallocation of mapped RX pages only
through dedicated API functions.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 46 +++++++++++++++----------
 1 file changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 8ad4d32..c1cb510 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -305,26 +305,32 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
 }
 
-static inline int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
-					   struct mlx5e_mpw_info *wi,
-					   int i)
+static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
+					  struct mlx5e_dma_info *dma_info)
 {
 	struct page *page = dev_alloc_page();
+
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	wi->umr.dma_info[i].page = page;
-	wi->umr.dma_info[i].addr = dma_map_page(rq->pdev, page, 0, PAGE_SIZE,
-						PCI_DMA_FROMDEVICE);
-	if (unlikely(dma_mapping_error(rq->pdev, wi->umr.dma_info[i].addr))) {
+	dma_info->page = page;
+	dma_info->addr = dma_map_page(rq->pdev, page, 0, PAGE_SIZE,
+				      DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
 		put_page(page);
 		return -ENOMEM;
 	}
-	wi->umr.mtt[i] = cpu_to_be64(wi->umr.dma_info[i].addr | MLX5_EN_WR);
 
 	return 0;
 }
 
+static inline void mlx5e_page_release(struct mlx5e_rq *rq,
+				      struct mlx5e_dma_info *dma_info)
+{
+	dma_unmap_page(rq->pdev, dma_info->addr, PAGE_SIZE, DMA_FROM_DEVICE);
+	put_page(dma_info->page);
+}
+
 static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 				    struct mlx5e_rx_wqe *wqe,
 				    u16 ix)
@@ -336,10 +342,13 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 	int i;
 
 	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
-		err = mlx5e_alloc_and_map_page(rq, wi, i);
+		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
+
+		err = mlx5e_page_alloc_mapped(rq, dma_info);
 		if (unlikely(err))
 			goto err_unmap;
-		page_ref_add(wi->umr.dma_info[i].page, pg_strides);
+		wi->umr.mtt[i] = cpu_to_be64(dma_info->addr | MLX5_EN_WR);
+		page_ref_add(dma_info->page, pg_strides);
 		wi->skbs_frags[i] = 0;
 	}
 
@@ -350,10 +359,10 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 
 err_unmap:
 	while (--i >= 0) {
-		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
-		page_ref_sub(wi->umr.dma_info[i].page, pg_strides);
-		put_page(wi->umr.dma_info[i].page);
+		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
+
+		page_ref_sub(dma_info->page, pg_strides);
+		mlx5e_page_release(rq, dma_info);
 	}
 
 	return err;
@@ -365,11 +374,10 @@ void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi)
 	int i;
 
 	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
-		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
-		page_ref_sub(wi->umr.dma_info[i].page,
-			     pg_strides - wi->skbs_frags[i]);
-		put_page(wi->umr.dma_info[i].page);
+		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
+
+		page_ref_sub(dma_info->page, pg_strides - wi->skbs_frags[i]);
+		mlx5e_page_release(rq, dma_info);
 	}
 }
 
-- 
2.7.4
