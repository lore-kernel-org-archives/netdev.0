From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] i40e/i40evf: Store CEE DCBX DesiredCfg and RemoteCfg
Date: Thu,  8 Oct 2015 18:32:43 -0700
Message-ID: <1444354374-24351-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbbJIBc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:58 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch adds capability to query and store the CEE DCBX DesiredCfg
and RemoteCfg data from the LLDP MIB.
Added new member "desired_dcbx_config" in the i40e_hw data structure
to hold CEE only DesiredCfg data.

Change-ID: I19c550369594384eaff4cc63e690ca740231195d
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c    | 44 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  5 +--
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  5 +--
 3 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 89e60e3..fbec7d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -762,6 +762,36 @@ static void i40e_cee_to_dcb_config(
 }
 
 /**
+ * i40e_get_ieee_dcb_config
+ * @hw: pointer to the hw struct
+ *
+ * Get IEEE mode DCB configuration from the Firmware
+ **/
+static i40e_status i40e_get_ieee_dcb_config(struct i40e_hw *hw)
+{
+	i40e_status ret = 0;
+
+	/* IEEE mode */
+	hw->local_dcbx_config.dcbx_mode = I40E_DCBX_MODE_IEEE;
+	/* Get Local DCB Config */
+	ret = i40e_aq_get_dcb_config(hw, I40E_AQ_LLDP_MIB_LOCAL, 0,
+				     &hw->local_dcbx_config);
+	if (ret)
+		goto out;
+
+	/* Get Remote DCB Config */
+	ret = i40e_aq_get_dcb_config(hw, I40E_AQ_LLDP_MIB_REMOTE,
+				     I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
+				     &hw->remote_dcbx_config);
+	/* Don't treat ENOENT as an error for Remote MIBs */
+	if (hw->aq.asq_last_status == I40E_AQ_RC_ENOENT)
+		ret = 0;
+
+out:
+	return ret;
+}
+
+/**
  * i40e_get_dcb_config
  * @hw: pointer to the hw struct
  *
@@ -776,7 +806,7 @@ i40e_status i40e_get_dcb_config(struct i40e_hw *hw)
 	/* If Firmware version < v4.33 IEEE only */
 	if (((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver < 33)) ||
 	    (hw->aq.fw_maj_ver < 4))
-		goto ieee;
+		return i40e_get_ieee_dcb_config(hw);
 
 	/* If Firmware version == v4.33 use old CEE struct */
 	if ((hw->aq.fw_maj_ver == 4) && (hw->aq.fw_min_ver == 33)) {
@@ -805,16 +835,14 @@ i40e_status i40e_get_dcb_config(struct i40e_hw *hw)
 
 	/* CEE mode not enabled try querying IEEE data */
 	if (hw->aq.asq_last_status == I40E_AQ_RC_ENOENT)
-		goto ieee;
-	else
+		return i40e_get_ieee_dcb_config(hw);
+
+	if (ret)
 		goto out;
 
-ieee:
-	/* IEEE mode */
-	hw->local_dcbx_config.dcbx_mode = I40E_DCBX_MODE_IEEE;
-	/* Get Local DCB Config */
+	/* Get CEE DCB Desired Config */
 	ret = i40e_aq_get_dcb_config(hw, I40E_AQ_LLDP_MIB_LOCAL, 0,
-				     &hw->local_dcbx_config);
+				     &hw->desired_dcbx_config);
 	if (ret)
 		goto out;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 34720e0..1c0bedb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -510,8 +510,9 @@ struct i40e_hw {
 	u16 dcbx_status;
 
 	/* DCBX info */
-	struct i40e_dcbx_config local_dcbx_config;
-	struct i40e_dcbx_config remote_dcbx_config;
+	struct i40e_dcbx_config local_dcbx_config; /* Oper/Local Cfg */
+	struct i40e_dcbx_config remote_dcbx_config; /* Peer Cfg */
+	struct i40e_dcbx_config desired_dcbx_config; /* CEE Desired Cfg */
 
 	/* debug mask */
 	u32 debug_mask;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index bbb3886..4b5528d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -504,8 +504,9 @@ struct i40e_hw {
 	u16 dcbx_status;
 
 	/* DCBX info */
-	struct i40e_dcbx_config local_dcbx_config;
-	struct i40e_dcbx_config remote_dcbx_config;
+	struct i40e_dcbx_config local_dcbx_config; /* Oper/Local Cfg */
+	struct i40e_dcbx_config remote_dcbx_config; /* Peer Cfg */
+	struct i40e_dcbx_config desired_dcbx_config; /* CEE Desired Cfg */
 
 	/* debug mask */
 	u32 debug_mask;
-- 
2.4.3
