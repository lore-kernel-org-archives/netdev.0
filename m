From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbe: Refactor set_num_queues() and
	cache_ring_register()
Date: Wed, 04 Feb 2009 17:39:02 -0800
Message-ID: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:42982 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932497AbZBEBjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:39:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The current code to determine the number of queues the device will want
on driver initialization is ugly and difficult to maintain.  It also
doesn't allow for easy expansion for future features or future hardware.
This patch refactors these routines, and make them easier to deal with.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  222 +++++++++++++++++++++-------------------
 1 files changed, 118 insertions(+), 104 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ed8d141..d396c6e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2314,68 +2314,61 @@ static void ixgbe_reset_task(struct work_struct *work)
 	ixgbe_reinit_locked(adapter);
 }
 
-static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+#ifdef CONFIG_IXGBE_DCB
+static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
-	int nrq = 1, ntq = 1;
-	int feature_mask = 0, rss_i, rss_m;
-	int dcb_i, dcb_m;
+	bool ret = false;
 
-	/* Number of supported queues */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		dcb_i = adapter->ring_feature[RING_F_DCB].indices;
-		dcb_m = 0;
-		rss_i = adapter->ring_feature[RING_F_RSS].indices;
-		rss_m = 0;
-		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
-		feature_mask |= IXGBE_FLAG_DCB_ENABLED;
-
-		switch (adapter->flags & feature_mask) {
-		case (IXGBE_FLAG_RSS_ENABLED | IXGBE_FLAG_DCB_ENABLED):
-			dcb_m = 0x7 << 3;
-			rss_i = min(8, rss_i);
-			rss_m = 0x7;
-			nrq = dcb_i * rss_i;
-			ntq = min(MAX_TX_QUEUES, dcb_i * rss_i);
-			break;
-		case (IXGBE_FLAG_DCB_ENABLED):
-			dcb_m = 0x7 << 3;
-			nrq = dcb_i;
-			ntq = dcb_i;
-			break;
-		case (IXGBE_FLAG_RSS_ENABLED):
-			rss_m = 0xF;
-			nrq = rss_i;
-			ntq = rss_i;
-			break;
-		case 0:
-		default:
-			dcb_i = 0;
-			dcb_m = 0;
-			rss_i = 0;
-			rss_m = 0;
-			nrq = 1;
-			ntq = 1;
-			break;
-		}
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		adapter->ring_feature[RING_F_DCB].mask = 0x7 << 3;
+		adapter->num_rx_queues =
+		                      adapter->ring_feature[RING_F_DCB].indices;
+		adapter->num_tx_queues =
+		                      adapter->ring_feature[RING_F_DCB].indices;
+		ret = true;
+	} else {
+		adapter->ring_feature[RING_F_DCB].mask = 0;
+		adapter->ring_feature[RING_F_DCB].indices = 0;
+		ret = false;
+	}
 
-		/* Sanity check, we should never have zero queues */
-		nrq = (nrq ?:1);
-		ntq = (ntq ?:1);
+	return ret;
+}
+#endif
 
-		adapter->ring_feature[RING_F_DCB].indices = dcb_i;
-		adapter->ring_feature[RING_F_DCB].mask = dcb_m;
-		adapter->ring_feature[RING_F_RSS].indices = rss_i;
-		adapter->ring_feature[RING_F_RSS].mask = rss_m;
-		break;
-	default:
-		nrq = 1;
-		ntq = 1;
-		break;
+static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
+{
+	bool ret = false;
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+		adapter->ring_feature[RING_F_RSS].mask = 0xF;
+		adapter->num_rx_queues =
+		                      adapter->ring_feature[RING_F_RSS].indices;
+		adapter->num_tx_queues =
+		                      adapter->ring_feature[RING_F_RSS].indices;
+		ret = true;
+	} else {
+		adapter->ring_feature[RING_F_RSS].mask = 0;
+		adapter->ring_feature[RING_F_RSS].indices = 0;
+		ret = false;
 	}
 
