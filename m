From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum: Add ability to query KVDL allocation size
Date: Sun, 22 Oct 2017 23:11:45 +0200
Message-ID: <20171022211150.2567-4-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:55238 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932133AbdJVVLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:55 -0400
Received: by mail-wr0-f193.google.com with SMTP id o44so15477251wrf.11
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:54 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The current KVDL allocation API allows the user to specify the requested
number of entries, but the user has no way of knowing how many entries
were actually allocated.

This works because existing users (e.g., router) request the exact
number they end up using. With the introduction of large adjacency
groups, this will change, as the router will have the ability to choose
from several allocation sizes, where larger allocations provide higher
accuracy with respect to requested weights and better resilience against
nexthop failures.

One option is to have the router try several allocations of descending
size until one succeeds, but a better way is to simply allow it to query
the actual allocation size and then size its request accordingly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h      |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c | 15 +++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 035c753..78ff20d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -415,6 +415,9 @@ void mlxsw_sp_kvdl_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
 			u32 *p_entry_index);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
+int mlxsw_sp_kvdl_alloc_size_query(struct mlxsw_sp *mlxsw_sp,
+				   unsigned int entry_count,
+				   unsigned int *p_alloc_size);
 
 struct mlxsw_sp_acl_rule_info {
 	unsigned int priority;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
index 5125375..266b3af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
@@ -164,6 +164,21 @@ void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index)
 	mlxsw_sp_kvdl_part_free(part, entry_index);
 }
 
+int mlxsw_sp_kvdl_alloc_size_query(struct mlxsw_sp *mlxsw_sp,
+				   unsigned int entry_count,
+				   unsigned int *p_alloc_size)
+{
+	struct mlxsw_sp_kvdl_part *part;
+
+	part = mlxsw_sp_kvdl_alloc_size_part(mlxsw_sp->kvdl, entry_count);
+	if (IS_ERR(part))
+		return PTR_ERR(part);
+
+	*p_alloc_size = part->info->alloc_size;
+
+	return 0;
+}
+
 static const struct mlxsw_sp_kvdl_part_info kvdl_parts_info[] = {
 	{
 		.part_index	= 0,
-- 
2.9.5
