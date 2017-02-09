From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] mlxsw: spectrum_router: Add support for route replace
Date: Thu,  9 Feb 2017 10:28:44 +0100
Message-ID: <1486632524-5588-8-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33300 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752225AbdBIJhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:37:48 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so1946980wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:37:47 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Upon the reception of an ENTRY_REPLACE notification, resolve the FIB
node corresponding to the prefix and length and insert the new route
before the first matching entry.

Since the notification also signals the deletion of the replaced route,
delete it from the driver's cache.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 44 ++++++++++++++++++----
 1 file changed, 37 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index d98f039..d7ac22d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2128,7 +2128,7 @@ static int mlxsw_sp_fib4_node_list_append(struct mlxsw_sp_fib_entry *fib_entry,
 static int
 mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib_node *fib_node,
 			       struct mlxsw_sp_fib_entry *new_entry,
-			       bool append)
+			       bool replace, bool append)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 
@@ -2136,7 +2136,12 @@ mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib_node *fib_node,
 
 	if (append)
 		return mlxsw_sp_fib4_node_list_append(fib_entry, new_entry);
+	if (replace && WARN_ON(!fib_entry))
+		return -EINVAL;
 
+	/* Insert new entry before replaced one, so that we can later
+	 * remove the second.
+	 */
 	if (fib_entry) {
 		list_add_tail(&new_entry->list, &fib_entry->list);
 	} else {
@@ -2207,12 +2212,13 @@ mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
 
 static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_fib_entry *fib_entry,
-					 bool append)
+					 bool replace, bool append)
 {
 	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
 	int err;
 
-	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib_entry, append);
+	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib_entry, replace,
+					     append);
 	if (err)
 		return err;
 
@@ -2240,10 +2246,28 @@ mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_fib4_node_list_remove(fib_entry);
 }
 
+static void mlxsw_sp_fib4_entry_replace(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry,
+					bool replace)
+{
+	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
+	struct mlxsw_sp_fib_entry *replaced;
+
+	if (!replace)
+		return;
+
+	/* We inserted the new entry before replaced one */
+	replaced = list_next_entry(fib_entry, list);
+
+	mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, replaced);
+	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, replaced);
+	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+}
+
 static int
 mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 			 const struct fib_entry_notifier_info *fen_info,
-			 bool append)
+			 bool replace, bool append)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_node *fib_node;
@@ -2265,12 +2289,15 @@ mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 		goto err_fib4_entry_create;
 	}
 
-	err = mlxsw_sp_fib4_node_entry_link(mlxsw_sp, fib_entry, append);
+	err = mlxsw_sp_fib4_node_entry_link(mlxsw_sp, fib_entry, replace,
+					    append);
 	if (err) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to link FIB entry to node\n");
 		goto err_fib4_node_entry_link;
 	}
 
+	mlxsw_sp_fib4_entry_replace(mlxsw_sp, fib_entry, replace);
+
 	return 0;
 
 err_fib4_node_entry_link:
@@ -2479,17 +2506,19 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
-	bool append;
+	bool replace, append;
 	int err;
 
 	/* Protect internal structures from changes */
 	rtnl_lock();
 	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_APPEND: /* fall through */
 	case FIB_EVENT_ENTRY_ADD:
+		replace = fib_work->event == FIB_EVENT_ENTRY_REPLACE;
 		append = fib_work->event == FIB_EVENT_ENTRY_APPEND;
 		err = mlxsw_sp_router_fib4_add(mlxsw_sp, &fib_work->fen_info,
-					       append);
+					       replace, append);
 		if (err)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		fib_info_put(fib_work->fen_info.fi);
@@ -2533,6 +2562,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	fib_work->event = event;
 
 	switch (event) {
+	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_APPEND: /* fall through */
 	case FIB_EVENT_ENTRY_ADD: /* fall through */
 	case FIB_EVENT_ENTRY_DEL:
-- 
2.7.4
