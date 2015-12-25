From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: report correct media type for KR, KX and KX4 interfaces
Date: Thu, 24 Dec 2015 21:29:51 -0800
Message-ID: <1451021396-68858-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Veola Nazareth <veola.nazareth@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40717 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbbLYF37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:29:59 -0500
In-Reply-To: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veola Nazareth <veola.nazareth@intel.com>

Ethtool reports backplane type interfaces as 1000/10000baseT link modes.
This has been corrected to report the media as KR, KX or KX4 based on the
backplane interface present.

Signed-off-by: Veola Nazareth <veola.nazareth@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 55 ++++++++++++++++++------
 1 file changed, 42 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e10d197..2448eba 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -151,6 +151,34 @@ static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define IXGBE_TEST_LEN sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN
 
+/* currently supported speeds for 10G */
+#define ADVRTSD_MSK_10G (SUPPORTED_10000baseT_Full | \
+			 SUPPORTED_10000baseKX4_Full | \
+			 SUPPORTED_10000baseKR_Full)
+
+#define ixgbe_isbackplane(type) ((type) == ixgbe_media_type_backplane)
+
+static u32 ixgbe_get_supported_10gtypes(struct ixgbe_hw *hw)
+{
+	if (!ixgbe_isbackplane(hw->phy.media_type))
+		return SUPPORTED_10000baseT_Full;
+
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598:
+	case IXGBE_DEV_ID_82599_KX4:
+	case IXGBE_DEV_ID_82599_KX4_MEZZ:
+	case IXGBE_DEV_ID_X550EM_X_KX4:
+		return SUPPORTED_10000baseKX4_Full;
+	case IXGBE_DEV_ID_82598_BX:
+	case IXGBE_DEV_ID_82599_KR:
+	case IXGBE_DEV_ID_X550EM_X_KR:
+		return SUPPORTED_10000baseKR_Full;
+	default:
+		return SUPPORTED_10000baseKX4_Full |
+		       SUPPORTED_10000baseKR_Full;
+	}
+}
+
 static int ixgbe_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
@@ -165,29 +193,30 @@ static int ixgbe_get_settings(struct net_device *netdev,
 
 	/* set the supported link speeds */
 	if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
-		ecmd->supported |= SUPPORTED_10000baseT_Full;
+		ecmd->supported |= ixgbe_get_supported_10gtypes(hw);
 	if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
 		ecmd->supported |= SUPPORTED_1000baseT_Full;
 	if (supported_link & IXGBE_LINK_SPEED_100_FULL)
-		ecmd->supported |= SUPPORTED_100baseT_Full;
+		ecmd->supported |= ixgbe_isbackplane(hw->phy.media_type) ?
+				   SUPPORTED_1000baseKX_Full :
+				   SUPPORTED_1000baseT_Full;
 
+	/* default advertised speed if phy.autoneg_advertised isn't set */
+	ecmd->advertising = ecmd->supported;
 	/* set the advertised speeds */
 	if (hw->phy.autoneg_advertised) {
+		ecmd->advertising = 0;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
-			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+			ecmd->advertising |= ecmd->supported & ADVRTSD_MSK_10G;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL) {
+			if (ecmd->supported & SUPPORTED_1000baseKX_Full)
+				ecmd->advertising |= ADVERTISED_1000baseKX_Full;
+			else
+				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		}
 	} else {
-		/* default modes in case phy.autoneg_advertised isn't set */
-		if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
-			ecmd->advertising |= ADVERTISED_10000baseT_Full;
-		if (supported_link & IXGBE_LINK_SPEED_1GB_FULL)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		if (supported_link & IXGBE_LINK_SPEED_100_FULL)
-			ecmd->advertising |= ADVERTISED_100baseT_Full;
-
 		if (hw->phy.multispeed_fiber && !autoneg) {
 			if (supported_link & IXGBE_LINK_SPEED_10GB_FULL)
 				ecmd->advertising = ADVERTISED_10000baseT_Full;
-- 
2.5.0
