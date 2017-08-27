From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx5e: E-switch, Add steering drop counters
Date: Sun, 27 Aug 2017 14:06:18 +0300
Message-ID: <20170827110618.20599-5-saeedm@mellanox.com>
References: <20170827110618.20599-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37295 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751135AbdH0LV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2017 07:21:29 -0400
In-Reply-To: <20170827110618.20599-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add flow counters to count packets dropped due to drop rules
configured in eswitch egress and ingress ACLs.
These counters will count VFs violations and incoming traffic drops.
Will be presented on hypervisor via standard 'ip -s link show' command.

Example: "ip -s link show dev enp5s0f0"

6: enp5s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 24:8a:07:a5:28:f0 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       2
    TX: bytes  packets  errors  dropped carrier collsns
    1406       17       0       0       0       0
    vf 0 MAC 00:00:ca:fe:ca:fe, vlan 5, spoof checking off, link-state auto, trust off, query_rss off
    RX: bytes  packets  mcast   bcast   dropped
    1666       29       14         32      0
    TX: bytes  packets   dropped
    2880       44       2412

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 97 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  2 +
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  |  6 ++
 3 files changed, 98 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index a8e8670c7c8d..6c992e43e397 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -37,6 +37,7 @@
 #include <linux/mlx5/fs.h>
 #include "mlx5_core.h"
 #include "eswitch.h"
+#include "fs_core.h"
 
 #define UPLINK_VPORT 0xFFFF
 
@@ -1007,8 +1008,14 @@ static void esw_vport_cleanup_egress_rules(struct mlx5_eswitch *esw,
 		kfree(trunk_vlan_rule);
 	}
 
-	if (!IS_ERR_OR_NULL(vport->egress.drop_rule))
+	if (!IS_ERR_OR_NULL(vport->egress.drop_rule)) {
+		struct mlx5_fc *drop_counter =
+			mlx5_flow_rule_counter(vport->egress.drop_rule);
+
 		mlx5_del_flow_rules(vport->egress.drop_rule);
+		if (drop_counter)
+			mlx5_fc_destroy(vport->dev, drop_counter);
+	}
 
 	if (!IS_ERR_OR_NULL(vport->egress.allow_untagged_rule))
 		mlx5_del_flow_rules(vport->egress.allow_untagged_rule);
@@ -1174,8 +1181,14 @@ static void esw_vport_cleanup_ingress_rules(struct mlx5_eswitch *esw,
 {
 	struct mlx5_acl_vlan *trunk_vlan_rule, *tmp;
 
-	if (!IS_ERR_OR_NULL(vport->ingress.drop_rule))
+	if (!IS_ERR_OR_NULL(vport->ingress.drop_rule)) {
+		struct mlx5_fc *drop_counter =
+			mlx5_flow_rule_counter(vport->ingress.drop_rule);
+
 		mlx5_del_flow_rules(vport->ingress.drop_rule);
+		if (drop_counter)
+			mlx5_fc_destroy(vport->dev, drop_counter);
+	}
 
 	list_for_each_entry_safe(trunk_vlan_rule, tmp,
 				 &vport->ingress.allowed_vlans_rules, list) {
@@ -1222,6 +1235,8 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	bool need_vlan_filter = !!bitmap_weight(vport->info.vlan_trunk_8021q_bitmap,
 						VLAN_N_VID);
 	struct mlx5_acl_vlan *trunk_vlan_rule;
+	struct mlx5_flow_destination dest;
+	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	bool need_acl_table = true;
@@ -1333,18 +1348,33 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 	}
 
 drop_rule:
+	/* Alloc ingress drop flow counter */
+	counter = mlx5_fc_create(esw->dev, false);
+	if (IS_ERR(counter)) {
+		esw_warn(esw->dev,
+			 "vport[%d] configure ingress drop rule counter failed\n",
+			 vport->vport);
+		counter = NULL;
+	} else {
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+		dest.counter = counter;
+	}
+
+	/* Drop others rule (star rule) */
 	memset(spec, 0, sizeof(*spec));
 	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
+	if (counter)
+		flow_act.action |= MLX5_FLOW_CONTEXT_ACTION_COUNT;
 	vport->ingress.drop_rule =
-		mlx5_add_flow_rules(vport->ingress.acl, spec,
-				    &flow_act, NULL, 0);
+		mlx5_add_flow_rules(vport->ingress.acl, spec, &flow_act, &dest, 1);
 	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
 		esw_warn(esw->dev,
 			 "vport[%d] configure ingress drop rule, err(%d)\n",
 			 vport->vport, err);
 		vport->ingress.drop_rule = NULL;
-		goto out;
+		if (counter)
+			mlx5_fc_destroy(vport->dev, counter);
 	}
 
 out:
@@ -1362,6 +1392,8 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	bool need_acl_table = vport->info.vlan || vport->info.qos ||
 			      need_vlan_filter;
 	struct mlx5_acl_vlan *trunk_vlan_rule;
+	struct mlx5_flow_destination dest;
+	struct mlx5_fc *counter = NULL;
 	struct mlx5_flow_act flow_act = {0};
 	struct mlx5_flow_spec *spec;
 	u16 vlan_id = 0;
@@ -1454,18 +1486,33 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 		list_add(&trunk_vlan_rule->list, &vport->egress.allowed_vlans_rules);
 	}
 
