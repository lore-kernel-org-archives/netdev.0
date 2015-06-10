From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 05/13] net/mlx4_core: Adjust counter grant policy in the resource tracker
Date: Wed, 10 Jun 2015 17:59:30 +0300
Message-ID: <1433948378-17570-6-git-send-email-ogerlitz@mellanox.com>
References: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38045 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933145AbbFJPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 11:01:14 -0400
In-Reply-To: <1433948378-17570-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Each physical function has a guarantee of two counters per port, one
for a default counter and one for the IB driver.

Each virtual function has a guarantee of one counter per port.
All other counters are free and can be obtained on demand.

This is a preparation step for supporting a get_vf_stats ndo call,
so we can promise a counter for every VF in order to collect their
statistics from the PF context.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   35 +++++++++++++++++--
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index ab48386..802eb2a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -48,6 +48,8 @@
 #include "fw.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
+#define MLX4_PF_COUNTERS_PER_PORT	2
+#define MLX4_VF_COUNTERS_PER_PORT	1
 
 struct mac_res {
 	struct list_head list;
@@ -459,11 +461,21 @@ void mlx4_init_quotas(struct mlx4_dev *dev)
 	dev->quotas.mpt =
 		priv->mfunc.master.res_tracker.res_alloc[RES_MPT].quota[pf];
 }
+
+static int get_max_gauranteed_vfs_counter(struct mlx4_dev *dev)
+{
+	/* reduce the sink counter */
+	return (dev->caps.max_counters - 1 -
+		(MLX4_PF_COUNTERS_PER_PORT * MLX4_MAX_PORTS))
+		/ MLX4_MAX_PORTS;
+}
+
 int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	int i, j;
 	int t;
+	int max_vfs_guarantee_counter = get_max_gauranteed_vfs_counter(dev);
 
 	priv->mfunc.master.res_tracker.slave_list =
 		kzalloc(dev->num_slaves * sizeof(struct slave_list),
@@ -499,6 +511,9 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 			res_alloc->allocated = kzalloc((dev->persist->
 							num_vfs + 1) *
 						       sizeof(int), GFP_KERNEL);
+		/* Reduce the sink counter */
+		if (i == RES_COUNTER)
+			res_alloc->res_free = dev->caps.max_counters - 1;
 
 		if (!res_alloc->quota || !res_alloc->guaranteed ||
 		    !res_alloc->allocated)
@@ -577,9 +592,17 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 				break;
 			case RES_COUNTER:
 				res_alloc->quota[t] = dev->caps.max_counters;
-				res_alloc->guaranteed[t] = 0;
 				if (t == mlx4_master_func_num(dev))
-					res_alloc->res_free = res_alloc->quota[t];
+					res_alloc->guaranteed[t] =
+						MLX4_PF_COUNTERS_PER_PORT *
+						MLX4_MAX_PORTS;
+				else if (t <= max_vfs_guarantee_counter)
+					res_alloc->guaranteed[t] =
+						MLX4_VF_COUNTERS_PER_PORT *
+						MLX4_MAX_PORTS;
+				else
+					res_alloc->guaranteed[t] = 0;
+				res_alloc->res_free -= res_alloc->guaranteed[t];
 				break;
 			default:
 				break;
@@ -952,7 +975,7 @@ static struct res_common *alloc_srq_tr(int id)
 	return &ret->com;
 }
 
-static struct res_common *alloc_counter_tr(int id)
+static struct res_common *alloc_counter_tr(int id, int port)
 {
 	struct res_counter *ret;
 
@@ -962,6 +985,7 @@ static struct res_common *alloc_counter_tr(int id)
 
 	ret->com.res_id = id;
 	ret->com.state = RES_COUNTER_ALLOCATED;
+	ret->port = port;
 
 	return &ret->com;
 }
@@ -1022,7 +1046,7 @@ static struct res_common *alloc_tr(u64 id, enum mlx4_resource type, int slave,
 		pr_err("implementation missing\n");
 		return NULL;
 	case RES_COUNTER:
-		ret = alloc_counter_tr(id);
+		ret = alloc_counter_tr(id, extra);
 		break;
 	case RES_XRCD:
 		ret = alloc_xrcdn_tr(id);
@@ -2335,6 +2359,9 @@ static int counter_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 		return -EINVAL;
 
 	index = get_param_l(&in_param);
+	if (index == MLX4_SINK_COUNTER_INDEX(dev))
+		return 0;
+
 	err = rem_res_range(dev, slave, index, 1, RES_COUNTER, 0);
 	if (err)
 		return err;
-- 
1.7.1
