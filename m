From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum_switchdev: Release multicast groups during fini
Date: Fri,  4 Aug 2017 14:12:30 +0200
Message-ID: <20170804121230.2144-3-jiri@resnulli.us>
References: <20170804121230.2144-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37235 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752584AbdHDMMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:12:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id t138so5472498wmt.4
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:12:37 -0700 (PDT)
In-Reply-To: <20170804121230.2144-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Each multicast group (MID) stores a bitmap of ports to which a packet
should be forwarded to in case an MDB entry associated with the MID is
hit.

Since the initial introduction of IGMP snooping in commit 3a49b4fde2a1
("mlxsw: Adding layer 2 multicast support") the driver didn't correctly
free these multicast groups upon ungraceful situations such as the
removal of the upper bridge device or module removal.

The correct way to fix this is to associate each MID with the bridge
ports member in it and then drop the reference in case the bridge port
is destroyed, but this will result in a lot more code and will be fixed
in net-next.

For now, upon module removal, traverse the MID list and release each
one.

Fixes: 3a49b4fde2a1 ("mlxsw: Adding layer 2 multicast support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 73d54df..5eb1606 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1974,6 +1974,17 @@ static void mlxsw_sp_fdb_fini(struct mlxsw_sp *mlxsw_sp)
 
 }
 
+static void mlxsw_sp_mids_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_mid *mid, *tmp;
+
+	list_for_each_entry_safe(mid, tmp, &mlxsw_sp->bridge->mids_list, list) {
+		list_del(&mid->list);
+		clear_bit(mid->mid, mlxsw_sp->bridge->mids_bitmap);
+		kfree(mid);
+	}
+}
+
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_bridge *bridge;
@@ -1996,7 +2007,7 @@ int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	mlxsw_sp_fdb_fini(mlxsw_sp);
-	WARN_ON(!list_empty(&mlxsw_sp->bridge->mids_list));
+	mlxsw_sp_mids_fini(mlxsw_sp);
 	WARN_ON(!list_empty(&mlxsw_sp->bridge->bridges_list));
 	kfree(mlxsw_sp->bridge);
 }
-- 
2.9.3
