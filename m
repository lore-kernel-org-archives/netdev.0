From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: Cosmetic naming change
Date: Fri, 17 Mar 2017 09:38:00 +0100
Message-ID: <1489739881-2826-2-git-send-email-jiri@resnulli.us>
References: <1489739881-2826-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36657 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751066AbdCQIrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 04:47:13 -0400
Received: by mail-wm0-f66.google.com with SMTP id x124so2065954wmf.3
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 01:47:12 -0700 (PDT)
In-Reply-To: <1489739881-2826-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Currently the struct representing router interface "mlxsw_sp_rif"
is reffered as "r" in various places in the driver. Furthermore it
contains a member which specify the index which is called "rif".
This patch change "r" to "rif" and "rif" to "rif_index".

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   8 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 282 +++++++++++----------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   4 +-
 4 files changed, 152 insertions(+), 146 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 28019f8..cbc1646 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -4088,8 +4088,8 @@ static void mlxsw_sp_master_bridge_vlan_unlink(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_fid *f;
 
 	f = mlxsw_sp_fid_find(mlxsw_sp, fid);
-	if (f && f->r)
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+	if (f && f->rif)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 	if (f && --f->ref_count == 0)
 		mlxsw_sp_fid_destroy(mlxsw_sp, f);
 }
@@ -4206,8 +4206,8 @@ static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 	clear_bit(vfid, mlxsw_sp->vfids.mapped);
 	list_del(&f->list);
 
-	if (f->r)
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+	if (f->rif)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 
 	kfree(f);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0e223f6..bffd9e6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -103,7 +103,7 @@ struct mlxsw_sp_fid {
 	struct list_head list;
 	unsigned int ref_count;
 	struct net_device *dev;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	u16 fid;
 };
 
@@ -577,7 +577,7 @@ int mlxsw_sp_netdevice_router_port_event(struct net_device *dev);
 int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 			    unsigned long event, void *ptr);
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_rif *r);
+				 struct mlxsw_sp_rif *rif);
 int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport);
 void mlxsw_sp_vport_vrf_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
 int mlxsw_sp_port_vrf_join(struct mlxsw_sp_port *mlxsw_sp_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 488bc1f..fe4a55e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -60,7 +60,7 @@ struct mlxsw_sp_rif {
 	struct mlxsw_sp_fid *f;
 	unsigned char addr[ETH_ALEN];
 	int mtu;
-	u16 rif;
+	u16 rif_index;
 	u16 vr_id;
 };
 
@@ -600,14 +600,14 @@ static struct mlxsw_sp_neigh_entry *
 mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	int err;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, n->dev);
-	if (!r)
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, n->dev);
+	if (!rif)
 		return ERR_PTR(-EINVAL);
 
-	neigh_entry = mlxsw_sp_neigh_entry_alloc(mlxsw_sp, n, r->rif);
+	neigh_entry = mlxsw_sp_neigh_entry_alloc(mlxsw_sp, n, rif->rif_index);
 	if (!neigh_entry)
 		return ERR_PTR(-ENOMEM);
 
@@ -615,7 +615,7 @@ mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 	if (err)
 		goto err_neigh_entry_insert;
 
-	list_add(&neigh_entry->rif_list_node, &r->neigh_list);
+	list_add(&neigh_entry->rif_list_node, &rif->neigh_list);
 
 	return neigh_entry;
 
@@ -1023,22 +1023,22 @@ static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 }
 
 static int mlxsw_sp_neigh_rif_flush(struct mlxsw_sp *mlxsw_sp,
-				    const struct mlxsw_sp_rif *r)
+				    const struct mlxsw_sp_rif *rif)
 {
 	char rauht_pl[MLXSW_REG_RAUHT_LEN];
 
 	mlxsw_reg_rauht_pack(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE_ALL,
-			     r->rif, r->addr);
+			     rif->rif_index, rif->addr);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
 }
 
 static void mlxsw_sp_neigh_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
-					 struct mlxsw_sp_rif *r)
+					 struct mlxsw_sp_rif *rif)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry, *tmp;
 
