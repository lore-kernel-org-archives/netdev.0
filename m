From: John Crispin <john@phrozen.org>
Subject: [PATCH 2/2] net-next: mediatek: bring up QDMA RX ring 0
Date: Wed,  9 Aug 2017 12:09:32 +0200
Message-ID: <20170809100932.10539-3-john@phrozen.org>
References: <20170809100932.10539-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809100932.10539-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is in preparation for adding HW flow and QoS offloading. For
those features to work, the driver needs to bring up the first QDMA RX
ring. This ring is used by the PPE offloading HW.

Signed-off-by: John Crisp in <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 36 +++++++++++++++++++++--------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  3 +++
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ff97f2939209..4c85b4713c0d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1285,9 +1285,19 @@ static void mtk_tx_clean(struct mtk_eth *eth)
 
 static int mtk_rx_alloc(struct mtk_eth *eth, int ring_no, int rx_flag)
 {
-	struct mtk_rx_ring *ring = &eth->rx_ring[ring_no];
+	struct mtk_rx_ring *ring;
 	int rx_data_len, rx_dma_size;
 	int i;
+	u32 offset = 0;
+
+	if (rx_flag == MTK_RX_FLAGS_QDMA) {
+		if (ring_no)
+			return -EINVAL;
+		ring = &eth->rx_ring_qdma;
+		offset = 0x1000;
+	} else {
+		ring = &eth->rx_ring[ring_no];
+	}
 
 	if (rx_flag == MTK_RX_FLAGS_HWLRO) {
 		rx_data_len = MTK_MAX_LRO_RX_LENGTH;
@@ -1337,17 +1347,16 @@ static int mtk_rx_alloc(struct mtk_eth *eth, int ring_no, int rx_flag)
 	 */
 	wmb();
 
-	mtk_w32(eth, ring->phys, MTK_PRX_BASE_PTR_CFG(ring_no));
-	mtk_w32(eth, rx_dma_size, MTK_PRX_MAX_CNT_CFG(ring_no));
-	mtk_w32(eth, ring->calc_idx, ring->crx_idx_reg);
-	mtk_w32(eth, MTK_PST_DRX_IDX_CFG(ring_no), MTK_PDMA_RST_IDX);
+	mtk_w32(eth, ring->phys, MTK_PRX_BASE_PTR_CFG(ring_no) + offset);
+	mtk_w32(eth, rx_dma_size, MTK_PRX_MAX_CNT_CFG(ring_no) + offset);
+	mtk_w32(eth, ring->calc_idx, ring->crx_idx_reg + offset);
+	mtk_w32(eth, MTK_PST_DRX_IDX_CFG(ring_no), MTK_PDMA_RST_IDX + offset);
 
 	return 0;
 }
 
-static void mtk_rx_clean(struct mtk_eth *eth, int ring_no)
+static void mtk_rx_clean(struct mtk_eth *eth, struct mtk_rx_ring *ring)
 {
-	struct mtk_rx_ring *ring = &eth->rx_ring[ring_no];
 	int i;
 
 	if (ring->data && ring->dma) {
@@ -1673,6 +1682,10 @@ static int mtk_dma_init(struct mtk_eth *eth)
 	if (err)
 		return err;
 
+	err = mtk_rx_alloc(eth, 0, MTK_RX_FLAGS_QDMA);
+	if (err)
+		return err;
+
 	err = mtk_rx_alloc(eth, 0, MTK_RX_FLAGS_NORMAL);
 	if (err)
 		return err;
@@ -1712,12 +1725,13 @@ static void mtk_dma_free(struct mtk_eth *eth)
 		eth->phy_scratch_ring = 0;
 	}
 	mtk_tx_clean(eth);
-	mtk_rx_clean(eth, 0);
+	mtk_rx_clean(eth, &eth->rx_ring[0]);
+	mtk_rx_clean(eth, &eth->rx_ring_qdma);
 
 	if (eth->hwlro) {
 		mtk_hwlro_rx_uninit(eth);
 		for (i = 1; i < MTK_MAX_RX_RING_NUM; i++)
-			mtk_rx_clean(eth, i);
+			mtk_rx_clean(eth, &eth->rx_ring[i]);
 	}
 
 	kfree(eth->scratch_head);
@@ -1784,7 +1798,9 @@ static int mtk_start_dma(struct mtk_eth *eth)
 
 	mtk_w32(eth,
 		MTK_TX_WB_DDONE | MTK_TX_DMA_EN |
-		MTK_DMA_SIZE_16DWORDS | MTK_NDP_CO_PRO,
+		MTK_DMA_SIZE_16DWORDS | MTK_NDP_CO_PRO |
+		MTK_RX_DMA_EN | MTK_RX_2B_OFFSET |
+		MTK_RX_BT_32DWORDS,
 		MTK_QDMA_GLO_CFG);
 
 	mtk_w32(eth,
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 940517af8039..3d3c24a28112 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -532,6 +532,7 @@ struct mtk_tx_ring {
 enum mtk_rx_flags {
 	MTK_RX_FLAGS_NORMAL = 0,
 	MTK_RX_FLAGS_HWLRO,
+	MTK_RX_FLAGS_QDMA,
 };
 
 /* struct mtk_rx_ring -	This struct holds info describing a RX ring
@@ -601,6 +602,7 @@ struct mtk_soc_data {
  * @dma_refcnt:		track how many netdevs are using the DMA engine
  * @tx_ring:		Pointer to the memory holding info about the TX ring
  * @rx_ring:		Pointer to the memory holding info about the RX ring
+ * @rx_ring_qdma:	Pointer to the memory holding info about the QDMA RX ring
  * @tx_napi:		The TX NAPI struct
  * @rx_napi:		The RX NAPI struct
  * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
@@ -633,6 +635,7 @@ struct mtk_eth {
 	atomic_t			dma_refcnt;
 	struct mtk_tx_ring		tx_ring;
 	struct mtk_rx_ring		rx_ring[MTK_MAX_RX_RING_NUM];
+	struct mtk_rx_ring		rx_ring_qdma;
 	struct napi_struct		tx_napi;
 	struct napi_struct		rx_napi;
 	struct mtk_tx_dma		*scratch_ring;
-- 
2.11.0
