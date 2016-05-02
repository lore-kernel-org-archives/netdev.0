From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Use consistent type for vf_id
Date: Sun,  1 May 2016 17:06:14 -0700
Message-ID: <1462147581-135254-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1786 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556AbcEBAG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:27 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was all over the place using signed or unsigned types
for vf_id, when it should always be signed.

This fixes warnings of type unsafe comparisons from gcc with W=2.

Change-Id: I2cb681f83d0f68ca124d2e4131e4ac0d9f8a6b22
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++++++------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  4 ++--
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e312adf..00c4738 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -554,7 +554,7 @@ struct i40e_vsi {
 	u16 num_queue_pairs; /* Used tx and rx pairs */
 	u16 num_desc;
 	enum i40e_vsi_type type;  /* VSI type, e.g., LAN, FCoE, etc */
-	u16 vf_id;		/* Virtual function ID for SRIOV VSIs */
+	s16 vf_id;		/* Virtual function ID for SRIOV VSIs */
 
 	struct i40e_tc_configuration tc_config;
 	struct i40e_aqc_vsi_properties_data info;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a534fe6..6b9db79 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -48,7 +48,7 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 	int i;
 
 	for (i = 0; i < pf->num_alloc_vfs; i++, vf++) {
-		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+		int abs_vf_id = vf->vf_id + (int)hw->func_caps.vf_base_id;
 		/* Not all vfs are enabled so skip the ones that are not */
 		if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
 		    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
@@ -74,7 +74,7 @@ static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_link_status *ls = &pf->hw.phy.link_info;
-	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+	int abs_vf_id = vf->vf_id + (int)hw->func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
@@ -141,7 +141,7 @@ void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
 	    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
 		return;
 
-	abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
+	abs_vf_id = vf->vf_id + (int)vf->pf->hw.func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
@@ -2516,11 +2516,11 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
  * called from the common aeq/arq handler to
  * process request from VF
  **/
-int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
+int i40e_vc_process_vf_msg(struct i40e_pf *pf, s16 vf_id, u32 v_opcode,
 			   u32 v_retval, u8 *msg, u16 msglen)
 {
 	struct i40e_hw *hw = &pf->hw;
-	unsigned int local_vf_id = vf_id - hw->func_caps.vf_base_id;
+	int local_vf_id = vf_id - (s16)hw->func_caps.vf_base_id;
 	struct i40e_vf *vf;
 	int ret;
 
@@ -2622,9 +2622,10 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
  **/
 int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 {
-	u32 reg, reg_idx, bit_idx, vf_id;
 	struct i40e_hw *hw = &pf->hw;
+	u32 reg, reg_idx, bit_idx;
 	struct i40e_vf *vf;
+	int vf_id;
 
 	if (!test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
 		return 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index bf54873..8751741 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -77,7 +77,7 @@ struct i40e_vf {
 	struct i40e_pf *pf;
 
 	/* VF id in the PF space */
-	u16 vf_id;
+	s16 vf_id;
 	/* all VF vsis connect to the same parent */
 	enum i40e_switch_element_types parent_type;
 	struct i40e_virtchnl_version_info vf_ver;
@@ -121,7 +121,7 @@ struct i40e_vf {
 void i40e_free_vfs(struct i40e_pf *pf);
 int i40e_pci_sriov_configure(struct pci_dev *dev, int num_vfs);
 int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs);
-int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
+int i40e_vc_process_vf_msg(struct i40e_pf *pf, s16 vf_id, u32 v_opcode,
 			   u32 v_retval, u8 *msg, u16 msglen);
 int i40e_vc_process_vflr_event(struct i40e_pf *pf);
 void i40e_reset_vf(struct i40e_vf *vf, bool flr);
-- 
2.5.5
