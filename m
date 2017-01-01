From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: dec: uli526x: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 19:11:06 +0100
Message-ID: <1483294266-6222-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, a@unstable.cc,
        fw@strlen.de, jarod@redhat.com
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/dec/tulip/uli526x.c |   41 +++++++++++++++++------------
 1 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index f82ebe5..8d98b259 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -926,48 +926,53 @@ static void uli526x_set_filter_mode(struct net_device * dev)
 }
 
 static void
-ULi_ethtool_gset(struct uli526x_board_info *db, struct ethtool_cmd *ecmd)
+ULi_ethtool_get_link_ksettings(struct uli526x_board_info *db,
+			       struct ethtool_link_ksettings *cmd)
 {
-	ecmd->supported = (SUPPORTED_10baseT_Half |
+	u32 supported, advertising;
+
+	supported = (SUPPORTED_10baseT_Half |
 	                   SUPPORTED_10baseT_Full |
 	                   SUPPORTED_100baseT_Half |
 	                   SUPPORTED_100baseT_Full |
 	                   SUPPORTED_Autoneg |
 	                   SUPPORTED_MII);
 
-	ecmd->advertising = (ADVERTISED_10baseT_Half |
+	advertising = (ADVERTISED_10baseT_Half |
 	                   ADVERTISED_10baseT_Full |
 	                   ADVERTISED_100baseT_Half |
 	                   ADVERTISED_100baseT_Full |
 	                   ADVERTISED_Autoneg |
 	                   ADVERTISED_MII);
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
-	ecmd->port = PORT_MII;
-	ecmd->phy_address = db->phy_addr;
-
-	ecmd->transceiver = XCVR_EXTERNAL;
+	cmd->base.port = PORT_MII;
+	cmd->base.phy_address = db->phy_addr;
 
-	ethtool_cmd_speed_set(ecmd, SPEED_10);
-	ecmd->duplex = DUPLEX_HALF;
+	cmd->base.speed = SPEED_10;
+	cmd->base.duplex = DUPLEX_HALF;
 
 	if(db->op_mode==ULI526X_100MHF || db->op_mode==ULI526X_100MFD)
 	{
-		ethtool_cmd_speed_set(ecmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 	}
 	if(db->op_mode==ULI526X_10MFD || db->op_mode==ULI526X_100MFD)
 	{
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	}
 	if(db->link_failed)
 	{
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
 	if (db->media_mode & ULI526X_AUTO)
 	{
-		ecmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	}
 }
 
@@ -981,10 +986,12 @@ static void netdev_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, pci_name(np->pdev), sizeof(info->bus_info));
 }
 
-static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd) {
+static int netdev_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
+{
 	struct uli526x_board_info *np = netdev_priv(dev);
 
-	ULi_ethtool_gset(np, cmd);
+	ULi_ethtool_get_link_ksettings(np, cmd);
 
 	return 0;
 }
@@ -1006,9 +1013,9 @@ static void uli526x_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
-	.get_settings		= netdev_get_settings,
 	.get_link		= netdev_get_link,
 	.get_wol		= uli526x_get_wol,
+	.get_link_ksettings	= netdev_get_link_ksettings,
 };
 
 /*
-- 
1.7.4.4

