From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/8] mlxsw: Disable vlan_filtering for non .1D bridge
Date: Wed,  6 Jan 2016 13:01:10 +0100
Message-ID: <1452081671-8476-8-git-send-email-jiri@resnulli.us>
References: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33403 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102AbcAFMBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 07:01:22 -0500
Received: by mail-wm0-f43.google.com with SMTP id f206so57174076wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 04:01:22 -0800 (PST)
In-Reply-To: <1452081671-8476-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

When a port is bridged, the bridge must be vlan aware bridge (.1Q)
or the bridging should be on top of VLAN interfaces (.1D bridge).

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c    | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index ad1bf7f..d6242cf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -299,6 +299,22 @@ static int mlxsw_sp_port_attr_br_ageing_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_ageing_set(mlxsw_sp, ageing_time);
 }
 
+static int mlxsw_sp_port_attr_br_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					  struct switchdev_trans *trans,
+					  struct net_device *orig_dev,
+					  bool vlan_enabled)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	/* SWITCHDEV_TRANS_PREPARE phase */
+	if ((!vlan_enabled) && (mlxsw_sp->master_bridge.dev == orig_dev)) {
+		netdev_err(mlxsw_sp_port->dev, "Bridge must be vlan-aware\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int mlxsw_sp_port_attr_set(struct net_device *dev,
 				  const struct switchdev_attr *attr,
 				  struct switchdev_trans *trans)
@@ -323,6 +339,11 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 		err = mlxsw_sp_port_attr_br_ageing_set(mlxsw_sp_port, trans,
 						       attr->u.ageing_time);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
+		err = mlxsw_sp_port_attr_br_vlan_set(mlxsw_sp_port, trans,
+						     attr->orig_dev,
+						     attr->u.vlan_filtering);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.9.3
