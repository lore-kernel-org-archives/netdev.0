From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: fix early budget split
Date: Tue,  6 Dec 2016 03:45:00 +0200
Message-ID: <1480988700-17046-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The budget split function requires the phy speed to be known.
While ndo open a phy speed identification is postponed till the
moment link is up. Hence, move it to appropriate callback, when link
is up.

Reported-by: Grygorii Strashko <grygorii.strashko@ti.com>
Fixes: 8feb0a196507 ("net: ethernet: ti: cpsw: split tx budget according between channels")
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/cpsw.c | 154 ++++++++++++++++++++---------------------
 1 file changed, 77 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 3f96c57..f373a4b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -753,6 +753,82 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		dev_kfree_skb_any(new_skb);
 }
 
+/* split budget depending on channel rates */
+static void cpsw_split_budget(struct net_device *ndev)
+{
+	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_vector *txv = cpsw->txv;
+	u32 consumed_rate, bigest_rate = 0;
+	int budget, bigest_rate_ch = 0;
+	struct cpsw_slave *slave;
+	int i, rlim_ch_num = 0;
+	u32 ch_rate, max_rate;
+	int ch_budget = 0;
+
+	if (cpsw->data.dual_emac)
+		slave = &cpsw->slaves[priv->emac_port];
+	else
+		slave = &cpsw->slaves[cpsw->data.active_slave];
+
+	max_rate = slave->phy->speed * 1000;
+
+	consumed_rate = 0;
+	for (i = 0; i < cpsw->tx_ch_num; i++) {
+		ch_rate = cpdma_chan_get_rate(txv[i].ch);
+		if (!ch_rate)
+			continue;
+
+		rlim_ch_num++;
+		consumed_rate += ch_rate;
+	}
+
+	if (cpsw->tx_ch_num == rlim_ch_num) {
+		max_rate = consumed_rate;
+	} else {
+		ch_budget = (consumed_rate * CPSW_POLL_WEIGHT) / max_rate;
+		ch_budget = (CPSW_POLL_WEIGHT - ch_budget) /
+			    (cpsw->tx_ch_num - rlim_ch_num);
+		bigest_rate = (max_rate - consumed_rate) /
+			      (cpsw->tx_ch_num - rlim_ch_num);
+	}
+
+	/* split tx budget */
+	budget = CPSW_POLL_WEIGHT;
+	for (i = 0; i < cpsw->tx_ch_num; i++) {
+		ch_rate = cpdma_chan_get_rate(txv[i].ch);
+		if (ch_rate) {
+			txv[i].budget = (ch_rate * CPSW_POLL_WEIGHT) / max_rate;
+			if (!txv[i].budget)
+				txv[i].budget = 1;
+			if (ch_rate > bigest_rate) {
+				bigest_rate_ch = i;
+				bigest_rate = ch_rate;
+			}
+		} else {
+			txv[i].budget = ch_budget;
+			if (!bigest_rate_ch)
+				bigest_rate_ch = i;
+		}
+
+		budget -= txv[i].budget;
+	}
+
+	if (budget)
+		txv[bigest_rate_ch].budget += budget;
+
+	/* split rx budget */
+	budget = CPSW_POLL_WEIGHT;
+	ch_budget = budget / cpsw->rx_ch_num;
+	for (i = 0; i < cpsw->rx_ch_num; i++) {
+		cpsw->rxv[i].budget = ch_budget;
+		budget -= ch_budget;
+	}
+
+	if (budget)
+		cpsw->rxv[0].budget += budget;
+}
+
 static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
 {
 	struct cpsw_common *cpsw = dev_id;
@@ -941,6 +1017,7 @@ static void cpsw_adjust_link(struct net_device *ndev)
 	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
 
 	if (link) {
+		cpsw_split_budget(priv->ndev);
 		netif_carrier_on(ndev);
 		if (netif_running(ndev))
 			netif_tx_wake_all_queues(ndev);
@@ -1280,82 +1357,6 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	}
 }
 
-/* split budget depending on channel rates */
-static void cpsw_split_budget(struct net_device *ndev)
-{
-	struct cpsw_priv *priv = netdev_priv(ndev);
-	struct cpsw_common *cpsw = priv->cpsw;
-	struct cpsw_vector *txv = cpsw->txv;
-	u32 consumed_rate, bigest_rate = 0;
-	int budget, bigest_rate_ch = 0;
-	struct cpsw_slave *slave;
-	int i, rlim_ch_num = 0;
-	u32 ch_rate, max_rate;
-	int ch_budget = 0;
-
-	if (cpsw->data.dual_emac)
-		slave = &cpsw->slaves[priv->emac_port];
-	else
-		slave = &cpsw->slaves[cpsw->data.active_slave];
-
-	max_rate = slave->phy->speed * 1000;
-
-	consumed_rate = 0;
-	for (i = 0; i < cpsw->tx_ch_num; i++) {
-		ch_rate = cpdma_chan_get_rate(txv[i].ch);
-		if (!ch_rate)
-			continue;
-
-		rlim_ch_num++;
-		consumed_rate += ch_rate;
-	}
-
-	if (cpsw->tx_ch_num == rlim_ch_num) {
-		max_rate = consumed_rate;
-	} else {
-		ch_budget = (consumed_rate * CPSW_POLL_WEIGHT) / max_rate;
-		ch_budget = (CPSW_POLL_WEIGHT - ch_budget) /
-			    (cpsw->tx_ch_num - rlim_ch_num);
-		bigest_rate = (max_rate - consumed_rate) /
-			      (cpsw->tx_ch_num - rlim_ch_num);
-	}
-
-	/* split tx budget */
-	budget = CPSW_POLL_WEIGHT;
-	for (i = 0; i < cpsw->tx_ch_num; i++) {
-		ch_rate = cpdma_chan_get_rate(txv[i].ch);
-		if (ch_rate) {
-			txv[i].budget = (ch_rate * CPSW_POLL_WEIGHT) / max_rate;
-			if (!txv[i].budget)
-				txv[i].budget = 1;
-			if (ch_rate > bigest_rate) {
-				bigest_rate_ch = i;
-				bigest_rate = ch_rate;
-			}
-		} else {
-			txv[i].budget = ch_budget;
-			if (!bigest_rate_ch)
-				bigest_rate_ch = i;
-		}
-
-		budget -= txv[i].budget;
-	}
-
-	if (budget)
-		txv[bigest_rate_ch].budget += budget;
-
-	/* split rx budget */
-	budget = CPSW_POLL_WEIGHT;
-	ch_budget = budget / cpsw->rx_ch_num;
-	for (i = 0; i < cpsw->rx_ch_num; i++) {
-		cpsw->rxv[i].budget = ch_budget;
-		budget -= ch_budget;
-	}
-
-	if (budget)
-		cpsw->rxv[0].budget += budget;
-}
-
 static int cpsw_fill_rx_channels(struct cpsw_priv *priv)
 {
 	struct cpsw_common *cpsw = priv->cpsw;
@@ -1501,7 +1502,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_set_coalesce(ndev, &coal);
 	}
 
-	cpsw_split_budget(ndev);
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
 
-- 
2.7.4
