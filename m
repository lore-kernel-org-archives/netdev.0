From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: clean up ixgbe_get_settings ethtool function
Date: Wed, 20 Jun 2012 01:45:03 -0700
Message-ID: <1340181903-16382-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60849 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755537Ab2FTIpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:10 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch cleans up the method used for determining the link speed of
devices. The old method re-wrote some logic already existing in a mac.ops
function which should be used instead. The result is much simpler to
understand and removes a strange double-check of logic, as well as reducing
code redundancy.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  147 +++++++++-------------
 1 file changed, 62 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 3178f1e..bbc7da5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -154,100 +154,60 @@ static int ixgbe_get_settings(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	ixgbe_link_speed supported_link;
 	u32 link_speed = 0;
+	bool autoneg;
 	bool link_up;
 
-	ecmd->supported = SUPPORTED_10000baseT_Full;
-	ecmd->autoneg = AUTONEG_ENABLE;
-	ecmd->transceiver = XCVR_EXTERNAL;
-	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
-	    (hw->phy.multispeed_fiber)) {
-		ecmd->supported |= (SUPPORTED_1000baseT_Full |
-		                    SUPPORTED_Autoneg);
-
-		switch (hw->mac.type) {
-		case ixgbe_mac_X540:
-			ecmd->supported |= SUPPORTED_100baseT_Full;
-			break;
-		default:
-			break;
-		}
-
-		ecmd->advertising = ADVERTISED_Autoneg;
-		if (hw->phy.autoneg_advertised) {
-			if (hw->phy.autoneg_advertised &
-			    IXGBE_LINK_SPEED_100_FULL)
-				ecmd->advertising |= ADVERTISED_100baseT_Full;
-			if (hw->phy.autoneg_advertised &
-			    IXGBE_LINK_SPEED_10GB_FULL)
-				ecmd->advertising |= ADVERTISED_10000baseT_Full;
-			if (hw->phy.autoneg_advertised &
-			    IXGBE_LINK_SPEED_1GB_FULL)
-				ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		} else {
-			/*
-			 * Default advertised modes in case
-			 * phy.autoneg_advertised isn't set.
-			 */
-			ecmd->advertising |= (ADVERTISED_10000baseT_Full |
-					      ADVERTISED_1000baseT_Full);
-			if (hw->mac.type == ixgbe_mac_X540)
-				ecmd->advertising |= ADVERTISED_100baseT_Full;
-		}
-
-		if (hw->phy.media_type == ixgbe_media_type_copper) {
-			ecmd->supported |= SUPPORTED_TP;
-			ecmd->advertising |= ADVERTISED_TP;
-			ecmd->port = PORT_TP;
-		} else {
-			ecmd->supported |= SUPPORTED_FIBRE;
-			ecmd->advertising |= ADVERTISED_FIBRE;
-			ecmd->port = PORT_FIBRE;
-		}
-	} else if (hw->phy.media_type == ixgbe_media_type_backplane) {
-		/* Set as FIBRE until SERDES defined in kernel */
-		if (hw->device_id == IXGBE_DEV_ID_82598_BX) {
-			ecmd->supported = (SUPPORTED_1000baseT_Full |
-					   SUPPORTED_FIBRE);
-			ecmd->advertising = (ADVERTISED_1000baseT_Full |
-					     ADVERTISED_FIBRE);
-			ecmd->port = PORT_FIBRE;
-			ecmd->autoneg = AUTONEG_DISABLE;
-		} else if ((hw->device_id == IXGBE_DEV_ID_82599_COMBO_BACKPLANE) ||
-			   (hw->device_id == IXGBE_DEV_ID_82599_KX4_MEZZ)) {
-			ecmd->supported |= (SUPPORTED_1000baseT_Full |
-					    SUPPORTED_Autoneg |
-					    SUPPORTED_FIBRE);
-			ecmd->advertising = (ADVERTISED_10000baseT_Full |
-					     ADVERTISED_1000baseT_Full |
-					     ADVERTISED_Autoneg |
-					     ADVERTISED_FIBRE);
-			ecmd->port = PORT_FIBRE;
-		} else {
-			ecmd->supported |= (SUPPORTED_1000baseT_Full |
-					    SUPPORTED_FIBRE);
-			ecmd->advertising = (ADVERTISED_10000baseT_Full |
-					     ADVERTISED_1000baseT_Full |
-					     ADVERTISED_FIBRE);
-			ecmd->port = PORT_FIBRE;
-		}
+	hw->mac.ops.get_link_capabilities(hw, &supported_link, &autoneg);
+
+	/* set the supported link speeds */
+	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
+		ecmd->supported |= SUPPORTED_10000baseT_Full;
+	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
+		ecmd->supported |= SUPPORTED_1000baseT_Full;
+	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
+		ecmd->supported |= SUPPORTED_100baseT_Full;
+
+	/* set the advertised speeds */
+	if (hw->phy.autoneg_advertised) {
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
+			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 	} else {
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising = (ADVERTISED_10000baseT_Full |
-		                     ADVERTISED_FIBRE);
-		ecmd->port = PORT_FIBRE;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		/* default modes in case phy.autoneg_advertised isn't set */
+		if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
+			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+		if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		if (supported_link & IXGBE_LINK_SPEED_100_FULL)
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
 	}
 
-	/* Get PHY type */
+	if (autoneg) {
+		ecmd->supported |= SUPPORTED_Autoneg;
+		ecmd->advertising |= ADVERTISED_Autoneg;
+		ecmd->autoneg = AUTONEG_ENABLE;
+	} else
+		ecmd->autoneg = AUTONEG_DISABLE;
+
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	/* Determine the remaining settings based on the PHY type. */
 	switch (adapter->hw.phy.type) {
 	case ixgbe_phy_tn:
 	case ixgbe_phy_aq:
 	case ixgbe_phy_cu_unknown:
-		/* Copper 10G-BASET */
+		ecmd->supported |= SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
 		break;
 	case ixgbe_phy_qt:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_FIBRE;
 		break;
 	case ixgbe_phy_nl:
@@ -257,42 +217,59 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	case ixgbe_phy_sfp_avago:
 	case ixgbe_phy_sfp_intel:
 	case ixgbe_phy_sfp_unknown:
-		switch (adapter->hw.phy.sfp_type) {
 		/* SFP+ devices, further checking needed */
+		switch (adapter->hw.phy.sfp_type) {
 		case ixgbe_sfp_type_da_cu:
 		case ixgbe_sfp_type_da_cu_core0:
 		case ixgbe_sfp_type_da_cu_core1:
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
 			ecmd->port = PORT_DA;
 			break;
 		case ixgbe_sfp_type_sr:
 		case ixgbe_sfp_type_lr:
 		case ixgbe_sfp_type_srlr_core0:
 		case ixgbe_sfp_type_srlr_core1:
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
 			ecmd->port = PORT_FIBRE;
 			break;
 		case ixgbe_sfp_type_not_present:
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
 			ecmd->port = PORT_NONE;
 			break;
 		case ixgbe_sfp_type_1g_cu_core0:
 		case ixgbe_sfp_type_1g_cu_core1:
+			ecmd->supported |= SUPPORTED_TP;
+			ecmd->advertising |= ADVERTISED_TP;
 			ecmd->port = PORT_TP;
-			ecmd->supported = SUPPORTED_TP;
-			ecmd->advertising = (ADVERTISED_1000baseT_Full |
-			                     ADVERTISED_TP);
+			break;
+		case ixgbe_sfp_type_1g_sx_core0:
+		case ixgbe_sfp_type_1g_sx_core1:
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
+			ecmd->port = PORT_FIBRE;
 			break;
 		case ixgbe_sfp_type_unknown:
 		default:
+			ecmd->supported |= SUPPORTED_FIBRE;
+			ecmd->advertising |= ADVERTISED_FIBRE;
 			ecmd->port = PORT_OTHER;
 			break;
 		}
 		break;
 	case ixgbe_phy_xaui:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_NONE;
 		break;
 	case ixgbe_phy_unknown:
 	case ixgbe_phy_generic:
 	case ixgbe_phy_sfp_unsupported:
 	default:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_OTHER;
 		break;
 	}
-- 
1.7.10.2
