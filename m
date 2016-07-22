From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] i40e: Fix to show correct Advertised Link Modes when link is down
Date: Fri, 22 Jul 2016 00:36:30 -0700
Message-ID: <1469172999-8969-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37308 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747AbcGVHgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:50 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

When link is down, Advertised Link Modes was wrongly displaying full
supported link modes instead of Advertised link mode. Added conditional
checks in order to make sure correct Advertised link modes are
displayed when the link is down.

Change-ID: I8a61413f9ee174149c7a33157b5f0b0a8da9842d
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 47 +++++++++++++++-----------
 1 file changed, 28 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 4962e85..0cfde30 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -272,15 +272,16 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 				     u32 *advertising)
 {
 	enum i40e_aq_capabilities_phy_type phy_types = pf->hw.phy.phy_types;
-
+	struct i40e_link_status *hw_link_info = &pf->hw.phy.link_info;
 	*supported = 0x0;
 	*advertising = 0x0;
 
 	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_1000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg |
-				ADVERTISED_1000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
+			*advertising |= ADVERTISED_1000baseT_Full;
 		if (pf->flags & I40E_FLAG_100M_SGMII_CAPABLE) {
 			*supported |= SUPPORTED_100baseT_Full;
 			*advertising |= ADVERTISED_100baseT_Full;
@@ -299,8 +300,9 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_10000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg |
-				ADVERTISED_10000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
+			*advertising |= ADVERTISED_10000baseT_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_XLAUI ||
 	    phy_types & I40E_CAP_PHY_TYPE_XLPPI ||
@@ -310,14 +312,16 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_40000baseCR4_Full;
-		*advertising |= ADVERTISED_Autoneg |
-				ADVERTISED_40000baseCR4_Full;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_40GB)
+			*advertising |= ADVERTISED_40000baseCR4_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_100baseT_Full;
-		*advertising |= ADVERTISED_Autoneg |
-				ADVERTISED_100baseT_Full;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
+			*advertising |= ADVERTISED_100baseT_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_T ||
 	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
@@ -325,8 +329,9 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_1000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg |
-				ADVERTISED_1000baseT_Full;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
+			*advertising |= ADVERTISED_1000baseT_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_SR4)
 		*supported |= SUPPORTED_40000baseSR4_Full;
@@ -341,26 +346,30 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	if (phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2) {
 		*supported |= SUPPORTED_20000baseKR2_Full |
 			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_20000baseKR2_Full |
-				ADVERTISED_Autoneg;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_20GB)
+			*advertising |= ADVERTISED_20000baseKR2_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR) {
 		*supported |= SUPPORTED_10000baseKR_Full |
 			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_10000baseKR_Full |
-				ADVERTISED_Autoneg;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
+			*advertising |= ADVERTISED_10000baseKR_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4) {
 		*supported |= SUPPORTED_10000baseKX4_Full |
 			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_10000baseKX4_Full |
-				ADVERTISED_Autoneg;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
+			*advertising |= ADVERTISED_10000baseKX4_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX) {
 		*supported |= SUPPORTED_1000baseKX_Full |
 			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_1000baseKX_Full |
-				ADVERTISED_Autoneg;
+		*advertising |= ADVERTISED_Autoneg;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
+			*advertising |= ADVERTISED_1000baseKX_Full;
 	}
 }
 
-- 
2.5.5
