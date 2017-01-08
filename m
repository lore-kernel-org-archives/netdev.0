From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 3/4] net: ethernet: ti: cpsw: don't duplicate ndev_running
Date: Sun,  8 Jan 2017 18:41:02 +0200
Message-ID: <1483893663-15673-4-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to create additional vars to identify if interface is running.
So simplify code by removing redundant var and checking usage counter
instead.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 40d7fc9..daae87f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -357,7 +357,6 @@ struct cpsw_slave {
 	struct phy_device		*phy;
 	struct net_device		*ndev;
 	u32				port_vlan;
-	u32				open_stat;
 };
 
 static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
@@ -1241,7 +1240,7 @@ static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
 	u32 usage_count = 0;
 
 	for (i = 0; i < cpsw->data.slaves; i++)
-		if (cpsw->slaves[i].open_stat)
+		if (netif_running(cpsw->slaves[i].ndev))
 			usage_count++;
 
 	return usage_count;
@@ -1502,7 +1501,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 CPSW_RTL_VERSION(reg));
 
 	/* initialize host and slave ports */
-	if (!cpsw_common_res_usage_state(cpsw))
+	if (cpsw_common_res_usage_state(cpsw) < 2)
 		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
@@ -1513,7 +1512,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
-	if (!cpsw_common_res_usage_state(cpsw)) {
+	if (cpsw_common_res_usage_state(cpsw) < 2) {
 		/* disable priority elevation */
 		__raw_writel(0, &cpsw->regs->ptype);
 
@@ -1556,9 +1555,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
 
-	if (cpsw->data.dual_emac)
-		cpsw->slaves[priv->emac_port].open_stat = true;
-
 	return 0;
 
 err_cleanup:
@@ -1578,7 +1574,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_tx_stop_all_queues(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
-	if (cpsw_common_res_usage_state(cpsw) <= 1) {
+	if (!cpsw_common_res_usage_state(cpsw)) {
 		napi_disable(&cpsw->napi_rx);
 		napi_disable(&cpsw->napi_tx);
 		cpts_unregister(cpsw->cpts);
@@ -1592,8 +1588,6 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 		cpsw_split_res(ndev);
 
 	pm_runtime_put_sync(cpsw->dev);
-	if (cpsw->data.dual_emac)
-		cpsw->slaves[priv->emac_port].open_stat = false;
 	return 0;
 }
 
-- 
2.7.4
