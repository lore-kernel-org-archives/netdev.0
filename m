From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/3] mlxsw: spectrum_router: Don't reflect dead neighs
Date: Fri, 23 Dec 2016 09:32:49 +0100
Message-ID: <1482481970-2327-3-git-send-email-jiri@resnulli.us>
References: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36857 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755008AbcLWIcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 03:32:55 -0500
Received: by mail-wj0-f196.google.com with SMTP id j10so39230568wjb.3
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 00:32:54 -0800 (PST)
In-Reply-To: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a neighbour is considered to be dead, we should remove it from the
device's table regardless of its NUD state.

Without this patch, after setting a port to be administratively down we
get the following errors when we periodically try to update the kernel
about neighbours activity:

[  461.947268] mlxsw_spectrum 0000:03:00.0 sw1p3: Failed to find
matching neighbour for IP=192.168.100.2

Fixes: a6bf9e933daf ("mlxsw: spectrum_router: Offload neighbours based on NUD state change")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 53126bf..a0f9742 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -942,7 +942,7 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 	char rauht_pl[MLXSW_REG_RAUHT_LEN];
 	struct net_device *dev;
 	bool entry_connected;
-	u8 nud_state;
+	u8 nud_state, dead;
 	bool updating;
 	bool removing;
 	bool adding;
@@ -953,10 +953,11 @@ static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
 	dip = ntohl(*((__be32 *) n->primary_key));
 	memcpy(neigh_entry->ha, n->ha, sizeof(neigh_entry->ha));
 	nud_state = n->nud_state;
+	dead = n->dead;
 	dev = n->dev;
 	read_unlock_bh(&n->lock);
 
-	entry_connected = nud_state & NUD_VALID;
+	entry_connected = nud_state & NUD_VALID && !dead;
 	adding = (!neigh_entry->offloaded) && entry_connected;
 	updating = neigh_entry->offloaded && entry_connected;
 	removing = neigh_entry->offloaded && !entry_connected;
@@ -1351,7 +1352,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct net_device *dev = fib_nh->nh_dev;
 	struct neighbour *n;
-	u8 nud_state;
+	u8 nud_state, dead;
 
 	/* Take a reference of neigh here ensuring that neigh would
 	 * not be detructed before the nexthop entry is finished.
@@ -1383,8 +1384,9 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	list_add_tail(&nh->neigh_list_node, &neigh_entry->nexthop_list);
 	read_lock_bh(&n->lock);
 	nud_state = n->nud_state;
+	dead = n->dead;
 	read_unlock_bh(&n->lock);
-	__mlxsw_sp_nexthop_neigh_update(nh, !(nud_state & NUD_VALID));
+	__mlxsw_sp_nexthop_neigh_update(nh, !(nud_state & NUD_VALID && !dead));
 
 	return 0;
 }
-- 
2.7.4
