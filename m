From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/15] mlxsw: spectrum_router: Use trap action only for some route types
Date: Wed,  8 Feb 2017 11:16:38 +0100
Message-ID: <1486549002-2056-12-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34975 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753007AbdBHKQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:58 -0500
Received: by mail-wr0-f180.google.com with SMTP id 89so57621512wrr.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:57 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The device can have one of three actions associated with a route:

1) Remote - packets continue to the adjacency table
2) Local - packets continue to the neighbour table
3) Trap - packets continue to the CPU

The first two actions can also trap packets to the CPU, but they do so
using a different trap ID, which has a lower traffic class and less
allotted bandwidth.

We currently use the third action for both RTN_{LOCAL,BROADCAST} routes
and RTN_UNICAST routes not pointing to the switch ports.

However, packets that merely need to be forwarded by the switch are
likely not control packets and can be therefore scheduled towards the
CPU using a lower traffic class.

Achieve the above by assigning the third action only to local and
broadcast routes and have any other route use either of the first two
actions, based on whether the route is gatewayed or not.

This will also allow us to refresh routes using the local action and
have them trap packets when their RIF is no longer valid following a
NH_DEL event.

One side effect of this patch is that we no longer give special
treatment to multipath routes using both switch and non-switch ports
towards their nexthops. If at least one of the nexthops can be resolved,
then the device will forward the packets instead of trapping them.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 42 +++++++---------------
 1 file changed, 13 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c452bd3..136a50c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1623,7 +1623,7 @@ mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
 	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
 		return !!nh_group->adj_index_valid;
 	case MLXSW_SP_FIB_ENTRY_TYPE_LOCAL:
-		return true;
+		return !!nh_group->nh_rif;
 	default:
 		return false;
 	}
@@ -1718,16 +1718,25 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 					enum mlxsw_reg_ralue_op op)
 {
 	struct mlxsw_sp_rif *r = fib_entry->nh_group->nh_rif;
+	enum mlxsw_reg_ralue_trap_action trap_action;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
 	u32 *p_dip = (u32 *) fib_entry->key.addr;
 	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	u16 trap_id = 0;
+	u16 rif = 0;
+
+	if (mlxsw_sp_fib_entry_should_offload(fib_entry)) {
+		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_NOP;
+		rif = r->rif;
+	} else {
+		trap_action = MLXSW_REG_RALUE_TRAP_ACTION_TRAP;
+		trap_id = MLXSW_TRAP_ID_RTR_INGRESS0;
+	}
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
 			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
 			      vr->id, fib_entry->key.prefix_len, *p_dip);
-	mlxsw_reg_ralue_act_local_pack(ralue_pl,
-				       MLXSW_REG_RALUE_TRAP_ACTION_NOP, 0,
-				       r->rif);
+	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id, rif);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
@@ -1798,8 +1807,6 @@ mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
 			     struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct fib_info *fi = fen_info->fi;
-	struct mlxsw_sp_rif *r = NULL;
-	int nhsel;
 
 	if (fen_info->type == RTN_LOCAL || fen_info->type == RTN_BROADCAST) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
@@ -1807,29 +1814,6 @@ mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
 	}
 	if (fen_info->type != RTN_UNICAST)
 		return -EINVAL;
-
-	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
-		const struct fib_nh *nh = &fi->fib_nh[nhsel];
-
-		if (!nh->nh_dev)
-			continue;
-		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, nh->nh_dev);
-		if (!r) {
-			/* In case router interface is not found for
-			 * at least one of the nexthops, that means
-			 * the nexthop points to some device unrelated
-			 * to us. Set trap and pass the packets for
-			 * this prefix to kernel.
-			 */
-			break;
-		}
-	}
-
-	if (!r) {
-		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
-		return 0;
-	}
-
 	if (fi->fib_nh->nh_scope != RT_SCOPE_LINK)
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 	else
-- 
2.7.4
