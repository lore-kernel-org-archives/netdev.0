From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] mlxsw: spectrum_router: Prepare for large adjacency groups
Date: Sun, 22 Oct 2017 23:11:47 +0200
Message-ID: <20171022211150.2567-6-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:43482 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbdJVVL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:56 -0400
Received: by mail-wr0-f193.google.com with SMTP id w105so6171641wrc.0
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:56 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The device has certain restrictions regarding the size of an adjacency
group.

Have the router determine the size of the adjacency group according to
available KVDL allocation sizes and these restrictions.

This was not needed until now since only allocations of up 32 entries
were supported and these are all valid sizes for an adjacency group.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 58 ++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8cd422d..68ce549 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2708,6 +2708,59 @@ mlxsw_sp_nexthop_fib_entries_refresh(struct mlxsw_sp_nexthop_group *nh_grp)
 	}
 }
 
+static void mlxsw_sp_adj_grp_size_round_up(u16 *p_adj_grp_size)
+{
+	/* Valid sizes for an adjacency group are:
+	 * 1-64, 512, 1024, 2048 and 4096.
+	 */
+	if (*p_adj_grp_size <= 64)
+		return;
+	else if (*p_adj_grp_size <= 512)
+		*p_adj_grp_size = 512;
+	else if (*p_adj_grp_size <= 1024)
+		*p_adj_grp_size = 1024;
+	else if (*p_adj_grp_size <= 2048)
+		*p_adj_grp_size = 2048;
+	else
+		*p_adj_grp_size = 4096;
+}
+
+static void mlxsw_sp_adj_grp_size_round_down(u16 *p_adj_grp_size,
+					     unsigned int alloc_size)
+{
+	if (alloc_size >= 4096)
+		*p_adj_grp_size = 4096;
+	else if (alloc_size >= 2048)
+		*p_adj_grp_size = 2048;
+	else if (alloc_size >= 1024)
+		*p_adj_grp_size = 1024;
+	else if (alloc_size >= 512)
+		*p_adj_grp_size = 512;
+}
+
+static int mlxsw_sp_fix_adj_grp_size(struct mlxsw_sp *mlxsw_sp,
+				     u16 *p_adj_grp_size)
+{
+	unsigned int alloc_size;
+	int err;
+
+	/* Round up the requested group size to the next size supported
+	 * by the device and make sure the request can be satisfied.
+	 */
+	mlxsw_sp_adj_grp_size_round_up(p_adj_grp_size);
+	err = mlxsw_sp_kvdl_alloc_size_query(mlxsw_sp, *p_adj_grp_size,
+					     &alloc_size);
+	if (err)
+		return err;
+	/* It is possible the allocation results in more allocated
+	 * entries than requested. Try to use as much of them as
+	 * possible.
+	 */
+	mlxsw_sp_adj_grp_size_round_down(p_adj_grp_size, alloc_size);
+
+	return 0;
+}
+
 static void
 mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_nexthop_group *nh_grp)
@@ -2755,6 +2808,11 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 		 */
 		goto set_trap;
 
+	err = mlxsw_sp_fix_adj_grp_size(mlxsw_sp, &ecmp_size);
+	if (err)
+		/* No valid allocation size available. */
+		goto set_trap;
+
 	err = mlxsw_sp_kvdl_alloc(mlxsw_sp, ecmp_size, &adj_index);
 	if (err) {
 		/* We ran out of KVD linear space, just set the
-- 
2.9.5
