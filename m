From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: Add support for pause frames
Date: Fri, 29 Aug 2014 14:26:21 +0530
Message-ID: <1409302581-25290-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:37124 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbaH2I43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 04:56:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPSW supports both rx and tx pause frames for flow control.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 999fb72..81325d4 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -397,6 +397,8 @@ struct cpsw_priv {
 	struct cpdma_ctlr		*dma;
 	struct cpdma_chan		*txch, *rxch;
 	struct cpsw_ale			*ale;
+	bool				rx_pause;
+	bool				tx_pause;
 	/* snapshot of IRQ numbers */
 	u32 irqs_table[4];
 	u32 num_irqs;
@@ -832,6 +834,12 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 		else if (phy->speed == 10)
 			mac_control |= BIT(18); /* In Band mode */
 
+		if (priv->rx_pause)
+			mac_control |= BIT(3);
+
+		if (priv->tx_pause)
+			mac_control |= BIT(4);
+
 		*link = true;
 	} else {
 		mac_control = 0;
@@ -1223,6 +1231,9 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		/* enable statistics collection only on all ports */
 		__raw_writel(0x7, &priv->regs->stat_port_en);
 
+		/* Enable internal fifo flow control */
+		writel(0x7, &priv->regs->flow_control);
+
 		if (WARN_ON(!priv->data.rx_descs))
 			priv->data.rx_descs = 128;
 
@@ -1784,6 +1795,30 @@ static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 		return -EOPNOTSUPP;
 }
 
+static void cpsw_get_pauseparam(struct net_device *ndev,
+				struct ethtool_pauseparam *pause)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+
+	pause->autoneg = AUTONEG_DISABLE;
+	pause->rx_pause = (priv->rx_pause) ? true : false;
+	pause->tx_pause = (priv->tx_pause) ? true : false;
+}
+
+static int cpsw_set_pauseparam(struct net_device *ndev,
+			       struct ethtool_pauseparam *pause)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	bool link;
+
+	priv->rx_pause = (pause->rx_pause) ? true : false;
+	priv->tx_pause = (pause->tx_pause) ? true : false;
+
+	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
+
+	return 0;
+}
+
 static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_drvinfo	= cpsw_get_drvinfo,
 	.get_msglevel	= cpsw_get_msglevel,
@@ -1797,6 +1832,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.get_sset_count		= cpsw_get_sset_count,
 	.get_strings		= cpsw_get_strings,
 	.get_ethtool_stats	= cpsw_get_ethtool_stats,
+	.get_pauseparam		= cpsw_get_pauseparam,
+	.set_pauseparam		= cpsw_set_pauseparam,
 	.get_wol	= cpsw_get_wol,
 	.set_wol	= cpsw_set_wol,
 	.get_regs_len	= cpsw_get_regs_len,
-- 
2.1.0
