From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next 2/2] net: mvneta: Use cacheable memory to store the rx buffer DMA address
Date: Fri, 17 Feb 2017 17:57:27 +0800
Message-ID: <20170217095727.2226-3-jszhang@marvell.com>
References: <20170217095727.2226-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217095727.2226-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In hot code path such as mvneta_rx_hwbm() and mvneta_rx_swbm, the
buf_phys_addr field of rx_dec is accessed. The rx_desc is allocated by
dma_alloc_coherent, it's uncacheable if the device isn't cache
coherent, reading from uncached memory is fairly slow. This patch uses
cacheable memory to store the rx buffer DMA address. We get the
following performance data on Marvell BG4CT Platforms (tested with
iperf):

before the patch:
recving 1GB in mvneta_rx_swbm() costs 149265960 ns

after the patch:
recving 1GB in mvneta_rx_swbm() costs 1421565640 ns

We saved 4.76% time.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/marvell/mvneta.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 06df72b8da85..e24c3028fe1d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -580,6 +580,9 @@ struct mvneta_rx_queue {
 	/* Virtual address of the RX buffer */
 	void  **buf_virt_addr;
 
+	/* DMA address of the RX buffer */
+	dma_addr_t *buf_dma_addr;
+
 	/* Virtual address of the RX DMA descriptors array */
 	struct mvneta_rx_desc *descs;
 
@@ -1617,6 +1620,7 @@ static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
 
 	rx_desc->buf_phys_addr = phys_addr;
 	i = rx_desc - rxq->descs;
+	rxq->buf_dma_addr[i] = phys_addr;
 	rxq->buf_virt_addr[i] = virt_addr;
 }
 
@@ -1900,22 +1904,22 @@ static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 		for (i = 0; i < rx_done; i++) {
 			struct mvneta_rx_desc *rx_desc =
 						  mvneta_rxq_next_desc_get(rxq);
+			int index = rx_desc - rxq->descs;
 			u8 pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_desc->status);
 			struct mvneta_bm_pool *bm_pool;
 
 			bm_pool = &pp->bm_priv->bm_pools[pool_id];
 			/* Return dropped buffer to the pool */
 			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
-					      rx_desc->buf_phys_addr);
+					      rxq->buf_dma_addr[index]);
 		}
 		return;
 	}
 
 	for (i = 0; i < rxq->size; i++) {
-		struct mvneta_rx_desc *rx_desc = rxq->descs + i;
 		void *data = rxq->buf_virt_addr[i];
 
-		dma_unmap_single(pp->dev->dev.parent, rx_desc->buf_phys_addr,
+		dma_unmap_single(pp->dev->dev.parent, rxq->buf_dma_addr[i],
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 		mvneta_frag_free(pp->frag_size, data);
 	}
@@ -1953,7 +1957,7 @@ static int mvneta_rx_swbm(struct mvneta_port *pp, int rx_todo,
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		index = rx_desc - rxq->descs;
 		data = rxq->buf_virt_addr[index];
-		phys_addr = rx_desc->buf_phys_addr;
+		phys_addr = rxq->buf_dma_addr[index];
 
 		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
@@ -2062,6 +2066,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 	/* Fairness NAPI loop */
 	while (rx_done < rx_todo) {
 		struct mvneta_rx_desc *rx_desc = mvneta_rxq_next_desc_get(rxq);
+		int index = rx_desc - rxq->descs;
 		struct mvneta_bm_pool *bm_pool = NULL;
 		struct sk_buff *skb;
 		unsigned char *data;
@@ -2074,7 +2079,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		rx_status = rx_desc->status;
 		rx_bytes = rx_desc->data_size - (ETH_FCS_LEN + MVNETA_MH_SIZE);
 		data = (u8 *)(uintptr_t)rx_desc->buf_cookie;
-		phys_addr = rx_desc->buf_phys_addr;
+		phys_addr = rxq->buf_dma_addr[index];
 		pool_id = MVNETA_RX_GET_BM_POOL_ID(rx_status);
 		bm_pool = &pp->bm_priv->bm_pools[pool_id];
 
@@ -2082,8 +2087,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
 err_drop_frame_ret_pool:
 			/* Return the buffer to the pool */
-			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
-					      rx_desc->buf_phys_addr);
+			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool, phys_addr);
 err_drop_frame:
 			dev->stats.rx_errors++;
 			mvneta_rx_error(pp, rx_desc);
@@ -2098,7 +2102,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 				goto err_drop_frame_ret_pool;
 
 			dma_sync_single_range_for_cpu(dev->dev.parent,
-			                              rx_desc->buf_phys_addr,
+			                              phys_addr,
 			                              MVNETA_MH_SIZE + NET_SKB_PAD,
 			                              rx_bytes,
 			                              DMA_FROM_DEVICE);
@@ -2114,8 +2118,7 @@ static int mvneta_rx_hwbm(struct mvneta_port *pp, int rx_todo,
 			rcvd_bytes += rx_bytes;
 
 			/* Return the buffer to the pool */
-			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool,
-					      rx_desc->buf_phys_addr);
+			mvneta_bm_pool_put_bp(pp->bm_priv, bm_pool, phys_addr);
 
 			/* leave the descriptor and buffer untouched */
 			continue;
@@ -4019,7 +4022,10 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		rxq->buf_virt_addr = devm_kmalloc(pp->dev->dev.parent,
 						  rxq->size * sizeof(void *),
 						  GFP_KERNEL);
-		if (!rxq->buf_virt_addr)
+		rxq->buf_dma_addr = devm_kmalloc(pp->dev->dev.parent,
+						 rxq->size * sizeof(dma_addr_t),
+						 GFP_KERNEL);
+		if (!rxq->buf_virt_addr || !rxq->buf_dma_addr)
 			return -ENOMEM;
 	}
 
-- 
2.11.0
