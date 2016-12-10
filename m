From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 4/5] net: ethernet: ti: cpsw: re-split res only when speed is changed
Date: Sat, 10 Dec 2016 14:23:49 +0200
Message-ID: <1481372630-14914-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't re-split res in the following cases:
- speed of phys is not changed
- speed of phys is changed and no rate limited channels
- speed of phys is changed and all channels are rate limited
- phy is unlinked while dev is open
- phy is linked back but speed is not changed

The maximum speed is sum of "linked" phys, thus res are split taken
in account two interfaces, both for dual emac mode and for
switch mode.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 64 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 59 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a2c2c06..7ccfa63 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -394,6 +394,7 @@ struct cpsw_common {
 	u32 irqs_table[IRQ_NUM];
 	struct cpts			*cpts;
 	int				rx_ch_num, tx_ch_num;
+	int				speed;
 };
 
 struct cpsw_priv {
@@ -761,7 +762,6 @@ static void cpsw_split_res(struct net_device *ndev)
 	struct cpsw_vector *txv = cpsw->txv;
 	int i, ch_weight, rlim_ch_num = 0;
 	int budget, bigest_rate_ch = 0;
-	struct cpsw_slave *slave;
 	u32 ch_rate, max_rate;
 	int ch_budget = 0;
 
@@ -781,8 +781,16 @@ static void cpsw_split_res(struct net_device *ndev)
 		bigest_rate = 0;
 		max_rate = consumed_rate;
 	} else {
-		slave = &cpsw->slaves[cpsw_slave_index(cpsw, priv)];
-		max_rate = slave->phy->speed * 1000;
+		max_rate = cpsw->speed * 1000;
+
+		/* if max_rate is less then expected due to reduced link speed,
+		 * split proportionally according next potential max speed
+		 */
+		if (max_rate < consumed_rate)
+			max_rate *= 10;
+
+		if (max_rate < consumed_rate)
+			max_rate *= 10;
 
 		ch_budget = (consumed_rate * CPSW_POLL_WEIGHT) / max_rate;
 		ch_budget = (CPSW_POLL_WEIGHT - ch_budget) /
@@ -1013,15 +1021,56 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	slave->mac_control = mac_control;
 }
 
+static int cpsw_get_common_speed(struct cpsw_common *cpsw)
+{
+	int i, speed;
+
+	for (i = 0, speed = 0; i < cpsw->data.slaves; i++)
+		if (cpsw->slaves[i].phy && cpsw->slaves[i].phy->link)
+			speed += cpsw->slaves[i].phy->speed;
+
+	return speed;
+}
+
+static int cpsw_need_resplit(struct cpsw_common *cpsw)
+{
+	int i, rlim_ch_num;
+	int speed, ch_rate;
+
+	/* re-split resources only in case speed was changed */
+	speed = cpsw_get_common_speed(cpsw);
+	if (speed == cpsw->speed || !speed)
+		return 0;
+
+	cpsw->speed = speed;
+
+	for (i = 0, rlim_ch_num = 0; i < cpsw->tx_ch_num; i++) {
+		ch_rate = cpdma_chan_get_rate(cpsw->txv[i].ch);
+		if (!ch_rate)
+			break;
+
+		rlim_ch_num++;
+	}
+
+	/* cases not dependent on speed */
+	if (!rlim_ch_num || rlim_ch_num == cpsw->tx_ch_num)
+		return 0;
+
+	return 1;
+}
+
 static void cpsw_adjust_link(struct net_device *ndev)
 {
 	struct cpsw_priv	*priv = netdev_priv(ndev);
+	struct cpsw_common	*cpsw = priv->cpsw;
 	bool			link = false;
 
 	for_each_slave(priv, _cpsw_adjust_link, priv, &link);
 
 	if (link) {
-		cpsw_split_res(priv->ndev);
+		if (cpsw_need_resplit(cpsw))
+			cpsw_split_res(ndev);
+
 		netif_carrier_on(ndev);
 		if (netif_running(ndev))
 			netif_tx_wake_all_queues(ndev);
@@ -1538,6 +1587,10 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_ale_stop(cpsw->ale);
 	}
 	for_each_slave(priv, cpsw_slave_stop, cpsw);
+
+	if (cpsw_need_resplit(cpsw))
+		cpsw_split_res(ndev);
+
 	pm_runtime_put_sync(cpsw->dev);
 	if (cpsw->data.dual_emac)
 		cpsw->slaves[priv->emac_port].open_stat = false;
@@ -1983,7 +2036,7 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 		return -EINVAL;
 	}
 
-	if (rate > 2000) {
+	if (rate > cpsw->speed) {
 		dev_err(priv->dev, "The channel rate cannot be more than 2Gbps");
 		return -EINVAL;
 	}
@@ -2998,6 +3051,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &cpsw_ethtool_ops;
 	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
 	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
+	cpsw_split_res(ndev);
 
 	/* register the network device */
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-- 
2.7.4
