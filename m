From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate representation
Date: Thu, 25 Feb 2016 18:37:24 +0100
Message-ID: <1456421844-5901-4-git-send-email-pablo@netfilter.org>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36314 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933419AbcBYRhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 12:37:40 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 141D37403
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:38 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 004BBDA38C
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:38 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 24206DA39D
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:31 +0100 (CET)
In-Reply-To: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the u32 parser from the ixgbe that John has made to the
core u32. This parser has been adapted to build the intermediate
representation.

To store the parsing information, this patch introduces a parse table
object, one per device, so we don't need to store the parsing states in
the adapter, which is the major dependency with previous patches.

Since u32 allows rules connected via links, the u32 parser tracks this
links and then generates the intermediate representation that is passed
to the ixgbe driver.

New drivers will only have to implement the jit translation code based
on the intermediate representation. With some extra work, I think it
should be possible to generalize the existing tc specific ndo action so
it can be used by other frontends.

I tried to stick to John's original u32 frontend parser as much as
possible, adapting it to build the intermediate representation.

After this change, we don't expose the tc action structure layout and
other similar frontend details to the backend anymore to the backend
anymore. I think this is good since changes in the frontend should not
need to be propagated to the 1..n drivers supporting u32 offloads. In
that sense, this helps to keep the frontend software representation
separated from low-level backend driver details.

After this patch, it should be possible to put the tc_cls_u32_knode
structure into diet since we only need the handle (as unique id) and the
ast tree.

I couldn't send any more incremental changes to update previous work
since the u32 parser and the internal representation were put together,
that why this patch is slightly large.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 216 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
 include/net/pkt_cls.h                          |   3 +
 net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++
 5 files changed, 454 insertions(+), 225 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 84fa28c..09c2d9b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -796,10 +796,6 @@ struct ixgbe_adapter {
 	u8 default_up;
 	unsigned long fwd_bitmask; /* Bitmask indicating in use pools */
 
-#define IXGBE_MAX_LINK_HANDLE 10
-	struct ixgbe_mat_field *jump_tables[IXGBE_MAX_LINK_HANDLE];
-	unsigned long tables;
-
 /* maximum number of RETA entries among all devices supported by ixgbe
  * driver: currently it's x550 device in non-SRIOV mode
  */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 252e9ff..416be60 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -67,7 +67,6 @@
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
-#include "ixgbe_model.h"
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
@@ -5548,9 +5547,6 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #endif /* CONFIG_IXGBE_DCB */
 #endif /* IXGBE_FCOE */
 
-	/* initialize static ixgbe jump table entries */
-	adapter->jump_tables[0] = ixgbe_ipv4_fields;
-
 	adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
 				     hw->mac.num_rar_entries,
 				     GFP_ATOMIC);
@@ -8221,20 +8217,12 @@ static int ixgbe_configure_clsu32_add_hnode(struct ixgbe_adapter *adapter,
 					    __be16 protocol,
 					    struct tc_cls_u32_offload *cls)
 {
-	/* This ixgbe devices do not support hash tables at the moment
-	 * so abort when given hash tables.
-	 */
-	if (cls->hnode.divisor > 0)
-		return -EINVAL;
-
-	set_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
 	return 0;
 }
 
 static int ixgbe_configure_clsu32_del_hnode(struct ixgbe_adapter *adapter,
 					    struct tc_cls_u32_offload *cls)
 {
-	clear_bit(TC_U32_USERHTID(cls->hnode.handle), &adapter->tables);
 	return 0;
 }
 
@@ -8244,111 +8232,134 @@ struct ixgbe_filter {
 	u8 queue;
 };
 
