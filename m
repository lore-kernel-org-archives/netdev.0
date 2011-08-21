From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] ixgbe: commonize ixgbe_map_rings_to_vectors to work for all interrupt types
Date: Sun, 21 Aug 2011 00:29:18 -0700
Message-ID: <1313911761-11709-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61333 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815Ab1HUH32 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:28 -0400
In-Reply-To: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes it so that the map_rings_to_vectors call will work with
all interrupt types.  The advantage to this is that there will now be a
predictable mapping for all given interrupt types.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   90 ++++++++++---------------
 1 files changed, 35 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1929d23..2879a74 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2014,59 +2014,41 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
  * group the rings as "efficiently" as possible.  You would add new
  * mapping configurations in here.
  **/
-static int ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter)
+static void ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter)
 {
-	int q_vectors;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	int rxr_remaining = adapter->num_rx_queues, rxr_idx = 0;
+	int txr_remaining = adapter->num_tx_queues, txr_idx = 0;
 	int v_start = 0;
-	int rxr_idx = 0, txr_idx = 0;
-	int rxr_remaining = adapter->num_rx_queues;
-	int txr_remaining = adapter->num_tx_queues;
-	int i, j;
-	int rqpv, tqpv;
-	int err = 0;
 
-	/* No mapping required if MSI-X is disabled. */
+	/* only one q_vector if MSI-X is disabled. */
 	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		goto out;
-
-	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		q_vectors = 1;
 
 	/*
-	 * The ideal configuration...
-	 * We have enough vectors to map one per queue.
+	 * If we don't have enough vectors for a 1-to-1 mapping, we'll have to
+	 * group them so there are multiple queues per vector.
+	 *
+	 * Re-adjusting *qpv takes care of the remainder.
 	 */
-	if (q_vectors == adapter->num_rx_queues + adapter->num_tx_queues) {
-		for (; rxr_idx < rxr_remaining; v_start++, rxr_idx++)
+	for (; v_start < q_vectors && rxr_remaining; v_start++) {
+		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - v_start);
+		for (; rqpv; rqpv--, rxr_idx++, rxr_remaining--)
 			map_vector_to_rxq(adapter, v_start, rxr_idx);
-
-		for (; txr_idx < txr_remaining; v_start++, txr_idx++)
-			map_vector_to_txq(adapter, v_start, txr_idx);
-
-		goto out;
 	}
 
 	/*
-	 * If we don't have enough vectors for a 1-to-1
-	 * mapping, we'll have to group them so there are
-	 * multiple queues per vector.
+	 * If there are not enough q_vectors for each ring to have it's own
+	 * vector then we must pair up Rx/Tx on a each vector
 	 */
-	/* Re-adjusting *qpv takes care of the remainder. */
-	for (i = v_start; i < q_vectors; i++) {
-		rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - i);
-		for (j = 0; j < rqpv; j++) {
-			map_vector_to_rxq(adapter, i, rxr_idx);
-			rxr_idx++;
-			rxr_remaining--;
-		}
-		tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - i);
-		for (j = 0; j < tqpv; j++) {
-			map_vector_to_txq(adapter, i, txr_idx);
-			txr_idx++;
-			txr_remaining--;
-		}
+	if ((v_start + txr_remaining) > q_vectors)
+		v_start = 0;
+
+	for (; v_start < q_vectors && txr_remaining; v_start++) {
+		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - v_start);
+		for (; tqpv; tqpv--, txr_idx++, txr_remaining--)
+			map_vector_to_txq(adapter, v_start, txr_idx);
 	}
-out:
-	return err;
 }
 
 /**
@@ -2083,10 +2065,6 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	int vector, err;
 	int ri = 0, ti = 0;
 
-	err = ixgbe_map_rings_to_vectors(adapter);
-	if (err)
-		return err;
-
 	for (vector = 0; vector < q_vectors; vector++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
 		struct msix_entry *entry = &adapter->msix_entries[vector];
@@ -2294,19 +2272,25 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int err;
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+	/* map all of the rings to the q_vectors */
+	ixgbe_map_rings_to_vectors(adapter);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		err = ixgbe_request_msix_irqs(adapter);
-	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
+	else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED)
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, 0,
 				  netdev->name, adapter);
-	} else {
+	else
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, IRQF_SHARED,
 				  netdev->name, adapter);
-	}
 
-	if (err)
+	if (err) {
 		e_err(probe, "request_irq failed, Error %d\n", err);
 
+		/* place q_vectors and rings back into a known good state */
+		ixgbe_reset_q_vectors(adapter);
+	}
+
 	return err;
 }
 
@@ -2316,11 +2300,10 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		int i, q_vectors;
 
 		q_vectors = adapter->num_msix_vectors;
-
 		i = q_vectors - 1;
 		free_irq(adapter->msix_entries[i].vector, adapter);
-
 		i--;
+
 		for (; i >= 0; i--) {
 			/* free only the irqs that were actually requested */
 			if (!adapter->q_vector[i]->rx.ring &&
@@ -2387,9 +2370,6 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	ixgbe_set_ivar(adapter, 0, 0, 0);
 	ixgbe_set_ivar(adapter, 1, 0, 0);
 
-	map_vector_to_rxq(adapter, 0, 0);
-	map_vector_to_txq(adapter, 0, 0);
-
 	e_info(hw, "Legacy interrupt IVAR setup done\n");
 }
 
-- 
1.7.6

