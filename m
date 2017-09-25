From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/10] mlxsw: spectrum_router: Keep nexthops in a linked list
Date: Mon, 25 Sep 2017 10:32:23 +0200
Message-ID: <20170925083230.1193-4-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36495 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933826AbdIYIce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id r136so6474990wmf.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:34 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Keep nexthops in a linked list for easy access.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 16c041b..e8c2170 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -80,6 +80,7 @@ struct mlxsw_sp_router {
 	struct rhashtable neigh_ht;
 	struct rhashtable nexthop_group_ht;
 	struct rhashtable nexthop_ht;
+	struct list_head nexthop_list;
 	struct {
 		struct mlxsw_sp_lpm_tree *trees;
 		unsigned int tree_count;
@@ -2043,6 +2044,7 @@ struct mlxsw_sp_nexthop_key {
 struct mlxsw_sp_nexthop {
 	struct list_head neigh_list_node; /* member of neigh entry list */
 	struct list_head rif_list_node;
+	struct list_head router_list_node;
 	struct mlxsw_sp_nexthop_group *nh_grp; /* pointer back to the group
 						* this belongs to
 						*/
@@ -2799,6 +2801,8 @@ static int mlxsw_sp_nexthop4_init(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
+	list_add_tail(&nh->router_list_node, &mlxsw_sp->router->nexthop_list);
+
 	if (!dev)
 		return 0;
 
@@ -2822,6 +2826,7 @@ static void mlxsw_sp_nexthop4_fini(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_nexthop *nh)
 {
 	mlxsw_sp_nexthop4_type_fini(mlxsw_sp, nh);
+	list_del(&nh->router_list_node);
 	mlxsw_sp_nexthop_remove(mlxsw_sp, nh);
 }
 
@@ -4060,6 +4065,8 @@ static int mlxsw_sp_nexthop6_init(struct mlxsw_sp *mlxsw_sp,
 	nh->nh_grp = nh_grp;
 	memcpy(&nh->gw_addr, &rt->rt6i_gateway, sizeof(nh->gw_addr));
 
+	list_add_tail(&nh->router_list_node, &mlxsw_sp->router->nexthop_list);
+
 	if (!dev)
 		return 0;
 	nh->ifindex = dev->ifindex;
@@ -4071,6 +4078,7 @@ static void mlxsw_sp_nexthop6_fini(struct mlxsw_sp *mlxsw_sp,
 				   struct mlxsw_sp_nexthop *nh)
 {
 	mlxsw_sp_nexthop6_type_fini(mlxsw_sp, nh);
+	list_del(&nh->router_list_node);
 }
 
 static bool mlxsw_sp_rt6_is_gateway(const struct mlxsw_sp *mlxsw_sp,
@@ -6178,6 +6186,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_nexthop_group_ht_init;
 
+	INIT_LIST_HEAD(&mlxsw_sp->router->nexthop_list);
 	err = mlxsw_sp_lpm_init(mlxsw_sp);
 	if (err)
 		goto err_lpm_init;
-- 
2.9.5
