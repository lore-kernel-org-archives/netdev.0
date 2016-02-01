From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 9/9] net/mlx5e: Flow steering support through switchdev
Date: Mon,  1 Feb 2016 08:34:45 +0000
Message-ID: <1454315685-32202-10-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32996 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751414AbcBAIht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:37:49 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse switchdev flow object into device specific commands and program
the hardware to classify and mark/drop the flow accordingly.

A new Kconfig is introduced: MLX5_EN_SWITCHDEV. This config enables to
compile the driver when switchdev is not compiled.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   2 +
 .../net/ethernet/mellanox/mlx5/core/en_switchdev.c | 475 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_switchdev.h |  60 +++
 8 files changed, 568 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index c503ea0..61a9eed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -19,3 +19,10 @@ config MLX5_CORE_EN
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
 	  Ethernet and Infiniband support in ConnectX-4 are currently mutually
 	  exclusive.
+
+config MLX5_EN_SWITCHDEV
+	bool "MLX5 EN switchdev support"
+	depends on MLX5_CORE_EN && NET_SWITCHDEV
+	default y
+	---help---
+	  Switchdev support in Mellanox Technologies ConnectX-4 NIC.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 01c0256..b80143e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -3,6 +3,9 @@ obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o   \
 		mad.o transobj.o vport.o sriov.o fs_cmd.o fs_core.o
+
+mlx5_core-$(CONFIG_MLX5_EN_SWITCHDEV) += en_switchdev.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_fs.o en_ethtool.o en_tx.o en_rx.o \
 		en_txrx.o en_clock.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9ea49a8..e61a67c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -39,6 +39,8 @@
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
 #include <linux/mlx5/vport.h>
+#include <linux/rhashtable.h>
+#include <net/switchdev.h>
 #include "wq.h"
 #include "transobj.h"
 #include "mlx5_core.h"
@@ -497,8 +499,16 @@ struct mlx5e_flow_table {
 	struct mlx5_flow_group		**g;
 };
 
