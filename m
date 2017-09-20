From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/16] mlxsw: spectrum_switchdev: Flood mc when mc is disabled by user flag
Date: Wed, 20 Sep 2017 16:15:11 +0200
Message-ID: <20170920141516.1402-12-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36114 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdITOP2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:28 -0400
Received: by mail-wm0-f68.google.com with SMTP id r136so2577740wmf.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:28 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

When multicast is disabled, flood mc packets only to port that are marked
BR_MCAST_FLOOD (instead to all).

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c    | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 19ac206..50c4d7c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -262,7 +262,8 @@ mlxsw_sp_bridge_port_create(struct mlxsw_sp_bridge_device *bridge_device,
 	bridge_port->dev = brport_dev;
 	bridge_port->bridge_device = bridge_device;
 	bridge_port->stp_state = BR_STATE_DISABLED;
-	bridge_port->flags = BR_LEARNING | BR_FLOOD | BR_LEARNING_SYNC;
+	bridge_port->flags = BR_LEARNING | BR_FLOOD | BR_LEARNING_SYNC |
+			     BR_MCAST_FLOOD;
 	INIT_LIST_HEAD(&bridge_port->vlans_list);
 	list_add(&bridge_port->list, &bridge_device->ports_list);
 	bridge_port->ref_count = 1;
@@ -468,7 +469,8 @@ static int mlxsw_sp_port_attr_get(struct net_device *dev,
 					       &attr->u.brport_flags);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
-		attr->u.brport_flags_support = BR_LEARNING | BR_FLOOD;
+		attr->u.brport_flags_support = BR_LEARNING | BR_FLOOD |
+					       BR_MCAST_FLOOD;
 		break;
 	default:
 		return -EOPNOTSUPP;
@@ -653,8 +655,18 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (err)
 		return err;
 
-	memcpy(&bridge_port->flags, &brport_flags, sizeof(brport_flags));
+	if (bridge_port->bridge_device->multicast_enabled)
+		goto out;
 
+	err = mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port, bridge_port,
+						   MLXSW_SP_FLOOD_TYPE_MC,
+						   brport_flags &
+						   BR_MCAST_FLOOD);
+	if (err)
+		return err;
+
+out:
+	memcpy(&bridge_port->flags, &brport_flags, sizeof(brport_flags));
 	return 0;
 }
 
@@ -747,7 +759,8 @@ static bool mlxsw_sp_mc_flood(const struct mlxsw_sp_bridge_port *bridge_port)
 	const struct mlxsw_sp_bridge_device *bridge_device;
 
 	bridge_device = bridge_port->bridge_device;
-	return !bridge_device->multicast_enabled ? true : bridge_port->mrouter;
+	return bridge_device->multicast_enabled ? bridge_port->mrouter :
+					bridge_port->flags & BR_MCAST_FLOOD;
 }
 
 static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
2.9.5
