From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/16] i40e/i40evf: Add module_types and update_link_info
Date: Tue, 13 Oct 2015 23:59:51 -0700
Message-ID: <1444805996-3877-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47517 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbbJNHAC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 03:00:02 -0400
In-Reply-To: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Add a module_types variable to the link_info struct to save the module
information from get_phy_capabilities. This information can be used to
determine which speeds the module supports.

Also add a new function update_link_info which updates the module_types
parameter and then calls get_link_info. This function should be called
in place of get_link_info so that the module_types variable stays
up-to-date with the rest of the link information.

The EAS table does not reflect the values that are actually returned,
so instead, basing these values on the Ethernet compliance codes
specified in table 33 of SFF-8436 as these have been accurate.

Use the new variable in ethtool to differentiate between a 10G/1G dual
speed fiber module and a 10G only module.

Change-ID: Ib7585cce321319c10ce15180054c41a6cbd41389
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 30 +++++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   | 16 +++++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h      | 18 ++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h    | 18 ++++++++++++++
 6 files changed, 76 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2d012d9..ffd1cd0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1717,14 +1717,14 @@ enum i40e_status_code i40e_set_fc(struct i40e_hw *hw, u8 *aq_failures,
 			*aq_failures |= I40E_SET_FC_AQ_FAIL_SET;
 	}
 	/* Update the link info */
-	status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+	status = i40e_update_link_info(hw);
 	if (status) {
 		/* Wait a little bit (on 40G cards it sometimes takes a really
 		 * long time for link to come back from the atomic reset)
 		 * and try once more
 		 */
 		msleep(1000);
-		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+		status = i40e_update_link_info(hw);
 	}
 	if (status)
 		*aq_failures |= I40E_SET_FC_AQ_FAIL_UPDATE;
@@ -2247,7 +2247,7 @@ i40e_status i40e_get_link_status(struct i40e_hw *hw, bool *link_up)
 	i40e_status status = 0;
 
 	if (hw->phy.get_link_info) {
-		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+		status = i40e_update_link_info(hw);
 
 		if (status)
 			i40e_debug(hw, I40E_DEBUG_LINK, "get link failed: status %d\n",
@@ -2260,6 +2260,30 @@ i40e_status i40e_get_link_status(struct i40e_hw *hw, bool *link_up)
 }
 
 /**
+ * i40e_updatelink_status - update status of the HW network link
+ * @hw: pointer to the hw struct
+ **/
+i40e_status i40e_update_link_info(struct i40e_hw *hw)
+{
+	struct i40e_aq_get_phy_abilities_resp abilities;
+	i40e_status status = 0;
+
+	status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+	if (status)
+		return status;
+
+	status = i40e_aq_get_phy_capabilities(hw, false, false, &abilities,
+					      NULL);
+	if (status)
+		return status;
+
+	memcpy(hw->phy.link_info.module_type, &abilities.module_type,
+	       sizeof(hw->phy.link_info.module_type));
+
+	return status;
+}
+
+/**
  * i40e_aq_add_veb - Insert a VEB between the VSI and the MAC
  * @hw: pointer to the hw struct
  * @uplink_seid: the MAC or other gizmo SEID
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 148f614..46019e9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -307,12 +307,18 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	case I40E_PHY_TYPE_10GBASE_LR:
 	case I40E_PHY_TYPE_1000BASE_SX:
 	case I40E_PHY_TYPE_1000BASE_LX:
-		ecmd->supported = SUPPORTED_10000baseT_Full |
-				  SUPPORTED_1000baseT_Full;
+		ecmd->supported = SUPPORTED_10000baseT_Full;
+		if (hw_link_info->module_type[2] &
+		    I40E_MODULE_TYPE_1000BASE_SX ||
+		    hw_link_info->module_type[2] &
+		    I40E_MODULE_TYPE_1000BASE_LX) {
+			ecmd->supported |= SUPPORTED_1000baseT_Full;
+			if (hw_link_info->requested_speeds &
+			    I40E_LINK_SPEED_1GB)
+				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		}
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 		break;
 	case I40E_PHY_TYPE_1000BASE_KX:
 		ecmd->supported = SUPPORTED_Autoneg |
@@ -704,7 +710,7 @@ static int i40e_set_settings(struct net_device *netdev,
 			return -EAGAIN;
 		}
 
-		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
+		status = i40e_update_link_info(hw);
 		if (status)
 			netdev_info(netdev, "Updating link info failed with err %s aq_err %s\n",
 				    i40e_stat_str(hw, status),
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 45b3292..dc80a5f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9728,7 +9728,7 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit)
 		i40e_config_rss(pf);
 
 	/* fill in link information and enable LSE reporting */
-	i40e_aq_get_link_info(&pf->hw, true, NULL, NULL);
+	i40e_update_link_info(&pf->hw);
 	i40e_link_event(pf);
 
 	/* Initialize user-specific link properties */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index e51e156..4454974 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -259,6 +259,7 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw);
 void i40e_clear_hw(struct i40e_hw *hw);
 void i40e_clear_pxe_mode(struct i40e_hw *hw);
 i40e_status i40e_get_link_status(struct i40e_hw *hw, bool *link_up);
