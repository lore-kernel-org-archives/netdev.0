From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH linux-next v3 2/2] ixgbe: Example usage of the new IRQ
	affinity_hint callback
Date: Fri, 30 Apr 2010 13:24:10 -0700
Message-ID: <20100430202410.4591.47026.stgit@ppwaskie-hc2.jf.intel.com>
References: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54999 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759466Ab0D3UPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 16:15:35 -0400
In-Reply-To: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
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
 drivers/net/ixgbe/ixgbe_main.c |   21 ++++++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

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
index 1b1419c..8f84bb8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1083,6 +1083,16 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
+
+		/*
+		 * Allocate the affinity_hint cpumask, assign the mask for
+		 * this vector, and register our affinity_hint for this irq.
+		 */
+		if (!alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL))
+			return;
+		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+		irq_register_affinity_hint(adapter->msix_entries[v_idx].vector,
+		                           q_vector->affinity_mask);
 	}
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
@@ -3218,7 +3228,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
 	u32 txdctl;
-	int i, j;
+	int i, j, num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
@@ -3251,6 +3261,15 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	for (i = 0; i < num_q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
+		/* release the CPU mask memory */
+		free_cpumask_var(q_vector->affinity_mask);
+		/* clear the affinity_mask in the IRQ descriptor */
+		irq_register_affinity_hint(adapter->msix_entries[i].vector,
+		                           NULL);
+	}
+
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);

