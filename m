From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: nf_tables: add select_ops for stateful objects
Date: Mon,  4 Sep 2017 22:11:04 +0200
Message-ID: <1504555874-4168-3-git-send-email-pablo@netfilter.org>
References: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42128 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754670AbdIDUL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 16:11:26 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AD428532F8B
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:10:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9D1DF2133C
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 22:10:58 +0200 (CEST)
In-Reply-To: <1504555874-4168-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Pablo M. Bermudo Garay" <pablombg@gmail.com>

This patch adds support for overloading stateful objects operations
through the select_ops() callback, just as it is implemented for
expressions.

This change is needed for upcoming additions to the stateful objects
infrastructure.

Signed-off-by: Pablo M. Bermudo Garay <pablombg@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h | 35 ++++++++++++++++++++++++-----------
 net/netfilter/nf_tables_api.c     | 36 ++++++++++++++++++++++++------------
 net/netfilter/nft_counter.c       | 20 +++++++++++++-------
 net/netfilter/nft_ct.c            | 18 ++++++++++++------
 net/netfilter/nft_objref.c        |  7 ++++---
 net/netfilter/nft_quota.c         | 20 +++++++++++++-------
 6 files changed, 90 insertions(+), 46 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f9795fe394f3..0f5b12a4ad09 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -1007,12 +1007,12 @@ int nft_verdict_dump(struct sk_buff *skb, int type,
  *
  *	@list: table stateful object list node
  *	@table: table this object belongs to
- *	@type: pointer to object type
- *	@data: pointer to object data
  *	@name: name of this stateful object
  *	@genmask: generation mask
  *	@use: number of references to this stateful object
  * 	@data: object data, layout depends on type
+ *	@ops: object operations
+ *	@data: pointer to object data
  */
 struct nft_object {
 	struct list_head		list;
@@ -1021,7 +1021,7 @@ struct nft_object {
 	u32				genmask:2,
 					use:30;
 	/* runtime data below here */
-	const struct nft_object_type	*type ____cacheline_aligned;
+	const struct nft_object_ops	*ops ____cacheline_aligned;
 	unsigned char			data[]
 		__attribute__((aligned(__alignof__(u64))));
 };
@@ -1044,27 +1044,39 @@ void nft_obj_notify(struct net *net, struct nft_table *table,
 /**
  *	struct nft_object_type - stateful object type
  *
- *	@eval: stateful object evaluation function
+ *	@select_ops: function to select nft_object_ops
+ *	@ops: default ops, used when no select_ops functions is present
  *	@list: list node in list of object types
  *	@type: stateful object numeric type
- *	@size: stateful object size
  *	@owner: module owner
  *	@maxattr: maximum netlink attribute
  *	@policy: netlink attribute policy
+ */
+struct nft_object_type {
+	const struct nft_object_ops	*(*select_ops)(const struct nft_ctx *,
+						       const struct nlattr * const tb[]);
+	const struct nft_object_ops	*ops;
+	struct list_head		list;
+	u32				type;
+	unsigned int                    maxattr;
+	struct module			*owner;
+	const struct nla_policy		*policy;
+};
+
+/**
+ *	struct nft_object_ops - stateful object operations
+ *
+ *	@eval: stateful object evaluation function
+ *	@size: stateful object size
  *	@init: initialize object from netlink attributes
  *	@destroy: release existing stateful object
  *	@dump: netlink dump stateful object
  */
-struct nft_object_type {
+struct nft_object_ops {
 	void				(*eval)(struct nft_object *obj,
 						struct nft_regs *regs,
 						const struct nft_pktinfo *pkt);
-	struct list_head		list;
-	u32				type;
 	unsigned int			size;
-	unsigned int			maxattr;
-	struct module			*owner;
-	const struct nla_policy		*policy;
 	int				(*init)(const struct nft_ctx *ctx,
 						const struct nlattr *const tb[],
 						struct nft_object *obj);
@@ -1072,6 +1084,7 @@ struct nft_object_type {
 	int				(*dump)(struct sk_buff *skb,
 						struct nft_object *obj,
 						bool reset);
+	const struct nft_object_type	*type;
 };
 
 int nft_register_obj(struct nft_object_type *obj_type);
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 149785ff1c7b..b37c178897f3 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4248,7 +4248,7 @@ struct nft_object *nf_tables_obj_lookup(const struct nft_table *table,
 
 	list_for_each_entry(obj, &table->objects, list) {
 		if (!nla_strcmp(nla, obj->name) &&
-		    objtype == obj->type->type &&
+		    objtype == obj->ops->type->type &&
 		    nft_active_genmask(obj, genmask))
 			return obj;
 	}
@@ -4270,6 +4270,7 @@ static struct nft_object *nft_obj_init(const struct nft_ctx *ctx,
 				       const struct nlattr *attr)
 {
 	struct nlattr *tb[type->maxattr + 1];
+	const struct nft_object_ops *ops;
 	struct nft_object *obj;
 	int err;
 
@@ -4282,16 +4283,27 @@ static struct nft_object *nft_obj_init(const struct nft_ctx *ctx,
 		memset(tb, 0, sizeof(tb[0]) * (type->maxattr + 1));
 	}
 
+	if (type->select_ops) {
+		ops = type->select_ops(ctx, (const struct nlattr * const *)tb);
+		if (IS_ERR(ops)) {
+			err = PTR_ERR(ops);
+			goto err1;
+		}
+	} else {
+		ops = type->ops;
+	}
+
 	err = -ENOMEM;
-	obj = kzalloc(sizeof(struct nft_object) + type->size, GFP_KERNEL);
+	obj = kzalloc(sizeof(*obj) + ops->size, GFP_KERNEL);
 	if (obj == NULL)
 		goto err1;
 
-	err = type->init(ctx, (const struct nlattr * const *)tb, obj);
+	err = ops->init(ctx, (const struct nlattr * const *)tb, obj);
 	if (err < 0)
 		goto err2;
 
-	obj->type = type;
+	obj->ops = ops;
+
 	return obj;
 err2:
 	kfree(obj);
@@ -4307,7 +4319,7 @@ static int nft_object_dump(struct sk_buff *skb, unsigned int attr,
 	nest = nla_nest_start(skb, attr);
 	if (!nest)
 		goto nla_put_failure;
-	if (obj->type->dump(skb, obj, reset) < 0)
+	if (obj->ops->dump(skb, obj, reset) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 	return 0;
@@ -4418,8 +4430,8 @@ static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 err3:
 	kfree(obj->name);
 err2:
-	if (obj->type->destroy)
-		obj->type->destroy(obj);
+	if (obj->ops->destroy)
+		obj->ops->destroy(obj);
 	kfree(obj);
 err1:
 	module_put(type->owner);
@@ -4446,7 +4458,7 @@ static int nf_tables_fill_obj_info(struct sk_buff *skb, struct net *net,
 
 	if (nla_put_string(skb, NFTA_OBJ_TABLE, table->name) ||
 	    nla_put_string(skb, NFTA_OBJ_NAME, obj->name) ||
-	    nla_put_be32(skb, NFTA_OBJ_TYPE, htonl(obj->type->type)) ||
+	    nla_put_be32(skb, NFTA_OBJ_TYPE, htonl(obj->ops->type->type)) ||
 	    nla_put_be32(skb, NFTA_OBJ_USE, htonl(obj->use)) ||
 	    nft_object_dump(skb, NFTA_OBJ_DATA, obj, reset))
 		goto nla_put_failure;
@@ -4500,7 +4512,7 @@ static int nf_tables_dump_obj(struct sk_buff *skb, struct netlink_callback *cb)
 					goto cont;
 				if (filter &&
 				    filter->type != NFT_OBJECT_UNSPEC &&
-				    obj->type->type != filter->type)
+				    obj->ops->type->type != filter->type)
 					goto cont;
 
 				if (nf_tables_fill_obj_info(skb, net, NETLINK_CB(cb->skb).portid,
@@ -4628,10 +4640,10 @@ static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 
 static void nft_obj_destroy(struct nft_object *obj)
 {
-	if (obj->type->destroy)
-		obj->type->destroy(obj);
+	if (obj->ops->destroy)
+		obj->ops->destroy(obj);
 
-	module_put(obj->type->owner);
+	module_put(obj->ops->type->owner);
 	kfree(obj->name);
 	kfree(obj);
 }
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 67a710ebde09..eefe3b409925 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -175,15 +175,21 @@ static const struct nla_policy nft_counter_policy[NFTA_COUNTER_MAX + 1] = {
 	[NFTA_COUNTER_BYTES]	= { .type = NLA_U64 },
 };
 
-static struct nft_object_type nft_counter_obj __read_mostly = {
-	.type		= NFT_OBJECT_COUNTER,
+static struct nft_object_type nft_counter_obj_type;
+static const struct nft_object_ops nft_counter_obj_ops = {
+	.type		= &nft_counter_obj_type,
 	.size		= sizeof(struct nft_counter_percpu_priv),
-	.maxattr	= NFTA_COUNTER_MAX,
-	.policy		= nft_counter_policy,
 	.eval		= nft_counter_obj_eval,
 	.init		= nft_counter_obj_init,
 	.destroy	= nft_counter_obj_destroy,
 	.dump		= nft_counter_obj_dump,
+};
+
+static struct nft_object_type nft_counter_obj_type __read_mostly = {
+	.type		= NFT_OBJECT_COUNTER,
+	.ops		= &nft_counter_obj_ops,
+	.maxattr	= NFTA_COUNTER_MAX,
+	.policy		= nft_counter_policy,
 	.owner		= THIS_MODULE,
 };
 
@@ -271,7 +277,7 @@ static int __init nft_counter_module_init(void)
 	for_each_possible_cpu(cpu)
 		seqcount_init(per_cpu_ptr(&nft_counter_seq, cpu));
 
-	err = nft_register_obj(&nft_counter_obj);
+	err = nft_register_obj(&nft_counter_obj_type);
 	if (err < 0)
 		return err;
 
@@ -281,14 +287,14 @@ static int __init nft_counter_module_init(void)
 
 	return 0;
 err1:
-	nft_unregister_obj(&nft_counter_obj);
+	nft_unregister_obj(&nft_counter_obj_type);
 	return err;
 }
 
 static void __exit nft_counter_module_exit(void)
 {
 	nft_unregister_expr(&nft_counter_type);
-	nft_unregister_obj(&nft_counter_obj);
+	nft_unregister_obj(&nft_counter_obj_type);
 }
 
 module_init(nft_counter_module_init);
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 1678e9e75e8e..bd0975d7dd6f 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -904,15 +904,21 @@ static const struct nla_policy nft_ct_helper_policy[NFTA_CT_HELPER_MAX + 1] = {
 	[NFTA_CT_HELPER_L4PROTO] = { .type = NLA_U8 },
 };
 
-static struct nft_object_type nft_ct_helper_obj __read_mostly = {
-	.type		= NFT_OBJECT_CT_HELPER,
+static struct nft_object_type nft_ct_helper_obj_type;
+static const struct nft_object_ops nft_ct_helper_obj_ops = {
+	.type		= &nft_ct_helper_obj_type,
 	.size		= sizeof(struct nft_ct_helper_obj),
-	.maxattr	= NFTA_CT_HELPER_MAX,
-	.policy		= nft_ct_helper_policy,
 	.eval		= nft_ct_helper_obj_eval,
 	.init		= nft_ct_helper_obj_init,
 	.destroy	= nft_ct_helper_obj_destroy,
 	.dump		= nft_ct_helper_obj_dump,
+};
+
+static struct nft_object_type nft_ct_helper_obj_type __read_mostly = {
+	.type		= NFT_OBJECT_CT_HELPER,
+	.ops		= &nft_ct_helper_obj_ops,
+	.maxattr	= NFTA_CT_HELPER_MAX,
+	.policy		= nft_ct_helper_policy,
 	.owner		= THIS_MODULE,
 };
 
@@ -930,7 +936,7 @@ static int __init nft_ct_module_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = nft_register_obj(&nft_ct_helper_obj);
+	err = nft_register_obj(&nft_ct_helper_obj_type);
 	if (err < 0)
 		goto err2;
 
@@ -945,7 +951,7 @@ static int __init nft_ct_module_init(void)
 
 static void __exit nft_ct_module_exit(void)
 {
-	nft_unregister_obj(&nft_ct_helper_obj);
+	nft_unregister_obj(&nft_ct_helper_obj_type);
 	nft_unregister_expr(&nft_notrack_type);
 	nft_unregister_expr(&nft_ct_type);
 }
diff --git a/net/netfilter/nft_objref.c b/net/netfilter/nft_objref.c
index 1dd428fbaaa3..7bcdc48f3d73 100644
--- a/net/netfilter/nft_objref.c
+++ b/net/netfilter/nft_objref.c
@@ -22,7 +22,7 @@ static void nft_objref_eval(const struct nft_expr *expr,
 {
 	struct nft_object *obj = nft_objref_priv(expr);
 
-	obj->type->eval(obj, regs, pkt);
+	obj->ops->eval(obj, regs, pkt);
 }
 
 static int nft_objref_init(const struct nft_ctx *ctx,
@@ -54,7 +54,8 @@ static int nft_objref_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	const struct nft_object *obj = nft_objref_priv(expr);
 
 	if (nla_put_string(skb, NFTA_OBJREF_IMM_NAME, obj->name) ||
-	    nla_put_be32(skb, NFTA_OBJREF_IMM_TYPE, htonl(obj->type->type)))
+	    nla_put_be32(skb, NFTA_OBJREF_IMM_TYPE,
+			 htonl(obj->ops->type->type)))
 		goto nla_put_failure;
 
 	return 0;
@@ -104,7 +105,7 @@ static void nft_objref_map_eval(const struct nft_expr *expr,
 		return;
 	}
 	obj = *nft_set_ext_obj(ext);
-	obj->type->eval(obj, regs, pkt);
+	obj->ops->eval(obj, regs, pkt);
 }
 
 static int nft_objref_map_init(const struct nft_ctx *ctx,
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index 25e33159be57..0ed124a93fcf 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -151,14 +151,20 @@ static int nft_quota_obj_dump(struct sk_buff *skb, struct nft_object *obj,
 	return nft_quota_do_dump(skb, priv, reset);
 }
 
-static struct nft_object_type nft_quota_obj __read_mostly = {
-	.type		= NFT_OBJECT_QUOTA,
+static struct nft_object_type nft_quota_obj_type;
+static const struct nft_object_ops nft_quota_obj_ops = {
+	.type		= &nft_quota_obj_type,
 	.size		= sizeof(struct nft_quota),
-	.maxattr	= NFTA_QUOTA_MAX,
-	.policy		= nft_quota_policy,
 	.init		= nft_quota_obj_init,
 	.eval		= nft_quota_obj_eval,
 	.dump		= nft_quota_obj_dump,
+};
+
+static struct nft_object_type nft_quota_obj_type __read_mostly = {
+	.type		= NFT_OBJECT_QUOTA,
+	.ops		= &nft_quota_obj_ops,
+	.maxattr	= NFTA_QUOTA_MAX,
+	.policy		= nft_quota_policy,
 	.owner		= THIS_MODULE,
 };
 
@@ -209,7 +215,7 @@ static int __init nft_quota_module_init(void)
 {
 	int err;
 
-	err = nft_register_obj(&nft_quota_obj);
+	err = nft_register_obj(&nft_quota_obj_type);
 	if (err < 0)
 		return err;
 
@@ -219,14 +225,14 @@ static int __init nft_quota_module_init(void)
 
 	return 0;
 err1:
-	nft_unregister_obj(&nft_quota_obj);
+	nft_unregister_obj(&nft_quota_obj_type);
 	return err;
 }
 
 static void __exit nft_quota_module_exit(void)
 {
 	nft_unregister_expr(&nft_quota_type);
-	nft_unregister_obj(&nft_quota_obj);
+	nft_unregister_obj(&nft_quota_obj_type);
 }
 
 module_init(nft_quota_module_init);
-- 
2.1.4
