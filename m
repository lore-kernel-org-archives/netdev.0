From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] igb: Update link modes display in ethtool
Date: Sat,  9 Nov 2013 04:52:14 -0800
Message-ID: <1384001534-18709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8453 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186Ab3KIMwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 07:52:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes multiple problems in the link modes display in ethtool.
Newer parts have more complicated methods to determine actual link
capabilities.  Older parts cannot communicate with their SFP modules.
Finally, all the available defines are not displayed by ethtool.  This
updates the link modes to be as accurate as possible depending on what data
is available to the driver at any given time.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 51 +++++++++++++++-------------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 151e00c..430b12f 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -146,6 +146,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	struct e1000_sfp_flags *eth_flags = &dev_spec->eth_flags;
 	u32 status;
 
+	status = rd32(E1000_STATUS);
 	if (hw->phy.media_type == e1000_media_type_copper) {
 
 		ecmd->supported = (SUPPORTED_10baseT_Half |
@@ -169,13 +170,22 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->transceiver = XCVR_INTERNAL;
 	} else {
 		ecmd->supported = (SUPPORTED_FIBRE |
+				   SUPPORTED_1000baseKX_Full |
 				   SUPPORTED_Autoneg |
 				   SUPPORTED_Pause);
-		ecmd->advertising = ADVERTISED_FIBRE;
-
-		if ((eth_flags->e1000_base_lx) || (eth_flags->e1000_base_sx)) {
-			ecmd->supported |= SUPPORTED_1000baseT_Full;
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		ecmd->advertising = (ADVERTISED_FIBRE |
+				     ADVERTISED_1000baseKX_Full);
+		if (hw->mac.type == e1000_i354) {
+			if ((hw->device_id ==
+			     E1000_DEV_ID_I354_BACKPLANE_2_5GBPS) &&
+			    !(status & E1000_STATUS_2P5_SKU_OVER)) {
+				ecmd->supported |= SUPPORTED_2500baseX_Full;
+				ecmd->supported &=
+					~SUPPORTED_1000baseKX_Full;
+				ecmd->advertising |= ADVERTISED_2500baseX_Full;
+				ecmd->advertising &=
+					~ADVERTISED_1000baseKX_Full;
+			}
 		}
 		if (eth_flags->e100_base_fx) {
 			ecmd->supported |= SUPPORTED_100baseT_Full;
@@ -187,35 +197,29 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->port = PORT_FIBRE;
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
-
 	if (hw->mac.autoneg != 1)
 		ecmd->advertising &= ~(ADVERTISED_Pause |
 				       ADVERTISED_Asym_Pause);
 
-	if (hw->fc.requested_mode == e1000_fc_full)
+	switch (hw->fc.requested_mode) {
+	case e1000_fc_full:
 		ecmd->advertising |= ADVERTISED_Pause;
-	else if (hw->fc.requested_mode == e1000_fc_rx_pause)
+		break;
+	case e1000_fc_rx_pause:
 		ecmd->advertising |= (ADVERTISED_Pause |
 				      ADVERTISED_Asym_Pause);
-	else if (hw->fc.requested_mode == e1000_fc_tx_pause)
+		break;
+	case e1000_fc_tx_pause:
 		ecmd->advertising |=  ADVERTISED_Asym_Pause;
-	else
+		break;
+	default:
 		ecmd->advertising &= ~(ADVERTISED_Pause |
 				       ADVERTISED_Asym_Pause);
-
-	status = rd32(E1000_STATUS);
-
+	}
 	if (status & E1000_STATUS_LU) {
-		if (hw->mac.type == e1000_i354) {
-			if ((status & E1000_STATUS_2P5_SKU) &&
-			    !(status & E1000_STATUS_2P5_SKU_OVER)) {
-				ecmd->supported = SUPPORTED_2500baseX_Full;
-				ecmd->advertising = ADVERTISED_2500baseX_Full;
-				ecmd->speed = SPEED_2500;
-			} else {
-				ecmd->supported = SUPPORTED_1000baseT_Full;
-				ecmd->advertising = ADVERTISED_1000baseT_Full;
-			}
+		if ((status & E1000_STATUS_2P5_SKU) &&
+		    !(status & E1000_STATUS_2P5_SKU_OVER)) {
+			ecmd->speed = SPEED_2500;
 		} else if (status & E1000_STATUS_SPEED_1000) {
 			ecmd->speed = SPEED_1000;
 		} else if (status & E1000_STATUS_SPEED_100) {
@@ -232,7 +236,6 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->speed = -1;
 		ecmd->duplex = -1;
 	}
-
 	if ((hw->phy.media_type == e1000_media_type_fiber) ||
 	    hw->mac.autoneg)
 		ecmd->autoneg = AUTONEG_ENABLE;
-- 
1.8.3.1
