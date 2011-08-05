From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 6/6] be2net: fix to set ecmd->autoneg correctly
Date: Fri, 5 Aug 2011 15:01:07 -0500
Message-ID: <20110805200107.GA13631@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2949 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756287Ab1HEUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:01:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the autonegotation settings correctly based on the port speed.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 5dd3ed6..2177c8c 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -353,6 +353,8 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	u8 mac_speed = 0;
 	u16 link_speed = 0;
 	int status;
+	u16 port_speed = 0;
+	u16 dac_cable_len = 0;
 
 	if ((adapter->link_speed < 0) || (!(netdev->flags & IFF_UP))) {
 		status = be_cmd_link_status_query(adapter, &mac_speed,
@@ -397,11 +399,9 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			switch (phy_info.interface_type) {
 			case PHY_TYPE_KR_10GB:
 			case PHY_TYPE_KX4_10GB:
-				ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->transceiver = XCVR_INTERNAL;
 				break;
 			default:
-				ecmd->autoneg = AUTONEG_DISABLE;
 				ecmd->transceiver = XCVR_EXTERNAL;
 				break;
 			}
@@ -411,12 +411,25 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		adapter->link_speed = ethtool_cmd_speed(ecmd);
 		adapter->port_type = ecmd->port;
 		adapter->transceiver = ecmd->transceiver;
-		adapter->autoneg = ecmd->autoneg;
 	} else {
 		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->port = adapter->port_type;
 		ecmd->transceiver = adapter->transceiver;
-		ecmd->autoneg = adapter->autoneg;
+	}
+
+	be_cmd_get_port_speed(adapter, adapter->port_num,
+			&dac_cable_len, &port_speed);
+	switch (port_speed) {
+	case SPEED_FORCED_10GB:
+	case SPEED_FORCED_1GB:
+	case SPEED_FORCED_100MB:
+	case SPEED_FORCED_10MB:
+	case SPEED_DEFAULT:
+		ecmd->autoneg = AUTONEG_DISABLE;
+		break;
+	default:
+		ecmd->autoneg = AUTONEG_ENABLE;
+		break;
 	}
 
 	ecmd->duplex = DUPLEX_FULL;
-- 
1.7.4.1

