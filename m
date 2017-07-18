From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/22] mlxsw: spectrum_router: Reflect IPv6 neighbours to the device
Date: Tue, 18 Jul 2017 10:10:15 +0200
Message-ID: <20170718081030.2781-8-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36475 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbdGRIKq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:46 -0400
Received: by mail-wr0-f195.google.com with SMTP id y67so669558wrb.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:46 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

As with IPv4, listen to NEIGH_UPDATE events from the ndisc table and
program relevant neighbours to the device's neighbour table.

Note that neighbours with a link-local IP address aren't programmed, as
packets with a link-local destination IP are trapped after LPM lookup
and never reach the neighbour table.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 40 ++++++++++++++++++++--
 1 file changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7224066..a0de736 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -50,6 +50,8 @@
 #include <net/fib_rules.h>
 #include <net/l3mdev.h>
 #include <net/addrconf.h>
+#include <net/ndisc.h>
+#include <net/ipv6.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -1148,6 +1150,32 @@ mlxsw_sp_router_neigh_entry_op4(struct mlxsw_sp *mlxsw_sp,
 }
 
 static void
+mlxsw_sp_router_neigh_entry_op6(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_neigh_entry *neigh_entry,
+				enum mlxsw_reg_rauht_op op)
+{
+	struct neighbour *n = neigh_entry->key.n;
+	char rauht_pl[MLXSW_REG_RAUHT_LEN];
+	const char *dip = n->primary_key;
+
+	mlxsw_reg_rauht_pack6(rauht_pl, op, neigh_entry->rif, neigh_entry->ha,
+			      dip);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht), rauht_pl);
+}
+
+static bool mlxsw_sp_neigh_ipv6_ignore(struct neighbour *n)
+{
+	/* Packets with a link-local destination address are trapped
+	 * after LPM lookup and never reach the neighbour table, so
+	 * there is no need to program such neighbours to the device.
+	 */
+	if (ipv6_addr_type((struct in6_addr *) &n->primary_key) &
+	    IPV6_ADDR_LINKLOCAL)
+		return true;
+	return false;
+}
+
+static void
 mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
 			    struct mlxsw_sp_neigh_entry *neigh_entry,
 			    bool adding)
@@ -1155,11 +1183,17 @@ mlxsw_sp_neigh_entry_update(struct mlxsw_sp *mlxsw_sp,
 	if (!adding && !neigh_entry->connected)
 		return;
 	neigh_entry->connected = adding;
-	if (neigh_entry->key.n->tbl == &arp_tbl)
+	if (neigh_entry->key.n->tbl == &arp_tbl) {
 		mlxsw_sp_router_neigh_entry_op4(mlxsw_sp, neigh_entry,
 						mlxsw_sp_rauht_op(adding));
-	else
+	} else if (neigh_entry->key.n->tbl == &nd_tbl) {
+		if (mlxsw_sp_neigh_ipv6_ignore(neigh_entry->key.n))
+			return;
+		mlxsw_sp_router_neigh_entry_op6(mlxsw_sp, neigh_entry,
+						mlxsw_sp_rauht_op(adding));
+	} else {
 		WARN_ON_ONCE(1);
+	}
 }
 
 struct mlxsw_sp_neigh_event_work {
@@ -1247,7 +1281,7 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 	case NETEVENT_NEIGH_UPDATE:
 		n = ptr;
 
-		if (n->tbl != &arp_tbl)
+		if (n->tbl != &arp_tbl && n->tbl != &nd_tbl)
 			return NOTIFY_DONE;
 
 		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(n->dev);
-- 
2.9.3
