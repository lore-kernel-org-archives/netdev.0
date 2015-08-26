From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/14] i40e: Fix legacy interrupt mode in the driver
Date: Wed, 26 Aug 2015 15:49:23 -0700
Message-ID: <1440629373-21287-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34139 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646AbbHZWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:37 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch fixes the driver flow to take into account legacy interrupts.
Over time we added code that assumes MSIX is the only mode that the
driver runs in. It also enables a legacy workaround to trigger SWINT
when the TX ring has non-cache aligned descriptors pending and interrupts
are disabled.

We work with a single vector in MSI mode too, so apply the same
restrictions as Legacy.

Change-ID: I826ddff1f9bd45d2dbe11f56a3ddcef0dbf42563
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 07bfe61..481f427 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1550,7 +1550,10 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	 * vectors available and so we need to lower the used
 	 * q count.
 	 */
-	qcount = min_t(int, vsi->alloc_queue_pairs, pf->num_lan_msix);
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
+		qcount = min_t(int, vsi->alloc_queue_pairs, pf->num_lan_msix);
+	else
+		qcount = vsi->alloc_queue_pairs;
 	num_tc_qps = qcount / numtc;
 	num_tc_qps = min_t(int, num_tc_qps, i40e_pf_get_max_q_per_tc(pf));
 
@@ -1614,7 +1617,7 @@ static void i40e_vsi_setup_queue_map(struct i40e_vsi *vsi,
 	if ((vsi->type == I40E_VSI_MAIN) && (numtc == 1)) {
 		if (vsi->req_queue_pairs > 0)
 			vsi->num_queue_pairs = vsi->req_queue_pairs;
-		else
+		else if (pf->flags & I40E_FLAG_MSIX_ENABLED)
 			vsi->num_queue_pairs = pf->num_lan_msix;
 	}
 
@@ -3416,7 +3419,7 @@ static irqreturn_t i40e_fdir_clean_ring(int irq, void *data)
  * @v_idx: vector index
  * @qp_idx: queue pair index
  **/
-static void map_vector_to_qp(struct i40e_vsi *vsi, int v_idx, int qp_idx)
+static void i40e_map_vector_to_qp(struct i40e_vsi *vsi, int v_idx, int qp_idx)
 {
 	struct i40e_q_vector *q_vector = vsi->q_vectors[v_idx];
 	struct i40e_ring *tx_ring = vsi->tx_rings[qp_idx];
@@ -3470,7 +3473,7 @@ static void i40e_vsi_map_rings_to_vectors(struct i40e_vsi *vsi)
 		q_vector->tx.ring = NULL;
 
 		while (num_ringpairs--) {
-			map_vector_to_qp(vsi, v_start, qp_idx);
+			i40e_map_vector_to_qp(vsi, v_start, qp_idx);
 			qp_idx++;
 			qp_remaining--;
 		}
@@ -8798,6 +8801,11 @@ static int i40e_vsi_setup_vectors(struct i40e_vsi *vsi)
 		goto vector_setup_out;
 	}
 
+	/* In Legacy mode, we do not have to get any other vector since we
+	 * piggyback on the misc/ICR0 for queue interrupts.
+	*/
+	if (!(pf->flags & I40E_FLAG_MSIX_ENABLED))
+		return ret;
 	if (vsi->num_q_vectors)
 		vsi->base_vector = i40e_get_lump(pf, pf->irq_pile,
 						 vsi->num_q_vectors, vsi->idx);
-- 
2.4.3
