From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/6] mlxsw: spectrum: Add support for port identification
Date: Fri, 27 Nov 2015 13:45:55 +0100
Message-ID: <1448628359-20077-3-git-send-email-jiri@resnulli.us>
References: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35735 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbK0MqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 07:46:05 -0500
Received: by wmuu63 with SMTP id u63so54384172wmu.0
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 04:46:04 -0800 (PST)
In-Reply-To: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow a user to flash the port's LED in order to identify it. This is
achieved by setting the Management LED Control Register (MLCR).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3be4a23..14a9a9f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -859,6 +859,29 @@ static void mlxsw_sp_port_get_strings(struct net_device *dev,
 	}
 }
 
+static int mlxsw_sp_port_set_phys_id(struct net_device *dev,
+				     enum ethtool_phys_id_state state)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char mlcr_pl[MLXSW_REG_MLCR_LEN];
+	bool active;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		active = true;
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		active = false;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	mlxsw_reg_mlcr_pack(mlcr_pl, mlxsw_sp_port->local_port, active);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mlcr), mlcr_pl);
+}
+
 static void mlxsw_sp_port_get_stats(struct net_device *dev,
 				    struct ethtool_stats *stats, u64 *data)
 {
@@ -1205,6 +1228,7 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.get_drvinfo		= mlxsw_sp_port_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_strings		= mlxsw_sp_port_get_strings,
+	.set_phys_id		= mlxsw_sp_port_set_phys_id,
 	.get_ethtool_stats	= mlxsw_sp_port_get_stats,
 	.get_sset_count		= mlxsw_sp_port_get_sset_count,
 	.get_settings		= mlxsw_sp_port_get_settings,
-- 
1.9.3
