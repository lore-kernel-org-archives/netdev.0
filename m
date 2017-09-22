From: Matt Redfearn <matt.redfearn@imgtec.com>
Subject: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Fri, 22 Sep 2017 12:13:53 +0100
Message-ID: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matt Redfearn <matt.redfearn@imgtec.com>, <netdev@vger.kernel.org>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        <linux-kernel@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to Documentation/DMA-API.txt:
 Warnings:  Memory coherency operates at a granularity called the cache
 line width.  In order for memory mapped by this API to operate
 correctly, the mapped region must begin exactly on a cache line
 boundary and end exactly on one (to prevent two separately mapped
 regions from sharing a single cache line).  Since the cache line size
 may not be known at compile time, the API will not enforce this
 requirement.  Therefore, it is recommended that driver writers who
 don't take special care to determine the cache line size at run time
 only map virtual regions that begin and end on page boundaries (which
 are guaranteed also to be cache line boundaries).

On some systems where DMA is non-coherent and requires software
writeback / invalidate of the caches, we must ensure that
dma_(un)map_single is called with a cacheline aligned buffer and a
length of a whole number of cachelines.

To address the alignment requirements of DMA buffers, keep a separate
entry in stmmac_rx_queue for the aligned skbuff head. Use this for
dma_map_single, such that the address meets the cacheline alignment
requirents. Use skb_headroom() to convert between rx_skbuff_head, the
aligned head of the buffer, and the packet data, rx_skbuff_dma.

Tested on a Creator Ci40 with Pistachio SoC.

Signed-off-by: Matt Redfearn <matt.redfearn@imgtec.com>
---

 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 50 ++++++++++++++++-------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index a916e13624eb..dd26a724dee7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -67,6 +67,7 @@ struct stmmac_rx_queue {
 	struct dma_desc *dma_rx ____cacheline_aligned_in_smp;
 	struct sk_buff **rx_skbuff;
 	dma_addr_t *rx_skbuff_dma;
+	dma_addr_t *rx_skbuff_head;
 	unsigned int cur_rx;
 	unsigned int dirty_rx;
 	u32 rx_zeroc_thresh;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1763e48c84e2..da68eeff2a1c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1132,14 +1132,16 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 		return -ENOMEM;
 	}
 	rx_q->rx_skbuff[i] = skb;
-	rx_q->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
-						priv->dma_buf_sz,
-						DMA_FROM_DEVICE);
-	if (dma_mapping_error(priv->device, rx_q->rx_skbuff_dma[i])) {
+	rx_q->rx_skbuff_head[i] = dma_map_single(priv->device, skb->head,
+						 skb_headroom(skb) +
+						 priv->dma_buf_sz,
+						 DMA_FROM_DEVICE);
+	if (dma_mapping_error(priv->device, rx_q->rx_skbuff_head[i])) {
 		netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
+	rx_q->rx_skbuff_dma[i] = rx_q->rx_skbuff_head[i] + skb_headroom(skb);
 
 	if (priv->synopsys_id >= DWMAC_CORE_4_00)
 		p->des0 = cpu_to_le32(rx_q->rx_skbuff_dma[i]);
@@ -1164,7 +1166,8 @@ static void stmmac_free_rx_buffer(struct stmmac_priv *priv, u32 queue, int i)
 	struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
 
 	if (rx_q->rx_skbuff[i]) {
-		dma_unmap_single(priv->device, rx_q->rx_skbuff_dma[i],
+		dma_unmap_single(priv->device, rx_q->rx_skbuff_head[i],
+				 skb_headroom(rx_q->rx_skbuff[i]) +
 				 priv->dma_buf_sz, DMA_FROM_DEVICE);
 		dev_kfree_skb_any(rx_q->rx_skbuff[i]);
 	}
@@ -1438,6 +1441,7 @@ static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
 					  rx_q->dma_erx, rx_q->dma_rx_phy);
 
 		kfree(rx_q->rx_skbuff_dma);
+		kfree(rx_q->rx_skbuff_head);
 		kfree(rx_q->rx_skbuff);
 	}
 }
