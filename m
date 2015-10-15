From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] i40e: Remove 100M SGMII unless hw is X722
Date: Thu, 15 Oct 2015 02:39:53 -0700
Message-ID: <1444902004-14433-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31273 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbbJOJm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:26 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Only the X722 device now supports 100M SGMII, and nothing supports
100M on 1000Base_T.

Change-ID: I6f44dcd818944edd40041410e6de380f4a359a0c
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 42 ++++++++++++++++----------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 185ac91..b311391 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -255,7 +255,8 @@ static void i40e_partition_setting_complaint(struct i40e_pf *pf)
  **/
 static void i40e_get_settings_link_up(struct i40e_hw *hw,
 				      struct ethtool_cmd *ecmd,
-				      struct net_device *netdev)
+				      struct net_device *netdev,
+				      struct i40e_pf *pf)
 {
 	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
 	u32 link_speed = hw_link_info->link_speed;
@@ -299,16 +300,18 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		break;
 	case I40E_PHY_TYPE_10GBASE_T:
 	case I40E_PHY_TYPE_1000BASE_T:
-	case I40E_PHY_TYPE_100BASE_TX:
 		ecmd->supported = SUPPORTED_Autoneg |
 				  SUPPORTED_10000baseT_Full |
-				  SUPPORTED_1000baseT_Full |
-				  SUPPORTED_100baseT_Full;
+				  SUPPORTED_1000baseT_Full;
 		ecmd->advertising = ADVERTISED_Autoneg;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		break;
+	case I40E_PHY_TYPE_100BASE_TX:
+		ecmd->supported = SUPPORTED_Autoneg |
+				  SUPPORTED_100baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		break;
@@ -328,12 +331,15 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		break;
 	case I40E_PHY_TYPE_SGMII:
 		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_1000baseT_Full |
-				  SUPPORTED_100baseT_Full;
+				  SUPPORTED_1000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
+		if (pf->hw.mac.type == I40E_MAC_X722) {
+			ecmd->supported |= SUPPORTED_100baseT_Full;
+			if (hw_link_info->requested_speeds &
+			    I40E_LINK_SPEED_100MB)
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
+		}
 		break;
 	/* Backplane is set based on supported phy types in get_settings
 	 * so don't set anything here but don't warn either
@@ -381,7 +387,8 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
  * Reports link settings that can be determined when link is down
  **/
 static void i40e_get_settings_link_down(struct i40e_hw *hw,
-					struct ethtool_cmd *ecmd)
+					struct ethtool_cmd *ecmd,
+					struct i40e_pf *pf)
 {
 	enum i40e_aq_capabilities_phy_type phy_types = hw->phy.phy_types;
 
@@ -392,11 +399,13 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 	ecmd->advertising = 0x0;
 	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
 		ecmd->supported |= SUPPORTED_Autoneg |
-				   SUPPORTED_1000baseT_Full |
-				   SUPPORTED_100baseT_Full;
+				   SUPPORTED_1000baseT_Full;
 		ecmd->advertising |= ADVERTISED_Autoneg |
-				     ADVERTISED_1000baseT_Full |
-				     ADVERTISED_100baseT_Full;
+				     ADVERTISED_1000baseT_Full;
+		if (pf->hw.mac.type == I40E_MAC_X722) {
+			ecmd->supported |= SUPPORTED_100baseT_Full;
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
+		}
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_XAUI ||
 	    phy_types & I40E_CAP_PHY_TYPE_XFI ||
@@ -425,7 +434,8 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 		ecmd->advertising |= ADVERTISED_Autoneg |
 				    ADVERTISED_40000baseCR4_Full;
 	}
-	if (phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
+	if ((phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) &&
+	    !(phy_types & I40E_CAP_PHY_TYPE_1000BASE_T)) {
 		ecmd->supported |= SUPPORTED_Autoneg |
 				   SUPPORTED_100baseT_Full;
 		ecmd->advertising |= ADVERTISED_Autoneg |
@@ -467,9 +477,9 @@ static int i40e_get_settings(struct net_device *netdev,
 	bool link_up = hw_link_info->link_info & I40E_AQ_LINK_UP;
 
 	if (link_up)
-		i40e_get_settings_link_up(hw, ecmd, netdev);
+		i40e_get_settings_link_up(hw, ecmd, netdev, pf);
 	else
-		i40e_get_settings_link_down(hw, ecmd);
+		i40e_get_settings_link_down(hw, ecmd, pf);
 
 	/* Now set the settings that don't rely on link being up/down */
 
-- 
2.4.3
