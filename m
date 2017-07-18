From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/22] mlxsw: spectrum_router: Don't assume neighbour type
Date: Tue, 18 Jul 2017 10:10:19 +0200
Message-ID: <20170718081030.2781-12-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35660 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdGRIKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:52 -0400
Received: by mail-wr0-f194.google.com with SMTP id a10so2871457wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:51 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Thankfully, the neighbour subsystem is agnostic to the upper protocol
and used by both IPv4 and IPv6. By removing assumptions regarding the
neighbour type we can thus re-use much of the neighbour-related code for
both IPv4 and IPv6.

For each nexthop, store its gateway IP and for nexthop group store the
neighbour table used by its nexthops.

Use this information throughout the code and remove assumption about the
neighbour type.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index cb797fb..36f2b68 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1437,6 +1437,7 @@ struct mlxsw_sp_nexthop {
 						*/
 	struct rhash_head ht_node;
 	struct mlxsw_sp_nexthop_key key;
+	unsigned char gw_addr[sizeof(struct in6_addr)];
 	struct mlxsw_sp_rif *rif;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
@@ -1457,6 +1458,7 @@ struct mlxsw_sp_nexthop_group_key {
 struct mlxsw_sp_nexthop_group {
 	struct rhash_head ht_node;
 	struct list_head fib_list; /* list of fib entries that use this group */
+	struct neigh_table *neigh_tbl;
 	struct mlxsw_sp_nexthop_group_key key;
 	u8 adj_index_valid:1,
 	   gateway:1; /* routes using the group use a gateway */
@@ -1774,7 +1776,6 @@ static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 				       struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry;
-	struct fib_nh *fib_nh = nh->key.fib_nh;
 	struct neighbour *n;
 	u8 nud_state, dead;
 	int err;
@@ -1787,9 +1788,10 @@ static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 	 * The reference is taken either in neigh_lookup() or
 	 * in neigh_create() in case n is not found.
 	 */
-	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, fib_nh->nh_dev);
+	n = neigh_lookup(nh->nh_grp->neigh_tbl, &nh->gw_addr, nh->rif->dev);
 	if (!n) {
-		n = neigh_create(&arp_tbl, &fib_nh->nh_gw, fib_nh->nh_dev);
+		n = neigh_create(nh->nh_grp->neigh_tbl, &nh->gw_addr,
+				 nh->rif->dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 		neigh_event_send(n, NULL);
@@ -1863,6 +1865,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 
 	nh->nh_grp = nh_grp;
 	nh->key.fib_nh = fib_nh;
+	memcpy(&nh->gw_addr, &fib_nh->nh_gw, sizeof(fib_nh->nh_gw));
 	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
 	if (err)
 		return err;
@@ -1961,6 +1964,8 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 	if (!nh_grp)
 		return ERR_PTR(-ENOMEM);
 	INIT_LIST_HEAD(&nh_grp->fib_list);
+	nh_grp->neigh_tbl = &arp_tbl;
+
 	nh_grp->gateway = fi->fib_nh->nh_scope == RT_SCOPE_LINK;
 	nh_grp->count = fi->fib_nhs;
 	nh_grp->key.fi = fi;
-- 
2.9.3
