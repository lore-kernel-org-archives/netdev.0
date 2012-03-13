From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbe: Default to queue pairs when number of queues is less than CPUs
Date: Mon, 12 Mar 2012 21:03:48 -0700
Message-ID: <1331611432-30109-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11875 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab2CMEEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:04 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The old code had several errors in how it was determining the vector
budget.  In order to simplify things this patch updates the code so that it
will attempt to always allocated paired Rx/Tx vectors instead of attempting
to allocate individual vectors when the number of queues is less than the
number of CPUs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index c5cd2b6..f25b4e2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -370,7 +370,7 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 #define MAX_MSIX_Q_VECTORS MAX_MSIX_Q_VECTORS_82599
 #define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82599
 
-#define MIN_MSIX_Q_VECTORS 2
+#define MIN_MSIX_Q_VECTORS 1
 #define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
 
 /* default to trying for four seconds */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bad9c05..80ae919 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4561,11 +4561,9 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 {
 	int err, vector_threshold;
 
-	/* We'll want at least 3 (vector_threshold):
-	 * 1) TxQ[0] Cleanup
-	 * 2) RxQ[0] Cleanup
-	 * 3) Other (Link Status Change, etc.)
-	 * 4) TCP Timer (optional)
+	/* We'll want at least 2 (vector_threshold):
+	 * 1) TxQ[0] + RxQ[0] handler
+	 * 2) Other (Link Status Change, etc.)
 	 */
 	vector_threshold = MIN_MSIX_COUNT;
 
@@ -4919,9 +4917,11 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
 	 * (roughly) the same number of vectors as there are CPU's.
+	 * The default is to use pairs of vectors.
 	 */
-	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-		       (int)num_online_cpus()) + NON_Q_VECTORS;
+	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
+	v_budget = min_t(int, v_budget, num_online_cpus());
+	v_budget += NON_Q_VECTORS;
 
 	/*
 	 * At the same time, hardware can only support a maximum of
-- 
1.7.7.6
