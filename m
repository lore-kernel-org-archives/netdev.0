From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 3/3] drivers: net: cpsw: add separate napi for tx
Date: Tue, 4 Aug 2015 16:06:20 +0530
Message-ID: <1438684580-11384-4-git-send-email-mugunthanvnm@ti.com>
References: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:33439 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbbHDKgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 06:36:43 -0400
In-Reply-To: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of processing tx events in isr adding separate napi for
tx which improves performance by ~180Mbps with
omap2plus_defconfig on DRA74x platform. Also cleaning up rx napis
by renaming to napi_rx for better understanding the code.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 44 +++++++++++++++++++++++++++++-------------
 1 file changed, 31 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1d923e8..3b81b39 100644
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
@@ -751,13 +752,10 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_priv *priv = dev_id;
 
+	writel(0, &priv->wr_regs->tx_en);
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
-	cpdma_chan_process(priv->txch, 128);
-
-	priv = cpsw_get_slave_priv(priv, 1);
-	if (priv)
-		cpdma_chan_process(priv->txch, 128);
 
+	napi_schedule(&priv->napi_tx);
 	return IRQ_HANDLED;
 }
 
@@ -768,18 +766,35 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
 	writel(0, &priv->wr_regs->rx_en);
 
-	napi_schedule(&priv->napi);
+	napi_schedule(&priv->napi_rx);
 	return IRQ_HANDLED;
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
 
@@ -1249,7 +1264,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		/* Enable internal fifo flow control */
 		writel(0x7, &priv->regs->flow_control);
 
-		napi_enable(&priv_sl0->napi);
+		napi_enable(&priv_sl0->napi_rx);
+		napi_enable(&priv_sl0->napi_tx);
 
 		if (WARN_ON(!priv->data.rx_descs))
 			priv->data.rx_descs = 128;
@@ -1315,7 +1331,8 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	if (cpsw_common_res_usage_state(priv) <= 1) {
 		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
 
-		napi_disable(&priv_sl0->napi);
+		napi_disable(&priv_sl0->napi_rx);
+		napi_disable(&priv_sl0->napi_tx);
 		cpts_unregister(priv->cpts);
 		cpsw_intr_disable(priv);
 		cpdma_ctlr_stop(priv->dma);
@@ -2349,7 +2366,8 @@ static int cpsw_probe(struct platform_device *pdev)
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &priv->napi, cpsw_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
+	netif_napi_add(ndev, &priv->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-- 
2.5.0.234.gefc8a62
