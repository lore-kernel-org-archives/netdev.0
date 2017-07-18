From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/22] mlxsw: spectrum_router: Don't create FIB node during lookup
Date: Tue, 18 Jul 2017 10:10:20 +0200
Message-ID: <20170718081030.2781-13-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35671 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdGRIKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:53 -0400
Received: by mail-wr0-f196.google.com with SMTP id a10so2871571wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:52 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When looking up a FIB entry we shouldn't create the FIB node where it's
supposed to be linked in case the node doesn't already exist.

Instead, lookup the node and fail if it doesn't exist.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 36f2b68..da8590b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2314,8 +2314,8 @@ static void mlxsw_sp_fib4_entry_destroy(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_fib_node *
-mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
-		       const struct fib_entry_notifier_info *fen_info);
+mlxsw_sp_fib_node_lookup(struct mlxsw_sp_fib *fib, const void *addr,
+			 size_t addr_len, unsigned char prefix_len);
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib4_entry_lookup(struct mlxsw_sp *mlxsw_sp,
@@ -2323,9 +2323,18 @@ mlxsw_sp_fib4_entry_lookup(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_node *fib_node;
+	struct mlxsw_sp_fib *fib;
+	struct mlxsw_sp_vr *vr;
 
-	fib_node = mlxsw_sp_fib4_node_get(mlxsw_sp, fen_info);
-	if (IS_ERR(fib_node))
+	vr = mlxsw_sp_vr_find(mlxsw_sp, fen_info->tb_id);
+	if (!vr)
+		return NULL;
+	fib = mlxsw_sp_vr_fib(vr, MLXSW_SP_L3_PROTO_IPV4);
+
+	fib_node = mlxsw_sp_fib_node_lookup(fib, &fen_info->dst,
+					    sizeof(fen_info->dst),
+					    fen_info->dst_len);
+	if (!fib_node)
 		return NULL;
 
 	list_for_each_entry(fib_entry, &fib_node->entry_list, list) {
-- 
2.9.3
