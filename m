From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/12] net/mlx5e: Add parsing of TC pedit actions to HW format
Date: Wed, 29 Mar 2017 02:27:11 +0300
Message-ID: <20170328232713.29894-11-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42865 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932220AbdC1X2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:07 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Parse/translate a set of TC pedit actions to be formed in the HW API format.

User-space provides set of keys where each one of them is made of: command (add or
set), header-type, byte offset within that header along with a 32 bit mask and value.

The mask dictates what bits in the 32 bit word that starts on the offset we should
be dealing with, but under negative polarity (unset bits are to be modified).

We do a 1st pass over the set of keys while using the header-type and offset to
fill the masks and the values into a data-structure containting all the
supported network headers.

We then do a 2nd pass over the set of fields to re-write supported by the HW,
where for each such candidate field, we use the masks filled on the 1st pass to
realize if we should offloading re-write it.

In case offloading is required, we fill a HW descriptor with the following:

(1) the header field to modify
(2) the bit offset within the field from where to modify (set command only)
(3) the value to set/add
(4) the length in bits 1...32 to modify (set command only)

Note that it's possible for a given pedit mask to dictate modifying the
same header field multiple times or to modify multiple header fields.
Currently such combinations are not supported for offloading, hence, for set
commands, the offset within the field is always zero, and the length to modify
is the field size.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 273 ++++++++++++++++++++++++
 1 file changed, 273 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index af92d9c1a619..3a31195f0d9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -42,6 +42,7 @@
 #include <net/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_vlan.h>
 #include <net/tc_act/tc_tunnel_key.h>
+#include <net/tc_act/tc_pedit.h>
 #include <net/vxlan.h>
 #include "en.h"
 #include "en_tc.h"
