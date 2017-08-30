From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: spectrum_router: Export IPv6 link local address check helper
Date: Wed, 30 Aug 2017 14:03:00 +0200
Message-ID: <20170830120306.6128-3-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34598 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdH3MDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:16 -0400
Received: by mail-wr0-f195.google.com with SMTP id z91so4030224wrc.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:15 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Neighbors with link local addresses are not offloaded to the host table,
yet, the are maintained in the driver for adjacency table usage. When
dumping the IPv6 host neighbors this link local neighbors should be
ignored. This patch exports this helper for dpipe usage.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 6 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h | 1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 377d85c..1f41bcd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1396,8 +1396,10 @@ mlxsw_sp_router_neigh_entry_op6(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
 }
 
-static bool mlxsw_sp_neigh_ipv6_ignore(struct neighbour *n)
+bool mlxsw_sp_neigh_ipv6_ignore(struct mlxsw_sp_neigh_entry *neigh_entry)
 {
+	struct neighbour *n = neigh_entry->key.n;
+
 	/* Packets with a link-local destination address are trapped
 	 * after LPM lookup and never reach the neighbour table, so
 	 * there is no need to program such neighbours to the device.
@@ -1420,7 +1422,7 @@ mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_router_neigh_entry_op4(mlxsw_sp, neigh_entry,
 						mlxsw_sp_rauht_op(adding));
 	} else if (neigh_entry->key.n->tbl->family == AF_INET6) {
-		if (mlxsw_sp_neigh_ipv6_ignore(neigh_entry->key.n))
+		if (mlxsw_sp_neigh_ipv6_ignore(neigh_entry))
 			return;
 		mlxsw_sp_router_neigh_entry_op6(mlxsw_sp, neigh_entry,
 						mlxsw_sp_rauht_op(adding));
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index fb0f971..5b68616 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -76,5 +76,6 @@ void
 mlxsw_sp_neigh_entry_counter_update(struct mlxsw_sp *mlxsw_sp,
 				    struct mlxsw_sp_neigh_entry *neigh_entry,
 				    bool adding);
+bool mlxsw_sp_neigh_ipv6_ignore(struct mlxsw_sp_neigh_entry *neigh_entry);
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.3
