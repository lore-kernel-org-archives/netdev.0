From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: spectrum_router: Simplify neighbour reflection
Date: Mon,  6 Feb 2017 16:20:13 +0100
Message-ID: <1486394417-8011-5-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33964 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdBFPUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:25 -0500
Received: by mail-wj0-f195.google.com with SMTP id ip10so3364471wjb.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:24 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we had two interfaces for neighbour related configuration:
ndo_neigh_{construct,destroy} and NEIGH_UPDATE netevents. The ndos were
used to add and remove neighbours from the driver's cache, whereas the
netevent was used to reflect the neighbours into the device's tables.

However, if the NUD state of a neighbour isn't NUD_VALID or if the
neighbour is dead, then there's really no reason for us to keep it
inside our cache. The only exception to this rule are neighbours that
are also used for nexthops, which we periodically refresh to get them
resolved.

We can therefore eliminate the ndo entry point into the driver and
simplify the code, making it similar to the FIB reflection, which is
based solely on events. This also helps us avoid a locking issue, in
which the RIF cache was traversed without proper locking during
insertion into the neigh entry cache.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 -
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 263 +++++++++++----------
 3 files changed, 135 insertions(+), 134 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8a52c86..c2a6751 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1400,8 +1400,6 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_get_offload_stats	= mlxsw_sp_port_get_offload_stats,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
-	.ndo_neigh_construct	= mlxsw_sp_router_neigh_construct,
-	.ndo_neigh_destroy	= mlxsw_sp_router_neigh_destroy,
 	.ndo_fdb_add		= switchdev_port_fdb_add,
 	.ndo_fdb_del		= switchdev_port_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 4d251e0..dcd641a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -599,10 +599,6 @@ static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
