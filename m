From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e/i40evf: Refactor PHY structure and add phy_capabilities enum
Date: Mon, 12 Oct 2015 22:53:14 -0700
Message-ID: <1444715598-20970-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33013 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbbJMFx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:28 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Remove unused members in the PHY structure and add a new member to store
all the capabilities the PHY has as reported by the FW. This information
will help us determine what speeds the device is capable of when link is
down.

Also add an enum to decode the PHY types the NVM is capable of.
Use the phy_types variable to determine what phy types are possible
when link is down instead of device id as it will be more accurate.

When on a backplane device, we do not support changing any settings,
however we should display all the phy_types we are capable of so if we
see a backplane dev ID set supported and advertised purely based on
the phy_types variable.

Change-ID: Ia75d560f1fcd30c54cbfb7458690c5867559a930
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 189 ++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_main.c    |   8 ++
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  37 ++++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h  |  37 ++++-
 4 files changed, 181 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 46019e9..831f971 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -273,36 +273,12 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 	case I40E_PHY_TYPE_40GBASE_AOC:
 		ecmd->supported = SUPPORTED_40000baseCR4_Full;
 		break;
-	case I40E_PHY_TYPE_40GBASE_KR4:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_40000baseKR4_Full;
-		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_40000baseKR4_Full;
-		break;
 	case I40E_PHY_TYPE_40GBASE_SR4:
 		ecmd->supported = SUPPORTED_40000baseSR4_Full;
 		break;
 	case I40E_PHY_TYPE_40GBASE_LR4:
 		ecmd->supported = SUPPORTED_40000baseLR4_Full;
 		break;
-	case I40E_PHY_TYPE_20GBASE_KR2:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_20000baseKR2_Full;
-		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_20000baseKR2_Full;
-		break;
-	case I40E_PHY_TYPE_10GBASE_KX4:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_10000baseKX4_Full;
-		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_10000baseKX4_Full;
-		break;
-	case I40E_PHY_TYPE_10GBASE_KR:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_10000baseKR_Full;
-		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_10000baseKR_Full;
-		break;
 	case I40E_PHY_TYPE_10GBASE_SR:
 	case I40E_PHY_TYPE_10GBASE_LR:
 	case I40E_PHY_TYPE_1000BASE_SX:
@@ -320,12 +296,6 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		break;
-	case I40E_PHY_TYPE_1000BASE_KX:
-		ecmd->supported = SUPPORTED_Autoneg |
-				  SUPPORTED_1000baseKX_Full;
-		ecmd->advertising = ADVERTISED_Autoneg |
-				    ADVERTISED_1000baseKX_Full;
-		break;
 	case I40E_PHY_TYPE_10GBASE_T:
 	case I40E_PHY_TYPE_1000BASE_T:
 	case I40E_PHY_TYPE_100BASE_TX:
