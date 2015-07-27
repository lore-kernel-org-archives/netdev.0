From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 2/2] drivers: net: cpsw: add separate napi for tx packet handling for performance improvment
Date: Mon, 27 Jul 2015 16:49:01 +0530
Message-ID: <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43494 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbbG0LTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:19:19 -0400
In-Reply-To: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of processing tx events in ISR itself, moving the tx
event processing to a separate napi improves tx performance by
180 Mbps with omap2plus_defconfig. Also cleaning up rx napis by
renaming to napi_rx for better understanding the code.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 61 ++++++++++++++++++++++++++++++++----------
 1 file changed, 47 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d68d759..4f98537 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -365,7 +365,8 @@ struct cpsw_priv {
 	spinlock_t			lock;
 	struct platform_device		*pdev;
 	struct net_device		*ndev;
-	struct napi_struct		napi;
+	struct napi_struct		napi_rx;
+	struct napi_struct		napi_tx;
 	struct device			*dev;
 	struct cpsw_platform_data	data;
 	struct cpsw_ss_regs __iomem	*regs;
@@ -752,13 +753,22 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 	struct cpsw_priv *priv = dev_id;
 
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
-	cpdma_chan_process(priv->txch, 128);
+	writel(0, &priv->wr_regs->tx_en);
+
+	if (netif_running(priv->ndev)) {
+		napi_schedule(&priv->napi_tx);
+		return IRQ_HANDLED;
+	}
 
 	priv = cpsw_get_slave_priv(priv, 1);
-	if (priv)
-		cpdma_chan_process(priv->txch, 128);
+	if (!priv)
+		return IRQ_NONE;
 
-	return IRQ_HANDLED;
+	if (netif_running(priv->ndev)) {
+		napi_schedule(&priv->napi_tx);
+		return IRQ_HANDLED;
+	}
+	return IRQ_NONE;
 }
 
 static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
@@ -769,7 +779,7 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	writel(0, &priv->wr_regs->rx_en);
 
 	if (netif_running(priv->ndev)) {
-		napi_schedule(&priv->napi);
+		napi_schedule(&priv->napi_rx);
 		return IRQ_HANDLED;
 	}
 
@@ -778,20 +788,37 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 
 	if (netif_running(priv->ndev)) {
-		napi_schedule(&priv->napi);
+		napi_schedule(&priv->napi_rx);
 		return IRQ_HANDLED;
 	}
 	return IRQ_NONE;
 }
 
-static int cpsw_poll(struct napi_struct *napi, int budget)
+static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
+{
+	struct cpsw_priv	*priv = napi_to_priv(napi_tx);
+	int			num_tx;
+
+	num_tx = cpdma_chan_process(priv->txch, budget);
+	if (num_tx < budget) {
+		napi_complete(napi_tx);
+		writel(0xff, &priv->wr_regs->tx_en);
+	}
+
+	if (num_tx)
+		cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
+
+	return num_tx;
+}
+
+static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 {
-	struct cpsw_priv	*priv = napi_to_priv(napi);
+	struct cpsw_priv	*priv = napi_to_priv(napi_rx);
 	int			num_rx;
 
 	num_rx = cpdma_chan_process(priv->rxch, budget);
 	if (num_rx < budget) {
-		napi_complete(napi);
+		napi_complete(napi_rx);
 		writel(0xff, &priv->wr_regs->rx_en);
 	}
 
@@ -1297,7 +1324,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
-	napi_enable(&priv->napi);
+	napi_enable(&priv->napi_rx);
+	napi_enable(&priv->napi_tx);
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 
@@ -1319,7 +1347,8 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
 	netif_stop_queue(priv->ndev);
-	napi_disable(&priv->napi);
+	napi_disable(&priv->napi_rx);
+	napi_disable(&priv->napi_tx);
 	netif_carrier_off(priv->ndev);
 
 	if (cpsw_common_res_usage_state(priv) <= 1) {
@@ -2105,7 +2134,10 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &priv_sl2->napi, cpsw_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv_sl2->napi_rx, cpsw_rx_poll,
+		       CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv_sl2->napi_tx, cpsw_tx_poll,
+		       CPSW_POLL_WEIGHT);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -2357,7 +2389,8 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &priv->napi, cpsw_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-- 
2.5.0.rc3.2.g6f9504c
