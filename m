From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_router: Fix handling of neighbour structure
Date: Thu, 10 Nov 2016 12:00:48 +0100
Message-ID: <1478775649-3386-2-git-send-email-jiri@resnulli.us>
References: <1478775649-3386-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36201 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754542AbcKJLAy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:00:54 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so688019wma.3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:00:53 -0800 (PST)
In-Reply-To: <1478775649-3386-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

__neigh_create function works in a different way than assumed.
It passes "n" as a parameter to ndo_neigh_construct. But this "n" might
be destroyed right away before __neigh_create() returns in case there is
already another neighbour struct in the hashtable with the same dev and
primary key. That is not expected by mlxsw_sp_router_neigh_construct()
and the stored "n" points to freed memory, eventually leading to crash.

Fix this by doing tight 1:1 coupling between neighbour struct and
internal driver neigh_entry. That allows to narrow down the key in
internal driver hashtable to do lookups by "n" only.

Fixes: 6cf3c971dc84 ("mlxsw: spectrum_router: Add private neigh table")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 95 ++++++++--------------
 1 file changed, 34 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4573da2..2863012 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -600,15 +600,13 @@ static void mlxsw_sp_vrs_fini(struct mlxsw_sp *mlxsw_sp)
 }
 
 struct mlxsw_sp_neigh_key {
-	unsigned char addr[sizeof(struct in6_addr)];
-	struct net_device *dev;
+	struct neighbour *n;
 };
 
 struct mlxsw_sp_neigh_entry {
 	struct rhash_head ht_node;
 	struct mlxsw_sp_neigh_key key;
 	u16 rif;
-	struct neighbour *n;
 	bool offloaded;
 	struct delayed_work dw;
 	struct mlxsw_sp_port *mlxsw_sp_port;
@@ -646,19 +644,15 @@ mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
 static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work);
 
 static struct mlxsw_sp_neigh_entry *
-mlxsw_sp_neigh_entry_create(const void *addr, size_t addr_len,
-			    struct net_device *dev, u16 rif,
-			    struct neighbour *n)
+mlxsw_sp_neigh_entry_create(struct neighbour *n, u16 rif)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 
 	neigh_entry = kzalloc(sizeof(*neigh_entry), GFP_ATOMIC);
 	if (!neigh_entry)
 		return NULL;
-	memcpy(neigh_entry->key.addr, addr, addr_len);
-	neigh_entry->key.dev = dev;
+	neigh_entry->key.n = n;
 	neigh_entry->rif = rif;
-	neigh_entry->n = n;
 	INIT_DELAYED_WORK(&neigh_entry->dw, mlxsw_sp_router_neigh_update_hw);
 	INIT_LIST_HEAD(&neigh_entry->nexthop_list);
 	return neigh_entry;
@@ -671,13 +665,11 @@ mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp_neigh_entry *neigh_entry)
 }
 
 static struct mlxsw_sp_neigh_entry *
-mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, const void *addr,
-			    size_t addr_len, struct net_device *dev)
+mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 {
-	struct mlxsw_sp_neigh_key key = {{ 0 } };
+	struct mlxsw_sp_neigh_key key;
 
-	memcpy(key.addr, addr, addr_len);
-	key.dev = dev;
+	key.n = n;
 	return rhashtable_lookup_fast(&mlxsw_sp->router.neigh_ht,
 				      &key, mlxsw_sp_neigh_ht_params);
 }
@@ -689,26 +681,20 @@ int mlxsw_sp_router_neigh_construct(struct net_device *dev,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct mlxsw_sp_rif *r;
-	u32 dip;
 	int err;
 
 	if (n->tbl != &arp_tbl)
 		return 0;
 
-	dip = ntohl(*((__be32 *) n->primary_key));
-	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &dip, sizeof(dip),
-						  n->dev);
-	if (neigh_entry) {
-		WARN_ON(neigh_entry->n != n);
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
+	if (neigh_entry)
 		return 0;
-	}
 
 	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, n->dev);
 	if (WARN_ON(!r))
 		return -EINVAL;
 
-	neigh_entry = mlxsw_sp_neigh_entry_create(&dip, sizeof(dip), n->dev,
-						  r->rif, n);
+	neigh_entry = mlxsw_sp_neigh_entry_create(n, r->rif);
 	if (!neigh_entry)
 		return -ENOMEM;
 	err = mlxsw_sp_neigh_entry_insert(mlxsw_sp, neigh_entry);
@@ -727,14 +713,11 @@ void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	u32 dip;
 
 	if (n->tbl != &arp_tbl)
 		return;
 
-	dip = ntohl(*((__be32 *) n->primary_key));
-	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &dip, sizeof(dip),
-						  n->dev);
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
 	if (!neigh_entry)
 		return;
 	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
