From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 40/42] mlxsw: spectrum_router: Implement next-hop routing
Date: Fri,  1 Jul 2016 16:05:08 +0200
Message-ID: <1467381910-3445-41-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36367 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbcGAOY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:24:58 -0400
Received: by mail-wm0-f66.google.com with SMTP id c82so5691396wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:24:27 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement next-hop routing offload including ECMP. To make it possible,
introduce next-hop group entity. This entity keeps track of resolved
neighbours and updates HW adjacency table accordingly. Note that HW
next-hops are stored in this adjacency table, in form of MAC.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 493 ++++++++++++++++++++-
 2 files changed, 492 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index e781128..0fe6051 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -222,6 +222,7 @@ struct mlxsw_sp_router {
 		struct delayed_work dw;
 		unsigned long interval;	/* ms */
 	} neighs_update;
+	struct list_head nexthop_group_list;
 };
 
 struct mlxsw_sp {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index ed0e6c0..dc13178 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -117,6 +117,8 @@ enum mlxsw_sp_fib_entry_type {
 	MLXSW_SP_FIB_ENTRY_TYPE_TRAP,
 };
 
+struct mlxsw_sp_nexthop_group;
+
 struct mlxsw_sp_fib_entry {
 	struct rhash_head ht_node;
 	struct mlxsw_sp_fib_key key;
@@ -124,6 +126,8 @@ struct mlxsw_sp_fib_entry {
 	u8 added:1;
 	u16 rif; /* used for action local */
 	struct mlxsw_sp_vr *vr;
+	struct list_head nexthop_group_node;
+	struct mlxsw_sp_nexthop_group *nh_group;
 };
 
 struct mlxsw_sp_fib {
@@ -563,6 +567,9 @@ struct mlxsw_sp_neigh_entry {
 	struct delayed_work dw;
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	unsigned char ha[ETH_ALEN];
+	struct list_head nexthop_list; /* list of nexthops using
+					* this neigh entry
+					*/
 };
 
 static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
@@ -606,6 +613,7 @@ mlxsw_sp_neigh_entry_create(const void *addr, size_t addr_len,
 	neigh_entry->rif = rif;
 	neigh_entry->n = n;
 	INIT_DELAYED_WORK(&neigh_entry->dw, mlxsw_sp_router_neigh_update_hw);
+	INIT_LIST_HEAD(&neigh_entry->nexthop_list);
 	return neigh_entry;
 }
 
@@ -808,6 +816,11 @@ static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
 	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
 }
 
+static void
+mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
+			      struct mlxsw_sp_neigh_entry *neigh_entry,
+			      bool removing);
+
 static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry =
@@ -849,6 +862,7 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 		} else {
 			neigh_entry->offloaded = true;
 		}
+		mlxsw_sp_nexthop_neigh_update(mlxsw_sp, neigh_entry, false);
 	} else if (removing) {
 		mlxsw_reg_rauht_pack4(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE,
 				      neigh_entry->rif,
@@ -861,6 +875,7 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 		} else {
 			neigh_entry->offloaded = false;
 		}
+		mlxsw_sp_nexthop_neigh_update(mlxsw_sp, neigh_entry, true);
 	}
 
 	neigh_release(n);
@@ -978,6 +993,434 @@ static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
 
