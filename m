From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/12] mlxsw: spectrum_router: Move RIFs array to its rightful place
Date: Tue, 16 May 2017 19:38:27 +0200
Message-ID: <20170516173835.2978-5-jiri@resnulli.us>
References: <20170516173835.2978-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36501 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752752AbdEPRit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:38:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id u65so38963618wmu.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:38:44 -0700 (PDT)
In-Reply-To: <20170516173835.2978-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The router interfaces (RIFs) array is of no interest to code outside the
routing realm, so declare it inside the router specific struct instead
of the chip-wide one.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 -
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 17 +++++-----
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 39 +++++++++++++---------
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  2 ++
 4 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7c9e2f1..babaf1f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -160,7 +160,6 @@ struct mlxsw_sp {
 		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_MAX);
 	} vfids;
 	struct list_head fids;	/* VLAN-aware bridge FIDs */
-	struct mlxsw_sp_rif **rifs;
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index ea56f6a..ce2534d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -241,10 +241,11 @@ mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
 		return err;
 	j = 0;
 	for (; i < rif_count; i++) {
-		if (!mlxsw_sp->rifs[i])
+		struct mlxsw_sp_rif *rif = mlxsw_sp_rif_by_index(mlxsw_sp, i);
+
+		if (!rif)
 			continue;
-		err = mlxsw_sp_erif_entry_get(mlxsw_sp, &entry,
-					      mlxsw_sp->rifs[i],
+		err = mlxsw_sp_erif_entry_get(mlxsw_sp, &entry, rif,
 					      counters_enabled);
 		if (err)
 			goto err_entry_get;
@@ -281,15 +282,15 @@ static int mlxsw_sp_table_erif_counters_update(void *priv, bool enable)
 
 	rtnl_lock();
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
-		if (!mlxsw_sp->rifs[i])
+		struct mlxsw_sp_rif *rif = mlxsw_sp_rif_by_index(mlxsw_sp, i);
+
+		if (!rif)
 			continue;
 		if (enable)
-			mlxsw_sp_rif_counter_alloc(mlxsw_sp,
-						   mlxsw_sp->rifs[i],
+			mlxsw_sp_rif_counter_alloc(mlxsw_sp, rif,
 						   MLXSW_SP_RIF_COUNTER_EGRESS);
 		else
-			mlxsw_sp_rif_counter_free(mlxsw_sp,
-						  mlxsw_sp->rifs[i],
+			mlxsw_sp_rif_counter_free(mlxsw_sp, rif,
 						  MLXSW_SP_RIF_COUNTER_EGRESS);
 	}
 	rtnl_unlock();
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 434e091..7b44389 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -61,6 +61,7 @@ struct mlxsw_sp_lpm_tree;
 
 struct mlxsw_sp_router {
 	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_rif **rifs;
 	struct mlxsw_sp_vr *vrs;
 	struct rhashtable neigh_ht;
 	struct rhashtable nexthop_group_ht;
@@ -885,13 +886,13 @@ static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_reg_rauhtd_ent_ipv4_unpack(rauhtd_pl, ent_index, &rif, &dip);
 
-	if (!mlxsw_sp->rifs[rif]) {
+	if (!mlxsw_sp->router->rifs[rif]) {
 		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect RIF in neighbour entry\n");
 		return;
 	}
 
 	dipn = htonl(dip);
-	dev = mlxsw_sp->rifs[rif]->dev;
+	dev = mlxsw_sp->router->rifs[rif]->dev;
 	n = neigh_lookup(&arp_tbl, &dipn, dev);
 	if (!n) {
 		netdev_err(dev, "Failed to find matching neighbour for IP=%pI4h\n",
@@ -2846,8 +2847,9 @@ mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 	int i;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
-			return mlxsw_sp->rifs[i];
+		if (mlxsw_sp->router->rifs[i] &&
+		    mlxsw_sp->router->rifs[i]->dev == dev)
+			return mlxsw_sp->router->rifs[i];
 
 	return NULL;
 }
@@ -2903,7 +2905,7 @@ static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 	int i;
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		if (!mlxsw_sp->rifs[i])
+		if (!mlxsw_sp->router->rifs[i])
 			return i;
 
 	return MLXSW_SP_INVALID_INDEX_RIF;
@@ -2983,6 +2985,12 @@ mlxsw_sp_rif_alloc(u16 rif_index, u16 vr_id, struct net_device *l3_dev,
 	return rif;
 }
 
+struct mlxsw_sp_rif *mlxsw_sp_rif_by_index(const struct mlxsw_sp *mlxsw_sp,
+					   u16 rif_index)
+{
+	return mlxsw_sp->router->rifs[rif_index];
+}
+
 u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif)
 {
 	return rif->rif_index;
@@ -3045,7 +3053,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	}
 
 	f->rif = rif;
-	mlxsw_sp->rifs[rif_index] = rif;
+	mlxsw_sp->router->rifs[rif_index] = rif;
 	vr->rif_count++;
 
 	return rif;
@@ -3078,7 +3086,7 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_rif_counter_free(mlxsw_sp, rif, MLXSW_SP_RIF_COUNTER_INGRESS);
 
 	vr->rif_count--;
-	mlxsw_sp->rifs[rif_index] = NULL;
+	mlxsw_sp->router->rifs[rif_index] = NULL;
 	f->rif = NULL;
 
 	kfree(rif);
@@ -3302,7 +3310,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	f->rif = rif;
-	mlxsw_sp->rifs[rif_index] = rif;
+	mlxsw_sp->router->rifs[rif_index] = rif;
 	vr->rif_count++;
 
 	netdev_dbg(l3_dev, "RIF=%d created\n", rif_index);
@@ -3332,7 +3340,7 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, rif);
 
 	vr->rif_count--;
-	mlxsw_sp->rifs[rif_index] = NULL;
+	mlxsw_sp->router->rifs[rif_index] = NULL;
 	f->rif = NULL;
 
 	kfree(rif);
@@ -3562,9 +3570,10 @@ static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 		return -EIO;
 
 	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
-	mlxsw_sp->rifs = kcalloc(max_rifs, sizeof(struct mlxsw_sp_rif *),
-				 GFP_KERNEL);
-	if (!mlxsw_sp->rifs)
+	mlxsw_sp->router->rifs = kcalloc(max_rifs,
+					 sizeof(struct mlxsw_sp_rif *),
+					 GFP_KERNEL);
+	if (!mlxsw_sp->router->rifs)
 		return -ENOMEM;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, true);
@@ -3576,7 +3585,7 @@ static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 
 err_rgcr_fail:
-	kfree(mlxsw_sp->rifs);
+	kfree(mlxsw_sp->router->rifs);
 	return err;
 }
 
@@ -3589,9 +3598,9 @@ static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 
 	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
-		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
+		WARN_ON_ONCE(mlxsw_sp->router->rifs[i]);
 
-	kfree(mlxsw_sp->rifs);
+	kfree(mlxsw_sp->router->rifs);
 }
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index c3095fe..a3e8d2b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -42,6 +42,8 @@ enum mlxsw_sp_rif_counter_dir {
 	MLXSW_SP_RIF_COUNTER_EGRESS,
 };
 
+struct mlxsw_sp_rif *mlxsw_sp_rif_by_index(const struct mlxsw_sp *mlxsw_sp,
+					   u16 rif_index);
 u16 mlxsw_sp_rif_index(const struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_dev_ifindex(const struct mlxsw_sp_rif *rif);
 int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
-- 
2.9.3
