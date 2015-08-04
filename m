From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v2 2/3] drivers: net: cpsw: dual_emac: simplify napi usage
Date: Tue, 4 Aug 2015 16:06:19 +0530
Message-ID: <1438684580-11384-3-git-send-email-mugunthanvnm@ti.com>
References: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38356 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755774AbbHDKgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 06:36:41 -0400
In-Reply-To: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since interrupt is shared between the two ethernet interface and
in isr only one napi is scheduled at an instance so having two
napis doesn't make any difference. So making napi also as a
common resource for the dual ethernet interfaces.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d68d759..1d923e8 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -768,20 +768,8 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
 	writel(0, &priv->wr_regs->rx_en);
 
-	if (netif_running(priv->ndev)) {
-		napi_schedule(&priv->napi);
-		return IRQ_HANDLED;
-	}
-
-	priv = cpsw_get_slave_priv(priv, 1);
-	if (!priv)
-		return IRQ_NONE;
-
-	if (netif_running(priv->ndev)) {
-		napi_schedule(&priv->napi);
-		return IRQ_HANDLED;
-	}
-	return IRQ_NONE;
+	napi_schedule(&priv->napi);
+	return IRQ_HANDLED;
 }
 
 static int cpsw_poll(struct napi_struct *napi, int budget)
@@ -1246,6 +1234,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 				  ALE_ALL_PORTS << priv->host_port, 0, 0);
 
 	if (!cpsw_common_res_usage_state(priv)) {
+		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+
 		/* setup tx dma to fixed prio and zero offset */
 		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
 		cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
@@ -1259,6 +1249,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		/* Enable internal fifo flow control */
 		writel(0x7, &priv->regs->flow_control);
 
+		napi_enable(&priv_sl0->napi);
+
 		if (WARN_ON(!priv->data.rx_descs))
 			priv->data.rx_descs = 128;
 
@@ -1297,7 +1289,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
-	napi_enable(&priv->napi);
 	cpdma_ctlr_start(priv->dma);
 	cpsw_intr_enable(priv);
 
@@ -1319,10 +1310,12 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 
 	cpsw_info(priv, ifdown, "shutting down cpsw device\n");
 	netif_stop_queue(priv->ndev);
-	napi_disable(&priv->napi);
 	netif_carrier_off(priv->ndev);
 
 	if (cpsw_common_res_usage_state(priv) <= 1) {
+		struct cpsw_priv *priv_sl0 = cpsw_get_slave_priv(priv, 0);
+
+		napi_disable(&priv_sl0->napi);
 		cpts_unregister(priv->cpts);
 		cpsw_intr_disable(priv);
 		cpdma_ctlr_stop(priv->dma);
@@ -2105,7 +2098,6 @@ static int cpsw_probe_dual_emac(struct platform_device *pdev,
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
-	netif_napi_add(ndev, &priv_sl2->napi, cpsw_poll, CPSW_POLL_WEIGHT);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-- 
2.5.0.234.gefc8a62
