From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: spectrum_router: Store weight in nexthop struct
Date: Sun, 22 Oct 2017 23:11:46 +0200
Message-ID: <20171022211150.2567-5-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:52404 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932139AbdJVVL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id 78so3496989wmb.1
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:55 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As the first step towards non-equal-cost multi-path support, store each
nexthop's weight.

For IPv6 nexthops always set the weight to 1, as it only supports ECMP.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index cb0d25e..8cd422d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2203,6 +2203,7 @@ struct mlxsw_sp_nexthop {
 	struct mlxsw_sp_nexthop_key key;
 	unsigned char gw_addr[sizeof(struct in6_addr)];
 	int ifindex;
+	int nh_weight;
 	struct mlxsw_sp_rif *rif;
 	u8 should_offload:1, /* set indicates this neigh is connected and
 			      * should be put to KVD linear area of this group.
@@ -3045,6 +3046,11 @@ static int mlxsw_sp_nexthop4_init(struct mlxsw_sp *mlxsw_sp,
 
 	nh->nh_grp = nh_grp;
 	nh->key.fib_nh = fib_nh;
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	nh->nh_weight = fib_nh->nh_weight;
+#else
+	nh->nh_weight = 1;
+#endif
 	memcpy(&nh->gw_addr, &fib_nh->nh_gw, sizeof(fib_nh->nh_gw));
 	err = mlxsw_sp_nexthop_insert(mlxsw_sp, nh);
 	if (err)
@@ -4304,6 +4310,7 @@ static int mlxsw_sp_nexthop6_init(struct mlxsw_sp *mlxsw_sp,
 	struct net_device *dev = rt->dst.dev;
 
 	nh->nh_grp = nh_grp;
+	nh->nh_weight = 1;
 	memcpy(&nh->gw_addr, &rt->rt6i_gateway, sizeof(nh->gw_addr));
 	mlxsw_sp_nexthop_counter_alloc(mlxsw_sp, nh);
 
-- 
2.9.5
