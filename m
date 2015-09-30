From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e: refactor interrupt enable
Date: Wed, 30 Sep 2015 05:52:37 -0700
Message-ID: <1443617561-40490-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34535 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932530AbbI3Mwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:46 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The interrupt enable function was always making the caller add
the base_vector from the VSI struct which is already passed to
the function. Just collapse the math into the helper function.

Change-ID: I54ef33aa7ceebc3231c3cc48f7b39fd0c3ff5806
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 ++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  6 ++----
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 43e21bd..c9a7dfa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3066,7 +3066,7 @@ void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf)
 /**
  * i40e_irq_dynamic_enable - Enable default interrupt generation settings
  * @vsi: pointer to a vsi
- * @vector: enable a particular Hw Interrupt vector
+ * @vector: enable a particular Hw Interrupt vector, without base_vector
  **/
 void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 {
@@ -3077,7 +3077,7 @@ void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 	val = I40E_PFINT_DYN_CTLN_INTENA_MASK |
 	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
 	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
-	wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
+	wr32(hw, I40E_PFINT_DYN_CTLN(vector + vsi->base_vector - 1), val);
 	/* skip the flush */
 }
 
@@ -3220,8 +3220,7 @@ static int i40e_vsi_enable_irq(struct i40e_vsi *vsi)
 	int i;
 
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
-		for (i = vsi->base_vector;
-		     i < (vsi->num_q_vectors + vsi->base_vector); i++)
+		for (i = 0; i < vsi->num_q_vectors; i++)
 			i40e_irq_dynamic_enable(vsi, i);
 	} else {
 		i40e_irq_dynamic_enable_icr0(pf);
@@ -3453,8 +3452,7 @@ static bool i40e_clean_fdir_tx_irq(struct i40e_ring *tx_ring, int budget)
 	tx_ring->next_to_clean = i;
 
 	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
-		i40e_irq_dynamic_enable(vsi,
-				tx_ring->q_vector->v_idx + vsi->base_vector);
+		i40e_irq_dynamic_enable(vsi, tx_ring->q_vector->v_idx);
 	}
 	return budget > 0;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 47dba9b0..5e1a7dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1783,8 +1783,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		if (!test_bit(__I40E_DOWN, &vsi->state))
 			wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
 	} else {
-		i40e_irq_dynamic_enable(vsi,
-					q_vector->v_idx + vsi->base_vector);
+		i40e_irq_dynamic_enable(vsi, q_vector->v_idx);
 	}
 	if (ITR_IS_DYNAMIC(vsi->tx_itr_setting)) {
 		old_itr = q_vector->tx.itr;
@@ -1806,8 +1805,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 			wr32(hw, I40E_PFINT_DYN_CTLN(q_vector->v_idx +
 			      vsi->base_vector - 1), val);
 	} else {
-		i40e_irq_dynamic_enable(vsi,
-					q_vector->v_idx + vsi->base_vector);
+		i40e_irq_dynamic_enable(vsi, q_vector->v_idx);
 	}
 }
 
-- 
2.4.3
