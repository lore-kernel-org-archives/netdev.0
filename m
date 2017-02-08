From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/15] mlxsw: spectrum_router: Refactor nexthop init routine
Date: Wed,  8 Feb 2017 11:16:35 +0100
Message-ID: <1486549002-2056-9-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33284 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753308AbdBHKQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:54 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so32309544wmv.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:53 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The nexthop init and de-init functions both have symmetric parts
concerned with the reflection of the neighbour entry into the device's
adjacency table, in case it's used by a gatewayed route.

These sections of code also need to be called when a nexthop is marked
as valid / invalid following NH_{ADD,DEL} events. Break these out into
appropriate functions, so that they could be invoked following the
reception of above events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 80 +++++++++++++---------
 1 file changed, 49 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 74839f7..f535135 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1407,30 +1407,16 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 	}
 }
 
-static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_nexthop_group *nh_grp,
-				 struct mlxsw_sp_nexthop *nh,
-				 struct fib_nh *fib_nh)
+static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	struct net_device *dev = fib_nh->nh_dev;
-	struct mlxsw_sp_rif *r;
+	struct fib_nh *fib_nh = nh->key.fib_nh;
 	struct neighbour *n;
 	u8 nud_state, dead;
 	int err;
 
-	nh->nh_grp = nh_grp;
-	nh->key.fib_nh = fib_nh;
-	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
-	if (err)
-		return err;
-
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!r)
-		return 0;
-	nh->r = r;
-
-	if (!nh_grp->gateway)
+	if (!nh->nh_grp->gateway)
 		return 0;
 
 	/* Take a reference of neigh here ensuring that neigh would
@@ -1438,13 +1424,11 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	 * The reference is taken either in neigh_lookup() or
 	 * in neigh_create() in case n is not found.
 	 */
-	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, dev);
+	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, fib_nh->nh_dev);
 	if (!n) {
-		n = neigh_create(&arp_tbl, &fib_nh->nh_gw, dev);
-		if (IS_ERR(n)) {
-			err = PTR_ERR(n);
-			goto err_neigh_create;
-		}
+		n = neigh_create(&arp_tbl, &fib_nh->nh_gw, fib_nh->nh_dev);
+		if (IS_ERR(n))
+			return PTR_ERR(n);
 		neigh_event_send(n, NULL);
 	}
 	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
@@ -1475,19 +1459,18 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 
 err_neigh_entry_create:
 	neigh_release(n);
-err_neigh_create:
-	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 	return err;
 }
 
-static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_nexthop *nh)
+static void mlxsw_sp_nexthop_neigh_fini(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
-	struct neighbour *n = neigh_entry->key.n;
+	struct neighbour *n;
 
 	if (!neigh_entry)
-		goto out;
+		return;
+	n = neigh_entry->key.n;
 
 	__mlxsw_sp_nexthop_neigh_update(nh, true);
 	list_del(&nh->neigh_list_node);
@@ -1503,8 +1486,43 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
 
 	neigh_release(n);
+}
 
-out:
+static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_nexthop_group *nh_grp,
+				 struct mlxsw_sp_nexthop *nh,
+				 struct fib_nh *fib_nh)
+{
+	struct net_device *dev = fib_nh->nh_dev;
+	struct mlxsw_sp_rif *r;
+	int err;
+
+	nh->nh_grp = nh_grp;
+	nh->key.fib_nh = fib_nh;
+	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
+	if (err)
+		return err;
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!r)
+		return 0;
+	nh->r = r;
+
+	err = mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
+	if (err)
+		goto err_nexthop_neigh_init;
+
+	return 0;
+
+err_nexthop_neigh_init:
+	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
+	return err;
+}
+
+static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_nexthop *nh)
+{
+	mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
-- 
2.7.4
