From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_switchdev: Fix mrouter flag update
Date: Tue, 22 Aug 2017 10:28:11 +0200
Message-ID: <20170822082811.1356-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36404 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932126AbdHVI2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 04:28:14 -0400
Received: by mail-wr0-f193.google.com with SMTP id f8so16206850wrf.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 01:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Update the value of the mrouter flag in struct mlxsw_sp_bridge_port when
it is being changed.

Fixes: c57529e1d5d8 ("mlxsw: spectrum: Replace vPorts with Port-VLAN")
Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 5eb1606..d39ffbf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -705,6 +705,7 @@ static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					    bool is_port_mc_router)
 {
 	struct mlxsw_sp_bridge_port *bridge_port;
+	int err;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
@@ -715,11 +716,17 @@ static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		return 0;
 
 	if (!bridge_port->bridge_device->multicast_enabled)
-		return 0;
+		goto out;
 
-	return mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port, bridge_port,
-						    MLXSW_SP_FLOOD_TYPE_MC,
-						    is_port_mc_router);
+	err = mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port, bridge_port,
+						   MLXSW_SP_FLOOD_TYPE_MC,
+						   is_port_mc_router);
+	if (err)
+		return err;
+
+out:
+	bridge_port->mrouter = is_port_mc_router;
+	return 0;
 }
 
 static int mlxsw_sp_port_mc_disabled_set(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
2.9.3
