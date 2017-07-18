From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/22] mlxsw: spectrum_router: Set activity interval according to both neighbour tables
Date: Tue, 18 Jul 2017 10:10:18 +0200
Message-ID: <20170718081030.2781-11-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35640 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdGRIKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:50 -0400
Received: by mail-wr0-f196.google.com with SMTP id a10so2871297wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:50 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The neighbours' activity is currently dumped according to the ARP
table's DELAY_PROBE time, but with the introduction of IPv6 offload we
should set the interval according to the minimum between the ARP and
ndisc tables.

Signed-off-by: Arkadi Sharshvesky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 312fb67..cb797fb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -932,8 +932,11 @@ mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, struct neighbour *n)
 static void
 mlxsw_sp_router_neighs_update_interval_init(struct mlxsw_sp *mlxsw_sp)
 {
-	unsigned long interval = NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME);
+	unsigned long interval;
 
+	interval = min_t(unsigned long,
+			 NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME),
+			 NEIGH_VAR(&nd_tbl.parms, DELAY_PROBE_TIME));
 	mlxsw_sp->router->neighs_update.interval = jiffies_to_msecs(interval);
 }
 
@@ -1321,7 +1324,7 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 		p = ptr;
 
 		/* We don't care about changes in the default table. */
-		if (!p->dev || p->tbl != &arp_tbl)
+		if (!p->dev || (p->tbl != &arp_tbl && p->tbl != &nd_tbl))
 			return NOTIFY_DONE;
 
 		/* We are in atomic context and can't take RTNL mutex,
-- 
2.9.3
