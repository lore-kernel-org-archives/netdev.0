From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 07/14] be2net: Fix ethtool get_settings output for VF
Date: Sat, 20 Oct 2012 21:33:04 +0530
Message-ID: <9a832229-828d-4800-baf1-5f518e3f3bbe@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22353 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab2JTQEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:04:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return default values for fields for which VFs dont have privilege to get the
required information from FW.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   73 ++++++++++++++----------
 1 files changed, 42 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 2496123..00454a1 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -528,6 +528,10 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	u8 link_status;
 	u16 link_speed = 0;
 	int status;
+	u32 auto_speeds;
+	u32 fixed_speeds;
+	u32 dac_cable_len;
+	u16 interface_type;
 
 	if (adapter->phy.link_speed < 0) {
 		status = be_cmd_link_status_query(adapter, &link_speed,
@@ -537,39 +541,46 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ethtool_cmd_speed_set(ecmd, link_speed);
 
 		status = be_cmd_get_phy_info(adapter);
-		if (status)
-			return status;
-
-		ecmd->supported =
-			convert_to_et_setting(adapter->phy.interface_type,
-					adapter->phy.auto_speeds_supported |
-					adapter->phy.fixed_speeds_supported);
-		ecmd->advertising =
-			convert_to_et_setting(adapter->phy.interface_type,
-					adapter->phy.auto_speeds_supported);
-
-		ecmd->port = be_get_port_type(adapter->phy.interface_type,
-					      adapter->phy.dac_cable_len);
-
-		if (adapter->phy.auto_speeds_supported) {
-			ecmd->supported |= SUPPORTED_Autoneg;
-			ecmd->autoneg = AUTONEG_ENABLE;
-			ecmd->advertising |= ADVERTISED_Autoneg;
-		}
+		if (!status) {
+			interface_type = adapter->phy.interface_type;
+			auto_speeds = adapter->phy.auto_speeds_supported;
+			fixed_speeds = adapter->phy.fixed_speeds_supported;
+			dac_cable_len = adapter->phy.dac_cable_len;
+
+			ecmd->supported =
+				convert_to_et_setting(interface_type,
+						      auto_speeds |
+						      fixed_speeds);
+			ecmd->advertising =
+				convert_to_et_setting(interface_type,
+						      auto_speeds);
+
+			ecmd->port = be_get_port_type(interface_type,
+						      dac_cable_len);
+
+			if (adapter->phy.auto_speeds_supported) {
+				ecmd->supported |= SUPPORTED_Autoneg;
+				ecmd->autoneg = AUTONEG_ENABLE;
+				ecmd->advertising |= ADVERTISED_Autoneg;
+			}
 
-		if (be_pause_supported(adapter)) {
 			ecmd->supported |= SUPPORTED_Pause;
-			ecmd->advertising |= ADVERTISED_Pause;
-		}
-
-		switch (adapter->phy.interface_type) {
-		case PHY_TYPE_KR_10GB:
-		case PHY_TYPE_KX4_10GB:
-			ecmd->transceiver = XCVR_INTERNAL;
-			break;
-		default:
-			ecmd->transceiver = XCVR_EXTERNAL;
-			break;
+			if (be_pause_supported(adapter))
+				ecmd->advertising |= ADVERTISED_Pause;
+
+			switch (adapter->phy.interface_type) {
+			case PHY_TYPE_KR_10GB:
+			case PHY_TYPE_KX4_10GB:
+				ecmd->transceiver = XCVR_INTERNAL;
+				break;
+			default:
+				ecmd->transceiver = XCVR_EXTERNAL;
+				break;
+			}
+		} else {
+			ecmd->port = PORT_OTHER;
+			ecmd->autoneg = AUTONEG_DISABLE;
+			ecmd->transceiver = XCVR_DUMMY1;
 		}
 
 		/* Save for future use */
-- 
1.6.0.2
