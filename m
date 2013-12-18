From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Fix queue allocation method to accommodate changing during runtime
Date: Tue, 17 Dec 2013 22:44:41 -0800
Message-ID: <1387349082-18506-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3472 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab3LRGpG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:45:06 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

When changing number of queues using ethtool's set_channels during runtime,
a queue allocation could fail, which can leave the device in a down state.
In order to preserve the usability of the device in this scenario, this patch
changes the driver to allocate the  number of queues only if they have not
been allocated already. The first allocation is then done for the max number
of queues, which is the default queues for this driver.   With this change,
queue quantity changes are not subject to queue allocation failures.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 66 ++++++++++++++++++++-----------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3bc10bd..db040d6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -983,43 +983,61 @@ err_out:
 	return err;
 }
 
-static void igb_reset_interrupt_capability(struct igb_adapter *adapter)
-{
-	if (adapter->msix_entries) {
-		pci_disable_msix(adapter->pdev);
-		kfree(adapter->msix_entries);
-		adapter->msix_entries = NULL;
-	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
-		pci_disable_msi(adapter->pdev);
-	}
-}
-
 /**
  *  igb_free_q_vector - Free memory allocated for specific interrupt vector
  *  @adapter: board private structure to initialize
  *  @v_idx: Index of vector to be freed
  *
- *  This function frees the memory allocated to the q_vector.  In addition if
- *  NAPI is enabled it will delete any references to the NAPI struct prior
- *  to freeing the q_vector.
+ *  This function frees the memory allocated to the q_vector.
  **/
 static void igb_free_q_vector(struct igb_adapter *adapter, int v_idx)
 {
 	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
 
+	adapter->q_vector[v_idx] = NULL;
+
+	/* igb_get_stats64() might access the rings on this vector,
+	 * we must wait a grace period before freeing it.
+	 */
+	kfree_rcu(q_vector, rcu);
+}
+
+/**
+ *  igb_reset_q_vector - Reset config for interrupt vector
+ *  @adapter: board private structure to initialize
+ *  @v_idx: Index of vector to be reset
+ *
+ *  If NAPI is enabled it will delete any references to the
+ *  NAPI struct. This is preparation for igb_free_q_vector.
+ **/
+static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
+{
+	struct igb_q_vector *q_vector = adapter->q_vector[v_idx];
+
 	if (q_vector->tx.ring)
 		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
 
 	if (q_vector->rx.ring)
 		adapter->tx_ring[q_vector->rx.ring->queue_index] = NULL;
 
-	adapter->q_vector[v_idx] = NULL;
 	netif_napi_del(&q_vector->napi);
 
-	/* igb_get_stats64() might access the rings on this vector,
-	 * we must wait a grace period before freeing it.
-	 */
-	kfree_rcu(q_vector, rcu);
+}
+
+static void igb_reset_interrupt_capability(struct igb_adapter *adapter)
+{
+	int v_idx = adapter->num_q_vectors;
+
+	if (adapter->msix_entries) {
+		pci_disable_msix(adapter->pdev);
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
+		pci_disable_msi(adapter->pdev);
+	}
+
+	while (v_idx--)
+		igb_reset_q_vector(adapter, v_idx);
 }
 
 /**
@@ -1038,8 +1056,10 @@ static void igb_free_q_vectors(struct igb_adapter *adapter)
 	adapter->num_rx_queues = 0;
 	adapter->num_q_vectors = 0;
 
-	while (v_idx--)
+	while (v_idx--) {
+		igb_reset_q_vector(adapter, v_idx);
 		igb_free_q_vector(adapter, v_idx);
+	}
 }
 
 /**
@@ -1172,7 +1192,9 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 	       (sizeof(struct igb_ring) * ring_count);
 
 	/* allocate q_vector and rings */
-	q_vector = kzalloc(size, GFP_KERNEL);
+	q_vector = adapter->q_vector[v_idx];
+	if (!q_vector)
+		q_vector = kzalloc(size, GFP_KERNEL);
 	if (!q_vector)
 		return -ENOMEM;
 
@@ -8037,7 +8059,7 @@ int igb_reinit_queues(struct igb_adapter *adapter)
 	if (netif_running(netdev))
 		igb_close(netdev);
 
-	igb_clear_interrupt_scheme(adapter);
+	igb_reset_interrupt_capability(adapter);
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
-- 
1.8.3.1
