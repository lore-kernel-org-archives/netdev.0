From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_router: Don't offload routes next in list
Date: Fri, 21 Jul 2017 18:04:28 +0200
Message-ID: <20170721160428.23149-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35239 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752048AbdGUQEb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 12:04:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id m75so1146269wmb.2
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 09:04:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Each FIB node holds a linked list of routes sharing the same prefix and
length. In the case of IPv4 it's ordered according to table ID, metric
and TOS and only the first route in the list is actually programmed to
the device.

In case a gatewayed route is added somewhere in the list, then after its
nexthop group will be refreshed and become valid (due to the resolution
of its gateway), it'll mistakenly overwrite the existing entry.

Example:
192.168.200.0/24 dev enp3s0np3 scope link metric 1000 offload
192.168.200.0/24 via 192.168.100.1 dev enp3s0np3 metric 1000 offload

Both routes are marked as offloaded despite the fact only the first one
should actually be present in the device's table.

When refreshing the nexthop group, don't write the route to the device's
table unless it's the first in its node.

Fixes: 9aecce1c7d97 ("mlxsw: spectrum_router: Correctly handle identical routes")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 383fef5a..4b2e0fd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1512,6 +1512,10 @@ mlxsw_sp_nexthop_group_mac_update(struct mlxsw_sp *mlxsw_sp,
 static int mlxsw_sp_fib_entry_update(struct mlxsw_sp *mlxsw_sp,
 				     struct mlxsw_sp_fib_entry *fib_entry);
 
+static bool
+mlxsw_sp_fib_node_entry_is_first(const struct mlxsw_sp_fib_node *fib_node,
+				 const struct mlxsw_sp_fib_entry *fib_entry);
+
 static int
 mlxsw_sp_nexthop_fib_entries_update(struct mlxsw_sp *mlxsw_sp,
 				    struct mlxsw_sp_nexthop_group *nh_grp)
@@ -1520,6 +1524,9 @@ mlxsw_sp_nexthop_fib_entries_update(struct mlxsw_sp *mlxsw_sp,
 	int err;
 
 	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
+		if (!mlxsw_sp_fib_node_entry_is_first(fib_entry->fib_node,
+						      fib_entry))
+			continue;
 		err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
 		if (err)
 			return err;
-- 
2.9.3
