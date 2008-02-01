From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/8] ixbge: Make ethtool code account for media types
Date: Fri, 01 Feb 2008 15:58:54 -0800
Message-ID: <20080201235854.31474.16988.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31020 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758136AbYBBADW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 19:03:22 -0500
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

The i82598 can support various media types but this ethtool
code only was coded for fiber just yet.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   52 ++++++++++++++++++++++++++-----------
 1 files changed, 36 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 9f3cdb8..b447dd7 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -103,21 +103,41 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = 0;
+	bool link_up;
 
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->port = PORT_FIBRE;
+	ecmd->supported = SUPPORTED_10000baseT_Full;
+	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
+	if (hw->phy.media_type == ixgbe_media_type_copper) {
+		ecmd->supported |= (SUPPORTED_1000baseT_Full |
+				    SUPPORTED_TP | SUPPORTED_Autoneg);
+
+		ecmd->advertising = (ADVERTISED_TP | ADVERTISED_Autoneg);
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
+			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+
+		ecmd->port = PORT_TP;
+	} else {
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising = (ADVERTISED_10000baseT_Full |
+				     ADVERTISED_FIBRE);
+		ecmd->port = PORT_FIBRE;
+	}
 
-	if (netif_carrier_ok(adapter->netdev)) {
-		ecmd->speed = SPEED_10000;
+	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up);
+	if (link_up) {
+		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+				SPEED_10000 : SPEED_1000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ecmd->speed = -1;
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -125,17 +145,17 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
-		return -EINVAL;
-
-	if (netif_running(adapter->netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_reset(adapter);
-		ixgbe_up(adapter);
-	} else {
-		ixgbe_reset(adapter);
+	switch (hw->phy.media_type) {
+	case ixgbe_media_type_fiber:
+		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
+		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+			return -EINVAL;
+		/* in this case we currently only support 10Gb/FULL */
+		break;
+	default:
+		break;
 	}
 
 	return 0;

