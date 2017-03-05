From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: toshiba: ps3_genic_net: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun,  5 Mar 2017 23:21:06 +0100
Message-ID: <1488752466-27232-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: geoff@infradead.org, benh@kernel.crashing.org, paulus@samba.org,
 mpe@ellerman.id.au, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c |   51 +++++++++++++++-----------
 1 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 7201331..fa6a065 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1206,61 +1206,68 @@ void gelic_net_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
-static int gelic_ether_get_settings(struct net_device *netdev,
-				    struct ethtool_cmd *cmd)
+static int gelic_ether_get_link_ksettings(struct net_device *netdev,
+					  struct ethtool_link_ksettings *cmd)
 {
 	struct gelic_card *card = netdev_card(netdev);
+	u32 supported, advertising;
 
 	gelic_card_get_ether_port_status(card, 0);
 
 	if (card->ether_port_status & GELIC_LV1_ETHER_FULL_DUPLEX)
-		cmd->duplex = DUPLEX_FULL;
+		cmd->base.duplex = DUPLEX_FULL;
 	else
-		cmd->duplex = DUPLEX_HALF;
+		cmd->base.duplex = DUPLEX_HALF;
 
 	switch (card->ether_port_status & GELIC_LV1_ETHER_SPEED_MASK) {
 	case GELIC_LV1_ETHER_SPEED_10:
-		ethtool_cmd_speed_set(cmd, SPEED_10);
+		cmd->base.speed = SPEED_10;
 		break;
 	case GELIC_LV1_ETHER_SPEED_100:
-		ethtool_cmd_speed_set(cmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 		break;
 	case GELIC_LV1_ETHER_SPEED_1000:
-		ethtool_cmd_speed_set(cmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 		break;
 	default:
 		pr_info("%s: speed unknown\n", __func__);
-		ethtool_cmd_speed_set(cmd, SPEED_10);
+		cmd->base.speed = SPEED_10;
 		break;
 	}
 
-	cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg |
+	supported = SUPPORTED_TP | SUPPORTED_Autoneg |
 			SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			SUPPORTED_1000baseT_Full;
-	cmd->advertising = cmd->supported;
+	advertising = supported;
 	if (card->link_mode & GELIC_LV1_ETHER_AUTO_NEG) {
-		cmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->advertising &= ~ADVERTISED_Autoneg;
+		cmd->base.autoneg = AUTONEG_DISABLE;
+		advertising &= ~ADVERTISED_Autoneg;
 	}
-	cmd->port = PORT_TP;
+	cmd->base.port = PORT_TP;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
 
-static int gelic_ether_set_settings(struct net_device *netdev,
-				    struct ethtool_cmd *cmd)
+static int
+gelic_ether_set_link_ksettings(struct net_device *netdev,
+			       const struct ethtool_link_ksettings *cmd)
 {
 	struct gelic_card *card = netdev_card(netdev);
 	u64 mode;
 	int ret;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		mode = GELIC_LV1_ETHER_AUTO_NEG;
 	} else {
-		switch (cmd->speed) {
+		switch (cmd->base.speed) {
 		case SPEED_10:
 			mode = GELIC_LV1_ETHER_SPEED_10;
 			break;
@@ -1273,9 +1280,9 @@ static int gelic_ether_set_settings(struct net_device *netdev,
 		default:
 			return -EINVAL;
 		}
-		if (cmd->duplex == DUPLEX_FULL)
+		if (cmd->base.duplex == DUPLEX_FULL) {
 			mode |= GELIC_LV1_ETHER_FULL_DUPLEX;
-		else if (cmd->speed == SPEED_1000) {
+		} else if (cmd->base.speed == SPEED_1000) {
 			pr_info("1000 half duplex is not supported.\n");
 			return -EINVAL;
 		}
@@ -1370,11 +1377,11 @@ static int gelic_net_set_wol(struct net_device *netdev,
 
 static const struct ethtool_ops gelic_ether_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
-	.get_settings	= gelic_ether_get_settings,
-	.set_settings	= gelic_ether_set_settings,
 	.get_link	= ethtool_op_get_link,
 	.get_wol	= gelic_net_get_wol,
 	.set_wol	= gelic_net_set_wol,
+	.get_link_ksettings = gelic_ether_get_link_ksettings,
+	.set_link_ksettings = gelic_ether_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
