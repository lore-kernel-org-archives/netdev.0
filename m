From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: Refactor ethtool get_settings
Date: Sat, 14 May 2016 21:57:28 -0700
Message-ID: <1463288255-1654-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbcEOE5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:40 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Previously we were only looking at the FW supported PHY types if link
was down, because we want to be more specific when link is up. This
refactor changes this. When link is down, we still rely on the FW
supported PHY types, but when link is up, we select the possible
supported link modes from what we know about the current PHY type, and
AND that with the FW supported PHY types.

Change-ID: Ice5dad83f2a17932b0b8b59f07439696ad6aa013
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 258 +++++++++++++------------
 1 file changed, 135 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 52b58e3..5e8d84f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -262,6 +262,110 @@ static void i40e_partition_setting_complaint(struct i40e_pf *pf)
 }
 
 /**
+ * i40e_phy_type_to_ethtool - convert the phy_types to ethtool link modes
+ * @phy_types: PHY types to convert
+ * @supported: pointer to the ethtool supported variable to fill in
+ * @advertising: pointer to the ethtool advertising variable to fill in
+ *
+ **/
+static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
+				     u32 *advertising)
+{
+	enum i40e_aq_capabilities_phy_type phy_types = pf->hw.phy.phy_types;
+
+	*supported = 0x0;
+	*advertising = 0x0;
+
+	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
+		*supported |= SUPPORTED_Autoneg |
+			      SUPPORTED_1000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg |
+				ADVERTISED_1000baseT_Full;
+		if (pf->flags & I40E_FLAG_100M_SGMII_CAPABLE) {
+			*supported |= SUPPORTED_100baseT_Full;
+			*advertising |= ADVERTISED_100baseT_Full;
+		}
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_XAUI ||
+	    phy_types & I40E_CAP_PHY_TYPE_XFI ||
+	    phy_types & I40E_CAP_PHY_TYPE_SFI ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SFPP_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_AOC)
+		*supported |= SUPPORTED_10000baseT_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1 ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SR ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR) {
+		*supported |= SUPPORTED_Autoneg |
+			      SUPPORTED_10000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg |
+				ADVERTISED_10000baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_XLAUI ||
+	    phy_types & I40E_CAP_PHY_TYPE_XLPPI ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_AOC)
+		*supported |= SUPPORTED_40000baseCR4_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4) {
+		*supported |= SUPPORTED_Autoneg |
+			      SUPPORTED_40000baseCR4_Full;
+		*advertising |= ADVERTISED_Autoneg |
+				ADVERTISED_40000baseCR4_Full;
+	}
+	if ((phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) &&
+	    !(phy_types & I40E_CAP_PHY_TYPE_1000BASE_T)) {
+		*supported |= SUPPORTED_Autoneg |
+			      SUPPORTED_100baseT_Full;
+		*advertising |= ADVERTISED_Autoneg |
+				ADVERTISED_100baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_LX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL) {
+		*supported |= SUPPORTED_Autoneg |
+			      SUPPORTED_1000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg |
+				ADVERTISED_1000baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_SR4)
+		*supported |= SUPPORTED_40000baseSR4_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_LR4)
+		*supported |= SUPPORTED_40000baseLR4_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_KR4) {
+		*supported |= SUPPORTED_40000baseKR4_Full |
+			      SUPPORTED_Autoneg;
+		*advertising |= ADVERTISED_40000baseKR4_Full |
+				ADVERTISED_Autoneg;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2) {
+		*supported |= SUPPORTED_20000baseKR2_Full |
+			      SUPPORTED_Autoneg;
+		*advertising |= ADVERTISED_20000baseKR2_Full |
+				ADVERTISED_Autoneg;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR) {
+		*supported |= SUPPORTED_10000baseKR_Full |
+			      SUPPORTED_Autoneg;
+		*advertising |= ADVERTISED_10000baseKR_Full |
+				ADVERTISED_Autoneg;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4) {
+		*supported |= SUPPORTED_10000baseKX4_Full |
+			      SUPPORTED_Autoneg;
+		*advertising |= ADVERTISED_10000baseKX4_Full |
+				ADVERTISED_Autoneg;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX) {
+		*supported |= SUPPORTED_1000baseKX_Full |
+			      SUPPORTED_Autoneg;
+		*advertising |= ADVERTISED_1000baseKX_Full |
+				ADVERTISED_Autoneg;
+	}
+}
+
+/**
  * i40e_get_settings_link_up - Get the Link settings for when link is up
  * @hw: hw structure
  * @ecmd: ethtool command to fill in
@@ -275,6 +379,8 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 {
 	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
 	u32 link_speed = hw_link_info->link_speed;
+	u32 e_advertising = 0x0;
+	u32 e_supported = 0x0;
 
 	/* Initialize supported and advertised settings based on phy settings */
 	switch (hw_link_info->phy_type) {
@@ -315,21 +421,18 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		break;
 	case I40E_PHY_TYPE_10GBASE_T:
 	case I40E_PHY_TYPE_1000BASE_T:
+	case I40E_PHY_TYPE_100BASE_TX:
 		ecmd->supported = SUPPORTED_Autoneg |
 				  SUPPORTED_10000baseT_Full |
-				  SUPPORTED_1000baseT_Full;
+				  SUPPORTED_1000baseT_Full |
+				  SUPPORTED_100baseT_Full;
 		ecmd->advertising = ADVERTISED_Autoneg;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		/* adding 100baseT support for 10GBASET_PHY */
-		if (pf->flags & I40E_FLAG_HAVE_10GBASET_PHY) {
-			ecmd->supported |= SUPPORTED_100baseT_Full;
-			ecmd->advertising |= ADVERTISED_100baseT_Full |
-					     ADVERTISED_1000baseT_Full |
-					     ADVERTISED_10000baseT_Full;
-		}
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		break;
 	case I40E_PHY_TYPE_1000BASE_T_OPTICAL:
 		ecmd->supported = SUPPORTED_Autoneg |
@@ -337,21 +440,6 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		ecmd->advertising = ADVERTISED_Autoneg |
 				    ADVERTISED_1000baseT_Full;
 		break;
-	case I40E_PHY_TYPE_100BASE_TX:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_100baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
-		/* firmware detects 10G phy as 100M phy at 100M speed */
-		if (pf->flags & I40E_FLAG_HAVE_10GBASET_PHY) {
-			ecmd->supported |= SUPPORTED_10000baseT_Full |
-					   SUPPORTED_1000baseT_Full;
-			ecmd->advertising |= ADVERTISED_Autoneg |
-					     ADVERTISED_100baseT_Full |
-					     ADVERTISED_1000baseT_Full |
-					     ADVERTISED_10000baseT_Full;
-		}
-		break;
 	case I40E_PHY_TYPE_10GBASE_CR1_CU:
 	case I40E_PHY_TYPE_10GBASE_CR1:
 		ecmd->supported = SUPPORTED_Autoneg |
@@ -378,14 +466,23 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 				ecmd->advertising |= ADVERTISED_100baseT_Full;
 		}
 		break;