-	mlxsw_sp_neigh_rif_flush(mlxsw_sp, r);
-	list_for_each_entry_safe(neigh_entry, tmp, &r->neigh_list,
+	mlxsw_sp_neigh_rif_flush(mlxsw_sp, rif);
+	list_for_each_entry_safe(neigh_entry, tmp, &rif->neigh_list,
 				 rif_list_node)
 		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
 }
@@ -1055,7 +1055,7 @@ struct mlxsw_sp_nexthop {
 						*/
 	struct rhash_head ht_node;
 	struct mlxsw_sp_nexthop_key key;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
 			      */
@@ -1082,7 +1082,7 @@ struct mlxsw_sp_nexthop_group {
 	u16 ecmp_size;
 	u16 count;
 	struct mlxsw_sp_nexthop nexthops[0];
-#define nh_rif	nexthops[0].r
+#define nh_rif	nexthops[0].rif
 };
 
 static const struct rhashtable_params mlxsw_sp_nexthop_group_ht_params = {
@@ -1372,22 +1372,22 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 }
 
 static void mlxsw_sp_nexthop_rif_init(struct mlxsw_sp_nexthop *nh,
-				      struct mlxsw_sp_rif *r)
+				      struct mlxsw_sp_rif *rif)
 {
-	if (nh->r)
+	if (nh->rif)
 		return;
 
-	nh->r = r;
-	list_add(&nh->rif_list_node, &r->nexthop_list);
+	nh->rif = rif;
+	list_add(&nh->rif_list_node, &rif->nexthop_list);
 }
 
 static void mlxsw_sp_nexthop_rif_fini(struct mlxsw_sp_nexthop *nh)
 {
-	if (!nh->r)
+	if (!nh->rif)
 		return;
 
 	list_del(&nh->rif_list_node);
-	nh->r = NULL;
+	nh->rif = NULL;
 }
 
 static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
@@ -1478,7 +1478,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 {
 	struct net_device *dev = fib_nh->nh_dev;
 	struct in_device *in_dev;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	int err;
 
 	nh->nh_grp = nh_grp;
@@ -1495,10 +1495,10 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	    fib_nh->nh_flags & RTNH_F_LINKDOWN)
 		return 0;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!r)
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!rif)
 		return 0;
-	mlxsw_sp_nexthop_rif_init(nh, r);
+	mlxsw_sp_nexthop_rif_init(nh, rif);
 
 	err = mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
 	if (err)
@@ -1524,7 +1524,7 @@ static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_nexthop_key key;
 	struct mlxsw_sp_nexthop *nh;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 
 	if (mlxsw_sp->router.aborted)
 		return;
@@ -1534,13 +1534,13 @@ static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
 	if (WARN_ON_ONCE(!nh))
 		return;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fib_nh->nh_dev);
