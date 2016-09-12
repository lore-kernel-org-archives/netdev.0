From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: spectrum: Correctly report autonegotiation
Date: Mon, 12 Sep 2016 13:26:23 +0200
Message-ID: <1473679587-9112-2-git-send-email-jiri@resnulli.us>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34476 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757525AbcILL0b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id g141so2138214wmd.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:31 -0700 (PDT)
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now the device always reported autonegotiation to be off
although it was on by default.

Allow the user to disable / enable autonegotiation and report its status
correctly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 14 ++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  3 ++-
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6c6b726..9de2383 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1814,7 +1814,12 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 			 mlxsw_sp_from_ptys_supported_link(eth_proto_cap) |
 			 SUPPORTED_Pause | SUPPORTED_Asym_Pause |
 			 SUPPORTED_Autoneg;
-	cmd->advertising = mlxsw_sp_from_ptys_advert_link(eth_proto_admin);
+	if (mlxsw_sp_port->link.autoneg) {
+		cmd->advertising =
+			mlxsw_sp_from_ptys_advert_link(eth_proto_admin);
+		cmd->advertising |= ADVERTISED_Autoneg;
+		cmd->autoneg = AUTONEG_ENABLE;
+	}
 	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev),
 					eth_proto_oper, cmd);
 
@@ -1872,11 +1877,13 @@ static int mlxsw_sp_port_set_settings(struct net_device *dev,
 	u32 eth_proto_new;
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
+	bool autoneg;
 	int err;
 
+	autoneg = cmd->autoneg == AUTONEG_ENABLE;
 	speed = ethtool_cmd_speed(cmd);
 
-	eth_proto_new = cmd->autoneg == AUTONEG_ENABLE ?
+	eth_proto_new = autoneg ?
 		mlxsw_sp_to_ptys_advert_link(cmd->advertising) :
 		mlxsw_sp_to_ptys_speed(speed);
 
@@ -1906,6 +1913,8 @@ static int mlxsw_sp_port_set_settings(struct net_device *dev,
 	if (!netif_running(dev))
 		return 0;
 
+	mlxsw_sp_port->link.autoneg = autoneg;
+
 	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
 	if (err) {
 		netdev_err(dev, "Failed to set admin status");
@@ -2081,6 +2090,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	mlxsw_sp_port->mapping.module = module;
 	mlxsw_sp_port->mapping.width = width;
 	mlxsw_sp_port->mapping.lane = lane;
+	mlxsw_sp_port->link.autoneg = 1;
 	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
 	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
 	if (!mlxsw_sp_port->active_vlans) {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 01537d3..ae04613 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -341,7 +341,8 @@ struct mlxsw_sp_port {
 	} vport;
 	struct {
 		u8 tx_pause:1,
-		   rx_pause:1;
+		   rx_pause:1,
+		   autoneg:1;
 	} link;
 	struct {
 		struct ieee_ets *ets;
-- 
2.5.5
