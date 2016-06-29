From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e: add hw struct local variable
Date: Tue, 28 Jun 2016 21:40:48 -0700
Message-ID: <1467175262-54719-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbcF2EnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:16 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

This function uses the i40e_hw struct all over the place, so why doesn't
it keep a pointer to the struct? Add this pointer as a local variable
and use it consistently throughout the function.

Change-ID: I10eb688fe40909433fcb8ac7ac891cef67445d72
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 79 +++++++++++++++--------------
 1 file changed, 41 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 734cba6..9a26ecc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1840,6 +1840,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 {
 	struct list_head tmp_del_list, tmp_add_list;
 	struct i40e_mac_filter *f, *ftmp, *fclone;
+	struct i40e_hw *hw = &vsi->back->hw;
 	bool promisc_forced_on = false;
 	bool add_happened = false;
 	int filter_list_len = 0;
@@ -1920,7 +1921,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	if (!list_empty(&tmp_del_list)) {
 		int del_list_size;
 
-		filter_list_len = pf->hw.aq.asq_buf_size /
+		filter_list_len = hw->aq.asq_buf_size /
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
 		del_list_size = filter_list_len *
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
@@ -1952,12 +1953,11 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* flush a full buffer */
 			if (num_del == filter_list_len) {
-				aq_ret = i40e_aq_remove_macvlan(&pf->hw,
-								vsi->seid,
-								del_list,
-								num_del,
-								NULL);
-				aq_err = pf->hw.aq.asq_last_status;
+				aq_ret =
+					i40e_aq_remove_macvlan(hw, vsi->seid,
+							       del_list,
+							       num_del, NULL);
+				aq_err = hw->aq.asq_last_status;
 				num_del = 0;
 				memset(del_list, 0, del_list_size);
 
@@ -1965,8 +1965,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 					retval = -EIO;
 					dev_err(&pf->pdev->dev,
 						"ignoring delete macvlan error, err %s, aq_err %s while flushing a full buffer\n",
-						i40e_stat_str(&pf->hw, aq_ret),
-						i40e_aq_str(&pf->hw, aq_err));
+
+						 i40e_stat_str(hw, aq_ret),
+						 i40e_aq_str(hw, aq_err));
 				}
 			}
 			/* Release memory for MAC filter entries which were
@@ -1977,17 +1978,16 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		}
 
 		if (num_del) {
-			aq_ret = i40e_aq_remove_macvlan(&pf->hw, vsi->seid,
-							del_list, num_del,
-							NULL);
-			aq_err = pf->hw.aq.asq_last_status;
+			aq_ret = i40e_aq_remove_macvlan(hw, vsi->seid, del_list,
+							num_del, NULL);
+			aq_err = hw->aq.asq_last_status;
 			num_del = 0;
 
 			if (aq_ret && aq_err != I40E_AQ_RC_ENOENT)
 				dev_info(&pf->pdev->dev,
 					 "ignoring delete macvlan error, err %s aq_err %s\n",
-					 i40e_stat_str(&pf->hw, aq_ret),
-					 i40e_aq_str(&pf->hw, aq_err));
+					 i40e_stat_str(hw, aq_ret),
+					 i40e_aq_str(hw, aq_err));
 		}
 
 		kfree(del_list);
@@ -1998,7 +1998,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		int add_list_size;
 
 		/* do all the adds now */
-		filter_list_len = pf->hw.aq.asq_buf_size /
+		filter_list_len = hw->aq.asq_buf_size /
 			       sizeof(struct i40e_aqc_add_macvlan_element_data),
 		add_list_size = filter_list_len *
 			       sizeof(struct i40e_aqc_add_macvlan_element_data);
