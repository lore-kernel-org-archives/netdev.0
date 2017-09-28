From: w00273186 <wangyunjian@huawei.com>
Subject: [PATCH net v2] i40e: Fix limit imprecise of the number of MAC/VLAN that can be added for VFs
Date: Thu, 28 Sep 2017 10:01:04 +0800
Message-ID: <1506564064-10740-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>,
        <caihe@huawei.com>, Yunjian Wang <wangyunjian@huawei.com>
To: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
        <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:7061 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751946AbdI1CBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 22:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yunjian Wang <wangyunjian@huawei.com>

Now it doesn't limit the number of MAC/VLAN strictly. When there is more
elements in the virtchnl MAC/VLAN list, it can still add successfully.

Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 27 +++++++++++++---------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4d1e670..285b96a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2065,11 +2065,6 @@ static inline int i40e_check_vf_permission(struct i40e_vf *vf, u8 *macaddr)
 		dev_err(&pf->pdev->dev,
 			"VF attempting to override administratively set MAC address, reload the VF driver to resume normal operation\n");
 		ret = -EPERM;
-	} else if ((vf->num_mac >= I40E_VC_MAX_MAC_ADDR_PER_VF) &&
-		   !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
-		dev_err(&pf->pdev->dev,
-			"VF is not trusted, switch the VF to trusted to add more functionality\n");
-		ret = -EPERM;
 	}
 	return ret;
 }
@@ -2128,6 +2123,15 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		} else {
 			vf->num_mac++;
 		}
+
+		if ((vf->num_mac >= I40E_VC_MAX_MAC_ADDR_PER_VF) &&
+		    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+			dev_err(&pf->pdev->dev,
+				"VF is not trusted, switch the VF to trusted to add more functionality\n");
+			ret = -EPERM;
+			spin_unlock_bh(&vsi->mac_filter_hash_lock);
+			goto error_param;
+		}
 	}
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
@@ -2221,12 +2225,6 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	i40e_status aq_ret = 0;
 	int i;
 
-	if ((vf->num_vlan >= I40E_VC_MAX_VLAN_PER_VF) &&
-	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
-		dev_err(&pf->pdev->dev,
-			"VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
-		goto error_param;
-	}
 	if (!test_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states) ||
 	    !i40e_vc_isvalid_vsi_id(vf, vsi_id)) {
 		aq_ret = I40E_ERR_PARAM;
@@ -2269,6 +2267,13 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 			dev_err(&pf->pdev->dev,
 				"Unable to add VLAN filter %d for VF %d, error %d\n",
 				vfl->vlan_id[i], vf->vf_id, ret);
+		if ((vf->num_vlan >= I40E_VC_MAX_VLAN_PER_VF) &&
+		    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+			dev_err(&pf->pdev->dev,
+				"VF is not trusted, switch the VF to trusted to add more VLAN addresses\n");
+			aq_ret = -EPERM;
+			goto error_param;
+		}
 	}
 
 error_param:
-- 
1.8.3.1
