From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/12] mlxsw: spectrum_router: Add support for setting counters on neighbors
Date: Thu, 24 Aug 2017 08:40:08 +0200
Message-ID: <20170824064010.1646-11-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37263 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbdHXGka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id v186so1689701wmf.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:29 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for setting counters on neighbors based on dpipe's host table
counter status. This patch also adds the ability for getting the counter
value, which will be used by the dpipe host table implementation in the
next patches.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  8 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 ++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 56 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  3 ++
 4 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index bcf55f6..11e290c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -5054,6 +5054,14 @@ static inline void mlxsw_reg_rauht_pack6(char *payload,
 	mlxsw_reg_rauht_dip6_memcpy_to(payload, dip);
 }
 
+static inline void mlxsw_reg_rauht_pack_counter(char *payload,
+						u64 counter_index)
+{
+	mlxsw_reg_rauht_counter_index_set(payload, counter_index);
+	mlxsw_reg_rauht_counter_set_type_set(payload,
+					     MLXSW_REG_FLOW_COUNTER_SET_TYPE_PACKETS_BYTES);
+}
+
 /* RALEU - Router Algorithmic LPM ECMP Update Register
  * ---------------------------------------------------
  * The register enables updating the ECMP section in the action for multiple
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5332b8f..17fc988 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -386,8 +386,10 @@ int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mgpc), mgpc_pl);
 	if (err)
 		return err;
-	*packets = mlxsw_reg_mgpc_packet_counter_get(mgpc_pl);
-	*bytes = mlxsw_reg_mgpc_byte_counter_get(mgpc_pl);
+	if (packets)
+		*packets = mlxsw_reg_mgpc_packet_counter_get(mgpc_pl);
+	if (bytes)
+		*bytes = mlxsw_reg_mgpc_byte_counter_get(mgpc_pl);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 0b989e1..abccd84 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -901,6 +901,8 @@ struct mlxsw_sp_neigh_entry {
 					* this neigh entry
 					*/
 	struct list_head nexthop_neighs_list_node;
+	unsigned int counter_index;
+	bool counter_valid;
 };
 
 static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
@@ -945,6 +947,17 @@ u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry)
 	return ntohl(*((__be32 *) n->primary_key));
 }
 
+int mlxsw_sp_neigh_counter_get(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_neigh_entry *neigh_entry,
+			       u64 *p_counter)
+{
+	if (!neigh_entry->counter_valid)
+		return -EINVAL;
+
+	return mlxsw_sp_flow_counter_get(mlxsw_sp, neigh_entry->counter_index,
+					 p_counter, NULL);
+}
+
 static struct mlxsw_sp_neigh_entry *
 mlxsw_sp_neigh_entry_alloc(struct mlxsw_sp *mlxsw_sp, struct neighbour *n,
 			   u16 rif)
@@ -985,6 +998,41 @@ mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
 			       mlxsw_sp_neigh_ht_params);
 }
 
+static bool
+mlxsw_sp_neigh4_counter_should_alloc(struct mlxsw_sp *mlxsw_sp)
+{
+	struct devlink *devlink;
+
+	devlink = priv_to_devlink(mlxsw_sp->core);
+	return devlink_dpipe_table_counter_enabled(devlink,
+						   MLXSW_SP_DPIPE_TABLE_NAME_HOST4);
+}
+
+static void
+mlxsw_sp_neigh_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			     struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	if (mlxsw_sp_neigh_entry_type(neigh_entry) != AF_INET ||
+	    !mlxsw_sp_neigh4_counter_should_alloc(mlxsw_sp))
+		return;
+
+	if (mlxsw_sp_flow_counter_alloc(mlxsw_sp, &neigh_entry->counter_index))
+		return;
+
+	neigh_entry->counter_valid = true;
+}
+
+static void
+mlxsw_sp_neigh_counter_free(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	if (!neigh_entry->counter_valid)
+		return;
+	mlxsw_sp_flow_counter_free(mlxsw_sp,
+				   neigh_entry->counter_index);
+	neigh_entry->counter_valid = false;
+}
+
 static struct mlxsw_sp_neigh_entry *
 mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 {
@@ -1004,6 +1052,7 @@ mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 	if (err)
 		goto err_neigh_entry_insert;
 
+	mlxsw_sp_neigh_counter_alloc(mlxsw_sp, neigh_entry);
 	list_add(&neigh_entry->rif_list_node, &rif->neigh_list);
 
 	return neigh_entry;
@@ -1018,6 +1067,7 @@ mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 			     struct mlxsw_sp_neigh_entry *neigh_entry)
 {
 	list_del(&neigh_entry->rif_list_node);
+	mlxsw_sp_neigh_counter_free(mlxsw_sp, neigh_entry);
 	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
 	mlxsw_sp_neigh_entry_free(neigh_entry);
 }
@@ -1323,6 +1373,9 @@ mlxsw_sp_router_neigh_entry_op4(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_reg_rauht_pack4(rauht_pl, op, neigh_entry->rif, neigh_entry->ha,
 			      dip);
+	if (neigh_entry->counter_valid)
+		mlxsw_reg_rauht_pack_counter(rauht_pl,
+					     neigh_entry->counter_index);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
 }
 
@@ -1337,6 +1390,9 @@ mlxsw_sp_router_neigh_entry_op6(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_reg_rauht_pack6(rauht_pl, op, neigh_entry->rif, neigh_entry->ha,
 			      dip);
+	if (neigh_entry->counter_valid)
+		mlxsw_reg_rauht_pack_counter(rauht_pl,
+					     neigh_entry->counter_index);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 80ac032..aafae46 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -69,5 +69,8 @@ u32 mlxsw_sp_neigh4_entry_dip(struct mlxsw_sp_neigh_entry *neigh_entry);
 #define mlxsw_sp_rif_neigh_for_each(neigh_entry, rif)				\
 	for (neigh_entry = mlxsw_sp_rif_neigh_next(rif, NULL); neigh_entry;	\
 	     neigh_entry = mlxsw_sp_rif_neigh_next(rif, neigh_entry))
+int mlxsw_sp_neigh_counter_get(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_neigh_entry *neigh_entry,
+			       u64 *p_counter);
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.3
