From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: Add flag for L2 VEB filtering
Date: Fri,  6 Dec 2013 18:17:13 -0800
Message-ID: <1386382643-29055-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23891 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758126Ab3LGCR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:28 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

Add a new flag to the add VEB command which allows the
driver to request the hardware to filter on L2 parameters.

This is an implementation of the driver access to a new firmware
feature.

Change-Id: Id61d3cad4125bdc68b8fd9d555c448a10c344b6b
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 8 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 4 +++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h | 3 ++-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2cc01c2..1300d3d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -924,6 +924,7 @@ i40e_get_link_status_exit:
  * @downlink_seid: the VSI SEID
  * @enabled_tc: bitmap of TCs to be enabled
  * @default_port: true for default port VSI, false for control port
+ * @enable_l2_filtering: true to add L2 filter table rules to regular forwarding rules for cloud support
  * @veb_seid: pointer to where to put the resulting VEB SEID
  * @cmd_details: pointer to command details structure or NULL
  *
@@ -932,7 +933,8 @@ i40e_get_link_status_exit:
  **/
 i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
 				u16 downlink_seid, u8 enabled_tc,
-				bool default_port, u16 *veb_seid,
+				bool default_port, bool enable_l2_filtering,
+				u16 *veb_seid,
 				struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
@@ -958,6 +960,10 @@ i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
 		veb_flags |= I40E_AQC_ADD_VEB_PORT_TYPE_DEFAULT;
 	else
 		veb_flags |= I40E_AQC_ADD_VEB_PORT_TYPE_DATA;
+
+	if (enable_l2_filtering)
+		veb_flags |= I40E_AQC_ADD_VEB_ENABLE_L2_FILTER;
+
 	cmd->veb_flags = cpu_to_le16(veb_flags);
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5d234a1..b6d6494 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6525,11 +6525,13 @@ void i40e_veb_release(struct i40e_veb *veb)
 static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 {
 	bool is_default = (vsi->idx == vsi->back->lan_vsi);
+	bool is_cloud = false;
 	int ret;
 
 	/* get a VEB from the hardware */
 	ret = i40e_aq_add_veb(&veb->pf->hw, veb->uplink_seid, vsi->seid,
-			      veb->enabled_tc, is_default, &veb->seid, NULL);
+			      veb->enabled_tc, is_default,
+			      is_cloud, &veb->seid, NULL);
 	if (ret) {
 		dev_info(&veb->pf->pdev->dev,
 			 "couldn't add VEB, err %d, aq_err %d\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index f75bb9c..930f53a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -106,7 +106,8 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
 				u16 downlink_seid, u8 enabled_tc,
-				bool default_port, u16 *pveb_seid,
+				bool default_port, bool enable_l2_filtering,
+				u16 *pveb_seid,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_veb_parameters(struct i40e_hw *hw,
 				u16 veb_seid, u16 *switch_id, bool *floating,
-- 
1.8.3.1