+struct mlxsw_sp_nexthop {
+	struct list_head neigh_list_node; /* member of neigh entry list */
+	struct mlxsw_sp_nexthop_group *nh_grp; /* pointer back to the group
+						* this belongs to
+						*/
+	u8 should_offload:1, /* set indicates this neigh is connected and
+			      * should be put to KVD linear area of this group.
+			      */
+	   offloaded:1, /* set in case the neigh is actually put into
+			 * KVD linear area of this group.
+			 */
+	   update:1; /* set indicates that MAC of this neigh should be
+		      * updated in HW
+		      */
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+};
+
+struct mlxsw_sp_nexthop_group {
+	struct list_head list; /* node in mlxsw->router.nexthop_group_list */
+	struct list_head fib_list; /* list of fib entries that use this group */
+	u8 adj_index_valid:1;
+	u32 adj_index;
+	u16 ecmp_size;
+	u16 count;
+	struct mlxsw_sp_nexthop nexthops[0];
+};
+
+static int mlxsw_sp_adj_index_mass_update_vr(struct mlxsw_sp *mlxsw_sp,
+					     struct mlxsw_sp_vr *vr,
+					     u32 adj_index, u16 ecmp_size,
+					     u32 new_adj_index,
+					     u16 new_ecmp_size)
+{
+	char raleu_pl[MLXSW_REG_RALEU_LEN];
+
+	mlxsw_reg_raleu_pack(raleu_pl, vr->proto, vr->id,
+			     adj_index, ecmp_size,
+			     new_adj_index, new_ecmp_size);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raleu), raleu_pl);
+}
+
+static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
+					  struct mlxsw_sp_nexthop_group *nh_grp,
+					  u32 old_adj_index, u16 old_ecmp_size)
+{
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_vr *vr = NULL;
+	int err;
+
+	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
+		if (vr == fib_entry->vr)
+			continue;
+		vr = fib_entry->vr;
+		err = mlxsw_sp_adj_index_mass_update_vr(mlxsw_sp, vr,
+							old_adj_index,
+							old_ecmp_size,
+							nh_grp->adj_index,
+							nh_grp->ecmp_size);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int mlxsw_sp_nexthop_mac_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+				       struct mlxsw_sp_nexthop *nh)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
+	char ratr_pl[MLXSW_REG_RATR_LEN];
+
+	mlxsw_reg_ratr_pack(ratr_pl, MLXSW_REG_RATR_OP_WRITE_WRITE_ENTRY,
+			    true, adj_index, neigh_entry->rif);
+	mlxsw_reg_ratr_eth_entry_pack(ratr_pl, neigh_entry->ha);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ratr), ratr_pl);
+}
+
+static int
+mlxsw_sp_nexthop_group_mac_update(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	u32 adj_index = nh_grp->adj_index; /* base */
+	struct mlxsw_sp_nexthop *nh;
+	int i;
+	int err;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+
+		if (!nh->should_offload) {
+			nh->offloaded = 0;
+			continue;
+		}
+
+		if (nh->update) {
+			err = mlxsw_sp_nexthop_mac_update(mlxsw_sp,
+							  adj_index, nh);
+			if (err)
+				return err;
+			nh->update = 0;
+			nh->offloaded = 1;
+		}
+		adj_index++;
+	}
+	return 0;
+}
+
+static int mlxsw_sp_fib_entry_update(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_fib_entry *fib_entry);
+
+static int
+mlxsw_sp_nexthop_fib_entries_update(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	struct mlxsw_sp_fib_entry *fib_entry;
+	int err;
+
+	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
+		err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static void
+mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	struct mlxsw_sp_nexthop *nh;
+	bool offload_change = false;
+	u32 adj_index;
+	u16 ecmp_size = 0;
+	bool old_adj_index_valid;
+	u32 old_adj_index;
+	u16 old_ecmp_size;
+	int ret;
+	int i;
+	int err;
+
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+
+		if (nh->should_offload ^ nh->offloaded) {
+			offload_change = true;
+			if (nh->should_offload)
+				nh->update = 1;
+		}
+		if (nh->should_offload)
+			ecmp_size++;
+	}
+	if (!offload_change) {
+		/* Nothing was added or removed, so no need to reallocate. Just
+		 * update MAC on existing adjacency indexes.
+		 */
+		err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp);
+		if (err) {
+			dev_warn(mlxsw_sp->bus_info->dev, "Failed to update neigh MAC in adjacency table.\n");
+			goto set_trap;
+		}
+		return;
+	}
+	if (!ecmp_size)
+		/* No neigh of this group is connected so we just set
+		 * the trap and let everthing flow through kernel.
+		 */
+		goto set_trap;
+
+	ret = mlxsw_sp_kvdl_alloc(mlxsw_sp, ecmp_size);
+	if (ret < 0) {
+		/* We ran out of KVD linear space, just set the
+		 * trap and let everything flow through kernel.
+		 */
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to allocate KVD linear area for nexthop group.\n");
+		goto set_trap;
+	}
+	adj_index = ret;
+	old_adj_index_valid = nh_grp->adj_index_valid;
+	old_adj_index = nh_grp->adj_index;
+	old_ecmp_size = nh_grp->ecmp_size;
+	nh_grp->adj_index_valid = 1;
+	nh_grp->adj_index = adj_index;
+	nh_grp->ecmp_size = ecmp_size;
+	err = mlxsw_sp_nexthop_group_mac_update(mlxsw_sp, nh_grp);
+	if (err) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to update neigh MAC in adjacency table.\n");
+		goto set_trap;
+	}
+
+	if (!old_adj_index_valid) {
+		/* The trap was set for fib entries, so we have to call
+		 * fib entry update to unset it and use adjacency index.
+		 */
+		err = mlxsw_sp_nexthop_fib_entries_update(mlxsw_sp, nh_grp);
+		if (err) {
+			dev_warn(mlxsw_sp->bus_info->dev, "Failed to add adjacency index to fib entries.\n");
+			goto set_trap;
+		}
+		return;
+	}
+
+	err = mlxsw_sp_adj_index_mass_update(mlxsw_sp, nh_grp,
+					     old_adj_index, old_ecmp_size);
+	mlxsw_sp_kvdl_free(mlxsw_sp, old_adj_index);
+	if (err) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to mass-update adjacency index for nexthop group.\n");
+		goto set_trap;
+	}
+	return;
+
+set_trap:
+	old_adj_index_valid = nh_grp->adj_index_valid;
+	nh_grp->adj_index_valid = 0;
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+		nh->offloaded = 0;
+	}
+	err = mlxsw_sp_nexthop_fib_entries_update(mlxsw_sp, nh_grp);
+	if (err)
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set traps for fib entries.\n");
+	if (old_adj_index_valid)
+		mlxsw_sp_kvdl_free(mlxsw_sp, nh_grp->adj_index);
+}
+
+static void __mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp_nexthop *nh,
+					    bool removing)
+{
+	if (!removing && !nh->should_offload)
+		nh->should_offload = 1;
+	else if (removing && nh->offloaded)
+		nh->should_offload = 0;
+	nh->update = 1;
+}
+
+static void
+mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
+			      struct mlxsw_sp_neigh_entry *neigh_entry,
+			      bool removing)
+{
+	struct mlxsw_sp_nexthop *nh;
+
+	/* Take RTNL mutex here to prevent lists from changes */
+	rtnl_lock();
+	list_for_each_entry(nh, &neigh_entry->nexthop_list,
+			    neigh_list_node) {
+		__mlxsw_sp_nexthop_neigh_update(nh, removing);
+		mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
+	}
+	rtnl_unlock();
+}
+
+static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_nexthop_group *nh_grp,
+				 struct mlxsw_sp_nexthop *nh,
+				 struct fib_nh *fib_nh)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+	u32 gwip = ntohl(fib_nh->nh_gw);
+	struct net_device *dev = fib_nh->nh_dev;
+	struct neighbour *n;
+	u8 nud_state;
+
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &gwip,
+						  sizeof(gwip), dev);
+	if (!neigh_entry) {
+		__be32 gwipn = htonl(gwip);
+
+		n = neigh_create(&arp_tbl, &gwipn, dev);
+		if (IS_ERR(n))
+			return PTR_ERR(n);
+		neigh_event_send(n, NULL);
+		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &gwip,
+							  sizeof(gwip), dev);
+		if (!neigh_entry) {
+			neigh_release(n);
+			return -EINVAL;
+		}
+	} else {
+		/* Take a reference of neigh here ensuring that neigh would
+		 * not be detructed before the nexthop entry is finished.
+		 * The second branch takes the reference in neith_create()
+		 */
+		n = neigh_entry->n;
+		neigh_clone(n);
+	}
+	nh->nh_grp = nh_grp;
+	nh->neigh_entry = neigh_entry;
+	list_add_tail(&nh->neigh_list_node, &neigh_entry->nexthop_list);
+	read_lock_bh(&n->lock);
+	nud_state = n->nud_state;
+	read_unlock_bh(&n->lock);
+	__mlxsw_sp_nexthop_neigh_update(nh, !(nud_state & NUD_VALID));
+
+	return 0;
+}
+
+static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_nexthop *nh)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
+
+	list_del(&nh->neigh_list_node);
+	neigh_release(neigh_entry->n);
+}
+
+static struct mlxsw_sp_nexthop_group *
+mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp;
+	struct mlxsw_sp_nexthop *nh;
+	struct fib_nh *fib_nh;
+	size_t alloc_size;
+	int i;
+	int err;
+
+	alloc_size = sizeof(*nh_grp) +
+		     fi->fib_nhs * sizeof(struct mlxsw_sp_nexthop);
+	nh_grp = kzalloc(alloc_size, GFP_KERNEL);
+	if (!nh_grp)
+		return ERR_PTR(-ENOMEM);
+	INIT_LIST_HEAD(&nh_grp->fib_list);
+	nh_grp->count = fi->fib_nhs;
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+		fib_nh = &fi->fib_nh[i];
+		err = mlxsw_sp_nexthop_init(mlxsw_sp, nh_grp, nh, fib_nh);
+		if (err)
+			goto err_nexthop_init;
+	}
+	list_add_tail(&nh_grp->list, &mlxsw_sp->router.nexthop_group_list);
+	mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh_grp);
+	return nh_grp;
+
+err_nexthop_init:
+	for (i--; i >= 0; i--)
+		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
+	kfree(nh_grp);
+	return ERR_PTR(err);
+}
+
+static void
+mlxsw_sp_nexthop_group_destroy(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	struct mlxsw_sp_nexthop *nh;
+	int i;
+
+	list_del(&nh_grp->list);
+	for (i = 0; i < nh_grp->count; i++) {
+		nh = &nh_grp->nexthops[i];
+		mlxsw_sp_nexthop_fini(mlxsw_sp, nh);
+	}
+	kfree(nh_grp);
+}
+
+static bool mlxsw_sp_nexthop_match(struct mlxsw_sp_nexthop *nh,
+				   struct fib_info *fi)
+{
+	int i;
+
+	for (i = 0; i < fi->fib_nhs; i++) {
+		struct fib_nh *fib_nh = &fi->fib_nh[i];
+		u32 gwip = ntohl(fib_nh->nh_gw);
+
+		if (memcmp(nh->neigh_entry->key.addr,
+			   &gwip, sizeof(u32)) == 0 &&
+		    nh->neigh_entry->key.dev == fib_nh->nh_dev)
+			return true;
+	}
+	return false;
+}
+
+static bool mlxsw_sp_nexthop_group_match(struct mlxsw_sp_nexthop_group *nh_grp,
+					 struct fib_info *fi)
+{
+	int i;
+
+	if (nh_grp->count != fi->fib_nhs)
+		return false;
+	for (i = 0; i < nh_grp->count; i++) {
+		struct mlxsw_sp_nexthop *nh = &nh_grp->nexthops[i];
+
+		if (!mlxsw_sp_nexthop_match(nh, fi))
+			return false;
+	}
+	return true;
+}
+
+static struct mlxsw_sp_nexthop_group *
+mlxsw_sp_nexthop_group_find(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp;
+
+	list_for_each_entry(nh_grp, &mlxsw_sp->router.nexthop_group_list,
+			    list) {
+		if (mlxsw_sp_nexthop_group_match(nh_grp, fi))
+			return nh_grp;
+	}
+	return NULL;
+}
+
+static int mlxsw_sp_nexthop_group_get(struct mlxsw_sp *mlxsw_sp,
+				      struct mlxsw_sp_fib_entry *fib_entry,
+				      struct fib_info *fi)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp;
+
+	nh_grp = mlxsw_sp_nexthop_group_find(mlxsw_sp, fi);
+	if (!nh_grp) {
+		nh_grp = mlxsw_sp_nexthop_group_create(mlxsw_sp, fi);
+		if (IS_ERR(nh_grp))
+			return PTR_ERR(nh_grp);
+	}
+	list_add_tail(&fib_entry->nexthop_group_node, &nh_grp->fib_list);
+	fib_entry->nh_group = nh_grp;
+	return 0;
+}
+
+static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_nexthop_group *nh_grp = fib_entry->nh_group;
+
+	list_del(&fib_entry->nexthop_group_node);
+	if (!list_empty(&nh_grp->fib_list))
+		return;
+	mlxsw_sp_nexthop_group_destroy(mlxsw_sp, nh_grp);
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
@@ -999,6 +1442,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
 