-	if (!r)
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fib_nh->nh_dev);
+	if (!rif)
 		return;
 
 	switch (event) {
 	case FIB_EVENT_NH_ADD:
-		mlxsw_sp_nexthop_rif_init(nh, r);
+		mlxsw_sp_nexthop_rif_init(nh, rif);
 		mlxsw_sp_nexthop_neigh_init(mlxsw_sp, nh);
 		break;
 	case FIB_EVENT_NH_DEL:
@@ -1553,11 +1553,11 @@ static void mlxsw_sp_nexthop_event(struct mlxsw_sp *mlxsw_sp,
 }
 
 static void mlxsw_sp_nexthop_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
-					   struct mlxsw_sp_rif *r)
+					   struct mlxsw_sp_rif *rif)
 {
 	struct mlxsw_sp_nexthop *nh, *tmp;
 
-	list_for_each_entry_safe(nh, tmp, &r->nexthop_list, rif_list_node) {
+	list_for_each_entry_safe(nh, tmp, &rif->nexthop_list, rif_list_node) {
 		mlxsw_sp_nexthop_neigh_fini(mlxsw_sp, nh);
 		mlxsw_sp_nexthop_rif_fini(nh);
 		mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
@@ -1760,17 +1760,17 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 					struct mlxsw_sp_fib_entry *fib_entry,
 					enum mlxsw_reg_ralue_op op)
 {
-	struct mlxsw_sp_rif *r = fib_entry->nh_group->nh_rif;
+	struct mlxsw_sp_rif *rif = fib_entry->nh_group->nh_rif;
 	struct mlxsw_sp_fib *fib = fib_entry->fib_node->fib;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
 	u16 trap_id = 0;
-	u16 rif = 0;
+	u16 rif_index = 0;
 
 	if (mlxsw_sp_fib_entry_should_offload(fib_entry)) {
 		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_NOP;
-		rif = r->rif;
+		rif_index = rif->rif_index;
 	} else {
 		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_TRAP;
 		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
@@ -1780,7 +1780,8 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 			      (enum mlxsw_reg_ralxx_protocol) fib->proto, op,
 			      fib->vr->id, fib_entry->fib_node->key.prefix_len,
 			      *p_dip);
-	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id, rif);
+	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id,
+				       rif_index);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
@@ -2644,24 +2645,25 @@ static int mlxsw_sp_router_rif_disable(struct mlxsw_sp *mlxsw_sp, u16 rif)
 }
 
 static void mlxsw_sp_router_rif_gone_sync(struct mlxsw_sp *mlxsw_sp,
-					  struct mlxsw_sp_rif *r)
+					  struct mlxsw_sp_rif *rif)
 {
-	mlxsw_sp_router_rif_disable(mlxsw_sp, r->rif);
-	mlxsw_sp_nexthop_rif_gone_sync(mlxsw_sp, r);
-	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_router_rif_disable(mlxsw_sp, rif->rif_index);
+	mlxsw_sp_nexthop_rif_gone_sync(mlxsw_sp, rif);
+	mlxsw_sp_neigh_rif_gone_sync(mlxsw_sp, rif);
 }
 
