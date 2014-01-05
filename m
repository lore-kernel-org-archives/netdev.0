From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: Fix ring allocation
Date: Sun,  5 Jan 2014 02:47:04 -0800
Message-ID: <1388918827-13430-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5196 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083AbaAEKrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:16 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

The allocation and clearing of rings for a VSI should be
using the alloc_queue_pairs and not num_queue_pairs.

The alloc_queue_pairs per VSI is a pre-allocated number
of queues assigned to a VSI; based on number of TCs enabled
only certain number of queues may be used from that. This
is mainly valid only for the LAN VSI case as that is the
only VSI that may be enabled with multiple traffic classes.
In the future the number of TCs may change based on DCBX
configuration.

The actual number of queues that are enabled/configured is
based on the number of TCs enabled for a given VSI and that
is stored in num_queue_pairs.

With this change num_[tr]x_queues is unused so remove them.

Change-Id: I9c2f84778bb25f7313c630e9b002a0caa883ce29
Signed-off-by: Neerav Parikh <Neerav.Parikh@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  3 ---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++----------
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 496ce05..7de6e01 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -249,9 +249,6 @@ struct i40e_pf {
 #define I40E_FLAG_VXLAN_FILTER_SYNC            (u64)(1 << 27)
 #endif
 
-	u16 num_tx_queues;
-	u16 num_rx_queues;
-
 	bool stat_offsets_loaded;
 	struct i40e_hw_port_stats stats;
 	struct i40e_hw_port_stats stats_offsets;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bfc3037..13df3fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3981,11 +3981,11 @@ static int i40e_open(struct net_device *netdev)
 		goto err_setup_rx;
 
 	/* Notify the stack of the actual queue counts. */
-	err = netif_set_real_num_tx_queues(netdev, pf->num_tx_queues);
+	err = netif_set_real_num_tx_queues(netdev, vsi->num_queue_pairs);
 	if (err)
 		goto err_set_queues;
 
-	err = netif_set_real_num_rx_queues(netdev, pf->num_rx_queues);
+	err = netif_set_real_num_rx_queues(netdev, vsi->num_queue_pairs);
 	if (err)
 		goto err_set_queues;
 
@@ -5364,7 +5364,7 @@ static void i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 	int i;
 
 	if (vsi->tx_rings[0]) {
-		for (i = 0; i < vsi->num_queue_pairs; i++) {
+		for (i = 0; i < vsi->alloc_queue_pairs; i++) {
 			kfree_rcu(vsi->tx_rings[i], rcu);
 			vsi->tx_rings[i] = NULL;
 			vsi->rx_rings[i] = NULL;
@@ -5382,7 +5382,7 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 	int i;
 
 	/* Set basic values in the rings to be used later during open() */
-	for (i = 0; i < vsi->num_queue_pairs; i++) {
+	for (i = 0; i < vsi->alloc_queue_pairs; i++) {
 		struct i40e_ring *tx_ring;
 		struct i40e_ring *rx_ring;
 
@@ -7225,12 +7225,6 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 			i40e_fdir_teardown(pf);
 			return -EAGAIN;
 		}
-		/* accommodate kcompat by copying the main VSI queue count
-		 * into the pf, since this newer code pushes the pf queue
-		 * info down a level into a VSI
-		 */
-		pf->num_rx_queues = vsi->num_queue_pairs;
-		pf->num_tx_queues = vsi->num_queue_pairs;
 	} else {
 		/* force a reset of TC and queue layout configurations */
 		u8 enabled_tc = pf->vsi[pf->lan_vsi]->tc_config.enabled_tc;
-- 
1.8.3.1
