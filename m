From: Nelson Chang <nelson.chang@mediatek.com>
Subject: [PATCH net-next v2 1/3] net: ethernet: mediatek: add HW LRO functions of PDMA RX rings
Date: Wed, 14 Sep 2016 13:58:57 +0800
Message-ID: <1473832739-4983-2-git-send-email-nelson.chang@mediatek.com>
References: <1473832739-4983-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>,
        Nelson Chang <nelson.chang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:23234 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755852AbcINF7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:59:23 -0400
In-Reply-To: <1473832739-4983-1-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The codes add the large receive offload (LRO) functions by hardware as below:
1) PDMA has total four RX rings that one is the normal ring, and others can
   be configured as LRO rings.
2) Only TCP/IP RX flows can be offloaded. The hardware can set four IP
   addresses at most, if the destination IP of the RX flow matches one of
   them, it has the chance to be offloaded.
3) There three RX flows can be offloaded at most, and one flow is mapped to
   one RX ring.
4) If there are more than three candidate RX flows, the hardware can
   choose three of them by throughput comparison results.

Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 215 +++++++++++++++++++++++++---
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  75 +++++++++-
 2 files changed, 265 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6e01f1f..ed35e0f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -810,11 +810,51 @@ drop:
 	return NETDEV_TX_OK;
 }
 
+static struct mtk_rx_ring *mtk_get_rx_ring(struct mtk_eth *eth)
+{
+	int i;
+	struct mtk_rx_ring *ring;
+	int idx;
+
+	if (!eth->hwlro)
+		return &eth->rx_ring[0];
+
+	for (i = 0; i < MTK_MAX_RX_RING_NUM; i++) {
+		ring = &eth->rx_ring[i];
+		idx = NEXT_RX_DESP_IDX(ring->calc_idx, ring->dma_size);
+		if (ring->dma[idx].rxd2 & RX_DMA_DONE) {
+			ring->calc_idx_update = true;
+			return ring;
+		}
+	}
+
+	return NULL;
+}
+
+static void mtk_update_rx_cpu_idx(struct mtk_eth *eth)
+{
+	struct mtk_rx_ring *ring;
+	int i;
+
+	if (!eth->hwlro) {
+		ring = &eth->rx_ring[0];
+		mtk_w32(eth, ring->calc_idx, ring->crx_idx_reg);
+	} else {
+		for (i = 0; i < MTK_MAX_RX_RING_NUM; i++) {
+			ring = &eth->rx_ring[i];
+			if (ring->calc_idx_update) {
+				ring->calc_idx_update = false;
+				mtk_w32(eth, ring->calc_idx, ring->crx_idx_reg);
+			}
+		}
+	}
+}
+
 static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		       struct mtk_eth *eth)
 {
-	struct mtk_rx_ring *ring = &eth->rx_ring;
-	int idx = ring->calc_idx;
+	struct mtk_rx_ring *ring;
+	int idx;
 	struct sk_buff *skb;
 	u8 *data, *new_data;
 	struct mtk_rx_dma *rxd, trxd;
@@ -826,7 +866,11 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		dma_addr_t dma_addr;
 		int mac = 0;
 
-		idx = NEXT_RX_DESP_IDX(idx);
+		ring = mtk_get_rx_ring(eth);
+		if (unlikely(!ring))
+			goto rx_done;
+
+		idx = NEXT_RX_DESP_IDX(ring->calc_idx, ring->dma_size);
 		rxd = &ring->dma[idx];
 		data = ring->data[idx];
 
@@ -894,12 +938,13 @@ release_desc:
 		done++;
 	}
 
+rx_done:
 	if (done) {
 		/* make sure that all changes to the dma ring are flushed before
 		 * we continue
 		 */
 		wmb();
-		mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
+		mtk_update_rx_cpu_idx(eth);
 	}
 
 	return done;
@@ -1122,32 +1167,41 @@ static void mtk_tx_clean(struct mtk_eth *eth)
 	}
 }
 
