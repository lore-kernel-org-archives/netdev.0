From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx5e: Add HW cacheline start padding
Date: Thu, 11 Jun 2015 14:47:28 +0300
Message-ID: <1434023253-24362-3-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47261 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752817AbbFKLr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:47:59 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Enable HW cacheline start padding and align RX WQE size to cacheline
while considering HW start padding. Also, fix dma_unmap call to use
the correct SKB data buffer size.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    5 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   10 +++++-----
 include/linux/mlx5/device.h                       |    4 ++++
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f9fdeac..95772dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -309,12 +309,15 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 
 	rq->wqe_sz = (priv->params.lro_en) ? priv->params.lro_wqe_sz :
 					     MLX5E_SW2HW_MTU(priv->netdev->mtu);
+	rq->wqe_sz = SKB_DATA_ALIGN(rq->wqe_sz + MLX5E_NET_IP_ALIGN);
 
 	for (i = 0; i < wq_sz; i++) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(&rq->wq, i);
+		u32 byte_count = rq->wqe_sz - MLX5E_NET_IP_ALIGN;
 
 		wqe->data.lkey       = c->mkey_be;
-		wqe->data.byte_count = cpu_to_be32(rq->wqe_sz);
+		wqe->data.byte_count =
+			cpu_to_be32(byte_count | MLX5_HW_START_PADDING);
 	}
 
 	rq->pdev    = c->pdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index ce1317c..06e7c74 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -45,18 +45,18 @@ static inline int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq,
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	skb_reserve(skb, MLX5E_NET_IP_ALIGN);
-
 	dma_addr = dma_map_single(rq->pdev,
 				  /* hw start padding */
-				  skb->data - MLX5E_NET_IP_ALIGN,
-				  /* hw   end padding */
+				  skb->data,
+				  /* hw end padding */
 				  rq->wqe_sz,
 				  DMA_FROM_DEVICE);
 
 	if (unlikely(dma_mapping_error(rq->pdev, dma_addr)))
 		goto err_free_skb;
 
+	skb_reserve(skb, MLX5E_NET_IP_ALIGN);
+
 	*((dma_addr_t *)skb->cb) = dma_addr;
 	wqe->data.addr = cpu_to_be64(dma_addr + MLX5E_NET_IP_ALIGN);
 
@@ -217,7 +217,7 @@ bool mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 
 		dma_unmap_single(rq->pdev,
 				 *((dma_addr_t *)skb->cb),
-				 skb_end_offset(skb),
+				 rq->wqe_sz,
 				 DMA_FROM_DEVICE);
 
 		if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index b2c4350..b943cd9 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -132,6 +132,10 @@ enum {
 };
 
 enum {
+	MLX5_HW_START_PADDING = MLX5_INLINE_SEG,
+};
+
+enum {
 	MLX5_MIN_PKEY_TABLE_SIZE = 128,
 	MLX5_MAX_LOG_PKEY_TABLE  = 5,
 };
-- 
1.7.1
