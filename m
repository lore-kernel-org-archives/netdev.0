From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: Add VF promiscuous mode driver support
Date: Tue, 26 Apr 2016 13:55:47 -0700
Message-ID: <1461704148-114349-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64065 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865AbcDZUzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:55:55 -0400
In-Reply-To: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add infrastructure for Network Function Virtualization VLAN tagged
packet steering feature.

Change-Id: I9b873d8fcc253858e6baba65ac68ec5b9363944e
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 153 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +
 2 files changed, 149 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index c364588..f47b0e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1427,6 +1427,25 @@ static void i40e_vc_reset_vf_msg(struct i40e_vf *vf)
 }
 
 /**
+ * i40e_getnum_vf_vsi_vlan_filters
+ * @vsi: pointer to the vsi
+ *
+ * called to get the number of VLANs offloaded on this VF
+ **/
+static inline int i40e_getnum_vf_vsi_vlan_filters(struct i40e_vsi *vsi)
+{
+	struct i40e_mac_filter *f;
+	int num_vlans = 0;
+
+	list_for_each_entry(f, &vsi->mac_filter_list, list) {
+		if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
+			num_vlans++;
+	}
+
+	return num_vlans;
+}
+
+/**
  * i40e_vc_config_promiscuous_mode_msg
  * @vf: pointer to the VF info
  * @msg: pointer to the msg buffer
@@ -1442,22 +1461,122 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 	    (struct i40e_virtchnl_promisc_info *)msg;
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_hw *hw = &pf->hw;
-	struct i40e_vsi *vsi;
+	struct i40e_mac_filter *f;
+	i40e_status aq_ret = 0;
 	bool allmulti = false;
-	i40e_status aq_ret;
+	struct i40e_vsi *vsi;
+	bool alluni = false;
+	int aq_err = 0;
 
 	vsi = i40e_find_vsi_from_id(pf, info->vsi_id);
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
 	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
-	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id) ||
-	    (vsi->type != I40E_VSI_FCOE)) {
+	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id)) {
+		dev_err(&pf->pdev->dev,
+			"VF %d doesn't meet requirements to enter promiscuous mode\n",
+			vf->vf_id);
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
+	/* Multicast promiscuous handling*/
 	if (info->flags & I40E_FLAG_VF_MULTICAST_PROMISC)
 		allmulti = true;
