From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum_router: Fix build when IPv6 isn't enabled
Date: Mon, 24 Jul 2017 09:56:00 +0200
Message-ID: <20170724075600.2798-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33954 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdGXH4D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 03:56:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id 79so4081209wmg.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 00:56:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When IPv6 isn't enabled the following error is generated:

ERROR: "nd_tbl" [drivers/net/ethernet/mellanox/mlxsw/mlxsw_spectrum.ko]
undefined!

Fix it by replacing 'arp_tbl' and 'nd_tbl' with 'tbl->family' wherever
possible and reference 'nd_tbl' only when IPV6 is enabled.

Fixes: d5eb89cf68d6 ("mlxsw: spectrum_router: Reflect IPv6 neighbours to the device")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e6d629f..274f72a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -43,6 +43,7 @@
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/socket.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -949,9 +950,13 @@ mlxsw_sp_router_neighs_update_interval_init(struct mlxsw_sp *mlxsw_sp)
 {
 	unsigned long interval;
 
+#if IS_ENABLED(CONFIG_IPV6)
 	interval = min_t(unsigned long,
 			 NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME),
 			 NEIGH_VAR(&nd_tbl.parms, DELAY_PROBE_TIME));
+#else
+	interval = NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME);
+#endif
 	mlxsw_sp->router->neighs_update.interval = jiffies_to_msecs(interval);
 }
 
@@ -986,6 +991,7 @@ static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 	neigh_release(n);
 }
 
+#if IS_ENABLED(IPV6)
 static void mlxsw_sp_router_neigh_ent_ipv6_process(struct mlxsw_sp *mlxsw_sp,
 						   char *rauhtd_pl,
 						   int rec_index)
@@ -1015,6 +1021,13 @@ static void mlxsw_sp_router_neigh_ent_ipv6_process(struct mlxsw_sp *mlxsw_sp,
 	neigh_event_send(n, NULL);
 	neigh_release(n);
 }
+#else
+static void mlxsw_sp_router_neigh_ent_ipv6_process(struct mlxsw_sp *mlxsw_sp,
+						   char *rauhtd_pl,
+						   int rec_index)
+{
+}
+#endif
 
 static void mlxsw_sp_router_neigh_rec_ipv4_process(struct mlxsw_sp *mlxsw_sp,
 						   char *rauhtd_pl,
@@ -1260,10 +1273,10 @@ mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
 	if (!adding && !neigh_entry->connected)
 		return;
 	neigh_entry->connected = adding;
-	if (neigh_entry->key.n->tbl == &arp_tbl) {
+	if (neigh_entry->key.n->tbl->family == AF_INET) {
 		mlxsw_sp_router_neigh_entry_op4(mlxsw_sp, neigh_entry,
 						mlxsw_sp_rauht_op(adding));
-	} else if (neigh_entry->key.n->tbl == &nd_tbl) {
+	} else if (neigh_entry->key.n->tbl->family == AF_INET6) {
 		if (mlxsw_sp_neigh_ipv6_ignore(neigh_entry->key.n))
 			return;
 		mlxsw_sp_router_neigh_entry_op6(mlxsw_sp, neigh_entry,
@@ -1339,7 +1352,8 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 		p = ptr;
 
 		/* We don't care about changes in the default table. */
-		if (!p->dev || (p->tbl != &arp_tbl && p->tbl != &nd_tbl))
+		if (!p->dev || (p->tbl->family != AF_INET &&
+				p->tbl->family != AF_INET6))
 			return NOTIFY_DONE;
 
 		/* We are in atomic context and can't take RTNL mutex,
@@ -1358,7 +1372,7 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 	case NETEVENT_NEIGH_UPDATE:
 		n = ptr;
 
-		if (n->tbl != &arp_tbl && n->tbl != &nd_tbl)
+		if (n->tbl->family != AF_INET && n->tbl->family != AF_INET6)
 			return NOTIFY_DONE;
 
 		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(n->dev);
-- 
2.9.3
