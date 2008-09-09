From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 20/24] ixgbe: move set_num_queues and call it after
	msix failure
Date: Mon, 08 Sep 2008 21:48:26 -0700
Message-ID: <20080909044826.18904.61506.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:15187 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbYIIEs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:28 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1350307waf.23
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:27 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is partial preparation for a future patch which will extend
ixgbe_set_num_queues

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    2 -
 drivers/net/ixgbe/ixgbe_main.c    |   88 +++++++++++++++++++------------------
 2 files changed, 45 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index ff4fac3..020b0c7 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -947,7 +947,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 }
 
 
-static struct ethtool_ops ixgbe_ethtool_ops = {
+static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
 	.get_drvinfo            = ixgbe_get_drvinfo,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a9ef7b8..8916f07 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2333,6 +2333,46 @@ static void ixgbe_reset_task(struct work_struct *work)
 	ixgbe_reinit_locked(adapter);
 }
 
+static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+{
+	int nrq = 1, ntq = 1;
+	int feature_mask = 0, rss_i, rss_m;
+
+	/* Number of supported queues */
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_82598EB:
+		rss_i = adapter->ring_feature[RING_F_RSS].indices;
+		rss_m = 0;
+		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
+
+		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_RSS_ENABLED):
+			rss_m = 0xF;
+			nrq = rss_i;
+			ntq = rss_i;
+			break;
+		case 0:
+		default:
+			rss_i = 0;
+			rss_m = 0;
+			nrq = 1;
+			ntq = 1;
+			break;
+		}
+
+		adapter->ring_feature[RING_F_RSS].indices = rss_i;
+		adapter->ring_feature[RING_F_RSS].mask = rss_m;
+		break;
+	default:
+		nrq = 1;
+		ntq = 1;
+		break;
+	}
+
+	adapter->num_rx_queues = nrq;
+	adapter->num_tx_queues = ntq;
+}
+
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 				       int vectors)
 {
@@ -2372,54 +2412,13 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
-		adapter->num_tx_queues = 1;
-		adapter->num_rx_queues = 1;
+		ixgbe_set_num_queues(adapter);
 	} else {
 		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
 		adapter->num_msix_vectors = vectors;
 	}
 }
 
-static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
-{
-	int nrq, ntq;
-	int feature_mask = 0, rss_i, rss_m;
-
-	/* Number of supported queues */
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82598EB:
-		rss_i = adapter->ring_feature[RING_F_RSS].indices;
-		rss_m = 0;
-		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
-
-		switch (adapter->flags & feature_mask) {
-		case (IXGBE_FLAG_RSS_ENABLED):
-			rss_m = 0xF;
-			nrq = rss_i;
-			ntq = rss_i;
-			break;
-		case 0:
-		default:
-			rss_i = 0;
-			rss_m = 0;
-			nrq = 1;
-			ntq = 1;
-			break;
-		}
-
-		adapter->ring_feature[RING_F_RSS].indices = rss_i;
-		adapter->ring_feature[RING_F_RSS].mask = rss_m;
-		break;
-	default:
-		nrq = 1;
-		ntq = 1;
-		break;
-	}
-
-	adapter->num_rx_queues = nrq;
-	adapter->num_tx_queues = ntq;
-}
-
 /**
  * ixgbe_cache_ring_register - Descriptor ring to register mapping
  * @adapter: board private structure to initialize
@@ -2482,11 +2481,12 @@ static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 		goto err_rx_ring_allocation;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i].count = IXGBE_DEFAULT_TXD;
+		adapter->tx_ring[i].count = adapter->tx_ring_count;
 		adapter->tx_ring[i].queue_index = i;
 	}
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].count = IXGBE_DEFAULT_RXD;
+		adapter->rx_ring[i].count = adapter->rx_ring_count;
 		adapter->rx_ring[i].queue_index = i;
 	}
 

