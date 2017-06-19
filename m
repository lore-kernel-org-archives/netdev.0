From: John Crispin <john@phrozen.org>
Subject: [PATCH 3/4] net-next: mediatek: split IRQ register locking into TX and RX
Date: Mon, 19 Jun 2017 15:37:05 +0200
Message-ID: <20170619133706.3415-4-john@phrozen.org>
References: <20170619133706.3415-1-john@phrozen.org>
Cc: linux-mediatek@lists.infradead.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Sean Wang <sean.wang@mediatek.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57326 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750907AbdFSNhV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 09:37:21 -0400
In-Reply-To: <20170619133706.3415-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally the driver only utilised the new QDMA engine. The current code
still assumes this is the case when locking the IRQ mask register. Since
RX now runs on the old style PDMA engine we can add a second lock. This
patch reduces the IRQ latency as the TX and RX path no longer need to wait
on each other under heavy load.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 79 ++++++++++++++++++-----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  5 +-
 2 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 92be59a1e4e7..462d1e83e254 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -372,28 +372,48 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
 	mdiobus_unregister(eth->mii_bus);
 }
 
-static inline void mtk_irq_disable(struct mtk_eth *eth,
-				   unsigned reg, u32 mask)
+static inline void mtk_tx_irq_disable(struct mtk_eth *eth, u32 mask)
 {
 	unsigned long flags;
 	u32 val;
 
-	spin_lock_irqsave(&eth->irq_lock, flags);
-	val = mtk_r32(eth, reg);
-	mtk_w32(eth, val & ~mask, reg);
-	spin_unlock_irqrestore(&eth->irq_lock, flags);
+	spin_lock_irqsave(&eth->tx_irq_lock, flags);
+	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
+	mtk_w32(eth, val & ~mask, MTK_QDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->tx_irq_lock, flags);
 }
 
-static inline void mtk_irq_enable(struct mtk_eth *eth,
-				  unsigned reg, u32 mask)
+static inline void mtk_tx_irq_enable(struct mtk_eth *eth, u32 mask)
 {
 	unsigned long flags;
 	u32 val;
 
-	spin_lock_irqsave(&eth->irq_lock, flags);
-	val = mtk_r32(eth, reg);
-	mtk_w32(eth, val | mask, reg);
-	spin_unlock_irqrestore(&eth->irq_lock, flags);
+	spin_lock_irqsave(&eth->tx_irq_lock, flags);
+	val = mtk_r32(eth, MTK_QDMA_INT_MASK);
+	mtk_w32(eth, val | mask, MTK_QDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->tx_irq_lock, flags);
+}
+
+static inline void mtk_rx_irq_disable(struct mtk_eth *eth, u32 mask)
+{
+	unsigned long flags;
+	u32 val;
+
+	spin_lock_irqsave(&eth->rx_irq_lock, flags);
+	val = mtk_r32(eth, MTK_PDMA_INT_MASK);
+	mtk_w32(eth, val & ~mask, MTK_PDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->rx_irq_lock, flags);
+}
+
+static inline void mtk_rx_irq_enable(struct mtk_eth *eth, u32 mask)
+{
+	unsigned long flags;
+	u32 val;
+
+	spin_lock_irqsave(&eth->rx_irq_lock, flags);
+	val = mtk_r32(eth, MTK_PDMA_INT_MASK);
+	mtk_w32(eth, val | mask, MTK_PDMA_INT_MASK);
+	spin_unlock_irqrestore(&eth->rx_irq_lock, flags);
 }
 
 static int mtk_set_mac_address(struct net_device *dev, void *p)
@@ -1101,7 +1121,7 @@ static int mtk_napi_tx(struct napi_struct *napi, int budget)
 		return budget;
 
 	napi_complete(napi);
-	mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
+	mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
 
 	return tx_done;
 }
@@ -1135,7 +1155,7 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
 		goto poll_again;
 	}
 	napi_complete(napi);
-	mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+	mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
 
 	return rx_done + budget - remain_budget;
 }
