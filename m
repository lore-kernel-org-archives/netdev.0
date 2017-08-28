From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: remove workaround for resetting XPS
Date: Sun, 27 Aug 2017 17:15:58 -0700
Message-ID: <20170828001603.75876-11-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:47467 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751623AbdH1AQU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:20 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since commit 3ffa037d7f78 ("i40e: Set XPS bit mask to zero in DCB mode")
we've tried to reset the XPS settings by building a custom
empty CPU mask.

This workaround is not necessary because we're not really removing the
XPS setting, but simply setting it so that no CPU is valid.

Second, we shorten the code further by using zalloc_cpumask_var instead
of a separate call to bitmap_zero().

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0962b85ef6f3..7366e7c7f399 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2874,22 +2874,15 @@ static void i40e_vsi_free_rx_resources(struct i40e_vsi *vsi)
 static void i40e_config_xps_tx_ring(struct i40e_ring *ring)
 {
 	struct i40e_vsi *vsi = ring->vsi;
-	cpumask_var_t mask;
 
 	if (!ring->q_vector || !ring->netdev)
 		return;
 
-	/* Single TC mode enable XPS */
-	if (vsi->tc_config.numtc <= 1) {
-		if (!test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state))
-			netif_set_xps_queue(ring->netdev,
-					    &ring->q_vector->affinity_mask,
-					    ring->queue_index);
-	} else if (alloc_cpumask_var(&mask, GFP_KERNEL)) {
-		/* Disable XPS to allow selection based on TC */
-		bitmap_zero(cpumask_bits(mask), nr_cpumask_bits);
-		netif_set_xps_queue(ring->netdev, mask, ring->queue_index);
-		free_cpumask_var(mask);
+	if ((vsi->tc_config.numtc <= 1) &&
+	    !test_and_set_bit(__I40E_TX_XPS_INIT_DONE, &ring->state)) {
+		netif_set_xps_queue(ring->netdev,
+				    &ring->q_vector->affinity_mask,
+				    ring->queue_index);
 	}
 
 	/* schedule our worker thread which will take care of
-- 
2.14.1
