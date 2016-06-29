From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH V2 4/4] net-next: mediatek: add support for IRQ grouping
Date: Wed, 29 Jun 2016 13:38:11 +0200
Message-ID: <1467200291-60106-5-git-send-email-john@phrozen.org>
References: <1467200291-60106-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467200291-60106-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The ethernet core has 3 IRQs. Using the IRQ grouping registers we are able
to separate TX and RX IRQs, which allows us to service them on separate
cores. This patch splits the IRQ handler into 2 separate functions, one for
TX and another for RX. The TX housekeeping is split out into its own NAPI
handler.

Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |  155 +++++++++++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |   15 ++-
 2 files changed, 111 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 698caba..7056a37 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -893,17 +893,17 @@ release_desc:
 	return done;
 }
 
-static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
+static int mtk_poll_tx(struct mtk_eth *eth, int budget)
 {
 	struct mtk_tx_ring *ring = &eth->tx_ring;
 	struct mtk_tx_dma *desc;
 	struct sk_buff *skb;
 	struct mtk_tx_buf *tx_buf;
-	int total = 0, done[MTK_MAX_DEVS];
+	unsigned int done[MTK_MAX_DEVS];
 	unsigned int bytes[MTK_MAX_DEVS];
 	u32 cpu, dma;
 	static int condition;
-	int i;
+	int total = 0, i;
 
 	memset(done, 0, sizeof(done));
 	memset(bytes, 0, sizeof(bytes));
@@ -954,15 +954,6 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 		total += done[i];
 	}
 
-	/* read hw index again make sure no new tx packet */
-	if (cpu != dma || cpu != mtk_r32(eth, MTK_QTX_DRX_PTR))
-		*tx_again = true;
-	else
-		mtk_w32(eth, MTK_TX_DONE_INT, MTK_QMTK_INT_STATUS);
-
-	if (!total)
-		return 0;
-
 	if (mtk_queue_stopped(eth) &&
 	    (atomic_read(&ring->free_count) > ring->thresh))
 		mtk_wake_queue(eth);
@@ -970,47 +961,75 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 	return total;
 }
 
-static int mtk_poll(struct napi_struct *napi, int budget)
+static void mtk_handle_status_irq(struct mtk_eth *eth)
 {
-	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
-	u32 status, status2, mask;
-	int tx_done, rx_done;
-	bool tx_again = false;
-
-	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
-	status2 = mtk_r32(eth, MTK_INT_STATUS2);
-	tx_done = 0;
-	rx_done = 0;
-	tx_again = 0;
-
-	if (status & MTK_TX_DONE_INT)
-		tx_done = mtk_poll_tx(eth, budget, &tx_again);
-
-	if (status & MTK_RX_DONE_INT)
-		rx_done = mtk_poll_rx(napi, budget, eth);
+	u32 status2 = mtk_r32(eth, MTK_INT_STATUS2);
 
 	if (unlikely(status2 & (MTK_GDM1_AF | MTK_GDM2_AF))) {
 		mtk_stats_update(eth);
 		mtk_w32(eth, (MTK_GDM1_AF | MTK_GDM2_AF),
 			MTK_INT_STATUS2);
 	}
+}
+
+static int mtk_napi_tx(struct napi_struct *napi, int budget)
+{
+	struct mtk_eth *eth = container_of(napi, struct mtk_eth, tx_napi);
+	u32 status, mask;
+	int tx_done = 0;
+
+	mtk_handle_status_irq(eth);
+	mtk_w32(eth, MTK_TX_DONE_INT, MTK_QMTK_INT_STATUS);
+	tx_done = mtk_poll_tx(eth, budget);
+
+	if (unlikely(netif_msg_intr(eth))) {
+		status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
+		mask = mtk_r32(eth, MTK_QDMA_INT_MASK);
+		dev_info(eth->dev,
+			 "done tx %d, intr 0x%08x/0x%x\n",
+			 tx_done, status, mask);
+	}
+
+	if (tx_done == budget)
+		return budget;
+
+	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
+	if (status & MTK_TX_DONE_INT)
+		return budget;
+
+	napi_complete(napi);
+	mtk_irq_enable(eth, MTK_TX_DONE_INT);
+
+	return tx_done;
+}
+
+static int mtk_napi_rx(struct napi_struct *napi, int budget)
+{
+	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
+	u32 status, mask;
+	int rx_done = 0;
+
+	mtk_handle_status_irq(eth);
+	mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
+	rx_done = mtk_poll_rx(napi, budget, eth);
 
 	if (unlikely(netif_msg_intr(eth))) {
+		status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
 		mask = mtk_r32(eth, MTK_QDMA_INT_MASK);
-		netdev_info(eth->netdev[0],
-			    "done tx %d, rx %d, intr 0x%08x/0x%x\n",
-			    tx_done, rx_done, status, mask);
+		dev_info(eth->dev,
+			 "done rx %d, intr 0x%08x/0x%x\n",
+			 rx_done, status, mask);
 	}
 
-	if (tx_again || rx_done == budget)
+	if (rx_done == budget)
 		return budget;
 
 	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
-	if (status & (tx_intr | rx_intr))
+	if (status & MTK_RX_DONE_INT)
 		return budget;
 
 	napi_complete(napi);
-	mtk_irq_enable(eth, MTK_RX_DONE_INT | MTK_RX_DONE_INT);
+	mtk_irq_enable(eth, MTK_RX_DONE_INT);
 
 	return rx_done;
 }
