From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/14] i40e/i40evf: Use correct number of VF vectors
Date: Fri, 14 Mar 2014 16:34:34 -0700
Message-ID: <1394840075-6851-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31884 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756590AbaCNXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:09 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Now that the 2.4 firmware reports the correct number of MSI-X vectors,
use this value correctly when communicating with the VF, and when
setting up the interrupt linked list.

The PF has always reported the correct number of MSI-X vectors, so we
should never increment the value in the vf driver.

Change-ID: Ifeefc631c321390192219ce2af9ada6180c1492f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 9 +++++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 42cc6ba..7839343 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -69,7 +69,7 @@ static inline bool i40e_vc_isvalid_vector_id(struct i40e_vf *vf, u8 vector_id)
 {
 	struct i40e_pf *pf = vf->pf;
 
-	return vector_id <= pf->hw.func_caps.num_msix_vectors_vf;
+	return vector_id < pf->hw.func_caps.num_msix_vectors_vf;
 }
 
 /***********************vf resource mgmt routines*****************/
@@ -126,8 +126,8 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_idx,
 		reg_idx = I40E_VPINT_LNKLST0(vf->vf_id);
 	else
 		reg_idx = I40E_VPINT_LNKLSTN(
-					   (pf->hw.func_caps.num_msix_vectors_vf
-					      * vf->vf_id) + (vector_id - 1));
+		     ((pf->hw.func_caps.num_msix_vectors_vf - 1) * vf->vf_id) +
+		     (vector_id - 1));
 
 	if (vecmap->rxq_map == 0 && vecmap->txq_map == 0) {
 		/* Special case - No queues mapped on this vector */
@@ -506,7 +506,8 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 		vf->lan_vsi_index = 0;
 		vf->lan_vsi_id = 0;
 	}
-	msix_vf = pf->hw.func_caps.num_msix_vectors_vf + 1;
+	msix_vf = pf->hw.func_caps.num_msix_vectors_vf;
+
 	/* disable interrupts so the VF starts in a known state */
 	for (i = 0; i < msix_vf; i++) {
 		/* format is same for both registers */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 11d0b61..8daab3a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1141,7 +1141,7 @@ static int i40evf_set_interrupt_capability(struct i40evf_adapter *adapter)
 	 * (roughly) twice the number of vectors as there are CPU's.
 	 */
 	v_budget = min(pairs, (int)(num_online_cpus() * 2)) + NONQ_VECS;
-	v_budget = min(v_budget, (int)adapter->vf_res->max_vectors + 1);
+	v_budget = min(v_budget, (int)adapter->vf_res->max_vectors);
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter.
-- 
1.8.3.1