-	/* Backplane is set based on supported phy types in get_settings
-	 * so don't set anything here but don't warn either
-	 */
 	case I40E_PHY_TYPE_40GBASE_KR4:
 	case I40E_PHY_TYPE_20GBASE_KR2:
 	case I40E_PHY_TYPE_10GBASE_KR:
 	case I40E_PHY_TYPE_10GBASE_KX4:
 	case I40E_PHY_TYPE_1000BASE_KX:
+		ecmd->supported |= SUPPORTED_40000baseKR4_Full |
+				   SUPPORTED_20000baseKR2_Full |
+				   SUPPORTED_10000baseKR_Full |
+				   SUPPORTED_10000baseKX4_Full |
+				   SUPPORTED_1000baseKX_Full |
+				   SUPPORTED_Autoneg;
+		ecmd->advertising |= ADVERTISED_40000baseKR4_Full |
+				     ADVERTISED_20000baseKR2_Full |
+				     ADVERTISED_10000baseKR_Full |
+				     ADVERTISED_10000baseKX4_Full |
+				     ADVERTISED_1000baseKX_Full |
+				     ADVERTISED_Autoneg;
 		break;
 	default:
 		/* if we got here and link is up something bad is afoot */
@@ -393,6 +490,16 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 			    hw_link_info->phy_type);
 	}
 
