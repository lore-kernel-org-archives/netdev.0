From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V1 08/10] net/mlx5e: Introduce tc offload support
Date: Thu,  3 Mar 2016 11:23:24 +0200
Message-ID: <1456997006-18538-9-git-send-email-amir@vadai.me>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36206 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757266AbcCCJT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:19:56 -0500
Received: by mail-wm0-f65.google.com with SMTP id l68so3023773wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:19:55 -0800 (PST)
In-Reply-To: <1456997006-18538-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend ndo_setup_tc() to support ingress tc offloading. Will be used by
later patches to offload tc flower filter.

Feature is off by default and could be enabled by issuing:
 # ethtool  -K eth0 hw-tc-offload on

Offloads flow table is dynamically created when first filter is
added.
Rules are saved in a hash table that is maintained by the consumer (for
example - the flower offload in the next patch).
When last filter is removed and no filters exist in the hash table, the
offload flow table is destroyed.

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   9 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  38 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 131 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  44 ++++++++
 5 files changed, 222 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 11b592d..4fc45ee 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -6,6 +6,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
-		en_txrx.o en_clock.o vxlan.o
+		en_txrx.o en_clock.o vxlan.o en_tc.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9c0e80e..36f3dba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -43,6 +43,7 @@
 #include <linux/mlx5/port.h>
 #include <linux/mlx5/vport.h>
 #include <linux/mlx5/transobj.h>
+#include <linux/rhashtable.h>
 #include "wq.h"
 #include "mlx5_core.h"
 
@@ -526,8 +527,16 @@ struct mlx5e_flow_table {
 	struct mlx5_flow_group		**g;
 };
 
+struct mlx5e_tc_flow_table {
+	struct mlx5_flow_table		*t;
+
+	struct rhashtable_params        ht_params;
+	struct rhashtable               ht;
+};
+
 struct mlx5e_flow_tables {
 	struct mlx5_flow_namespace	*ns;
+	struct mlx5e_tc_flow_table	tc;
 	struct mlx5e_flow_table		vlan;
 	struct mlx5e_flow_table		main;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5e3692f..011c4f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -30,9 +30,12 @@
  * SOFTWARE.
  */
 
+#include <net/tc_act/tc_gact.h>
+#include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
 #include "en.h"
+#include "en_tc.h"
 #include "eswitch.h"
 #include "vxlan.h"
 
@@ -1883,6 +1886,17 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 			      __be16 proto, struct tc_to_netdev *tc)
 {
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+		goto mqprio;
+
+	switch (tc->type) {
+	default:
+		return -EOPNOTSUPP;
+	}
+
+mqprio:
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
@@ -1966,6 +1980,13 @@ static int mlx5e_set_features(struct net_device *netdev,
 			mlx5e_disable_vlan_filter(priv);
 	}
 
+	if ((changes & NETIF_F_HW_TC) && !(features & NETIF_F_HW_TC) &&
+	    mlx5e_tc_num_filters(priv)) {
+		netdev_err(netdev,
+			   "Active offloaded tc filters, can't turn hw_tc_offload off\n");
+		return -EINVAL;
+	}
+
 	return err;
 }
 
@@ -2365,6 +2386,13 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 	if (!priv->params.lro_en)
 		netdev->features  &= ~NETIF_F_LRO;
 
+#define FT_CAP(f) MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.f)
+	if (FT_CAP(flow_modify_en) &&
+	    FT_CAP(modify_root) &&
+	    FT_CAP(identified_miss_table_mode) &&
+	    FT_CAP(flow_table_modify))
+		priv->netdev->hw_features      |= NETIF_F_HW_TC;
+
 	netdev->features         |= NETIF_F_HIGHDMA;
 
 	netdev->priv_flags       |= IFF_UNICAST_FLT;
@@ -2486,6 +2514,10 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	mlx5e_vxlan_init(priv);
 
+	err = mlx5e_tc_init(priv);
+	if (err)
+		goto err_destroy_flow_tables;
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
 #endif
@@ -2493,7 +2525,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	err = register_netdev(netdev);
 	if (err) {
 		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
-		goto err_destroy_flow_tables;
+		goto err_tc_cleanup;
 	}
 
 	if (mlx5e_vxlan_allowed(mdev))
@@ -2504,6 +2536,9 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	return priv;
 
+err_tc_cleanup:
+	mlx5e_tc_cleanup(priv);
+
 err_destroy_flow_tables:
 	mlx5e_destroy_flow_tables(priv);
 
