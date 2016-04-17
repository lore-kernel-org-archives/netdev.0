From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 08/11] net/mlx5e: Use napi_alloc_skb for RX SKB allocations
Date: Mon, 18 Apr 2016 00:32:02 +0300
Message-ID: <1460928725-18741-9-git-send-email-saeedm@mellanox.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37036 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750855AbcDQVcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2016 17:32:54 -0400
In-Reply-To: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Instead of netdev_alloc_skb, we use the napi_alloc_skb function
which is designated to allocate skbuff's for RX in a
channel-specific NAPI instance, and implies the IP packet alignment.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   12 +++++-------
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1d4e8fe..6127bc7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -91,7 +91,6 @@
 #define MLX5E_SQ_BF_BUDGET             16
 
 #define MLX5E_NUM_MAIN_GROUPS 9
-#define MLX5E_NET_IP_ALIGN 2
 
 static inline u16 mlx5_min_rx_wqes(int wq_type, u32 wq_size)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 942829e..9b17bc0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -373,8 +373,8 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		rq->wqe_sz = (priv->params.lro_en) ?
 				priv->params.lro_wqe_sz :
 				MLX5E_SW2HW_MTU(priv->netdev->mtu);
-		rq->wqe_sz = SKB_DATA_ALIGN(rq->wqe_sz + MLX5E_NET_IP_ALIGN);
-		byte_count = rq->wqe_sz - MLX5E_NET_IP_ALIGN;
+		rq->wqe_sz = SKB_DATA_ALIGN(rq->wqe_sz);
+		byte_count = rq->wqe_sz;
 		byte_count |= MLX5_HW_START_PADDING;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 22c2812..ea90e6f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -47,7 +47,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	struct sk_buff *skb;
 	dma_addr_t dma_addr;
 
-	skb = netdev_alloc_skb(rq->netdev, rq->wqe_sz);
+	skb = napi_alloc_skb(rq->cq.napi, rq->wqe_sz);
 	if (unlikely(!skb))
 		return -ENOMEM;
 
@@ -61,10 +61,8 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	if (unlikely(dma_mapping_error(rq->pdev, dma_addr)))
 		goto err_free_skb;
 
-	skb_reserve(skb, MLX5E_NET_IP_ALIGN);
-
 	*((dma_addr_t *)skb->cb) = dma_addr;
-	wqe->data.addr = cpu_to_be64(dma_addr + MLX5E_NET_IP_ALIGN);
+	wqe->data.addr = cpu_to_be64(dma_addr);
 	wqe->data.lkey = rq->mkey_be;
 
 	rq->skb[ix] = skb;
@@ -646,9 +644,9 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto mpwrq_cqe_out;
 	}
 
-	skb = netdev_alloc_skb(rq->netdev,
-			       ALIGN(MLX5_MPWRQ_SMALL_PACKET_THRESHOLD,
-				     sizeof(long)));
+	skb = napi_alloc_skb(rq->cq.napi,
+			     ALIGN(MLX5_MPWRQ_SMALL_PACKET_THRESHOLD,
+				   sizeof(long)));
 	if (unlikely(!skb))
 		goto mpwrq_cqe_out;
 
-- 
1.7.1
