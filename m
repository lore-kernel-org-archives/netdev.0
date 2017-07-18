From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 20/22] mlxsw: spectrum_router: Drop unnecessary parameter
Date: Tue, 18 Jul 2017 10:10:28 +0200
Message-ID: <20170718081030.2781-21-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34480 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdGRILE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:11:04 -0400
Received: by mail-wr0-f193.google.com with SMTP id w4so2854695wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:11:04 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Functions that take as argument a FIB entry don't need to take FIB node
as well, as it can be extracted from the entry.

Remove unnecessary FIB node parameter.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 32 +++++++++-------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 5d787c1..c8c8187 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2627,10 +2627,10 @@ mlxsw_sp_fib4_node_list_append(struct mlxsw_sp_fib4_entry *fib4_entry,
 }
 
 static int
-mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib_node *fib_node,
-			       struct mlxsw_sp_fib4_entry *new4_entry,
+mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib4_entry *new4_entry,
 			       bool replace, bool append)
 {
+	struct mlxsw_sp_fib_node *fib_node = new4_entry->common.fib_node;
 	struct mlxsw_sp_fib4_entry *fib4_entry;
 
 	fib4_entry = mlxsw_sp_fib4_node_entry_find(fib_node, new4_entry);
@@ -2672,11 +2672,11 @@ mlxsw_sp_fib4_node_list_remove(struct mlxsw_sp_fib4_entry *fib4_entry)
 	list_del(&fib4_entry->common.list);
 }
 
-static int
-mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
-			     const struct mlxsw_sp_fib_node *fib_node,
-			     struct mlxsw_sp_fib_entry *fib_entry)
+static int mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry)
 {
+	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
+
 	if (!mlxsw_sp_fib_node_entry_is_first(fib_node, fib_entry))
 		return 0;
 
@@ -2693,11 +2693,11 @@ mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
 	return mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
 }
 
-static void
-mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
-			     const struct mlxsw_sp_fib_node *fib_node,
-			     struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_fib_entry *fib_entry)
 {
+	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
+
 	if (!mlxsw_sp_fib_node_entry_is_first(fib_node, fib_entry))
 		return;
 
@@ -2718,17 +2718,13 @@ static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_fib4_entry *fib4_entry,
 					 bool replace, bool append)
 {
-	struct mlxsw_sp_fib_node *fib_node;
 	int err;
 
-	fib_node = fib4_entry->common.fib_node;
-	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib4_entry, replace,
-					     append);
+	err = mlxsw_sp_fib4_node_list_insert(fib4_entry, replace, append);
 	if (err)
 		return err;
 
-	err = mlxsw_sp_fib4_node_entry_add(mlxsw_sp, fib_node,
-					   &fib4_entry->common);
+	err = mlxsw_sp_fib4_node_entry_add(mlxsw_sp, &fib4_entry->common);
 	if (err)
 		goto err_fib4_node_entry_add;
 
@@ -2743,9 +2739,7 @@ static void
 mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
 				struct mlxsw_sp_fib4_entry *fib4_entry)
 {
-	struct mlxsw_sp_fib_node *fib_node = fib4_entry->common.fib_node;
-
-	mlxsw_sp_fib4_node_entry_del(mlxsw_sp, fib_node, &fib4_entry->common);
+	mlxsw_sp_fib4_node_entry_del(mlxsw_sp, &fib4_entry->common);
 	mlxsw_sp_fib4_node_list_remove(fib4_entry);
 }
 
-- 
2.9.3
