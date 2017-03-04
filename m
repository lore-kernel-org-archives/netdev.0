From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sun: niu: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  4 Mar 2017 17:50:06 +0100
Message-ID: <1488646206-8966-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com,
        akpm@linux-foundation.org, vbabka@suse.cz, jarod@redhat.com,
        edumazet@google.com, iamjoonsoo.kim@lge.com, fw@strlen.de,
        stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sun/niu.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 5797805..2dcca24 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6813,7 +6813,8 @@ static void niu_get_drvinfo(struct net_device *dev,
 			sizeof(info->bus_info));
 }
 
-static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int niu_get_link_ksettings(struct net_device *dev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct niu *np = netdev_priv(dev);
 	struct niu_link_config *lp;
@@ -6821,28 +6822,30 @@ static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	lp = &np->link_config;
 
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->phy_address = np->phy_addr;
-	cmd->supported = lp->supported;
-	cmd->advertising = lp->active_advertising;
-	cmd->autoneg = lp->active_autoneg;
-	ethtool_cmd_speed_set(cmd, lp->active_speed);
-	cmd->duplex = lp->active_duplex;
-	cmd->port = (np->flags & NIU_FLAGS_FIBER) ? PORT_FIBRE : PORT_TP;
-	cmd->transceiver = (np->flags & NIU_FLAGS_XCVR_SERDES) ?
-		XCVR_EXTERNAL : XCVR_INTERNAL;
+	cmd->base.phy_address = np->phy_addr;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						lp->supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						lp->active_advertising);
+	cmd->base.autoneg = lp->active_autoneg;
+	cmd->base.speed = lp->active_speed;
+	cmd->base.duplex = lp->active_duplex;
+	cmd->base.port = (np->flags & NIU_FLAGS_FIBER) ? PORT_FIBRE : PORT_TP;
 
 	return 0;
 }
 
-static int niu_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int niu_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct niu *np = netdev_priv(dev);
 	struct niu_link_config *lp = &np->link_config;
 
-	lp->advertising = cmd->advertising;
-	lp->speed = ethtool_cmd_speed(cmd);
-	lp->duplex = cmd->duplex;
-	lp->autoneg = cmd->autoneg;
+	ethtool_convert_link_mode_to_legacy_u32(&lp->advertising,
+						cmd->link_modes.advertising);
+	lp->speed = cmd->base.speed;
+	lp->duplex = cmd->base.duplex;
+	lp->autoneg = cmd->base.autoneg;
 	return niu_init_link(np);
 }
 
@@ -7902,14 +7905,14 @@ static int niu_set_phys_id(struct net_device *dev,
 	.nway_reset		= niu_nway_reset,
 	.get_eeprom_len		= niu_get_eeprom_len,
 	.get_eeprom		= niu_get_eeprom,
-	.get_settings		= niu_get_settings,
-	.set_settings		= niu_set_settings,
 	.get_strings		= niu_get_strings,
 	.get_sset_count		= niu_get_sset_count,
 	.get_ethtool_stats	= niu_get_ethtool_stats,
 	.set_phys_id		= niu_set_phys_id,
 	.get_rxnfc		= niu_get_nfc,
 	.set_rxnfc		= niu_set_nfc,
+	.get_link_ksettings	= niu_get_link_ksettings,
+	.set_link_ksettings	= niu_set_link_ksettings,
 };
 
 static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
-- 
1.7.4.4
