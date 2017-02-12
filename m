From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: neterion: s2io: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 11:44:36 +0100
Message-ID: <1486896276-5647-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jdmason@kudzu.us, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/neterion/s2io.c |   51 +++++++++++++++++++--------------
 1 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 203abcb..c5c1d0e 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5300,10 +5300,10 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 }
 
 /**
- * s2io_ethtool_sset - Sets different link parameters.
+ * s2io_ethtool_set_link_ksettings - Sets different link parameters.
  * @sp : private member of the device structure, which is a pointer to the
  * s2io_nic structure.
- * @info: pointer to the structure with parameters given by ethtool to set
+ * @cmd: pointer to the structure with parameters given by ethtool to set
  * link information.
  * Description:
  * The function sets different link parameters provided by the user onto
@@ -5312,13 +5312,14 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
  * 0 on success.
  */
 
-static int s2io_ethtool_sset(struct net_device *dev,
-			     struct ethtool_cmd *info)
+static int
+s2io_ethtool_set_link_ksettings(struct net_device *dev,
+				const struct ethtool_link_ksettings *cmd)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
-	if ((info->autoneg == AUTONEG_ENABLE) ||
-	    (ethtool_cmd_speed(info) != SPEED_10000) ||
-	    (info->duplex != DUPLEX_FULL))
+	if ((cmd->base.autoneg == AUTONEG_ENABLE) ||
+	    (cmd->base.speed != SPEED_10000) ||
+	    (cmd->base.duplex != DUPLEX_FULL))
 		return -EINVAL;
 	else {
 		s2io_close(sp->dev);
@@ -5329,10 +5330,10 @@ static int s2io_ethtool_sset(struct net_device *dev,
 }
 
 /**
- * s2io_ethtol_gset - Return link specific information.
+ * s2io_ethtol_get_link_ksettings - Return link specific information.
  * @sp : private member of the device structure, pointer to the
  *      s2io_nic structure.
- * @info : pointer to the structure with parameters given by ethtool
+ * @cmd : pointer to the structure with parameters given by ethtool
  * to return link information.
  * Description:
  * Returns link specific information like speed, duplex etc.. to ethtool.
@@ -5340,25 +5341,31 @@ static int s2io_ethtool_sset(struct net_device *dev,
  * return 0 on success.
  */
 
-static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
+static int
+s2io_ethtool_get_link_ksettings(struct net_device *dev,
+				struct ethtool_link_ksettings *cmd)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
-	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	info->port = PORT_FIBRE;
 
-	/* info->transceiver */
-	info->transceiver = XCVR_EXTERNAL;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
+
+	cmd->base.port = PORT_FIBRE;
 
 	if (netif_carrier_ok(sp->dev)) {
-		ethtool_cmd_speed_set(info, SPEED_10000);
-		info->duplex = DUPLEX_FULL;
+		cmd->base.speed = SPEED_10000;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(info, SPEED_UNKNOWN);
-		info->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	info->autoneg = AUTONEG_DISABLE;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -6626,8 +6633,6 @@ static int s2io_set_features(struct net_device *dev, netdev_features_t features)
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_settings = s2io_ethtool_gset,
-	.set_settings = s2io_ethtool_sset,
 	.get_drvinfo = s2io_ethtool_gdrvinfo,
 	.get_regs_len = s2io_ethtool_get_regs_len,
 	.get_regs = s2io_ethtool_gregs,
@@ -6643,6 +6648,8 @@ static int s2io_set_features(struct net_device *dev, netdev_features_t features)
 	.set_phys_id = s2io_ethtool_set_led,
 	.get_ethtool_stats = s2io_get_ethtool_stats,
 	.get_sset_count = s2io_get_sset_count,
+	.get_link_ksettings = s2io_ethtool_get_link_ksettings,
+	.set_link_ksettings = s2io_ethtool_set_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
