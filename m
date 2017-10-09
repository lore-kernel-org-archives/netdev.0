From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e: allow XPS with QoS enabled
Date: Mon,  9 Oct 2017 15:38:36 -0700
Message-ID: <20171009223841.2557-10-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36097 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755534AbdJIWjH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:07 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Recently, the kernel gained support for enabling XPS and QoS at the
same time. Thus, we no longer need to worry about the number of
traffic classes when enabling XPS.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 74875ddaeb33..b26f615bed5a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2879,23 +2879,18 @@ static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
  **/
 static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 {
-	struct i40e_vsi *vsi = ring->vsi;
 	int cpu;
 
 	if (!ring->q_vector || !ring->netdev)
 		return;
 
-	if ((vsi->tc_config.numtc <= 1) &&
-	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, ring->state)) {
-		cpu = cpumask_local_spread(ring->q_vector->v_idx, -1);
-		netif_set_xps_queue(ring->netdev, get_cpu_mask(cpu),
-				    ring->queue_index);
-	}
+	/* We only initialize XPS once, so as not to overwrite user settings */
+	if (test_and_set_bit(__I40E_TX_XPS_INIT_DONE, ring->state))
+		return;
 
-	/* schedule our worker thread which will take care of
-	 * applying the new filter changes
-	 */
-	i40e_service_event_schedule(vsi->back);
+	cpu = cpumask_local_spread(ring->q_vector->v_idx, -1);
+	netif_set_xps_queue(ring->netdev, get_cpu_mask(cpu),
+			    ring->queue_index);
 }
 
 /**
-- 
2.14.2