+struct mlx5e_offloads_flow_table {
+	struct mlx5_flow_table		*t;
+
+	struct rhashtable_params        ht_params;
+	struct rhashtable               ht;
+};
+
 struct mlx5e_flow_tables {
 	struct mlx5_flow_namespace	*ns;
+	struct mlx5e_offloads_flow_table      offloads;
 	struct mlx5e_flow_table		vlan;
 	struct mlx5e_flow_table		main;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 80d81ab..0fbe45c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -36,6 +36,7 @@
 #include <linux/tcp.h>
 #include <linux/mlx5/fs.h>
 #include "en.h"
+#include "en_switchdev.h"
 
 #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
 
@@ -1202,12 +1203,18 @@ int mlx5e_create_flow_tables(struct mlx5e_priv *priv)
 	if (err)
 		goto err_destroy_vlan_flow_table;
 
-	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	err = mlx5e_create_offloads_flow_table(priv);
 	if (err)
 		goto err_destroy_main_flow_table;
 
+	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	if (err)
+		goto err_destroy_offloads_flow_table;
+
 	return 0;
 
+err_destroy_offloads_flow_table:
+	mlx5e_destroy_offloads_flow_table(priv);
 err_destroy_main_flow_table:
 	mlx5e_destroy_main_flow_table(priv);
 err_destroy_vlan_flow_table:
@@ -1219,6 +1226,7 @@ err_destroy_vlan_flow_table:
 void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv)
 {
 	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	mlx5e_destroy_offloads_flow_table(priv);
 	mlx5e_destroy_main_flow_table(priv);
 	mlx5e_destroy_vlan_flow_table(priv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5c74a73..4bc9243 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -32,6 +32,7 @@
 
 #include <linux/mlx5/fs.h>
 #include "en.h"
+#include "en_switchdev.h"
 #include "eswitch.h"
 
 struct mlx5e_rq_param {
@@ -2178,6 +2179,7 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	netdev->priv_flags       |= IFF_UNICAST_FLT;
 
+	mlx5e_switchdev_init(netdev);
 	mlx5e_set_netdev_dev_addr(netdev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index dd959d9..678d4e0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -223,6 +223,8 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	if (cqe_has_vlan(cqe))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       be16_to_cpu(cqe->vlan_info));
+
+	skb->mark = be32_to_cpu(cqe->sop_drop_qpn) & 0x00ffffff;
 }
 
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.c b/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.c
new file mode 100644
index 0000000..b88ead4
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.c
@@ -0,0 +1,475 @@
+/*
+ * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
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
+#include <net/switchdev.h>
+#include <linux/mlx5/fs.h>
+#include <linux/mlx5/device.h>
+#include <linux/rhashtable.h>
+#include "en.h"
+#include "en_switchdev.h"
+#include "eswitch.h"
+
+struct mlx5e_switchdev_flow {
+	struct rhash_head	node;
+	unsigned long		cookie;
+	void			*rule;
+};
+
+static int prep_flow_attr(struct switchdev_obj_port_flow *f)
+{
+	struct switchdev_obj_port_flow_act *act = f->actions;
+
+	if (~(BIT(FLOW_DISSECTOR_KEY_CONTROL) |
+	      BIT(FLOW_DISSECTOR_KEY_BASIC) |
+	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_VLANID) |
+	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
+	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS)) & f->dissector->used_keys) {
+		pr_warn("Unsupported key used: 0x%x\n",
+			f->dissector->used_keys);
+		return -ENOTSUPP;
+	}
+
+	if (~(BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_DROP) |
+	      BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK)) & act->actions) {
+		pr_warn("Unsupported action used: 0x%x\n", act->actions);
+		return -ENOTSUPP;
+	}
+
+	if (BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK) & act->actions &&
+	    (act->mark & ~0xffff)) {
+		pr_warn("Bad flow mark - only 16 bit is supported: 0x%x\n",
+			act->mark);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int parse_flow_attr(u32 *match_c, u32 *match_v,
+			   u32 *action, u32 *flow_tag,
+			   struct switchdev_obj_port_flow *f)
+{
+	void *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_c,
+					     outer_headers);
+	void *outer_headers_v = MLX5_ADDR_OF(fte_match_param, match_v,
+					     outer_headers);
+	struct switchdev_obj_port_flow_act *act = f->actions;
+	u16 addr_type = 0;
+	u8 ip_proto = 0;
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_CONTROL)) {
+		struct flow_dissector_key_control *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->key);
+		addr_type = key->addr_type;
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_BASIC)) {
+		struct flow_dissector_key_basic *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->key);
+		struct flow_dissector_key_basic *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_BASIC,
+						  f->mask);
+		ip_proto = key->ip_proto;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ethertype,
+			 ntohs(mask->n_proto));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ethertype,
+			 ntohs(key->n_proto));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 mask->ip_proto);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 key->ip_proto);
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
+		struct flow_dissector_key_eth_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
+						  f->key);
+		struct flow_dissector_key_eth_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_ETH_ADDRS,
+						  f->mask);
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_c, dmac_47_16),
+				mask->dst);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_v, dmac_47_16),
+				key->dst);
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_c, smac_47_16),
+				mask->src);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4,
+					     outer_headers_v, smac_47_16),
+				key->src);
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_VLANID)) {
+		struct flow_dissector_key_tags *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLANID,
+						  f->key);
+		struct flow_dissector_key_tags *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_VLANID,
+						  f->mask);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, vlan_tag, 1);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, vlan_tag, 1);
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, first_vid,
+			 ntohs(mask->vlan_id));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, first_vid,
+			 ntohs(key->vlan_id));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, first_cfi,
+			 ntohs(mask->flow_label));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, first_cfi,
+			 ntohs(key->flow_label));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, first_prio,
+			 ntohs(mask->flow_label) >> 1);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, first_prio,
+			 ntohs(key->flow_label) >> 1);
+	}
+
+	if (addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS) {
+		struct flow_dissector_key_ipv4_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv4_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+						  f->mask);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &mask->src, sizeof(mask->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &key->src, sizeof(key->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &mask->dst, sizeof(mask->dst));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &key->dst, sizeof(key->dst));
+	}
+
+	if (addr_type == FLOW_DISSECTOR_KEY_IPV6_ADDRS) {
+		struct flow_dissector_key_ipv6_addrs *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+						  f->key);
+		struct flow_dissector_key_ipv6_addrs *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_IPV6_ADDRS,
+						  f->mask);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &mask->src, sizeof(mask->src));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    src_ipv4_src_ipv6.ipv6_layout.ipv6),
+		       &key->src, sizeof(key->src));
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &mask->dst, sizeof(mask->dst));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    dst_ipv4_dst_ipv6.ipv6_layout.ipv6),
+		       &key->dst, sizeof(key->dst));
+	}
+
+	if (dissector_uses_key(f->dissector, FLOW_DISSECTOR_KEY_PORTS)) {
+		struct flow_dissector_key_ports *key =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_PORTS,
+						  f->key);
+		struct flow_dissector_key_ports *mask =
+			skb_flow_dissector_target(f->dissector,
+						  FLOW_DISSECTOR_KEY_PORTS,
+						  f->mask);
+		switch (ip_proto) {
+		case IPPROTO_TCP:
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 tcp_sport, ntohs(mask->src));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 tcp_sport, ntohs(key->src));
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 tcp_dport, ntohs(mask->dst));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 tcp_dport, ntohs(key->dst));
+			break;
+
+		case IPPROTO_UDP:
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 udp_sport, ntohs(mask->src));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 udp_sport, ntohs(key->src));
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 udp_dport, ntohs(mask->dst));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 udp_dport, ntohs(key->dst));
+			break;
+		default:
+			pr_err("Only UDP and TCP transport are supported\n");
+			return -EINVAL;
+		}
+	}
+
+	/* Actions: */
+	if (BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK) & act->actions) {
+		*flow_tag = act->mark;
+		*action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
+	}
+
+	if (BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_DROP) & act->actions)
+		*action |= MLX5_FLOW_CONTEXT_ACTION_DROP;
+
+	return 0;
+}
+
+#define MLX5E_TC_FLOW_TABLE_NUM_ENTRIES 10
+#define MLX5E_TC_FLOW_TABLE_NUM_GROUPS 10
+int mlx5e_create_offloads_flow_table(struct mlx5e_priv *priv)
+{
+	struct mlx5_flow_namespace *ns;
+
+	ns = mlx5_get_flow_namespace(priv->mdev,
+				     MLX5_FLOW_NAMESPACE_OFFLOADS);
+	if (!ns)
+		return -EINVAL;
+
+	priv->fts.offloads.t = mlx5_create_auto_grouped_flow_table(ns, 0,
+					    MLX5E_TC_FLOW_TABLE_NUM_ENTRIES,
+					    MLX5E_TC_FLOW_TABLE_NUM_GROUPS);
+	if (IS_ERR(priv->fts.offloads.t))
+		return PTR_ERR(priv->fts.offloads.t);
+
+	return 0;
+}
+
+void mlx5e_destroy_offloads_flow_table(struct mlx5e_priv *priv)
+{
+	mlx5_destroy_flow_table(priv->fts.offloads.t);
+	priv->fts.offloads.t = NULL;
+}
+
+static u8 generate_match_criteria_enable(u32 *match_c)
+{
+	u8 match_criteria_enable = 0;
+	void *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_c,
+					      outer_headers);
+	void *inner_headers_c = MLX5_ADDR_OF(fte_match_param, match_c,
+					      inner_headers);
+	void *misc_c = MLX5_ADDR_OF(fte_match_param, match_c,
+				     misc_parameters);
+	size_t header_size = MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4);
+	size_t misc_size = MLX5_ST_SZ_BYTES(fte_match_set_misc);
+
+	if (memchr_inv(outer_headers_c, 0, header_size))
+		match_criteria_enable |= MLX5_MATCH_OUTER_HEADERS;
+	if (memchr_inv(misc_c, 0, misc_size))
+		match_criteria_enable |= MLX5_MATCH_MISC_PARAMETERS;
+	if (memchr_inv(inner_headers_c, 0, header_size))
+		match_criteria_enable |= MLX5_MATCH_INNER_HEADERS;
+
+	return match_criteria_enable;
+}
+
+static int mlx5e_offloads_flow_add(struct net_device *netdev,
+				   struct switchdev_obj_port_flow *f)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_offloads_flow_table *offloads = &priv->fts.offloads;
+	struct mlx5_flow_table *ft = offloads->t;
+	u8 match_criteria_enable;
+	u32 *match_c;
+	u32 *match_v;
+	int err = 0;
+	u32 flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
+	u32 action = 0;
+	struct mlx5e_switchdev_flow *flow;
+
+	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	if (!match_c || !match_v) {
+		err = -ENOMEM;
+		goto free;
+	}
+
+	flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+	if (!flow) {
+		err = -ENOMEM;
+		goto free;
+	}
+	flow->cookie = f->cookie;
+
+	err = parse_flow_attr(match_c, match_v, &action, &flow_tag, f);
+	if (err < 0)
+		goto free;
+
+	/* Outer header support only */
+	match_criteria_enable = generate_match_criteria_enable(match_c);
+
+	flow->rule = mlx5_add_flow_rule(ft, match_criteria_enable,
+					match_c, match_v,
+					action, flow_tag, NULL);
+	if (IS_ERR(flow->rule)) {
+		kfree(flow);
+		err = PTR_ERR(flow->rule);
+		goto free;
+	}
+
+	err = rhashtable_insert_fast(&offloads->ht, &flow->node,
+				     offloads->ht_params);
+	if (err) {
+		mlx5_del_flow_rule(flow->rule);
+		kfree(flow);
+	}
+
+free:
+	kfree(match_c);
+	kfree(match_v);
+	return err;
+}
+
+static int mlx5e_offloads_flow_del(struct net_device *netdev,
+				   struct switchdev_obj_port_flow *f)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_switchdev_flow *flow;
+	struct mlx5e_offloads_flow_table *offloads = &priv->fts.offloads;
+
+	flow = rhashtable_lookup_fast(&offloads->ht, &f->cookie,
+				      offloads->ht_params);
+	if (!flow) {
+		pr_err("Can't find requested flow");
+		return -EINVAL;
+	}
+
+	mlx5_del_flow_rule(flow->rule);
+
+	rhashtable_remove_fast(&offloads->ht, &flow->node, offloads->ht_params);
+	kfree(flow);
+
+	return 0;
+}
+
+static int mlx5e_port_obj_add(struct net_device *dev,
+			      const struct switchdev_obj *obj,
+			      struct switchdev_trans *trans)
+{
+	int err = 0;
+
+	if (trans->ph_prepare) {
+		switch (obj->id) {
+		case SWITCHDEV_OBJ_ID_PORT_FLOW:
+			err = prep_flow_attr(SWITCHDEV_OBJ_PORT_FLOW(obj));
+			break;
+		default:
+			err = -EOPNOTSUPP;
+			break;
+		}
+
+		return err;
+	}
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_FLOW:
+		err = mlx5e_offloads_flow_add(dev,
+					      SWITCHDEV_OBJ_PORT_FLOW(obj));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+static int mlx5e_port_obj_del(struct net_device *dev,
+			      const struct switchdev_obj *obj)
+{
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_ID_PORT_FLOW:
+		err = mlx5e_offloads_flow_del(dev,
+					      SWITCHDEV_OBJ_PORT_FLOW(obj));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+const struct switchdev_ops mlx5e_switchdev_ops = {
+	.switchdev_port_obj_add = mlx5e_port_obj_add,
+	.switchdev_port_obj_del = mlx5e_port_obj_del,
+};
+
+static const struct rhashtable_params mlx5e_switchdev_flow_ht_params = {
+	.head_offset = offsetof(struct mlx5e_switchdev_flow, node),
+	.key_offset = offsetof(struct mlx5e_switchdev_flow, cookie),
+	.key_len = sizeof(unsigned long),
+	.hashfn = jhash,
+	.automatic_shrinking = true,
+};
+
+void mlx5e_switchdev_init(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_offloads_flow_table *offloads = &priv->fts.offloads;
+
+	netdev->switchdev_ops = &mlx5e_switchdev_ops;
+
+	offloads->ht_params = mlx5e_switchdev_flow_ht_params;
+	rhashtable_init(&offloads->ht, &offloads->ht_params);
+}
+
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.h b/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.h
new file mode 100644
index 0000000..8f4e3a3
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_switchdev.h
@@ -0,0 +1,60 @@
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
+#ifndef __MLX5_EN_SWITCHDEV__H__
+#define __MLX5_EN_SWITCHDEV__H__
+
+#ifdef CONFIG_MLX5_EN_SWITCHDEV
+
+extern const struct switchdev_ops mlx5e_switchdev_ops;
+
+void mlx5e_destroy_offloads_flow_table(struct mlx5e_priv *priv);
+int mlx5e_create_offloads_flow_table(struct mlx5e_priv *priv);
+void mlx5e_switchdev_init(struct net_device *dev);
+
+#else
+static inline void mlx5e_destroy_offloads_flow_table(struct mlx5e_priv *priv)
+{
+}
+
+static inline int mlx5e_create_offloads_flow_table(struct mlx5e_priv *priv)
+{
+	return 0;
+}
+
+static inline void mlx5e_switchdev_init(struct net_device *dev)
+{
+}
+#endif
+
+#endif /* __MLX5_EN_SWITCHDEV__H__ */
+
-- 
2.7.0