-int mlxsw_sp_router_neigh_construct(struct net_device *dev,
-				    struct neighbour *n);
-void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
-				   struct neighbour *n);
 int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 				   unsigned long event, void *ptr);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 851799d..c338b08 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -613,9 +613,7 @@ struct mlxsw_sp_neigh_entry {
 	struct rhash_head ht_node;
 	struct mlxsw_sp_neigh_key key;
 	u16 rif;
-	bool offloaded;
-	struct work_struct work;
-	struct mlxsw_sp_port *mlxsw_sp_port;
+	bool connected;
 	unsigned char ha[ETH_ALEN];
 	struct list_head nexthop_list; /* list of nexthops using
 					* this neigh entry
@@ -629,105 +627,88 @@ static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
 	.key_len = sizeof(struct mlxsw_sp_neigh_key),
 };
 
-static int
-mlxsw_sp_neigh_entry_insert(struct mlxsw_sp *mlxsw_sp,
-			    struct mlxsw_sp_neigh_entry *neigh_entry)
-{
-	return rhashtable_insert_fast(&mlxsw_sp->router.neigh_ht,
-				      &neigh_entry->ht_node,
-				      mlxsw_sp_neigh_ht_params);
-}
-
-static void
-mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
-			    struct mlxsw_sp_neigh_entry *neigh_entry)
-{
-	rhashtable_remove_fast(&mlxsw_sp->router.neigh_ht,
-			       &neigh_entry->ht_node,
-			       mlxsw_sp_neigh_ht_params);
-}
-
-static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work);
-
 static struct mlxsw_sp_neigh_entry *
-mlxsw_sp_neigh_entry_create(struct neighbour *n, u16 rif)
+mlxsw_sp_neigh_entry_alloc(struct mlxsw_sp *mlxsw_sp, struct neighbour *n,
+			   u16 rif)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 
-	neigh_entry = kzalloc(sizeof(*neigh_entry), GFP_ATOMIC);
+	neigh_entry = kzalloc(sizeof(*neigh_entry), GFP_KERNEL);
 	if (!neigh_entry)
 		return NULL;
+
 	neigh_entry->key.n = n;
 	neigh_entry->rif = rif;
-	INIT_WORK(&neigh_entry->work, mlxsw_sp_router_neigh_update_hw);
 	INIT_LIST_HEAD(&neigh_entry->nexthop_list);
+
 	return neigh_entry;
 }
 
-static void
-mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp_neigh_entry *neigh_entry)
+static void mlxsw_sp_neigh_entry_free(struct mlxsw_sp_neigh_entry *neigh_entry)
 {
 	kfree(neigh_entry);
 }
 
-static struct mlxsw_sp_neigh_entry *
-mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
+static int
+mlxsw_sp_neigh_entry_insert(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry)
 {
-	struct mlxsw_sp_neigh_key key;
+	return rhashtable_insert_fast(&mlxsw_sp->router.neigh_ht,
+				      &neigh_entry->ht_node,
+				      mlxsw_sp_neigh_ht_params);
+}
 
-	key.n = n;
-	return rhashtable_lookup_fast(&mlxsw_sp->router.neigh_ht,
-				      &key, mlxsw_sp_neigh_ht_params);
+static void
+mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	rhashtable_remove_fast(&mlxsw_sp->router.neigh_ht,
+			       &neigh_entry->ht_node,
+			       mlxsw_sp_neigh_ht_params);
 }
 
-int mlxsw_sp_router_neigh_construct(struct net_device *dev,
-				    struct neighbour *n)
+static struct mlxsw_sp_neigh_entry *
+mlxsw_sp_neigh_entry_create(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct mlxsw_sp_rif *r;
 	int err;
 
-	if (n->tbl != &arp_tbl)
-		return 0;
-
-	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
-	if (neigh_entry)
-		return 0;
-
 	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, n->dev);
-	if (WARN_ON(!r))
-		return -EINVAL;
+	if (!r)
+		return ERR_PTR(-EINVAL);
 
-	neigh_entry = mlxsw_sp_neigh_entry_create(n, r->rif);
+	neigh_entry = mlxsw_sp_neigh_entry_alloc(mlxsw_sp, n, r->rif);
 	if (!neigh_entry)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
+
 	err = mlxsw_sp_neigh_entry_insert(mlxsw_sp, neigh_entry);
 	if (err)
 		goto err_neigh_entry_insert;
-	return 0;
+
+	return neigh_entry;
 
 err_neigh_entry_insert:
-	mlxsw_sp_neigh_entry_destroy(neigh_entry);
-	return err;
+	mlxsw_sp_neigh_entry_free(neigh_entry);
+	return ERR_PTR(err);
 }
 
-void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
-				   struct neighbour *n)
+static void
+mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp *mlxsw_sp,
+			     struct mlxsw_sp_neigh_entry *neigh_entry)
 {
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_neigh_entry *neigh_entry;
+	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
+	mlxsw_sp_neigh_entry_free(neigh_entry);
+}
 
-	if (n->tbl != &arp_tbl)
-		return;
+static struct mlxsw_sp_neigh_entry *
+mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
+{
+	struct mlxsw_sp_neigh_key key;
 
-	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
-	if (!neigh_entry)
-		return;
-	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
-	mlxsw_sp_neigh_entry_destroy(neigh_entry);
+	key.n = n;
+	return rhashtable_lookup_fast(&mlxsw_sp->router.neigh_ht,
+				      &key, mlxsw_sp_neigh_ht_params);
 }
 
 static void
@@ -932,76 +913,99 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 			      struct mlxsw_sp_neigh_entry *neigh_entry,
 			      bool removing);
 
-static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
+static enum mlxsw_reg_rauht_op mlxsw_sp_rauht_op(bool adding)
+{
+	return adding ? MLXSW_REG_RAUHT_OP_WRITE_ADD :
+			MLXSW_REG_RAUHT_OP_WRITE_DELETE;
+}
+
+static void
+mlxsw_sp_router_neigh_entry_op4(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_neigh_entry *neigh_entry,
+				enum mlxsw_reg_rauht_op op)
 {
-	struct mlxsw_sp_neigh_entry *neigh_entry =
-		container_of(work, struct mlxsw_sp_neigh_entry, work);
 	struct neighbour *n = neigh_entry->key.n;
-	struct mlxsw_sp_port *mlxsw_sp_port = neigh_entry->mlxsw_sp_port;
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u32 dip = ntohl(*((__be32 *) n->primary_key));
 	char rauht_pl[MLXSW_REG_RAUHT_LEN];
-	struct net_device *dev;
+
+	mlxsw_reg_rauht_pack4(rauht_pl, op, neigh_entry->rif, neigh_entry->ha,
+			      dip);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
+}
+
+static void
+mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry,
+			    bool adding)
+{
+	if (!adding && !neigh_entry->connected)
+		return;
+	neigh_entry->connected = adding;
+	if (neigh_entry->key.n->tbl == &arp_tbl)
+		mlxsw_sp_router_neigh_entry_op4(mlxsw_sp, neigh_entry,
+						mlxsw_sp_rauht_op(adding));
+	else
+		WARN_ON_ONCE(1);
+}
+
+struct mlxsw_sp_neigh_event_work {
+	struct work_struct work;
+	struct mlxsw_sp *mlxsw_sp;
+	struct neighbour *n;
+};
+
+static void mlxsw_sp_router_neigh_event_work(struct work_struct *work)
+{
+	struct mlxsw_sp_neigh_event_work *neigh_work =
+		container_of(work, struct mlxsw_sp_neigh_event_work, work);
+	struct mlxsw_sp *mlxsw_sp = neigh_work->mlxsw_sp;
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+	struct neighbour *n = neigh_work->n;
+	unsigned char ha[ETH_ALEN];
 	bool entry_connected;
 	u8 nud_state, dead;
-	bool updating;
-	bool removing;
-	bool adding;
-	u32 dip;
-	int err;
 
+	/* If these parameters are changed after we release the lock,
+	 * then we are guaranteed to receive another event letting us
+	 * know about it.
+	 */
 	read_lock_bh(&n->lock);
-	dip = ntohl(*((__be32 *) n->primary_key));
-	memcpy(neigh_entry->ha, n->ha, sizeof(neigh_entry->ha));
+	memcpy(ha, n->ha, ETH_ALEN);
 	nud_state = n->nud_state;
 	dead = n->dead;
-	dev = n->dev;
 	read_unlock_bh(&n->lock);
 
+	rtnl_lock();
 	entry_connected = nud_state & NUD_VALID && !dead;
-	adding = (!neigh_entry->offloaded) && entry_connected;
-	updating = neigh_entry->offloaded && entry_connected;
-	removing = neigh_entry->offloaded && !entry_connected;
-
-	if (adding || updating) {
-		mlxsw_reg_rauht_pack4(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_ADD,
-				      neigh_entry->rif,
-				      neigh_entry->ha, dip);
-		err = mlxsw_reg_write(mlxsw_sp->core,
-				      MLXSW_REG(rauht), rauht_pl);
-		if (err) {
-			netdev_err(dev, "Could not add neigh %pI4h\n", &dip);
-			neigh_entry->offloaded = false;
-		} else {
-			neigh_entry->offloaded = true;
-		}
-		mlxsw_sp_nexthop_neigh_update(mlxsw_sp, neigh_entry, false);
-	} else if (removing) {
-		mlxsw_reg_rauht_pack4(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE,
-				      neigh_entry->rif,
-				      neigh_entry->ha, dip);
-		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht),
-				      rauht_pl);
-		if (err) {
-			netdev_err(dev, "Could not delete neigh %pI4h\n", &dip);
-			neigh_entry->offloaded = true;
-		} else {
-			neigh_entry->offloaded = false;
-		}
-		mlxsw_sp_nexthop_neigh_update(mlxsw_sp, neigh_entry, true);
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
+	if (!entry_connected && !neigh_entry)
+		goto out;
+	if (!neigh_entry) {
+		neigh_entry = mlxsw_sp_neigh_entry_create(mlxsw_sp, n);
+		if (IS_ERR(neigh_entry))
+			goto out;
 	}
 
