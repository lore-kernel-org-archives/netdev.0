From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/10] mlxsw: spectrum: Update mc_disabled flag by switchdev attr
Date: Thu,  9 Feb 2017 14:54:49 +0100
Message-ID: <1486648489-16455-11-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36106 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdBIOFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:05:13 -0500
Received: by mail-wr0-f194.google.com with SMTP id k90so12004740wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:04:23 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a function to update mc_disabled from switchdev attr
SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 28 ++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 9540f20..598727d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -274,6 +274,30 @@ static int mlxsw_sp_port_flood_table_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return err;
 }
 
+static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
+					 struct switchdev_trans *trans,
+					 bool mc_disabled)
+{
+	int set;
+	int err = 0;
+
+	if (switchdev_trans_ph_prepare(trans))
+		return 0;
+
+	if (mlxsw_sp_port->mc_router != mlxsw_sp_port->mc_flood) {
+		set = mc_disabled ?
+			mlxsw_sp_port->mc_flood : mlxsw_sp_port->mc_router;
+		err = mlxsw_sp_port_flood_table_set(mlxsw_sp_port,
+						    MLXSW_SP_FLOOD_TABLE_MC,
+						    set);
+	}
+
+	if (!err)
+		mlxsw_sp_port->mc_disabled = mc_disabled;
+
+	return err;
+}
+
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set)
 {
@@ -461,6 +485,10 @@ static int mlxsw_sp_port_attr_set(struct net_device *dev,
 		err = mlxsw_sp_port_attr_mc_router_set(mlxsw_sp_port, trans,
 						       attr->u.mrouter);
 		break;
+	case SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED:
+		err = mlxsw_sp_port_mc_disabled_set(mlxsw_sp_port, trans,
+						    attr->u.mc_disabled);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.7.4