@@ -364,6 +334,15 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		break;
+	/* Backplane is set based on supported phy types in get_settings
+	 * so don't set anything here but don't warn either
+	 */
+	case I40E_PHY_TYPE_40GBASE_KR4:
+	case I40E_PHY_TYPE_20GBASE_KR2:
+	case I40E_PHY_TYPE_10GBASE_KR:
+	case I40E_PHY_TYPE_10GBASE_KX4:
+	case I40E_PHY_TYPE_1000BASE_KX:
+		break;
 	default:
 		/* if we got here and link is up something bad is afoot */
 		netdev_info(netdev, "WARNING: Link is up but PHY type 0x%x is not recognized.\n",
@@ -403,64 +382,67 @@ static void i40e_get_settings_link_up(struct i40e_hw *hw,
 static void i40e_get_settings_link_down(struct i40e_hw *hw,
 					struct ethtool_cmd *ecmd)
 {
-	struct i40e_link_status *hw_link_info = &hw->phy.link_info;
+	enum i40e_aq_capabilities_phy_type phy_types = hw->phy.phy_types;
 
 	/* link is down and the driver needs to fall back on
-	 * device ID to determine what kinds of info to display,
-	 * it's mostly a guess that may change when link is up
+	 * supported phy types to figure out what info to display
 	 */
-	switch (hw->device_id) {
-	case I40E_DEV_ID_QSFP_A:
-	case I40E_DEV_ID_QSFP_B:
-	case I40E_DEV_ID_QSFP_C:
-		/* pluggable QSFP */
-		ecmd->supported = SUPPORTED_40000baseSR4_Full |
-				  SUPPORTED_40000baseCR4_Full |
-				  SUPPORTED_40000baseLR4_Full;
-		ecmd->advertising = ADVERTISED_40000baseSR4_Full |
-				    ADVERTISED_40000baseCR4_Full |
-				    ADVERTISED_40000baseLR4_Full;
-		break;
-	case I40E_DEV_ID_KX_B:
-		/* backplane 40G */
-		ecmd->supported = SUPPORTED_40000baseKR4_Full;
-		ecmd->advertising = ADVERTISED_40000baseKR4_Full;
-		break;
-	case I40E_DEV_ID_KX_C:
-		/* backplane 10G */
-		ecmd->supported = SUPPORTED_10000baseKR_Full;
-		ecmd->advertising = ADVERTISED_10000baseKR_Full;
-		break;
-	case I40E_DEV_ID_10G_BASE_T:
-	case I40E_DEV_ID_10G_BASE_T4:
-		ecmd->supported = SUPPORTED_10000baseT_Full |
-				  SUPPORTED_1000baseT_Full |
-				  SUPPORTED_100baseT_Full;
-		/* Figure out what has been requested */
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
-			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
-		break;
-	case I40E_DEV_ID_20G_KR2:
-	case I40E_DEV_ID_20G_KR2_A:
-		/* backplane 20G */
-		ecmd->supported = SUPPORTED_20000baseKR2_Full;
-		ecmd->advertising = ADVERTISED_20000baseKR2_Full;
-		break;
-	default:
-		/* all the rest are 10G/1G */
-		ecmd->supported = SUPPORTED_10000baseT_Full |
-				  SUPPORTED_1000baseT_Full;
-		/* Figure out what has been requested */
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
-			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		break;
+	ecmd->supported = 0x0;
+	ecmd->advertising = 0x0;
+	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
+		ecmd->supported |= SUPPORTED_Autoneg |
+				   SUPPORTED_1000baseT_Full |
+				   SUPPORTED_100baseT_Full;
+		ecmd->advertising |= ADVERTISED_Autoneg |
+				     ADVERTISED_1000baseT_Full |
+				     ADVERTISED_100baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_XAUI ||
+	    phy_types & I40E_CAP_PHY_TYPE_XFI ||
+	    phy_types & I40E_CAP_PHY_TYPE_SFI ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SFPP_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_AOC)
+		ecmd->supported |= SUPPORTED_10000baseT_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1 ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SR ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR) {
+		ecmd->supported |= SUPPORTED_Autoneg |
+				   SUPPORTED_10000baseT_Full;
+		ecmd->advertising |= ADVERTISED_Autoneg |
+				     ADVERTISED_10000baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_XLAUI ||
+	    phy_types & I40E_CAP_PHY_TYPE_XLPPI ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_AOC)
+		ecmd->supported |= SUPPORTED_40000baseCR4_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4) {
+		ecmd->supported |= SUPPORTED_Autoneg |
+				  SUPPORTED_40000baseCR4_Full;
+		ecmd->advertising |= ADVERTISED_Autoneg |
+				    ADVERTISED_40000baseCR4_Full;
 	}
+	if (phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
+		ecmd->supported |= SUPPORTED_Autoneg |
+				   SUPPORTED_100baseT_Full;
+		ecmd->advertising |= ADVERTISED_Autoneg |
+				     ADVERTISED_100baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_LX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL) {
+		ecmd->supported |= SUPPORTED_Autoneg |
+				   SUPPORTED_1000baseT_Full;
+		ecmd->advertising |= ADVERTISED_Autoneg |
+				     ADVERTISED_1000baseT_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_SR4)
+		ecmd->supported |= SUPPORTED_40000baseSR4_Full;
+	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_LR4)
+		ecmd->supported |= SUPPORTED_40000baseLR4_Full;
 
 	/* With no link speed and duplex are unknown */
 	ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