-static int mtk_rx_alloc(struct mtk_eth *eth)
+static int mtk_rx_alloc(struct mtk_eth *eth, int ring_no, int rx_flag)
 {
-	struct mtk_rx_ring *ring = &eth->rx_ring;
+	struct mtk_rx_ring *ring = &eth->rx_ring[ring_no];
+	int rx_data_len, rx_dma_size;
 	int i;
 
-	ring->frag_size = mtk_max_frag_size(ETH_DATA_LEN);
+	if (rx_flag == MTK_RX_FLAGS_HWLRO) {
+		rx_data_len = MTK_MAX_LRO_RX_LENGTH;
+		rx_dma_size = MTK_HW_LRO_DMA_SIZE;
+	} else {
+		rx_data_len = ETH_DATA_LEN;
+		rx_dma_size = MTK_DMA_SIZE;
+	}
+
+	ring->frag_size = mtk_max_frag_size(rx_data_len);
 	ring->buf_size = mtk_max_buf_size(ring->frag_size);
-	ring->data = kcalloc(MTK_DMA_SIZE, sizeof(*ring->data),
+	ring->data = kcalloc(rx_dma_size, sizeof(*ring->data),
 			     GFP_KERNEL);
 	if (!ring->data)
 		return -ENOMEM;
 
-	for (i = 0; i < MTK_DMA_SIZE; i++) {
+	for (i = 0; i < rx_dma_size; i++) {
 		ring->data[i] = netdev_alloc_frag(ring->frag_size);
 		if (!ring->data[i])
 			return -ENOMEM;
 	}
 
 	ring->dma = dma_alloc_coherent(eth->dev,
-				       MTK_DMA_SIZE * sizeof(*ring->dma),
+				       rx_dma_size * sizeof(*ring->dma),
 				       &ring->phys,
 				       GFP_ATOMIC | __GFP_ZERO);
 	if (!ring->dma)
 		return -ENOMEM;
 
-	for (i = 0; i < MTK_DMA_SIZE; i++) {
+	for (i = 0; i < rx_dma_size; i++) {
 		dma_addr_t dma_addr = dma_map_single(eth->dev,
 				ring->data[i] + NET_SKB_PAD,
 				ring->buf_size,
@@ -1158,27 +1212,30 @@ static int mtk_rx_alloc(struct mtk_eth *eth)
 
 		ring->dma[i].rxd2 = RX_DMA_PLEN0(ring->buf_size);
 	}
-	ring->calc_idx = MTK_DMA_SIZE - 1;
+	ring->dma_size = rx_dma_size;
+	ring->calc_idx_update = false;
+	ring->calc_idx = rx_dma_size - 1;
+	ring->crx_idx_reg = MTK_PRX_CRX_IDX_CFG(ring_no);
 	/* make sure that all changes to the dma ring are flushed before we
 	 * continue
 	 */
 	wmb();
 
-	mtk_w32(eth, eth->rx_ring.phys, MTK_PRX_BASE_PTR0);
-	mtk_w32(eth, MTK_DMA_SIZE, MTK_PRX_MAX_CNT0);
-	mtk_w32(eth, eth->rx_ring.calc_idx, MTK_PRX_CRX_IDX0);
-	mtk_w32(eth, MTK_PST_DRX_IDX0, MTK_PDMA_RST_IDX);
+	mtk_w32(eth, ring->phys, MTK_PRX_BASE_PTR_CFG(ring_no));
+	mtk_w32(eth, rx_dma_size, MTK_PRX_MAX_CNT_CFG(ring_no));
+	mtk_w32(eth, ring->calc_idx, ring->crx_idx_reg);
+	mtk_w32(eth, MTK_PST_DRX_IDX_CFG(ring_no), MTK_PDMA_RST_IDX);
 
 	return 0;
 }
 
-static void mtk_rx_clean(struct mtk_eth *eth)
+static void mtk_rx_clean(struct mtk_eth *eth, int ring_no)
 {
-	struct mtk_rx_ring *ring = &eth->rx_ring;
+	struct mtk_rx_ring *ring = &eth->rx_ring[ring_no];
 	int i;
 
 	if (ring->data && ring->dma) {
-		for (i = 0; i < MTK_DMA_SIZE; i++) {
+		for (i = 0; i < ring->dma_size; i++) {
 			if (!ring->data[i])
 				continue;
 			if (!ring->dma[i].rxd1)
@@ -1195,13 +1252,98 @@ static void mtk_rx_clean(struct mtk_eth *eth)
 
 	if (ring->dma) {
 		dma_free_coherent(eth->dev,
-				  MTK_DMA_SIZE * sizeof(*ring->dma),
+				  ring->dma_size * sizeof(*ring->dma),
 				  ring->dma,
 				  ring->phys);
 		ring->dma = NULL;
 	}
 }
 
+static int mtk_hwlro_rx_init(struct mtk_eth *eth)
+{
+	int i;
+	u32 ring_ctrl_dw1 = 0, ring_ctrl_dw2 = 0, ring_ctrl_dw3 = 0;
+	u32 lro_ctrl_dw0 = 0, lro_ctrl_dw3 = 0;
+
+	/* set LRO rings to auto-learn modes */
+	ring_ctrl_dw2 |= MTK_RING_AUTO_LERAN_MODE;
+
+	/* validate LRO ring */
+	ring_ctrl_dw2 |= MTK_RING_VLD;
+
+	/* set AGE timer (unit: 20us) */
+	ring_ctrl_dw2 |= MTK_RING_AGE_TIME_H;
+	ring_ctrl_dw1 |= MTK_RING_AGE_TIME_L;
+
+	/* set max AGG timer (unit: 20us) */
+	ring_ctrl_dw2 |= MTK_RING_MAX_AGG_TIME;
+
+	/* set max LRO AGG count */
+	ring_ctrl_dw2 |= MTK_RING_MAX_AGG_CNT_L;
+	ring_ctrl_dw3 |= MTK_RING_MAX_AGG_CNT_H;
+
+	for (i = 1; i < MTK_MAX_RX_RING_NUM; i++) {
+		mtk_w32(eth, ring_ctrl_dw1, MTK_LRO_CTRL_DW1_CFG(i));
+		mtk_w32(eth, ring_ctrl_dw2, MTK_LRO_CTRL_DW2_CFG(i));
+		mtk_w32(eth, ring_ctrl_dw3, MTK_LRO_CTRL_DW3_CFG(i));
+	}
+
+	/* IPv4 checksum update enable */
+	lro_ctrl_dw0 |= MTK_L3_CKS_UPD_EN;
+
+	/* switch priority comparison to packet count mode */
+	lro_ctrl_dw0 |= MTK_LRO_ALT_PKT_CNT_MODE;
+
+	/* bandwidth threshold setting */
+	mtk_w32(eth, MTK_HW_LRO_BW_THRE, MTK_PDMA_LRO_CTRL_DW2);
+
+	/* auto-learn score delta setting */
+	mtk_w32(eth, MTK_HW_LRO_REPLACE_DELTA, MTK_PDMA_LRO_ALT_SCORE_DELTA);
+
+	/* set refresh timer for altering flows to 1 sec. (unit: 20us) */
+	mtk_w32(eth, (MTK_HW_LRO_TIMER_UNIT << 16) | MTK_HW_LRO_REFRESH_TIME,
+		MTK_PDMA_LRO_ALT_REFRESH_TIMER);
+
+	/* set HW LRO mode & the max aggregation count for rx packets */
+	lro_ctrl_dw3 |= MTK_ADMA_MODE | (MTK_HW_LRO_MAX_AGG_CNT & 0xff);
+
+	/* the minimal remaining room of SDL0 in RXD for lro aggregation */
+	lro_ctrl_dw3 |= MTK_LRO_MIN_RXD_SDL;
+
+	/* enable HW LRO */
+	lro_ctrl_dw0 |= MTK_LRO_EN;
+
+	mtk_w32(eth, lro_ctrl_dw3, MTK_PDMA_LRO_CTRL_DW3);
+	mtk_w32(eth, lro_ctrl_dw0, MTK_PDMA_LRO_CTRL_DW0);
+
+	return 0;
+}
+
+static void mtk_hwlro_rx_uninit(struct mtk_eth *eth)
+{
+	int i;
+	u32 val;
+
+	/* relinquish lro rings, flush aggregated packets */
+	mtk_w32(eth, MTK_LRO_RING_RELINQUISH_REQ, MTK_PDMA_LRO_CTRL_DW0);
+
+	/* wait for relinquishments done */
+	for (i = 0; i < 10; i++) {
+		val = mtk_r32(eth, MTK_PDMA_LRO_CTRL_DW0);
+		if (val & MTK_LRO_RING_RELINQUISH_DONE) {
+			msleep(20);
+			continue;
+		}
+	}
+
+	/* invalidate lro rings */
+	for (i = 1; i < MTK_MAX_RX_RING_NUM; i++)
+		mtk_w32(eth, 0, MTK_LRO_CTRL_DW2_CFG(i));
+
+	/* disable HW LRO */
+	mtk_w32(eth, 0, MTK_PDMA_LRO_CTRL_DW0);
+}
+
 /* wait for DMA to finish whatever it is doing before we start using it again */
 static int mtk_dma_busy_wait(struct mtk_eth *eth)
 {
@@ -1222,6 +1364,7 @@ static int mtk_dma_busy_wait(struct mtk_eth *eth)
 static int mtk_dma_init(struct mtk_eth *eth)
 {
 	int err;
+	u32 i;
 
 	if (mtk_dma_busy_wait(eth))
 		return -EBUSY;
@@ -1237,10 +1380,21 @@ static int mtk_dma_init(struct mtk_eth *eth)
 	if (err)
 		return err;
 
-	err = mtk_rx_alloc(eth);
+	err = mtk_rx_alloc(eth, 0, MTK_RX_FLAGS_NORMAL);
 	if (err)
 		return err;
 
+	if (eth->hwlro) {
+		for (i = 1; i < MTK_MAX_RX_RING_NUM; i++) {
+			err = mtk_rx_alloc(eth, i, MTK_RX_FLAGS_HWLRO);
+			if (err)
+				return err;
+		}
+		err = mtk_hwlro_rx_init(eth);
+		if (err)
+			return err;
+	}
+
 	/* Enable random early drop and set drop threshold automatically */
 	mtk_w32(eth, FC_THRES_DROP_MODE | FC_THRES_DROP_EN | FC_THRES_MIN,
 		MTK_QDMA_FC_THRES);
@@ -1265,7 +1419,14 @@ static void mtk_dma_free(struct mtk_eth *eth)
 		eth->phy_scratch_ring = 0;
 	}
 	mtk_tx_clean(eth);
-	mtk_rx_clean(eth);
+	mtk_rx_clean(eth, 0);
+
+	if (eth->hwlro) {
+		mtk_hwlro_rx_uninit(eth);
+		for (i = 1; i < MTK_MAX_RX_RING_NUM; i++)
+			mtk_rx_clean(eth, i);
+	}
+
 	kfree(eth->scratch_head);
 }
 
@@ -1765,6 +1926,9 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	mac->hw = eth;
 	mac->of_node = np;
 
+	memset(mac->hwlro_ip, 0, sizeof(mac->hwlro_ip));
+	mac->hwlro_ip_cnt = 0;
+
 	mac->hw_stats = devm_kzalloc(eth->dev,
 				     sizeof(*mac->hw_stats),
 				     GFP_KERNEL);
@@ -1781,6 +1945,11 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	eth->netdev[id]->watchdog_timeo = 5 * HZ;
 	eth->netdev[id]->netdev_ops = &mtk_netdev_ops;
 	eth->netdev[id]->base_addr = (unsigned long)eth->base;
+
+	eth->netdev[id]->hw_features = MTK_HW_FEATURES;
+	if (eth->hwlro)
+		eth->netdev[id]->hw_features |= NETIF_F_LRO;
+
 	eth->netdev[id]->vlan_features = MTK_HW_FEATURES &
 		~(NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
 	eth->netdev[id]->features |= MTK_HW_FEATURES;
@@ -1848,6 +2017,8 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->rstc);
 	}
 
+	eth->hwlro = of_property_read_bool(pdev->dev.of_node, "mediatek,hwlro");
+
 	for (i = 0; i < 3; i++) {
 		eth->irq[i] = platform_get_irq(pdev, i);
 		if (eth->irq[i] < 0) {
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 0b984dc..d91848b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -39,7 +39,21 @@
 				 NETIF_F_SG | NETIF_F_TSO | \
 				 NETIF_F_TSO6 | \
 				 NETIF_F_IPV6_CSUM)
-#define NEXT_RX_DESP_IDX(X)	(((X) + 1) & (MTK_DMA_SIZE - 1))
+#define NEXT_RX_DESP_IDX(X, Y)	(((X) + 1) & ((Y) - 1))
+
+#define MTK_MAX_RX_RING_NUM	4
+#define MTK_HW_LRO_DMA_SIZE	8
+
+#define	MTK_MAX_LRO_RX_LENGTH		(4096 * 3)
+#define	MTK_MAX_LRO_IP_CNT		2
+#define	MTK_HW_LRO_TIMER_UNIT		1	/* 20 us */
+#define	MTK_HW_LRO_REFRESH_TIME		50000	/* 1 sec. */
+#define	MTK_HW_LRO_AGG_TIME		10	/* 200us */
+#define	MTK_HW_LRO_AGE_TIME		50	/* 1ms */
+#define	MTK_HW_LRO_MAX_AGG_CNT		64
+#define	MTK_HW_LRO_BW_THRE		3000
+#define	MTK_HW_LRO_REPLACE_DELTA	1000
+#define	MTK_HW_LRO_SDL_REMAIN_ROOM	1522
 
 /* Frame Engine Global Reset Register */
 #define MTK_RST_GL		0x04
@@ -50,6 +64,9 @@
 #define MTK_GDM1_AF		BIT(28)
 #define MTK_GDM2_AF		BIT(29)
 
+/* PDMA HW LRO Alter Flow Timer Register */
+#define MTK_PDMA_LRO_ALT_REFRESH_TIMER	0x1c
+
 /* Frame Engine Interrupt Grouping Register */
 #define MTK_FE_INT_GRP		0x20
 
@@ -70,12 +87,29 @@
 
 /* PDMA RX Base Pointer Register */
 #define MTK_PRX_BASE_PTR0	0x900
+#define MTK_PRX_BASE_PTR_CFG(x)	(MTK_PRX_BASE_PTR0 + (x * 0x10))
 
 /* PDMA RX Maximum Count Register */
 #define MTK_PRX_MAX_CNT0	0x904
+#define MTK_PRX_MAX_CNT_CFG(x)	(MTK_PRX_MAX_CNT0 + (x * 0x10))
 
 /* PDMA RX CPU Pointer Register */
 #define MTK_PRX_CRX_IDX0	0x908
+#define MTK_PRX_CRX_IDX_CFG(x)	(MTK_PRX_CRX_IDX0 + (x * 0x10))
+
+/* PDMA HW LRO Control Registers */
+#define MTK_PDMA_LRO_CTRL_DW0	0x980
+#define MTK_LRO_EN			BIT(0)
+#define MTK_L3_CKS_UPD_EN		BIT(7)
+#define MTK_LRO_ALT_PKT_CNT_MODE	BIT(21)
+#define MTK_LRO_RING_RELINQUISH_REQ	(0x3 << 26)
+#define MTK_LRO_RING_RELINQUISH_DONE	(0x3 << 29)
+
+#define MTK_PDMA_LRO_CTRL_DW1	0x984
+#define MTK_PDMA_LRO_CTRL_DW2	0x988
+#define MTK_PDMA_LRO_CTRL_DW3	0x98c
+#define MTK_ADMA_MODE		BIT(15)
+#define MTK_LRO_MIN_RXD_SDL	(MTK_HW_LRO_SDL_REMAIN_ROOM << 16)
 
 /* PDMA Global Configuration Register */
 #define MTK_PDMA_GLO_CFG	0xa04
@@ -84,6 +118,7 @@
 /* PDMA Reset Index Register */
 #define MTK_PDMA_RST_IDX	0xa08
 #define MTK_PST_DRX_IDX0	BIT(16)
+#define MTK_PST_DRX_IDX_CFG(x)	(MTK_PST_DRX_IDX0 << (x))
 
 /* PDMA Delay Interrupt Register */
 #define MTK_PDMA_DELAY_INT	0xa0c
@@ -94,10 +129,33 @@
 /* PDMA Interrupt Mask Register */
 #define MTK_PDMA_INT_MASK	0xa28
 
+/* PDMA HW LRO Alter Flow Delta Register */
+#define MTK_PDMA_LRO_ALT_SCORE_DELTA	0xa4c
+
 /* PDMA Interrupt grouping registers */
 #define MTK_PDMA_INT_GRP1	0xa50
 #define MTK_PDMA_INT_GRP2	0xa54
 
+/* PDMA HW LRO IP Setting Registers */
+#define MTK_LRO_RX_RING0_DIP_DW0	0xb04
+#define MTK_LRO_DIP_DW0_CFG(x)		(MTK_LRO_RX_RING0_DIP_DW0 + (x * 0x40))
+#define MTK_RING_MYIP_VLD		BIT(9)
+
+/* PDMA HW LRO Ring Control Registers */
+#define MTK_LRO_RX_RING0_CTRL_DW1	0xb28
+#define MTK_LRO_RX_RING0_CTRL_DW2	0xb2c
+#define MTK_LRO_RX_RING0_CTRL_DW3	0xb30
+#define MTK_LRO_CTRL_DW1_CFG(x)		(MTK_LRO_RX_RING0_CTRL_DW1 + (x * 0x40))
+#define MTK_LRO_CTRL_DW2_CFG(x)		(MTK_LRO_RX_RING0_CTRL_DW2 + (x * 0x40))
+#define MTK_LRO_CTRL_DW3_CFG(x)		(MTK_LRO_RX_RING0_CTRL_DW3 + (x * 0x40))
+#define MTK_RING_AGE_TIME_L		((MTK_HW_LRO_AGE_TIME & 0x3ff) << 22)
+#define MTK_RING_AGE_TIME_H		((MTK_HW_LRO_AGE_TIME >> 10) & 0x3f)
+#define MTK_RING_AUTO_LERAN_MODE	(3 << 6)
+#define MTK_RING_VLD			BIT(8)
+#define MTK_RING_MAX_AGG_TIME		((MTK_HW_LRO_AGG_TIME & 0xffff) << 10)
+#define MTK_RING_MAX_AGG_CNT_L		((MTK_HW_LRO_MAX_AGG_CNT & 0x3f) << 26)
+#define MTK_RING_MAX_AGG_CNT_H		((MTK_HW_LRO_MAX_AGG_CNT >> 6) & 0x3)
+
 /* QDMA TX Queue Configuration Registers */
 #define MTK_QTX_CFG(x)		(0x1800 + (x * 0x10))
 #define QDMA_RES_THRES		4
@@ -132,7 +190,6 @@
 
 /* QDMA Reset Index Register */
 #define MTK_QDMA_RST_IDX	0x1A08
-#define MTK_PST_DRX_IDX0	BIT(16)
 
 /* QDMA Delay Interrupt Register */
 #define MTK_QDMA_DELAY_INT	0x1A0C
@@ -367,6 +424,12 @@ struct mtk_tx_ring {
 	atomic_t free_count;
 };
 
+/* PDMA rx ring mode */
+enum mtk_rx_flags {
+	MTK_RX_FLAGS_NORMAL = 0,
+	MTK_RX_FLAGS_HWLRO,
+};
+
 /* struct mtk_rx_ring -	This struct holds info describing a RX ring
  * @dma:		The descriptor ring
  * @data:		The memory pointed at by the ring
@@ -381,7 +444,10 @@ struct mtk_rx_ring {
 	dma_addr_t phys;
 	u16 frag_size;
 	u16 buf_size;
+	u16 dma_size;
+	bool calc_idx_update;
 	u16 calc_idx;
+	u32 crx_idx_reg;
 };
 
 /* currently no SoC has more than 2 macs */
@@ -429,9 +495,10 @@ struct mtk_eth {
 	unsigned long			sysclk;
 	struct regmap			*ethsys;
 	struct regmap			*pctl;
+	bool				hwlro;
 	atomic_t			dma_refcnt;
 	struct mtk_tx_ring		tx_ring;
-	struct mtk_rx_ring		rx_ring;
+	struct mtk_rx_ring		rx_ring[MTK_MAX_RX_RING_NUM];
 	struct napi_struct		tx_napi;
 	struct napi_struct		rx_napi;
 	struct mtk_tx_dma		*scratch_ring;
@@ -457,6 +524,8 @@ struct mtk_mac {
 	struct mtk_eth			*hw;
 	struct mtk_hw_stats		*hw_stats;
 	struct phy_device		*phy_dev;
+	__be32				hwlro_ip[MTK_MAX_LRO_IP_CNT];
+	int				hwlro_ip_cnt;
 };
 
 /* the struct describing the SoC. these are declared in the soc_xyz.c files */
-- 
1.9.1
