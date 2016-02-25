From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 2/3] net: intermediate representation for jit translation
Date: Thu, 25 Feb 2016 18:37:23 +0100
Message-ID: <1456421844-5901-3-git-send-email-pablo@netfilter.org>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36286 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933434AbcBYRhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 12:37:34 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 161E17412
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:33 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 03EFBDA398
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:33 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A88D7DA394
	for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 18:37:30 +0100 (CET)
In-Reply-To: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the generic intermediate representation that consists of
abstract syntax tree (ast) that is expressed via a list of statements.
Currently there are two type of statements:

* Expression, that is used to match packet selector and meta
  information. Expressions are basically small trees that represent what
  you want to match.

* Actions, that you can use to indicate what action you want to perform
  on the packets, currently only verdict supported but it should be
  easy to extend it to support other actions.

The general idea is that every frontend needs to provide a parser that
builds the ast, then pass this to the backend. Since the representation
is the same for every frontend, the plan is to achieve a single unified
backend jit translation from the ast to the internal backend
representation.

>From the backend side, you can use this generic infrastructure to
describe the jit translation from the intermediate representation
expressed through an abstract syntax tree to target internal
representation.

The backend has to define the jit description structure, which looks
like the following:

 struct net_ir_jit_desc {
       enum net_ir_payload_bases               base;
       const struct net_ir_proto_desc          *proto_desc;
       int                                     (*verdict)(struct net_ir_jit_ctx *ctx,
                                                          enum net_ir_stmt_verdict verdict,
                                                          void *data);
 };

This structure contains a protocol description (defined by struct
net_ir_proto_desc) that is the initial node of the protocol graph that
describes the protocol translation. This initial node starts from lower
supported layer as base (eg. link-layer) then describing the upper
protocols up to the transport protocols through the following structure:

 struct net_ir_proto_desc {
       enum net_ir_payload_bases               base;
       u32                                     protonum;
       int                                     (*jit)(struct net_ir_jit_ctx *ctx,
                                                      const struct net_ir_expr *expr,
                                                      void *data);
       const struct net_ir_proto_desc          *protocols[];
 };

This patch also includes an initial action to describe the verdict on
the packet. Meta matching and other actions are not yet available, but
it should be easy to add them to this representation.

The net_ir_jit_ctx structure is opaque to the backend, currently you use
this context object to update protocol context via:

 int net_ir_jit_update_pctx(struct net_ir_jit_ctx *ctx, u32 base, u32 proto);

Taking the ast as input, the backend can generate the internal
backend representation invoking the net_ir_jit() function.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ir.h  | 173 ++++++++++++++++++++++++++++++++++++++++++
 net/core/Makefile |   2 +-
 net/core/ir.c     | 219 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 393 insertions(+), 1 deletion(-)
 create mode 100644 include/net/ir.h
 create mode 100644 net/core/ir.c