-	aq_ret = i40e_aq_set_vsi_multicast_promiscuous(hw, vsi->seid,
-						       allmulti, NULL);
+
+	if (vf->port_vlan_id) {
+		aq_ret = i40e_aq_set_vsi_mc_promisc_on_vlan(hw, vsi->seid,
+							    allmulti,
+							    vf->port_vlan_id,
+							    NULL);
+	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
+		list_for_each_entry(f, &vsi->mac_filter_list, list) {
+			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
+				aq_ret = i40e_aq_set_vsi_mc_promisc_on_vlan
+								   (hw,
+								   vsi->seid,
+								   allmulti,
+								   f->vlan,
+								   NULL);
+			aq_err = pf->hw.aq.asq_last_status;
+			if (aq_ret) {
+				dev_err(&pf->pdev->dev,
+					"Could not add VLAN %d to multicast promiscuous domain err %s aq_err %s\n",
+					f->vlan,
+					i40e_stat_str(&pf->hw, aq_ret),
+					i40e_aq_str(&pf->hw, aq_err));
+				break;
+			}
+		}
+	} else {
+		aq_ret = i40e_aq_set_vsi_multicast_promiscuous(hw, vsi->seid,
+							       allmulti, NULL);
+		aq_err = pf->hw.aq.asq_last_status;
+		if (aq_ret) {
+			dev_err(&pf->pdev->dev,
+				"VF %d failed to set multicast promiscuous mode err %s aq_err %s\n",
+				vf->vf_id,
+				i40e_stat_str(&pf->hw, aq_ret),
+				i40e_aq_str(&pf->hw, aq_err));
+			goto error_param_int;
+		}
+	}
+
+	if (!aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "VF %d successfully set multicast promiscuous mode\n",
+			 vf->vf_id);
+		if (allmulti)
+			set_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states);
+		else
+			clear_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states);
+	}
+
+	if (info->flags & I40E_FLAG_VF_UNICAST_PROMISC)
+		alluni = true;
+	if (vf->port_vlan_id) {
+		aq_ret = i40e_aq_set_vsi_uc_promisc_on_vlan(hw, vsi->seid,
+							    alluni,
+							    vf->port_vlan_id,
+							    NULL);
+	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
+		list_for_each_entry(f, &vsi->mac_filter_list, list) {
+			aq_ret = 0;
+			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
+				aq_ret =
+				i40e_aq_set_vsi_uc_promisc_on_vlan(hw,
+								   vsi->seid,
+								   alluni,
+								   f->vlan,
+								   NULL);
+				aq_err = pf->hw.aq.asq_last_status;
+			if (aq_ret)
+				dev_err(&pf->pdev->dev,
+					"Could not add VLAN %d to Unicast promiscuous domain err %s aq_err %s\n",
+					f->vlan,
+					i40e_stat_str(&pf->hw, aq_ret),
+					i40e_aq_str(&pf->hw, aq_err));
+		}
+	} else {
+		aq_ret = i40e_aq_set_vsi_unicast_promiscuous(hw, vsi->seid,
+							     allmulti, NULL);
+		aq_err = pf->hw.aq.asq_last_status;
+		if (aq_ret)
+			dev_err(&pf->pdev->dev,
+				"VF %d failed to set unicast promiscuous mode %8.8x err %s aq_err %s\n",
+				vf->vf_id, info->flags,
+				i40e_stat_str(&pf->hw, aq_ret),
+				i40e_aq_str(&pf->hw, aq_err));
+	}
+
+error_param_int:
+	if (!aq_ret) {
+		dev_info(&pf->pdev->dev,
+			 "VF %d successfully set unicast promiscuous mode\n",
+			 vf->vf_id);
+		if (alluni)
+			set_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states);
+		else
+			clear_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states);
+	}
 
 error_param:
 	/* send the response to the VF */
@@ -1919,6 +2038,17 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		/* add new VLAN filter */
 		int ret = i40e_vsi_add_vlan(vsi, vfl->vlan_id[i]);
 
+		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
+			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
+							   true,
+							   vfl->vlan_id[i],
+							   NULL);
+		if (test_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states))
+			i40e_aq_set_vsi_mc_promisc_on_vlan(&pf->hw, vsi->seid,
+							   true,
+							   vfl->vlan_id[i],
+							   NULL);
+
 		if (ret)
 			dev_err(&pf->pdev->dev,
 				"Unable to add VLAN filter %d for VF %d, error %d\n",
@@ -1971,6 +2101,17 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	for (i = 0; i < vfl->num_elements; i++) {
 		int ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
 
+		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
+			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
+							   false,
+							   vfl->vlan_id[i],
+							   NULL);
+		if (test_bit(I40E_VF_STAT_MC_PROMISC, &vf->vf_states))
+			i40e_aq_set_vsi_mc_promisc_on_vlan(&pf->hw, vsi->seid,
+							   false,
+							   vfl->vlan_id[i],
+							   NULL);
+
 		if (ret)
 			dev_err(&pf->pdev->dev,
 				"Unable to delete VLAN filter %d for VF %d, error %d\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 838cbd2..8cbf579 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -61,6 +61,8 @@ enum i40e_vf_states {
 	I40E_VF_STAT_IWARPENA,
 	I40E_VF_STAT_FCOEENA,
 	I40E_VF_STAT_DISABLED,
+	I40E_VF_STAT_MC_PROMISC,
+	I40E_VF_STAT_UC_PROMISC,
 };
 
 /* VF capabilities */
-- 
2.5.5
