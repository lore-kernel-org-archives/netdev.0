From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] igb: Support for 100base-fx SFP
Date: Thu,  4 Apr 2013 04:37:51 -0700
Message-ID: <1365075480-20183-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29187 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758847Ab3DDLiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:23 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch adds support for 100base-fx SFP and report proper link
speed/duplex via Ethtool.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_hw.h    |  3 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 48 ++++++++++++++++++++--------
 drivers/net/ethernet/intel/igb/igb_main.c    | 13 +++++---
 3 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
index 0d5cf9c..f8cd124 100644
--- a/drivers/net/ethernet/intel/igb/e1000_hw.h
+++ b/drivers/net/ethernet/intel/igb/e1000_hw.h
@@ -98,7 +98,8 @@ enum e1000_mac_type {
 enum e1000_media_type {
 	e1000_media_type_unknown = 0,
 	e1000_media_type_copper = 1,
-	e1000_media_type_internal_serdes = 2,
+	e1000_media_type_fiber = 2,
+	e1000_media_type_internal_serdes = 3,
 	e1000_num_media_types
 };
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a3830a8..8499c48 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -178,27 +178,33 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 		ecmd->port = PORT_TP;
 		ecmd->phy_address = hw->phy.addr;
+		ecmd->transceiver = XCVR_INTERNAL;
 	} else {
 		ecmd->supported   = (SUPPORTED_1000baseT_Full |
+				     SUPPORTED_100baseT_Full |
+				     SUPPORTED_Autoneg |
 				     SUPPORTED_FIBRE |
-				     SUPPORTED_Autoneg);
+				     SUPPORTED_Pause);
 
-		ecmd->advertising = (ADVERTISED_1000baseT_Full |
-				     ADVERTISED_FIBRE |
-				     ADVERTISED_Autoneg |
-				     ADVERTISED_Pause);
+		ecmd->advertising = ADVERTISED_FIBRE;
+
+		if (adapter->link_speed == SPEED_100)
+			ecmd->advertising = ADVERTISED_100baseT_Full;
+		else if (adapter->link_speed == SPEED_1000)
+			ecmd->advertising = ADVERTISED_1000baseT_Full;
+
+		if (hw->mac.autoneg == 1)
+			ecmd->advertising |= ADVERTISED_Autoneg;
 
 		ecmd->port = PORT_FIBRE;
+		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	ecmd->transceiver = XCVR_INTERNAL;
-
 	status = rd32(E1000_STATUS);
 
 	if (status & E1000_STATUS_LU) {
 
-		if ((status & E1000_STATUS_SPEED_1000) ||
-		    hw->phy.media_type != e1000_media_type_copper)
+		if (status & E1000_STATUS_SPEED_1000)
 			ethtool_cmd_speed_set(ecmd, SPEED_1000);
 		else if (status & E1000_STATUS_SPEED_100)
 			ethtool_cmd_speed_set(ecmd, SPEED_100);
@@ -215,7 +221,11 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = hw->mac.autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	if ((hw->phy.media_type == e1000_media_type_fiber) ||
+	    hw->mac.autoneg)
+		ecmd->autoneg = AUTONEG_ENABLE;
+	else
+		ecmd->autoneg = AUTONEG_DISABLE;
 
 	/* MDI-X => 2; MDI =>1; Invalid =>0 */
 	if (hw->phy.media_type == e1000_media_type_copper)
@@ -266,9 +276,21 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->mac.autoneg = 1;
-		hw->phy.autoneg_advertised = ecmd->advertising |
-					     ADVERTISED_TP |
-					     ADVERTISED_Autoneg;
+		if (hw->phy.media_type == e1000_media_type_fiber) {
+			hw->phy.autoneg_advertised = ecmd->advertising |
+						     ADVERTISED_FIBRE |
+						     ADVERTISED_Autoneg;
+			if (adapter->link_speed == SPEED_1000)
+				hw->phy.autoneg_advertised =
+					ADVERTISED_1000baseT_Full;
+			else if (adapter->link_speed == SPEED_100)
+				hw->phy.autoneg_advertised =
+					ADVERTISED_100baseT_Full;
+		} else {
+			hw->phy.autoneg_advertised = ecmd->advertising |
+						     ADVERTISED_TP |
+						     ADVERTISED_Autoneg;
+		}
 		ecmd->advertising = hw->phy.autoneg_advertised;
 		if (adapter->fc_autoneg)
 			hw->fc.requested_mode = e1000_fc_default;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8496adf..fb162ef 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7008,11 +7008,14 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
 	if ((spd & 1) || (dplx & ~1))
 		goto err_inval;
 
-	/* Fiber NIC's only allow 1000 Gbps Full duplex */
-	if ((adapter->hw.phy.media_type == e1000_media_type_internal_serdes) &&
-	    spd != SPEED_1000 &&
-	    dplx != DUPLEX_FULL)
-		goto err_inval;
+	/* Fiber NIC's only allow 1000 gbps Full duplex
+	 * and 100Mbps Full duplex for 100baseFx sfp
+	 */
+	if (adapter->hw.phy.media_type == e1000_media_type_internal_serdes) {
+		if ((spd + dplx != (SPEED_1000 + DUPLEX_FULL)) ||
+		    (spd + dplx != (SPEED_100 + DUPLEX_FULL)))
+			goto err_inval;
+	}
 
 	switch (spd + dplx) {
 	case SPEED_10 + DUPLEX_HALF:
-- 
1.7.11.7