@@ -490,6 +472,37 @@ static int i40e_get_settings(struct net_device *netdev,
 
 	/* Now set the settings that don't rely on link being up/down */
 
+	/* For backplane, supported and advertised are only reliant on the
+	 * phy types the NVM specifies are supported.
+	 */
+	if (hw->device_id == I40E_DEV_ID_KX_B ||
+	    hw->device_id == I40E_DEV_ID_KX_C ||
+	    hw->device_id == I40E_DEV_ID_20G_KR2 ||
+	    hw->device_id ==  I40E_DEV_ID_20G_KR2_A) {
+		ecmd->supported = SUPPORTED_Autoneg;
+		ecmd->advertising = ADVERTISED_Autoneg;
+		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_40GBASE_KR4) {
+			ecmd->supported |= SUPPORTED_40000baseKR4_Full;
+			ecmd->advertising |= ADVERTISED_40000baseKR4_Full;
+		}
+		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2) {
+			ecmd->supported |= SUPPORTED_20000baseKR2_Full;
+			ecmd->advertising |= ADVERTISED_20000baseKR2_Full;
+		}
+		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR) {
+			ecmd->supported |= SUPPORTED_10000baseKR_Full;
+			ecmd->advertising |= ADVERTISED_10000baseKR_Full;
+		}
+		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4) {
+			ecmd->supported |= SUPPORTED_10000baseKX4_Full;
+			ecmd->advertising |= ADVERTISED_10000baseKX4_Full;
+		}
+		if (hw->phy.phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX) {
+			ecmd->supported |= SUPPORTED_1000baseKX_Full;
+			ecmd->advertising |= ADVERTISED_1000baseKX_Full;
+		}
+	}
+
 	/* Set autoneg settings */
 	ecmd->autoneg = ((hw_link_info->an_info & I40E_AQ_AN_COMPLETED) ?
 			  AUTONEG_ENABLE : AUTONEG_DISABLE);
