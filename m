From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum_router: Don't read 'nud_state' without lock
Date: Mon,  6 Feb 2017 16:20:16 +0100
Message-ID: <1486394417-8011-8-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33699 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbdBFPUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:38 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so22464778wmv.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:38 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We periodically ask the neighbouring system to try and resolve
neighbours that are used for nexthops, but aren't currently resolved.

However, 'nud_state' is protected by the neighbour lock, so we shouldn't
access it without taking it. Instead, we can simply check the
'connected' field of the neighbour entry, which we update upon
NEIGH_UPDATE events.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 98a6d03..ec022f9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -896,7 +896,7 @@ static void mlxsw_sp_router_probe_unresolved_nexthops(struct work_struct *work)
 	rtnl_lock();
 	list_for_each_entry(neigh_entry, &mlxsw_sp->router.nexthop_neighs_list,
 			    nexthop_neighs_list_node)
-		if (!(neigh_entry->key.n->nud_state & NUD_VALID))
+		if (!neigh_entry->connected)
 			neigh_event_send(neigh_entry->key.n, NULL);
 	rtnl_unlock();
 
-- 
2.7.4
