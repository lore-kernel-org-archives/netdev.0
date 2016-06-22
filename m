From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 2/5] be2net: support asymmetric rx/tx queue counts
Date: Wed, 22 Jun 2016 08:54:54 -0400
Message-ID: <1466600097-1641-3-git-send-email-sathya.perla@broadcom.com>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752366AbcFVMzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:19 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be2net so far supported creation of RX/TX queues only in pairs.
On configs where rx and tx queue counts are different, creation of only
the lesser number of queues has been supported.

This patch now allows a combination of RX/TX-only channels along with
combined channels. N TX-queues and M RX-queues can be created with the
following cmds:
ethtool -L ethX combined N rx M-N  (when N < M)
ethtool -L ethX combined M tx N-M (when M < N)

Setting both RX-only and TX-only channels is still not supported.
It is mandatory to create atleast one combined channel.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h         | 32 ++++++++++++++++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 29 ++++++++++++++++----
 drivers/net/ethernet/emulex/benet/be_main.c    | 38 ++++++++++++++++----------
 3 files changed, 74 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f8040ef..096cb1f5 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -526,7 +526,8 @@ struct be_adapter {
 	spinlock_t mcc_lock;	/* For serializing mcc cmds to BE card */
 	spinlock_t mcc_cq_lock;
 
-	u16 cfg_num_qs;		/* configured via set-channels */
+	u16 cfg_num_rx_irqs;		/* configured via set-channels */
+	u16 cfg_num_tx_irqs;		/* configured via set-channels */
 	u16 num_evt_qs;
 	u16 num_msix_vec;
 	struct be_eq_obj eq_obj[MAX_EVT_QS];
@@ -652,14 +653,35 @@ struct be_adapter {
 #define be_if_cap_flags(adapter)	(adapter->res.if_cap_flags)
 #define be_max_pf_pool_rss_tables(adapter)	\
 				(adapter->pool_res.max_rss_tables)
+/* Max irqs avaialble for NIC */
+#define be_max_irqs(adapter)		\
+			(min_t(u16, be_max_nic_eqs(adapter), num_online_cpus()))
 
-static inline u16 be_max_qs(struct be_adapter *adapter)
+/* Max irqs *needed* for RX queues */
+static inline u16 be_max_rx_irqs(struct be_adapter *adapter)
 {
-	/* If no RSS, need atleast the one def RXQ */
+	/* If no RSS, need atleast one irq for def-RXQ */
 	u16 num = max_t(u16, be_max_rss(adapter), 1);
 
-	num = min(num, be_max_nic_eqs(adapter));
-	return min_t(u16, num, num_online_cpus());
+	return min_t(u16, num, be_max_irqs(adapter));
+}
+
+/* Max irqs *needed* for TX queues */
+static inline u16 be_max_tx_irqs(struct be_adapter *adapter)
+{
+	return min_t(u16, be_max_txqs(adapter), be_max_irqs(adapter));
+}
+
+/* Max irqs *needed* for combined queues */
+static inline u16 be_max_qp_irqs(struct be_adapter *adapter)
+{
+	return min(be_max_tx_irqs(adapter), be_max_rx_irqs(adapter));
+}
+
+/* Max irqs *needed* for RX and TX queues together */
+static inline u16 be_max_any_irqs(struct be_adapter *adapter)
+{
+	return max(be_max_tx_irqs(adapter), be_max_rx_irqs(adapter));
 }
 
 /* Is BE in pvid_tagging mode */
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index c569cd7..71940b9 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -1196,9 +1196,17 @@ static void be_get_channels(struct net_device *netdev,
 			    struct ethtool_channels *ch)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	u16 num_rx_irqs = max_t(u16, adapter->num_rss_qs, 1);
 
-	ch->combined_count = adapter->num_evt_qs;
-	ch->max_combined = be_max_qs(adapter);
+	/* num_tx_qs is always same as the number of irqs used for TX */
+	ch->combined_count = min(adapter->num_tx_qs, num_rx_irqs);
+	ch->rx_count = num_rx_irqs - ch->combined_count;
+	ch->tx_count = adapter->num_tx_qs - ch->combined_count;
+
+	ch->max_combined = be_max_qp_irqs(adapter);
+	/* The user must create atleast one combined channel */
+	ch->max_rx = be_max_rx_irqs(adapter) - 1;
+	ch->max_tx = be_max_tx_irqs(adapter) - 1;
 }
 
 static int be_set_channels(struct net_device  *netdev,
@@ -1207,11 +1215,22 @@ static int be_set_channels(struct net_device  *netdev,
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status;
 
-	if (ch->rx_count || ch->tx_count || ch->other_count ||
-	    !ch->combined_count || ch->combined_count > be_max_qs(adapter))
+	/* we support either only combined channels or a combination of
+	 * combined and either RX-only or TX-only channels.
+	 */
+	if (ch->other_count || !ch->combined_count ||
+	    (ch->rx_count && ch->tx_count))
+		return -EINVAL;
+
+	if (ch->combined_count > be_max_qp_irqs(adapter) ||
+	    (ch->rx_count &&
+	     (ch->rx_count + ch->combined_count) > be_max_rx_irqs(adapter)) ||
+	    (ch->tx_count &&
+	     (ch->tx_count + ch->combined_count) > be_max_tx_irqs(adapter)))
 		return -EINVAL;
 
-	adapter->cfg_num_qs = ch->combined_count;
+	adapter->cfg_num_rx_irqs = ch->combined_count + ch->rx_count;
+	adapter->cfg_num_tx_irqs = ch->combined_count + ch->tx_count;
 
 	status = be_update_queues(adapter);
 	return be_cmd_status(status);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c67830f..a654c12 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2620,8 +2620,10 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 	struct be_aic_obj *aic;
 	int i, rc;
 
+	/* need enough EQs to service both RX and TX queues */
 	adapter->num_evt_qs = min_t(u16, num_irqs(adapter),
-				    adapter->cfg_num_qs);
+				    max(adapter->cfg_num_rx_irqs,
+					adapter->cfg_num_tx_irqs));
 
 	for_all_evt_queues(adapter, eqo, i) {
 		int numa_node = dev_to_node(&adapter->pdev->dev);
@@ -2726,7 +2728,7 @@ static int be_tx_qs_create(struct be_adapter *adapter)
 	struct be_eq_obj *eqo;
 	int status, i;
 
-	adapter->num_tx_qs = min(adapter->num_evt_qs, be_max_txqs(adapter));
+	adapter->num_tx_qs = min(adapter->num_evt_qs, adapter->cfg_num_tx_irqs);
 
 	for_all_tx_queues(adapter, txo, i) {
 		cq = &txo->cq;
@@ -2784,11 +2786,11 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 	struct be_rx_obj *rxo;
 	int rc, i;
 
-	/* We can create as many RSS rings as there are EQs. */
-	adapter->num_rss_qs = adapter->num_evt_qs;
+	adapter->num_rss_qs =
+			min(adapter->num_evt_qs, adapter->cfg_num_rx_irqs);
 
 	/* We'll use RSS only if atleast 2 RSS rings are supported. */
-	if (adapter->num_rss_qs <= 1)
+	if (adapter->num_rss_qs < 2)
 		adapter->num_rss_qs = 0;
 
 	adapter->num_rx_qs = adapter->num_rss_qs + adapter->need_def_rxq;
@@ -3249,18 +3251,22 @@ static void be_msix_disable(struct be_adapter *adapter)
 
 static int be_msix_enable(struct be_adapter *adapter)
 {
-	int i, num_vec;
+	unsigned int i, num_vec, max_roce_eqs;
 	struct device *dev = &adapter->pdev->dev;
 
 	/* If RoCE is supported, program the max number of vectors that
 	 * could be used for NIC and RoCE, else, just program the number
 	 * we'll use initially.
 	 */
-	if (be_roce_supported(adapter))
-		num_vec = min_t(int, be_max_func_eqs(adapter),
-				2 * num_online_cpus());
-	else
-		num_vec = adapter->cfg_num_qs;
+	if (be_roce_supported(adapter)) {
+		max_roce_eqs =
+			be_max_func_eqs(adapter) - be_max_nic_eqs(adapter);
+		max_roce_eqs = min(max_roce_eqs, num_online_cpus());
+		num_vec = be_max_any_irqs(adapter) + max_roce_eqs;
+	} else {
+		num_vec = max(adapter->cfg_num_rx_irqs,
+			      adapter->cfg_num_tx_irqs);
+	}
 
 	for (i = 0; i < num_vec; i++)
 		adapter->msix_entries[i].entry = i;
@@ -4255,9 +4261,11 @@ static int be_get_resources(struct be_adapter *adapter)
 		 be_max_uc(adapter), be_max_mc(adapter),
 		 be_max_vlans(adapter));
 
-	/* Sanitize cfg_num_qs based on HW and platform limits */
-	adapter->cfg_num_qs = min_t(u16, netif_get_num_default_rss_queues(),
-				    be_max_qs(adapter));
+	/* Ensure RX and TX queues are created in pairs at init time */
+	adapter->cfg_num_rx_irqs =
+				min_t(u16, netif_get_num_default_rss_queues(),
+				      be_max_qp_irqs(adapter));
+	adapter->cfg_num_tx_irqs = adapter->cfg_num_rx_irqs;
 	return 0;
 }
 
@@ -4370,7 +4378,7 @@ static int be_if_create(struct be_adapter *adapter)
 	u32 cap_flags = be_if_cap_flags(adapter);
 	int status;
 
-	if (adapter->cfg_num_qs == 1)
+	if (adapter->cfg_num_rx_irqs == 1)
 		cap_flags &= ~(BE_IF_FLAGS_DEFQ_RSS | BE_IF_FLAGS_RSS);
 
 	en_flags &= cap_flags;
-- 
2.4.1
