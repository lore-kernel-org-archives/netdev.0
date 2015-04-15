From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40e: notify VFs of link state
Date: Tue, 14 Apr 2015 21:51:42 -0700
Message-ID: <1429073511-27664-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47805 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932230AbbDOEwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:02 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Gratuitously notify VFs of link state when they activate their queues.
In general, this is the last thing that a VF driver will do as it opens
its interface, so this is a good time to notify the VF.

Currently, VF devices assume link is up unless told otherwise, which
means that VFs instantiated on a PF with no link will report the wrong
state. This change corrects that issue.

Change-ID: Iea53622904ecc681ac3f8938d81c30033ef9a0a6
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 50 ++++++++++++++--------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9b3fc83..8df2b52 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -25,6 +25,7 @@
  ******************************************************************************/
 
 #include "i40e.h"
+static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf);
 
 /***********************misc routines*****************************/
 
@@ -1767,6 +1768,7 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 		break;
 	case I40E_VIRTCHNL_OP_ENABLE_QUEUES:
 		ret = i40e_vc_enable_queues_msg(vf, msg, msglen);
+		i40e_vc_notify_vf_link_state(vf);
 		break;
 	case I40E_VIRTCHNL_OP_DISABLE_QUEUES:
 		ret = i40e_vc_disable_queues_msg(vf, msg, msglen);
@@ -1875,35 +1877,45 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 
 /**
  * i40e_vc_notify_link_state
- * @pf: pointer to the PF structure
+ * @vf: pointer to the VF structure
  *
- * send a link status message to all VFs on a given PF
+ * send a link status message to a single VF
  **/
-void i40e_vc_notify_link_state(struct i40e_pf *pf)
+static void i40e_vc_notify_vf_link_state(struct i40e_vf *vf)
 {
 	struct i40e_virtchnl_pf_event pfe;
+	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
-	struct i40e_vf *vf = pf->vf;
 	struct i40e_link_status *ls = &pf->hw.phy.link_info;
-	int i;
+	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
-	for (i = 0; i < pf->num_alloc_vfs; i++, vf++) {
-		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
-		if (vf->link_forced) {
-			pfe.event_data.link_event.link_status = vf->link_up;
-			pfe.event_data.link_event.link_speed =
-				(vf->link_up ? I40E_LINK_SPEED_40GB : 0);
-		} else {
-			pfe.event_data.link_event.link_status =
-				ls->link_info & I40E_AQ_LINK_UP;
-			pfe.event_data.link_event.link_speed = ls->link_speed;
-		}
-		i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
-				       0, (u8 *)&pfe, sizeof(pfe),
-				       NULL);
+	if (vf->link_forced) {
+		pfe.event_data.link_event.link_status = vf->link_up;
+		pfe.event_data.link_event.link_speed =
+			(vf->link_up ? I40E_LINK_SPEED_40GB : 0);
+	} else {
+		pfe.event_data.link_event.link_status =
+			ls->link_info & I40E_AQ_LINK_UP;
+		pfe.event_data.link_event.link_speed = ls->link_speed;
 	}
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
 }
 
 /**
-- 
1.9.3
