From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: add clear_pxe AdminQ request
Date: Thu, 29 May 2014 08:10:13 -0700
Message-ID: <1401376216-12531-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55978 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932782AbaE2PKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:40 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the clear_pxe AdminQ API call.

Change-ID: Ia770ff3404971bb3889b53a39c3a7bfaf3f4d399
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 30 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 ++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 4bea409..064b0aa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -793,6 +793,9 @@ void i40e_clear_pxe_mode(struct i40e_hw *hw)
 {
 	u32 reg;
 
+	if (i40e_check_asq_alive(hw))
+		i40e_aq_clear_pxe_mode(hw, NULL);
+
 	/* Clear single descriptor fetch/write-back mode */
 	reg = rd32(hw, I40E_GLLAN_RCTL_0);
 
@@ -911,6 +914,33 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
 /* Admin command wrappers */
 
 /**
+ * i40e_aq_clear_pxe_mode
+ * @hw: pointer to the hw struct
+ * @cmd_details: pointer to command details structure or NULL
+ *
+ * Tell the firmware that the driver is taking over from PXE
+ **/
+i40e_status i40e_aq_clear_pxe_mode(struct i40e_hw *hw,
+				struct i40e_asq_cmd_details *cmd_details)
+{
+	i40e_status status;
+	struct i40e_aq_desc desc;
+	struct i40e_aqc_clear_pxe *cmd =
+		(struct i40e_aqc_clear_pxe *)&desc.params.raw;
+
+	i40e_fill_default_direct_cmd_desc(&desc,
+					  i40e_aqc_opc_clear_pxe_mode);
+
+	cmd->rx_cnt = 0x2;
+
+	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	wr32(hw, I40E_GLLAN_RCTL_0, 0x1);
+
+	return status;
+}
+
+/**
  * i40e_aq_set_link_restart_an
  * @hw: pointer to the hw struct
  * @cmd_details: pointer to command details structure or NULL
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index d351832..57172f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -74,6 +74,8 @@ i40e_status i40e_aq_set_phy_reset(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw, u16 vsi_id,
 				struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_aq_clear_pxe_mode(struct i40e_hw *hw,
+				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
-- 
1.9.3
