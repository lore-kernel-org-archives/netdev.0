From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/17] net/mlx5e: Replace multiplication by stride size with a shift
Date: Sun,  3 Sep 2017 07:21:02 +0300
Message-ID: <20170903042117.28923-3-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59978 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750858AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In RX data-path, use shift operations instead of a regular multiplication
by stride size, as it is a power of two.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d964db286c95..44bd8df905ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -535,8 +535,8 @@ struct mlx5e_rq {
 		struct {
 			struct mlx5e_mpw_info *info;
 			void                  *mtt_no_align;
-			u16                    stride_sz;
 			u16                    num_strides;
+			u8                     log_stride_sz;
 		} mpwqe;
 	};
 	struct {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 94761d0e1b33..7a25d952c922 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -615,10 +615,10 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			goto err_rq_wq_destroy;
 		}
 
-		rq->mpwqe.stride_sz = BIT(params->mpwqe_log_stride_sz);
+		rq->mpwqe.log_stride_sz = params->mpwqe_log_stride_sz;
 		rq->mpwqe.num_strides = BIT(params->mpwqe_log_num_strides);
 
-		rq->buff.wqe_sz = rq->mpwqe.stride_sz * rq->mpwqe.num_strides;
+		rq->buff.wqe_sz = rq->mpwqe.num_strides << rq->mpwqe.log_stride_sz;
 		byte_count = rq->buff.wqe_sz;
 
 		err = mlx5e_create_rq_umr_mkey(mdev, rq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 1b50f1e7e48a..aa5cc1590859 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -304,7 +304,7 @@ static inline void mlx5e_add_skb_frag_mpwqe(struct mlx5e_rq *rq,
 					    u32 page_idx, u32 frag_offset,
 					    u32 len)
 {
-	unsigned int truesize = ALIGN(len, rq->mpwqe.stride_sz);
+	unsigned int truesize = ALIGN(len, BIT(rq->mpwqe.log_stride_sz));
 
 	dma_sync_single_for_cpu(rq->pdev,
 				wi->umr.dma_info[page_idx].addr + frag_offset,
@@ -910,7 +910,7 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
 					   struct sk_buff *skb)
 {
 	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
-	u32 wqe_offset     = stride_ix * rq->mpwqe.stride_sz;
+	u32 wqe_offset     = stride_ix << rq->mpwqe.log_stride_sz;
 	u32 head_offset    = wqe_offset & (PAGE_SIZE - 1);
 	u32 page_idx       = wqe_offset >> PAGE_SHIFT;
 	u32 head_page_idx  = page_idx;
-- 
2.13.0
