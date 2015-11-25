From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40e/i40evf: clean up error messages
Date: Tue, 24 Nov 2015 16:04:41 -0800
Message-ID: <1448409886-90686-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:14673 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbbKYAEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:53 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Clean up and enhance error messages related to VF MAC/VLAN filters.
Indicate which VF is having issues, and if possible indicate the MAC
address or VLAN involved.

Also, when an error is returned from the PF driver, print useful
information about what went wrong, for the most likely cases.

Change-ID: Ib3d15eef9e3369a78fd142948671e5fa26d921b8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 21 +++++++++--------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 26 +++++++++++++++++++---
 2 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 44462b4..9c54ca2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1623,7 +1623,8 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		if (!f) {
 			dev_err(&pf->pdev->dev,
-				"Unable to add VF MAC filter\n");
+				"Unable to add MAC filter %pM for VF %d\n",
+				 al->list[i].addr, vf->vf_id);
 			ret = I40E_ERR_PARAM;
 			spin_unlock_bh(&vsi->mac_filter_list_lock);
 			goto error_param;
@@ -1633,7 +1634,8 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	/* program the updated filter list */
 	if (i40e_sync_vsi_filters(vsi, false))
-		dev_err(&pf->pdev->dev, "Unable to program VF MAC filters\n");
+		dev_err(&pf->pdev->dev, "Unable to program VF %d MAC filters\n",
+			vf->vf_id);
 
 error_param:
 	/* send the response to the VF */
@@ -1669,8 +1671,8 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	for (i = 0; i < al->num_elements; i++) {
 		if (is_broadcast_ether_addr(al->list[i].addr) ||
 		    is_zero_ether_addr(al->list[i].addr)) {
-			dev_err(&pf->pdev->dev, "invalid VF MAC addr %pM\n",
-				al->list[i].addr);
+			dev_err(&pf->pdev->dev, "Invalid MAC addr %pM for VF %d\n",
+				al->list[i].addr, vf->vf_id);
 			ret = I40E_ERR_INVALID_MAC_ADDR;
 			goto error_param;
 		}
@@ -1686,7 +1688,8 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 	/* program the updated filter list */
 	if (i40e_sync_vsi_filters(vsi, false))
-		dev_err(&pf->pdev->dev, "Unable to program VF MAC filters\n");
+		dev_err(&pf->pdev->dev, "Unable to program VF %d MAC filters\n",
+			vf->vf_id);
 
 error_param:
 	/* send the response to the VF */
@@ -1740,8 +1743,8 @@ static int i40e_vc_add_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		if (ret)
 			dev_err(&pf->pdev->dev,
-				"Unable to add VF vlan filter %d, error %d\n",
-				vfl->vlan_id[i], ret);
+				"Unable to add VLAN filter %d for VF %d, error %d\n",
+				vfl->vlan_id[i], vf->vf_id, ret);
 	}
 
 error_param:
@@ -1792,8 +1795,8 @@ static int i40e_vc_remove_vlan_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 		if (ret)
 			dev_err(&pf->pdev->dev,
-				"Unable to delete VF vlan filter %d, error %d\n",
-				vfl->vlan_id[i], ret);
+				"Unable to delete VLAN filter %d for VF %d, error %d\n",
+				vfl->vlan_id[i], vf->vf_id, ret);
 	}
 
 error_param:
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 32e620e..091ef6a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -724,9 +724,29 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		return;
 	}
 	if (v_retval) {
-		dev_err(&adapter->pdev->dev, "PF returned error %d (%s) to our request %d\n",
-			v_retval, i40evf_stat_str(&adapter->hw, v_retval),
-			v_opcode);
+		switch (v_opcode) {
+		case I40E_VIRTCHNL_OP_ADD_VLAN:
+			dev_err(&adapter->pdev->dev, "Failed to add VLAN filter, error %s\n",
+				i40evf_stat_str(&adapter->hw, v_retval));
+			break;
+		case I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS:
+			dev_err(&adapter->pdev->dev, "Failed to add MAC filter, error %s\n",
+				i40evf_stat_str(&adapter->hw, v_retval));
+			break;
+		case I40E_VIRTCHNL_OP_DEL_VLAN:
+			dev_err(&adapter->pdev->dev, "Failed to delete VLAN filter, error %s\n",
+				i40evf_stat_str(&adapter->hw, v_retval));
+			break;
+		case I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS:
+			dev_err(&adapter->pdev->dev, "Failed to delete MAC filter, error %s\n",
+				i40evf_stat_str(&adapter->hw, v_retval));
+			break;
+		default:
+			dev_err(&adapter->pdev->dev, "PF returned error %d (%s) to our request %d\n",
+				v_retval,
+				i40evf_stat_str(&adapter->hw, v_retval),
+				v_opcode);
+		}
 	}
 	switch (v_opcode) {
 	case I40E_VIRTCHNL_OP_GET_STATS: {
-- 
2.5.0
