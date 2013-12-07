From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: only set up the rings to be used
Date: Fri,  6 Dec 2013 18:17:19 -0800
Message-ID: <1386382643-29055-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:44976 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758032Ab3LGCRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:30 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The VSI may be allocated more queues (alloc_queue_pairs) than actually
are to be used (num_queue_pairs), so only allocate rings for the queues
to be used.  The numbers will likely be the same for most VSIs, but can
be different based on how TCs are assigned and enabled.

Change-Id: Ie40f7ad0affbc4b45d6f049bcf02ee2fa24edc74
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 40c64c4..aae2f04 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5087,12 +5087,11 @@ static int i40e_vsi_alloc_arrays(struct i40e_vsi *vsi)
 	int size;
 	int ret = 0;
 
-	/* allocate memory for ring pointers */
+	/* allocate memory for both Tx and Rx ring pointers */
 	size = sizeof(struct i40e_ring *) * vsi->alloc_queue_pairs * 2;
 	vsi->tx_rings = kzalloc(size, GFP_KERNEL);
 	if (!vsi->tx_rings)
 		return -ENOMEM;
-
 	vsi->rx_rings = &vsi->tx_rings[vsi->alloc_queue_pairs];
 
 	/* allocate memory for q_vector pointers */
@@ -5265,7 +5264,7 @@ static s32 i40e_vsi_clear_rings(struct i40e_vsi *vsi)
 	int i;
 
 	if (vsi->tx_rings[0])
-		for (i = 0; i < vsi->alloc_queue_pairs; i++) {
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
 			kfree_rcu(vsi->tx_rings[i], rcu);
 			vsi->tx_rings[i] = NULL;
 			vsi->rx_rings[i] = NULL;
@@ -5284,10 +5283,11 @@ static int i40e_alloc_rings(struct i40e_vsi *vsi)
 	int i;
 
 	/* Set basic values in the rings to be used later during open() */
-	for (i = 0; i < vsi->alloc_queue_pairs; i++) {
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
 		struct i40e_ring *tx_ring;
 		struct i40e_ring *rx_ring;
 
+		/* allocate space for both Tx and Rx in one shot */
 		tx_ring = kzalloc(sizeof(struct i40e_ring) * 2, GFP_KERNEL);
 		if (!tx_ring)
 			goto err_out;
@@ -5858,7 +5858,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	int etherdev_size;
 
 	etherdev_size = sizeof(struct i40e_netdev_priv);
-	netdev = alloc_etherdev_mq(etherdev_size, vsi->alloc_queue_pairs);
+	netdev = alloc_etherdev_mq(etherdev_size, vsi->num_queue_pairs);
 	if (!netdev)
 		return -ENOMEM;
 
@@ -6939,8 +6939,8 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf)
 		 * into the pf, since this newer code pushes the pf queue
 		 * info down a level into a VSI
 		 */
-		pf->num_rx_queues = vsi->alloc_queue_pairs;
-		pf->num_tx_queues = vsi->alloc_queue_pairs;
+		pf->num_rx_queues = vsi->num_queue_pairs;
+		pf->num_tx_queues = vsi->num_queue_pairs;
 	} else {
 		/* force a reset of TC and queue layout configurations */
 		u8 enabled_tc = pf->vsi[pf->lan_vsi]->tc_config.enabled_tc;
-- 
1.8.3.1