-	adapter->num_rx_queues = nrq;
-	adapter->num_tx_queues = ntq;
+	return ret;
+}
+
+static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+{
+	/* Start with base case */
+	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 1;
+
+#ifdef CONFIG_IXGBE_DCB
+	if (ixgbe_set_dcb_queues(adapter))
+		return;
+
+#endif
+	if (ixgbe_set_rss_queues(adapter))
+		return;
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
@@ -2432,66 +2425,87 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 }
 
 /**
- * ixgbe_cache_ring_register - Descriptor ring to register mapping
+ * ixgbe_cache_ring_rss - Descriptor ring to register mapping for RSS
  * @adapter: board private structure to initialize
  *
- * Once we know the feature-set enabled for the device, we'll cache
- * the register offset the descriptor ring is assigned to.
+ * Cache the descriptor ring offsets for RSS to the assigned rings.
+ *
  **/
-static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
+static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 {
-	int feature_mask = 0, rss_i;
-	int i, txr_idx, rxr_idx;
-	int dcb_i;
+	int i;
+	bool ret = false;
 
-	/* Number of supported queues */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		dcb_i = adapter->ring_feature[RING_F_DCB].indices;
-		rss_i = adapter->ring_feature[RING_F_RSS].indices;
-		txr_idx = 0;
-		rxr_idx = 0;
-		feature_mask |= IXGBE_FLAG_DCB_ENABLED;
-		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
-		switch (adapter->flags & feature_mask) {
-		case (IXGBE_FLAG_RSS_ENABLED | IXGBE_FLAG_DCB_ENABLED):
-			for (i = 0; i < dcb_i; i++) {
-				int j;
-				/* Rx first */
-				for (j = 0; j < adapter->num_rx_queues; j++) {
-					adapter->rx_ring[rxr_idx].reg_idx =
-						i << 3 | j;
-					rxr_idx++;
-				}
-				/* Tx now */
-				for (j = 0; j < adapter->num_tx_queues; j++) {
-					adapter->tx_ring[txr_idx].reg_idx =
-						i << 2 | (j >> 1);
-					if (j & 1)
-						txr_idx++;
-				}
-			}
-		case (IXGBE_FLAG_DCB_ENABLED):
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].reg_idx = i;
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			adapter->tx_ring[i].reg_idx = i;
+		ret = true;
+	} else {
+		ret = false;
+	}
+
+	return ret;
+}
+
+#ifdef CONFIG_IXGBE_DCB
+/**
+ * ixgbe_cache_ring_dcb - Descriptor ring to register mapping for DCB
+ * @adapter: board private structure to initialize
+ *
+ * Cache the descriptor ring offsets for DCB to the assigned rings.
+ *
+ **/
+static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
+{
+	int i;
+	bool ret = false;
+	int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
 			/* the number of queues is assumed to be symmetric */
 			for (i = 0; i < dcb_i; i++) {
 				adapter->rx_ring[i].reg_idx = i << 3;
 				adapter->tx_ring[i].reg_idx = i << 2;
 			}
-			break;
-		case (IXGBE_FLAG_RSS_ENABLED):
-			for (i = 0; i < adapter->num_rx_queues; i++)
-				adapter->rx_ring[i].reg_idx = i;
-			for (i = 0; i < adapter->num_tx_queues; i++)
-				adapter->tx_ring[i].reg_idx = i;
-			break;
-		case 0:
-		default:
-			break;
+			ret = true;
+		} else {
+			ret = false;
 		}
-		break;
-	default:
-		break;
+	} else {
+		ret = false;
 	}
+
+	return ret;
+}
+#endif
+
+/**
+ * ixgbe_cache_ring_register - Descriptor ring to register mapping
+ * @adapter: board private structure to initialize
+ *
+ * Once we know the feature-set enabled for the device, we'll cache
+ * the register offset the descriptor ring is assigned to.
+ *
+ * Note, the order the various feature calls is important.  It must start with
+ * the "most" features enabled at the same time, then trickle down to the
+ * least amount of features turned on at once.
+ **/
+static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
+{
+	/* start with default case */
+	adapter->rx_ring[0].reg_idx = 0;
+	adapter->tx_ring[0].reg_idx = 0;
+
+#ifdef CONFIG_IXGBE_DCB
+	if (ixgbe_cache_ring_dcb(adapter))
+		return;
+
+#endif
+	if (ixgbe_cache_ring_rss(adapter))
+		return;
 }
 
 /**

