From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Don't batch neighbour deletion
Date: Fri, 21 Jul 2017 20:31:38 +0200
Message-ID: <20170721183138.23505-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35860 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdGUSbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 14:31:41 -0400
Received: by mail-wr0-f196.google.com with SMTP id y67so12031437wrb.3
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 11:31:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Current firmware supported by the driver doesn't support batch deletion
of IPv6 neighbours on a given router interface (RIF).

Until a new version that supports this functionality is made available,
delete neighbours one by one.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e6d629f..548552c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1419,25 +1419,16 @@ static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 	rhashtable_destroy(&mlxsw_sp->router->neigh_ht);
 }
 
-static int mlxsw_sp_neigh_rif_flush(struct mlxsw_sp *mlxsw_sp,
-				    const struct mlxsw_sp_rif *rif)
-{
-	char rauht_pl[MLXSW_REG_RAUHT_LEN];
-
-	mlxsw_reg_rauht_pack(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE_ALL,
-			     rif->rif_index, rif->addr);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
-}
-
 static void mlxsw_sp_neigh_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_rif *rif)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry, *tmp;
 
-	mlxsw_sp_neigh_rif_flush(mlxsw_sp, rif);
 	list_for_each_entry_safe(neigh_entry, tmp, &rif->neigh_list,
-				 rif_list_node)
+				 rif_list_node) {
+		mlxsw_sp_neigh_entry_update(mlxsw_sp, neigh_entry, false);
 		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
+	}
 }
 
 struct mlxsw_sp_nexthop_key {
-- 
2.9.3
