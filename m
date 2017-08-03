From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 19/21] mlxsw: spectrum_router: Add support for route replace
Date: Thu,  3 Aug 2017 13:28:29 +0200
Message-ID: <20170803112831.1831-20-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37022 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdHCL3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so1808322wmt.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:09 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case we got a replace event, then the replaced route must exist. If
the route isn't capable of multipath, then replace first matching
non-multipath capable route.

If the route is capable of multipath and matching multipath capable
route is found, then replace it. Otherwise, replace first matching
non-multipath capable route.

The new route is inserted before the replaced one. In case the replaced
route is currently offloaded, then it's overwritten in the device's table
by the new route and later deleted, thus not impacting routed traffic.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 63 +++++++++++++++++-----
 1 file changed, 49 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2345c00..cded8e8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3035,11 +3035,11 @@ mlxsw_sp_fib6_entry_rt(const struct mlxsw_sp_fib6_entry *fib6_entry)
 
 static struct mlxsw_sp_fib6_entry *
 mlxsw_sp_fib6_node_mp_entry_find(const struct mlxsw_sp_fib_node *fib_node,
-				 const struct rt6_info *nrt)
+				 const struct rt6_info *nrt, bool replace)
 {
 	struct mlxsw_sp_fib6_entry *fib6_entry;
 
-	if (!mlxsw_sp_fib6_rt_can_mp(nrt))
+	if (!mlxsw_sp_fib6_rt_can_mp(nrt) || replace)
 		return NULL;
 
 	list_for_each_entry(fib6_entry, &fib_node->entry_list, common.list) {
@@ -3371,9 +3371,9 @@ static void mlxsw_sp_fib6_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 
 static struct mlxsw_sp_fib6_entry *
 mlxsw_sp_fib6_node_entry_find(const struct mlxsw_sp_fib_node *fib_node,
-			      const struct rt6_info *nrt)
+			      const struct rt6_info *nrt, bool replace)
 {
-	struct mlxsw_sp_fib6_entry *fib6_entry;
+	struct mlxsw_sp_fib6_entry *fib6_entry, *fallback = NULL;
 
 	list_for_each_entry(fib6_entry, &fib_node->entry_list, common.list) {
 		struct rt6_info *rt = mlxsw_sp_fib6_entry_rt(fib6_entry);
@@ -3382,21 +3382,32 @@ mlxsw_sp_fib6_node_entry_find(const struct mlxsw_sp_fib_node *fib_node,
 			continue;
 		if (rt->rt6i_table->tb6_id != nrt->rt6i_table->tb6_id)
 			break;
+		if (replace && rt->rt6i_metric == nrt->rt6i_metric) {
+			if (mlxsw_sp_fib6_rt_can_mp(rt) ==
+			    mlxsw_sp_fib6_rt_can_mp(nrt))
+				return fib6_entry;
+			if (mlxsw_sp_fib6_rt_can_mp(nrt))
+				fallback = fallback ?: fib6_entry;
+		}
 		if (rt->rt6i_metric > nrt->rt6i_metric)
-			return fib6_entry;
+			return fallback ?: fib6_entry;
 	}
 
-	return NULL;
+	return fallback;
 }
 
 static int
-mlxsw_sp_fib6_node_list_insert(struct mlxsw_sp_fib6_entry *new6_entry)
+mlxsw_sp_fib6_node_list_insert(struct mlxsw_sp_fib6_entry *new6_entry,
+			       bool replace)
 {
 	struct mlxsw_sp_fib_node *fib_node = new6_entry->common.fib_node;
 	struct rt6_info *nrt = mlxsw_sp_fib6_entry_rt(new6_entry);
 	struct mlxsw_sp_fib6_entry *fib6_entry;
 
-	fib6_entry = mlxsw_sp_fib6_node_entry_find(fib_node, nrt);
+	fib6_entry = mlxsw_sp_fib6_node_entry_find(fib_node, nrt, replace);
+
+	if (replace && WARN_ON(!fib6_entry))
+		return -EINVAL;
 
 	if (fib6_entry) {
 		list_add_tail(&new6_entry->common.list,
@@ -3430,11 +3441,12 @@ mlxsw_sp_fib6_node_list_remove(struct mlxsw_sp_fib6_entry *fib6_entry)
 }
 
 static int mlxsw_sp_fib6_node_entry_link(struct mlxsw_sp *mlxsw_sp,
-					 struct mlxsw_sp_fib6_entry *fib6_entry)
+					 struct mlxsw_sp_fib6_entry *fib6_entry,
+					 bool replace)
 {
 	int err;
 
-	err = mlxsw_sp_fib6_node_list_insert(fib6_entry);
+	err = mlxsw_sp_fib6_node_list_insert(fib6_entry, replace);
 	if (err)
 		return err;
 
@@ -3489,8 +3501,25 @@ mlxsw_sp_fib6_entry_lookup(struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
+static void mlxsw_sp_fib6_entry_replace(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib6_entry *fib6_entry,
+					bool replace)
+{
+	struct mlxsw_sp_fib_node *fib_node = fib6_entry->common.fib_node;
+	struct mlxsw_sp_fib6_entry *replaced;
+
+	if (!replace)
+		return;
+
+	replaced = list_next_entry(fib6_entry, common.list);
+
+	mlxsw_sp_fib6_node_entry_unlink(mlxsw_sp, replaced);
+	mlxsw_sp_fib6_entry_destroy(mlxsw_sp, replaced);
+	mlxsw_sp_fib_node_put(mlxsw_sp, fib_node);
+}
+
 static int mlxsw_sp_router_fib6_add(struct mlxsw_sp *mlxsw_sp,
-				    struct rt6_info *rt)
+				    struct rt6_info *rt, bool replace)
 {
 	struct mlxsw_sp_fib6_entry *fib6_entry;
 	struct mlxsw_sp_fib_node *fib_node;
@@ -3513,7 +3542,7 @@ static int mlxsw_sp_router_fib6_add(struct mlxsw_sp *mlxsw_sp,
 	/* Before creating a new entry, try to append route to an existing
 	 * multipath entry.
 	 */
-	fib6_entry = mlxsw_sp_fib6_node_mp_entry_find(fib_node, rt);
+	fib6_entry = mlxsw_sp_fib6_node_mp_entry_find(fib_node, rt, replace);
 	if (fib6_entry) {
 		err = mlxsw_sp_fib6_entry_nexthop_add(mlxsw_sp, fib6_entry, rt);
 		if (err)
@@ -3527,10 +3556,12 @@ static int mlxsw_sp_router_fib6_add(struct mlxsw_sp *mlxsw_sp,
 		goto err_fib6_entry_create;
 	}
 
-	err = mlxsw_sp_fib6_node_entry_link(mlxsw_sp, fib6_entry);
+	err = mlxsw_sp_fib6_node_entry_link(mlxsw_sp, fib6_entry, replace);
 	if (err)
 		goto err_fib6_node_entry_link;
 
+	mlxsw_sp_fib6_entry_replace(mlxsw_sp, fib6_entry, replace);
+
 	return 0;
 
 err_fib6_node_entry_link:
@@ -3795,13 +3826,16 @@ static void mlxsw_sp_router_fib6_event_work(struct work_struct *work)
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
 	struct fib_rule *rule;
+	bool replace;
 	int err;
 
 	rtnl_lock();
 	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_ADD:
+		replace = fib_work->event == FIB_EVENT_ENTRY_REPLACE;
 		err = mlxsw_sp_router_fib6_add(mlxsw_sp,
-					       fib_work->fen6_info.rt);
+					       fib_work->fen6_info.rt, replace);
 		if (err)
 			mlxsw_sp_router_fib_abort(mlxsw_sp);
 		mlxsw_sp_rt6_release(fib_work->fen6_info.rt);
@@ -3853,6 +3887,7 @@ static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
 	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_ADD: /* fall through */
 	case FIB_EVENT_ENTRY_DEL:
 		memcpy(&fib_work->fen6_info, info, sizeof(fib_work->fen6_info));
-- 
2.9.3
