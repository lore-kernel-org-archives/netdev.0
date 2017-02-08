From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/15] mlxsw: spectrum_router: Store nexthops in a hash table
Date: Wed,  8 Feb 2017 11:16:30 +0100
Message-ID: <1486549002-2056-4-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34670 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752759AbdBHKQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:48 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so32407142wmi.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:47 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Later in the patchset we'll add the NH_{ADD,DEL} events which will let
us know when a nexthop is considered to be dead. Based on these events
we need to be able to add or remove the nexthop from the device's
tables.

Therefore, store the private nexthop structs in a hash table and use the
kernel's fib_nh struct as the key, so that we'll be able to easily find
them when the events are received.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 58 ++++++++++++++++++++--
 2 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 8014d15..eb743fe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -255,6 +255,7 @@ struct mlxsw_sp_router {
 	struct mlxsw_sp_vr *vrs;
 	struct rhashtable neigh_ht;
 	struct rhashtable nexthop_group_ht;
+	struct rhashtable nexthop_ht;
 	struct {
 		struct delayed_work dw;
 		unsigned long interval;	/* ms */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index a511b95..3d540d9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1090,11 +1090,17 @@ static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
 
+struct mlxsw_sp_nexthop_key {
+	struct fib_nh *fib_nh;
+};
+
 struct mlxsw_sp_nexthop {
 	struct list_head neigh_list_node; /* member of neigh entry list */
 	struct mlxsw_sp_nexthop_group *nh_grp; /* pointer back to the group
 						* this belongs to
 						*/
+	struct rhash_head ht_node;
+	struct mlxsw_sp_nexthop_key key;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
 			      */
@@ -1152,6 +1158,26 @@ mlxsw_sp_nexthop_group_lookup(struct mlxsw_sp *mlxsw_sp,
 				      mlxsw_sp_nexthop_group_ht_params);
 }
 
+static const struct rhashtable_params mlxsw_sp_nexthop_ht_params = {
+	.key_offset = offsetof(struct mlxsw_sp_nexthop, key),
+	.head_offset = offsetof(struct mlxsw_sp_nexthop, ht_node),
+	.key_len = sizeof(struct mlxsw_sp_nexthop_key),
+};
+
+static int mlxsw_sp_nexthop_insert(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_nexthop *nh)
+{
+	return rhashtable_insert_fast(&mlxsw_sp->router.nexthop_ht,
+				      &nh->ht_node, mlxsw_sp_nexthop_ht_params);
+}
+
+static void mlxsw_sp_nexthop_remove(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_nexthop *nh)
+{
+	rhashtable_remove_fast(&mlxsw_sp->router.nexthop_ht, &nh->ht_node,
+			       mlxsw_sp_nexthop_ht_params);
+}
+
 static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
 					     struct mlxsw_sp_vr *vr,
 					     u32 adj_index, u16 ecmp_size,
@@ -1384,6 +1410,12 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	struct net_device *dev = fib_nh->nh_dev;
 	struct neighbour *n;
 	u8 nud_state, dead;
+	int err;
+
+	nh->key.fib_nh = fib_nh;
+	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
+	if (err)
+		return err;
 
 	/* Take a reference of neigh here ensuring that neigh would
 	 * not be detructed before the nexthop entry is finished.
@@ -1393,16 +1425,18 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, dev);
 	if (!n) {
 		n = neigh_create(&arp_tbl, &fib_nh->nh_gw, dev);
-		if (IS_ERR(n))
-			return PTR_ERR(n);
+		if (IS_ERR(n)) {
+			err = PTR_ERR(n);
+			goto err_neigh_create;
+		}
 		neigh_event_send(n, NULL);
 	}
 	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
 	if (!neigh_entry) {
 		neigh_entry = mlxsw_sp_neigh_entry_create(mlxsw_sp, n);
 		if (IS_ERR(neigh_entry)) {
-			neigh_release(n);
-			return -EINVAL;
+			err = -EINVAL;
+			goto err_neigh_entry_create;
 		}
 	}
 
@@ -1423,6 +1457,12 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	__mlxsw_sp_nexthop_neigh_update(nh, !(nud_state & NUD_VALID && !dead));
 
 	return 0;
+
+err_neigh_entry_create:
+	neigh_release(n);
+err_neigh_create:
+	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
+	return err;
 }
 
 static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
@@ -1445,6 +1485,8 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
 
 	neigh_release(n);
+
+	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
 static struct mlxsw_sp_nexthop_group *
@@ -2052,6 +2094,11 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
+	err = rhashtable_init(&mlxsw_sp->router.nexthop_ht,
+			      &mlxsw_sp_nexthop_ht_params);
+	if (err)
+		goto err_nexthop_ht_init;
+
 	err = rhashtable_init(&mlxsw_sp->router.nexthop_group_ht,
 			      &mlxsw_sp_nexthop_group_ht_params);
 	if (err)
@@ -2081,6 +2128,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_vrs_init:
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
 err_nexthop_group_ht_init:
+	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
+err_nexthop_ht_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
 	return err;
 }
@@ -2091,5 +2140,6 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
+	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
-- 
2.7.4
