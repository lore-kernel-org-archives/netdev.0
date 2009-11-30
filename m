From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6 6/6] be2net: fix unnecessary access to
 hardware to get link, port info
Date: Mon, 30 Nov 2009 09:27:46 +0530
Message-ID: <20091130035736.GA15579@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29542 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752885AbZK3D5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 22:57:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every time while doing ethtool->get_settings we are accessing
the hardware to get link status and port information.
This is not necessary.  We now use the cached copy for this info
and update it when the link status changes.

From: Suresh R <sureshr@serverengines.com>

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    2 +
 drivers/net/benet/be_ethtool.c |   56 ++++++++++++++++++++++++---------------
 drivers/net/benet/be_main.c    |    3 ++
 3 files changed, 39 insertions(+), 22 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index d90cc01..1224748 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -272,6 +272,8 @@ struct be_adapter {
 	u32 cap;
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
+	int link_speed;
+	u8 port_type;
 };
 
 extern const struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 3c05f2b..329560f 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -297,36 +297,48 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	u8 mac_speed = 0, connector = 0;
 	u16 link_speed = 0;
 	bool link_up = false;
+	int status;
 
-	be_cmd_link_status_query(adapter, &link_up, &mac_speed, &link_speed);
+	if (adapter->link_speed < 0) {
+		status = be_cmd_link_status_query(adapter, &link_up,
+						&mac_speed, &link_speed);
+
+		/* link_speed is in units of 10 Mbps */
+		if (link_speed) {
+			ecmd->speed = link_speed*10;
+		} else {
+			switch (mac_speed) {
+			case PHY_LINK_SPEED_1GBPS:
+				ecmd->speed = SPEED_1000;
+				break;
+			case PHY_LINK_SPEED_10GBPS:
+				ecmd->speed = SPEED_10000;
+				break;
+			}
+		}
 
-	/* link_speed is in units of 10 Mbps */
-	if (link_speed) {
-		ecmd->speed = link_speed*10;
-	} else {
-		switch (mac_speed) {
-		case PHY_LINK_SPEED_1GBPS:
-			ecmd->speed = SPEED_1000;
+		status = be_cmd_read_port_type(adapter, adapter->port_num,
+						&connector);
+		switch (connector) {
+		case 7:
+			ecmd->port = PORT_FIBRE;
 			break;
-		case PHY_LINK_SPEED_10GBPS:
-			ecmd->speed = SPEED_10000;
+		default:
+			ecmd->port = PORT_TP;
 			break;
 		}
+
+		/* Save for future use */
+		adapter->link_speed = ecmd->speed;
+		adapter->port_type = ecmd->port;
+	} else {
+		ecmd->speed = adapter->link_speed;
+		ecmd->port = adapter->port_type;
 	}
+
 	ecmd->duplex = DUPLEX_FULL;
 	ecmd->autoneg = AUTONEG_DISABLE;
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_TP);
-
-	be_cmd_read_port_type(adapter, adapter->port_num, &connector);
-	switch (connector) {
-	case 7:
-		ecmd->port = PORT_FIBRE;
-		break;
-	default:
-		ecmd->port = PORT_TP;
-		break;
-	}
-
 	ecmd->phy_address = adapter->port_num;
 	ecmd->transceiver = XCVR_INTERNAL;
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f3e97ab..e291b1b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -220,6 +220,7 @@ void be_link_status_update(struct be_adapter *adapter, bool link_up)
 
 	/* If link came up or went down */
 	if (adapter->link_up != link_up) {
+		adapter->link_speed = -1;
 		if (link_up) {
 			netif_start_queue(netdev);
 			netif_carrier_on(netdev);
@@ -1674,6 +1675,8 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
+	adapter->link_speed = -1;
+
 	return 0;
 
 rx_qs_destroy:
-- 
1.6.3.3

