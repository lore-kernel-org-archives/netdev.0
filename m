From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 16/16] ixgbe: Adding 100MB FULL support in ethtool
Date: Tue,  8 Feb 2011 04:29:27 -0800
Message-ID: <1297168167-15755-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Atita Shirwaikar <atita.shirwaikar@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38672 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015Ab1BHM3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:41 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atita Shirwaikar <atita.shirwaikar@intel.com>

Current driver does not show 100MB support in ethtool.
Adding support for the same.

Signed-off-by: Atita Shirwaikar <atita.shirwaikar@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   34 ++++++++++++++++++++++++++++++++--
 drivers/net/ixgbe/ixgbe_main.c    |    5 ++++-
 2 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 2002ea8..309272f 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -152,7 +152,17 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		ecmd->supported |= (SUPPORTED_1000baseT_Full |
 		                    SUPPORTED_Autoneg);
 
+		switch (hw->mac.type) {
+		case ixgbe_mac_X540:
+			ecmd->supported |= SUPPORTED_100baseT_Full;
+			break;
+		default:
+			break;
+		}
+
 		ecmd->advertising = ADVERTISED_Autoneg;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
+			ecmd->advertising |= ADVERTISED_100baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
 			ecmd->advertising |= ADVERTISED_10000baseT_Full;
 		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
@@ -167,6 +177,15 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= (ADVERTISED_10000baseT_Full |
 					      ADVERTISED_1000baseT_Full);
 
+		switch (hw->mac.type) {
+		case ixgbe_mac_X540:
+			if (!(ecmd->advertising & ADVERTISED_100baseT_Full))
+				ecmd->advertising |= (ADVERTISED_100baseT_Full);
+			break;
+		default:
+			break;
+		}
+
 		if (hw->phy.media_type == ixgbe_media_type_copper) {
 			ecmd->supported |= SUPPORTED_TP;
 			ecmd->advertising |= ADVERTISED_TP;
@@ -271,8 +290,19 @@ static int ixgbe_get_settings(struct net_device *netdev,
 
 	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	if (link_up) {
-		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
-		               SPEED_10000 : SPEED_1000;
+		switch (link_speed) {
+		case IXGBE_LINK_SPEED_10GB_FULL:
+			ecmd->speed = SPEED_10000;
+			break;
+		case IXGBE_LINK_SPEED_1GB_FULL:
+			ecmd->speed = SPEED_1000;
+			break;
+		case IXGBE_LINK_SPEED_100_FULL:
+			ecmd->speed = SPEED_100;
+			break;
+		default:
+			break;
+		}
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ecmd->speed = -1;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2dab240..7947063 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6094,7 +6094,10 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
 			       "10 Gbps" :
 			       (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-			       "1 Gbps" : "unknown speed")),
+			       "1 Gbps" :
+			       (link_speed == IXGBE_LINK_SPEED_100_FULL ?
+			       "100 Mbps" :
+			       "unknown speed"))),
 			       ((flow_rx && flow_tx) ? "RX/TX" :
 			       (flow_rx ? "RX" :
 			       (flow_tx ? "TX" : "None"))));
-- 
1.7.4

