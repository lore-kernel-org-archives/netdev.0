From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/7] mlxsw: spectrum_router: Add support for route append
Date: Thu,  9 Feb 2017 10:28:43 +0100
Message-ID: <1486632524-5588-7-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35487 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752487AbdBIJfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:35:30 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so11315326wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:35:19 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a new route is appended, it's placed after existing routes sharing
the same parameters (prefix, length, table ID, TOS and priority).

While the device supports only one route with the same prefix and length
in a single table, it's important to correctly place the appended route
in the driver's cache, as when a route is deleted the next one is
programmed into the device.

Following the reception of an ENTRY_APPEND notification, resolve the
FIB node corresponding to the prefix and length and correctly place the
new entry in its entry list.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 43 +++++++++++++++++++---
 1 file changed, 37 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7c55df9..d98f039 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2105,14 +2105,38 @@ mlxsw_sp_fib4_node_entry_find(const struct mlxsw_sp_fib_node *fib_node,
 	return NULL;
 }
 
+static int mlxsw_sp_fib4_node_list_append(struct mlxsw_sp_fib_entry *fib_entry,
+					  struct mlxsw_sp_fib_entry *new_entry)
+{
+	struct mlxsw_sp_fib_node *fib_node;
+
+	if (WARN_ON(!fib_entry))
+		return -EINVAL;
+
+	fib_node = fib_entry->fib_node;
+	list_for_each_entry_from(fib_entry, &fib_node->entry_list, list) {
+		if (fib_entry->params.tb_id != new_entry->params.tb_id ||
+		    fib_entry->params.tos != new_entry->params.tos ||
+		    fib_entry->params.prio != new_entry->params.prio)
+			break;
+	}
+
+	list_add_tail(&new_entry->list, &fib_entry->list);
+	return 0;
+}
+
 static int
 mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib_node *fib_node,
-			       struct mlxsw_sp_fib_entry *new_entry)
+			       struct mlxsw_sp_fib_entry *new_entry,
+			       bool append)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 
 	fib_entry = mlxsw_sp_fib4_node_entry_find(fib_node, &new_entry->params);
 
+	if (append)
+		return mlxsw_sp_fib4_node_list_append(fib_entry, new_entry);
+
 	if (fib_entry) {
 		list_add_tail(&new_entry->list, &fib_entry->list);
 	} else {
@@ -2182,12 +2206,13 @@ mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
 }
 
 static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
-					 struct mlxsw_sp_fib_entry *fib_entry)
+					 struct mlxsw_sp_fib_entry *fib_entry,
+					 bool append)
 {
 	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
 	int err;
 
-	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib_entry);
+	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib_entry, append);
 	if (err)
 		return err;
 
@@ -2217,7 +2242,8 @@ mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
 
 static int
 mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
-			 const struct fib_entry_notifier_info *fen_info)
+			 const struct fib_entry_notifier_info *fen_info,
+			 bool append)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_node *fib_node;
@@ -2239,7 +2265,7 @@ mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
 		goto err_fib4_entry_create;
 	}
 
-	err = mlxsw_sp_fib4_node_entry_link(mlxsw_sp, fib_entry);
+	err = mlxsw_sp_fib4_node_entry_link(mlxsw_sp, fib_entry, append);
 	if (err) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to link FIB entry to node\n");
 		goto err_fib4_node_entry_link;
@@ -2453,13 +2479,17 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	struct mlxsw_sp_fib_event_work *fib_work =
 		container_of(work, struct mlxsw_sp_fib_event_work, work);
 	struct mlxsw_sp *mlxsw_sp = fib_work->mlxsw_sp;
+	bool append;
 	int err;
 
 	/* Protect internal structures from changes */
 	rtnl_lock();
 	switch (fib_work->event) {
+	case FIB_EVENT_ENTRY_APPEND: /* fall through */
 	case FIB_EVENT_ENTRY_ADD:
-		err = mlxsw_sp_router_fib4_add(mlxsw_sp, &fib_work->fen_info);
+		append = fib_work->event == FIB_EVENT_ENTRY_APPEND;
+		err = mlxsw_sp_router_fib4_add(mlxsw_sp, &fib_work->fen_info,
+					       append);
 		if (err)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		fib_info_put(fib_work->fen_info.fi);
@@ -2503,6 +2533,7 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	fib_work->event = event;
 
 	switch (event) {
+	case FIB_EVENT_ENTRY_APPEND: /* fall through */
 	case FIB_EVENT_ENTRY_ADD: /* fall through */
 	case FIB_EVENT_ENTRY_DEL:
 		memcpy(&fib_work->fen_info, ptr, sizeof(fib_work->fen_info));
-- 
2.7.4
