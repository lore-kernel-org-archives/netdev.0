From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH linux-next v2 2/2] ixgbe: Example usage of the new IRQ
	affinity_hint callback
Date: Fri, 30 Apr 2010 01:52:21 -0700
Message-ID: <20100430085220.4630.14124.stgit@ppwaskie-hc2.jf.intel.com>
References: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch uses the new IRQ affinity_hint callback mechanism.
It serves purely as an example of how a low-level driver can
utilize this new interface.

An official ixgbe patch will be pushed through netdev once the
IRQ patches have been accepted and merged.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   20 +++++++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletions(-)

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
index 1b1419c..28f9d6b 100644
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
@@ -3251,6 +3261,14 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	for (i = 0; i < num_q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
+		/* unregister the affinity_hint */
+		irq_unregister_affinity_hint(adapter->msix_entries[i].vector);
+		/* release the CPU mask memory */
+		free_cpumask_var(q_vector->affinity_mask);
+	}
+
 	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);