+i40e_status i40e_update_link_info(struct i40e_hw *hw);
 i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr);
 i40e_status i40e_read_bw_from_alt_ram(struct i40e_hw *hw,
 				      u32 *max_bw, u32 *min_bw, bool *min_valid,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 102d0c4..0a450ac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -167,6 +167,24 @@ struct i40e_link_status {
 	bool crc_enable;
 	u8 pacing;
 	u8 requested_speeds;
+	u8 module_type[3];
+	/* 1st byte: module identifier */
+#define I40E_MODULE_TYPE_SFP		0x03
+#define I40E_MODULE_TYPE_QSFP		0x0D
+	/* 2nd byte: ethernet compliance codes for 10/40G */
+#define I40E_MODULE_TYPE_40G_ACTIVE	0x01
+#define I40E_MODULE_TYPE_40G_LR4	0x02
+#define I40E_MODULE_TYPE_40G_SR4	0x04
+#define I40E_MODULE_TYPE_40G_CR4	0x08
+#define I40E_MODULE_TYPE_10G_BASE_SR	0x10
+#define I40E_MODULE_TYPE_10G_BASE_LR	0x20
+#define I40E_MODULE_TYPE_10G_BASE_LRM	0x40
+#define I40E_MODULE_TYPE_10G_BASE_ER	0x80
+	/* 3rd byte: ethernet compliance codes for 1G */
+#define I40E_MODULE_TYPE_1000BASE_SX	0x01
+#define I40E_MODULE_TYPE_1000BASE_LX	0x02
+#define I40E_MODULE_TYPE_1000BASE_CX	0x04
+#define I40E_MODULE_TYPE_1000BASE_T	0x08
 };
 
 struct i40e_phy_info {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 6dbace3..f3155e3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -167,6 +167,24 @@ struct i40e_link_status {
 	bool crc_enable;
 	u8 pacing;
 	u8 requested_speeds;
+	u8 module_type[3];
+	/* 1st byte: module identifier */
+#define I40E_MODULE_TYPE_SFP		0x03
+#define I40E_MODULE_TYPE_QSFP		0x0D
+	/* 2nd byte: ethernet compliance codes for 10/40G */
+#define I40E_MODULE_TYPE_40G_ACTIVE	0x01
+#define I40E_MODULE_TYPE_40G_LR4	0x02
+#define I40E_MODULE_TYPE_40G_SR4	0x04
+#define I40E_MODULE_TYPE_40G_CR4	0x08
+#define I40E_MODULE_TYPE_10G_BASE_SR	0x10
+#define I40E_MODULE_TYPE_10G_BASE_LR	0x20
+#define I40E_MODULE_TYPE_10G_BASE_LRM	0x40
+#define I40E_MODULE_TYPE_10G_BASE_ER	0x80
+	/* 3rd byte: ethernet compliance codes for 1G */
+#define I40E_MODULE_TYPE_1000BASE_SX	0x01
+#define I40E_MODULE_TYPE_1000BASE_LX	0x02
+#define I40E_MODULE_TYPE_1000BASE_CX	0x04
+#define I40E_MODULE_TYPE_1000BASE_T	0x08
 };
 
 struct i40e_phy_info {
-- 
2.4.3
