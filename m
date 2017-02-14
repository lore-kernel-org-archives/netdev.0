From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: use var instead of func for usage count
Date: Tue, 14 Feb 2017 16:02:36 +0200
Message-ID: <1487080956-28661-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage count function is based on ndev_running flag that is
updated before calling ndo_open/close, but if ndo is called in
another place, as with suspend/resume, the counter is not changed,
that breaks sus/resume. For common resource no difference which
device is using it, does matter only device count. So, replace
usage count function on var and inc and dec it in ndo_open/close.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/cpsw.c | 42 ++++++++++++------------------------------
 1 file changed, 12 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 503fa8a..e86f226 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -399,6 +399,7 @@ struct cpsw_common {
 	struct cpts			*cpts;
 	int				rx_ch_num, tx_ch_num;
 	int				speed;
+	int				usage_count;
 };
 
 struct cpsw_priv {
@@ -671,18 +672,6 @@ static void cpsw_intr_disable(struct cpsw_common *cpsw)
 	return;
 }
 
-static int cpsw_get_usage_count(struct cpsw_common *cpsw)
-{
-	u32 i;
-	u32 usage_count = 0;
-
-	for (i = 0; i < cpsw->data.slaves; i++)
-		if (cpsw->slaves[i].ndev && netif_running(cpsw->slaves[i].ndev))
-			usage_count++;
-
-	return usage_count;
-}
-
 static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct netdev_queue	*txq;
@@ -716,8 +705,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
 		/* In dual emac mode check for all interfaces */
-		if (cpsw->data.dual_emac &&
-		    cpsw_get_usage_count(cpsw) &&
+		if (cpsw->data.dual_emac && cpsw->usage_count &&
 		    (status >= 0)) {
 			/* The packet received is for the interface which
 			 * is already down and the other interface is up
@@ -1492,11 +1480,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
 		 CPSW_RTL_VERSION(reg));
 
-	/* Initialize host and slave ports.
-	 * Given ndev is marked as opened already, so init port only if 1 ndev
-	 * is opened
-	 */
-	if (cpsw_get_usage_count(cpsw) < 2)
+	/* Initialize host and slave ports */
+	if (!cpsw->usage_count)
 		cpsw_init_host_port(priv);
 	for_each_slave(priv, cpsw_slave_open, priv);
 
@@ -1507,10 +1492,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 		cpsw_ale_add_vlan(cpsw->ale, cpsw->data.default_vlan,
 				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
 
-	/* Given ndev is marked as opened already, so if more ndev
-	 * are opened - no need to init shared resources.
-	 */
-	if (cpsw_get_usage_count(cpsw) < 2) {
+	/* initialize shared resources for every ndev */
+	if (!cpsw->usage_count) {
 		/* disable priority elevation */
 		__raw_writel(0, &cpsw->regs->ptype);
 
@@ -1552,6 +1535,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 
 	cpdma_ctlr_start(cpsw->dma);
 	cpsw_intr_enable(cpsw);
+	cpsw->usage_count++;
 
 	return 0;
 
@@ -1572,10 +1556,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_tx_stop_all_queues(priv->ndev);
 	netif_carrier_off(priv->ndev);
 
-	/* Given ndev is marked as close already,
-	 * so disable shared resources if no open devices
-	 */
-	if (!cpsw_get_usage_count(cpsw)) {
+	if (cpsw->usage_count <= 1) {
 		napi_disable(&cpsw->napi_rx);
 		napi_disable(&cpsw->napi_tx);
 		cpts_unregister(cpsw->cpts);
@@ -1588,6 +1569,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	if (cpsw_need_resplit(cpsw))
 		cpsw_split_res(ndev);
 
+	cpsw->usage_count--;
 	pm_runtime_put_sync(cpsw->dev);
 	return 0;
 }
@@ -2393,7 +2375,7 @@ static int cpsw_resume_data_pass(struct net_device *ndev)
 			netif_dormant_off(slave->ndev);
 
 	/* After this receive is started */
-	if (cpsw_get_usage_count(cpsw)) {
+	if (cpsw->usage_count) {
 		ret = cpsw_fill_rx_channels(priv);
 		if (ret)
 			return ret;
@@ -2447,7 +2429,7 @@ static int cpsw_set_channels(struct net_device *ndev,
 		}
 	}
 
-	if (cpsw_get_usage_count(cpsw))
+	if (cpsw->usage_count)
 		cpsw_split_res(ndev);
 
 	ret = cpsw_resume_data_pass(ndev);
@@ -2529,7 +2511,7 @@ static int cpsw_set_ringparam(struct net_device *ndev,
 
 	cpdma_set_num_rx_descs(cpsw->dma, ering->rx_pending);
 
-	if (cpsw_get_usage_count(cpsw))
+	if (cpsw->usage_count)
 		cpdma_chan_split_pool(cpsw->dma);
 
 	ret = cpsw_resume_data_pass(ndev);
-- 
2.7.4