@@ -1246,22 +1265,26 @@ static void mtk_tx_timeout(struct net_device *dev)
 	schedule_work(&eth->pending_work);
 }
 
-static irqreturn_t mtk_handle_irq(int irq, void *_eth)
+static irqreturn_t mtk_handle_irq_rx(int irq, void *_eth)
 {
 	struct mtk_eth *eth = _eth;
-	u32 status;
 
-	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
-	if (unlikely(!status))
-		return IRQ_NONE;
+	if (likely(napi_schedule_prep(&eth->rx_napi))) {
+		__napi_schedule(&eth->rx_napi);
+		mtk_irq_disable(eth, MTK_RX_DONE_INT);
+	}
 
-	if (likely(status & (MTK_RX_DONE_INT | MTK_TX_DONE_INT))) {
-		if (likely(napi_schedule_prep(&eth->rx_napi)))
-			__napi_schedule(&eth->rx_napi);
-	} else {
-		mtk_w32(eth, status, MTK_QMTK_INT_STATUS);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t mtk_handle_irq_tx(int irq, void *_eth)
+{
+	struct mtk_eth *eth = _eth;
+
+	if (likely(napi_schedule_prep(&eth->tx_napi))) {
+		__napi_schedule(&eth->tx_napi);
+		mtk_irq_disable(eth, MTK_TX_DONE_INT);
 	}
-	mtk_irq_disable(eth, (MTK_RX_DONE_INT | MTK_TX_DONE_INT));
 
 	return IRQ_HANDLED;
 }
@@ -1274,7 +1297,7 @@ static void mtk_poll_controller(struct net_device *dev)
 	u32 int_mask = MTK_TX_DONE_INT | MTK_RX_DONE_INT;
 
 	mtk_irq_disable(eth, int_mask);
-	mtk_handle_irq(dev->irq, dev);
+	mtk_handle_irq(dev->irq[0], dev);
 	mtk_irq_enable(eth, int_mask);
 }
 #endif
@@ -1310,6 +1333,7 @@ static int mtk_open(struct net_device *dev)
 		if (err)
 			return err;
 
+		napi_enable(&eth->tx_napi);
 		napi_enable(&eth->rx_napi);
 		mtk_irq_enable(eth, MTK_TX_DONE_INT | MTK_RX_DONE_INT);
 	}
@@ -1358,6 +1382,7 @@ static int mtk_stop(struct net_device *dev)
 		return 0;
 
 	mtk_irq_disable(eth, MTK_TX_DONE_INT | MTK_RX_DONE_INT);
+	napi_disable(&eth->tx_napi);
 	napi_disable(&eth->rx_napi);
 
 	mtk_stop_dma(eth, MTK_QDMA_GLO_CFG);
@@ -1395,7 +1420,11 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	/* Enable RX VLan Offloading */
 	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
 
-	err = devm_request_irq(eth->dev, eth->irq, mtk_handle_irq, 0,
+	err = devm_request_irq(eth->dev, eth->irq[1], mtk_handle_irq_tx, 0,
+			       dev_name(eth->dev), eth);
+	if (err)
+		return err;
+	err = devm_request_irq(eth->dev, eth->irq[2], mtk_handle_irq_rx, 0,
 			       dev_name(eth->dev), eth);
 	if (err)
 		return err;
@@ -1411,7 +1440,11 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 	mtk_w32(eth, 0, MTK_RST_GL);
 
 	/* FE int grouping */
-	mtk_w32(eth, 0, MTK_FE_INT_GRP);
+	mtk_w32(eth, MTK_TX_DONE_INT, MTK_PDMA_INT_GRP1);
+	mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_GRP2);
+	mtk_w32(eth, MTK_TX_DONE_INT, MTK_QDMA_INT_GRP1);
+	mtk_w32(eth, MTK_RX_DONE_INT, MTK_QDMA_INT_GRP2);
+	mtk_w32(eth, 0x21021000, MTK_FE_INT_GRP);
 
 	for (i = 0; i < 2; i++) {
 		u32 val = mtk_r32(eth, MTK_GDMA_FWD_CFG(i));
@@ -1459,7 +1492,9 @@ static void mtk_uninit(struct net_device *dev)
 	phy_disconnect(mac->phy_dev);
 	mtk_mdio_cleanup(eth);
 	mtk_irq_disable(eth, ~0);
-	free_irq(dev->irq, dev);
+	free_irq(eth->irq[0], dev);
+	free_irq(eth->irq[1], dev);
+	free_irq(eth->irq[2], dev);
 }
 
 static int mtk_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -1733,10 +1768,10 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 		dev_err(eth->dev, "error bringing up device\n");
 		goto free_netdev;
 	}
