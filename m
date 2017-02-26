From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: rocker: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 26 Feb 2017 19:00:29 +0100
Message-ID: <1488132029-2251-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jiri@resnulli.us, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/rocker/rocker_main.c |   55 +++++++++++++++++------------
 1 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 0f63a44..b712ec2 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1115,7 +1115,7 @@ int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
 					  const struct rocker_desc_info *desc_info,
 					  void *priv)
 {
-	struct ethtool_cmd *ecmd = priv;
+	struct ethtool_link_ksettings *ecmd = priv;
 	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
 	const struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
 	u32 speed;
@@ -1137,13 +1137,14 @@ int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
 	duplex = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX]);
 	autoneg = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG]);
 
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->supported = SUPPORTED_TP;
-	ecmd->phy_address = 0xff;
-	ecmd->port = PORT_TP;
-	ethtool_cmd_speed_set(ecmd, speed);
-	ecmd->duplex = duplex ? DUPLEX_FULL : DUPLEX_HALF;
-	ecmd->autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	ethtool_link_ksettings_zero_link_mode(ecmd, supported);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, TP);
+
+	ecmd->base.phy_address = 0xff;
+	ecmd->base.port = PORT_TP;
+	ecmd->base.speed = speed;
+	ecmd->base.duplex = duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	ecmd->base.autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	return 0;
 }
@@ -1250,7 +1251,7 @@ struct port_name {
 					  struct rocker_desc_info *desc_info,
 					  void *priv)
 {
-	struct ethtool_cmd *ecmd = priv;
+	struct ethtool_link_ksettings *ecmd = priv;
 	struct rocker_tlv *cmd_info;
 
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
@@ -1263,13 +1264,13 @@ struct port_name {
 			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_SPEED,
-			       ethtool_cmd_speed(ecmd)))
+			       ecmd->base.speed))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX,
-			      ecmd->duplex))
+			      ecmd->base.duplex))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG,
-			      ecmd->autoneg))
+			      ecmd->base.autoneg))
 		return -EMSGSIZE;
 	rocker_tlv_nest_end(desc_info, cmd_info);
 	return 0;
@@ -1347,8 +1348,9 @@ struct port_name {
 	return 0;
 }
 
-static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
-						struct ethtool_cmd *ecmd)
+static int
+rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
+				     struct ethtool_link_ksettings *ecmd)
 {
 	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_get_port_settings_prep, NULL,
@@ -1373,12 +1375,17 @@ static int rocker_cmd_get_port_settings_mode(struct rocker_port *rocker_port,
 			       rocker_cmd_get_port_settings_mode_proc, p_mode);
 }
 
-static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
-						struct ethtool_cmd *ecmd)
+static int
+rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
+				     const struct ethtool_link_ksettings *ecmd)
 {
+	struct ethtool_link_ksettings copy_ecmd;
+
+	memcpy(&copy_ecmd, ecmd, sizeof(copy_ecmd));
+
 	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_settings_ethtool_prep,
-			       ecmd, NULL, NULL);
+			       &copy_ecmd, NULL, NULL);
 }
 
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
@@ -2237,16 +2244,18 @@ static int rocker_router_fib_event(struct notifier_block *nb,
  * ethtool interface
  ********************/
 
-static int rocker_port_get_settings(struct net_device *dev,
-				    struct ethtool_cmd *ecmd)
+static int
+rocker_port_get_link_ksettings(struct net_device *dev,
+			       struct ethtool_link_ksettings *ecmd)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
 	return rocker_cmd_get_port_settings_ethtool(rocker_port, ecmd);
 }
 
-static int rocker_port_set_settings(struct net_device *dev,
-				    struct ethtool_cmd *ecmd)
+static int
+rocker_port_set_link_ksettings(struct net_device *dev,
+			       const struct ethtool_link_ksettings *ecmd)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
@@ -2388,13 +2397,13 @@ static int rocker_port_get_sset_count(struct net_device *netdev, int sset)
 }
 
 static const struct ethtool_ops rocker_port_ethtool_ops = {
-	.get_settings		= rocker_port_get_settings,
-	.set_settings		= rocker_port_set_settings,
 	.get_drvinfo		= rocker_port_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_strings		= rocker_port_get_strings,
 	.get_ethtool_stats	= rocker_port_get_stats,
 	.get_sset_count		= rocker_port_get_sset_count,
+	.get_link_ksettings	= rocker_port_get_link_ksettings,
+	.set_link_ksettings	= rocker_port_set_link_ksettings,
 };
 
 /*****************
-- 
1.7.4.4
