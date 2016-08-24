From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum: Add missing flood to router port
Date: Wed, 24 Aug 2016 11:18:51 +0200
Message-ID: <1472030332-6208-2-git-send-email-jiri@resnulli.us>
References: <1472030332-6208-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35974 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754065AbcHXJb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 05:31:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so1743860wmf.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 02:31:22 -0700 (PDT)
In-Reply-To: <1472030332-6208-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case we have a layer 3 interface on top of a bridge (VLAN / FID RIF),
then we should flood the following packet types to the router:

* Broadcast: If DIP is the broadcast address of the interface, then we
need to be able to get it to CPU by trapping it following route lookup.

* Reserved IP multicast (224.0.0.X): Some control packets (e.g. OSPF)
use this range and are trapped in the router block.

Fixes: 99f44bb3527b ("mlxsw: spectrum: Enable L3 interfaces on top of bridge devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/port.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 43 +++++++++++++++++++++++++-
 2 files changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index f33b997..af371a8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -56,6 +56,7 @@
 #define MLXSW_PORT_PHY_BITS_MASK	(MLXSW_PORT_MAX_PHY_PORTS - 1)
 
 #define MLXSW_PORT_CPU_PORT		0x0
+#define MLXSW_PORT_ROUTER_PORT		(MLXSW_PORT_MAX_PHY_PORTS + 2)
 
 #define MLXSW_PORT_DONT_CARE		(MLXSW_PORT_MAX_PORTS)
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1f81689..7291f2c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3324,6 +3324,39 @@ static struct mlxsw_sp_fid *mlxsw_sp_bridge_fid_get(struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_sp_fid_find(mlxsw_sp, fid);
 }
 
+static enum mlxsw_flood_table_type mlxsw_sp_flood_table_type_get(u16 fid)
+{
+	return mlxsw_sp_fid_is_vfid(fid) ? MLXSW_REG_SFGC_TABLE_TYPE_FID :
+	       MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
+}
+
+static u16 mlxsw_sp_flood_table_index_get(u16 fid)
+{
+	return mlxsw_sp_fid_is_vfid(fid) ? mlxsw_sp_fid_to_vfid(fid) : fid;
+}
+
+static int mlxsw_sp_router_port_flood_set(struct mlxsw_sp *mlxsw_sp, u16 fid,
+					  bool set)
+{
+	enum mlxsw_flood_table_type table_type;
+	char *sftr_pl;
+	u16 index;
+	int err;
+
+	sftr_pl = kmalloc(MLXSW_REG_SFTR_LEN, GFP_KERNEL);
+	if (!sftr_pl)
+		return -ENOMEM;
+
+	table_type = mlxsw_sp_flood_table_type_get(fid);
+	index = mlxsw_sp_flood_table_index_get(fid);
+	mlxsw_reg_sftr_pack(sftr_pl, MLXSW_SP_FLOOD_TABLE_BM, index, table_type,
+			    1, MLXSW_PORT_ROUTER_PORT, set);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sftr), sftr_pl);
+
+	kfree(sftr_pl);
+	return err;
+}
+
 static enum mlxsw_reg_ritr_if_type mlxsw_sp_rif_type_get(u16 fid)
 {
 	if (mlxsw_sp_fid_is_vfid(fid))
@@ -3360,10 +3393,14 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (rif == MLXSW_SP_RIF_MAX)
 		return -ERANGE;
 
-	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
+	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
 	if (err)
 		return err;
 
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
+	if (err)
+		goto err_rif_bridge_op;
+
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, true);
 	if (err)
 		goto err_rif_fdb_op;
@@ -3385,6 +3422,8 @@ err_rif_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 err_rif_fdb_op:
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
+err_rif_bridge_op:
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 	return err;
 }
 
@@ -3404,6 +3443,8 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
 
+	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+
 	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif);
 }
 
-- 
2.5.5
