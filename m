From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-2.6 PATCH 3/3] be2net: Bug fix to return correct values in
 ethtool get_settings.
Date: Wed, 23 Dec 2009 20:12:51 +0530
Message-ID: <20091223144241.GA23415@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:11782 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751669AbZLWOmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:42:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to return correct values for transceiver and supported in
ethtool get_settings function.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_ethtool.c |   40 +++++++++++++++++++++++++++++++---------
 2 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 9e56014..9fd8e5e 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -275,6 +275,7 @@ struct be_adapter {
 	u32 tx_fc;		/* Tx flow control */
 	int link_speed;
 	u8 port_type;
+	u8 transceiver;
 };
 
 extern const struct ethtool_ops be_ethtool_ops;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index da66d15..5d001c4 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -340,28 +340,50 @@ static int be_get_settings(struct net_de
 
 		status = be_cmd_read_port_type(adapter, adapter->port_num,
 						&connector);
-		switch (connector) {
-		case 7:
-			ecmd->port = PORT_FIBRE;
-			break;
-		default:
-			ecmd->port = PORT_TP;
-			break;
+		if (!status) {
+			switch (connector) {
+			case 7:
+				ecmd->port = PORT_FIBRE;
+				ecmd->transceiver = XCVR_EXTERNAL;
+				break;
+			case 0:
+				ecmd->port = PORT_TP;
+				ecmd->transceiver = XCVR_EXTERNAL;
+				break;
+			default:
+				ecmd->port = PORT_TP;
+				ecmd->transceiver = XCVR_INTERNAL;
+				break;
+			}
+		} else {
+			ecmd->port = PORT_AUI;
+			ecmd->transceiver = XCVR_INTERNAL;
 		}
 
 		/* Save for future use */
 		adapter->link_speed = ecmd->speed;
 		adapter->port_type = ecmd->port;
+		adapter->transceiver = ecmd->transceiver;
 	} else {
 		ecmd->speed = adapter->link_speed;
 		ecmd->port = adapter->port_type;
+		ecmd->transceiver = adapter->transceiver;
 	}
 
 	ecmd->duplex = DUPLEX_FULL;
 	ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_TP);
 	ecmd->phy_address = adapter->port_num;
-	ecmd->transceiver = XCVR_INTERNAL;
+	switch (ecmd->port) {
+	case PORT_FIBRE:
+		ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+		break;
+	case PORT_TP:
+		ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_TP);
+		break;
+	case PORT_AUI:
+		ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_AUI);
+		break;
+	}
 
 	return 0;
 }
-- 
1.4.0

