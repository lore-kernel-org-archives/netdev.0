From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: fix XPS mask when resetting
Date: Thu,  5 Mar 2015 08:46:24 -0800
Message-ID: <1425573992-30955-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41895 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757944AbbCEQqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:53 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

During resets (possibly caused by a Tx hang) the driver would
accidentally clear the XPS mask for all queues back to 0.

This caused higher CPU utilization and had some other performance impacts
for transmit tests.

Change-ID: I95f112432c9e643a153eaa31cd28cdcbfdd01831
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 620dd23..a287cc8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2399,20 +2399,20 @@ static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 	struct i40e_vsi *vsi = ring->vsi;
 	cpumask_var_t mask;
 
-	if (ring->q_vector && ring->netdev) {
-		/* Single TC mode enable XPS */
-		if (vsi->tc_config.numtc <= 1 &&
-		    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state)) {
+	if (!ring->q_vector || !ring->netdev)
+		return;
+
+	/* Single TC mode enable XPS */
+	if (vsi->tc_config.numtc <= 1) {
+		if (!test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state))
 			netif_set_xps_queue(ring->netdev,
 					    &ring->q_vector->affinity_mask,
 					    ring->queue_index);
-		} else if (alloc_cpumask_var(&mask, GFP_KERNEL)) {
-			/* Disable XPS to allow selection based on TC */
-			bitmap_zero(cpumask_bits(mask), nr_cpumask_bits);
-			netif_set_xps_queue(ring->netdev, mask,
-					    ring->queue_index);
-			free_cpumask_var(mask);
-		}
+	} else if (alloc_cpumask_var(&mask, GFP_KERNEL)) {
+		/* Disable XPS to allow selection based on TC */
+		bitmap_zero(cpumask_bits(mask), nr_cpumask_bits);
+		netif_set_xps_queue(ring->netdev, mask, ring->queue_index);
+		free_cpumask_var(mask);
 	}
 }
 
-- 
1.9.3
