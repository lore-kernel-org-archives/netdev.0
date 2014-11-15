From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] i40e: Check for LLDP AdminStatus before querying DCBX
Date: Fri, 14 Nov 2014 22:08:30 -0800
Message-ID: <1416031715-32498-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42056 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbaKOGIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:42 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch adds a check whether LLDP Agent's default AdminStatus is
enabled or disabled on a given port. If it is disabled then it sets
the DCBX status to disabled as well; and would not query firmware for
any DCBX configuration data.

Change-ID: I73c0b9f0adbf4cae177d14914b20a48c9a8f50fd
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c       | 49 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h      | 12 ++++++
 3 files changed, 63 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 1396c70..3ce4358 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -640,10 +640,27 @@ out:
 i40e_status i40e_init_dcb(struct i40e_hw *hw)
 {
 	i40e_status ret = 0;
+	struct i40e_lldp_variables lldp_cfg;
+	u8 adminstatus = 0;
 
 	if (!hw->func_caps.dcb)
 		return ret;
 
+	/* Read LLDP NVM area */
+	ret = i40e_read_lldp_cfg(hw, &lldp_cfg);
+	if (ret)
+		return ret;
+
+	/* Get the LLDP AdminStatus for the current port */
+	adminstatus = lldp_cfg.adminstatus >> (hw->port * 4);
+	adminstatus &= 0xF;
+
+	/* LLDP agent disabled */
+	if (!adminstatus) {
+		hw->dcbx_status = I40E_DCBX_STATUS_DISABLED;
+		return ret;
+	}
+
 	/* Get DCBX status */
 	ret = i40e_get_dcbx_status(hw, &hw->dcbx_status);
 	if (ret)
@@ -655,6 +672,8 @@ i40e_status i40e_init_dcb(struct i40e_hw *hw)
 	case I40E_DCBX_STATUS_IN_PROGRESS:
 		/* Get current DCBX configuration */
 		ret = i40e_get_dcb_config(hw);
+		if (ret)
+			return ret;
 		break;
 	case I40E_DCBX_STATUS_DISABLED:
 		return ret;
@@ -671,3 +690,33 @@ i40e_status i40e_init_dcb(struct i40e_hw *hw)
 
 	return ret;
 }
+
+/**
+ * i40e_read_lldp_cfg - read LLDP Configuration data from NVM
+ * @hw: pointer to the HW structure
+ * @lldp_cfg: pointer to hold lldp configuration variables
+ *
+ * Reads the LLDP configuration data from NVM
+ **/
+i40e_status i40e_read_lldp_cfg(struct i40e_hw *hw,
+			       struct i40e_lldp_variables *lldp_cfg)
+{
+	i40e_status ret = 0;
+	u32 offset = (2 * I40E_NVM_LLDP_CFG_PTR);
+
+	if (!lldp_cfg)
+		return I40E_ERR_PARAM;
+
+	ret = i40e_acquire_nvm(hw, I40E_RESOURCE_READ);
+	if (ret)
+		goto err_lldp_cfg;
+
+	ret = i40e_aq_read_nvm(hw, I40E_SR_EMP_MODULE_PTR, offset,
+			       sizeof(struct i40e_lldp_variables),
+			       (u8 *)lldp_cfg,
+			       true, NULL);
+	i40e_release_nvm(hw);
+
+err_lldp_cfg:
+	return ret;
+}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 24bdc43..2fb4306 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -235,6 +235,8 @@ i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
 		struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_resume_port_tx(struct i40e_hw *hw,
 				   struct i40e_asq_cmd_details *cmd_details);
+i40e_status i40e_read_lldp_cfg(struct i40e_hw *hw,
+			       struct i40e_lldp_variables *lldp_cfg);
 /* i40e_common */
 i40e_status i40e_init_shared_code(struct i40e_hw *hw);
 i40e_status i40e_pf_reset(struct i40e_hw *hw);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index afe2539..c852143 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1377,6 +1377,18 @@ enum i40e_reset_type {
 	I40E_RESET_EMPR		= 3,
 };
 
+/* IEEE 802.1AB LLDP Agent Variables from NVM */
+#define I40E_NVM_LLDP_CFG_PTR		0xD
+struct i40e_lldp_variables {
+	u16 length;
+	u16 adminstatus;
+	u16 msgfasttx;
+	u16 msgtxinterval;
+	u16 txparams;
+	u16 timers;
+	u16 crc8;
+};
+
 /* RSS Hash Table Size */
 #define I40E_PFQF_CTL_0_HASHLUTSIZE_512	0x00010000
 #endif /* _I40E_TYPE_H_ */
-- 
1.9.3
