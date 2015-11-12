From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/6] net/mlx5e: Use the right DMA free function on TX path
Date: Thu, 12 Nov 2015 19:35:28 +0200
Message-ID: <1447349730-19832-5-git-send-email-ogerlitz@mellanox.com>
References: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46736 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752983AbbKLRf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:58 -0500
In-Reply-To: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

On xmit path we use skb_frag_dma_map() which is using dma_map_page(),
while upon completion we dma-unmap the skb fragments using
dma_unmap_single() rather than dma_unmap_page().

To fix this, we now save the dma map type on xmit path and use this
info to call the right dma unmap method upon TX completion.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    | 10 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 65 +++++++++++++------------
 2 files changed, 43 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f2ae62d..22e72bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -334,9 +334,15 @@ struct mlx5e_tx_skb_cb {
 
 #define MLX5E_TX_SKB_CB(__skb) ((struct mlx5e_tx_skb_cb *)__skb->cb)
 
+enum mlx5e_dma_map_type {
+	MLX5E_DMA_MAP_SINGLE,
+	MLX5E_DMA_MAP_PAGE
+};
+
 struct mlx5e_sq_dma {
-	dma_addr_t addr;
-	u32        size;
+	dma_addr_t              addr;
+	u32                     size;
+	enum mlx5e_dma_map_type type;
 };
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index f687ebf..1341b1d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -61,39 +61,47 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 	}
 }
 
-static void mlx5e_dma_pop_last_pushed(struct mlx5e_sq *sq, dma_addr_t *addr,
-				      u32 *size)
+static inline void mlx5e_tx_dma_unmap(struct device *pdev,
+				      struct mlx5e_sq_dma *dma)
 {
-	sq->dma_fifo_pc--;
-	*addr = sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr;
-	*size = sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size;
-}
-
-static void mlx5e_dma_unmap_wqe_err(struct mlx5e_sq *sq, struct sk_buff *skb)
-{
-	dma_addr_t addr;
-	u32 size;
-	int i;
-
-	for (i = 0; i < MLX5E_TX_SKB_CB(skb)->num_dma; i++) {
-		mlx5e_dma_pop_last_pushed(sq, &addr, &size);
-		dma_unmap_single(sq->pdev, addr, size, DMA_TO_DEVICE);
+	switch (dma->type) {
+	case MLX5E_DMA_MAP_SINGLE:
+		dma_unmap_single(pdev, dma->addr, dma->size, DMA_TO_DEVICE);
+		break;
+	case MLX5E_DMA_MAP_PAGE:
+		dma_unmap_page(pdev, dma->addr, dma->size, DMA_TO_DEVICE);
+		break;
+	default:
+		WARN_ONCE(true, "mlx5e_tx_dma_unmap unknown DMA type!\n");
 	}
 }
 
-static inline void mlx5e_dma_push(struct mlx5e_sq *sq, dma_addr_t addr,
-				  u32 size)
+static inline void mlx5e_dma_push(struct mlx5e_sq *sq,
+				  dma_addr_t addr,
+				  u32 size,
+				  enum mlx5e_dma_map_type map_type)
 {
 	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].addr = addr;
 	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].size = size;
+	sq->dma_fifo[sq->dma_fifo_pc & sq->dma_fifo_mask].type = map_type;
 	sq->dma_fifo_pc++;
 }
 
-static inline void mlx5e_dma_get(struct mlx5e_sq *sq, u32 i, dma_addr_t *addr,
-				 u32 *size)
+static inline struct mlx5e_sq_dma *mlx5e_dma_get(struct mlx5e_sq *sq, u32 i)
+{
+	return &sq->dma_fifo[i & sq->dma_fifo_mask];
+}
+
+static void mlx5e_dma_unmap_wqe_err(struct mlx5e_sq *sq, struct sk_buff *skb)
 {
-	*addr = sq->dma_fifo[i & sq->dma_fifo_mask].addr;
-	*size = sq->dma_fifo[i & sq->dma_fifo_mask].size;
+	int i;
+
+	for (i = 0; i < MLX5E_TX_SKB_CB(skb)->num_dma; i++) {
+		struct mlx5e_sq_dma *last_pushed_dma =
+			mlx5e_dma_get(sq, --sq->dma_fifo_pc);
+
+		mlx5e_tx_dma_unmap(sq->pdev, last_pushed_dma);
+	}
 }
 
 u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
@@ -225,7 +233,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		dseg->lkey       = sq->mkey_be;
 		dseg->byte_count = cpu_to_be32(headlen);
 
-		mlx5e_dma_push(sq, dma_addr, headlen);
+		mlx5e_dma_push(sq, dma_addr, headlen, MLX5E_DMA_MAP_SINGLE);
 		MLX5E_TX_SKB_CB(skb)->num_dma++;
 
 		dseg++;
@@ -244,7 +252,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		dseg->lkey       = sq->mkey_be;
 		dseg->byte_count = cpu_to_be32(fsz);
 
-		mlx5e_dma_push(sq, dma_addr, fsz);
+		mlx5e_dma_push(sq, dma_addr, fsz, MLX5E_DMA_MAP_PAGE);
 		MLX5E_TX_SKB_CB(skb)->num_dma++;
 
 		dseg++;
@@ -360,13 +368,10 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq)
 			}
 
 			for (j = 0; j < MLX5E_TX_SKB_CB(skb)->num_dma; j++) {
-				dma_addr_t addr;
-				u32 size;
+				struct mlx5e_sq_dma *dma =
+					mlx5e_dma_get(sq, dma_fifo_cc++);
 
-				mlx5e_dma_get(sq, dma_fifo_cc, &addr, &size);
-				dma_fifo_cc++;
-				dma_unmap_single(sq->pdev, addr, size,
-						 DMA_TO_DEVICE);
+				mlx5e_tx_dma_unmap(sq->pdev, dma);
 			}
 
 			npkts++;
-- 
2.3.7