-	eth->netdev[id]->irq = eth->irq;
+	eth->netdev[id]->irq = eth->irq[0];
 	netif_info(eth, probe, eth->netdev[id],
 		   "mediatek frame engine at 0x%08lx, irq %d\n",
-		   eth->netdev[id]->base_addr, eth->netdev[id]->irq);
+		   eth->netdev[id]->base_addr, eth->irq[0]);
 
 	return 0;
 
@@ -1753,6 +1788,7 @@ static int mtk_probe(struct platform_device *pdev)
 	struct mtk_soc_data *soc;
 	struct mtk_eth *eth;
 	int err;
+	int i;
 
 	match = of_match_device(of_mtk_match, &pdev->dev);
 	soc = (struct mtk_soc_data *)match->data;
@@ -1788,10 +1824,12 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->rstc);
 	}
 
-	eth->irq = platform_get_irq(pdev, 0);
-	if (eth->irq < 0) {
-		dev_err(&pdev->dev, "no IRQ resource found\n");
-		return -ENXIO;
+	for (i = 0; i < 3; i++) {
+		eth->irq[i] = platform_get_irq(pdev, i);
+		if (eth->irq[i] < 0) {
+			dev_err(&pdev->dev, "no IRQ%d resource found\n", i);
+			return -ENXIO;
+		}
 	}
 
 	eth->clk_ethif = devm_clk_get(&pdev->dev, "ethif");
@@ -1832,7 +1870,9 @@ static int mtk_probe(struct platform_device *pdev)
 	 * for NAPI to work
 	 */
 	init_dummy_netdev(&eth->dummy_dev);
-	netif_napi_add(&eth->dummy_dev, &eth->rx_napi, mtk_poll,
+	netif_napi_add(&eth->dummy_dev, &eth->tx_napi, mtk_napi_tx,
+		       MTK_NAPI_WEIGHT);
+	netif_napi_add(&eth->dummy_dev, &eth->rx_napi, mtk_napi_rx,
 		       MTK_NAPI_WEIGHT);
 
 	platform_set_drvdata(pdev, eth);
@@ -1853,6 +1893,7 @@ static int mtk_remove(struct platform_device *pdev)
 	clk_disable_unprepare(eth->clk_gp1);
 	clk_disable_unprepare(eth->clk_gp2);
 
+	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
 	mtk_cleanup(eth);
 	platform_set_drvdata(pdev, NULL);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 3159d2a..f82e3ac 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -68,6 +68,10 @@
 /* Unicast Filter MAC Address Register - High */
 #define MTK_GDMA_MAC_ADRH(x)	(0x50C + (x * 0x1000))
 
+/* PDMA Interrupt grouping registers */
+#define MTK_PDMA_INT_GRP1	0xa50
+#define MTK_PDMA_INT_GRP2	0xa54
+
 /* QDMA TX Queue Configuration Registers */
 #define MTK_QTX_CFG(x)		(0x1800 + (x * 0x10))
 #define QDMA_RES_THRES		4
@@ -125,6 +129,11 @@
 #define MTK_TX_DONE_INT		(MTK_TX_DONE_INT0 | MTK_TX_DONE_INT1 | \
 				 MTK_TX_DONE_INT2 | MTK_TX_DONE_INT3)
 
+/* QDMA Interrupt grouping registers */
+#define MTK_QDMA_INT_GRP1	0x1a20
+#define MTK_QDMA_INT_GRP2	0x1a24
+#define MTK_RLS_DONE_INT	BIT(0)
+
 /* QDMA Interrupt Status Register */
 #define MTK_QDMA_INT_MASK	0x1A1C
 
@@ -356,7 +365,8 @@ struct mtk_rx_ring {
  * @dma_refcnt:		track how many netdevs are using the DMA engine
  * @tx_ring:		Pointer to the memore holding info about the TX ring
  * @rx_ring:		Pointer to the memore holding info about the RX ring
- * @rx_napi:		The NAPI struct
+ * @tx_napi:		The TX NAPI struct
+ * @rx_napi:		The RX NAPI struct
  * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
  * @phy_scratch_ring:	physical address of scratch_ring
  * @scratch_head:	The scratch memory that scratch_ring points to.
@@ -377,7 +387,7 @@ struct mtk_eth {
 	struct net_device		dummy_dev;
 	struct net_device		*netdev[MTK_MAX_DEVS];
 	struct mtk_mac			*mac[MTK_MAX_DEVS];
-	int				irq;
+	int				irq[3];
 	u32				msg_enable;
 	unsigned long			sysclk;
 	struct regmap			*ethsys;
@@ -385,6 +395,7 @@ struct mtk_eth {
 	atomic_t			dma_refcnt;
 	struct mtk_tx_ring		tx_ring;
 	struct mtk_rx_ring		rx_ring;
+	struct napi_struct		tx_napi;
 	struct napi_struct		rx_napi;
 	struct mtk_tx_dma		*scratch_ring;
 	dma_addr_t			phy_scratch_ring;
-- 
1.7.10.4
