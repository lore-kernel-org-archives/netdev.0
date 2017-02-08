From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/15] mlxsw: spectrum_router: Flush resources when RIF is deleted
Date: Wed,  8 Feb 2017 11:16:42 +0100
Message-ID: <1486549002-2056-16-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35427 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754178AbdBHKt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:49:29 -0500
Received: by mail-wm0-f66.google.com with SMTP id u63so32545911wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:49:29 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the last IP address is removed from a netdev, its RIF is deleted.
However, if user didn't first remove neighbours and nexthops using this
interface, then they would still be present in the device's tables.

Therefore, whenever a RIF is deleted, make sure all the neighbours and
nexthops (adjacency entries) using it are removed from the relevant
tables as well.

The action associated with any route using this RIF would be refreshed,
most likely to trap. If the kernel decides to remove the route (f.e.,
because all the nexthops are now DEAD), then an event would be sent,
causing the route to be removed from the device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  6 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 86 +++++++++++++++++++++-
 3 files changed, 93 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c2a6751..8de5ed5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3473,6 +3473,8 @@ mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
 	if (!r)
 		return NULL;
 
+	INIT_LIST_HEAD(&r->nexthop_list);
+	INIT_LIST_HEAD(&r->neigh_list);
 	ether_addr_copy(r->addr, l3_dev->dev_addr);
 	r->mtu = l3_dev->mtu;
 	r->ref_count = 1;
@@ -3541,6 +3543,8 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 	u16 fid = f->fid;
 	u16 rif = r->rif;
 
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+
 	mlxsw_sp->rifs[rif] = NULL;
 	f->r = NULL;
 
@@ -3770,6 +3774,8 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_fid *f = r->f;
 	u16 rif = r->rif;
 
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+
 	mlxsw_sp->rifs[rif] = NULL;
 	f->r = NULL;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index eb743fe..145897c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -108,6 +108,8 @@ struct mlxsw_sp_fid {
 };
 
 struct mlxsw_sp_rif {
+	struct list_head nexthop_list;
+	struct list_head neigh_list;
 	struct net_device *dev;
 	unsigned int ref_count;
 	struct mlxsw_sp_fid *f;
@@ -602,6 +604,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 				   unsigned long event, void *ptr);
+void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_rif *r);
 
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8dfc025..ac8944e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -610,6 +610,7 @@ struct mlxsw_sp_neigh_key {
 };
 
 struct mlxsw_sp_neigh_entry {
+	struct list_head rif_list_node;
 	struct rhash_head ht_node;
 	struct mlxsw_sp_neigh_key key;
 	u16 rif;
@@ -686,6 +687,8 @@ mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 	if (err)
 		goto err_neigh_entry_insert;
 
+	list_add(&neigh_entry->rif_list_node, &r->neigh_list);
+
 	return neigh_entry;
 
 err_neigh_entry_insert:
@@ -697,6 +700,7 @@ static void
 mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 			     struct mlxsw_sp_neigh_entry *neigh_entry)
 {
+	list_del(&neigh_entry->rif_list_node);
 	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
 	mlxsw_sp_neigh_entry_free(neigh_entry);
 }
@@ -1090,12 +1094,34 @@ static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
 
+static int mlxsw_sp_neigh_rif_flush(struct mlxsw_sp *mlxsw_sp,
+				    const struct mlxsw_sp_rif *r)
+{
+	char rauht_pl[MLXSW_REG_RAUHT_LEN];
+
+	mlxsw_reg_rauht_pack(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE_ALL,
+			     r->rif, r->addr);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
+}
+
+static void mlxsw_sp_neigh_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_rif *r)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry, *tmp;
+
+	mlxsw_sp_neigh_rif_flush(mlxsw_sp, r);
+	list_for_each_entry_safe(neigh_entry, tmp, &r->neigh_list,
+				 rif_list_node)
+		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
+}
+
 struct mlxsw_sp_nexthop_key {
 	struct fib_nh *fib_nh;
 };
 
 struct mlxsw_sp_nexthop {
 	struct list_head neigh_list_node; /* member of neigh entry list */
+	struct list_head rif_list_node;
 	struct mlxsw_sp_nexthop_group *nh_grp; /* pointer back to the group
 						* this belongs to
 						*/
@@ -1417,6 +1443,25 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
+static void mlxsw_sp_nexthop_rif_init(struct mlxsw_sp_nexthop *nh,
+				      struct mlxsw_sp_rif *r)
+{
+	if (nh->r)
+		return;
+
+	nh->r = r;
+	list_add(&nh->rif_list_node, &r->nexthop_list);
+}
+
+static void mlxsw_sp_nexthop_rif_fini(struct mlxsw_sp_nexthop *nh)
+{
+	if (!nh->r)
+		return;
+
+	list_del(&nh->rif_list_node);
+	nh->r = NULL;
+}
+
 static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 				       struct mlxsw_sp_nexthop *nh)
 {
@@ -1522,7 +1567,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
 	if (!r)
 		return 0;
-	nh->r = r;
+	mlxsw_sp_nexthop_rif_init(nh, r);
 
 	err = mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
 	if (err)
@@ -1539,6 +1584,7 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 				  struct mlxsw_sp_nexthop *nh)
 {
 	mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
+	mlxsw_sp_nexthop_rif_fini(nh);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
@@ -1563,18 +1609,30 @@ static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
 
 	switch (event) {
 	case FIB_EVENT_NH_ADD:
-		nh->r = r;
+		mlxsw_sp_nexthop_rif_init(nh, r);
 		mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
 		break;
 	case FIB_EVENT_NH_DEL:
 		mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
-		nh->r = NULL;
+		mlxsw_sp_nexthop_rif_fini(nh);
 		break;
 	}
 
 	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
 }
 
+static void mlxsw_sp_nexthop_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
+					   struct mlxsw_sp_rif *r)
+{
+	struct mlxsw_sp_nexthop *nh, *tmp;
+
+	list_for_each_entry_safe(nh, tmp, &r->nexthop_list, rif_list_node) {
+		mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
+		mlxsw_sp_nexthop_rif_fini(nh);
+		mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
+	}
+}
+
 static struct mlxsw_sp_nexthop_group *
 mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 {
@@ -2089,6 +2147,28 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
 }
 
+static int mlxsw_sp_router_rif_disable(struct mlxsw_sp *mlxsw_sp, u16 rif)
+{
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	int err;
+
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+	if (WARN_ON_ONCE(err))
+		return err;
+
+	mlxsw_reg_ritr_enable_set(ritr_pl, false);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_rif *r)
+{
+	mlxsw_sp_router_rif_disable(mlxsw_sp, r->rif);
+	mlxsw_sp_nexthop_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, r);
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-- 
2.7.4
