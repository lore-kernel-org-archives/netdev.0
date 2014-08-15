From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] i40e: Fix for recent kernel panic
Date: Fri, 15 Aug 2014 04:37:51 -0700
Message-ID: <1408102673-27206-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Ashish N Shah <ashish.n.shah@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39386 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbaHOLi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 07:38:29 -0400
In-Reply-To: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Whenever we get a Tx hang we issue a PFR, which means we send AQ
messages to VFS about the reset coming. Unfortunately with the recent
fix to be able to send messages to all VFS which earlier was not
happening at all we now are sending messages to not just the VFS that
are up but also to VFS that are not up.  AQ complains about this and
sends us an error in ARQ called LAN overflow event for a queue. We
check if the queue belongs to a VF and if it does we try to send a
vc_notify_vf_reset message to that VF. Well if the VF is not up/enabled
we will be entering this function with a non-active VF id. In this
function we were assuming VF struct is populated but it won't be if
the VF is not active.

Change-ID: Ic6733cda4582d3609fe6d83b2872bb2dcdc73f4a
Signed-off-by: Ashish N Shah <ashish.n.shah@intel.com>
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 8967255..502b534 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1928,17 +1928,22 @@ static void i40e_vc_vf_broadcast(struct i40e_pf *pf,
 {
 	struct i40e_hw *hw = &pf->hw;
 	struct i40e_vf *vf = pf->vf;
-	int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
+	int abs_vf_id;
 	int i;
 
 	for (i = 0; i < pf->num_alloc_vfs; i++) {
+		/* Not all vfs are enabled so skip the ones that are not */
+		if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
+		    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+			continue;
+
 		/* Ignore return value on purpose - a given VF may fail, but
 		 * we need to keep going and send to all of them
 		 */
+		abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 		i40e_aq_send_msg_to_vf(hw, abs_vf_id, v_opcode, v_retval,
 				       msg, msglen, NULL);
 		vf++;
-		abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 	}
 }
 
@@ -2002,7 +2007,14 @@ void i40e_vc_notify_reset(struct i40e_pf *pf)
 void i40e_vc_notify_vf_reset(struct i40e_vf *vf)
 {
 	struct i40e_virtchnl_pf_event pfe;
-	int abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
+	int abs_vf_id;
+
+	/* verify if the VF is in either init or active before proceeding */
+	if (!test_bit(I40E_VF_STAT_INIT, &vf->vf_states) &&
+	    !test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states))
+		return;
+
+	abs_vf_id = vf->vf_id + vf->pf->hw.func_caps.vf_base_id;
 
 	pfe.event = I40E_VIRTCHNL_EVENT_RESET_IMPENDING;
 	pfe.severity = I40E_PF_EVENT_SEVERITY_CERTAIN_DOOM;
-- 
1.9.3
