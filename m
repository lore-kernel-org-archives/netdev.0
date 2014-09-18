From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] ixgbe: move msix_entries allocation into ixgbe_acquire_msix_vectors
Date: Thu, 18 Sep 2014 05:26:56 -0700
Message-ID: <1411043221-7163-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbaIRM1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:06 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We already have to kfree this value if we fail, and this is only part of
MSI-X mode, so we should simply allocate the value where we need it.
This is cleaner, and makes it a lot more obvious why we are freeing it
inside of ixgbe_acquire_msix_vectors.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 2a38894..f504faf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -699,7 +699,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 static int ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 				      int vectors)
 {
-	int vector_threshold;
+	int i, vector_threshold;
 
 	/* We'll want at least 2 (vector_threshold):
 	 * 1) TxQ[0] + RxQ[0] handler
@@ -713,6 +713,15 @@ static int ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	 * Right now, we simply care about how many we'll get; we'll
 	 * set them up later while requesting irq's.
 	 */
+	adapter->msix_entries = kcalloc(vectors,
+					sizeof(struct msix_entry),
+					GFP_KERNEL);
+	if (!adapter->msix_entries)
+		return -ENOMEM;
+
+	for (i = 0; i < vectors; i++)
+		adapter->msix_entries[i].entry = i;
+
 	vectors = pci_enable_msix_range(adapter->pdev, adapter->msix_entries,
 					vector_threshold, vectors);
 
@@ -1061,7 +1070,7 @@ static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
 static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int vector, v_budget, err;
+	int v_budget, err;
 
 	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
@@ -1085,15 +1094,8 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
-	adapter->msix_entries = kcalloc(v_budget,
-					sizeof(struct msix_entry), GFP_KERNEL);
-	if (adapter->msix_entries) {
-		for (vector = 0; vector < v_budget; vector++)
-			adapter->msix_entries[vector].entry = vector;
-
-		if (!ixgbe_acquire_msix_vectors(adapter, v_budget))
-			return;
-	}
+	if (!ixgbe_acquire_msix_vectors(adapter, v_budget))
+		return;
 
 	/* At this point, we do not have MSI-X capabilities. We need to
 	 * reconfigure or disable various features which require MSI-X
-- 
1.9.3