@@ -589,6 +602,14 @@ static int i40e_set_settings(struct net_device *netdev,
 	    hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
 		return -EOPNOTSUPP;
 
+	if (hw->device_id == I40E_DEV_ID_KX_B ||
+	    hw->device_id == I40E_DEV_ID_KX_C ||
+	    hw->device_id == I40E_DEV_ID_20G_KR2 ||
+	    hw->device_id == I40E_DEV_ID_20G_KR2_A) {
+		netdev_info(netdev, "Changing settings is not supported on backplane.\n");
+		return -EOPNOTSUPP;
+	}
+
 	/* get our own copy of the bits to check against */
 	memset(&safe_ecmd, 0, sizeof(struct ethtool_cmd));
 	i40e_get_settings(netdev, &safe_ecmd);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index dc80a5f..7158ff2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10338,6 +10338,14 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 	pf->hw.phy.link_info.requested_speeds = abilities.link_speed;
 
+	/* get the supported phy types from the fw */
+	err = i40e_aq_get_phy_capabilities(hw, false, true, &abilities, NULL);
+	if (err)
+		dev_dbg(&pf->pdev->dev, "get supported phy types ret =  %s last_status =  %s\n",
+			i40e_stat_str(&pf->hw, err),
+			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
+	pf->hw.phy.phy_types = le32_to_cpu(abilities.phy_type);
+
 	/* print a string summarizing features */
 	i40e_print_features(pf);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 0a450ac..6f69576 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -187,14 +187,45 @@ struct i40e_link_status {
 #define I40E_MODULE_TYPE_1000BASE_T	0x08
 };
 
+enum i40e_aq_capabilities_phy_type {
+	I40E_CAP_PHY_TYPE_SGMII		  = BIT(I40E_PHY_TYPE_SGMII),
+	I40E_CAP_PHY_TYPE_1000BASE_KX	  = BIT(I40E_PHY_TYPE_1000BASE_KX),
+	I40E_CAP_PHY_TYPE_10GBASE_KX4	  = BIT(I40E_PHY_TYPE_10GBASE_KX4),
+	I40E_CAP_PHY_TYPE_10GBASE_KR	  = BIT(I40E_PHY_TYPE_10GBASE_KR),
+	I40E_CAP_PHY_TYPE_40GBASE_KR4	  = BIT(I40E_PHY_TYPE_40GBASE_KR4),
+	I40E_CAP_PHY_TYPE_XAUI		  = BIT(I40E_PHY_TYPE_XAUI),
+	I40E_CAP_PHY_TYPE_XFI		  = BIT(I40E_PHY_TYPE_XFI),
+	I40E_CAP_PHY_TYPE_SFI		  = BIT(I40E_PHY_TYPE_SFI),
+	I40E_CAP_PHY_TYPE_XLAUI		  = BIT(I40E_PHY_TYPE_XLAUI),
+	I40E_CAP_PHY_TYPE_XLPPI		  = BIT(I40E_PHY_TYPE_XLPPI),
+	I40E_CAP_PHY_TYPE_40GBASE_CR4_CU  = BIT(I40E_PHY_TYPE_40GBASE_CR4_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_CR1_CU  = BIT(I40E_PHY_TYPE_10GBASE_CR1_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_AOC	  = BIT(I40E_PHY_TYPE_10GBASE_AOC),
+	I40E_CAP_PHY_TYPE_40GBASE_AOC	  = BIT(I40E_PHY_TYPE_40GBASE_AOC),
+	I40E_CAP_PHY_TYPE_100BASE_TX	  = BIT(I40E_PHY_TYPE_100BASE_TX),
+	I40E_CAP_PHY_TYPE_1000BASE_T	  = BIT(I40E_PHY_TYPE_1000BASE_T),
+	I40E_CAP_PHY_TYPE_10GBASE_T	  = BIT(I40E_PHY_TYPE_10GBASE_T),
+	I40E_CAP_PHY_TYPE_10GBASE_SR	  = BIT(I40E_PHY_TYPE_10GBASE_SR),
+	I40E_CAP_PHY_TYPE_10GBASE_LR	  = BIT(I40E_PHY_TYPE_10GBASE_LR),
+	I40E_CAP_PHY_TYPE_10GBASE_SFPP_CU = BIT(I40E_PHY_TYPE_10GBASE_SFPP_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_CR1	  = BIT(I40E_PHY_TYPE_10GBASE_CR1),
+	I40E_CAP_PHY_TYPE_40GBASE_CR4	  = BIT(I40E_PHY_TYPE_40GBASE_CR4),
+	I40E_CAP_PHY_TYPE_40GBASE_SR4	  = BIT(I40E_PHY_TYPE_40GBASE_SR4),
+	I40E_CAP_PHY_TYPE_40GBASE_LR4	  = BIT(I40E_PHY_TYPE_40GBASE_LR4),
+	I40E_CAP_PHY_TYPE_1000BASE_SX	  = BIT(I40E_PHY_TYPE_1000BASE_SX),
+	I40E_CAP_PHY_TYPE_1000BASE_LX	  = BIT(I40E_PHY_TYPE_1000BASE_LX),
+	I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL =
+					 BIT(I40E_PHY_TYPE_1000BASE_T_OPTICAL),
+	I40E_CAP_PHY_TYPE_20GBASE_KR2	  = BIT(I40E_PHY_TYPE_20GBASE_KR2)
+};
+
 struct i40e_phy_info {
 	struct i40e_link_status link_info;
 	struct i40e_link_status link_info_old;
-	u32 autoneg_advertised;
-	u32 phy_id;
-	u32 module_type;
 	bool get_link_info;
 	enum i40e_media_type media_type;
+	/* all the phy types the NVM is capable of */
+	enum i40e_aq_capabilities_phy_type phy_types;
 };
 
 #define I40E_HW_CAP_MAX_GPIO			30
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index f3155e3..85af3b4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -187,14 +187,45 @@ struct i40e_link_status {
 #define I40E_MODULE_TYPE_1000BASE_T	0x08
 };
 
+enum i40e_aq_capabilities_phy_type {
+	I40E_CAP_PHY_TYPE_SGMII		  = BIT(I40E_PHY_TYPE_SGMII),
+	I40E_CAP_PHY_TYPE_1000BASE_KX	  = BIT(I40E_PHY_TYPE_1000BASE_KX),
+	I40E_CAP_PHY_TYPE_10GBASE_KX4	  = BIT(I40E_PHY_TYPE_10GBASE_KX4),
+	I40E_CAP_PHY_TYPE_10GBASE_KR	  = BIT(I40E_PHY_TYPE_10GBASE_KR),
+	I40E_CAP_PHY_TYPE_40GBASE_KR4	  = BIT(I40E_PHY_TYPE_40GBASE_KR4),
+	I40E_CAP_PHY_TYPE_XAUI		  = BIT(I40E_PHY_TYPE_XAUI),
+	I40E_CAP_PHY_TYPE_XFI		  = BIT(I40E_PHY_TYPE_XFI),
+	I40E_CAP_PHY_TYPE_SFI		  = BIT(I40E_PHY_TYPE_SFI),
+	I40E_CAP_PHY_TYPE_XLAUI		  = BIT(I40E_PHY_TYPE_XLAUI),
+	I40E_CAP_PHY_TYPE_XLPPI		  = BIT(I40E_PHY_TYPE_XLPPI),
+	I40E_CAP_PHY_TYPE_40GBASE_CR4_CU  = BIT(I40E_PHY_TYPE_40GBASE_CR4_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_CR1_CU  = BIT(I40E_PHY_TYPE_10GBASE_CR1_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_AOC	  = BIT(I40E_PHY_TYPE_10GBASE_AOC),
+	I40E_CAP_PHY_TYPE_40GBASE_AOC	  = BIT(I40E_PHY_TYPE_40GBASE_AOC),
+	I40E_CAP_PHY_TYPE_100BASE_TX	  = BIT(I40E_PHY_TYPE_100BASE_TX),
+	I40E_CAP_PHY_TYPE_1000BASE_T	  = BIT(I40E_PHY_TYPE_1000BASE_T),
+	I40E_CAP_PHY_TYPE_10GBASE_T	  = BIT(I40E_PHY_TYPE_10GBASE_T),
+	I40E_CAP_PHY_TYPE_10GBASE_SR	  = BIT(I40E_PHY_TYPE_10GBASE_SR),
+	I40E_CAP_PHY_TYPE_10GBASE_LR	  = BIT(I40E_PHY_TYPE_10GBASE_LR),
+	I40E_CAP_PHY_TYPE_10GBASE_SFPP_CU = BIT(I40E_PHY_TYPE_10GBASE_SFPP_CU),
+	I40E_CAP_PHY_TYPE_10GBASE_CR1	  = BIT(I40E_PHY_TYPE_10GBASE_CR1),
+	I40E_CAP_PHY_TYPE_40GBASE_CR4	  = BIT(I40E_PHY_TYPE_40GBASE_CR4),
+	I40E_CAP_PHY_TYPE_40GBASE_SR4	  = BIT(I40E_PHY_TYPE_40GBASE_SR4),
+	I40E_CAP_PHY_TYPE_40GBASE_LR4	  = BIT(I40E_PHY_TYPE_40GBASE_LR4),
+	I40E_CAP_PHY_TYPE_1000BASE_SX	  = BIT(I40E_PHY_TYPE_1000BASE_SX),
+	I40E_CAP_PHY_TYPE_1000BASE_LX	  = BIT(I40E_PHY_TYPE_1000BASE_LX),
+	I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL =
+					 BIT(I40E_PHY_TYPE_1000BASE_T_OPTICAL),
+	I40E_CAP_PHY_TYPE_20GBASE_KR2	  = BIT(I40E_PHY_TYPE_20GBASE_KR2)
+};
+
 struct i40e_phy_info {
 	struct i40e_link_status link_info;
 	struct i40e_link_status link_info_old;
-	u32 autoneg_advertised;
-	u32 phy_id;
-	u32 module_type;
 	bool get_link_info;
 	enum i40e_media_type media_type;
+	/* all the phy types the NVM is capable of */
+	enum i40e_aq_capabilities_phy_type phy_types;
 };
 
 #define I40E_HW_CAP_MAX_GPIO			30
-- 
2.4.3
