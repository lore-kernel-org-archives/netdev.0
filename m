From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: initialize our affinity_mask based on cpu_possible_mask
Date: Sun, 27 Aug 2017 17:16:00 -0700
Message-ID: <20170828001603.75876-13-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47467 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751693AbdH1AQV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:21 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

On older kernels a call to irq_set_affinity_hint does not guarantee that
the IRQ affinity will be set. If nothing else on the system sets the IRQ
affinity this can result in a bug in the i40e_napi_poll() routine where
we notice that our interrupt fired on the "wrong" CPU according to our
internal affinity_mask variable.

This results in a bug where we continuously tell NAPI to stop polling to
move the interrupt to a new CPU, but the CPU never changes because our
affinity mask does not match the actual mask setup for the IRQ.

The root problem is a mismatched affinity mask value. So lets initialize
the value to cpu_possible_mask instead. This ensures that prior to the
first time we get an IRQ affinity notification we'll have the mask set
to include every possible CPU.

We use cpu_possible_mask instead of cpu_online_mask since the former is
almost certainly never going to change, while the later might change
after we've made a copy.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 12 +++++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  7 +++++--
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7366e7c7f399..6498da8806cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2881,7 +2881,7 @@ static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 	if ((vsi->tc_config.numtc <= 1) &&
 	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state)) {
 		netif_set_xps_queue(ring->netdev,
-				    &ring->q_vector->affinity_mask,
+				    get_cpu_mask(ring->q_vector->v_idx),
 				    ring->queue_index);
 	}
 
@@ -3506,8 +3506,10 @@ static int i40e_vsi_request_irq_msix(struct i40e_vsi *vsi, char *basename)
 		q_vector->affinity_notify.notify = i40e_irq_affinity_notify;
 		q_vector->affinity_notify.release = i40e_irq_affinity_release;
 		irq_set_affinity_notifier(irq_num, &q_vector->affinity_notify);
-		/* assign the mask for this irq */
-		irq_set_affinity_hint(irq_num, &q_vector->affinity_mask);
+		/* get_cpu_mask returns a static constant mask with
+		 * a permanent lifetime so it's ok to use here.
+		 */
+		irq_set_affinity_hint(irq_num, get_cpu_mask(q_vector->v_idx));
 	}
 
 	vsi->irqs_ready = true;
@@ -4289,7 +4291,7 @@ static void i40e_vsi_free_irq(struct i40e_vsi *vsi)
 
 			/* clear the affinity notifier in the IRQ descriptor */
 			irq_set_affinity_notifier(irq_num, NULL);
-			/* clear the affinity_mask in the IRQ descriptor */
+			/* remove our suggested affinity mask for this IRQ */
 			irq_set_affinity_hint(irq_num, NULL);
 			synchronize_irq(irq_num);
 			free_irq(irq_num, vsi->q_vectors[i]);
@@ -8235,7 +8237,7 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx, int cpu)
 
 	q_vector->vsi = vsi;
 	q_vector->v_idx = v_idx;
-	cpumask_set_cpu(cpu, &q_vector->affinity_mask);
+	cpumask_copy(&q_vector->affinity_mask, cpu_possible_mask);
 
 	if (vsi->netdev)
 		netif_napi_add(vsi->netdev, &q_vector->napi,
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 9ee277e87f10..1825d956bb00 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -584,8 +584,10 @@ i40evf_request_traffic_irqs(struct i40evf_adapter *adapter, char *basename)
 		q_vector->affinity_notify.release =
 						   i40evf_irq_affinity_release;
 		irq_set_affinity_notifier(irq_num, &q_vector->affinity_notify);
-		/* assign the mask for this irq */
-		irq_set_affinity_hint(irq_num, &q_vector->affinity_mask);
+		/* get_cpu_mask returns a static constant mask with
+		 * a permanent lifetime so it's ok to use here.
+		 */
+		irq_set_affinity_hint(irq_num, get_cpu_mask(q_vector->v_idx));
 	}
 
 	return 0;
@@ -1456,6 +1458,7 @@ static int i40evf_alloc_q_vectors(struct i40evf_adapter *adapter)
 		q_vector->adapter = adapter;
 		q_vector->vsi = &adapter->vsi;
 		q_vector->v_idx = q_idx;
+		cpumask_copy(&q_vector->affinity_mask, cpu_possible_mask);
 		netif_napi_add(adapter->netdev, &q_vector->napi,
 			       i40evf_napi_poll, NAPI_POLL_WEIGHT);
 	}
-- 
2.14.1
