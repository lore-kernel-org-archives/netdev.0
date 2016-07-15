From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/5] mlxsw: spectrum: Force link training according to admin state
Date: Fri, 15 Jul 2016 11:14:58 +0200
Message-ID: <1468574102-26288-2-git-send-email-jiri@resnulli.us>
References: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33134 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbcGOJPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so1382719wme.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:06 -0700 (PDT)
In-Reply-To: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When setting a new speed we need to disable and enable the port for the
changes to take effect. We currently only do that if the operational
state of the port is up. However, setting a new speed following link
training failure will require us to explicitly set the port down and then
up.

Instead, disable and enable the port based on its administrative state.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 25 +------------------------
 1 file changed, 1 insertion(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 660429e..5ccdf22 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -171,23 +171,6 @@ static int mlxsw_sp_port_admin_status_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(paos), paos_pl);
 }
 
-static int mlxsw_sp_port_oper_status_get(struct mlxsw_sp_port *mlxsw_sp_port,
-					 bool *p_is_up)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char paos_pl[MLXSW_REG_PAOS_LEN];
-	u8 oper_status;
-	int err;
-
-	mlxsw_reg_paos_pack(paos_pl, mlxsw_sp_port->local_port, 0);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(paos), paos_pl);
-	if (err)
-		return err;
-	oper_status = mlxsw_reg_paos_oper_status_get(paos_pl);
-	*p_is_up = oper_status == MLXSW_PORT_ADMIN_STATUS_UP ? true : false;
-	return 0;
-}
-
 static int mlxsw_sp_port_dev_addr_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				      unsigned char *addr)
 {
@@ -1493,7 +1476,6 @@ static int mlxsw_sp_port_set_settings(struct net_device *dev,
 	u32 eth_proto_new;
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
-	bool is_up;
 	int err;
 
 	speed = ethtool_cmd_speed(cmd);
@@ -1525,12 +1507,7 @@ static int mlxsw_sp_port_set_settings(struct net_device *dev,
 		return err;
 	}
 
-	err = mlxsw_sp_port_oper_status_get(mlxsw_sp_port, &is_up);
-	if (err) {
-		netdev_err(dev, "Failed to get oper status");
-		return err;
-	}
-	if (!is_up)
+	if (!netif_running(dev))
 		return 0;
 
 	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
-- 
2.5.5