-static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
+static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *rif,
 				       const struct in_device *in_dev,
 				       unsigned long event)
 {
 	switch (event) {
 	case NETDEV_UP:
-		if (!r)
+		if (!rif)
 			return true;
 		return false;
 	case NETDEV_DOWN:
-		if (r && !in_dev->ifa_list && !netif_is_l3_slave(r->dev))
+		if (rif && !in_dev->ifa_list &&
+		    !netif_is_l3_slave(rif->dev))
 			return true;
 		/* It is possible we already removed the RIF ourselves
 		 * if it was assigned to a netdev that is now a bridge
@@ -2673,7 +2675,7 @@ static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
 	return false;
 }
 
-#define MLXSW_SP_INVALID_RIF 0xffff
+#define MLXSW_SP_INVALID_INDEX_RIF 0xffff
 static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 {
 	int i;
@@ -2682,7 +2684,7 @@ static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 		if (!mlxsw_sp->rifs[i])
 			return i;
 
-	return MLXSW_SP_INVALID_RIF;
+	return MLXSW_SP_INVALID_INDEX_RIF;
 }
 
 static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -2696,15 +2698,15 @@ static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
 				    u16 vr_id, struct net_device *l3_dev,
-				    u16 rif, bool create)
+				    u16 rif_index, bool create)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	bool lagged = mlxsw_sp_vport->lagged;
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 	u16 system_port;
 
-	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif, vr_id,
-			    l3_dev->mtu, l3_dev->dev_addr);
+	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif_index,
+			    vr_id, l3_dev->mtu, l3_dev->dev_addr);
 
 	mlxsw_sp_vport_rif_sp_attr_get(mlxsw_sp_vport, &lagged, &system_port);
 	mlxsw_reg_ritr_sp_if_pack(ritr_pl, lagged, system_port,
@@ -2715,9 +2717,9 @@ static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
 
-static u16 mlxsw_sp_rif_sp_to_fid(u16 rif)
+static u16 mlxsw_sp_rif_sp_to_fid(u16 rif_index)
 {
-	return MLXSW_SP_RFID_BASE + rif;
+	return MLXSW_SP_RFID_BASE + rif_index;
 }
 
 static struct mlxsw_sp_fid *
@@ -2738,25 +2740,25 @@ mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
 }
 
 static struct mlxsw_sp_rif *
-mlxsw_sp_rif_alloc(u16 rif, u16 vr_id, struct net_device *l3_dev,
+mlxsw_sp_rif_alloc(u16 rif_index, u16 vr_id, struct net_device *l3_dev,
 		   struct mlxsw_sp_fid *f)
 {
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 
-	r = kzalloc(sizeof(*r), GFP_KERNEL);
-	if (!r)
+	rif = kzalloc(sizeof(*rif), GFP_KERNEL);
+	if (!rif)
 		return NULL;
 
-	INIT_LIST_HEAD(&r->nexthop_list);
-	INIT_LIST_HEAD(&r->neigh_list);
-	ether_addr_copy(r->addr, l3_dev->dev_addr);
-	r->mtu = l3_dev->mtu;
-	r->vr_id = vr_id;
-	r->dev = l3_dev;
-	r->rif = rif;
-	r->f = f;
+	INIT_LIST_HEAD(&rif->nexthop_list);
+	INIT_LIST_HEAD(&rif->neigh_list);
+	ether_addr_copy(rif->addr, l3_dev->dev_addr);
+	rif->mtu = l3_dev->mtu;
+	rif->vr_id = vr_id;
+	rif->dev = l3_dev;
+	rif->rif_index = rif_index;
+	rif->f = f;
 
-	return r;
+	return rif;
 }
 
 static struct mlxsw_sp_rif *
@@ -2767,24 +2769,24 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	u32 tb_id = l3mdev_fib_table(l3_dev);
 	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fid *f;
-	struct mlxsw_sp_rif *r;
-	u16 fid, rif;
+	struct mlxsw_sp_rif *rif;
+	u16 fid, rif_index;
 	int err;
 
-	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_INVALID_RIF)
+	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
+	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF)
 		return ERR_PTR(-ERANGE);
 
 	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
-	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif,
-				       true);
+	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev,
+				       rif_index, true);
 	if (err)
 		goto err_vport_rif_sp_op;
 
-	fid = mlxsw_sp_rif_sp_to_fid(rif);
+	fid = mlxsw_sp_rif_sp_to_fid(rif_index);
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
 	if (err)
 		goto err_rif_fdb_op;
@@ -2795,53 +2797,54 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_rfid_alloc;
 	}
 
-	r = mlxsw_sp_rif_alloc(rif, vr->id, l3_dev, f);
-	if (!r) {
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	if (!rif) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
 	}
 
-	f->r = r;
-	mlxsw_sp->rifs[rif] = r;
+	f->rif = rif;
+	mlxsw_sp->rifs[rif_index] = rif;
 	vr->rif_count++;
 
-	return r;
+	return rif;
 
 err_rif_alloc:
 	kfree(f);
 err_rfid_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 err_rif_fdb_op:
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif, false);
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif_index,
+				 false);
 err_vport_rif_sp_op:
 	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
 
 static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
-					  struct mlxsw_sp_rif *r)
+					  struct mlxsw_sp_rif *rif)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[r->vr_id];
-	struct net_device *l3_dev = r->dev;
-	struct mlxsw_sp_fid *f = r->f;
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[rif->vr_id];
+	struct net_device *l3_dev = rif->dev;
+	struct mlxsw_sp_fid *f = rif->f;
+	u16 rif_index = rif->rif_index;
 	u16 fid = f->fid;
-	u16 rif = r->rif;
 
-	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, rif);
 
 	vr->rif_count--;
-	mlxsw_sp->rifs[rif] = NULL;
-	f->r = NULL;
+	mlxsw_sp->rifs[rif_index] = NULL;
+	f->rif = NULL;
 
-	kfree(r);
+	kfree(rif);
 
 	kfree(f);
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif, false);
-
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif_index,
+				 false);
 	mlxsw_sp_vr_put(vr);
 }
 
@@ -2849,19 +2852,19 @@ static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				      struct net_device *l3_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
-	if (!r) {
-		r = mlxsw_sp_vport_rif_sp_create(mlxsw_sp_vport, l3_dev);
-		if (IS_ERR(r))
-			return PTR_ERR(r);
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, l3_dev);
+	if (!rif) {
+		rif = mlxsw_sp_vport_rif_sp_create(mlxsw_sp_vport, l3_dev);
+		if (IS_ERR(rif))
+			return PTR_ERR(rif);
 	}
 
-	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, r->f);
-	r->f->ref_count++;
+	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, rif->f);
+	rif->f->ref_count++;
 
-	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", r->f->fid);
+	netdev_dbg(mlxsw_sp_vport->dev, "Joined FID=%d\n", rif->f->fid);
 
 	return 0;
 }
@@ -2874,7 +2877,7 @@ static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	if (--f->ref_count == 0)
-		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->r);
+		mlxsw_sp_vport_rif_sp_destroy(mlxsw_sp_vport, f->rif);
 }
 
 static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
@@ -3014,13 +3017,13 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 				      struct mlxsw_sp_fid *f)
 {
 	u32 tb_id = l3mdev_fib_table(l3_dev);
+	struct mlxsw_sp_rif *rif;
 	struct mlxsw_sp_vr *vr;
-	struct mlxsw_sp_rif *r;
-	u16 rif;
+	u16 rif_index;
 	int err;
 
-	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_INVALID_RIF)
+	rif_index = mlxsw_sp_avail_rif_get(mlxsw_sp);
+	if (rif_index == MLXSW_SP_INVALID_INDEX_RIF)
 		return -ERANGE;
 
 	vr = mlxsw_sp_vr_get(mlxsw_sp, tb_id ? : RT_TABLE_MAIN);
@@ -3031,8 +3034,8 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_port_flood_set;
 
-	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif,
-				     true);
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid,
+				     rif_index, true);
 	if (err)
 		goto err_rif_bridge_op;
 
@@ -3040,24 +3043,25 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_rif_fdb_op;
 
-	r = mlxsw_sp_rif_alloc(rif, vr->id, l3_dev, f);
-	if (!r) {
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	if (!rif) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
 	}
 
-	f->r = r;
-	mlxsw_sp->rifs[rif] = r;
+	f->rif = rif;
+	mlxsw_sp->rifs[rif_index] = rif;
 	vr->rif_count++;
 
-	netdev_dbg(l3_dev, "RIF=%d created\n", rif);
+	netdev_dbg(l3_dev, "RIF=%d created\n", rif_index);
 
 	return 0;
 
 err_rif_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 err_rif_fdb_op:
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif, false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
+			       false);
 err_rif_bridge_op:
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 err_port_flood_set:
@@ -3066,30 +3070,31 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 }
 
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
-				 struct mlxsw_sp_rif *r)
+				 struct mlxsw_sp_rif *rif)
 {
-	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[r->vr_id];
-	struct net_device *l3_dev = r->dev;
-	struct mlxsw_sp_fid *f = r->f;
-	u16 rif = r->rif;
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[rif->vr_id];
+	struct net_device *l3_dev = rif->dev;
+	struct mlxsw_sp_fid *f = rif->f;
+	u16 rif_index = rif->rif_index;
 
-	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, rif);
 
 	vr->rif_count--;
-	mlxsw_sp->rifs[rif] = NULL;
-	f->r = NULL;
+	mlxsw_sp->rifs[rif_index] = NULL;
+	f->rif = NULL;
 
-	kfree(r);
+	kfree(rif);
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif, false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif_index,
+			       false);
 
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 
 	mlxsw_sp_vr_put(vr);
 
-	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif);
+	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif_index);
 }
 
 static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
@@ -3111,7 +3116,7 @@ static int mlxsw_sp_inetaddr_bridge_event(struct net_device *l3_dev,
 	case NETDEV_UP:
 		return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
 	case NETDEV_DOWN:
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 		break;
 	}
 
@@ -3145,15 +3150,15 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
 	struct net_device *dev = ifa->ifa_dev->dev;
 	struct mlxsw_sp *mlxsw_sp;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	int err = 0;
 
 	mlxsw_sp = mlxsw_sp_lower_get(dev);
 	if (!mlxsw_sp)
 		goto out;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!mlxsw_sp_rif_should_config(r, ifa->ifa_dev, event))
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!mlxsw_sp_rif_should_config(rif, ifa->ifa_dev, event))
 		goto out;
 
 	if (mlxsw_sp_port_dev_check(dev))
@@ -3169,13 +3174,13 @@ int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 	return notifier_from_errno(err);
 }
 
-static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
+static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif_index,
 			     const char *mac, int mtu)
 {
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 	int err;
 
-	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif_index);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 	if (err)
 		return err;
@@ -3189,40 +3194,41 @@ static int mlxsw_sp_rif_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
 int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
 {
 	struct mlxsw_sp *mlxsw_sp;
-	struct mlxsw_sp_rif *r;
+	struct mlxsw_sp_rif *rif;
 	int err;
 
 	mlxsw_sp = mlxsw_sp_lower_get(dev);
 	if (!mlxsw_sp)
 		return 0;
 
-	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!r)
+	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (!rif)
 		return 0;
 
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, false);
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, rif->addr, rif->f->fid, false);
 	if (err)
 		return err;
 
-	err = mlxsw_sp_rif_edit(mlxsw_sp, r->rif, dev->dev_addr, dev->mtu);
+	err = mlxsw_sp_rif_edit(mlxsw_sp, rif->rif_index, dev->dev_addr,
+				dev->mtu);
 	if (err)
 		goto err_rif_edit;
 
-	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, dev->dev_addr, r->f->fid, true);
+	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, dev->dev_addr, rif->f->fid, true);
 	if (err)
 		goto err_rif_fdb_op;
 
-	ether_addr_copy(r->addr, dev->dev_addr);
-	r->mtu = dev->mtu;
+	ether_addr_copy(rif->addr, dev->dev_addr);
+	rif->mtu = dev->mtu;
 
-	netdev_dbg(dev, "Updated RIF=%d\n", r->rif);
+	netdev_dbg(dev, "Updated RIF=%d\n", rif->rif_index);
 
 	return 0;
 
 err_rif_fdb_op:
-	mlxsw_sp_rif_edit(mlxsw_sp, r->rif, r->addr, r->mtu);
+	mlxsw_sp_rif_edit(mlxsw_sp, rif->rif_index, rif->addr, rif->mtu);
 err_rif_edit:
-	mlxsw_sp_rif_fdb_op(mlxsw_sp, r->addr, r->f->fid, true);
+	mlxsw_sp_rif_fdb_op(mlxsw_sp, rif->addr, rif->f->fid, true);
 	return err;
 }
 
@@ -3234,7 +3240,7 @@ int mlxsw_sp_vport_vrf_join(struct mlxsw_sp_port *mlxsw_sp_vport)
 	/* In case vPort already has a RIF, then we need to drop it.
 	 * A new one will be created using the VRF's VR.
 	 */
-	if (f && f->r)
+	if (f && f->rif)
 		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
 
 	return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, dev);
@@ -3276,8 +3282,8 @@ int mlxsw_sp_bridge_vrf_join(struct mlxsw_sp *mlxsw_sp,
 	if (WARN_ON(!f))
 		return -EINVAL;
 
-	if (f->r)
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+	if (f->rif)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 
 	return mlxsw_sp_rif_bridge_create(mlxsw_sp, l3_dev, f);
 }
@@ -3290,7 +3296,7 @@ void mlxsw_sp_bridge_vrf_leave(struct mlxsw_sp *mlxsw_sp,
 	f = mlxsw_sp_bridge_fid_get(mlxsw_sp, l3_dev);
 	if (WARN_ON(!f))
 		return;
-	mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+	mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 }
 
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 598727d..d44d92f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -568,8 +568,8 @@ void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f)
 
 	list_del(&f->list);
 
-	if (f->r)
-		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->r);
+	if (f->rif)
+		mlxsw_sp_rif_bridge_destroy(mlxsw_sp, f->rif);
 
 	kfree(f);
 
-- 
2.7.4
