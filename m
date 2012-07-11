From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] ixgbe: Merge RSS and flow director ring register caching and configuration
Date: Wed, 11 Jul 2012 02:09:29 -0700
Message-ID: <1341997769-22034-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11700 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab2GKJJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 05:09:40 -0400
In-Reply-To: <1341997769-22034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There are really only 3 modes that can control the number of queues.  Those
are RSS, DCB, and VMDq/SR-IOV.  Currently we have things much more broken
up than they need to be for how we are configuring the rings.  In order to
try and straiten some of this out I am going to start merging similar
functionality into single functions.  To start with I am merging the Flow
Director ring configuration into the RSS ring configuration since Flow
Director cannot function with DCB or SR-IOV.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |   98 +++++++-------------------
 1 file changed, 24 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 47e54e8..83eadd0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -138,30 +138,6 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 }
 #endif
 
-/**
- * ixgbe_cache_ring_fdir - Descriptor ring to register mapping for Flow Director
- * @adapter: board private structure to initialize
- *
- * Cache the descriptor ring offsets for Flow Director to the assigned rings.
- *
- **/
-static inline bool ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
-{
-	int i;
-	bool ret = false;
-
-	if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
-	    (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)) {
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i]->reg_idx = i;
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i]->reg_idx = i;
-		ret = true;
-	}
-
-	return ret;
-}
-
 #ifdef IXGBE_FCOE
 /**
  * ixgbe_cache_ring_fcoe - Descriptor ring to register mapping for the FCoE
@@ -180,10 +156,7 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 		return false;
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
-			ixgbe_cache_ring_fdir(adapter);
-		else
-			ixgbe_cache_ring_rss(adapter);
+		ixgbe_cache_ring_rss(adapter);
 
 		fcoe_rx_i = f->offset;
 		fcoe_tx_i = f->offset;
@@ -244,9 +217,6 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 		return;
 #endif /* IXGBE_FCOE */
 
-	if (ixgbe_cache_ring_fdir(adapter))
-		return;
-
 	if (ixgbe_cache_ring_rss(adapter))
 		return;
 }
@@ -272,53 +242,39 @@ static inline bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
  * to allocate one Rx queue per CPU, and if available, one Tx queue per CPU.
  *
  **/
-static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
+static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 {
-	bool ret = false;
-	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_RSS];
+	struct ixgbe_ring_feature *f;
+	u16 rss_i;
 
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		f->mask = 0xF;
-		adapter->num_rx_queues = f->indices;
-		adapter->num_tx_queues = f->indices;
-		ret = true;
+	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
+		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+		return false;
 	}
 
-	return ret;
-}
+	/* set mask for 16 queue limit of RSS */
+	f = &adapter->ring_feature[RING_F_RSS];
+	rss_i = f->limit;
 
-/**
- * ixgbe_set_fdir_queues - Allocate queues for Flow Director
- * @adapter: board private structure to initialize
- *
- * Flow Director is an advanced Rx filter, attempting to get Rx flows back
- * to the original CPU that initiated the Tx session.  This runs in addition
- * to RSS, so if a packet doesn't match an FDIR filter, we can still spread the
- * Rx load across CPUs using RSS.
- *
- **/
-static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
-{
-	bool ret = false;
-	struct ixgbe_ring_feature *f_fdir = &adapter->ring_feature[RING_F_FDIR];
-
-	f_fdir->indices = min_t(int, num_online_cpus(), f_fdir->limit);
-	f_fdir->mask = 0;
+	f->indices = rss_i;
+	f->mask = 0xF;
 
 	/*
-	 * Use RSS in addition to Flow Director to ensure the best
+	 * Use Flow Director in addition to RSS to ensure the best
 	 * distribution of flows across cores, even when an FDIR flow
 	 * isn't matched.
 	 */
-	if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
-	    (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)) {
-		adapter->num_tx_queues = f_fdir->indices;
-		adapter->num_rx_queues = f_fdir->indices;
-		ret = true;
-	} else {
-		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		f = &adapter->ring_feature[RING_F_FDIR];
+
+		f->indices = min_t(u16, num_online_cpus(), f->limit);
+		rss_i = max_t(u16, rss_i, f->indices);
 	}
-	return ret;
+
+	adapter->num_rx_queues = rss_i;
+	adapter->num_tx_queues = rss_i;
+
+	return true;
 }
 
 #ifdef IXGBE_FCOE
@@ -343,10 +299,7 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		e_info(probe, "FCoE enabled with RSS\n");
-		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
-			ixgbe_set_fdir_queues(adapter);
-		else
-			ixgbe_set_rss_queues(adapter);
+		ixgbe_set_rss_queues(adapter);
 	}
 
 	/* adding FCoE rx rings to the end */
@@ -438,9 +391,6 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 		goto done;
 
 #endif /* IXGBE_FCOE */
-	if (ixgbe_set_fdir_queues(adapter))
-		goto done;
-
 	if (ixgbe_set_rss_queues(adapter))
 		goto done;
 
-- 
1.7.10.4
