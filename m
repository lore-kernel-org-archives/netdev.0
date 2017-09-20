From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/16] mlxsw: spectrum_switchdev: Break mid deletion into two function
Date: Wed, 20 Sep 2017 16:15:07 +0200
Message-ID: <20170920141516.1402-8-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37281 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751678AbdITOPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:24 -0400
Received: by mail-wr0-f194.google.com with SMTP id u48so1582680wrf.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:24 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Break mid deletion into two function, so it will be possible in the future
to delete a mid entry for other reasons then switchdev command (like port
deletion).

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 32 ++++++++++++++--------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 9dd05d8..7f622de 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1468,6 +1468,25 @@ static int mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
+static int
+__mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
+			struct mlxsw_sp_bridge_port *bridge_port,
+			struct mlxsw_sp_mid *mid)
+{
+	struct net_device *dev = mlxsw_sp_port->dev;
+	int err;
+
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
+	if (err)
+		netdev_err(dev, "Unable to remove port from SMID\n");
+
+	err = mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid);
+	if (err)
+		netdev_err(dev, "Unable to remove MC SFD\n");
+
+	return err;
+}
+
 static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				 const struct switchdev_obj_port_mdb *mdb)
 {
@@ -1479,8 +1498,6 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct mlxsw_sp_bridge_port *bridge_port;
 	struct mlxsw_sp_mid *mid;
 	u16 fid_index;
-	u16 mid_idx;
-	int err = 0;
 
 	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
 	if (!bridge_port)
@@ -1501,16 +1518,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		return -EINVAL;
 	}
 
-	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
-	if (err)
-		netdev_err(dev, "Unable to remove port from SMID\n");
-
-	mid_idx = mid->mid;
-	err = mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid);
-	if (err)
-		netdev_err(dev, "Unable to remove MC SFD\n");
-
-	return err;
+	return __mlxsw_sp_port_mdb_del(mlxsw_sp_port, bridge_port, mid);
 }
 
 static int mlxsw_sp_port_obj_del(struct net_device *dev,
-- 
2.9.5
