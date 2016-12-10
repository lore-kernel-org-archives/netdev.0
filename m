From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 3/5] net: ethernet: ti: cpsw: combine budget and weight split and check
Date: Sat, 10 Dec 2016 14:23:48 +0200
Message-ID: <1481372630-14914-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34605 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753178AbcLJMX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 07:23:59 -0500
Received: by mail-lf0-f47.google.com with SMTP id y21so17043090lfa.1
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 04:23:58 -0800 (PST)
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-split weight along with budget. It simplify code a little
and update state after every rate change. Also it's necessarily
to move arguments checks to this combined function. Replace
maximum rate check for an interface on maximum possible rate.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 107 +++++++++++++----------------------------
 1 file changed, 34 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 23213a3..a2c2c06 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -753,27 +753,18 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		dev_kfree_skb_any(new_skb);
 }
 
-/* split budget depending on channel rates */
-static void cpsw_split_budget(struct net_device *ndev)
+static void cpsw_split_res(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	u32 consumed_rate = 0, bigest_rate = 0;
 	struct cpsw_common *cpsw = priv->cpsw;
 	struct cpsw_vector *txv = cpsw->txv;
-	u32 consumed_rate, bigest_rate = 0;
+	int i, ch_weight, rlim_ch_num = 0;
 	int budget, bigest_rate_ch = 0;
 	struct cpsw_slave *slave;
-	int i, rlim_ch_num = 0;
 	u32 ch_rate, max_rate;
 	int ch_budget = 0;
 
-	if (cpsw->data.dual_emac)
-		slave = &cpsw->slaves[priv->emac_port];
-	else
-		slave = &cpsw->slaves[cpsw->data.active_slave];
-
-	max_rate = slave->phy->speed * 1000;
-
-	consumed_rate = 0;
 	for (i = 0; i < cpsw->tx_ch_num; i++) {
 		ch_rate = cpdma_chan_get_rate(txv[i].ch);
 		if (!ch_rate)
@@ -785,7 +776,14 @@ static void cpsw_split_budget(struct net_device *ndev)
 
 	if (cpsw->tx_ch_num == rlim_ch_num) {
 		max_rate = consumed_rate;
+	} else if (!rlim_ch_num) {
+		ch_budget = CPSW_POLL_WEIGHT / cpsw->tx_ch_num;
+		bigest_rate = 0;
+		max_rate = consumed_rate;
 	} else {
+		slave = &cpsw->slaves[cpsw_slave_index(cpsw, priv)];
+		max_rate = slave->phy->speed * 1000;
+
 		ch_budget = (consumed_rate * CPSW_POLL_WEIGHT) / max_rate;
 		ch_budget = (CPSW_POLL_WEIGHT - ch_budget) /
 			    (cpsw->tx_ch_num - rlim_ch_num);
@@ -793,22 +791,28 @@ static void cpsw_split_budget(struct net_device *ndev)
 			      (cpsw->tx_ch_num - rlim_ch_num);
 	}
 
-	/* split tx budget */
+	/* split tx weight/budget */
 	budget = CPSW_POLL_WEIGHT;
 	for (i = 0; i < cpsw->tx_ch_num; i++) {
 		ch_rate = cpdma_chan_get_rate(txv[i].ch);
 		if (ch_rate) {
 			txv[i].budget = (ch_rate * CPSW_POLL_WEIGHT) / max_rate;
 			if (!txv[i].budget)
-				txv[i].budget = 1;
+				txv[i].budget++;
 			if (ch_rate > bigest_rate) {
 				bigest_rate_ch = i;
 				bigest_rate = ch_rate;
 			}
+
+			ch_weight = (ch_rate * 100) / max_rate;
+			if (!ch_weight)
+				ch_weight++;
+			cpdma_chan_set_weight(cpsw->txv[i].ch, ch_weight);
 		} else {
 			txv[i].budget = ch_budget;
 			if (!bigest_rate_ch)
 				bigest_rate_ch = i;
+			cpdma_chan_set_weight(cpsw->txv[i].ch, 0);
 		}
 
 		budget -= txv[i].budget;
@@ -1017,7 +1021,7 @@ static void cpsw_adjust_link(struct net_device *ndev)
 	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
 
 	if (link) {
-		cpsw_split_budget(priv->ndev);
+		cpsw_split_res(priv->ndev);
 		netif_carrier_on(ndev);
 		if (netif_running(ndev))
 			netif_tx_wake_all_queues(ndev);
@@ -1962,64 +1966,25 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
-	int tx_ch_num = ndev->real_num_tx_queues;
-	u32 consumed_rate, min_rate, max_rate;
 	struct cpsw_common *cpsw = priv->cpsw;
-	struct cpsw_slave *slave;
-	int ret, i, weight;
-	int rlim_num = 0;
+	u32 min_rate;
 	u32 ch_rate;
+	int ret;
 
 	ch_rate = netdev_get_tx_queue(ndev, queue)->tx_maxrate;
 	if (ch_rate == rate)
 		return 0;
 
-	if (cpsw->data.dual_emac)
-		slave = &cpsw->slaves[priv->emac_port];
-	else
-		slave = &cpsw->slaves[cpsw->data.active_slave];
-	max_rate = slave->phy->speed;
-
-	consumed_rate = 0;
-	for (i = 0; i < tx_ch_num; i++) {
-		if (i == queue)
-			ch_rate = rate;
-		else
-			ch_rate = netdev_get_tx_queue(ndev, i)->tx_maxrate;
-		if (!ch_rate)
-			continue;
-
-		rlim_num++;
-		consumed_rate += ch_rate;
-	}
-
-	if (consumed_rate > max_rate)
-		dev_info(priv->dev, "The common rate shouldn't be more than %dMbps",
-			 max_rate);
-
-	if (consumed_rate > max_rate) {
-		if (max_rate == 10 && consumed_rate <= 100) {
-			max_rate = 100;
-		} else if (max_rate <= 100 && consumed_rate <= 1000) {
-			max_rate = 1000;
-		} else {
-			dev_err(priv->dev, "The common rate cannot be more than %dMbps",
-				max_rate);
-			return -EINVAL;
-		}
-	}
-
-	if (consumed_rate > max_rate) {
-		dev_err(priv->dev, "The common rate cannot be more than %dMbps",
-			max_rate);
+	ch_rate = rate * 1000;
+	min_rate = cpdma_chan_get_min_rate(cpsw->dma);
+	if ((ch_rate < min_rate && ch_rate)) {
+		dev_err(priv->dev, "The channel rate cannot be less than %dMbps",
+			min_rate);
 		return -EINVAL;
 	}
 
-	rate *= 1000;
-	min_rate = cpdma_chan_get_min_rate(cpsw->dma);
-	if ((rate < min_rate && rate)) {
-		dev_err(priv->dev, "The common rate cannot be less than %dMbps",
-			min_rate);
+	if (rate > 2000) {
+		dev_err(priv->dev, "The channel rate cannot be more than 2Gbps");
 		return -EINVAL;
 	}
 
@@ -2029,17 +1994,13 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 		return ret;
 	}
 
-	if (rlim_num == tx_ch_num)
-		max_rate = consumed_rate;
+	ret = cpdma_chan_set_rate(cpsw->txv[queue].ch, ch_rate);
+	pm_runtime_put(cpsw->dev);
 
-	weight = (rate * 100) / (max_rate * 1000);
-	cpdma_chan_set_weight(cpsw->txv[queue].ch, weight);
-	ret = cpdma_chan_set_rate(cpsw->txv[queue].ch, rate);
+	if (ret)
+		return ret;
 
-	/* re-split budget between channels */
-	if (!rate)
-		cpsw_split_budget(ndev);
-	pm_runtime_put(cpsw->dev);
+	cpsw_split_res(ndev);
 	return ret;
 }
 
@@ -2399,7 +2360,7 @@ static int cpsw_set_channels(struct net_device *ndev,
 		if (ret)
 			goto err;
 
-		cpsw_split_budget(ndev);
+		cpsw_split_res(ndev);
 
 		/* After this receive is started */
 		cpdma_ctlr_start(cpsw->dma);
-- 
2.7.4