+	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_group_list);
 	err = __mlxsw_sp_router_init(mlxsw_sp);
 	if (err)
 		return err;
@@ -1013,6 +1457,38 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
 
+static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_fib_entry *fib_entry,
+					 enum mlxsw_reg_ralue_op op)
+{
+	char ralue_pl[MLXSW_REG_RALUE_LEN];
+	u32 *p_dip = (u32 *) fib_entry->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	enum mlxsw_reg_ralue_trap_action trap_action;
+	u16 trap_id = 0;
+	u32 adjacency_index = 0;
+	u16 ecmp_size = 0;
+
+	/* In case the nexthop group adjacency index is valid, use it
+	 * with provided ECMP size. Otherwise, setup trap and pass
+	 * traffic to kernel.
+	 */
+	if (fib_entry->nh_group->adj_index_valid) {
+		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_NOP;
+		adjacency_index = fib_entry->nh_group->adj_index;
+		ecmp_size = fib_entry->nh_group->ecmp_size;
+	} else {
+		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_TRAP;
+		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
+	}
+
+	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
+			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_act_remote_pack(ralue_pl, trap_action, trap_id,
+					adjacency_index, ecmp_size);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
+}
+
 static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 					struct mlxsw_sp_fib_entry *fib_entry,
 					enum mlxsw_reg_ralue_op op)