@@ -1670,7 +1690,7 @@ static irqreturn_t mtk_handle_irq_rx(int irq, void *_eth)
 
 	if (likely(napi_schedule_prep(&eth->rx_napi))) {
 		__napi_schedule(&eth->rx_napi);
-		mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+		mtk_rx_irq_disable(eth, MTK_RX_DONE_INT);
 	}
 
 	return IRQ_HANDLED;
@@ -1682,7 +1702,7 @@ static irqreturn_t mtk_handle_irq_tx(int irq, void *_eth)
 
 	if (likely(napi_schedule_prep(&eth->tx_napi))) {
 		__napi_schedule(&eth->tx_napi);
-		mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
+		mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
 	}
 
 	return IRQ_HANDLED;
@@ -1694,11 +1714,11 @@ static void mtk_poll_controller(struct net_device *dev)
 	struct mtk_mac *mac = netdev_priv(dev);
 	struct mtk_eth *eth = mac->hw;
 
-	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
-	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+	mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
+	mtk_rx_irq_disable(eth, MTK_RX_DONE_INT);
 	mtk_handle_irq_rx(eth->irq[2], dev);
-	mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
-	mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+	mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
+	mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
 }
 #endif
 
@@ -1739,8 +1759,8 @@ static int mtk_open(struct net_device *dev)
 
 		napi_enable(&eth->tx_napi);
 		napi_enable(&eth->rx_napi);
-		mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
-		mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+		mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
+		mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
 	}
 	atomic_inc(&eth->dma_refcnt);
 
@@ -1785,8 +1805,8 @@ static int mtk_stop(struct net_device *dev)
 	if (!atomic_dec_and_test(&eth->dma_refcnt))
 		return 0;
 
-	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
-	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
+	mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
+	mtk_rx_irq_disable(eth, MTK_RX_DONE_INT);
 	napi_disable(&eth->tx_napi);
 	napi_disable(&eth->rx_napi);
 
@@ -1866,8 +1886,8 @@ static int mtk_hw_init(struct mtk_eth *eth)
 
 	/* disable delay and normal interrupt */
 	mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
-	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
-	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
+	mtk_tx_irq_disable(eth, ~0);
+	mtk_rx_irq_disable(eth, ~0);
 	mtk_w32(eth, RST_GL_PSE, MTK_RST_GL);
 	mtk_w32(eth, 0, MTK_RST_GL);
 
@@ -1938,8 +1958,8 @@ static void mtk_uninit(struct net_device *dev)
 	phy_disconnect(dev->phydev);
 	if (of_phy_is_fixed_link(mac->of_node))
 		of_phy_deregister_fixed_link(mac->of_node);
-	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
-	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
+	mtk_tx_irq_disable(eth, ~0);
+	mtk_rx_irq_disable(eth, ~0);
 }
 
 static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -2399,7 +2419,8 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->base);
 
 	spin_lock_init(&eth->page_lock);
-	spin_lock_init(&eth->irq_lock);
+	spin_lock_init(&eth->tx_irq_lock);
+	spin_lock_init(&eth->rx_irq_lock);
 
 	eth->ethsys = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
 						      "mediatek,ethsys");
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index e130c3b24c4c..5868a09f623a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -519,6 +519,8 @@ struct mtk_rx_ring {
  * @dev:		The device pointer
  * @base:		The mapped register i/o base
  * @page_lock:		Make sure that register operations are atomic
+ * @tx_irq__lock:	Make sure that IRQ register operations are atomic
+ * @rx_irq__lock:	Make sure that IRQ register operations are atomic
  * @dummy_dev:		we run 2 netdevs on 1 physical DMA ring and need a
  *			dummy for NAPI to work
  * @netdev:		The netdev instances
@@ -547,7 +549,8 @@ struct mtk_eth {
 	struct device			*dev;
 	void __iomem			*base;
 	spinlock_t			page_lock;
-	spinlock_t			irq_lock;
+	spinlock_t			tx_irq_lock;
+	spinlock_t			rx_irq_lock;
 	struct net_device		dummy_dev;
 	struct net_device		*netdev[MTK_MAX_DEVS];
 	struct mtk_mac			*mac[MTK_MAX_DEVS];
-- 
2.11.0
