From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH linux-next 2/2] ixgbe: Example usage of the new IRQ
	affinity_hint callback
Date: Tue, 20 Apr 2010 11:01:39 -0700
Message-ID: <20100420180139.1276.79769.stgit@ppwaskie-hc2.jf.intel.com>
References: <20100420180112.1276.11906.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57964 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672Ab0DTR5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 13:57:04 -0400
In-Reply-To: <20100420180112.1276.11906.stgit@ppwaskie-hc2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the new IRQ affinity_hint callback mechanism.
It serves purely as an example of how a low-level driver can
utilize this new interface.

An official ixgbe patch will be pushed through netdev once the
IRQ patches have been accepted and merged.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   51 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 79c35ae..c220b9f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -32,6 +32,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/aer.h>
+#include <linux/cpumask.h>
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -236,6 +237,7 @@ struct ixgbe_q_vector {
 	u8 tx_itr;
 	u8 rx_itr;
 	u32 eitr;
+	cpumask_var_t affinity_mask;
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1b1419c..3e00d41 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1031,6 +1031,36 @@ next_desc:
 	return cleaned;
 }
 
+static unsigned int ixgbe_irq_affinity_callback(cpumask_var_t mask,
+                                                unsigned int irq, void *dev)
+{
+	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)dev;
+	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		return -EINVAL;
+
+	/*
+	 * Loop through the msix_entries array, looking for the vector that
+	 * matches the irq passed to us.  Once we find it, use that index to
+	 * grab the corresponding q_vector (1 to 1 mapping), and grab the
+	 * cpumask from that q_vector.
+	 */
+	for (i = 0; i < q_vectors; i++)
+		if (adapter->msix_entries[i].vector == irq)
+			break;
+
+	if (i == q_vectors)
+		return -EINVAL;
+
+	if (adapter->q_vector[i]->affinity_mask)
+		cpumask_copy(mask, adapter->q_vector[i]->affinity_mask);
+	else
+		return -EINVAL;
+
+	return 0;
+}
+
 static int ixgbe_clean_rxonly(struct napi_struct *, int);
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
@@ -1083,6 +1113,16 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
+
+		/*
+		 * Allocate the affinity_hint cpumask, assign the mask for
+		 * this vector, and register our affinity_hint callback.
+		 */
+		alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL);
+		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+		irq_register_affinity_hint(adapter->msix_entries[v_idx].vector,
+		                           adapter,
+		                           &ixgbe_irq_affinity_callback);
 	}
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
@@ -3218,7 +3258,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
 	u32 txdctl;
-	int i, j;
+	int i, j, num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
@@ -3251,6 +3291,14 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	for (i = 0; i < num_q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
+		/* unregister the affinity_hint callback */
+		irq_unregister_affinity_hint(adapter->msix_entries[i].vector);
+		/* release the CPU mask memory */
+		free_cpumask_var(q_vector->affinity_mask);
+	}
+
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);
@@ -4052,6 +4100,7 @@ static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[q_idx];
 		adapter->q_vector[q_idx] = NULL;
 		netif_napi_del(&q_vector->napi);
+		free_cpumask_var(q_vector->affinity_mask);
 		kfree(q_vector);
 	}
 }