diff --git a/include/net/ir.h b/include/net/ir.h
new file mode 100644
index 0000000..e3012a7
--- /dev/null
+++ b/include/net/ir.h
@@ -0,0 +1,173 @@
+#ifndef _NET_IR_H_
+#define _NET_IR_H_
+
+/**
+ * net_ir_expr_type - expression type
+ *
+ * NET_IR_EXPR_RELATIONAL: this relates two different expression, eg. matching
+ * NET_IR_EXPR_VALUE: a value
+ * NET_IR_EXPR_PAYLOAD: a payload expression [base, offset, length]
+ * NET_IR_EXPR_BINOP: a binary expression for bitwise operation
+ */
+enum net_ir_expr_type {
+	NET_IR_EXPR_UNSPEC	= 0,
+	NET_IR_EXPR_RELATIONAL,
+	NET_IR_EXPR_VALUE,
+	NET_IR_EXPR_PAYLOAD,
+	NET_IR_EXPR_BINOP,
+};
+
+/**
+ * net_ir_expr_ops - expression operations
+ *
+ * NET_IR_OP_EQ: expressions on both hand sides are equal
+ * NET_IR_OP_AND: expression on the lhs is and'ed to the one on the rhs
+ */
+enum net_ir_expr_ops {
+	NET_IR_OP_INVALID,
+	NET_IR_OP_EQ,
+	NET_IR_OP_AND,
+};
+
+/**
+ * net_ir_payload_baser_payload_basess - payload expression bases
+ *
+ * This indicates where the payload expression starts from.
+ *
+ * NET_IR_PAYLOAD_LL_HDR: link-layer header.
+ * NET_IR_PAYLOAD_NETWORK_HDR: network header.
+ * NET_IR_PAYLOAD_TRANSPORT_HDR: transport header.
+ */
+enum net_ir_payload_bases {
+	NET_IR_PAYLOAD_LL_HDR		= 0,
+	NET_IR_PAYLOAD_NETWORK_HDR,
+	NET_IR_PAYLOAD_TRANSPORT_HDR,
+	NET_IR_PAYLOAD_MAX_HDR
+};
+
+/**
+ *     struct net_ir_expr - expression
+ *
+ *     @type: expression type
+ *     @op: type of operation
+ *     @len: length of expression
+ */
+struct net_ir_expr {
+	enum net_ir_expr_type				type;
+	enum net_ir_expr_ops				op;
+	u32						len;
+	union {
+		struct {
+			u32				data;
+		} value;
+		struct {
+			enum net_ir_payload_bases	base;
+			u32				offset;
+		} payload;
+		struct {
+			struct net_ir_expr		*left;
+			struct net_ir_expr		*right;
+		} relational;
+		struct {
+			struct net_ir_expr		*left;
+			struct net_ir_expr		*right;
+		} binop;
+	};
+};
+
+struct net_ir_expr *net_ir_expr_alloc(enum net_ir_expr_type type);
+void net_ir_expr_free(struct net_ir_expr *expr);
+
+/**
+ * net_ir_stmt_type - statement types
+ *
+ * NET_IR_STMT_EXPR: expression statement, eg. matching payload.
+ * NET_IR_STMT_VERDICT: verdict statement (accept, drop)
+ */
+enum net_ir_stmt_type {
+	NET_IR_STMT_EXPR	= 0,
+	NET_IR_STMT_VERDICT,
+};
+
+/**
+ * net_stmt_verdict - verdict statement
+ *
+ * NET_IR_DROP: drop packet
+ * NET_IR_ACCEPT: accept packet
+ */
+enum net_ir_stmt_verdict {
+	NET_IR_VERDICT_DROP	= 0,
+	NET_IR_VERDICT_ACCEPT,
+};
+
+/**
+ * struct net_ir_stmt - statement
+ *
+ * @type: statement type
+ */
+struct net_ir_stmt {
+	struct list_head			list;
+
+	enum net_ir_stmt_type			type;
+	union {
+		struct net_ir_expr		*expr;
+		enum net_ir_stmt_verdict	verdict;
+	};
+};
+
+struct net_ir_stmt *net_ir_stmt_alloc(enum net_ir_stmt_type type);
+
+/* Opaque context object during jit transformation. */
+struct net_ir_jit_ctx;
+
+/**
+ * struct net_ir_proto_desc - protocol description
+ *
+ * @base: payload base
+ * @protonum: protocol number
+ * @jit: jit function
+ * @protocols: array of upper layer protocols on top of this
+ */
+struct net_ir_proto_desc {
+	enum net_ir_payload_bases		base;
+	u32					protonum;
+	int					(*jit)(struct net_ir_jit_ctx *ctx,
+						       const struct net_ir_expr *expr,
+						       void *data);
+	const struct net_ir_proto_desc		*protocols[];
+};
+
+/**
+ * struct net_ir_jit_desc - generic description
+ */
+struct net_ir_jit_desc {
+	enum net_ir_payload_bases		base;
+	const struct net_ir_proto_desc		*proto_desc;
+	int					(*verdict)(struct net_ir_jit_ctx *ctx,
+							   enum net_ir_stmt_verdict verdict,
+							   void *data);
+};
+
+struct net_ir_ast {
+	struct list_head stmt_list;
+};
+
+static inline void net_ir_ast_init(struct net_ir_ast *ast)
+{
+	INIT_LIST_HEAD(&ast->stmt_list);
+}
+
+static inline void net_ir_ast_add_stmt(struct net_ir_ast *ast,
+				       struct net_ir_stmt *stmt)
+{
+	list_add_tail(&stmt->list, &ast->stmt_list);
+}
+
+void net_ir_ast_free(struct net_ir_ast *ast);
+
+int net_ir_jit_update_pctx(struct net_ir_jit_ctx *ctx, u32 base, u32 proto);
+
+int net_ir_jit(const struct net_ir_ast *ast,
+	       const struct net_ir_jit_desc *jit_desc, void *data);
+
+#endif
diff --git a/net/core/Makefile b/net/core/Makefile
index 7a8fb8a..4070019 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
+			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o ir.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/ir.c b/net/core/ir.c
new file mode 100644
index 0000000..e3340c8
--- /dev/null
+++ b/net/core/ir.c
@@ -0,0 +1,219 @@
+/*
+ * Copyright (c) 2016 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <net/ir.h>
+
+struct net_ir_expr *net_ir_expr_alloc(enum net_ir_expr_type type)
+{
+	struct net_ir_expr *expr;
+
+	expr = kzalloc(sizeof(struct net_ir_expr), GFP_KERNEL);
+	if (expr == NULL)
+		return NULL;
+
+	expr->type = type;
+	expr->op   = NET_IR_OP_INVALID;
+
+	return expr;
+}
+EXPORT_SYMBOL_GPL(net_ir_expr_alloc);
+
+void net_ir_expr_free(struct net_ir_expr *expr)
+{
+	switch (expr->type) {
+	case NET_IR_EXPR_VALUE:
+	case NET_IR_EXPR_PAYLOAD:
+		kfree(expr);
+		break;
+	case NET_IR_EXPR_RELATIONAL:
+		net_ir_expr_free(expr->relational.left);
+		net_ir_expr_free(expr->relational.right);
+		kfree(expr);
+		break;
+	case NET_IR_EXPR_BINOP:
+		net_ir_expr_free(expr->binop.left);
+		net_ir_expr_free(expr->binop.right);
+		kfree(expr);
+		break;
+	default:
+		WARN_ONCE(1, "Destroying unknown expr %u\n", expr->type);
+	}
+}
+EXPORT_SYMBOL_GPL(net_ir_expr_free);
+
+struct net_ir_stmt *net_ir_stmt_alloc(enum net_ir_stmt_type type)
+{
+	struct net_ir_stmt *stmt;
+
+	stmt = kmalloc(sizeof(struct net_ir_stmt), GFP_KERNEL);
+	if (stmt == NULL)
+		return NULL;
+
+	stmt->type = type;
+	return stmt;
+}
+EXPORT_SYMBOL_GPL(net_ir_stmt_alloc);
+
+static void net_ir_stmt_free(struct net_ir_stmt *stmt)
+{
+	switch (stmt->type) {
+	case NET_IR_STMT_EXPR:
+		net_ir_expr_free(stmt->expr);
+		break;
+	case NET_IR_STMT_VERDICT:
+		break;
+	}
+	kfree(stmt);
+}
+
+void net_ir_ast_free(struct net_ir_ast *ast)
+{
+	struct net_ir_stmt *stmt, *next;
+
+	list_for_each_entry_safe(stmt, next, &ast->stmt_list, list) {
+		list_del(&stmt->list);
+		net_ir_stmt_free(stmt);
+	}
+}
+EXPORT_SYMBOL_GPL(net_ir_ast_free);
+
+struct net_ir_jit_ctx {
+	const struct net_ir_jit_desc	*jit_desc;
+	const struct net_ir_proto_desc	*pctx[NET_IR_PAYLOAD_MAX_HDR];
+	void				*data;
+};
+
+int net_ir_jit_update_pctx(struct net_ir_jit_ctx *ctx, u32 base, u32 proto)
+{
+	struct net_ir_proto_desc **protos =
+		(struct net_ir_proto_desc **)ctx->pctx[base - 1]->protocols;
+	int i;
+
+	/* We need to know about the underlying protocol to push a new one on
+	 * top of it.
+	 */
+	if (protos == NULL)
+		return -EINVAL;
+
+	for (i = 0; protos[i] != NULL; i++) {
+		if (protos[i]->protonum != proto)
+			continue;
+
+		ctx->pctx[base] = protos[i];
+		return 0;
+	}
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(net_ir_jit_update_pctx);
+
+static int net_ir_jit_relational(struct net_ir_jit_ctx *ctx,
+				 const struct net_ir_expr *expr)
+{
+	const struct net_ir_expr *left = expr->relational.left;
+	const struct net_ir_expr *right = expr->relational.right;
+	const struct net_ir_proto_desc *proto_desc;
+	int err;
+
+	if (right->type != NET_IR_EXPR_VALUE)
+		return -EINVAL;
+
+	if (left->type == NET_IR_EXPR_BINOP)
+		left = left->binop.left;
+
+	switch (left->type) {
+	case NET_IR_EXPR_PAYLOAD:
+		proto_desc = ctx->pctx[left->payload.base];
+		if (!proto_desc)
+			return -EOPNOTSUPP;
+
+		err = proto_desc->jit(ctx, expr, ctx->data);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return err;
+}
+
+static int net_ir_jit_expr(struct net_ir_jit_ctx *ctx,
+			   const struct net_ir_expr *expr)
+{
+	int err;
+
+	switch (expr->type) {
+	case NET_IR_EXPR_RELATIONAL:
+		err = net_ir_jit_relational(ctx, expr);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return err;
+}
+
+static int net_ir_jit_verdict(struct net_ir_jit_ctx *ctx,
+			      enum net_ir_stmt_verdict verdict)
+{
+	int err;
+
+	switch (verdict) {
+	case NET_IR_VERDICT_DROP:
+	case NET_IR_VERDICT_ACCEPT:
+		err = ctx->jit_desc->verdict(ctx, verdict, ctx->data);
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return err;
+}
+
+/**
+ * net_ir_jit_ctx_init - initialize jit context
+ *
+ * @ctx: jit context object
+ * @proto_desc: protocol description
+ */
+static void net_ir_jit_ctx_init(struct net_ir_jit_ctx *ctx,
+				const struct net_ir_jit_desc *jit_desc,
+				void *data)
+{
+	memset(ctx, 0, sizeof(*ctx));
+	ctx->jit_desc = jit_desc;
+	ctx->pctx[jit_desc->base] = jit_desc->proto_desc;
+	ctx->data = data;
+}
+
+int net_ir_jit(const struct net_ir_ast *ast,
+	       const struct net_ir_jit_desc *jit_desc, void *target)
+{
+	struct net_ir_jit_ctx ctx;
+	struct net_ir_stmt *stmt;
+	int err = 0;
+
+	net_ir_jit_ctx_init(&ctx, jit_desc, target);
+
+	list_for_each_entry(stmt, &ast->stmt_list, list) {
+		switch (stmt->type) {
+		case NET_IR_STMT_EXPR:
+			err = net_ir_jit_expr(&ctx, stmt->expr);
+			break;
+		case NET_IR_STMT_VERDICT:
+			err = net_ir_jit_verdict(&ctx, stmt->verdict);
+			break;
+		default:
+			return -EOPNOTSUPP;
+		}
+	}
+	return err;
+}
+EXPORT_SYMBOL_GPL(net_ir_jit);
-- 
2.1.4
