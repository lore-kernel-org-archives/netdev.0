From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: move VF notification routines up
Date: Tue, 14 Apr 2015 21:51:43 -0700
Message-ID: <1429073511-27664-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20217 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932521AbbDOEwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:04 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Move the VF notification functions to the top of the file. This
eliminates an unnecessary declaration.

Change-ID: I036171f14180ee9f0ce4e0a21334d6a217d06c94
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 246 ++++++++++-----------
 1 file changed, 123 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8df2b52..98e0921 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -25,8 +25,130 @@
  ******************************************************************************/
 
 #include "i40e.h"
-static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf);
 
+/*********************notification routines***********************/
+
+/**
+ * i40e_vc_vf_broadcast
+ * @pf: pointer to the PF structure
+ * @opcode: operation code
+ * @retval: return value
+ * @msg: pointer to the msg buffer
+ * @msglen: msg length
+ *
+ * send a message to all VFs on a given PF
+ **/
+static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
+				 enum i40e_virtchnl_ops v_opcode,
+				 i40e_status v_retval, u8 *msg,
+				 u16 msglen)
+{
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_vf *vf = pf->vf;
+	int i;
+
+	for (i = 0; i < pf->num_alloc_vfs; i++, vf++) {
+		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+		/* Not all vfs are enabled so skip the ones that are not */
+		if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
+		    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+			continue;
+
+		/* Ignore return value on purpose - a given VF may fail, but
+		 * we need to keep going and send to all of them
+		 */
+		i40e_aq_send_msg_to_vf(hw, abs_vf_id, v_opcode, v_retval,
+				       msg, msglen, NULL);
+	}
+}
+
+/**
+ * i40e_vc_notify_link_state
+ * @vf: pointer to the VF structure
+ *
+ * send a link status message to a single VF
+ **/
+static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
+{
+	struct i40e_virtchnl_pf_event pfe;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_hw *hw = &pf->hw;
+	struct i40e_link_status *ls = &pf->hw.phy.link_info;
+	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+
+	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
+	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
+	if (vf->link_forced) {
+		pfe.event_data.link_event.link_status = vf->link_up;
+		pfe.event_data.link_event.link_speed =
+			(vf->link_up ? I40E_LINK_SPEED_40GB : 0);
+	} else {
+		pfe.event_data.link_event.link_status =
+			ls->link_info & I40E_AQ_LINK_UP;
+		pfe.event_data.link_event.link_speed = ls->link_speed;
+	}
+	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
+			       0, (u8 *)&pfe, sizeof(pfe), NULL);
+}
+
+/**
+ * i40e_vc_notify_link_state
+ * @pf: pointer to the PF structure
+ *
+ * send a link status message to all VFs on a given PF
+ **/
+void i40e_vc_notify_link_state(struct i40e_pf *pf)
+{
+	int i;
+
+	for (i = 0; i < pf->num_alloc_vfs; i++)
+		i40e_vc_notify_vf_link_state(&pf->vf[i]);
+}
+
+/**
+ * i40e_vc_notify_reset
+ * @pf: pointer to the PF structure
+ *
+ * indicate a pending reset to all VFs on a given PF
+ **/
+void i40e_vc_notify_reset(struct i40e_pf *pf)
+{
+	struct i40e_virtchnl_pf_event pfe;
+
+	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
+	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
+	i40e_vc_vf_broadcast(pf, I40E_VIRTCHNL_OP_EVENT, 0,
+			     (u8 *)&pfe, sizeof(struct i40e_virtchnl_pf_event));
+}
+
+/**
+ * i40e_vc_notify_vf_reset
+ * @vf: pointer to the VF structure
+ *
+ * indicate a pending reset to the given VF
+ **/
+void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
+{
+	struct i40e_virtchnl_pf_event pfe;
+	int abs_vf_id;
+
+	/* validate the request */
+	if (!vf || vf->vf_id >= vf->pf->num_alloc_vfs)
+		return;
+
+	/* verify if the VF is in either init or active before proceeding */
+	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
+	    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+		return;
+
+	abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
+
+	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
+	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
+	i40e_aq_send_msg_to_vf(&vf->pf->hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
+			       0, (u8 *)&pfe,
+			       sizeof(struct i40e_virtchnl_pf_event), NULL);
+}
 /***********************misc routines*****************************/
 
 /**
@@ -1842,128 +1964,6 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 }
 
 /**
- * i40e_vc_vf_broadcast
- * @pf: pointer to the PF structure
- * @opcode: operation code
- * @retval: return value
- * @msg: pointer to the msg buffer
- * @msglen: msg length
- *
- * send a message to all VFs on a given PF
- **/
-static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
-				 enum i40e_virtchnl_ops v_opcode,
-				 i40e_status v_retval, u8 *msg,
-				 u16 msglen)
-{
-	struct i40e_hw *hw = &pf->hw;
-	struct i40e_vf *vf = pf->vf;
-	int i;
-
-	for (i = 0; i < pf->num_alloc_vfs; i++, vf++) {
-		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
-		/* Not all VFs are enabled so skip the ones that are not */
-		if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
-		    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
-			continue;
-
-		/* Ignore return value on purpose - a given VF may fail, but
-		 * we need to keep going and send to all of them
-		 */
-		i40e_aq_send_msg_to_vf(hw, abs_vf_id, v_opcode, v_retval,
-				       msg, msglen, NULL);
-	}
-}
-
-/**
- * i40e_vc_notify_link_state
- * @vf: pointer to the VF structure
- *
- * send a link status message to a single VF
- **/
-static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
-{
-	struct i40e_virtchnl_pf_event pfe;
-	struct i40e_pf *pf = vf->pf;
-	struct i40e_hw *hw = &pf->hw;
-	struct i40e_link_status *ls = &pf->hw.phy.link_info;
-	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
-
-	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
-	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
-	if (vf->link_forced) {
-		pfe.event_data.link_event.link_status = vf->link_up;
-		pfe.event_data.link_event.link_speed =
-			(vf->link_up ? I40E_LINK_SPEED_40GB : 0);
-	} else {
-		pfe.event_data.link_event.link_status =
-			ls->link_info & I40E_AQ_LINK_UP;
-		pfe.event_data.link_event.link_speed = ls->link_speed;
-	}
-	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
-			       0, (u8 *)&pfe, sizeof(pfe), NULL);
-}
-
-/**
- * i40e_vc_notify_link_state
- * @pf: pointer to the PF structure
- *
- * send a link status message to all VFs on a given PF
- **/
-void i40e_vc_notify_link_state(struct i40e_pf *pf)
-{
-	int i;
-
-	for (i = 0; i < pf->num_alloc_vfs; i++)
-		i40e_vc_notify_vf_link_state(&pf->vf[i]);
-}
-
-/**
- * i40e_vc_notify_reset
- * @pf: pointer to the PF structure
- *
- * indicate a pending reset to all VFs on a given PF
- **/
-void i40e_vc_notify_reset(struct i40e_pf *pf)
-{
-	struct i40e_virtchnl_pf_event pfe;
-
-	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
-	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
-	i40e_vc_vf_broadcast(pf, I40E_VIRTCHNL_OP_EVENT, I40E_SUCCESS,
-			     (u8 *)&pfe, sizeof(struct i40e_virtchnl_pf_event));
-}
-
-/**
- * i40e_vc_notify_vf_reset
- * @vf: pointer to the VF structure
- *
- * indicate a pending reset to the given VF
- **/
-void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
-{
-	struct i40e_virtchnl_pf_event pfe;
-	int abs_vf_id;
-
-	/* validate the request */
-	if (!vf || vf->vf_id >= vf->pf->num_alloc_vfs)
-		return;
-
-	/* verify if the VF is in either init or active before proceeding */
-	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
-	    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
-		return;
-
-	abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
-
-	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
-	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
-	i40e_aq_send_msg_to_vf(&vf->pf->hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
-			       I40E_SUCCESS, (u8 *)&pfe,
-			       sizeof(struct i40e_virtchnl_pf_event), NULL);
-}
-
-/**
  * i40e_ndo_set_vf_mac
  * @netdev: network interface device structure
  * @vf_id: VF identifier
-- 
1.9.3
