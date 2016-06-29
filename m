From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/16] i40e: add VSI info to macaddr messages
Date: Tue, 28 Jun 2016 21:40:59 -0700
Message-ID: <1467175262-54719-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbcF2EnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:19 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Since the macaddr add and delete happens asynchronously, error
messages don't easily get associated to the actual request. Here
we add a bit of information to the error messages to help
determine the source of the error.

Change-ID: Id2d6df5287141c3579677d72d8bd21122823d79f
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 ++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d6a5106..880602f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1837,6 +1837,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	struct i40e_hw *hw = &vsi->back->hw;
 	bool promisc_forced_on = false;
 	bool add_happened = false;
+	char vsi_name[16] = "PF";
 	int filter_list_len = 0;
 	u32 changed_flags = 0;
 	i40e_status aq_ret = 0;
@@ -1864,6 +1865,11 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	INIT_LIST_HEAD(&tmp_del_list);
 	INIT_LIST_HEAD(&tmp_add_list);
 
+	if (vsi->type == I40E_VSI_SRIOV)
+		snprintf(vsi_name, sizeof(vsi_name) - 1, "VF %d", vsi->vf_id);
+	else if (vsi->type != I40E_VSI_MAIN)
+		snprintf(vsi_name, sizeof(vsi_name) - 1, "vsi %d", vsi->seid);
+
 	if (vsi->flags & I40E_VSI_FLAG_FILTER_CHANGED) {
 		vsi->flags &= ~I40E_VSI_FLAG_FILTER_CHANGED;
 
@@ -1958,8 +1964,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				if (aq_ret && aq_err != I40E_AQ_RC_ENOENT) {
 					retval = -EIO;
 					dev_err(&pf->pdev->dev,
-						"ignoring delete macvlan error, err %s, aq_err %s while flushing a full buffer\n",
-
+						 "ignoring delete macvlan error on %s, err %s, aq_err %s while flushing a full buffer\n",
+						 vsi_name,
 						 i40e_stat_str(hw, aq_ret),
 						 i40e_aq_str(hw, aq_err));
 				}
@@ -1979,7 +1985,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			if (aq_ret && aq_err != I40E_AQ_RC_ENOENT)
 				dev_info(&pf->pdev->dev,
-					 "ignoring delete macvlan error, err %s aq_err %s\n",
+					 "ignoring delete macvlan error on %s, err %s aq_err %s\n",
+					 vsi_name,
 					 i40e_stat_str(hw, aq_ret),
 					 i40e_aq_str(hw, aq_err));
 		}
@@ -2056,7 +2063,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		if (add_happened && aq_ret && aq_err != I40E_AQ_RC_EINVAL) {
 			retval = i40e_aq_rc_to_posix(aq_ret, aq_err);
 			dev_info(&pf->pdev->dev,
-				 "add filter failed, err %s aq_err %s\n",
+				 "add filter failed on %s, err %s aq_err %s\n",
+				 vsi_name,
 				 i40e_stat_str(hw, aq_ret),
 				 i40e_aq_str(hw, aq_err));
 			if ((hw->aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
@@ -2065,7 +2073,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				promisc_forced_on = true;
 				set_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 					&vsi->state);
-				dev_info(&pf->pdev->dev, "promiscuous mode forced on\n");
+				dev_info(&pf->pdev->dev, "promiscuous mode forced on %s\n",
+					 vsi_name);
 			}
 		}
 	}
@@ -2089,7 +2098,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			retval = i40e_aq_rc_to_posix(aq_ret,
 						     hw->aq.asq_last_status);
 			dev_info(&pf->pdev->dev,
-				 "set multi promisc failed, err %s aq_err %s\n",
+				 "set multi promisc failed on %s, err %s aq_err %s\n",
+				 vsi_name,
 				 i40e_stat_str(hw, aq_ret),
 				 i40e_aq_str(hw, hw->aq.asq_last_status));
 		}
@@ -2124,7 +2134,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 					retval = i40e_aq_rc_to_posix(aq_ret,
 							hw->aq.asq_last_status);
 					dev_info(&pf->pdev->dev,
-						 "Set default VSI failed, err %s, aq_err %s\n",
+						 "Set default VSI failed on %s, err %s, aq_err %s\n",
+						 vsi_name,
 						 i40e_stat_str(hw, aq_ret),
 						 i40e_aq_str(hw,
 						     hw->aq.asq_last_status));
@@ -2141,7 +2152,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				i40e_aq_rc_to_posix(aq_ret,
 						    hw->aq.asq_last_status);
 				dev_info(&pf->pdev->dev,
-					 "set unicast promisc failed, err %s, aq_err %s\n",
+					 "set unicast promisc failed on %s, err %s, aq_err %s\n",
+					 vsi_name,
 					 i40e_stat_str(hw, aq_ret),
 					 i40e_aq_str(hw,
 						     hw->aq.asq_last_status));
@@ -2155,7 +2167,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 				i40e_aq_rc_to_posix(aq_ret,
 						    hw->aq.asq_last_status);
 				dev_info(&pf->pdev->dev,
-					 "set multicast promisc failed, err %s, aq_err %s\n",
+					 "set multicast promisc failed on %s, err %s, aq_err %s\n",
+					 vsi_name,
 					 i40e_stat_str(hw, aq_ret),
 					 i40e_aq_str(hw,
 						     hw->aq.asq_last_status));
-- 
2.5.5
