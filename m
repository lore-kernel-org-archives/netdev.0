From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: Use affinity_hint when Flow Director is
	enabled
Date: Tue, 05 Oct 2010 04:27:49 -0700
Message-ID: <20101005112511.23263.64121.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:56895
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758143Ab0JEL2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 07:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Use the new infrastructure to balance interrupts for flow
alignment when ATR or Flow Director are enabled.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5cebc37..a8c47b0 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -31,6 +31,7 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/cpumask.h>
 #include <linux/aer.h>
 
 #include "ixgbe_type.h"
@@ -241,6 +242,7 @@ struct ixgbe_q_vector {
 	u8 tx_itr;
 	u8 rx_itr;
 	u32 eitr;
+	cpumask_var_t affinity_mask;
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c35e13c..95dbf60 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1433,6 +1433,21 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			q_vector->eitr = adapter->rx_eitr_param;
 
 		ixgbe_write_eitr(q_vector);
+		/* If Flow Director is enabled, set interrupt affinity */
+		if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
+		    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)) {
+			/*
+			 * Allocate the affinity_hint cpumask, assign the mask
+			 * for this vector, and set our affinity_hint for
+			 * this irq.
+			 */
+			if (!alloc_cpumask_var(&q_vector->affinity_mask,
+			                       GFP_KERNEL))
+				return;
+			cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+			irq_set_affinity_hint(adapter->msix_entries[v_idx].vector,
+			                      q_vector->affinity_mask);
+		}
 	}
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
@@ -3816,6 +3831,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	u32 rxctrl;
 	u32 txdctl;
 	int i, j;
+	int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
@@ -3854,6 +3870,15 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	/* Cleanup the affinity_hint CPU mask memory and callback */
+	for (i = 0; i < num_q_vectors; i++) {
+		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
+		/* clear the affinity_mask in the IRQ descriptor */
+		irq_set_affinity_hint(adapter->msix_entries[i]. vector, NULL);
+		/* release the CPU mask memory */
+		free_cpumask_var(q_vector->affinity_mask);
+	}
+
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);

