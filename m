From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: fix write-back-on-itr to work with legacy itr
Date: Tue, 16 Feb 2016 21:34:13 -0800
Message-ID: <1455687262-20453-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:54509 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756350AbcBQFe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:27 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

We were not doing write-back on interrupt throttle for Legacy case in X722.
This patch fixes that, so we do WB_ON_ITR for Legacy as well. Plus the issue
that we should still be setting NO_ITR if we are touching the DYN_CTLN register
since we do not want to change ITR setting here.

Change-ID: I5db8491ee1544118a389db839cecc93e1bbc480e
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 18 +++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  3 ++-
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 47bd8b3..6234136 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -789,12 +789,20 @@ void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 		if (q_vector->arm_wb_state)
 			return;
 
-		val = I40E_PFINT_DYN_CTLN_WB_ON_ITR_MASK;
+		if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
+			val = I40E_PFINT_DYN_CTLN_WB_ON_ITR_MASK |
+			      I40E_PFINT_DYN_CTLN_ITR_INDX_MASK; /* set noitr */
+
+			wr32(&vsi->back->hw,
+			     I40E_PFINT_DYN_CTLN(q_vector->v_idx +
+						 vsi->base_vector - 1),
+			     val);
+		} else {
+			val = I40E_PFINT_DYN_CTL0_WB_ON_ITR_MASK |
+			      I40E_PFINT_DYN_CTL0_ITR_INDX_MASK; /* set noitr */
 
-		wr32(&vsi->back->hw,
-		     I40E_PFINT_DYN_CTLN(q_vector->v_idx +
-					 vsi->base_vector - 1),
-		     val);
+			wr32(&vsi->back->hw, I40E_PFINT_DYN_CTL0, val);
+		}
 		q_vector->arm_wb_state = true;
 	} else if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 		u32 val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7d663fb..3e69235 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -307,7 +307,8 @@ static void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector
 		if (q_vector->arm_wb_state)
 			return;
 
-		val = I40E_VFINT_DYN_CTLN1_WB_ON_ITR_MASK;
+		val = I40E_VFINT_DYN_CTLN1_WB_ON_ITR_MASK |
+		      I40E_VFINT_DYN_CTLN1_ITR_INDX_MASK; /* set noitr */
 
 		wr32(&vsi->back->hw,
 		     I40E_VFINT_DYN_CTLN1(q_vector->v_idx +
-- 
2.5.0