@@ -1049,7 +1525,7 @@ static int mlxsw_sp_fib_entry_op4(struct mlxsw_sp *mlxsw_sp,
 {
 	switch (fib_entry->type) {
 	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
-		return -EINVAL;
+		return mlxsw_sp_fib_entry_op4_remote(mlxsw_sp, fib_entry, op);
 	case MLXSW_SP_FIB_ENTRY_TYPE_LOCAL:
 		return mlxsw_sp_fib_entry_op4_local(mlxsw_sp, fib_entry, op);
 	case MLXSW_SP_FIB_ENTRY_TYPE_TRAP:
@@ -1129,7 +1605,17 @@ mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
 		fib_entry->rif = r->rif;
 		return 0;
 	}
-	return -EINVAL;
+	fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
+	return mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
+}
+
+static void
+mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_fib_entry *fib_entry)
+{
+	if (fib_entry->type != MLXSW_SP_FIB_ENTRY_TYPE_REMOTE)
+		return;
+	mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
 }
 
 static int
@@ -1173,6 +1659,7 @@ mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 
 err_alloc_info:
+	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 err_fib4_entry_init:
 	mlxsw_sp_fib_entry_destroy(fib_entry);
 err_fib_entry_create:
@@ -1207,6 +1694,7 @@ mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
 err_fib_entry_add:
 	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
 err_fib_entry_insert:
+	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 	mlxsw_sp_fib_entry_destroy(fib_entry);
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
 	return err;
@@ -1243,6 +1731,7 @@ int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 	mlxsw_sp_fib_entry_del(mlxsw_sp_port->mlxsw_sp, fib_entry);
 	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
+	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
 	mlxsw_sp_fib_entry_destroy(fib_entry);
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
 	return 0;
-- 
2.5.5
