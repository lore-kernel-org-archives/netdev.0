From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: support virtual channel API 1.1
Date: Thu, 23 Jul 2015 06:52:39 -0700
Message-ID: <1437659564-48822-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:7061 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815AbbGWNw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 09:52:58 -0400
In-Reply-To: <1437659564-48822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Store off the VF API version for use when figuring out the VF driver
capabilities. Add support for the VF driver handing its capabilities to
the PF driver and then use this information when sending VF resource
information back to the VF driver.

Change-ID: Ic00d0eeeb5b8118085e12f068ef857089a8f7c2d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 25 ++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 ++
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fdd7f5e..176a289 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1121,12 +1121,13 @@ static int i40e_vc_send_resp_to_vf(struct i40e_vf *vf,
  *
  * called from the VF to request the API version used by the PF
  **/
-static int i40e_vc_get_version_msg(struct i40e_vf *vf)
+static int i40e_vc_get_version_msg(struct i40e_vf *vf, u8 *msg)
 {
 	struct i40e_virtchnl_version_info info = {
 		I40E_VIRTCHNL_VERSION_MAJOR, I40E_VIRTCHNL_VERSION_MINOR
 	};
 
+	vf->vf_ver = *(struct i40e_virtchnl_version_info *)msg;
 	return i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_VERSION,
 				      I40E_SUCCESS, (u8 *)&info,
 				      sizeof(struct
@@ -1141,7 +1142,7 @@ static int i40e_vc_get_version_msg(struct i40e_vf *vf)
  *
  * called from the VF to request its resources
  **/
-static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf)
+static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 {
 	struct i40e_virtchnl_vf_resource *vfres = NULL;
 	struct i40e_pf *pf = vf->pf;
@@ -1165,11 +1166,18 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf)
 		len = 0;
 		goto err;
 	}
+	if (VF_IS_V11(vf))
+		vf->driver_caps = *(u32 *)msg;
+	else
+		vf->driver_caps = I40E_VIRTCHNL_VF_OFFLOAD_L2 |
+				  I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG |
+				  I40E_VIRTCHNL_VF_OFFLOAD_VLAN;
 
 	vfres->vf_offload_flags = I40E_VIRTCHNL_VF_OFFLOAD_L2;
 	vsi = pf->vsi[vf->lan_vsi_idx];
 	if (!vsi->info.pvid)
-		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_VLAN;
+		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_VLAN |
+					   I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG;
 
 	vfres->num_vsis = num_vsis;
 	vfres->num_queue_pairs = vf->num_queue_pairs;
@@ -1771,9 +1779,14 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 		valid_len = sizeof(struct i40e_virtchnl_version_info);
 		break;
 	case I40E_VIRTCHNL_OP_RESET_VF:
-	case I40E_VIRTCHNL_OP_GET_VF_RESOURCES:
 		valid_len = 0;
 		break;
+	case I40E_VIRTCHNL_OP_GET_VF_RESOURCES:
+		if (VF_IS_V11(vf))
+			valid_len = sizeof(u32);
+		else
+			valid_len = 0;
+		break;
 	case I40E_VIRTCHNL_OP_CONFIG_TX_QUEUE:
 		valid_len = sizeof(struct i40e_virtchnl_txq_info);
 		break;
@@ -1886,10 +1899,10 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 
 	switch (v_opcode) {
 	case I40E_VIRTCHNL_OP_VERSION:
-		ret = i40e_vc_get_version_msg(vf);
+		ret = i40e_vc_get_version_msg(vf, msg);
 		break;
 	case I40E_VIRTCHNL_OP_GET_VF_RESOURCES:
-		ret = i40e_vc_get_vf_resources_msg(vf);
+		ret = i40e_vc_get_vf_resources_msg(vf, msg);
 		break;
 	case I40E_VIRTCHNL_OP_RESET_VF:
 		i40e_vc_reset_vf_msg(vf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index d254a5e..736f6f0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -78,6 +78,8 @@ struct i40e_vf {
 	u16 vf_id;
 	/* all VF vsis connect to the same parent */
 	enum i40e_switch_element_types parent_type;
+	struct i40e_virtchnl_version_info vf_ver;
+	u32 driver_caps; /* reported by VF driver */
 
 	/* VF Port Extender (PE) stag if used */
 	u16 stag;
-- 
2.4.3