+	memcpy(neigh_entry->ha, ha, ETH_ALEN);
+	mlxsw_sp_neigh_entry_update(mlxsw_sp, neigh_entry, entry_connected);
+	mlxsw_sp_nexthop_neigh_update(mlxsw_sp, neigh_entry, !entry_connected);
+
+	if (!neigh_entry->connected && list_empty(&neigh_entry->nexthop_list))
+		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
+
+out:
+	rtnl_unlock();
 	neigh_release(n);
-	mlxsw_sp_port_dev_put(mlxsw_sp_port);
+	kfree(neigh_work);
 }
 
 int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 				   unsigned long event, void *ptr)
 {
-	struct mlxsw_sp_neigh_entry *neigh_entry;
+	struct mlxsw_sp_neigh_event_work *neigh_work;
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp;
 	unsigned long interval;
-	struct net_device *dev;
 	struct neigh_parms *p;
 	struct neighbour *n;
 
@@ -1028,32 +1032,31 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 		break;
 	case NETEVENT_NEIGH_UPDATE:
 		n = ptr;
-		dev = n->dev;
 
 		if (n->tbl != &arp_tbl)
 			return NOTIFY_DONE;
 
-		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(dev);
+		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(n->dev);
 		if (!mlxsw_sp_port)
 			return NOTIFY_DONE;
 
-		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
-		if (WARN_ON(!neigh_entry)) {
+		neigh_work = kzalloc(sizeof(*neigh_work), GFP_ATOMIC);
+		if (!neigh_work) {
 			mlxsw_sp_port_dev_put(mlxsw_sp_port);
-			return NOTIFY_DONE;
+			return NOTIFY_BAD;
 		}
-		neigh_entry->mlxsw_sp_port = mlxsw_sp_port;
+
+		INIT_WORK(&neigh_work->work, mlxsw_sp_router_neigh_event_work);
+		neigh_work->mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+		neigh_work->n = n;
 
 		/* Take a reference to ensure the neighbour won't be
 		 * destructed until we drop the reference in delayed
 		 * work.
 		 */
 		neigh_clone(n);
-		if (!mlxsw_core_schedule_work(&neigh_entry->work)) {
-			neigh_release(n);
-			mlxsw_sp_port_dev_put(mlxsw_sp_port);
-		}
+		mlxsw_core_schedule_work(&neigh_work->work);
+		mlxsw_sp_port_dev_put(mlxsw_sp_port);
 		break;
 	}
 
@@ -1334,14 +1337,11 @@ mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_nexthop *nh;
 
-	/* Take RTNL mutex here to prevent lists from changes */
-	rtnl_lock();
 	list_for_each_entry(nh, &neigh_entry->nexthop_list,
 			    neigh_list_node) {
 		__mlxsw_sp_nexthop_neigh_update(nh, removing);
 		mlxsw_sp_nexthop_group_refresh(mlxsw_sp, nh->nh_grp);
 	}
-	rtnl_unlock();
 }
 
 static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
@@ -1368,8 +1368,11 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	}
 	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
 	if (!neigh_entry) {
-		neigh_release(n);
-		return -EINVAL;
+		neigh_entry = mlxsw_sp_neigh_entry_create(mlxsw_sp, n);
+		if (IS_ERR(neigh_entry)) {
+			neigh_release(n);
+			return -EINVAL;
+		}
 	}
 
 	/* If that is the first nexthop connected to that neigh, add to
@@ -1395,6 +1398,7 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 				  struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
+	struct neighbour *n = neigh_entry->key.n;
 
 	__mlxsw_sp_nexthop_neigh_update(nh, true);
 	list_del(&nh->neigh_list_node);
@@ -1405,7 +1409,10 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 	if (list_empty(&nh->neigh_entry->nexthop_list))
 		list_del(&nh->neigh_entry->nexthop_neighs_list_node);
 
-	neigh_release(neigh_entry->key.n);
+	if (!neigh_entry->connected && list_empty(&neigh_entry->nexthop_list))
+		mlxsw_sp_neigh_entry_destroy(mlxsw_sp, neigh_entry);
+
+	neigh_release(n);
 }
 
 static struct mlxsw_sp_nexthop_group *
-- 
2.7.4