+	/* Alloc egress drop flow counter */
+	counter = mlx5_fc_create(esw->dev, false);
+	if (IS_ERR(counter)) {
+		esw_warn(esw->dev,
+			 "vport[%d] configure egress drop rule counter failed\n",
+			 vport->vport);
+		counter = NULL;
+	} else {
+		dest.type = MLX5_FLOW_DESTINATION_TYPE_COUNTER;
+		dest.counter = counter;
+	}
+
 	/* Drop others rule (star rule) */
 	memset(spec, 0, sizeof(*spec));
 	flow_act.action = MLX5_FLOW_CONTEXT_ACTION_DROP;
+	if (counter)
+		flow_act.action |= MLX5_FLOW_CONTEXT_ACTION_COUNT;
 	vport->egress.drop_rule =
-		mlx5_add_flow_rules(vport->egress.acl, spec,
-				    &flow_act, NULL, 0);
+		mlx5_add_flow_rules(vport->egress.acl, spec, &flow_act, &dest, 1);
 	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
 		esw_warn(esw->dev,
 			 "vport[%d] configure egress drop rule failed, err(%d)\n",
 			 vport->vport, err);
 		vport->egress.drop_rule = NULL;
+		if (counter)
+			mlx5_fc_destroy(vport->dev, counter);
 	}
 out:
 	if (err)
@@ -2316,6 +2363,38 @@ int mlx5_eswitch_del_vport_trunk_range(struct mlx5_eswitch *esw,
 	return err;
 }
 
+static int mlx5_eswitch_query_vport_drop_stats(struct mlx5_core_dev *dev,
+					       int vport_idx,
+					       u64 *rx_dropped,
+					       u64 *tx_dropped)
+{
+	struct mlx5_eswitch *esw = dev->priv.eswitch;
+	struct mlx5_vport *vport = &esw->vports[vport_idx];
+	struct mlx5_fc *drop_counter;
+	u16 idx = 0;
+	u64 dummy;
+
+	if (!vport->enabled)
+		return 0;
+
+	if (vport->egress.drop_rule) {
+		drop_counter = mlx5_flow_rule_counter(vport->egress.drop_rule);
+		if (drop_counter) {
+			idx = drop_counter->id;
+			mlx5_fc_query(dev, idx, rx_dropped, &dummy);
+		}
+	}
+
+	if (vport->ingress.drop_rule) {
+		drop_counter = mlx5_flow_rule_counter(vport->ingress.drop_rule);
+		if (drop_counter) {
+			idx = drop_counter->id;
+			mlx5_fc_query(dev, idx, tx_dropped, &dummy);
+		}
+	}
+	return 0;
+}
+
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats)
@@ -2376,6 +2455,10 @@ int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 	vf_stats->broadcast =
 		MLX5_GET_CTR(out, received_eth_broadcast.packets);
 
+	mlx5_eswitch_query_vport_drop_stats(esw->dev, vport,
+					    &vf_stats->rx_dropped,
+					    &vf_stats->tx_dropped);
+
 free_out:
 	kvfree(out);
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 5509a752f98e..e86d75fbc0f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -221,6 +221,8 @@ void mlx5_fc_queue_stats_work(struct mlx5_core_dev *dev,
 			      unsigned long delay);
 void mlx5_fc_update_sampling_interval(struct mlx5_core_dev *dev,
 				      unsigned long interval);
+int mlx5_fc_query(struct mlx5_core_dev *dev, u16 id,
+		  u64 *packets, u64 *bytes);
 
 int mlx5_init_fs(struct mlx5_core_dev *dev);
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 89d1f8650033..b7ab929d5f8e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -312,6 +312,12 @@ void mlx5_cleanup_fc_stats(struct mlx5_core_dev *dev)
 	}
 }
 
+int mlx5_fc_query(struct mlx5_core_dev *dev, u16 id,
+		  u64 *packets, u64 *bytes)
+{
+	return mlx5_cmd_fc_query(dev, id, packets, bytes);
+}
+
 void mlx5_fc_query_cached(struct mlx5_fc *counter,
 			  u64 *bytes, u64 *packets, u64 *lastuse)
 {
-- 
2.13.0
