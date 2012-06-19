From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 9/11 v2] bnx2x: Add support for ethtool -L
Date: Tue, 19 Jun 2012 20:48:30 +0300
Message-ID: <1340128112-22935-10-git-send-email-meravs@broadcom.com>
References: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3481 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439Ab2FSOla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 10:41:30 -0400
In-Reply-To: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ethtool -L/-l for setting and getting the number of RSS queues.
The 'combined' field is used as we don't support separate IRQ for Rx and Tx.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   11 ++-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   80 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   15 ++--
 5 files changed, 100 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 25d46c1..fcc3b26 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1393,6 +1393,7 @@ struct bnx2x {
 #define BNX2X_MAX_COS			3
 #define BNX2X_MAX_TX_COS		2
 	int			num_queues;
+	int			num_napi_queues;
 	int			disable_tpa;
 
 	u32			rx_mode;
@@ -1680,6 +1681,9 @@ struct bnx2x_func_init_params {
 			continue;		\
 		else
 
+#define for_each_napi_rx_queue(bp, var) \
+	for ((var) = 0; (var) < bp->num_napi_queues; (var)++)
+
 /* Skip OOO FP */
 #define for_each_tx_queue(bp, var) \
 	for ((var) = 0; (var) < BNX2X_NUM_QUEUES(bp); (var)++) \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 413b665..829befb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1360,7 +1360,7 @@ void bnx2x_free_irq(struct bnx2x *bp)
 		free_irq(bp->dev->irq, bp->dev);
 }
 
-int __devinit bnx2x_enable_msix(struct bnx2x *bp)
+int bnx2x_enable_msix(struct bnx2x *bp)
 {
 	int msix_vec = 0, i, rc, req_cnt;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 11afe5d..12dbbc4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -29,6 +29,7 @@
 extern int load_count[2][3]; /* per-path: 0-common, 1-port0, 2-port1 */
 
 extern int num_queues;
+extern int int_mode;
 
 /************************ Macros ********************************/
 #define BNX2X_PCI_FREE(x, y, size) \
@@ -495,7 +496,7 @@ void bnx2x_netif_start(struct bnx2x *bp);
  * fills msix_table, requests vectors, updates num_queues
  * according to number of available vectors.
  */
-int __devinit bnx2x_enable_msix(struct bnx2x *bp);
+int bnx2x_enable_msix(struct bnx2x *bp);
 
 /**
  * bnx2x_enable_msi - request msi mode from OS, updated internals accordingly
@@ -788,8 +789,10 @@ static inline void bnx2x_add_all_napi(struct bnx2x *bp)
 {
 	int i;
 
+	bp->num_napi_queues = bp->num_queues;
+
 	/* Add NAPI objects */
-	for_each_rx_queue(bp, i)
+	for_each_napi_rx_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
 }
@@ -798,10 +801,12 @@ static inline void bnx2x_del_all_napi(struct bnx2x *bp)
 {
 	int i;
 
-	for_each_rx_queue(bp, i)
+	for_each_napi_rx_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 }
 
+void bnx2x_set_int_mode(struct bnx2x *bp);
+
 static inline void bnx2x_disable_msi(struct bnx2x *bp)
 {
 	if (bp->flags & USING_MSIX_FLAG) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index e10b7cc..b92b3ce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2796,6 +2796,84 @@ static int bnx2x_set_rxfh_indir(struct net_device *dev, const u32 *indir)
 	return bnx2x_config_rss_eth(bp, false);
 }
 
+/**
+ * bnx2x_get_channels - gets the number of RSS queues.
+ *
+ * @dev:		net device
+ * @channels:		returns the number of max / current queues
+ */
+static void bnx2x_get_channels(struct net_device *dev,
+			       struct ethtool_channels *channels)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	channels->max_combined = BNX2X_MAX_RSS_COUNT(bp);
+	channels->combined_count = BNX2X_NUM_ETH_QUEUES(bp);
+}
+
+/**
+ * bnx2x_change_num_queues - change the number of RSS queues.
+ *
+ * @bp:			bnx2x private structure
+ *
+ * Re-configure interrupt mode to get the new number of MSI-X
+ * vectors and re-add NAPI objects.
+ */
+static void bnx2x_change_num_queues(struct bnx2x *bp, int num_rss)
+{
+	bnx2x_del_all_napi(bp);
+	bnx2x_disable_msi(bp);
+	BNX2X_NUM_QUEUES(bp) = num_rss + NON_ETH_CONTEXT_USE;
+	bnx2x_set_int_mode(bp);
+	bnx2x_add_all_napi(bp);
+}
+
+/**
+ * bnx2x_set_channels - sets the number of RSS queues.
+ *
+ * @dev:		net device
+ * @channels:		includes the number of queues requested
+ */
+static int bnx2x_set_channels(struct net_device *dev,
+			      struct ethtool_channels *channels)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+
+	DP(BNX2X_MSG_ETHTOOL,
+	   "set-channels command parameters: rx = %d, tx = %d, other = %d, combined = %d\n",
+	   channels->rx_count, channels->tx_count, channels->other_count,
+	   channels->combined_count);
+
+	/* We don't support separate rx / tx channels.
+	 * We don't allow setting 'other' channels.
+	 */
+	if (channels->rx_count || channels->tx_count || channels->other_count
+	    || (channels->combined_count == 0) ||
+	    (channels->combined_count > BNX2X_MAX_RSS_COUNT(bp))) {
+		DP(BNX2X_MSG_ETHTOOL, "command parameters not supported\n");
+		return -EINVAL;
+	}
+
+	/* Check if there was a change in the active parameters */
+	if (channels->combined_count == BNX2X_NUM_ETH_QUEUES(bp)) {
+		DP(BNX2X_MSG_ETHTOOL, "No change in active parameters\n");
+		return 0;
+	}
+
+	/* Set the requested number of queues in bp context.
+	 * Note that the actual number of queues created during load may be
+	 * less than requested if memory is low.
+	 */
+	if (unlikely(!netif_running(dev))) {
+		bnx2x_change_num_queues(bp, channels->combined_count);
+		return 0;
+	}
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_change_num_queues(bp, channels->combined_count);
+	return bnx2x_nic_load(bp, LOAD_NORMAL);
+}
+
 static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_settings		= bnx2x_get_settings,
 	.set_settings		= bnx2x_set_settings,
