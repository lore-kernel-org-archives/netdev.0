From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v4 08/11] drivers: net: xgene: ethtool: Use phy_ethtool_gset and sset
Date: Wed,  6 Jul 2016 17:35:09 -0700
Message-ID: <1467851712-24780-9-git-send-email-isubramanian@apm.com>
References: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	matthias.bgg@gmail.com, andrew@lunn.ch,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35721 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbcGGAfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 20:35:34 -0400
Received: by mail-pf0-f169.google.com with SMTP id c2so875831pfa.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 17:35:29 -0700 (PDT)
In-Reply-To: <1467851712-24780-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed SGMII 1G get_settings to use phy_ethtool_gset.
Changed SGMII 1G set_settings to use phy_ethtool_sset.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 416d6eb..22a7b26 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -65,8 +65,15 @@ static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 
 		return phy_ethtool_gset(phydev, cmd);
 	} else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
-		cmd->supported = SUPPORTED_1000baseT_Full |
-				 SUPPORTED_Autoneg | SUPPORTED_MII;
+		if (pdata->mdio_driver) {
+			if (!phydev)
+				return -ENODEV;
+
+			return phy_ethtool_gset(phydev, cmd);
+		}
+
+		cmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+				 SUPPORTED_MII;
 		cmd->advertising = cmd->supported;
 		ethtool_cmd_speed_set(cmd, SPEED_1000);
 		cmd->duplex = DUPLEX_FULL;
@@ -92,12 +99,21 @@ static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 	struct phy_device *phydev = pdata->phy_dev;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		if (phydev == NULL)
+		if (!phydev)
 			return -ENODEV;
 
 		return phy_ethtool_sset(phydev, cmd);
 	}
 
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
+		if (pdata->mdio_driver) {
+			if (!phydev)
+				return -ENODEV;
+
+			return phy_ethtool_sset(phydev, cmd);
+		}
+	}
+
 	return -EINVAL;
 }
 
-- 
1.9.1