@@ -2551,6 +2586,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_disable_async_events(priv);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+	mlx5e_tc_cleanup(priv);
 	mlx5e_vxlan_cleanup(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
new file mode 100644
index 0000000..9457173
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -0,0 +1,131 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/mlx5/fs.h>
+#include <linux/mlx5/device.h>
+#include <linux/rhashtable.h>
+#include "en.h"
+#include "en_tc.h"
+
+struct mlx5e_tc_flow {
+	struct rhash_head	node;
+	u64			cookie;
+	struct mlx5_flow_rule	*rule;
+};
+
+#define MLX5E_TC_FLOW_TABLE_NUM_ENTRIES 1024
+#define MLX5E_TC_FLOW_TABLE_NUM_GROUPS 4
+
+struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
+					 u32 *match_c, u32 *match_v,
+					 u32 action, u32 flow_tag)
+{
+	struct mlx5_flow_destination dest = {
+		.type = MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE,
+		{.ft = priv->fts.vlan.t},
+	};
+	struct mlx5_flow_rule *rule;
+	bool table_created = false;
+
+	if (IS_ERR_OR_NULL(priv->fts.tc.t)) {
+		priv->fts.tc.t =
+			mlx5_create_auto_grouped_flow_table(priv->fts.ns, 0,
+							    MLX5E_TC_FLOW_TABLE_NUM_ENTRIES,
+							    MLX5E_TC_FLOW_TABLE_NUM_GROUPS);
+		if (IS_ERR(priv->fts.tc.t)) {
+			netdev_err(priv->netdev,
+				   "Failed to create tc offload table\n");
+			return ERR_CAST(priv->fts.tc.t);
+		}
+
+		table_created = true;
+	}
+
+	rule = mlx5_add_flow_rule(priv->fts.tc.t, MLX5_MATCH_OUTER_HEADERS,
+				  match_c, match_v,
+				  action, flow_tag,
+				  action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST ? &dest : NULL);
+
+	if (IS_ERR(rule) && table_created) {
+		mlx5_destroy_flow_table(priv->fts.tc.t);
+		priv->fts.tc.t = NULL;
+	}
+
+	return rule;
+}
+
+static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
+			      struct mlx5_flow_rule *rule)
+{
+	mlx5_del_flow_rule(rule);
+
+	if (!mlx5e_tc_num_filters(priv)) {
+		mlx5_destroy_flow_table(priv->fts.tc.t);
+		priv->fts.tc.t = NULL;
+	}
+}
+
+static const struct rhashtable_params mlx5e_tc_flow_ht_params = {
+	.head_offset = offsetof(struct mlx5e_tc_flow, node),
+	.key_offset = offsetof(struct mlx5e_tc_flow, cookie),
+	.key_len = sizeof(((struct mlx5e_tc_flow *)0)->cookie),
+	.automatic_shrinking = true,
+};
+
+int mlx5e_tc_init(struct mlx5e_priv *priv)
+{
+	struct mlx5e_tc_flow_table *tc = &priv->fts.tc;
+
+	tc->ht_params = mlx5e_tc_flow_ht_params;
+	return rhashtable_init(&tc->ht, &tc->ht_params);
+}
+
+static void _mlx5e_tc_del_flow(void *ptr, void *arg)
+{
+	struct mlx5e_tc_flow *flow = ptr;
+	struct mlx5e_priv *priv = arg;
+
+	mlx5e_tc_del_flow(priv, flow->rule);
+	kfree(flow);
+}
+
+void mlx5e_tc_cleanup(struct mlx5e_priv *priv)
+{
+	struct mlx5e_tc_flow_table *tc = &priv->fts.tc;
+
+	rhashtable_free_and_destroy(&tc->ht, _mlx5e_tc_del_flow, priv);
+
+	if (!IS_ERR_OR_NULL(priv->fts.tc.t)) {
+		mlx5_destroy_flow_table(priv->fts.tc.t);
+		priv->fts.tc.t = NULL;
+	}
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
new file mode 100644
index 0000000..46eacc5
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -0,0 +1,44 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5_EN_TC_H__
+#define __MLX5_EN_TC_H__
+
+int mlx5e_tc_init(struct mlx5e_priv *priv);
+void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
+
+static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
+{
+	return atomic_read(&priv->fts.tc.ht.nelems);
+}
+
+#endif /* __MLX5_EN_TC_H__ */
-- 
2.7.0
