From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 3/5] net: ethernet: ti: cpsw: don't duplicate ndev_running
Date: Thu, 19 Jan 2017 18:58:25 +0200
Message-ID: <1484845107-30331-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35512 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753488AbdASRHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:07:33 -0500
Received: by mail-lf0-f42.google.com with SMTP id n124so41286137lfd.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:06:50 -0800 (PST)
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to create additional vars to identify if interface is running.
So simplify code by removing redundant var and checking usage counter
instead.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f798905..c681d39 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -357,7 +357,6 @@ struct cpsw_slave {
 	struct phy_device		*phy;
 	struct net_device		*ndev;
 	u32				port_vlan;
-	u32				open_stat;
 };
 
 static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
@@ -1235,13 +1234,13 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
+static int cpsw_get_usage_count(struct cpsw_common *cpsw)
 {
 	u32 i;
 	u32 usage_count = 0;
 
 	for (i = 0; i < cpsw->data.slaves; i++)
-		if (cpsw->slaves[i].open_stat)
+		if (netif_running(cpsw->slaves[i].ndev))
 			usage_count++;
 
 	return usage_count;
@@ -1501,8 +1500,11 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
 		 CPSW_RTL_VERSION(reg));
 
-	/* initialize host and slave ports */
-	if (!cpsw_common_res_usage_state(cpsw))
+	/* Initialize host and slave ports.
+	 * Given ndev is marked as opened already, so init port only if 1 ndev
+	 * is opened
+	 */
+	if (cpsw_get_usage_count(cpsw) < 2)
 		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
@@ -1513,7 +1515,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
-	if (!cpsw_common_res_usage_state(cpsw)) {
+	/* Given ndev is marked as opened already, so if more ndev
+	 * are opened - no need to init shared resources.
+	 */
+	if (cpsw_get_usage_count(cpsw) < 2) {
 		/* disable priority elevation */
 		__raw_writel(0, &cpsw->regs->ptype);
 
@@ -1556,9 +1561,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
 
-	if (cpsw->data.dual_emac)
-		cpsw->slaves[priv->emac_port].open_stat = true;
-
 	return 0;
 
 err_cleanup:
@@ -1578,7 +1580,10 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_tx_stop_all_queues(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
-	if (cpsw_common_res_usage_state(cpsw) <= 1) {
+	/* Given ndev is marked as close already,
+	 * so disable shared resources if no open devices
+	 */
+	if (!cpsw_get_usage_count(cpsw)) {
 		napi_disable(&cpsw->napi_rx);
 		napi_disable(&cpsw->napi_tx);
 		cpts_unregister(cpsw->cpts);
@@ -1592,8 +1597,6 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_split_res(ndev);
 
 	pm_runtime_put_sync(cpsw->dev);
-	if (cpsw->data.dual_emac)
-		cpsw->slaves[priv->emac_port].open_stat = false;
 	return 0;
 }
 
@@ -2418,7 +2421,7 @@ static int cpsw_set_channels(struct net_device *ndev,
 		netif_dormant_off(slave->ndev);
 	}
 
-	if (cpsw_common_res_usage_state(cpsw)) {
+	if (cpsw_get_usage_count(cpsw)) {
 		ret = cpsw_fill_rx_channels(priv);
 		if (ret)
 			goto err;
@@ -2537,7 +2540,7 @@ static int cpsw_set_ringparam(struct net_device *ndev,
 		netif_dormant_off(slave->ndev);
 	}
 
-	if (cpsw_common_res_usage_state(cpsw)) {
+	if (cpsw_get_usage_count(cpsw)) {
 		cpdma_chan_split_pool(cpsw->dma);
 
 		ret = cpsw_fill_rx_channels(priv);
-- 
2.7.4