@@ -1500,6 +1504,12 @@ static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
 		if (!rx_q->rx_skbuff_dma)
 			goto err_dma;
 
+		rx_q->rx_skbuff_head = kmalloc_array(DMA_RX_SIZE,
+						     sizeof(dma_addr_t),
+						     GFP_KERNEL);
+		if (!rx_q->rx_skbuff_head)
+			goto err_dma;
+
 		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
 						sizeof(struct sk_buff *),
 						GFP_KERNEL);
@@ -3225,15 +3235,18 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv, u32 queue)
 			}
 
 			rx_q->rx_skbuff[entry] = skb;
-			rx_q->rx_skbuff_dma[entry] =
-			    dma_map_single(priv->device, skb->data, bfsize,
+			rx_q->rx_skbuff_head[entry] =
+			    dma_map_single(priv->device, skb->head,
+					   skb_headroom(skb) + bfsize,
 					   DMA_FROM_DEVICE);
 			if (dma_mapping_error(priv->device,
-					      rx_q->rx_skbuff_dma[entry])) {
+					      rx_q->rx_skbuff_head[entry])) {
 				netdev_err(priv->dev, "Rx DMA map failed\n");
 				dev_kfree_skb(skb);
 				break;
 			}
+			rx_q->rx_skbuff_dma[entry] = rx_q->rx_skbuff_head[entry]
+						     + skb_headroom(skb);
 
 			if (unlikely(priv->synopsys_id >= DWMAC_CORE_4_00)) {
 				p->des0 = cpu_to_le32(rx_q->rx_skbuff_dma[entry]);
@@ -3333,10 +3346,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 				 * them in stmmac_rx_refill() function so that
 				 * device can reuse it.
 				 */
+				int head = skb_headroom(rx_q->rx_skbuff[entry]);
+
 				rx_q->rx_skbuff[entry] = NULL;
 				dma_unmap_single(priv->device,
-						 rx_q->rx_skbuff_dma[entry],
-						 priv->dma_buf_sz,
+						 rx_q->rx_skbuff_head[entry],
+						 head + priv->dma_buf_sz,
 						 DMA_FROM_DEVICE);
 			}
 		} else {
@@ -3384,6 +3399,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 			if (unlikely(!priv->plat->has_gmac4 &&
 				     ((frame_len < priv->rx_copybreak) ||
 				     stmmac_rx_threshold_count(rx_q)))) {
+				int total_len;
+
 				skb = netdev_alloc_skb_ip_align(priv->dev,
 								frame_len);
 				if (unlikely(!skb)) {
@@ -3394,9 +3411,11 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 					break;
 				}
 
+				total_len = skb_headroom(skb) + frame_len;
+
 				dma_sync_single_for_cpu(priv->device,
-							rx_q->rx_skbuff_dma
-							[entry], frame_len,
+							rx_q->rx_skbuff_head
+							[entry], total_len,
 							DMA_FROM_DEVICE);
 				skb_copy_to_linear_data(skb,
 							rx_q->
@@ -3405,8 +3424,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 
 				skb_put(skb, frame_len);
 				dma_sync_single_for_device(priv->device,
-							   rx_q->rx_skbuff_dma
-							   [entry], frame_len,
+							   rx_q->rx_skbuff_head
+							   [entry], total_len,
 							   DMA_FROM_DEVICE);
 			} else {
 				skb = rx_q->rx_skbuff[entry];
@@ -3423,7 +3442,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit, u32 queue)
 
 				skb_put(skb, frame_len);
 				dma_unmap_single(priv->device,
-						 rx_q->rx_skbuff_dma[entry],
+						 rx_q->rx_skbuff_head[entry],
+						 skb_headroom(skb) +
 						 priv->dma_buf_sz,
 						 DMA_FROM_DEVICE);
 			}
-- 
2.7.4