@@ -862,7 +845,7 @@ static void mlxsw_sp_router_neighs_update_nh(struct mlxsw_sp *mlxsw_sp)
 		 * is active regardless of the traffic.
 		 */
 		if (!list_empty(&neigh_entry->nexthop_list))
-			neigh_event_send(neigh_entry->n, NULL);
+			neigh_event_send(neigh_entry->key.n, NULL);
 	}
 	rtnl_unlock();
 }
@@ -908,9 +891,9 @@ static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
 	rtnl_lock();
 	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
 			    nexthop_neighs_list_node) {
-		if (!(neigh_entry->n->nud_state & NUD_VALID) &&
+		if (!(neigh_entry->key.n->nud_state & NUD_VALID) &&
 		    !list_empty(&neigh_entry->nexthop_list))
-			neigh_event_send(neigh_entry->n, NULL);
+			neigh_event_send(neigh_entry->key.n, NULL);
 	}
 	rtnl_unlock();
 
@@ -927,7 +910,7 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry =
 		container_of(work, struct mlxsw_sp_neigh_entry, dw.work);
-	struct neighbour *n = neigh_entry->n;
+	struct neighbour *n = neigh_entry->key.n;
 	struct mlxsw_sp_port *mlxsw_sp_port = neigh_entry->mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char rauht_pl[MLXSW_REG_RAUHT_LEN];
@@ -1030,11 +1013,8 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 
 		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 		dip = ntohl(*((__be32 *) n->primary_key));
-		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp,
-							  &dip,
-							  sizeof(__be32),
-							  dev);
-		if (WARN_ON(!neigh_entry) || WARN_ON(neigh_entry->n != n)) {
+		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
+		if (WARN_ON(!neigh_entry)) {
 			mlxsw_sp_port_dev_put(mlxsw_sp_port);
 			return NOTIFY_DONE;
 		}
@@ -1343,33 +1323,26 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 				 struct fib_nh *fib_nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	u32 gwip = ntohl(fib_nh->nh_gw);
 	struct net_device *dev = fib_nh->nh_dev;
 	struct neighbour *n;
 	u8 nud_state;
 
-	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &gwip,
-						  sizeof(gwip), dev);
-	if (!neigh_entry) {
-		__be32 gwipn = htonl(gwip);
-
-		n = neigh_create(&arp_tbl, &gwipn, dev);
+	/* Take a reference of neigh here ensuring that neigh would
+	 * not be detructed before the nexthop entry is finished.
+	 * The reference is taken either in neigh_lookup() or
+	 * in neith_create() in case n is not found.
+	 */
+	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, dev);
+	if (!n) {
+		n = neigh_create(&arp_tbl, &fib_nh->nh_gw, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 		neigh_event_send(n, NULL);
-		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &gwip,
-							  sizeof(gwip), dev);
-		if (!neigh_entry) {
-			neigh_release(n);
-			return -EINVAL;
-		}
-	} else {
-		/* Take a reference of neigh here ensuring that neigh would
-		 * not be detructed before the nexthop entry is finished.
-		 * The second branch takes the reference in neith_create()
-		 */
-		n = neigh_entry->n;
-		neigh_clone(n);
+	}
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
+	if (!neigh_entry) {
+		neigh_release(n);
+		return -EINVAL;
 	}
 
 	/* If that is the first nexthop connected to that neigh, add to
@@ -1403,7 +1376,7 @@ static void mlxsw_sp_nexthop_fini(struct mlxsw_sp *mlxsw_sp,
 	if (list_empty(&nh->neigh_entry->nexthop_list))
 		list_del(&nh->neigh_entry->nexthop_neighs_list_node);
 
-	neigh_release(neigh_entry->n);
+	neigh_release(neigh_entry->key.n);
 }
 
 static struct mlxsw_sp_nexthop_group *
@@ -1463,11 +1436,11 @@ static bool mlxsw_sp_nexthop_match(struct mlxsw_sp_nexthop *nh,
 
 	for (i = 0; i < fi->fib_nhs; i++) {
 		struct fib_nh *fib_nh = &fi->fib_nh[i];
-		u32 gwip = ntohl(fib_nh->nh_gw);
+		struct neighbour *n = nh->neigh_entry->key.n;
 
-		if (memcmp(nh->neigh_entry->key.addr,
-			   &gwip, sizeof(u32)) == 0 &&
-		    nh->neigh_entry->key.dev == fib_nh->nh_dev)
+		if (memcmp(n->primary_key, &fib_nh->nh_gw,
+			   sizeof(fib_nh->nh_gw)) == 0 &&
+		    n->dev == fib_nh->nh_dev)
 			return true;
 	}
 	return false;
-- 
2.7.4