+	/* Now that we've worked out everything that could be supported by the
+	 * current PHY type, get what is supported by the NVM and them to
+	 * get what is truly supported
+	 */
+	i40e_phy_type_to_ethtool(pf, &e_supported,
+				 &e_advertising);
+
+	ecmd->supported = ecmd->supported & e_supported;
+	ecmd->advertising = ecmd->advertising & e_advertising;
+
 	/* Set speed and duplex */
 	switch (link_speed) {
 	case I40E_LINK_SPEED_40GB:
@@ -427,74 +534,11 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 					struct ethtool_cmd *ecmd,
 					struct i40e_pf *pf)
 {
-	enum i40e_aq_capabilities_phy_type phy_types = hw->phy.phy_types;
-
 	/* link is down and the driver needs to fall back on
 	 * supported phy types to figure out what info to display
 	 */
-	ecmd->supported = 0x0;
-	ecmd->advertising = 0x0;
-	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
-		ecmd->supported |= SUPPORTED_Autoneg |
-				   SUPPORTED_1000baseT_Full;
-		ecmd->advertising |= ADVERTISED_Autoneg |
-				     ADVERTISED_1000baseT_Full;
-		if (pf->hw.mac.type == I40E_MAC_X722) {
-			ecmd->supported |= SUPPORTED_100baseT_Full;
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
-			if (pf->flags & I40E_FLAG_100M_SGMII_CAPABLE) {
-				ecmd->supported |= SUPPORTED_100baseT_Full;
-				ecmd->advertising |= ADVERTISED_100baseT_Full;
-			}
-		}
-	}
-	if (phy_types & I40E_CAP_PHY_TYPE_XAUI ||
-	    phy_types & I40E_CAP_PHY_TYPE_XFI ||
-	    phy_types & I40E_CAP_PHY_TYPE_SFI ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SFPP_CU ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_AOC)
-		ecmd->supported |= SUPPORTED_10000baseT_Full;
-	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1_CU ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1 ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_T ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SR ||
-	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR) {
-		ecmd->supported |= SUPPORTED_Autoneg |
-				   SUPPORTED_10000baseT_Full;
-		ecmd->advertising |= ADVERTISED_Autoneg |
-				     ADVERTISED_10000baseT_Full;
-	}
-	if (phy_types & I40E_CAP_PHY_TYPE_XLAUI ||
-	    phy_types & I40E_CAP_PHY_TYPE_XLPPI ||
-	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_AOC)
-		ecmd->supported |= SUPPORTED_40000baseCR4_Full;
-	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4_CU ||
-	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4) {
-		ecmd->supported |= SUPPORTED_Autoneg |
-				  SUPPORTED_40000baseCR4_Full;
-		ecmd->advertising |= ADVERTISED_Autoneg |
-				    ADVERTISED_40000baseCR4_Full;
-	}
-	if ((phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) &&
-	    !(phy_types & I40E_CAP_PHY_TYPE_1000BASE_T)) {
-		ecmd->supported |= SUPPORTED_Autoneg |
-				   SUPPORTED_100baseT_Full;
-		ecmd->advertising |= ADVERTISED_Autoneg |
-				     ADVERTISED_100baseT_Full;
-	}
-	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_T ||
-	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
-	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_LX ||
-	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL) {
-		ecmd->supported |= SUPPORTED_Autoneg |
-				   SUPPORTED_1000baseT_Full;
-		ecmd->advertising |= ADVERTISED_Autoneg |
-				     ADVERTISED_1000baseT_Full;
-	}
-	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_SR4)
-		ecmd->supported |= SUPPORTED_40000baseSR4_Full;
-	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_LR4)
-		ecmd->supported |= SUPPORTED_40000baseLR4_Full;
+	i40e_phy_type_to_ethtool(pf, &ecmd->supported,
+				 &ecmd->advertising);
 
 	/* With no link speed and duplex are unknown */
 	ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
@@ -523,38 +567,6 @@ static int i40e_get_settings(struct net_device *netdev,
 		i40e_get_settings_link_down(hw, ecmd, pf);
 
 	/* Now set the settings that don't rely on link being up/down */
-
-	/* For backplane, supported and advertised are only reliant on the
-	 * phy types the NVM specifies are supported.
-	 */
-	if (hw->device_id == I40E_DEV_ID_KX_B ||
-	    hw->device_id == I40E_DEV_ID_KX_C ||
-	    hw->device_id == I40E_DEV_ID_20G_KR2 ||
-	    hw->device_id ==  I40E_DEV_ID_20G_KR2_A) {
-		ecmd->supported = SUPPORTED_Autoneg;
-		ecmd->advertising = ADVERTISED_Autoneg;
-		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_40GBASE_KR4) {
-			ecmd->supported |= SUPPORTED_40000baseKR4_Full;
-			ecmd->advertising |= ADVERTISED_40000baseKR4_Full;
-		}
-		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2) {
-			ecmd->supported |= SUPPORTED_20000baseKR2_Full;
-			ecmd->advertising |= ADVERTISED_20000baseKR2_Full;
-		}
-		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR) {
-			ecmd->supported |= SUPPORTED_10000baseKR_Full;
-			ecmd->advertising |= ADVERTISED_10000baseKR_Full;
-		}
-		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4) {
-			ecmd->supported |= SUPPORTED_10000baseKX4_Full;
-			ecmd->advertising |= ADVERTISED_10000baseKX4_Full;
-		}
-		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX) {
-			ecmd->supported |= SUPPORTED_1000baseKX_Full;
-			ecmd->advertising |= ADVERTISED_1000baseKX_Full;
-		}
-	}
-
 	/* Set autoneg settings */
 	ecmd->autoneg = ((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
 			  AUTONEG_ENABLE : AUTONEG_DISABLE);
-- 
2.5.5
