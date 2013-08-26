From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 03/11] net: calxedaxgmac: fix race between xgmac_tx_complete and xgmac_tx_err
Date: Mon, 26 Aug 2013 17:45:18 -0500
Message-ID: <1377557126-10716-3-git-send-email-robherring2@gmail.com>
References: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Cc: Andreas Herrmann <andreas.herrmann@calxeda.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

It is possible for the xgmac_tx_complete to run concurrently with
xgmac_tx_err since there are no locks. Fix this by moving the tx
error handling to a workqueue so we can disable napi while we reset
the transmitter.

Reported-by: Andreas Herrmann <andreas.herrmann@calxeda.com>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 38 +++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index d41af68..df7e3e2 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -393,6 +393,7 @@ struct xgmac_priv {
 	char rx_pause;
 	char tx_pause;
 	int wolopts;
+	struct work_struct tx_timeout_work;
 };
 
 /* XGMAC Configuration Settings */
@@ -897,21 +898,18 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 		netif_wake_queue(priv->dev);
 }
 
-/**
- * xgmac_tx_err:
- * @priv: pointer to the private device structure
- * Description: it cleans the descriptors and restarts the transmission
- * in case of errors.
- */
-static void xgmac_tx_err(struct xgmac_priv *priv)
+static void xgmac_tx_timeout_work(struct work_struct *work)
 {
-	u32 reg, value, inten;
+	u32 reg, value;
+	struct xgmac_priv *priv =
+		container_of(work, struct xgmac_priv, tx_timeout_work);
 
-	netif_stop_queue(priv->dev);
+	napi_disable(&priv->napi);
 
-	inten = readl(priv->base + XGMAC_DMA_INTR_ENA);
 	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
 
+	netif_tx_lock(priv->dev);
+
 	reg = readl(priv->base + XGMAC_DMA_CONTROL);
 	writel(reg & ~DMA_CONTROL_ST, priv->base + XGMAC_DMA_CONTROL);
 	do {
@@ -927,9 +925,15 @@ static void xgmac_tx_err(struct xgmac_priv *priv)
 
 	writel(DMA_STATUS_TU | DMA_STATUS_TPS | DMA_STATUS_NIS | DMA_STATUS_AIS,
 		priv->base + XGMAC_DMA_STATUS);
-	writel(inten, priv->base + XGMAC_DMA_INTR_ENA);
 
+	netif_tx_unlock(priv->dev);
 	netif_wake_queue(priv->dev);
+
+	napi_enable(&priv->napi);
+
+	/* Enable interrupts */
+	writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_STATUS);
+	writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
 }
 
 static int xgmac_hw_init(struct net_device *dev)
@@ -1225,9 +1229,7 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
 static void xgmac_tx_timeout(struct net_device *dev)
 {
 	struct xgmac_priv *priv = netdev_priv(dev);
-
-	/* Clear Tx resources and restart transmitting again */
-	xgmac_tx_err(priv);
+	schedule_work(&priv->tx_timeout_work);
 }
 
 /**
@@ -1366,7 +1368,6 @@ static irqreturn_t xgmac_pmt_interrupt(int irq, void *dev_id)
 static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 {
 	u32 intr_status;
-	bool tx_err = false;
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct xgmac_priv *priv = netdev_priv(dev);
 	struct xgmac_extra_stats *x = &priv->xstats;
@@ -1396,16 +1397,12 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 		if (intr_status & DMA_STATUS_TPS) {
 			netdev_err(priv->dev, "transmit process stopped\n");
 			x->tx_process_stopped++;
-			tx_err = true;
+			schedule_work(&priv->tx_timeout_work);
 		}
 		if (intr_status & DMA_STATUS_FBI) {
 			netdev_err(priv->dev, "fatal bus error\n");
 			x->fatal_bus_error++;
-			tx_err = true;
 		}
-
-		if (tx_err)
-			xgmac_tx_err(priv);
 	}
 
 	/* TX/RX NORMAL interrupts */
@@ -1708,6 +1705,7 @@ static int xgmac_probe(struct platform_device *pdev)
 	ndev->netdev_ops = &xgmac_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &xgmac_ethtool_ops);
 	spin_lock_init(&priv->stats_lock);
+	INIT_WORK(&priv->tx_timeout_work, xgmac_tx_timeout_work);
 
 	priv->device = &pdev->dev;
 	priv->dev = ndev;
-- 
1.8.1.2
