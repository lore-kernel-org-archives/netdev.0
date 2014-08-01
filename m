From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 09/14] i40e: remove support for vf unicast promiscuous mode
Date: Fri,  1 Aug 2014 13:27:10 -0700
Message-ID: <1406924835-31550-10-git-send-email-aaron.f.brown@intel.com>
References: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18329 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbaHAUX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:28 -0400
In-Reply-To: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

Remove the ability of a VF to set unicast promiscuous mode.
Considered to be a security risk to allow VFs to receive traffic
intended for other VFs so don't allow it, simply ignore the flag.

Also fix it to send the correct seid to aq for multicast promiscuous set.

Change-ID: Icb9c49a281a8e9d3aeebf991ef1533ac82b84b14
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Jim Young  <jamesx.m.young@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 033d853..8967255 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1163,8 +1163,8 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 	    (struct i40e_virtchnl_promisc_info *)msg;
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
+	struct i40e_vsi *vsi;
 	bool allmulti = false;
-	bool promisc = false;
 	i40e_status aq_ret;
 
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
@@ -1174,17 +1174,10 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
-
-	if (info->flags & I40E_FLAG_VF_UNICAST_PROMISC)
-		promisc = true;
-	aq_ret = i40e_aq_set_vsi_unicast_promiscuous(hw, info->vsi_id,
-						     promisc, NULL);
-	if (aq_ret)
-		goto error_param;
-
+	vsi = pf->vsi[info->vsi_id];
 	if (info->flags & I40E_FLAG_VF_MULTICAST_PROMISC)
 		allmulti = true;
-	aq_ret = i40e_aq_set_vsi_multicast_promiscuous(hw, info->vsi_id,
+	aq_ret = i40e_aq_set_vsi_multicast_promiscuous(hw, vsi->seid,
 						       allmulti, NULL);
 
 error_param:
-- 
1.9.3
