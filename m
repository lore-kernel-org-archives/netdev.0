From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbe: return integer from ixgbe_acquire_msix_vectors
Date: Thu, 18 Sep 2014 05:26:55 -0700
Message-ID: <1411043221-7163-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43214 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbaIRM1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:06 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Similar to how ixgbevf handles acquiring MSI-X vectors, we can return an
error code instead of relying on the flag being set. This makes it more
clear that we have failed to setup MSI-X mode, and also will make it
easier to consolidate MSI-X related code all into the single function.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 32 ++++++++++++++++------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 5d085d5..2a38894 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -696,8 +696,8 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	ixgbe_set_rss_queues(adapter);
 }
 
-static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
-				       int vectors)
+static int ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
+				      int vectors)
 {
 	int vector_threshold;
 
@@ -726,16 +726,22 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
-	} else {
-		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
-		/*
-		 * Adjust for only the vectors we'll use, which is minimum
-		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
-		 * vectors we were allocated.
-		 */
-		vectors -= NON_Q_VECTORS;
-		adapter->num_q_vectors = min(vectors, adapter->max_q_vectors);
+
+		return vectors;
 	}
+
+	/* we successfully allocated some number of vectors within our
+	 * requested range.
+	 */
+	adapter->flags |= IXGBE_FLAG_MSIX_ENABLED;
+
+	/* Adjust for only the vectors we'll use, which is minimum
+	 * of max_q_vectors, or the number of vectors we were allocated.
+	 */
+	vectors -= NON_Q_VECTORS;
+	adapter->num_q_vectors = min_t(int, vectors, adapter->max_q_vectors);
+
+	return 0;
 }
 
 static void ixgbe_add_ring(struct ixgbe_ring *ring,
@@ -1085,9 +1091,7 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 		for (vector = 0; vector < v_budget; vector++)
 			adapter->msix_entries[vector].entry = vector;
 
-		ixgbe_acquire_msix_vectors(adapter, v_budget);
-
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		if (!ixgbe_acquire_msix_vectors(adapter, v_budget))
 			return;
 	}
 
-- 
1.9.3
