From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] ixgbe: cleanup allocation and freeing of IRQ affinity hint
Date: Thu, 15 Sep 2011 21:42:45 -0700
Message-ID: <1316148173-11209-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9739 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109Ab1IPEm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:58 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The allocation and freeing of the IRQ affinity hint needs some updates
since there are a number of spots where we run into possible issues with
the hint not being correctly updated.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   76 ++++++++++++-------------
 1 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3ce0277..73a669d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1565,20 +1565,6 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
-		/* If ATR is enabled, set interrupt affinity */
-		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
-			/*
-			 * Allocate the affinity_hint cpumask, assign the mask
-			 * for this vector, and set our affinity_hint for
-			 * this irq.
-			 */
-			if (!alloc_cpumask_var(&q_vector->affinity_mask,
-			                       GFP_KERNEL))
-				return;
-			cpumask_set_cpu(v_idx, q_vector->affinity_mask);
-			irq_set_affinity_hint(adapter->msix_entries[v_idx].vector,
-			                      q_vector->affinity_mask);
-		}
 	}
 
 	switch (adapter->hw.mac.type) {
@@ -2093,18 +2079,17 @@ out:
 static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int i, vector, q_vectors, err;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	int vector, err;
 	int ri = 0, ti = 0;
 
-	/* Decrement for Other and TCP Timer vectors */
-	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-
 	err = ixgbe_map_rings_to_vectors(adapter);
 	if (err)
 		return err;
 
 	for (vector = 0; vector < q_vectors; vector++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
+		struct msix_entry *entry = &adapter->msix_entries[vector];
 
 		if (q_vector->tx.ring && q_vector->rx.ring) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
@@ -2120,14 +2105,19 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 			/* skip this unused q_vector */
 			continue;
 		}
-		err = request_irq(adapter->msix_entries[vector].vector,
-				  &ixgbe_msix_clean_rings, 0, q_vector->name,
-				  q_vector);
+		err = request_irq(entry->vector, &ixgbe_msix_clean_rings, 0,
+				  q_vector->name, q_vector);
 		if (err) {
 			e_err(probe, "request_irq failed for MSIX interrupt "
 			      "Error: %d\n", err);
 			goto free_queue_irqs;
 		}
+		/* If Flow Director is enabled, set interrupt affinity */
+		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+			/* assign the mask for this irq */
+			irq_set_affinity_hint(entry->vector,
+					      q_vector->affinity_mask);
+		}
 	}
 
 	sprintf(adapter->lsc_int_name, "%s:lsc", netdev->name);
@@ -2141,9 +2131,13 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	return 0;
 
 free_queue_irqs:
-	for (i = vector - 1; i >= 0; i--)
-		free_irq(adapter->msix_entries[--vector].vector,
-			 adapter->q_vector[i]);
+	while (vector) {
+		vector--;
+		irq_set_affinity_hint(adapter->msix_entries[vector].vector,
+				      NULL);
+		free_irq(adapter->msix_entries[vector].vector,
+			 adapter->q_vector[vector]);
+	}
 	adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 	pci_disable_msix(adapter->pdev);
 	kfree(adapter->msix_entries);
@@ -2333,14 +2327,19 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 			    !adapter->q_vector[i]->tx.ring)
 				continue;
 
+			/* clear the affinity_mask in the IRQ descriptor */
+			irq_set_affinity_hint(adapter->msix_entries[i].vector,
+					      NULL);
+
 			free_irq(adapter->msix_entries[i].vector,
 				 adapter->q_vector[i]);
 		}
-
-		ixgbe_reset_q_vectors(adapter);
 	} else {
 		free_irq(adapter->pdev->irq, adapter);
 	}
+
+	/* clear q_vector state information */
+	ixgbe_reset_q_vectors(adapter);
 }
 
 /**
@@ -3879,7 +3878,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
 	int i;
-	int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
@@ -3924,15 +3922,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 			adapter->vfinfo[i].clear_to_send = 0;
 	}
 
-	/* Cleanup the affinity_hint CPU mask memory and callback */
-	for (i = 0; i < num_q_vectors; i++) {
-		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-		/* clear the affinity_mask in the IRQ descriptor */
-		irq_set_affinity_hint(adapter->msix_entries[i]. vector, NULL);
-		/* release the CPU mask memory */
-		free_cpumask_var(q_vector->affinity_mask);
-	}
-
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		u8 reg_idx = adapter->tx_ring[i]->reg_idx;
@@ -4677,6 +4666,11 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		q_vector->adapter = adapter;
 		q_vector->v_idx = v_idx;
 
+		/* Allocate the affinity_hint cpumask, configure the mask */
+		if (!alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL))
+			goto err_out;
+		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+
 		if (q_vector->tx.count && !q_vector->rx.count)
 			q_vector->eitr = adapter->tx_eitr_param;
 		else
@@ -4694,6 +4688,7 @@ err_out:
 		v_idx--;
 		q_vector = adapter->q_vector[v_idx];
 		netif_napi_del(&q_vector->napi);
+		free_cpumask_var(q_vector->affinity_mask);
 		kfree(q_vector);
 		adapter->q_vector[v_idx] = NULL;
 	}
@@ -4710,17 +4705,18 @@ err_out:
  **/
 static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int q_idx, num_q_vectors;
+	int v_idx, num_q_vectors;
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 	else
 		num_q_vectors = 1;
 
-	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
-		struct ixgbe_q_vector *q_vector = adapter->q_vector[q_idx];
-		adapter->q_vector[q_idx] = NULL;
+	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[v_idx];
+		adapter->q_vector[v_idx] = NULL;
 		netif_napi_del(&q_vector->napi);
+		free_cpumask_var(q_vector->affinity_mask);
 		kfree(q_vector);
 	}
 }
-- 
1.7.6
