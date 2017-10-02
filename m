From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum_router: Track RIF of IPIP next hops
Date: Mon,  2 Oct 2017 12:14:57 +0200
Message-ID: <20171002101457.1462-3-jiri@resnulli.us>
References: <20171002101457.1462-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33091 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdJBKPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:15:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id z96so2166066wrb.0
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:15:00 -0700 (PDT)
In-Reply-To: <20171002101457.1462-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

When considering whether to set RTNH_F_OFFLOAD flag on an IPv6 route,
mlxsw_sp_fib6_entry_offload_set() looks up the mlxsw_sp_nexthop
corresponding to a given route, and decides based on whether the next
hop's offloaded flag was set. When looking for the matching next hop, it
also takes into account the device of the route, which must match next
hop's RIF.

IPIP next hops however hitherto didn't set the RIF. As a result, IPv6
routes forwarding traffic to IP-in-IP netdevices are never marked as
offloaded, even when they actually are.

Thus track RIF of IPIP next hops the same way as that of ETHERNET next
hops.

Fixes: 8f28a3097645 ("mlxsw: spectrum_router: Support IPv6 overlay encap")
Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3917b4d..032089e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2723,6 +2723,7 @@ static void mlxsw_sp_nexthop_type_fini(struct mlxsw_sp *mlxsw_sp,
 		mlxsw_sp_nexthop_rif_fini(nh);
 		break;
 	case MLXSW_SP_NEXTHOP_TYPE_IPIP:
+		mlxsw_sp_nexthop_rif_fini(nh);
 		mlxsw_sp_nexthop_ipip_fini(mlxsw_sp, nh);
 		break;
 	}
@@ -2742,7 +2743,11 @@ static int mlxsw_sp_nexthop4_type_init(struct mlxsw_sp *mlxsw_sp,
 	    router->ipip_ops_arr[ipipt]->can_offload(mlxsw_sp, dev,
 						     MLXSW_SP_L3_PROTO_IPV4)) {
 		nh->type = MLXSW_SP_NEXTHOP_TYPE_IPIP;
-		return mlxsw_sp_nexthop_ipip_init(mlxsw_sp, ipipt, nh, dev);
+		err = mlxsw_sp_nexthop_ipip_init(mlxsw_sp, ipipt, nh, dev);
+		if (err)
+			return err;
+		mlxsw_sp_nexthop_rif_init(nh, &nh->ipip_entry->ol_lb->common);
+		return 0;
 	}
 
 	nh->type = MLXSW_SP_NEXTHOP_TYPE_ETH;
@@ -4009,7 +4014,11 @@ static int mlxsw_sp_nexthop6_type_init(struct mlxsw_sp *mlxsw_sp,
 	    router->ipip_ops_arr[ipipt]->can_offload(mlxsw_sp, dev,
 						     MLXSW_SP_L3_PROTO_IPV6)) {
 		nh->type = MLXSW_SP_NEXTHOP_TYPE_IPIP;
-		return mlxsw_sp_nexthop_ipip_init(mlxsw_sp, ipipt, nh, dev);
+		err = mlxsw_sp_nexthop_ipip_init(mlxsw_sp, ipipt, nh, dev);
+		if (err)
+			return err;
+		mlxsw_sp_nexthop_rif_init(nh, &nh->ipip_entry->ol_lb->common);
+		return 0;
 	}
 
 	nh->type = MLXSW_SP_NEXTHOP_TYPE_ETH;
-- 
2.9.5
