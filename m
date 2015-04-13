From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 10/11] net/mlx5: Ethernet resources handling
Date: Mon, 13 Apr 2015 14:45:00 +0300
Message-ID: <1428925501-2373-11-git-send-email-amirv@mellanox.com>
References: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:60796 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932263AbbDMLqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 07:46:01 -0400
In-Reply-To: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 858 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/flow_table.c   | 422 ++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 169 ++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |  47 ++
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    | 111 +++
 drivers/net/ethernet/mellanox/mlx5/core/vport.h    |  41 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       | 189 +++++
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       | 171 ++++
 include/linux/mlx5/flow_table.h                    |  54 ++
 9 files changed, 2062 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/transobj.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/wq.h
 create mode 100644 include/linux/mlx5/flow_table.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
new file mode 100644
index 0000000..6feebda
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -0,0 +1,858 @@
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
+#include <linux/list.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/mlx5/flow_table.h>
+#include "en.h"
+
+enum {
+	MLX5E_FULLMATCH = 0,
+	MLX5E_ALLMULTI  = 1,
+	MLX5E_PROMISC   = 2,
+};
+
+enum {
+	MLX5E_UC        = 0,
+	MLX5E_MC_IPV4   = 1,
+	MLX5E_MC_IPV6   = 2,
+	MLX5E_MC_OTHER  = 3,
+};
+
+enum {
+	MLX5E_ACTION_NONE = 0,
+	MLX5E_ACTION_ADD  = 1,
+	MLX5E_ACTION_DEL  = 2,
+};
+
+struct mlx5e_eth_addr_hash_node {
+	struct hlist_node          hlist;
+	u8                         action;
+	struct mlx5e_eth_addr_info ai;
+};
+
+static inline int mlx5e_hash_eth_addr(u8 *addr)
+{
+	return addr[5];
+}
+
+static void mlx5e_add_eth_addr_to_hash(struct hlist_head *hash, u8 *addr)
+{
+	struct mlx5e_eth_addr_hash_node *hn;
+	int ix = mlx5e_hash_eth_addr(addr);
+	int found = 0;
+
+	hlist_for_each_entry(hn, &hash[ix], hlist)
+		if (ether_addr_equal_64bits(hn->ai.addr, addr)) {
+			found = 1;
+			break;
+		}
+
+	if (found) {
+		hn->action = MLX5E_ACTION_NONE;
+		return;
+	}
+
+	hn = kzalloc(sizeof(*hn), GFP_ATOMIC);
+	if (!hn)
+		return;
+
+	ether_addr_copy(hn->ai.addr, addr);
+	hn->action = MLX5E_ACTION_ADD;
+
+	hlist_add_head(&hn->hlist, &hash[ix]);
+}
+
+static void mlx5e_del_eth_addr_from_hash(struct mlx5e_eth_addr_hash_node *hn)
+{
+	hlist_del(&hn->hlist);
+	kfree(hn);
+}
+
+static void mlx5e_del_eth_addr_from_flow_table(struct mlx5e_priv *priv,
+					       struct mlx5e_eth_addr_info *ai)
+{
+	void *ft = priv->ft.main;
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV6_TCP))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6_TCP]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV4_TCP))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4_TCP]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV6_UDP))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6_UDP]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV4_UDP))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4_UDP]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV6))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV6]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_IPV4))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_IPV4]);
+
+	if (ai->tt_vec & (1 << MLX5E_TT_ANY))
+		mlx5_del_flow_table_entry(ft, ai->ft_ix[MLX5E_TT_ANY]);
+}
+
+static int mlx5e_get_eth_addr_type(u8 *addr)
+{
+	if (is_unicast_ether_addr(addr))
+		return MLX5E_UC;
+
+	if ((addr[0] == 0x01) &&
+	    (addr[1] == 0x00) &&
+	    (addr[2] == 0x5e) &&
+	   !(addr[3] &  0x80))
+		return MLX5E_MC_IPV4;
+
+	if ((addr[0] == 0x33) &&
+	    (addr[1] == 0x33))
+		return MLX5E_MC_IPV6;
+
+	return MLX5E_MC_OTHER;
+}
+
+static u32 mlx5e_get_tt_vec(struct mlx5e_eth_addr_info *ai, int type)
+{
+	int eth_addr_type;
+	u32 ret;
+
+	switch (type) {
+	case MLX5E_FULLMATCH:
+		eth_addr_type = mlx5e_get_eth_addr_type(ai->addr);
+		switch (eth_addr_type) {
+		case MLX5E_UC:
+			ret =
+				(1 << MLX5E_TT_IPV4_TCP) |
+				(1 << MLX5E_TT_IPV6_TCP) |
+				(1 << MLX5E_TT_IPV4_UDP) |
+				(1 << MLX5E_TT_IPV6_UDP) |
+				(1 << MLX5E_TT_IPV4)     |
+				(1 << MLX5E_TT_IPV6)     |
+				(1 << MLX5E_TT_ANY)      |
+				0;
+			break;
+
+		case MLX5E_MC_IPV4:
+			ret =
+				(1 << MLX5E_TT_IPV4_UDP) |
+				(1 << MLX5E_TT_IPV4)     |
+				0;
+			break;
+
+		case MLX5E_MC_IPV6:
+			ret =
+				(1 << MLX5E_TT_IPV6_UDP) |
+				(1 << MLX5E_TT_IPV6)     |
+				0;
+			break;
+
+		case MLX5E_MC_OTHER:
+			ret =
+				(1 << MLX5E_TT_ANY)      |
+				0;
+			break;
+		}
+
+		break;
+
+	case MLX5E_ALLMULTI:
+		ret =
+			(1 << MLX5E_TT_IPV4_UDP) |
+			(1 << MLX5E_TT_IPV6_UDP) |
+			(1 << MLX5E_TT_IPV4)     |
+			(1 << MLX5E_TT_IPV6)     |
+			(1 << MLX5E_TT_ANY)      |
+			0;
+		break;
+
+	default: /* MLX5E_PROMISC */
+		ret =
+			(1 << MLX5E_TT_IPV4_TCP) |
+			(1 << MLX5E_TT_IPV6_TCP) |
+			(1 << MLX5E_TT_IPV4_UDP) |
+			(1 << MLX5E_TT_IPV6_UDP) |
+			(1 << MLX5E_TT_IPV4)     |
+			(1 << MLX5E_TT_IPV6)     |
+			(1 << MLX5E_TT_ANY)      |
+			0;
+		break;
+	}
+
+	return ret;
+}
+
+static int __mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
+				     struct mlx5e_eth_addr_info *ai, int type,
+				     void *flow_context, void *match_criteria)
+{
+	u8 match_criteria_enable = 0;
+	void *match_value;
+	void *dest;
+	u8   *dmac;
+	u8   *match_criteria_dmac;
+	void *ft   = priv->ft.main;
+	u32  *tirn = priv->tirn;
+	u32  tt_vec;
+	int  err;
+
+	match_value = MLX5_ADDR_OF(flow_context, flow_context, match_value);
+	dmac = MLX5_ADDR_OF(fte_match_param, match_value,
+			    outer_headers.dmac_47_16);
+	match_criteria_dmac = MLX5_ADDR_OF(fte_match_param, match_criteria,
+					   outer_headers.dmac_47_16);
+	dest = MLX5_ADDR_OF(flow_context, flow_context, destination);
+
+	MLX5_SET(flow_context, flow_context, action,
+		 MLX5_FLOW_CONTEXT_ACTION_FWD_DEST);
+	MLX5_SET(flow_context, flow_context, destination_list_size, 1);
+	MLX5_SET(dest_format_struct, dest, destination_type,
+		 MLX5_FLOW_CONTEXT_DEST_TYPE_TIR);
+
+	switch (type) {
+	case MLX5E_FULLMATCH:
+		match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+		memset(match_criteria_dmac, 0xff, ETH_ALEN);
+		ether_addr_copy(dmac, ai->addr);
+		break;
+
+	case MLX5E_ALLMULTI:
+		match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+		match_criteria_dmac[0] = 0x01;
+		dmac[0] = 0x01;
+		break;
+
+	case MLX5E_PROMISC:
+		break;
+	}
+
+	tt_vec = mlx5e_get_tt_vec(ai, type);
+
+	if (tt_vec & (1 << MLX5E_TT_ANY)) {
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_ANY]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_ANY]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_ANY);
+	}
+
+	match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
+			 outer_headers.ethertype);
+
+	if (tt_vec & (1 << MLX5E_TT_IPV4)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IP);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV4]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV4]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV4);
+	}
+
+	if (tt_vec & (1 << MLX5E_TT_IPV6)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IPV6);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV6]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV6]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV6);
+	}
+
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
+			 outer_headers.ip_protocol);
+	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
+		 IPPROTO_UDP);
+
+	if (tt_vec & (1 << MLX5E_TT_IPV4_UDP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IP);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV4_UDP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV4_UDP]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV4_UDP);
+	}
+
+	if (tt_vec & (1 << MLX5E_TT_IPV6_UDP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IPV6);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV6_UDP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV6_UDP]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV6_UDP);
+	}
+
+	MLX5_SET(fte_match_param, match_value, outer_headers.ip_protocol,
+		 IPPROTO_TCP);
+
+	if (tt_vec & (1 << MLX5E_TT_IPV4_TCP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IP);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV4_TCP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV4_TCP]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV4_TCP);
+	}
+
+	if (tt_vec & (1 << MLX5E_TT_IPV6_TCP)) {
+		MLX5_SET(fte_match_param, match_value, outer_headers.ethertype,
+			 ETH_P_IPV6);
+		MLX5_SET(dest_format_struct, dest, destination_id,
+			 tirn[MLX5E_TT_IPV6_TCP]);
+		err = mlx5_add_flow_table_entry(ft, match_criteria_enable,
+						match_criteria, flow_context,
+						&ai->ft_ix[MLX5E_TT_IPV6_TCP]);
+		if (err) {
+			mlx5e_del_eth_addr_from_flow_table(priv, ai);
+			return err;
+		}
+		ai->tt_vec |= (1 << MLX5E_TT_IPV6_TCP);
+	}
+
+	return 0;
+}
+
+static int mlx5e_add_eth_addr_rule(struct mlx5e_priv *priv,
+				   struct mlx5e_eth_addr_info *ai, int type)
+{
+	u32 *flow_context;
+	u32 *match_criteria;
+	int err;
+
+	flow_context   = mlx5_vzalloc(MLX5_ST_SZ_BYTES(flow_context) +
+				      MLX5_ST_SZ_BYTES(dest_format_struct));
+	match_criteria = mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
+	if (!flow_context || !match_criteria) {
+		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
+		err = -ENOMEM;
+		goto add_eth_addr_rule_out;
+	}
+
+	err = __mlx5e_add_eth_addr_rule(priv, ai, type, flow_context,
+					match_criteria);
+	if (err)
+		netdev_err(priv->netdev, "%s: failed\n", __func__);
+
+add_eth_addr_rule_out:
+	kvfree(match_criteria);
+	kvfree(flow_context);
+	return err;
+}
+
+enum mlx5e_vlan_rule_type {
+	MLX5E_VLAN_RULE_TYPE_UNTAGGED,
+	MLX5E_VLAN_RULE_TYPE_ANY_VID,
+	MLX5E_VLAN_RULE_TYPE_MATCH_VID,
+};
+
+static int mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
+			       enum mlx5e_vlan_rule_type rule_type, u16 vid)
+{
+	u8 match_criteria_enable = 0;
+	u32 *flow_context;
+	void *match_value;
+	void *dest;
+	u32 *match_criteria;
+	u32 *ft_ix;
+	int err;
+
+	flow_context   = mlx5_vzalloc(MLX5_ST_SZ_BYTES(flow_context) +
+				      MLX5_ST_SZ_BYTES(dest_format_struct));
+	match_criteria = mlx5_vzalloc(MLX5_ST_SZ_BYTES(fte_match_param));
+	if (!flow_context || !match_criteria) {
+		netdev_err(priv->netdev, "%s: alloc failed\n", __func__);
+		err = -ENOMEM;
+		goto add_vlan_rule_out;
+	}
+	match_value = MLX5_ADDR_OF(flow_context, flow_context, match_value);
+	dest = MLX5_ADDR_OF(flow_context, flow_context, destination);
+
+	MLX5_SET(flow_context, flow_context, action,
+		 MLX5_FLOW_CONTEXT_ACTION_FWD_DEST);
+	MLX5_SET(flow_context, flow_context, destination_list_size, 1);
+	MLX5_SET(dest_format_struct, dest, destination_type,
+		 MLX5_FLOW_CONTEXT_DEST_TYPE_FLOW_TABLE);
+	MLX5_SET(dest_format_struct, dest, destination_id,
+		 mlx5_get_flow_table_id(priv->ft.main));
+
+	match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, match_criteria,
+			 outer_headers.vlan_tag);
+
+	switch (rule_type) {
+	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
+		ft_ix = &priv->vlan.untagged_rule_ft_ix;
+		break;
+	case MLX5E_VLAN_RULE_TYPE_ANY_VID:
+		ft_ix = &priv->vlan.any_vlan_rule_ft_ix;
+		MLX5_SET(fte_match_param, match_value, outer_headers.vlan_tag,
+			 1);
+		break;
+	default: /* MLX5E_VLAN_RULE_TYPE_MATCH_VID */
+		ft_ix = &priv->vlan.active_vlans_ft_ix[vid];
+		MLX5_SET(fte_match_param, match_value, outer_headers.vlan_tag,
+			 1);
+		MLX5_SET_TO_ONES(fte_match_param, match_criteria,
+				 outer_headers.first_vid);
+		MLX5_SET(fte_match_param, match_value, outer_headers.first_vid,
+			 vid);
+		break;
+	}
+
+	err = mlx5_add_flow_table_entry(priv->ft.vlan, match_criteria_enable,
+					match_criteria, flow_context, ft_ix);
+	if (err)
+		netdev_err(priv->netdev, "%s: failed\n", __func__);
+
+add_vlan_rule_out:
+	kvfree(match_criteria);
+	kvfree(flow_context);
+	return err;
+}
+
+static void mlx5e_del_vlan_rule(struct mlx5e_priv *priv,
+				enum mlx5e_vlan_rule_type rule_type, u16 vid)
+{
+	switch (rule_type) {
+	case MLX5E_VLAN_RULE_TYPE_UNTAGGED:
+		mlx5_del_flow_table_entry(priv->ft.vlan,
+					  priv->vlan.untagged_rule_ft_ix);
+		break;
+	case MLX5E_VLAN_RULE_TYPE_ANY_VID:
+		mlx5_del_flow_table_entry(priv->ft.vlan,
+					  priv->vlan.any_vlan_rule_ft_ix);
+		break;
+	case MLX5E_VLAN_RULE_TYPE_MATCH_VID:
+		mlx5_del_flow_table_entry(priv->ft.vlan,
+					  priv->vlan.active_vlans_ft_ix[vid]);
+		break;
+	}
+}
+
+void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv)
+{
+	WARN_ON(!mutex_is_locked(&priv->state_lock));
+
+	if (priv->vlan.filter_disabled) {
+		priv->vlan.filter_disabled = false;
+		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+			mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
+					    0);
+	}
+}
+
+void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv)
+{
+	WARN_ON(!mutex_is_locked(&priv->state_lock));
+
+	if (!priv->vlan.filter_disabled) {
+		priv->vlan.filter_disabled = true;
+		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+			mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
+					    0);
+	}
+}
+
+int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
+			  u16 vid)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int err = 0;
+
+	mutex_lock(&priv->state_lock);
+
+	set_bit(vid, priv->vlan.active_vlans);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID,
+					  vid);
+
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
+int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
+			   u16 vid)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mutex_lock(&priv->state_lock);
+
+	clear_bit(vid, priv->vlan.active_vlans);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
+
+	mutex_unlock(&priv->state_lock);
+
+	return 0;
+}
+
+int mlx5e_add_all_vlan_rules(struct mlx5e_priv *priv)
+{
+	u16 vid;
+	int err;
+
+	for_each_set_bit(vid, priv->vlan.active_vlans, VLAN_N_VID) {
+		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID,
+					  vid);
+		if (err)
+			return err;
+	}
+
+	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	if (err)
+		return err;
+
+	if (priv->vlan.filter_disabled) {
+		err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID,
+					  0);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+void mlx5e_del_all_vlan_rules(struct mlx5e_priv *priv)
+{
+	u16 vid;
+
+	if (priv->vlan.filter_disabled)
+		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
+
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+
+	for_each_set_bit(vid, priv->vlan.active_vlans, VLAN_N_VID)
+		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
+}
+
+#define mlx5e_for_each_hash_node(hn, tmp, hash, i) \
+	for (i = 0; i < MLX5E_ETH_ADDR_HASH_SIZE; i++) \
+		hlist_for_each_entry_safe(hn, tmp, &hash[i], hlist)
+
+static void mlx5e_execute_action(struct mlx5e_priv *priv,
+				 struct mlx5e_eth_addr_hash_node *hn)
+{
+	switch (hn->action) {
+	case MLX5E_ACTION_ADD:
+		mlx5e_add_eth_addr_rule(priv, &hn->ai, MLX5E_FULLMATCH);
+		hn->action = MLX5E_ACTION_NONE;
+		break;
+
+	case MLX5E_ACTION_DEL:
+		mlx5e_del_eth_addr_from_flow_table(priv, &hn->ai);
+		mlx5e_del_eth_addr_from_hash(hn);
+		break;
+	}
+}
+
+static void mlx5e_sync_netdev_addr(struct mlx5e_priv *priv)
+{
+	struct net_device *netdev = priv->netdev;
+	struct netdev_hw_addr *ha;
+
+	netif_addr_lock_bh(netdev);
+
+	mlx5e_add_eth_addr_to_hash(priv->eth_addr.netdev_uc,
+				   priv->netdev->dev_addr);
+
+	netdev_for_each_uc_addr(ha, netdev)
+		mlx5e_add_eth_addr_to_hash(priv->eth_addr.netdev_uc, ha->addr);
+
+	netdev_for_each_mc_addr(ha, netdev)
+		mlx5e_add_eth_addr_to_hash(priv->eth_addr.netdev_mc, ha->addr);
+
+	netif_addr_unlock_bh(netdev);
+}
+
+static void mlx5e_apply_netdev_addr(struct mlx5e_priv *priv)
+{
+	struct mlx5e_eth_addr_hash_node *hn;
+	struct hlist_node *tmp;
+	int i;
+
+	mlx5e_for_each_hash_node(hn, tmp, priv->eth_addr.netdev_uc, i)
+		mlx5e_execute_action(priv, hn);
+
+	mlx5e_for_each_hash_node(hn, tmp, priv->eth_addr.netdev_mc, i)
+		mlx5e_execute_action(priv, hn);
+}
+
+static void mlx5e_handle_netdev_addr(struct mlx5e_priv *priv)
+{
+	struct mlx5e_eth_addr_hash_node *hn;
+	struct hlist_node *tmp;
+	int i;
+
+	mlx5e_for_each_hash_node(hn, tmp, priv->eth_addr.netdev_uc, i)
+		hn->action = MLX5E_ACTION_DEL;
+	mlx5e_for_each_hash_node(hn, tmp, priv->eth_addr.netdev_mc, i)
+		hn->action = MLX5E_ACTION_DEL;
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_sync_netdev_addr(priv);
+
+	mlx5e_apply_netdev_addr(priv);
+}
+
+void mlx5e_set_rx_mode_core(struct mlx5e_priv *priv)
+{
+	struct mlx5e_eth_addr_db *ea = &priv->eth_addr;
+	struct net_device *ndev = priv->netdev;
+
+	bool rx_mode_enable   = test_bit(MLX5E_STATE_OPENED, &priv->state);
+	bool promisc_enabled   = rx_mode_enable && (ndev->flags & IFF_PROMISC);
+	bool allmulti_enabled  = rx_mode_enable && (ndev->flags & IFF_ALLMULTI);
+	bool broadcast_enabled = rx_mode_enable;
+
+	bool enable_promisc    = !ea->promisc_enabled   &&  promisc_enabled;
+	bool disable_promisc   =  ea->promisc_enabled   && !promisc_enabled;
+	bool enable_allmulti   = !ea->allmulti_enabled  &&  allmulti_enabled;
+	bool disable_allmulti  =  ea->allmulti_enabled  && !allmulti_enabled;
+	bool enable_broadcast  = !ea->broadcast_enabled &&  broadcast_enabled;
+	bool disable_broadcast =  ea->broadcast_enabled && !broadcast_enabled;
+
+	if (enable_promisc)
+		mlx5e_add_eth_addr_rule(priv, &ea->promisc, MLX5E_PROMISC);
+	if (enable_allmulti)
+		mlx5e_add_eth_addr_rule(priv, &ea->allmulti, MLX5E_ALLMULTI);
+	if (enable_broadcast)
+		mlx5e_add_eth_addr_rule(priv, &ea->broadcast, MLX5E_FULLMATCH);
+
+	mlx5e_handle_netdev_addr(priv);
+
+	if (disable_broadcast)
+		mlx5e_del_eth_addr_from_flow_table(priv, &ea->broadcast);
+	if (disable_allmulti)
+		mlx5e_del_eth_addr_from_flow_table(priv, &ea->allmulti);
+	if (disable_promisc)
+		mlx5e_del_eth_addr_from_flow_table(priv, &ea->promisc);
+
+	ea->promisc_enabled   = promisc_enabled;
+	ea->allmulti_enabled  = allmulti_enabled;
+	ea->broadcast_enabled = broadcast_enabled;
+}
+
+void mlx5e_set_rx_mode_work(struct work_struct *work)
+{
+	struct mlx5e_priv *priv = container_of(work, struct mlx5e_priv,
+					       set_rx_mode_work);
+
+	mutex_lock(&priv->state_lock);
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_set_rx_mode_core(priv);
+	mutex_unlock(&priv->state_lock);
+}
+
+void mlx5e_init_eth_addr(struct mlx5e_priv *priv)
+{
+	ether_addr_copy(priv->eth_addr.broadcast.addr, priv->netdev->broadcast);
+}
+
+static int mlx5e_create_main_flow_table(struct mlx5e_priv *priv)
+{
+	struct mlx5_flow_table_group *g;
+	u8 *dmac;
+
+	g = kcalloc(9, sizeof(*g), GFP_KERNEL);
+
+	g[0].log_sz = 2;
+	g[0].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, g[0].match_criteria,
+			 outer_headers.ethertype);
+	MLX5_SET_TO_ONES(fte_match_param, g[0].match_criteria,
+			 outer_headers.ip_protocol);
+
+	g[1].log_sz = 1;
+	g[1].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, g[1].match_criteria,
+			 outer_headers.ethertype);
+
+	g[2].log_sz = 0;
+
+	g[3].log_sz = 14;
+	g[3].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[3].match_criteria,
+			    outer_headers.dmac_47_16);
+	memset(dmac, 0xff, ETH_ALEN);
+	MLX5_SET_TO_ONES(fte_match_param, g[3].match_criteria,
+			 outer_headers.ethertype);
+	MLX5_SET_TO_ONES(fte_match_param, g[3].match_criteria,
+			 outer_headers.ip_protocol);
+
+	g[4].log_sz = 13;
+	g[4].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[4].match_criteria,
+			    outer_headers.dmac_47_16);
+	memset(dmac, 0xff, ETH_ALEN);
+	MLX5_SET_TO_ONES(fte_match_param, g[4].match_criteria,
+			 outer_headers.ethertype);
+
+	g[5].log_sz = 11;
+	g[5].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[5].match_criteria,
+			    outer_headers.dmac_47_16);
+	memset(dmac, 0xff, ETH_ALEN);
+
+	g[6].log_sz = 2;
+	g[6].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[6].match_criteria,
+			    outer_headers.dmac_47_16);
+	dmac[0] = 0x01;
+	MLX5_SET_TO_ONES(fte_match_param, g[6].match_criteria,
+			 outer_headers.ethertype);
+	MLX5_SET_TO_ONES(fte_match_param, g[6].match_criteria,
+			 outer_headers.ip_protocol);
+
+	g[7].log_sz = 1;
+	g[7].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[7].match_criteria,
+			    outer_headers.dmac_47_16);
+	dmac[0] = 0x01;
+	MLX5_SET_TO_ONES(fte_match_param, g[7].match_criteria,
+			 outer_headers.ethertype);
+
+	g[8].log_sz = 0;
+	g[8].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	dmac = MLX5_ADDR_OF(fte_match_param, g[8].match_criteria,
+			    outer_headers.dmac_47_16);
+	dmac[0] = 0x01;
+	priv->ft.main = mlx5_create_flow_table(priv->mdev, 1,
+					       MLX5_FLOW_TABLE_TYPE_NIC_RCV,
+					       9, g);
+	kfree(g);
+
+	return priv->ft.main ? 0 : -ENOMEM;
+}
+
+static void mlx5e_destroy_main_flow_table(struct mlx5e_priv *priv)
+{
+	mlx5_destroy_flow_table(priv->ft.main);
+}
+
+static int mlx5e_create_vlan_flow_table(struct mlx5e_priv *priv)
+{
+	struct mlx5_flow_table_group *g;
+
+	g = kcalloc(2, sizeof(*g), GFP_KERNEL);
+	if (!g)
+		return -ENOMEM;
+
+	g[0].log_sz = 12;
+	g[0].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, g[0].match_criteria,
+			 outer_headers.vlan_tag);
+	MLX5_SET_TO_ONES(fte_match_param, g[0].match_criteria,
+			 outer_headers.first_vid);
+
+	/* untagged + any vlan id */
+	g[1].log_sz = 1;
+	g[1].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
+	MLX5_SET_TO_ONES(fte_match_param, g[1].match_criteria,
+			 outer_headers.vlan_tag);
+
+	priv->ft.vlan = mlx5_create_flow_table(priv->mdev, 0,
+					       MLX5_FLOW_TABLE_TYPE_NIC_RCV,
+					       2, g);
+
+	kfree(g);
+	return priv->ft.vlan ? 0 : -ENOMEM;
+}
+
+static void mlx5e_destroy_vlan_flow_table(struct mlx5e_priv *priv)
+{
+	mlx5_destroy_flow_table(priv->ft.vlan);
+}
+
+int mlx5e_open_flow_table(struct mlx5e_priv *priv)
+{
+	int err;
+
+	err = mlx5e_create_main_flow_table(priv);
+	if (err)
+		return err;
+
+	err = mlx5e_create_vlan_flow_table(priv);
+	if (err)
+		goto err_destroy_main_flow_table;
+
+	return 0;
+
+err_destroy_main_flow_table:
+	mlx5e_destroy_main_flow_table(priv);
+
+	return err;
+}
+
+void mlx5e_close_flow_table(struct mlx5e_priv *priv)
+{
+	mlx5e_destroy_vlan_flow_table(priv);
+	mlx5e_destroy_main_flow_table(priv);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
new file mode 100644
index 0000000..ca90b9b
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/flow_table.c
@@ -0,0 +1,422 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#include <linux/export.h>
+#include <linux/mlx5/driver.h>
+#include <linux/mlx5/flow_table.h>
+#include "mlx5_core.h"
+
+struct mlx5_ftg {
+	struct mlx5_flow_table_group    g;
+	u32				id;
+	u32				start_ix;
+};
+
+struct mlx5_flow_table {
+	struct mlx5_core_dev	*dev;
+	u8			level;
+	u8			type;
+	u32			id;
+	struct mutex		mutex; /* sync bitmap alloc */
+	u16			num_groups;
+	struct mlx5_ftg		*group;
+	unsigned long		*bitmap;
+	u32			size;
+};
+
+static int mlx5_set_flow_entry_cmd(struct mlx5_flow_table *ft, u32 group_ix,
+				   u32 flow_index, void *flow_context)
+{
+	u32 out[MLX5_ST_SZ_DW(set_fte_out)];
+	u32 *in;
+	void *in_flow_context;
+	int fcdls =
+		MLX5_GET(flow_context, flow_context, destination_list_size) *
+		MLX5_ST_SZ_BYTES(dest_format_struct);
+	int inlen = MLX5_ST_SZ_BYTES(set_fte_in) + fcdls;
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in) {
+		mlx5_core_warn(ft->dev, "failed to allocate inbox\n");
+		return -ENOMEM;
+	}
+
+	MLX5_SET(set_fte_in, in, table_type, ft->type);
+	MLX5_SET(set_fte_in, in, table_id,   ft->id);
+	MLX5_SET(set_fte_in, in, flow_index, flow_index);
+	MLX5_SET(set_fte_in, in, opcode, MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY);
+
+	in_flow_context = MLX5_ADDR_OF(set_fte_in, in, flow_context);
+	memcpy(in_flow_context, flow_context,
+	       MLX5_ST_SZ_BYTES(flow_context) + fcdls);
+
+	MLX5_SET(flow_context, in_flow_context, group_id,
+		 ft->group[group_ix].id);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(ft->dev, in, inlen, out,
+					 sizeof(out));
+	kvfree(in);
+
+	return err;
+}
+
+static void mlx5_del_flow_entry_cmd(struct mlx5_flow_table *ft, u32 flow_index)
+{
+	u32 in[MLX5_ST_SZ_DW(delete_fte_in)];
+	u32 out[MLX5_ST_SZ_DW(delete_fte_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+#define MLX5_SET_DFTEI(p, x, v) MLX5_SET(delete_fte_in, p, x, v)
+	MLX5_SET_DFTEI(in, table_type, ft->type);
+	MLX5_SET_DFTEI(in, table_id,   ft->id);
+	MLX5_SET_DFTEI(in, flow_index, flow_index);
+	MLX5_SET_DFTEI(in, opcode,     MLX5_CMD_OP_DELETE_FLOW_TABLE_ENTRY);
+
+	mlx5_cmd_exec_check_status(ft->dev, in, sizeof(in), out, sizeof(out));
+}
+
+static void mlx5_destroy_flow_group_cmd(struct mlx5_flow_table *ft, int i)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_flow_group_in)];
+	u32 out[MLX5_ST_SZ_DW(destroy_flow_group_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+#define MLX5_SET_DFGI(p, x, v) MLX5_SET(destroy_flow_group_in, p, x, v)
+	MLX5_SET_DFGI(in, table_type, ft->type);
+	MLX5_SET_DFGI(in, table_id,   ft->id);
+	MLX5_SET_DFGI(in, opcode, MLX5_CMD_OP_DESTROY_FLOW_GROUP);
+	MLX5_SET_DFGI(in, group_id, ft->group[i].id);
+	mlx5_cmd_exec_check_status(ft->dev, in, sizeof(in), out, sizeof(out));
+}
+
+static int mlx5_create_flow_group_cmd(struct mlx5_flow_table *ft, int i)
+{
+	u32 out[MLX5_ST_SZ_DW(create_flow_group_out)];
+	u32 *in;
+	void *in_match_criteria;
+	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_table_group *g = &ft->group[i].g;
+	u32 start_ix = ft->group[i].start_ix;
+	u32 end_ix = start_ix + (1 << g->log_sz) - 1;
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in) {
+		mlx5_core_warn(ft->dev, "failed to allocate inbox\n");
+		return -ENOMEM;
+	}
+	in_match_criteria = MLX5_ADDR_OF(create_flow_group_in, in,
+					 match_criteria);
+
+	memset(out, 0, sizeof(out));
+
+#define MLX5_SET_CFGI(p, x, v) MLX5_SET(create_flow_group_in, p, x, v)
+	MLX5_SET_CFGI(in, table_type,            ft->type);
+	MLX5_SET_CFGI(in, table_id,              ft->id);
+	MLX5_SET_CFGI(in, opcode,                MLX5_CMD_OP_CREATE_FLOW_GROUP);
+	MLX5_SET_CFGI(in, start_flow_index,      start_ix);
+	MLX5_SET_CFGI(in, end_flow_index,        end_ix);
+	MLX5_SET_CFGI(in, match_criteria_enable, g->match_criteria_enable);
+
+	memcpy(in_match_criteria, g->match_criteria,
+	       MLX5_ST_SZ_BYTES(fte_match_param));
+
+	err = mlx5_cmd_exec_check_status(ft->dev, in, inlen, out,
+					 sizeof(out));
+	if (!err)
+		ft->group[i].id = MLX5_GET(create_flow_group_out, out,
+					   group_id);
+
+	kvfree(in);
+
+	return err;
+}
+
+static void mlx5_destroy_flow_table_groups(struct mlx5_flow_table *ft)
+{
+	int i;
+
+	for (i = 0; i < ft->num_groups; i++)
+		mlx5_destroy_flow_group_cmd(ft, i);
+}
+
+static int mlx5_create_flow_table_groups(struct mlx5_flow_table *ft)
+{
+	int err;
+	int i;
+
+	for (i = 0; i < ft->num_groups; i++) {
+		err = mlx5_create_flow_group_cmd(ft, i);
+		if (err)
+			goto err_destroy_flow_table_groups;
+	}
+
+	return 0;
+
+err_destroy_flow_table_groups:
+	for (i--; i >= 0; i--)
+		mlx5_destroy_flow_group_cmd(ft, i);
+
+	return err;
+}
+
+static int mlx5_create_flow_table_cmd(struct mlx5_flow_table *ft)
+{
+	u32 in[MLX5_ST_SZ_DW(create_flow_table_in)];
+	u32 out[MLX5_ST_SZ_DW(create_flow_table_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(create_flow_table_in, in, table_type, ft->type);
+	MLX5_SET(create_flow_table_in, in, level,      ft->level);
+	MLX5_SET(create_flow_table_in, in, log_size,   order_base_2(ft->size));
+
+	MLX5_SET(create_flow_table_in, in, opcode,
+		 MLX5_CMD_OP_CREATE_FLOW_TABLE);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(ft->dev, in, sizeof(in), out,
+					 sizeof(out));
+	if (err)
+		return err;
+
+	ft->id = MLX5_GET(create_flow_table_out, out, table_id);
+
+	return 0;
+}
+
+static void mlx5_destroy_flow_table_cmd(struct mlx5_flow_table *ft)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_flow_table_in)];
+	u32 out[MLX5_ST_SZ_DW(destroy_flow_table_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+#define MLX5_SET_DFTI(p, x, v) MLX5_SET(destroy_flow_table_in, p, x, v)
+	MLX5_SET_DFTI(in, table_type, ft->type);
+	MLX5_SET_DFTI(in, table_id,   ft->id);
+	MLX5_SET_DFTI(in, opcode, MLX5_CMD_OP_DESTROY_FLOW_TABLE);
+
+	mlx5_cmd_exec_check_status(ft->dev, in, sizeof(in), out, sizeof(out));
+}
+
+static int mlx5_find_group(struct mlx5_flow_table *ft, u8 match_criteria_enable,
+			   u32 *match_criteria, int *group_ix)
+{
+	void *mc_outer = MLX5_ADDR_OF(fte_match_param, match_criteria,
+				      outer_headers);
+	void *mc_misc  = MLX5_ADDR_OF(fte_match_param, match_criteria,
+				      misc_parameters);
+	void *mc_inner = MLX5_ADDR_OF(fte_match_param, match_criteria,
+				      inner_headers);
+	int mc_outer_sz = MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4);
+	int mc_misc_sz  = MLX5_ST_SZ_BYTES(fte_match_set_misc);
+	int mc_inner_sz = MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4);
+	int i;
+
+	for (i = 0; i < ft->num_groups; i++) {
+		struct mlx5_flow_table_group *g = &ft->group[i].g;
+		void *gmc_outer = MLX5_ADDR_OF(fte_match_param,
+					       g->match_criteria,
+					       outer_headers);
+		void *gmc_misc  = MLX5_ADDR_OF(fte_match_param,
+					       g->match_criteria,
+					       misc_parameters);
+		void *gmc_inner = MLX5_ADDR_OF(fte_match_param,
+					       g->match_criteria,
+					       inner_headers);
+
+		if (g->match_criteria_enable != match_criteria_enable)
+			continue;
+
+		if (match_criteria_enable & MLX5_MATCH_OUTER_HEADERS)
+			if (memcmp(mc_outer, gmc_outer, mc_outer_sz))
+				continue;
+
+		if (match_criteria_enable & MLX5_MATCH_MISC_PARAMETERS)
+			if (memcmp(mc_misc, gmc_misc, mc_misc_sz))
+				continue;
+
+		if (match_criteria_enable & MLX5_MATCH_INNER_HEADERS)
+			if (memcmp(mc_inner, gmc_inner, mc_inner_sz))
+				continue;
+
+		*group_ix = i;
+		return 0;
+	}
+
+	return -EINVAL;
+}
+
+static int alloc_flow_index(struct mlx5_flow_table *ft, int group_ix, u32 *ix)
+{
+	struct mlx5_ftg *g = &ft->group[group_ix];
+	int err = 0;
+
+	mutex_lock(&ft->mutex);
+
+	*ix = find_next_zero_bit(ft->bitmap, ft->size, g->start_ix);
+	if (*ix >= (g->start_ix + (1 << g->g.log_sz)))
+		err = -ENOSPC;
+	else
+		__set_bit(*ix, ft->bitmap);
+
+	mutex_unlock(&ft->mutex);
+
+	return err;
+}
+
+static void mlx5_free_flow_index(struct mlx5_flow_table *ft, u32 ix)
+{
+	__clear_bit(ix, ft->bitmap);
+}
+
+int mlx5_add_flow_table_entry(void *flow_table, u8 match_criteria_enable,
+			      void *match_criteria, void *flow_context,
+			      u32 *flow_index)
+{
+	struct mlx5_flow_table *ft = flow_table;
+	int group_ix;
+	int err;
+
+	err = mlx5_find_group(ft, match_criteria_enable, match_criteria,
+			      &group_ix);
+	if (err) {
+		mlx5_core_warn(ft->dev, "mlx5_find_group failed\n");
+		return err;
+	}
+
+	err = alloc_flow_index(ft, group_ix, flow_index);
+	if (err) {
+		mlx5_core_warn(ft->dev, "alloc_flow_index failed\n");
+		return err;
+	}
+
+	return mlx5_set_flow_entry_cmd(ft, group_ix, *flow_index, flow_context);
+}
+EXPORT_SYMBOL(mlx5_add_flow_table_entry);
+
+void mlx5_del_flow_table_entry(void *flow_table, u32 flow_index)
+{
+	struct mlx5_flow_table *ft = flow_table;
+
+	mlx5_del_flow_entry_cmd(ft, flow_index);
+	mlx5_free_flow_index(ft, flow_index);
+}
+EXPORT_SYMBOL(mlx5_del_flow_table_entry);
+
+void *mlx5_create_flow_table(struct mlx5_core_dev *dev, u8 level, u8 table_type,
+			     u16 num_groups,
+			     struct mlx5_flow_table_group *group)
+{
+	struct mlx5_flow_table *ft;
+	u32 start_ix = 0;
+	u32 ft_size = 0;
+	void *gr;
+	void *bm;
+	int err;
+	int i;
+
+	for (i = 0; i < num_groups; i++)
+		ft_size += (1 << group[i].log_sz);
+
+	ft = kzalloc(sizeof(*ft), GFP_KERNEL);
+	gr = kcalloc(num_groups, sizeof(struct mlx5_ftg), GFP_KERNEL);
+	bm = kcalloc(BITS_TO_LONGS(ft_size), sizeof(uintptr_t), GFP_KERNEL);
+	if (!ft || !gr || !bm)
+		goto err_free_ft;
+
+	ft->group	= gr;
+	ft->bitmap	= bm;
+	ft->num_groups	= num_groups;
+	ft->level	= level;
+	ft->type	= table_type;
+	ft->size	= ft_size;
+	ft->dev		= dev;
+	mutex_init(&ft->mutex);
+
+	for (i = 0; i < ft->num_groups; i++) {
+		memcpy(&ft->group[i].g, &group[i], sizeof(*group));
+		ft->group[i].start_ix = start_ix;
+		start_ix += 1 << group[i].log_sz;
+	}
+
+	err = mlx5_create_flow_table_cmd(ft);
+	if (err)
+		goto err_free_ft;
+
+	err = mlx5_create_flow_table_groups(ft);
+	if (err)
+		goto err_destroy_flow_table_cmd;
+
+	return ft;
+
+err_destroy_flow_table_cmd:
+	mlx5_destroy_flow_table_cmd(ft);
+
+err_free_ft:
+	mlx5_core_warn(dev, "failed to alloc flow table\n");
+	kfree(bm);
+	kfree(gr);
+	kfree(ft);
+
+	return NULL;
+}
+EXPORT_SYMBOL(mlx5_create_flow_table);
+
+void mlx5_destroy_flow_table(void *flow_table)
+{
+	struct mlx5_flow_table *ft = flow_table;
+
+	mlx5_destroy_flow_table_groups(ft);
+	mlx5_destroy_flow_table_cmd(ft);
+	kfree(ft->bitmap);
+	kfree(ft->group);
+	kfree(ft);
+}
+EXPORT_SYMBOL(mlx5_destroy_flow_table);
+
+u32 mlx5_get_flow_table_id(void *flow_table)
+{
+	struct mlx5_flow_table *ft = flow_table;
+
+	return ft->id;
+}
+EXPORT_SYMBOL(mlx5_get_flow_table_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
new file mode 100644
index 0000000..3c555d7
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -0,0 +1,169 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#include <linux/mlx5/driver.h>
+#include "mlx5_core.h"
+#include "transobj.h"
+
+int mlx5_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
+{
+	u32 out[MLX5_ST_SZ_DW(create_rq_out)];
+	int err;
+
+	MLX5_SET(create_rq_in, in, opcode, MLX5_CMD_OP_CREATE_RQ);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+	if (!err)
+		*rqn = MLX5_GET(create_rq_out, out, rqn);
+
+	return err;
+}
+
+int mlx5_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_rq_out)];
+
+	MLX5_SET(modify_rq_in, in, rqn, rqn);
+	MLX5_SET(modify_rq_in, in, opcode, MLX5_CMD_OP_MODIFY_RQ);
+
+	memset(out, 0, sizeof(out));
+	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+}
+
+void mlx5_destroy_rq(struct mlx5_core_dev *dev, u32 rqn)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_rq_in)];
+	u32 out[MLX5_ST_SZ_DW(destroy_rq_out)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(destroy_rq_in, in, opcode, MLX5_CMD_OP_DESTROY_RQ);
+	MLX5_SET(destroy_rq_in, in, rqn, rqn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
+
+int mlx5_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn)
+{
+	u32 out[MLX5_ST_SZ_DW(create_sq_out)];
+	int err;
+
+	MLX5_SET(create_sq_in, in, opcode, MLX5_CMD_OP_CREATE_SQ);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+	if (!err)
+		*sqn = MLX5_GET(create_sq_out, out, sqn);
+
+	return err;
+}
+
+int mlx5_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_sq_out)];
+
+	MLX5_SET(modify_sq_in, in, sqn, sqn);
+	MLX5_SET(modify_sq_in, in, opcode, MLX5_CMD_OP_MODIFY_SQ);
+
+	memset(out, 0, sizeof(out));
+	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+}
+
+void mlx5_destroy_sq(struct mlx5_core_dev *dev, u32 sqn)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_sq_in)];
+	u32 out[MLX5_ST_SZ_DW(destroy_sq_out)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(destroy_sq_in, in, opcode, MLX5_CMD_OP_DESTROY_SQ);
+	MLX5_SET(destroy_sq_in, in, sqn, sqn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
+
+int mlx5_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tirn)
+{
+	u32 out[MLX5_ST_SZ_DW(create_tir_out)];
+	int err;
+
+	MLX5_SET(create_tir_in, in, opcode, MLX5_CMD_OP_CREATE_TIR);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+	if (!err)
+		*tirn = MLX5_GET(create_tir_out, out, tirn);
+
+	return err;
+}
+
+void mlx5_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_tir_out)];
+	u32 out[MLX5_ST_SZ_DW(destroy_tir_out)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(destroy_tir_in, in, opcode, MLX5_CMD_OP_DESTROY_TIR);
+	MLX5_SET(destroy_tir_in, in, tirn, tirn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
+
+int mlx5_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tisn)
+{
+	u32 out[MLX5_ST_SZ_DW(create_tis_out)];
+	int err;
+
+	MLX5_SET(create_tis_in, in, opcode, MLX5_CMD_OP_CREATE_TIS);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+	if (!err)
+		*tisn = MLX5_GET(create_tis_out, out, tisn);
+
+	return err;
+}
+
+void mlx5_destroy_tis(struct mlx5_core_dev *dev, u32 tisn)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_tis_out)];
+	u32 out[MLX5_ST_SZ_DW(destroy_tis_out)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(destroy_tis_in, in, opcode, MLX5_CMD_OP_DESTROY_TIS);
+	MLX5_SET(destroy_tis_in, in, tisn, tisn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
new file mode 100644
index 0000000..1bc898c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -0,0 +1,47 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#ifndef __TRANSOBJ_H__
+#define __TRANSOBJ_H__
+
+int mlx5_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn);
+int mlx5_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen);
+void mlx5_destroy_rq(struct mlx5_core_dev *dev, u32 rqn);
+int mlx5_create_sq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *sqn);
+int mlx5_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen);
+void mlx5_destroy_sq(struct mlx5_core_dev *dev, u32 sqn);
+int mlx5_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tirn);
+void mlx5_destroy_tir(struct mlx5_core_dev *dev, u32 tirn);
+int mlx5_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *tisn);
+void mlx5_destroy_tis(struct mlx5_core_dev *dev, u32 tisn);
+
+#endif /* __TRANSOBJ_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
new file mode 100644
index 0000000..3d1a55d
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -0,0 +1,111 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#include <linux/export.h>
+#include <linux/etherdevice.h>
+#include <linux/mlx5/driver.h>
+#include "vport.h"
+#include "mlx5_core.h"
+
+u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod)
+{
+	u32 in[MLX5_ST_SZ_DW(query_vport_state_in)];
+	u32 out[MLX5_ST_SZ_DW(query_vport_state_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_vport_state_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_VPORT_STATE);
+	MLX5_SET(query_vport_state_in, in, op_mod, opmod);
+
+	err = mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out,
+					 sizeof(out));
+	if (err)
+		mlx5_core_warn(mdev, "MLX5_CMD_OP_QUERY_VPORT_STATE failed\n");
+
+	return MLX5_GET(query_vport_state_out, out, state);
+}
+
+void mlx5_query_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
+{
+	u32  in[MLX5_ST_SZ_DW(query_nic_vport_context_in)];
+	u32 *out;
+	int outlen = MLX5_ST_SZ_BYTES(query_nic_vport_context_out);
+	u8 *out_addr;
+
+	out = mlx5_vzalloc(outlen);
+	if (!out)
+		return;
+
+	out_addr = MLX5_ADDR_OF(query_nic_vport_context_out, out,
+				nic_vport_context.permanent_address);
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_nic_vport_context_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_NIC_VPORT_CONTEXT);
+
+	memset(out, 0, outlen);
+	mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out, outlen);
+
+	ether_addr_copy(addr, &out_addr[2]);
+
+	kvfree(out);
+}
+
+int mlx5_vport_enable_roce(struct mlx5_core_dev *mdev)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_nic_vport_context_out)];
+	void *in;
+	int inlen = MLX5_ST_SZ_BYTES(modify_nic_vport_context_in);
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in) {
+		mlx5_core_warn(mdev, "failed to allocate inbox\n");
+		return -ENOMEM;
+	}
+
+	MLX5_SET(modify_nic_vport_context_in, in, field_select.roce_en, 1);
+	MLX5_SET(modify_nic_vport_context_in, in, nic_vport_context.roce_en, 1);
+	MLX5_SET(modify_nic_vport_context_in, in, opcode,
+		 MLX5_CMD_OP_MODIFY_NIC_VPORT_CONTEXT);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(mdev, in, inlen, out, sizeof(out));
+
+	kvfree(in);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_vport_enable_roce);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.h b/drivers/net/ethernet/mellanox/mlx5/core/vport.h
new file mode 100644
index 0000000..c05ca2c
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#ifndef __MLX5_VPORT_H__
+#define __MLX5_VPORT_H__
+
+#include <linux/mlx5/driver.h>
+
+u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
+void mlx5_query_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr);
+
+#endif /* __MLX5_VPORT_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
new file mode 100644
index 0000000..8bc7b62
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
@@ -0,0 +1,189 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#include <linux/mlx5/driver.h>
+#include "wq.h"
+#include "mlx5_core.h"
+
+u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq)
+{
+	return (u32)wq->sz_m1 + 1;
+}
+
+u32 mlx5_cqwq_get_size(struct mlx5_cqwq *wq)
+{
+	return wq->sz_m1 + 1;
+}
+
+u32 mlx5_wq_ll_get_size(struct mlx5_wq_ll *wq)
+{
+	return (u32)wq->sz_m1 + 1;
+}
+
+static u32 mlx5_wq_cyc_get_byte_size(struct mlx5_wq_cyc *wq)
+{
+	return mlx5_wq_cyc_get_size(wq) << wq->log_stride;
+}
+
+static u32 mlx5_cqwq_get_byte_size(struct mlx5_cqwq *wq)
+{
+	return mlx5_cqwq_get_size(wq) << wq->log_stride;
+}
+
+static u32 mlx5_wq_ll_get_byte_size(struct mlx5_wq_ll *wq)
+{
+	return mlx5_wq_ll_get_size(wq) << wq->log_stride;
+}
+
+int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		       void *wqc, struct mlx5_wq_cyc *wq,
+		       struct mlx5_wq_ctrl *wq_ctrl)
+{
+	int max_direct = param->linear ? INT_MAX : 0;
+	int err;
+
+	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
+	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_wq_cyc_get_byte_size(wq), max_direct,
+			     &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		     void *cqc, struct mlx5_cqwq *wq,
+		     struct mlx5_wq_ctrl *wq_ctrl)
+{
+	int max_direct = param->linear ? INT_MAX : 0;
+	int err;
+
+	wq->log_stride = 6 + MLX5_GET(cqc, cqc, cqe_sz);
+	wq->log_sz = MLX5_GET(cqc, cqc, log_cq_size);
+	wq->sz_m1 = (1 << wq->log_sz) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_cqwq_get_byte_size(wq), max_direct,
+			     &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		      void *wqc, struct mlx5_wq_ll *wq,
+		      struct mlx5_wq_ctrl *wq_ctrl)
+{
+	struct mlx5_wqe_srq_next_seg *next_seg;
+	int max_direct = param->linear ? INT_MAX : 0;
+	int err;
+	int i;
+
+	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
+	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
+
+	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
+		return err;
+	}
+
+	err = mlx5_buf_alloc(mdev, mlx5_wq_ll_get_byte_size(wq), max_direct,
+			     &wq_ctrl->buf);
+	if (err) {
+		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
+		goto err_db_free;
+	}
+
+	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->db  = wq_ctrl->db.db;
+
+	for (i = 0; i < wq->sz_m1; i++) {
+		next_seg = mlx5_wq_ll_get_wqe(wq, i);
+		next_seg->next_wqe_index = cpu_to_be16(i + 1);
+	}
+	next_seg = mlx5_wq_ll_get_wqe(wq, i);
+	wq->tail_next = &next_seg->next_wqe_index;
+
+	wq_ctrl->mdev = mdev;
+
+	return 0;
+
+err_db_free:
+	mlx5_db_free(mdev, &wq_ctrl->db);
+
+	return err;
+}
+
+void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl)
+{
+	mlx5_buf_free(wq_ctrl->mdev, &wq_ctrl->buf);
+	mlx5_db_free(wq_ctrl->mdev, &wq_ctrl->db);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
new file mode 100644
index 0000000..e0ddd69
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
@@ -0,0 +1,171 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#ifndef __MLX5_WQ_H__
+#define __MLX5_WQ_H__
+
+#include <linux/mlx5/mlx5_ifc.h>
+
+struct mlx5_wq_param {
+	int		linear;
+	int		numa;
+};
+
+struct mlx5_wq_ctrl {
+	struct mlx5_core_dev	*mdev;
+	struct mlx5_buf		buf;
+	struct mlx5_db		db;
+};
+
+struct mlx5_wq_cyc {
+	void			*buf;
+	__be32			*db;
+	u16			sz_m1;
+	u8			log_stride;
+};
+
+struct mlx5_cqwq {
+	void			*buf;
+	__be32			*db;
+	u32			sz_m1;
+	u32			cc; /* consumer counter */
+	u8			log_sz;
+	u8			log_stride;
+};
+
+struct mlx5_wq_ll {
+	void			*buf;
+	__be32			*db;
+	__be16			*tail_next;
+	u16			sz_m1;
+	u16			head;
+	u16			wqe_ctr;
+	u16			cur_sz;
+	u8			log_stride;
+};
+
+int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		       void *wqc, struct mlx5_wq_cyc *wq,
+		       struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq);
+
+int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		     void *cqc, struct mlx5_cqwq *wq,
+		     struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_cqwq_get_size(struct mlx5_cqwq *wq);
+
+int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
+		      void *wqc, struct mlx5_wq_ll *wq,
+		      struct mlx5_wq_ctrl *wq_ctrl);
+u32 mlx5_wq_ll_get_size(struct mlx5_wq_ll *wq);
+
+void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl);
+
+static inline u16 mlx5_wq_cyc_ctr2ix(struct mlx5_wq_cyc *wq, u16 ctr)
+{
+	return ctr & wq->sz_m1;
+}
+
+static inline void *mlx5_wq_cyc_get_wqe(struct mlx5_wq_cyc *wq, u16 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline int mlx5_wq_cyc_cc_bigger(u16 cc1, u16 cc2)
+{
+	int equal   = (cc1 == cc2);
+	int smaller = 0x8000 & (cc1 - cc2);
+
+	return !equal && !smaller;
+}
+
+static inline u32 mlx5_cqwq_get_ci(struct mlx5_cqwq *wq)
+{
+	return wq->cc & wq->sz_m1;
+}
+
+static inline void *mlx5_cqwq_get_wqe(struct mlx5_cqwq *wq, u32 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline u32 mlx5_cqwq_get_wrap_cnt(struct mlx5_cqwq *wq)
+{
+	return wq->cc >> wq->log_sz;
+}
+
+static inline void mlx5_cqwq_pop(struct mlx5_cqwq *wq)
+{
+	wq->cc++;
+}
+
+static inline void mlx5_cqwq_update_db_record(struct mlx5_cqwq *wq)
+{
+	*wq->db = cpu_to_be32(wq->cc & 0xffffff);
+}
+
+static inline int mlx5_wq_ll_is_full(struct mlx5_wq_ll *wq)
+{
+	return wq->cur_sz == wq->sz_m1;
+}
+
+static inline int mlx5_wq_ll_is_empty(struct mlx5_wq_ll *wq)
+{
+	return !wq->cur_sz;
+}
+
+static inline void *mlx5_wq_ll_get_wqe(struct mlx5_wq_ll *wq, u16 ix)
+{
+	return wq->buf + (ix << wq->log_stride);
+}
+
+static inline void mlx5_wq_ll_push(struct mlx5_wq_ll *wq, u16 head_next)
+{
+	wq->head = head_next;
+	wq->wqe_ctr++;
+	wq->cur_sz++;
+}
+
+static inline void mlx5_wq_ll_pop(struct mlx5_wq_ll *wq, __be16 ix,
+				  __be16 *next_tail_next)
+{
+	*wq->tail_next = ix;
+	wq->tail_next = next_tail_next;
+	wq->cur_sz--;
+}
+
+static inline void mlx5_wq_ll_update_db_record(struct mlx5_wq_ll *wq)
+{
+	*wq->db = cpu_to_be32(wq->wqe_ctr);
+}
+
+#endif /* __MLX5_WQ_H__ */
diff --git a/include/linux/mlx5/flow_table.h b/include/linux/mlx5/flow_table.h
new file mode 100644
index 0000000..5f922c6
--- /dev/null
+++ b/include/linux/mlx5/flow_table.h
@@ -0,0 +1,54 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
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
+#ifndef MLX5_FLOW_TABLE_H
+#define MLX5_FLOW_TABLE_H
+
+#include <linux/mlx5/driver.h>
+
+struct mlx5_flow_table_group {
+	u8	log_sz;
+	u8	match_criteria_enable;
+	u32	match_criteria[MLX5_ST_SZ_DW(fte_match_param)];
+};
+
+void *mlx5_create_flow_table(struct mlx5_core_dev *dev, u8 level, u8 table_type,
+			     u16 num_groups,
+			     struct mlx5_flow_table_group *group);
+void mlx5_destroy_flow_table(void *flow_table);
+int mlx5_add_flow_table_entry(void *flow_table, u8 match_criteria_enable,
+			      void *match_criteria, void *flow_context,
+			      u32 *flow_index);
+void mlx5_del_flow_table_entry(void *flow_table, u32 flow_index);
+u32 mlx5_get_flow_table_id(void *flow_table);
+
+#endif /* MLX5_FLOW_TABLE_H */
-- 
1.9.3