@@ -2827,6 +2905,8 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
 	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
 	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
+	.get_channels		= bnx2x_get_channels,
+	.set_channels		= bnx2x_set_channels,
 	.get_eee		= bnx2x_get_eee,
 	.set_eee		= bnx2x_set_eee,
 };
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7571c8c..2f87801 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -104,7 +104,7 @@ MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
 #define INT_MODE_INTx			1
 #define INT_MODE_MSI			2
-static int int_mode;
+int int_mode;
 module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode other than MSI-X "
 				"(1 INT#x; 2 MSI)");
@@ -7612,7 +7612,7 @@ int bnx2x_setup_leading(struct bnx2x *bp)
  *
  * In case of MSI-X it will also try to enable MSI-X.
  */
-static void __devinit bnx2x_set_int_mode(struct bnx2x *bp)
+void bnx2x_set_int_mode(struct bnx2x *bp)
 {
 	switch (int_mode) {
 	case INT_MODE_MSI:
@@ -7623,11 +7623,6 @@ static void __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 		BNX2X_DEV_INFO("set number of queues to 1\n");
 		break;
 	default:
-		/* Set number of queues for MSI-X mode */
-		bnx2x_set_num_queues(bp);
-
-		BNX2X_DEV_INFO("set number of queues to %d\n", bp->num_queues);
-
 		/* if we can't use MSI-X we only need one fp,
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
@@ -11883,8 +11878,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 #endif
 
+
+	/* Set bp->num_queues for MSI-X mode*/
+	bnx2x_set_num_queues(bp);
+
 	/* Configure interrupt mode: try to enable MSI-X/MSI if
-	 * needed, set bp->num_queues appropriately.
+	 * needed.
 	 */
 	bnx2x_set_int_mode(bp);
 
-- 
1.7.10