@@ -2033,10 +2033,10 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 
 			/* flush a full buffer */
 			if (num_add == filter_list_len) {
-				aq_ret = i40e_aq_add_macvlan(&pf->hw, vsi->seid,
+				aq_ret = i40e_aq_add_macvlan(hw, vsi->seid,
 							     add_list, num_add,
 							     NULL);
-				aq_err = pf->hw.aq.asq_last_status;
+				aq_err = hw->aq.asq_last_status;
 				num_add = 0;
 
 				if (aq_ret)
@@ -2051,9 +2051,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		}
 
 		if (num_add) {
-			aq_ret = i40e_aq_add_macvlan(&pf->hw, vsi->seid,
+			aq_ret = i40e_aq_add_macvlan(hw, vsi->seid,
 						     add_list, num_add, NULL);
-			aq_err = pf->hw.aq.asq_last_status;
+			aq_err = hw->aq.asq_last_status;
 			num_add = 0;
 		}
 		kfree(add_list);
@@ -2063,9 +2063,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			retval = i40e_aq_rc_to_posix(aq_ret, aq_err);
 			dev_info(&pf->pdev->dev,
 				 "add filter failed, err %s aq_err %s\n",
-				 i40e_stat_str(&pf->hw, aq_ret),
-				 i40e_aq_str(&pf->hw, aq_err));
-			if ((pf->hw.aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
+				 i40e_stat_str(hw, aq_ret),
+				 i40e_aq_str(hw, aq_err));
+			if ((hw->aq.asq_last_status == I40E_AQ_RC_ENOSPC) &&
 			    !test_bit(__I40E_FILTER_OVERFLOW_PROMISC,
 				      &vsi->state)) {
 				promisc_forced_on = true;
@@ -2093,12 +2093,11 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 							       NULL);
 		if (aq_ret) {
 			retval = i40e_aq_rc_to_posix(aq_ret,
-						     pf->hw.aq.asq_last_status);
+						     hw->aq.asq_last_status);
 			dev_info(&pf->pdev->dev,
 				 "set multi promisc failed, err %s aq_err %s\n",
-				 i40e_stat_str(&pf->hw, aq_ret),
-				 i40e_aq_str(&pf->hw,
-					     pf->hw.aq.asq_last_status));
+				 i40e_stat_str(hw, aq_ret),
+				 i40e_aq_str(hw, hw->aq.asq_last_status));
 		}
 	}
 	if ((changed_flags & IFF_PROMISC) || promisc_forced_on) {
@@ -2121,29 +2120,33 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			}
 		} else {
 			aq_ret = i40e_aq_set_vsi_unicast_promiscuous(
-							  &vsi->back->hw,
+							  hw,
 							  vsi->seid,
 							  cur_promisc, NULL,
 							  true);
 			if (aq_ret) {
 				retval =
 				i40e_aq_rc_to_posix(aq_ret,
-						    pf->hw.aq.asq_last_status);
+						    hw->aq.asq_last_status);
 				dev_info(&pf->pdev->dev,
-					 "set unicast promisc failed, err %d, aq_err %d\n",
-					 aq_ret, pf->hw.aq.asq_last_status);
+					 "set unicast promisc failed, err %s, aq_err %s\n",
+					 i40e_stat_str(hw, aq_ret),
+					 i40e_aq_str(hw,
+						     hw->aq.asq_last_status));
 			}
 			aq_ret = i40e_aq_set_vsi_multicast_promiscuous(
-							  &vsi->back->hw,
+							  hw,
 							  vsi->seid,
 							  cur_promisc, NULL);
 			if (aq_ret) {
 				retval =
 				i40e_aq_rc_to_posix(aq_ret,
-						    pf->hw.aq.asq_last_status);
+						    hw->aq.asq_last_status);
 				dev_info(&pf->pdev->dev,
-					 "set multicast promisc failed, err %d, aq_err %d\n",
-					 aq_ret, pf->hw.aq.asq_last_status);
+					 "set multicast promisc failed, err %s, aq_err %s\n",
+					 i40e_stat_str(hw, aq_ret),
+					 i40e_aq_str(hw,
+						     hw->aq.asq_last_status));
 			}
 		}
 		aq_ret = i40e_aq_set_vsi_broadcast(&vsi->back->hw,
@@ -2154,9 +2157,9 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 						     pf->hw.aq.asq_last_status);
 			dev_info(&pf->pdev->dev,
 				 "set brdcast promisc failed, err %s, aq_err %s\n",
-				 i40e_stat_str(&pf->hw, aq_ret),
-				 i40e_aq_str(&pf->hw,
-					     pf->hw.aq.asq_last_status));
+					 i40e_stat_str(hw, aq_ret),
+					 i40e_aq_str(hw,
+						     hw->aq.asq_last_status));
 		}
 	}
 out:
-- 
2.5.5