@@ -72,6 +73,8 @@ struct mlx5e_tc_flow {
 
 struct mlx5e_tc_flow_parse_attr {
 	struct mlx5_flow_spec spec;
+	int num_mod_hdr_actions;
+	void *mod_hdr_actions;
 };
 
 enum {
@@ -675,6 +678,276 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 	return err;
 }
 
+struct pedit_headers {
+	struct ethhdr  eth;
+	struct iphdr   ip4;
+	struct ipv6hdr ip6;
+	struct tcphdr  tcp;
+	struct udphdr  udp;
+};
+
+static int pedit_header_offsets[] = {
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_ETH] = offsetof(struct pedit_headers, eth),
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_IP4] = offsetof(struct pedit_headers, ip4),
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_IP6] = offsetof(struct pedit_headers, ip6),
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_TCP] = offsetof(struct pedit_headers, tcp),
+	[TCA_PEDIT_KEY_EX_HDR_TYPE_UDP] = offsetof(struct pedit_headers, udp),
+};
+
+#define pedit_header(_ph, _htype) ((void *)(_ph) + pedit_header_offsets[_htype])
+
+static int set_pedit_val(u8 hdr_type, u32 mask, u32 val, u32 offset,
+			 struct pedit_headers *masks,
+			 struct pedit_headers *vals)
+{
+	u32 *curr_pmask, *curr_pval;
+
+	if (hdr_type >= __PEDIT_HDR_TYPE_MAX)
+		goto out_err;
+
+	curr_pmask = (u32 *)(pedit_header(masks, hdr_type) + offset);
+	curr_pval  = (u32 *)(pedit_header(vals, hdr_type) + offset);
+
+	if (*curr_pmask & mask)  /* disallow acting twice on the same location */
+		goto out_err;
+
+	*curr_pmask |= mask;
+	*curr_pval  |= (val & mask);
+
+	return 0;
+
+out_err:
+	return -EOPNOTSUPP;
+}
+
+struct mlx5_fields {
+	u8  field;
+	u8  size;
+	u32 offset;
+};
+
+static struct mlx5_fields fields[] = {
+	{MLX5_ACTION_IN_FIELD_OUT_DMAC_47_16, 4, offsetof(struct pedit_headers, eth.h_dest[0])},
+	{MLX5_ACTION_IN_FIELD_OUT_DMAC_15_0,  2, offsetof(struct pedit_headers, eth.h_dest[4])},
+	{MLX5_ACTION_IN_FIELD_OUT_SMAC_47_16, 4, offsetof(struct pedit_headers, eth.h_source[0])},
+	{MLX5_ACTION_IN_FIELD_OUT_SMAC_15_0,  2, offsetof(struct pedit_headers, eth.h_source[4])},
+	{MLX5_ACTION_IN_FIELD_OUT_ETHERTYPE,  2, offsetof(struct pedit_headers, eth.h_proto)},
+
+	{MLX5_ACTION_IN_FIELD_OUT_IP_DSCP, 1, offsetof(struct pedit_headers, ip4.tos)},
+	{MLX5_ACTION_IN_FIELD_OUT_IP_TTL,  1, offsetof(struct pedit_headers, ip4.ttl)},
+	{MLX5_ACTION_IN_FIELD_OUT_SIPV4,   4, offsetof(struct pedit_headers, ip4.saddr)},
+	{MLX5_ACTION_IN_FIELD_OUT_DIPV4,   4, offsetof(struct pedit_headers, ip4.daddr)},
+
+	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_127_96, 4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[0])},
+	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_95_64,  4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[1])},
+	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_63_32,  4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[2])},
+	{MLX5_ACTION_IN_FIELD_OUT_SIPV6_31_0,   4, offsetof(struct pedit_headers, ip6.saddr.s6_addr32[3])},
+	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_127_96, 4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[0])},
+	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_95_64,  4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[1])},
+	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_63_32,  4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[2])},
+	{MLX5_ACTION_IN_FIELD_OUT_DIPV6_31_0,   4, offsetof(struct pedit_headers, ip6.daddr.s6_addr32[3])},
+
+	{MLX5_ACTION_IN_FIELD_OUT_TCP_SPORT, 2, offsetof(struct pedit_headers, tcp.source)},
+	{MLX5_ACTION_IN_FIELD_OUT_TCP_DPORT, 2, offsetof(struct pedit_headers, tcp.dest)},
+	{MLX5_ACTION_IN_FIELD_OUT_TCP_FLAGS, 1, offsetof(struct pedit_headers, tcp.ack_seq) + 5},
+
+	{MLX5_ACTION_IN_FIELD_OUT_UDP_SPORT, 2, offsetof(struct pedit_headers, udp.source)},
+	{MLX5_ACTION_IN_FIELD_OUT_UDP_DPORT, 2, offsetof(struct pedit_headers, udp.dest)},
+};
+
+/* On input attr->num_mod_hdr_actions tells how many HW actions can be parsed at
+ * max from the SW pedit action. On success, it says how many HW actions were
+ * actually parsed.
+ */
+static int offload_pedit_fields(struct pedit_headers *masks,
+				struct pedit_headers *vals,
+				struct mlx5e_tc_flow_parse_attr *parse_attr)
+{
+	struct pedit_headers *set_masks, *add_masks, *set_vals, *add_vals;
+	int i, action_size, nactions, max_actions, first, last;
+	void *s_masks_p, *a_masks_p, *vals_p;
+	u32 s_mask, a_mask, val;
+	struct mlx5_fields *f;
+	u8 cmd, field_bsize;
+	unsigned long mask;
+	void *action;
+
+	set_masks = &masks[TCA_PEDIT_KEY_EX_CMD_SET];
+	add_masks = &masks[TCA_PEDIT_KEY_EX_CMD_ADD];
+	set_vals = &vals[TCA_PEDIT_KEY_EX_CMD_SET];
+	add_vals = &vals[TCA_PEDIT_KEY_EX_CMD_ADD];
+
+	action_size = MLX5_UN_SZ_BYTES(set_action_in_add_action_in_auto);
+	action = parse_attr->mod_hdr_actions;
+	max_actions = parse_attr->num_mod_hdr_actions;
+	nactions = 0;
+
+	for (i = 0; i < ARRAY_SIZE(fields); i++) {
+		f = &fields[i];
+		/* avoid seeing bits set from previous iterations */
+		s_mask = a_mask = mask = val = 0;
+
+		s_masks_p = (void *)set_masks + f->offset;
+		a_masks_p = (void *)add_masks + f->offset;
+
+		memcpy(&s_mask, s_masks_p, f->size);
+		memcpy(&a_mask, a_masks_p, f->size);
+
+		if (!s_mask && !a_mask) /* nothing to offload here */
+			continue;
+
+		if (s_mask && a_mask) {
+			printk(KERN_WARNING "mlx5: can't set and add to the same HW field (%x)\n", f->field);
+			return -EOPNOTSUPP;
+		}
+
+		if (nactions == max_actions) {
+			printk(KERN_WARNING "mlx5: parsed %d pedit actions, can't do more\n", nactions);
+			return -EOPNOTSUPP;
+		}
+
+		if (s_mask) {
+			cmd  = MLX5_ACTION_TYPE_SET;
+			mask = s_mask;
+			vals_p = (void *)set_vals + f->offset;
+			/* clear to denote we consumed this field */
+			memset(s_masks_p, 0, f->size);
+		} else {
+			cmd  = MLX5_ACTION_TYPE_ADD;
+			mask = a_mask;
+			vals_p = (void *)add_vals + f->offset;
+			/* clear to denote we consumed this field */
+			memset(a_masks_p, 0, f->size);
+		}
+
+		memcpy(&val, vals_p, f->size);
+
+		field_bsize = f->size * BITS_PER_BYTE;
+		first = find_first_bit(&mask, field_bsize);
+		last  = find_last_bit(&mask, field_bsize);
+		if (first > 0 || last != (field_bsize - 1)) {
+			printk(KERN_WARNING "mlx5: partial rewrite (mask %lx) is currently not offloaded\n",
+			       mask);
+			return -EOPNOTSUPP;
+		}
+
+		MLX5_SET(set_action_in, action, action_type, cmd);
+		MLX5_SET(set_action_in, action, field, f->field);
+
+		if (cmd == MLX5_ACTION_TYPE_SET) {
+			MLX5_SET(set_action_in, action, offset, 0);
+			/* length is num of bits to be written, zero means length of 32 */
+			MLX5_SET(set_action_in, action, length, field_bsize);
+		}
+
+		if (field_bsize == 32)
+			MLX5_SET(set_action_in, action, data, ntohl(val));
+		else if (field_bsize == 16)
+			MLX5_SET(set_action_in, action, data, ntohs(val));
+		else if (field_bsize == 8)
+			MLX5_SET(set_action_in, action, data, val);
+
+		action += action_size;
+		nactions++;
+	}
+
+	parse_attr->num_mod_hdr_actions = nactions;
+	return 0;
+}
+
+static int alloc_mod_hdr_actions(struct mlx5e_priv *priv,
+				 const struct tc_action *a, int namespace,
+				 struct mlx5e_tc_flow_parse_attr *parse_attr)
+{
+	int nkeys, action_size, max_actions;
+
+	nkeys = tcf_pedit_nkeys(a);
+	action_size = MLX5_UN_SZ_BYTES(set_action_in_add_action_in_auto);
+
+	if (namespace == MLX5_FLOW_NAMESPACE_FDB) /* FDB offloading */
+		max_actions = MLX5_CAP_ESW_FLOWTABLE_FDB(priv->mdev, max_modify_header_actions);
+	else /* namespace is MLX5_FLOW_NAMESPACE_KERNEL - NIC offloading */
+		max_actions = MLX5_CAP_FLOWTABLE_NIC_RX(priv->mdev, max_modify_header_actions);
+
+	/* can get up to crazingly 16 HW actions in 32 bits pedit SW key */
+	max_actions = min(max_actions, nkeys * 16);
+
+	parse_attr->mod_hdr_actions = kcalloc(max_actions, action_size, GFP_KERNEL);
+	if (!parse_attr->mod_hdr_actions)
+		return -ENOMEM;
+
+	parse_attr->num_mod_hdr_actions = max_actions;
+	return 0;
+}
+
+static const struct pedit_headers zero_masks = {};
+
+static int parse_tc_pedit_action(struct mlx5e_priv *priv,
+				 const struct tc_action *a, int namespace,
+				 struct mlx5e_tc_flow_parse_attr *parse_attr)
+{
+	struct pedit_headers masks[__PEDIT_CMD_MAX], vals[__PEDIT_CMD_MAX], *cmd_masks;
+	int nkeys, i, err = -EOPNOTSUPP;
+	u32 mask, val, offset;
+	u8 cmd, htype;
+
+	nkeys = tcf_pedit_nkeys(a);
+
+	memset(masks, 0, sizeof(struct pedit_headers) * __PEDIT_CMD_MAX);
+	memset(vals,  0, sizeof(struct pedit_headers) * __PEDIT_CMD_MAX);
+
+	for (i = 0; i < nkeys; i++) {
+		htype = tcf_pedit_htype(a, i);
+		cmd = tcf_pedit_cmd(a, i);
+		err = -EOPNOTSUPP; /* can't be all optimistic */
+
+		if (htype == TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK) {
+			printk(KERN_WARNING "mlx5: legacy pedit isn't offloaded\n");
+			goto out_err;
+		}
+
+		if (cmd != TCA_PEDIT_KEY_EX_CMD_SET && cmd != TCA_PEDIT_KEY_EX_CMD_ADD) {
+			printk(KERN_WARNING "mlx5: pedit cmd %d isn't offloaded\n", cmd);
+			goto out_err;
+		}
+
+		mask = tcf_pedit_mask(a, i);
+		val = tcf_pedit_val(a, i);
+		offset = tcf_pedit_offset(a, i);
+
+		err = set_pedit_val(htype, ~mask, val, offset, &masks[cmd], &vals[cmd]);
+		if (err)
+			goto out_err;
+	}
+
+	err = alloc_mod_hdr_actions(priv, a, namespace, parse_attr);
+	if (err)
+		goto out_err;
+
+	err = offload_pedit_fields(masks, vals, parse_attr);
+	if (err < 0)
+		goto out_dealloc_parsed_actions;
+
+	for (cmd = 0; cmd < __PEDIT_CMD_MAX; cmd++) {
+		cmd_masks = &masks[cmd];
+		if (memcmp(cmd_masks, &zero_masks, sizeof(zero_masks))) {
+			printk(KERN_WARNING "mlx5: attempt to offload an unsupported field (cmd %d)\n",
+			       cmd);
+			print_hex_dump(KERN_WARNING, "mask: ", DUMP_PREFIX_ADDRESS,
+				       16, 1, cmd_masks, sizeof(zero_masks), true);
+			err = -EOPNOTSUPP;
+			goto out_dealloc_parsed_actions;
+		}
+	}
+
+	return 0;
+
+out_dealloc_parsed_actions:
+	kfree(parse_attr->mod_hdr_actions);
+out_err:
+	return err;
+}
+
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				struct mlx5e_tc_flow_parse_attr *parse_attr,
 				struct mlx5e_tc_flow *flow)
-- 
2.11.0