+static int ixgbe_tcp_jit(struct net_ir_jit_ctx *ctx,
+			 const struct net_ir_expr *expr,
+			 void *data)
+{
+	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
+	struct net_ir_expr *right = expr->relational.right;
+	struct net_ir_expr *payload;
+	u32 mask = 0xffffffff;
+
+	if (expr->relational.left->type == NET_IR_EXPR_BINOP) {
+		payload = expr->relational.left->binop.left;
+		mask = expr->relational.left->binop.right->value.data;
+	} else {
+		payload = expr->relational.left;
+	}
+
+	switch (payload->payload.offset) {
+	case offsetof(struct tcphdr, source):
+		f->input->filter.formatted.src_port = right->value.data & 0xffff;
+		f->mask.formatted.src_port = mask & 0xffff;
+		break;
+	case offsetof(struct tcphdr, dest):
+		f->input->filter.formatted.dst_port = right->value.data & 0xffff;
+		f->mask.formatted.dst_port = mask & 0xffff;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+static struct net_ir_proto_desc ixgbe_tcp_desc = {
+	.base		= NET_IR_PAYLOAD_TRANSPORT_HDR,
+	.protonum	= IPPROTO_TCP,
+	.jit		= ixgbe_tcp_jit,
+};
+
+static int ixgbe_ipv4_jit(struct net_ir_jit_ctx *ctx,
+			  const struct net_ir_expr *expr,
+			  void *data)
+{
+	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
+	struct net_ir_expr *right = expr->relational.right;
+	struct net_ir_expr *payload;
+	u32 mask = 0xffffffff;
+
+	if (expr->relational.left->type == NET_IR_EXPR_BINOP) {
+		payload = expr->relational.left->binop.left;
+		mask = expr->relational.left->binop.right->value.data;
+	} else {
+		payload = expr->relational.left;
+	}
+
+	switch (payload->payload.offset) {
+	case offsetof(struct iphdr, saddr):
+		f->input->filter.formatted.src_ip[0] = right->value.data;
+		f->mask.formatted.src_ip[0] = mask;
+		break;
+	case offsetof(struct iphdr, daddr):
+		f->input->filter.formatted.dst_ip[0] = right->value.data;
+		f->mask.formatted.dst_ip[0] = mask;
+		break;
+	case offsetof(struct iphdr, protocol):
+		net_ir_jit_update_pctx(ctx, NET_IR_PAYLOAD_TRANSPORT_HDR,
+				       right->value.data);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+static struct net_ir_proto_desc ixgbe_ipv4_desc = {
+	.base		= NET_IR_PAYLOAD_NETWORK_HDR,
+	.jit		= ixgbe_ipv4_jit,
+	.protocols	= {
+		&ixgbe_tcp_desc,
+		NULL
+	},
+};
+
+static int ixgbe_verdict(struct net_ir_jit_ctx *ctx,
+			 enum net_ir_stmt_verdict verdict, void *data)
+{
+	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
+
+	switch (verdict) {
+	case NET_IR_VERDICT_DROP:
+		f->input->action = IXGBE_FDIR_DROP_QUEUE;
+		f->queue = IXGBE_FDIR_DROP_QUEUE;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static struct net_ir_jit_desc ixgbe_desc = {
+	.base		= NET_IR_PAYLOAD_NETWORK_HDR,
+	.proto_desc	= &ixgbe_ipv4_desc,
+	.verdict	= ixgbe_verdict,
+};
+
 static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 				  __be16 protocol,
 				  struct tc_cls_u32_offload *cls)
 {
 	u32 loc = cls->knode.handle & 0xfffff;
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct ixgbe_mat_field *field_ptr;
 	struct ixgbe_filter f;
-#ifdef CONFIG_NET_CLS_ACT
-	const struct tc_action *a;
-#endif
-	int i, err = 0;
+	int err = 0;
 	u32 handle;
 
 	memset(&f.mask, 0, sizeof(union ixgbe_atr_input));
 	handle = cls->knode.handle;
 
-	/* At the moment cls_u32 jumps to transport layer and skips past
-	 * L2 headers. The canonical method to match L2 frames is to use
-	 * negative values. However this is error prone at best but really
-	 * just broken because there is no way to "know" what sort of hdr
-	 * is in front of the transport layer. Fix cls_u32 to support L2
-	 * headers when needed.
-	 */
-	if (protocol != htons(ETH_P_IP))
-		return -EINVAL;
-
-	if (cls->knode.link_handle ||
-	    cls->knode.link_handle >= IXGBE_MAX_LINK_HANDLE) {
-		struct ixgbe_nexthdr *nexthdr = ixgbe_ipv4_jumps;
-		u32 uhtid = TC_U32_USERHTID(cls->knode.link_handle);
-
-		if (!test_bit(uhtid, &adapter->tables))
-			return -EINVAL;
-
-		for (i = 0; nexthdr[i].jump; i++) {
-			if (nexthdr->o != cls->knode.sel->offoff ||
-			    nexthdr->s != cls->knode.sel->offshift ||
-			    nexthdr->m != cls->knode.sel->offmask ||
-			    /* do not support multiple key jumps its just mad */
-			    cls->knode.sel->nkeys > 1)
-				return -EINVAL;
-
-			if (nexthdr->off != cls->knode.sel->keys[0].off ||
-			    nexthdr->val != cls->knode.sel->keys[0].val ||
-			    nexthdr->mask != cls->knode.sel->keys[0].mask)
-				return -EINVAL;
-
-			if (uhtid >= IXGBE_MAX_LINK_HANDLE)
-				return -EINVAL;
-
-			adapter->jump_tables[uhtid] = nexthdr->jump;
-		}
-		return 0;
-	}
-
 	if (loc >= ((1024 << adapter->fdir_pballoc) - 2)) {
 		e_err(drv, "Location out of range\n");
 		return -EINVAL;
 	}
 
-	/* cls u32 is a graph starting at root node 0x800. The driver tracks
-	 * links and also the fields used to advance the parser across each
-	 * link (e.g. nexthdr/eat parameters from 'tc'). This way we can map
-	 * the u32 graph onto the hardware parse graph denoted in ixgbe_model.h
-	 * To add support for new nodes update ixgbe_model.h parse structures
-	 * this function _should_ be generic try not to hardcode values here.
-	 */
-	if (TC_U32_USERHTID(handle) == 0x800) {
-		field_ptr = adapter->jump_tables[0];
-	} else {
-		if (TC_U32_USERHTID(handle) >= ARRAY_SIZE(adapter->jump_tables))
-			return -EINVAL;
-
-		field_ptr = adapter->jump_tables[TC_U32_USERHTID(handle)];
-	}
-
-	if (!field_ptr)
-		return -EINVAL;
-
 	f.input = kzalloc(sizeof(struct ixgbe_fdir_filter), GFP_KERNEL);
 	if (!f.input)
 		return -ENOMEM;
 
-	for (i = 0; i < cls->knode.sel->nkeys; i++) {
-		int off = cls->knode.sel->keys[i].off;
-		__be32 val = cls->knode.sel->keys[i].val;
-		__be32 m = cls->knode.sel->keys[i].mask;
-		bool found_entry = false;
-		int j;
-
-		for (j = 0; field_ptr[j].val; j++) {
-			if (field_ptr[j].off == off &&
-			    field_ptr[j].mask == m) {
-				field_ptr[j].val(f.input, &f.mask, val, m);
-				f.input->filter.formatted.flow_type |=
-					field_ptr[j].type;
-				found_entry = true;
-				break;
-			}
-		}
-
-		if (!found_entry)
-			goto err_out;
-	}
+	if (net_ir_jit(&cls->knode.ast, &ixgbe_desc, &f) < 0)
+		return -EINVAL;
 
 	f.mask.formatted.flow_type = IXGBE_ATR_L4TYPE_IPV6_MASK |
 				     IXGBE_ATR_L4TYPE_MASK;
@@ -8356,18 +8367,6 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	if (f.input->filter.formatted.flow_type == IXGBE_ATR_FLOW_TYPE_IPV4)
 		f.mask.formatted.flow_type &= IXGBE_ATR_L4TYPE_IPV6_MASK;
 
-#ifdef CONFIG_NET_CLS_ACT
-	if (list_empty(&cls->knode.exts->actions))
-		goto err_out;
-
-	list_for_each_entry(a, &cls->knode.exts->actions, list) {
-		if (!is_tcf_gact_shot(a))
-			goto err_out;
-	}
-#endif
-
-	f.input->action = IXGBE_FDIR_DROP_QUEUE;
-	f.queue = IXGBE_FDIR_DROP_QUEUE;
 	f.input->sw_idx = loc;
 
 	spin_lock(&adapter->fdir_perfect_lock);
@@ -8393,7 +8392,6 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	return err;
 err_out_w_lock:
 	spin_unlock(&adapter->fdir_perfect_lock);
-err_out:
 	kfree(f.input);
 	return -EINVAL;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
deleted file mode 100644
index ce48872..0000000
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
+++ /dev/null
@@ -1,112 +0,0 @@
-/*******************************************************************************
- *
- * Intel 10 Gigabit PCI Express Linux drive
- * Copyright(c) 2016 Intel Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms and conditions of the GNU General Public License,
- * version 2, as published by the Free Software Foundation.
- *
- * This program is distributed in the hope it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program.  If not, see <http://www.gnu.org/licenses/>.
- *
- * The full GNU General Public License is included in this distribution in
- * the file called "COPYING".
- *
- * Contact Information:
- * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
- * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
- *
- ******************************************************************************/
-
-#ifndef _IXGBE_MODEL_H_
-#define _IXGBE_MODEL_H_
-
-#include "ixgbe.h"
-#include "ixgbe_type.h"
-
-struct ixgbe_mat_field {
-	unsigned int off;
-	unsigned int mask;
-	int (*val)(struct ixgbe_fdir_filter *input,
-		   union ixgbe_atr_input *mask,
-		   u32 val, u32 m);
-	unsigned int type;
-};
-
-static inline int ixgbe_mat_prgm_sip(struct ixgbe_fdir_filter *input,
-				     union ixgbe_atr_input *mask,
-				     u32 val, u32 m)
-{
-	input->filter.formatted.src_ip[0] = val;
-	mask->formatted.src_ip[0] = m;
-	return 0;
-}
-
-static inline int ixgbe_mat_prgm_dip(struct ixgbe_fdir_filter *input,
-				     union ixgbe_atr_input *mask,
-				     u32 val, u32 m)
-{
-	input->filter.formatted.dst_ip[0] = val;
-	mask->formatted.dst_ip[0] = m;
-	return 0;
-}
-
-static struct ixgbe_mat_field ixgbe_ipv4_fields[] = {
-	{ .off = 12, .mask = -1, .val = ixgbe_mat_prgm_sip,
-	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
-	{ .off = 16, .mask = -1, .val = ixgbe_mat_prgm_dip,
-	  .type = IXGBE_ATR_FLOW_TYPE_IPV4},
-	{ .val = NULL } /* terminal node */
-};
-
-static inline int ixgbe_mat_prgm_sport(struct ixgbe_fdir_filter *input,
-				       union ixgbe_atr_input *mask,
-				       u32 val, u32 m)
-{
-	input->filter.formatted.src_port = val & 0xffff;
-	mask->formatted.src_port = m & 0xffff;
-	return 0;
-};
-
-static inline int ixgbe_mat_prgm_dport(struct ixgbe_fdir_filter *input,
-				       union ixgbe_atr_input *mask,
-				       u32 val, u32 m)
-{
-	input->filter.formatted.dst_port = val & 0xffff;
-	mask->formatted.dst_port = m & 0xffff;
-	return 0;
-};
-
-static struct ixgbe_mat_field ixgbe_tcp_fields[] = {
-	{.off = 0, .mask = 0xffff, .val = ixgbe_mat_prgm_sport,
-	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
-	{.off = 2, .mask = 0xffff, .val = ixgbe_mat_prgm_dport,
-	 .type = IXGBE_ATR_FLOW_TYPE_TCPV4},
-	{ .val = NULL } /* terminal node */
-};
-
-struct ixgbe_nexthdr {
-	/* offset, shift, and mask of position to next header */
-	unsigned int o;
-	u32 s;
-	u32 m;
-	/* match criteria to make this jump*/
-	unsigned int off;
-	u32 val;
-	u32 mask;
-	/* location of jump to make */
-	struct ixgbe_mat_field *jump;
-};
-
-static struct ixgbe_nexthdr ixgbe_ipv4_jumps[] = {
-	{ .o = 0, .s = 6, .m = 0xf,
-	  .off = 8, .val = 0x600, .mask = 0xff00, .jump = ixgbe_tcp_fields},
-	{ .jump = NULL } /* terminal node */
-};
-#endif /* _IXGBE_MODEL_H_ */
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 2121df5..c276ba2 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -358,6 +358,8 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 }
 #endif /* CONFIG_NET_CLS_IND */
 
+#include <net/ir.h>
+
 struct tc_cls_u32_knode {
 	struct tcf_exts *exts;
 	struct tc_u32_sel *sel;
@@ -366,6 +368,7 @@ struct tc_cls_u32_knode {
 	u32 mask;
 	u32 link_handle;
 	u8 fshift;
+	struct net_ir_ast ast;
 };
 
 struct tc_cls_u32_hnode {
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d54bc94..b79b4675 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -44,6 +44,8 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 #include <linux/netdevice.h>
+#include <net/tc_act/tc_gact.h>
+#include <net/ir.h>
 
 struct tc_u_knode {
 	struct tc_u_knode __rcu	*next;
@@ -442,11 +444,208 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	}
 }
 
+static struct net_ir_stmt *
+u32_payload_stmt_alloc(enum net_ir_payload_bases base, u32 offset, u32 value,
+		       u32 mask)
+{
+	struct net_ir_expr *expr, *payload, *binop;
+	struct net_ir_stmt *stmt;
+
+	expr = net_ir_expr_alloc(NET_IR_EXPR_RELATIONAL);
+	if (!expr)
+		return NULL;
+
+	expr->op = NET_IR_OP_EQ;
+
+	payload = net_ir_expr_alloc(NET_IR_EXPR_PAYLOAD);
+	if (!payload) {
+		net_ir_expr_free(expr);
+		return NULL;
+	}
+
+	payload->payload.base = base;
+	payload->payload.offset = offset;
+
+	if (mask) {
+		binop = net_ir_expr_alloc(NET_IR_EXPR_BINOP);
+		if (!binop) {
+			net_ir_expr_free(expr);
+			net_ir_expr_free(payload);
+			return NULL;
+		}
+
+		binop->op = NET_IR_OP_AND;
+
+		binop->binop.left = payload;
+		binop->binop.right = net_ir_expr_alloc(NET_IR_EXPR_VALUE);
+		if (!binop->binop.right) {
+			net_ir_expr_free(expr);
+			net_ir_expr_free(binop);
+			return NULL;
+		}
+
+		binop->binop.right->value.data = mask;
+		expr->relational.left = binop;
+	} else {
+		expr->relational.left = payload;
+	}
+
+	expr->relational.right = net_ir_expr_alloc(NET_IR_EXPR_VALUE);
+	if (!expr->relational.right) {
+		net_ir_expr_free(expr);
+		return NULL;
+	}
+	expr->relational.right->value.data = value;
+
+	stmt = net_ir_stmt_alloc(NET_IR_STMT_EXPR);
+	if (!stmt) {
+		net_ir_expr_free(expr);
+		return NULL;
+	}
+
+	stmt->expr = expr;
+	return stmt;
+}
+
+struct u32_mat_field {
+	unsigned int off;
+	unsigned int mask;
+};
+
+struct u32_proto_def {
+	u32			protocol;
+	int			(*parse)(struct net_ir_ast *ast,
+					 struct u32_mat_field *field,
+					 u32 m, u32 val);
+	u32			field_num;
+	struct u32_mat_field	fields[];
+};
+
+static int u32_parse_ip(struct net_ir_ast *ast, struct u32_mat_field *field,
+			u32 mask, u32 val)
+{
+	struct net_ir_stmt *stmt;
+
+	stmt = u32_payload_stmt_alloc(NET_IR_PAYLOAD_NETWORK_HDR,
+				      field->off, val, mask);
+	if (!stmt)
+		return -ENOMEM;
+
+	net_ir_ast_add_stmt(ast, stmt);
+	return 0;
+}
+
+static struct u32_proto_def u32_ipv4_fields = {
+	.protocol 	= ETH_P_IP,
+	.parse		= u32_parse_ip,
+	.field_num	= 2,
+	.fields = {
+		{.off = 12,	.mask = -1, },
+		{.off = 16,	.mask = -1, },
+	},
+};
+
+static int u32_parse_tcp(struct net_ir_ast *ast, struct u32_mat_field *field,
+			 u32 mask, u32 val)
+{
+	struct net_ir_stmt *stmt;
+
+	/* Manually add ip protocol field to the abstract syntax tree. We can
+	 * get rid of this by storing context into the parser.
+	 */
+	stmt = u32_payload_stmt_alloc(NET_IR_PAYLOAD_NETWORK_HDR, 9,
+				      IPPROTO_TCP, 0);
+	if (!stmt)
+		return -ENOMEM;
+	net_ir_ast_add_stmt(ast, stmt);
+
+	stmt = u32_payload_stmt_alloc(NET_IR_PAYLOAD_TRANSPORT_HDR, field->off,
+				      val, mask);
+	if (!stmt)
+		return -ENOMEM;
+
+	net_ir_ast_add_stmt(ast, stmt);
+	return 0;
+}
+
+static struct u32_proto_def u32_tcp_fields = {
+	.protocol 	= IPPROTO_TCP,
+	.parse		= u32_parse_tcp,
+	.field_num	= 2,
+	.fields		= {
+		{ .off = 0,	.mask = 0xffff, },
+		{ .off = 2,	.mask = 0xffff, },
+	},
+};
+
+struct u32_nexthdr {
+	/* offset, shift, and mask of position to next header */
+	unsigned int o;
+	u32 s;
+	u32 m;
+	/* match criteria to make this jump*/
+	unsigned int off;
+	u32 val;
+	u32 mask;
+	/* location of jump to make */
+	struct u32_proto_def *jump;
+};
+
+static struct u32_nexthdr u32_ipv4_jumps[] = {
+	{ .o = 0, .s = 6, .m = 0xf,
+	  .off = 8, .val = 0x600, .mask = 0xff00, .jump = &u32_tcp_fields},
+	{ .jump = NULL } /* terminal node */
+};
+
+#define U32_PARSER_MAX_LINK_HANDLE 10
+
+static LIST_HEAD(u32_parser_tables);
+
+/* This stores the context for the u32 parser */
+struct u32_parser_table {
+	struct list_head	list;
+	struct net_device	*dev;	/* the owner of this table */
+	struct u32_proto_def	*jump_tables[U32_PARSER_MAX_LINK_HANDLE];
+	unsigned long		tables;
+};
+
+static struct u32_parser_table *u32_parser_table_alloc(struct net_device *dev)
+{
+	struct u32_parser_table *ptable;
+
+	ptable = kzalloc(sizeof(struct u32_parser_table), GFP_KERNEL);
+	if (!ptable)
+		return NULL;
+
+	ptable->dev = dev;
+	ptable->jump_tables[0] = &u32_ipv4_fields;
+
+	return ptable;
+}
+
+static struct u32_parser_table *u32_parser_tables_get(struct tcf_proto *tp)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct u32_parser_table *ptable;
+
+	list_for_each_entry(ptable, &u32_parser_tables, list) {
+		if (ptable->dev == dev)
+			return ptable;
+	}
+	ptable = u32_parser_table_alloc(dev);
+	if (!ptable)
+		return NULL;
+
+	list_add(&ptable->list, &u32_parser_tables);
+	return ptable;
+}
+
 static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
+	struct u32_parser_table *p;
 
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
@@ -457,6 +656,19 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 		offload.cls_u32->hnode.handle = h->handle;
 		offload.cls_u32->hnode.prio = h->prio;
 
+		/* No support hash tables at the moment so abort when given
+		 * hash tables.
+		 */
+		if (h->divisor > 0)
+			return;
+
+		p = u32_parser_tables_get(tp);
+		if (!p)
+			return;
+
+		set_bit(TC_U32_USERHTID(offload.cls_u32->hnode.handle),
+			&p->tables);
+
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
 	}
@@ -467,6 +679,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
+	struct u32_parser_table *p;
 
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
@@ -477,11 +690,135 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 		offload.cls_u32->hnode.handle = h->handle;
 		offload.cls_u32->hnode.prio = h->prio;
 
+		p = u32_parser_tables_get(tp);
+		if (!p)
+			return;
+
+		clear_bit(TC_U32_USERHTID(offload.cls_u32->hnode.handle),
+			  &p->tables);
+
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
 	}
 }
 
+static int u32_parser(struct tcf_proto *tp, struct tc_to_netdev *tc)
+{
+	struct tc_cls_u32_offload *cls = tc->cls_u32;
+	struct net_ir_ast *ast = &cls->knode.ast;
+	struct u32_proto_def *proto_def;
+	__be16 protocol = tp->protocol;
+	u32 handle = cls->knode.handle;
+	struct u32_parser_table *p;
+#ifdef CONFIG_NET_CLS_ACT
+	const struct tc_action *a;
+#endif
+	struct net_ir_stmt *stmt;
+	int i;
+
+	/* At the moment cls_u32 jumps to transport layer and skips past
+	 * L2 headers. The canonical method to match L2 frames is to use
+	 * negative values. However this is error prone at best but really
+	 * just broken because there is no way to "know" what sort of hdr
+	 * is in front of the transport layer. Fix cls_u32 to support L2
+	 * headers when needed.
+	 */
+	if (protocol != htons(ETH_P_IP))
+		return -EINVAL;
+
+	p = u32_parser_tables_get(tp);
+	if (!p)
+		return -ENOMEM;
+
+	if (cls->knode.link_handle ||
+	    cls->knode.link_handle >= U32_PARSER_MAX_LINK_HANDLE) {
+		struct u32_nexthdr *nexthdr = u32_ipv4_jumps;
+		u32 uhtid = TC_U32_USERHTID(cls->knode.link_handle);
+
+		if (!test_bit(uhtid, &p->tables))
+			return -EINVAL;
+
+		for (i = 0; nexthdr[i].jump; i++) {
+			if (nexthdr->o != cls->knode.sel->offoff ||
+			    nexthdr->s != cls->knode.sel->offshift ||
+			    nexthdr->m != cls->knode.sel->offmask ||
+			/* do not support multiple key jumps its just mad */
+			    cls->knode.sel->nkeys > 1)
+				return -EINVAL;
+
+			if (nexthdr->off != cls->knode.sel->keys[0].off ||
+			    nexthdr->val != cls->knode.sel->keys[0].val ||
+			    nexthdr->mask != cls->knode.sel->keys[0].mask)
+				return -EINVAL;
+
+			if (uhtid >= U32_PARSER_MAX_LINK_HANDLE)
+				return -EINVAL;
+
+			p->jump_tables[uhtid] = nexthdr->jump;
+		}
+		return -EINVAL; /* don't push this into hardware yet */
+	}
+
+	/* cls u32 is a graph starting at root node 0x800. This parser tracks
+	 * links and also the fields used to advance the parser across each
+	 * link (e.g. nexthdr/eat parameters from 'tc'). This way we can map
+	 * the u32 graph onto the intermediate representation denoted in ir.h.
+	 * To add support for new nodes update parse structures this function
+	 * _should_ be generic try not to hardcode values here.
+	 */
+	if (TC_U32_USERHTID(handle) == 0x800) {
+		proto_def = p->jump_tables[0];
+	} else {
+		if (TC_U32_USERHTID(handle) >= ARRAY_SIZE(p->jump_tables))
+			return -EINVAL;
+
+		proto_def = p->jump_tables[TC_U32_USERHTID(handle)];
+	}
+
+	if (!proto_def)
+		return -EINVAL;
+
+	for (i = 0; i < cls->knode.sel->nkeys; i++) {
+		int off = cls->knode.sel->keys[i].off;
+		__be32 val = cls->knode.sel->keys[i].val;
+		__be32 m = cls->knode.sel->keys[i].mask;
+		bool found_entry = false;
+		int j;
+
+		for (j = 0; j < proto_def->field_num; j++) {
+			if (proto_def->fields[j].off == off &&
+			    proto_def->fields[j].mask == m) {
+				if (proto_def->parse(ast, &proto_def->fields[j],
+						     m, val) < 0)
+					return -EINVAL;
+
+				found_entry = true;
+				break;
+			}
+		}
+
+		if (!found_entry)
+			return -EINVAL;
+	}
+
+#ifdef CONFIG_NET_CLS_ACT
+	if (list_empty(&cls->knode.exts->actions))
+		return -EINVAL;
+
+	list_for_each_entry(a, &cls->knode.exts->actions, list) {
+		if (!is_tcf_gact_shot(a))
+			return -EINVAL;
+	}
+	stmt = net_ir_stmt_alloc(NET_IR_STMT_VERDICT);
+	if (!stmt)
+		return -EINVAL;
+
+	stmt->verdict = NET_IR_VERDICT_DROP;
+	net_ir_ast_add_stmt(ast, stmt);
+#endif
+	return 0;
+}
+
 static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
@@ -507,8 +844,15 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
 		if (n->ht_down)
 			offload.cls_u32->knode.link_handle = n->ht_down->handle;
 
+		net_ir_ast_init(&offload.cls_u32->knode.ast);
+
+		if (u32_parser(tp, &offload) < 0)
+			return;
+
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					      tp->protocol, &offload);
+
+		net_ir_ast_free(&offload.cls_u32->knode.ast);
 	}
 }
 
-- 
2.1.4
