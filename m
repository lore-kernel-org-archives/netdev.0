From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 5/5] net: ethernet: ti: cpsw: clarify ethtool ops changing num of descs
Date: Thu, 19 Jan 2017 18:58:27 +0200
Message-ID: <1484845107-30331-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34431 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753581AbdASRHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:07:33 -0500
Received: by mail-lf0-f45.google.com with SMTP id v186so41414967lfa.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:07:13 -0800 (PST)
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After adding cpsw_set_ringparam ethtool op, better to carry out
common parts of similar ops splitting descriptors in runtime. It
allows to reuse these parts and shows what the ops actually do.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 132 ++++++++++++++++++-----------------------
 1 file changed, 59 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1f14afd..897ebbe 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2358,17 +2358,11 @@ static int cpsw_update_channels(struct cpsw_priv *priv,
 	return 0;
 }
 
-static int cpsw_set_channels(struct net_device *ndev,
-			     struct ethtool_channels *chs)
+static void cpsw_suspend_data_pass(struct net_device *ndev)
 {
-	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_common *cpsw = ndev_to_cpsw(ndev);
 	struct cpsw_slave *slave;
-	int i, ret;
-
-	ret = cpsw_check_ch_settings(cpsw, chs);
-	if (ret < 0)
-		return ret;
+	int i;
 
 	/* Disable NAPI scheduling */
 	cpsw_intr_disable(cpsw);
@@ -2386,6 +2380,51 @@ static int cpsw_set_channels(struct net_device *ndev,
 
 	/* Handle rest of tx packets and stop cpdma channels */
 	cpdma_ctlr_stop(cpsw->dma);
+}
+
+static int cpsw_resume_data_pass(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
+	int i, ret;
+
+	/* Allow rx packets handling */
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++)
+		if (slave->ndev && netif_running(slave->ndev))
+			netif_dormant_off(slave->ndev);
+
+	/* After this receive is started */
+	if (cpsw_get_usage_count(cpsw)) {
+		ret = cpsw_fill_rx_channels(priv);
+		if (ret)
+			return ret;
+
+		cpdma_ctlr_start(cpsw->dma);
+		cpsw_intr_enable(cpsw);
+	}
+
+	/* Resume transmit for every affected interface */
+	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++)
+		if (slave->ndev && netif_running(slave->ndev))
+			netif_tx_start_all_queues(slave->ndev);
+
+	return 0;
+}
+
+static int cpsw_set_channels(struct net_device *ndev,
+			     struct ethtool_channels *chs)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
+	int i, ret;
+
+	ret = cpsw_check_ch_settings(cpsw, chs);
+	if (ret < 0)
+		return ret;
+
+	cpsw_suspend_data_pass(ndev);
 	ret = cpsw_update_channels(priv, chs);
 	if (ret)
 		goto err;
@@ -2408,30 +2447,14 @@ static int cpsw_set_channels(struct net_device *ndev,
 			dev_err(priv->dev, "cannot set real number of rx queues\n");
 			goto err;
 		}
-
-		/* Enable rx packets handling */
-		netif_dormant_off(slave->ndev);
 	}
 
-	if (cpsw_get_usage_count(cpsw)) {
-		ret = cpsw_fill_rx_channels(priv);
-		if (ret)
-			goto err;
-
+	if (cpsw_get_usage_count(cpsw))
 		cpsw_split_res(ndev);
 
-		/* After this receive is started */
-		cpdma_ctlr_start(cpsw->dma);
-		cpsw_intr_enable(cpsw);
-	}
-
-	/* Resume transmit for every affected interface */
-	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
-		if (!(slave->ndev && netif_running(slave->ndev)))
-			continue;
-		netif_tx_start_all_queues(slave->ndev);
-	}
-	return 0;
+	ret = cpsw_resume_data_pass(ndev);
+	if (!ret)
+		return 0;
 err:
 	dev_err(priv->dev, "cannot update channels number, closing device\n");
 	dev_close(ndev);
@@ -2492,8 +2515,7 @@ static int cpsw_set_ringparam(struct net_device *ndev,
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
-	struct cpsw_slave *slave;
-	int i, ret;
+	int ret;
 
 	/* ignore ering->tx_pending - only rx_pending adjustment is supported */
 
@@ -2505,54 +2527,18 @@ static int cpsw_set_ringparam(struct net_device *ndev,
 	if (ering->rx_pending == cpdma_get_num_rx_descs(cpsw->dma))
 		return 0;
 
-	/* Disable NAPI scheduling */
-	cpsw_intr_disable(cpsw);
-
-	/* Stop all transmit queues for every network device.
-	 * Disable re-using rx descriptors with dormant_on.
-	 */
-	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
-		if (!(slave->ndev && netif_running(slave->ndev)))
-			continue;
-
-		netif_tx_stop_all_queues(slave->ndev);
-		netif_dormant_on(slave->ndev);
-	}
-
-	/* Handle rest of tx packets and stop cpdma channels */
-	cpdma_ctlr_stop(cpsw->dma);
+	cpsw_suspend_data_pass(ndev);
 
 	cpdma_set_num_rx_descs(cpsw->dma, ering->rx_pending);
 
-	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
-		if (!(slave->ndev && netif_running(slave->ndev)))
-			continue;
-
-		/* Enable rx packets handling */
-		netif_dormant_off(slave->ndev);
-	}
-
-	if (cpsw_get_usage_count(cpsw)) {
+	if (cpsw_get_usage_count(cpsw))
 		cpdma_chan_split_pool(cpsw->dma);
 
-		ret = cpsw_fill_rx_channels(priv);
-		if (ret)
-			goto err;
-
-		/* After this receive is started */
-		cpdma_ctlr_start(cpsw->dma);
-		cpsw_intr_enable(cpsw);
-	}
+	ret = cpsw_resume_data_pass(ndev);
+	if (!ret)
+		return 0;
 
-	/* Resume transmit for every affected interface */
-	for (i = cpsw->data.slaves, slave = cpsw->slaves; i; i--, slave++) {
-		if (!(slave->ndev && netif_running(slave->ndev)))
-			continue;
-		netif_tx_start_all_queues(slave->ndev);
-	}
-	return 0;
-err:
-	dev_err(priv->dev, "cannot set ring params, closing device\n");
+	dev_err(&ndev->dev, "cannot set ring params, closing device\n");
 	dev_close(ndev);
 	return ret;
 }
-- 
2.7.4
