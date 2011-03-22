From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 1/5] be2net: refactor code that decides adapter->num_rx_queues
Date: Tue, 22 Mar 2011 12:19:25 +0530
Message-ID: <25bff78f-c934-4250-88c8-d24965a73c70@exht1.ad.emulex.com>
References: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5034 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754232Ab1CVGuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:50:22 -0400
In-Reply-To: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code has been refactored to not set num_rx_qs inside be_enable_msix().
num_rx_qs is now set at the time of queue creation based on the number of
available msix vectors.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |    8 +++--
 drivers/net/benet/be_main.c |   66 ++++++++++++++++++++++---------------------
 2 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index f803c58..3937bca 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -84,7 +84,8 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MCC_CQ_LEN		256
 
 #define MAX_RSS_QS		4	/* BE limit is 4 queues/port */
-#define BE_MAX_MSIX_VECTORS	(MAX_RSS_QS + 1 + 1)/* RSS qs + 1 def Rx + Tx */
+#define MAX_RX_QS		(MAX_RSS_QS + 1) /* RSS qs + 1 def Rx */
+#define BE_MAX_MSIX_VECTORS	(MAX_RX_QS + 1)/* RX + TX */
 #define BE_NAPI_WEIGHT		64
 #define MAX_RX_POST 		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
@@ -276,7 +277,7 @@ struct be_adapter {
 	spinlock_t mcc_cq_lock;
 
 	struct msix_entry msix_entries[BE_MAX_MSIX_VECTORS];
-	bool msix_enabled;
+	u32 num_msix_vec;
 	bool isr_registered;
 
 	/* TX Rings */
@@ -287,7 +288,7 @@ struct be_adapter {
 	u32 cache_line_break[8];
 
 	/* Rx rings */
-	struct be_rx_obj rx_obj[MAX_RSS_QS + 1]; /* one default non-rss Q */
+	struct be_rx_obj rx_obj[MAX_RX_QS];
 	u32 num_rx_qs;
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
@@ -351,6 +352,7 @@ struct be_adapter {
 
 extern const struct ethtool_ops be_ethtool_ops;
 
+#define msix_enabled(adapter)		(adapter->num_msix_vec > 0)
 #define tx_stats(adapter)		(&adapter->tx_stats)
 #define rx_stats(rxo)			(&rxo->stats)
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a71163f..7a5d6a3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1567,12 +1567,31 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 	}
 }
 
+static u32 be_num_rxqs_want(struct be_adapter *adapter)
+{
+	if (multi_rxq && (adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
+		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
+		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
+	} else {
+		dev_warn(&adapter->pdev->dev,
+			"No support for multiple RX queues\n");
+		return 1;
+	}
+}
+
 static int be_rx_queues_create(struct be_adapter *adapter)
 {
 	struct be_queue_info *eq, *q, *cq;
 	struct be_rx_obj *rxo;
 	int rc, i;
 
+	adapter->num_rx_qs = min(be_num_rxqs_want(adapter),
+				msix_enabled(adapter) ?
+					adapter->num_msix_vec - 1 : 1);
+	if (adapter->num_rx_qs != MAX_RX_QS)
+		dev_warn(&adapter->pdev->dev,
+			"Can create only %d RX queues", adapter->num_rx_qs);
+
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	for_all_rx_queues(adapter, rxo, i) {
 		rxo->adapter = adapter;
@@ -1878,51 +1897,35 @@ reschedule:
 
 static void be_msix_disable(struct be_adapter *adapter)
 {
-	if (adapter->msix_enabled) {
+	if (msix_enabled(adapter)) {
 		pci_disable_msix(adapter->pdev);
-		adapter->msix_enabled = false;
-	}
-}
-
-static int be_num_rxqs_get(struct be_adapter *adapter)
-{
-	if (multi_rxq && (adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
-		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
-		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
-	} else {
-		dev_warn(&adapter->pdev->dev,
-			"No support for multiple RX queues\n");
-		return 1;
+		adapter->num_msix_vec = 0;
 	}
 }
 
 static void be_msix_enable(struct be_adapter *adapter)
 {
 #define BE_MIN_MSIX_VECTORS	(1 + 1) /* Rx + Tx */
-	int i, status;
+	int i, status, num_vec;
 
-	adapter->num_rx_qs = be_num_rxqs_get(adapter);
+	num_vec = be_num_rxqs_want(adapter) + 1;
 
-	for (i = 0; i < (adapter->num_rx_qs + 1); i++)
+	for (i = 0; i < num_vec; i++)
 		adapter->msix_entries[i].entry = i;
 
-	status = pci_enable_msix(adapter->pdev, adapter->msix_entries,
-			adapter->num_rx_qs + 1);
+	status = pci_enable_msix(adapter->pdev, adapter->msix_entries, num_vec);
 	if (status == 0) {
 		goto done;
 	} else if (status >= BE_MIN_MSIX_VECTORS) {
+		num_vec = status;
 		if (pci_enable_msix(adapter->pdev, adapter->msix_entries,
-				status) == 0) {
-			adapter->num_rx_qs = status - 1;
-			dev_warn(&adapter->pdev->dev,
-				"Could alloc only %d MSIx vectors. "
-				"Using %d RX Qs\n", status, adapter->num_rx_qs);
+				num_vec) == 0)
 			goto done;
-		}
 	}
 	return;
 done:
-	adapter->msix_enabled = true;
+	adapter->num_msix_vec = num_vec;
+	return;
 }
 
 static void be_sriov_enable(struct be_adapter *adapter)
@@ -2003,8 +2006,7 @@ err_msix:
 err:
 	dev_warn(&adapter->pdev->dev,
 		"MSIX Request IRQ failed - err %d\n", status);
-	pci_disable_msix(adapter->pdev);
-	adapter->msix_enabled = false;
+	be_msix_disable(adapter);
 	return status;
 }
 
@@ -2013,7 +2015,7 @@ static int be_irq_register(struct be_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int status;
 
-	if (adapter->msix_enabled) {
+	if (msix_enabled(adapter)) {
 		status = be_msix_register(adapter);
 		if (status == 0)
 			goto done;
@@ -2046,7 +2048,7 @@ static void be_irq_unregister(struct be_adapter *adapter)
 		return;
 
 	/* INTx */
-	if (!adapter->msix_enabled) {
+	if (!msix_enabled(adapter)) {
 		free_irq(netdev->irq, adapter);
 		goto done;
 	}
@@ -2088,7 +2090,7 @@ static int be_close(struct net_device *netdev)
 			 be_cq_notify(adapter, rxo->cq.id, false, 0);
 	}
 
-	if (adapter->msix_enabled) {
+	if (msix_enabled(adapter)) {
 		vec = be_msix_vec_get(adapter, tx_eq);
 		synchronize_irq(vec);
 
@@ -2261,7 +2263,7 @@ static int be_setup(struct be_adapter *adapter)
 				BE_IF_FLAGS_PASS_L3L4_ERRORS;
 		en_flags |= BE_IF_FLAGS_PASS_L3L4_ERRORS;
 
-		if (be_multi_rxq(adapter)) {
+		if (adapter->function_caps & BE_FUNCTION_CAPS_RSS) {
 			cap_flags |= BE_IF_FLAGS_RSS;
 			en_flags |= BE_IF_FLAGS_RSS;
 		}
-- 
1.6.5.2

