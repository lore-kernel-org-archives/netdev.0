From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC net-next-2.6 PATCH] ixgbe: Example usage of new IRQ
	affinity_hints for FCoE
Date: Fri, 23 Apr 2010 17:21:32 -0700
Message-ID: <20100424002132.16709.43724.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, arjan@linux.jf.intel.com,
	davem@davemloft.net, tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the fcoe protocol handler fcoe_rcv() is already executing
on the correct CPU, SCSI-FCP frames can avoid context switching
from the NET_RX softirq to the receive processing thread.

To avoid this context switch this patch uses the affinity_hint
callback to align the interrupt with the FCoE receive processing
threads.

To properly align interrupts for FCoE knowledge of how the
FCoE receive processing threads are setup as well as which
rx rings are dedicated to FCoE and their associated vectors
is needed.  Additionally if the FCoE application TLV moves
the FCoE priority this alignment will also need to change.
Handling this in irqbalance alone would required irqbalance
to be aware of DCB, the tx/rx ring mapping for FCoE in
ixgbe and FCoE recv thread CPU mappings. For these reasons
allowing irqbalance to accept hints from ixgbe is ideal for
this case.

Some quick investigative performance numbers show that by
aligning the interrupt correctly an increase in ~50k IOPS
and a decrease in ~10-15% CPU usage can be seen from a
standard default configuration setup by todays irqbalance.

This is a test patch to illustrate how using irq
affininty_hints in ixgbe can benifit FCoE.  This patch does
not consider the case where multiple CPU threads can map
to the same queue this case would need further work.
However, I think it does show the benefit of having
an interface to provide affinity_hints.

This patch applies on top of Peter P Waskiewicz Jr previous
series of two patches to implement the affinity hint callback
framework and sample implementation in ixgbe.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e4cff48..a680424 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1420,6 +1420,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	struct ixgbe_q_vector *q_vector;
 	int i, j, q_vectors, v_idx, r_idx;
 	u32 mask;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
@@ -1463,9 +1464,22 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		/*
 		 * Allocate the affinity_hint cpumask, assign the mask for
 		 * this vector, and register our affinity_hint callback.
+		 *
+		 * JF: Add a check for FCoE enabled adapter to catch rings
+		 * that are enabled for FCoE and align them to their
+		 * corresponding FCoE recv processing thread.
 		 */
 		alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL);
-		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+
+		r_idx = find_first_bit(q_vector->rxr_idx,
+		                       adapter->num_rx_queues);
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED &&
+		    (r_idx >= f->mask) && (r_idx < f->mask + f->indices))
+			cpumask_set_cpu(r_idx - f->mask,
+					q_vector->affinity_mask);
+		else
+			cpumask_set_cpu(v_idx, q_vector->affinity_mask);
+
 		irq_register_affinity_hint(adapter->msix_entries[v_idx].vector,
 		                           adapter,
 		                           &ixgbe_irq_affinity_callback);
