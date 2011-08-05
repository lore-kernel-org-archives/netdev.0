From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 4/6] be2net: add ethtool::set_settings support
Date: Fri, 5 Aug 2011 15:00:36 -0500
Message-ID: <20110805200036.GA13585@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2946 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755900Ab1HEUBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 16:01:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |   63 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index f144a6f..5dd3ed6 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -443,6 +443,68 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
+static int be_set_settings(struct net_device *netdev,
+				struct ethtool_cmd *ecmd)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_phy_info phy_info;
+	u16 mac_speed = 0;
+	u16 dac_cable_len = 0;
+	u16 port_speed = 0;
+	int status;
+
+	status = be_cmd_get_phy_info(adapter, &phy_info);
+	if (status) {
+		dev_err(&adapter->pdev->dev, "Get phy info cmd failed.\n");
+		return status;
+	}
+
+	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		switch (phy_info.interface_type) {
+		case PHY_TYPE_SFP_1GB:
+		case PHY_TYPE_BASET_1GB:
+		case PHY_TYPE_BASEX_1GB:
+		case PHY_TYPE_SGMII:
+			mac_speed = SPEED_AUTONEG_1GB_100MB_10MB;
+			break;
+		case PHY_TYPE_SFP_PLUS_10GB:
+			 dev_warn(&adapter->pdev->dev,
+				"Autoneg not supported on this module.\n");
+			 return -EINVAL;
+		case PHY_TYPE_KR_10GB:
+		case PHY_TYPE_KX4_10GB:
+			 mac_speed = SPEED_AUTONEG_10GB_1GB;
+			 break;
+		case PHY_TYPE_BASET_10GB:
+			 mac_speed = SPEED_AUTONEG_10GB_1GB_100MB;
+			 break;
+		}
+	} else if (ecmd->autoneg == AUTONEG_DISABLE) {
+		if (ethtool_cmd_speed(ecmd) == SPEED_10)
+			mac_speed = SPEED_FORCED_10MB;
+		else if (ethtool_cmd_speed(ecmd) == SPEED_100)
+			mac_speed = SPEED_FORCED_100MB;
+		else if (ethtool_cmd_speed(ecmd) == SPEED_1000)
+			mac_speed = SPEED_FORCED_1GB;
+		else if (ethtool_cmd_speed(ecmd) == SPEED_10000)
+			mac_speed = SPEED_FORCED_10GB;
+	}
+
+	status = be_cmd_get_port_speed(adapter, adapter->port_num,
+						&dac_cable_len, &port_speed);
+	if (status) {
+		dev_err(&adapter->pdev->dev, "Get port speed cmd failed.\n");
+		return status;
+	}
+
+	status = be_cmd_set_port_speed_v1(adapter, adapter->port_num,
+						mac_speed, dac_cable_len);
+	if (status)
+		dev_err(&adapter->pdev->dev, "Set port speed cmd failed.\n");
+
+	return status;
+}
+
 static void
 be_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
@@ -692,6 +754,7 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
+	.set_settings = be_set_settings,
 	.get_drvinfo = be_get_drvinfo,
 	.get_wol = be_get_wol,
 	.set_wol = be_set_wol,
-- 
1.7.4.1

