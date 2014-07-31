From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 05/15] i40e: use correct vf_id offset for virtchnl message
Date: Wed, 30 Jul 2014 17:32:01 -0700
Message-ID: <1406766731-4209-6-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64996 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034AbaGaA2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:18 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

The vf_id needs to be offset by the vf_base_id from hw function capabilities
for the case of multiple PFs.

Change-ID: I20ca8621f98e9cdf98649380b8eeaa35db52677c
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cafda0c..504bdf5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1005,7 +1005,7 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 {
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
-	int true_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	i40e_status aq_ret;
 
 	/* single place to detect unsuccessful return values */
@@ -1025,7 +1025,7 @@ static int i40e_vc_send_msg_to_vf(struct i40e_vf *vf, u32 v_opcode,
 		vf->num_valid_msgs++;
 	}
 
-	aq_ret = i40e_aq_send_msg_to_vf(hw, true_vf_id,	v_opcode, v_retval,
+	aq_ret = i40e_aq_send_msg_to_vf(hw, abs_vf_id,	v_opcode, v_retval,
 					msg, msglen, NULL);
 	if (aq_ret) {
 		dev_err(&pf->pdev->dev,
@@ -1935,15 +1935,17 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 {
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf = pf->vf;
+	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	int i;
 
 	for (i = 0; i < pf->num_alloc_vfs; i++) {
 		/* Ignore return value on purpose - a given VF may fail, but
 		 * we need to keep going and send to all of them
 		 */
-		i40e_aq_send_msg_to_vf(hw, vf->vf_id, v_opcode, v_retval,
+		i40e_aq_send_msg_to_vf(hw, abs_vf_id, v_opcode, v_retval,
 				       msg, msglen, NULL);
 		vf++;
+		abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	}
 }
 
@@ -1959,6 +1961,7 @@ void i40e_vc_notify_link_state(struct i40e_pf *pf)
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf = pf->vf;
 	struct i40e_link_status *ls = &pf->hw.phy.link_info;
+	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	int i;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
@@ -1973,10 +1976,11 @@ void i40e_vc_notify_link_state(struct i40e_pf *pf)
 				ls->link_info & I40E_AQ_LINK_UP;
 			pfe.event_data.link_event.link_speed = ls->link_speed;
 		}
-		i40e_aq_send_msg_to_vf(hw, vf->vf_id, I40E_VIRTCHNL_OP_EVENT,
+		i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 				       0, (u8 *)&pfe, sizeof(pfe),
 				       NULL);
 		vf++;
+		abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	}
 }
 
@@ -2005,10 +2009,11 @@ void i40e_vc_notify_reset(struct i40e_pf *pf)
 void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
 {
 	struct i40e_virtchnl_pf_event pfe;
+	int abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
-	i40e_aq_send_msg_to_vf(&vf->pf->hw, vf->vf_id, I40E_VIRTCHNL_OP_EVENT,
+	i40e_aq_send_msg_to_vf(&vf->pf->hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 			       I40E_SUCCESS, (u8 *)&pfe,
 			       sizeof(struct i40e_virtchnl_pf_event), NULL);
 }
@@ -2345,6 +2350,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 	struct i40e_virtchnl_pf_event pfe;
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf;
+	int abs_vf_id;
 	int ret = 0;
 
 	/* validate the request */
@@ -2355,6 +2361,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 	}
 
 	vf = &pf->vf[vf_id];
+	abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_LINK_CHANGE;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_INFO;
@@ -2384,7 +2391,7 @@ int i40e_ndo_set_vf_link_state(struct net_device *netdev, int vf_id, int link)
 		goto error_out;
 	}
 	/* Notify the VF of its new link state */
-	i40e_aq_send_msg_to_vf(hw, vf->vf_id, I40E_VIRTCHNL_OP_EVENT,
+	i40e_aq_send_msg_to_vf(hw, abs_vf_id, I40E_VIRTCHNL_OP_EVENT,
 			       0, (u8 *)&pfe, sizeof(pfe), NULL);
 
 error_out:
-- 
1.9.3
