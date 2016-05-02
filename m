From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Limit the number of MAC and VLAN addresses that can be added for VFs
Date: Sun,  1 May 2016 17:06:08 -0700
Message-ID: <1462147581-135254-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbcEBAGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:23 -0400
In-Reply-To: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

If the VF is privileged/trusted it can do as it may please including
but not limited to hogging resources and playing unfair.
But if the VF is not privileged/trusted it still can add some number
(8) of MAC and VLAN addresses.
Other restrictions with respect to Port VLAN and normal VLAN still apply
to not privileged/trusted VF.

Change-Id: I3a9529201b184c8873e1ad2e300aff468c9e6296
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 25 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  3 +++
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4c365d7..a8a65e0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1831,6 +1831,10 @@ error_param:
 				      (u8 *)&stats, sizeof(stats));
 }
 
+/* If the VF is not trusted restrict the number of MAC/VLAN it can program */
+#define I40E_VC_MAX_MAC_ADDR_PER_VF 8
+#define I40E_VC_MAX_VLAN_PER_VF 8
+
 /**
  * i40e_check_vf_permission
  * @vf: pointer to the VF info
@@ -1863,6 +1867,11 @@ static inline int i40e_check_vf_permission(struct i40e_vf *vf, u8 *macaddr)
 		dev_err(&pf->pdev->dev,
 			"VF attempting to override administratively set MAC address, reload the VF driver to resume normal operation\n");
 		ret = -EPERM;
+	} else if ((vf->num_mac >= I40E_VC_MAX_MAC_ADDR_PER_VF) &&
+		   !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+		dev_err(&pf->pdev->dev,
+			"VF is not trusted, switch the VF to trusted to add more functionality\n");
+		ret = -EPERM;
 	}
 	return ret;
 }
@@ -1924,6 +1933,8 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 			ret = I40E_ERR_PARAM;
 			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			goto error_param;
+		} else {
+			vf->num_mac++;
 		}
 	}
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
@@ -1982,6 +1993,8 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 			ret = I40E_ERR_INVALID_MAC_ADDR;
 			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			goto error_param;
+		} else {
+			vf->num_mac--;
 		}
 
 	spin_unlock_bh(&vsi->mac_filter_list_lock);
@@ -2016,8 +2029,13 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status aq_ret = 0;
 	int i;
 
+	if ((vf->num_vlan >= I40E_VC_MAX_VLAN_PER_VF) &&
+	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+		dev_err(&pf->pdev->dev,
+			"VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
+		goto error_param;
+	}
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2041,6 +2059,8 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	for (i = 0; i < vfl->num_elements; i++) {
 		/* add new VLAN filter */
 		int ret = i40e_vsi_add_vlan(vsi, vfl->vlan_id[i]);
+		if (!ret)
+			vf->num_vlan++;
 
 		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
@@ -2083,7 +2103,6 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	int i;
 
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
@@ -2104,6 +2123,8 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	for (i = 0; i < vfl->num_elements; i++) {
 		int ret = i40e_vsi_kill_vlan(vsi, vfl->vlan_id[i]);
+		if (!ret)
+			vf->num_vlan--;
 
 		if (test_bit(I40E_VF_STAT_UC_PROMISC, &vf->vf_states))
 			i40e_aq_set_vsi_uc_promisc_on_vlan(&pf->hw, vsi->seid,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 8cbf579..bf54873 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -111,6 +111,9 @@ struct i40e_vf {
 	bool link_forced;
 	bool link_up;		/* only valid if VF link is forced */
 	bool spoofchk;
+	u16 num_mac;
+	u16 num_vlan;
+
 	/* RDMA Client */
 	struct i40e_virtchnl_iwarp_qvlist_info *qvlist_info;
 };
-- 
2.5.5
