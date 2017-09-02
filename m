From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/21] mlxsw: spectrum_router: Support IPv6 overlay encap
Date: Sat,  2 Sep 2017 17:21:20 +0200
Message-ID: <20170902152126.17286-16-jiri@resnulli.us>
References: <20170902152126.17286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34456 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdIBPVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 11:21:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id l19so2652157wmi.1
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 08:21:52 -0700 (PDT)
In-Reply-To: <20170902152126.17286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Add the missing bits to recognize IPv6 next hops as IPIP ones to enable
offloading of IPv6 overlay encapsulation.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c    | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 231b597..05afd53 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3757,15 +3757,32 @@ mlxsw_sp_fib6_entry_rt_find(const struct mlxsw_sp_fib6_entry *fib6_entry,
 	return NULL;
 }
 
+static bool mlxsw_sp_nexthop6_ipip_type(const struct mlxsw_sp *mlxsw_sp,
+					const struct rt6_info *rt,
+					enum mlxsw_sp_ipip_type *ret)
+{
+	return rt->dst.dev &&
+	       mlxsw_sp_netdev_ipip_type(mlxsw_sp, rt->dst.dev, ret);
+}
+
 static int mlxsw_sp_nexthop6_type_init(struct mlxsw_sp *mlxsw_sp,
 				       struct mlxsw_sp_nexthop_group *nh_grp,
 				       struct mlxsw_sp_nexthop *nh,
 				       const struct rt6_info *rt)
 {
+	struct mlxsw_sp_router *router = mlxsw_sp->router;
 	struct net_device *dev = rt->dst.dev;
+	enum mlxsw_sp_ipip_type ipipt;
 	struct mlxsw_sp_rif *rif;
 	int err;
 
+	if (mlxsw_sp_nexthop6_ipip_type(mlxsw_sp, rt, &ipipt) &&
+	    router->ipip_ops_arr[ipipt]->can_offload(mlxsw_sp, dev,
+						     MLXSW_SP_L3_PROTO_IPV6)) {
+		nh->type = MLXSW_SP_NEXTHOP_TYPE_IPIP;
+		return mlxsw_sp_nexthop_ipip_init(mlxsw_sp, ipipt, nh, dev);
+	}
+
 	nh->type = MLXSW_SP_NEXTHOP_TYPE_ETH;
 	rif = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
 	if (!rif)
@@ -3815,7 +3832,8 @@ static void mlxsw_sp_nexthop6_fini(struct mlxsw_sp *mlxsw_sp,
 static bool mlxsw_sp_rt6_is_gateway(const struct mlxsw_sp *mlxsw_sp,
 				    const struct rt6_info *rt)
 {
-	return rt->rt6i_flags & RTF_GATEWAY;
+	return rt->rt6i_flags & RTF_GATEWAY ||
+	       mlxsw_sp_nexthop6_ipip_type(mlxsw_sp, rt, NULL);
 }
 
 static struct mlxsw_sp_nexthop_group *
-- 
2.9.3
