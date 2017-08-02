From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] mlxsw: spectrum_router: Refresh offload indication upon group refresh
Date: Wed,  2 Aug 2017 09:56:05 +0200
Message-ID: <20170802075606.1090-6-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33951 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdHBH4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:17 -0400
Received: by mail-wr0-f195.google.com with SMTP id o33so3044724wrb.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:17 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Now that we provide offload indication using the nexthop's flags we must
refresh the offload indication whenever the offload state within the
group changes.

This didn't matter until now, as offload indication was provided using
the FIB info flags and multipath routes were marked as offloaded as long
as one of the nexthops was offloaded.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 40aecbc..2f03c7e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1653,6 +1653,24 @@ mlxsw_sp_nexthop_fib_entries_update(struct mlxsw_sp *mlxsw_sp,
 }
 
 static void
+mlxsw_sp_fib_entry_offload_refresh(struct mlxsw_sp_fib_entry *fib_entry,
+				   enum mlxsw_reg_ralue_op op, int err);
+
+static void
+mlxsw_sp_nexthop_fib_entries_refresh(struct mlxsw_sp_nexthop_group *nh_grp)
+{
+	enum mlxsw_reg_ralue_op op = MLXSW_REG_RALUE_OP_WRITE_WRITE;
+	struct mlxsw_sp_fib_entry *fib_entry;
+
+	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
+		if (!mlxsw_sp_fib_node_entry_is_first(fib_entry->fib_node,
+						      fib_entry))
+			continue;
+		mlxsw_sp_fib_entry_offload_refresh(fib_entry, op, 0);
+	}
+}
+
+static void
 mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 			       struct mlxsw_sp_nexthop_group *nh_grp)
 {
@@ -1739,6 +1757,10 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to mass-update adjacency index for nexthop group.\n");
 		goto set_trap;
 	}
+
+	/* Offload state within the group changed, so update the flags. */
+	mlxsw_sp_nexthop_fib_entries_refresh(nh_grp);
+
 	return;
 
 set_trap:
-- 
2.9.3
