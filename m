From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/15] mlxsw: spectrum_router: Add gateway indication to nexthop group
Date: Wed,  8 Feb 2017 11:16:32 +0100
Message-ID: <1486549002-2056-6-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34866 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752949AbdBHKQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:50 -0500
Received: by mail-wr0-f193.google.com with SMTP id o16so8291315wra.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:50 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The next patch is going to generalize the way in which we store routes.
Instead of attaching a nexthop group only to gatewayed routes, one will
be attached to each route, in a similar way to the way the FIB code
stores its routes.

The above means that any function operating on a nexthop group cannot
assume the group represents only gatewayed nexthops. One such function
is the one that refreshes a nexthop group and updates the adjacency
table following nexthop changes.

For a nexthop group that doesn't represent any gateways this function
would essentially be a NOP, but it would be useful if it did update the
action associated with any route using it. This will allow us to later
consolidate code paths when a nexthop changes following NH_{ADD,DEL}
events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index cad7e9a..110a7bb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1121,7 +1121,8 @@ struct mlxsw_sp_nexthop_group {
 	struct rhash_head ht_node;
 	struct list_head fib_list; /* list of fib entries that use this group */
 	struct mlxsw_sp_nexthop_group_key key;
-	u8 adj_index_valid:1;
+	u8 adj_index_valid:1,
+	   gateway:1; /* routes using the group use a gateway */
 	u32 adj_index;
 	u16 ecmp_size;
 	u16 count;
@@ -1292,6 +1293,11 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 	int i;
 	int err;
 
+	if (!nh_grp->gateway) {
+		mlxsw_sp_nexthop_fib_entries_update(mlxsw_sp, nh_grp);
+		return;
+	}
+
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
 
@@ -1505,6 +1511,7 @@ mlxsw_sp_nexthop_group_create(struct mlxsw_sp *mlxsw_sp, struct fib_info *fi)
 	if (!nh_grp)
 		return ERR_PTR(-ENOMEM);
 	INIT_LIST_HEAD(&nh_grp->fib_list);
+	nh_grp->gateway = fi->fib_nh->nh_scope == RT_SCOPE_LINK;
 	nh_grp->count = fi->fib_nhs;
 	nh_grp->key.fi = fi;
 	for (i = 0; i < nh_grp->count; i++) {
-- 
2.7.4
