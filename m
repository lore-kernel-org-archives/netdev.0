From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 37/50] netfilter: nf_tables: atomic dump and reset for stateful objects
Date: Wed,  7 Dec 2016 22:52:43 +0100
Message-ID: <1481147576-5690-38-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new NFT_MSG_GETOBJ_RESET command perform an atomic
dump-and-reset of the stateful object. This also comes with add support
for atomic dump and reset for counter and quota objects.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        |  3 +-
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nf_tables_api.c            | 29 ++++++++++++-----
 net/netfilter/nft_counter.c              | 56 +++++++++++++++++++++++++++-----
 net/netfilter/nft_quota.c                | 18 ++++++----
 5 files changed, 85 insertions(+), 23 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index 903cd618f50e..6f7d6a1dc09c 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -997,7 +997,8 @@ struct nft_object_type {
 						struct nft_object *obj);
 	void				(*destroy)(struct nft_object *obj);
 	int				(*dump)(struct sk_buff *skb,
-						const struct nft_object *obj);
+						struct nft_object *obj,
+						bool reset);
 };
 
 int nft_register_obj(struct nft_object_type *obj_type);
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 3d47582caa80..399eac1eee91 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -89,6 +89,7 @@ enum nft_verdicts {
  * @NFT_MSG_NEWOBJ: create a stateful object (enum nft_obj_attributes)
  * @NFT_MSG_GETOBJ: get a stateful object (enum nft_obj_attributes)
  * @NFT_MSG_DELOBJ: delete a stateful object (enum nft_obj_attributes)
+ * @NFT_MSG_GETOBJ_RESET: get and reset a stateful object (enum nft_obj_attributes)
  */
 enum nf_tables_msg_types {
 	NFT_MSG_NEWTABLE,
@@ -112,6 +113,7 @@ enum nf_tables_msg_types {
 	NFT_MSG_NEWOBJ,
 	NFT_MSG_GETOBJ,
 	NFT_MSG_DELOBJ,
+	NFT_MSG_GETOBJ_RESET,
 	NFT_MSG_MAX,
 };
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2ae717c5dcb8..bfc015af366a 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3972,14 +3972,14 @@ static struct nft_object *nft_obj_init(const struct nft_object_type *type,
 }
 
 static int nft_object_dump(struct sk_buff *skb, unsigned int attr,
-			   const struct nft_object *obj)
+			   struct nft_object *obj, bool reset)
 {
 	struct nlattr *nest;
 
 	nest = nla_nest_start(skb, attr);
 	if (!nest)
 		goto nla_put_failure;
-	if (obj->type->dump(skb, obj) < 0)
+	if (obj->type->dump(skb, obj, reset) < 0)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 	return 0;
@@ -4096,7 +4096,7 @@ static int nf_tables_newobj(struct net *net, struct sock *nlsk,
 static int nf_tables_fill_obj_info(struct sk_buff *skb, struct net *net,
 				   u32 portid, u32 seq, int event, u32 flags,
 				   int family, const struct nft_table *table,
-				   const struct nft_object *obj)
+				   struct nft_object *obj, bool reset)
 {
 	struct nfgenmsg *nfmsg;
 	struct nlmsghdr *nlh;
@@ -4115,7 +4115,7 @@ static int nf_tables_fill_obj_info(struct sk_buff *skb, struct net *net,
 	    nla_put_string(skb, NFTA_OBJ_NAME, obj->name) ||
 	    nla_put_be32(skb, NFTA_OBJ_TYPE, htonl(obj->type->type)) ||
 	    nla_put_be32(skb, NFTA_OBJ_USE, htonl(obj->use)) ||
-	    nft_object_dump(skb, NFTA_OBJ_DATA, obj))
+	    nft_object_dump(skb, NFTA_OBJ_DATA, obj, reset))
 		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
@@ -4131,10 +4131,14 @@ static int nf_tables_dump_obj(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	const struct nft_af_info *afi;
 	const struct nft_table *table;
-	const struct nft_object *obj;
 	unsigned int idx = 0, s_idx = cb->args[0];
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
+	struct nft_object *obj;
+	bool reset = false;
+
+	if (NFNL_MSG_TYPE(cb->nlh->nlmsg_type) == NFT_MSG_GETOBJ_RESET)
+		reset = true;
 
 	rcu_read_lock();
 	cb->seq = net->nft.base_seq;
@@ -4156,7 +4160,7 @@ static int nf_tables_dump_obj(struct sk_buff *skb, struct netlink_callback *cb)
 							    cb->nlh->nlmsg_seq,
 							    NFT_MSG_NEWOBJ,
 							    NLM_F_MULTI | NLM_F_APPEND,
-							    afi->family, table, obj) < 0)
+							    afi->family, table, obj, reset) < 0)
 					goto done;
 
 				nl_dump_check_consistent(cb, nlmsg_hdr(skb));
@@ -4183,6 +4187,7 @@ static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 	const struct nft_table *table;
 	struct nft_object *obj;
 	struct sk_buff *skb2;
+	bool reset = false;
 	u32 objtype;
 	int err;
 
@@ -4214,9 +4219,12 @@ static int nf_tables_getobj(struct net *net, struct sock *nlsk,
 	if (!skb2)
 		return -ENOMEM;
 
+	if (NFNL_MSG_TYPE(nlh->nlmsg_type) == NFT_MSG_GETOBJ_RESET)
+		reset = true;
+
 	err = nf_tables_fill_obj_info(skb2, net, NETLINK_CB(skb).portid,
 				      nlh->nlmsg_seq, NFT_MSG_NEWOBJ, 0,
-				      family, table, obj);
+				      family, table, obj, reset);
 	if (err < 0)
 		goto err;
 
@@ -4291,7 +4299,7 @@ static int nf_tables_obj_notify(const struct nft_ctx *ctx,
 
 	err = nf_tables_fill_obj_info(skb, ctx->net, ctx->portid, ctx->seq,
 				      event, 0, ctx->afi->family, ctx->table,
-				      obj);
+				      obj, false);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto err;
@@ -4482,6 +4490,11 @@ static const struct nfnl_callback nf_tables_cb[NFT_MSG_MAX] = {
 		.attr_count	= NFTA_OBJ_MAX,
 		.policy		= nft_obj_policy,
 	},
+	[NFT_MSG_GETOBJ_RESET] = {
+		.call		= nf_tables_getobj,
+		.attr_count	= NFTA_OBJ_MAX,
+		.policy		= nft_obj_policy,
+	},
 };
 
 static void nft_chain_commit_update(struct nft_trans *trans)
diff --git a/net/netfilter/nft_counter.c b/net/netfilter/nft_counter.c
index 6f3dd429f865..f6a02c5071c2 100644
--- a/net/netfilter/nft_counter.c
+++ b/net/netfilter/nft_counter.c
@@ -100,10 +100,10 @@ static void nft_counter_obj_destroy(struct nft_object *obj)
 	nft_counter_do_destroy(priv);
 }
 
-static void nft_counter_fetch(const struct nft_counter_percpu __percpu *counter,
+static void nft_counter_fetch(struct nft_counter_percpu __percpu *counter,
 			      struct nft_counter *total)
 {
-	const struct nft_counter_percpu *cpu_stats;
+	struct nft_counter_percpu *cpu_stats;
 	u64 bytes, packets;
 	unsigned int seq;
 	int cpu;
@@ -122,12 +122,52 @@ static void nft_counter_fetch(const struct nft_counter_percpu __percpu *counter,
 	}
 }
 
+static u64 __nft_counter_reset(u64 *counter)
+{
+	u64 ret, old;
+
+	do {
+		old = *counter;
+		ret = cmpxchg64(counter, old, 0);
+	} while (ret != old);
+
+	return ret;
+}
+
+static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
+			      struct nft_counter *total)
+{
+	struct nft_counter_percpu *cpu_stats;
+	u64 bytes, packets;
+	unsigned int seq;
+	int cpu;
+
+	memset(total, 0, sizeof(*total));
+	for_each_possible_cpu(cpu) {
+		bytes = packets = 0;
+
+		cpu_stats = per_cpu_ptr(counter, cpu);
+		do {
+			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
+			packets	+= __nft_counter_reset(&cpu_stats->counter.packets);
+			bytes	+= __nft_counter_reset(&cpu_stats->counter.bytes);
+		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
+
+		total->packets += packets;
+		total->bytes += bytes;
+	}
+}
+
 static int nft_counter_do_dump(struct sk_buff *skb,
-			       const struct nft_counter_percpu_priv *priv)
+			       const struct nft_counter_percpu_priv *priv,
+			       bool reset)
 {
 	struct nft_counter total;
 
-	nft_counter_fetch(priv->counter, &total);
+	if (reset)
+		nft_counter_reset(priv->counter, &total);
+	else
+		nft_counter_fetch(priv->counter, &total);
 
 	if (nla_put_be64(skb, NFTA_COUNTER_BYTES, cpu_to_be64(total.bytes),
 			 NFTA_COUNTER_PAD) ||
@@ -141,11 +181,11 @@ static int nft_counter_do_dump(struct sk_buff *skb,
 }
 
 static int nft_counter_obj_dump(struct sk_buff *skb,
-				const struct nft_object *obj)
+				struct nft_object *obj, bool reset)
 {
-	const struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
+	struct nft_counter_percpu_priv *priv = nft_obj_data(obj);
 
-	return nft_counter_do_dump(skb, priv);
+	return nft_counter_do_dump(skb, priv, reset);
 }
 
 static const struct nla_policy nft_counter_policy[NFTA_COUNTER_MAX + 1] = {
@@ -178,7 +218,7 @@ static int nft_counter_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_counter_percpu_priv *priv = nft_expr_priv(expr);
 
-	return nft_counter_do_dump(skb, priv);
+	return nft_counter_do_dump(skb, priv, false);
 }
 
 static int nft_counter_init(const struct nft_ctx *ctx,
diff --git a/net/netfilter/nft_quota.c b/net/netfilter/nft_quota.c
index 0d344209803a..5d25f57497cb 100644
--- a/net/netfilter/nft_quota.c
+++ b/net/netfilter/nft_quota.c
@@ -83,12 +83,17 @@ static int nft_quota_obj_init(const struct nlattr * const tb[],
 	return nft_quota_do_init(tb, priv);
 }
 
-static int nft_quota_do_dump(struct sk_buff *skb, const struct nft_quota *priv)
+static int nft_quota_do_dump(struct sk_buff *skb, struct nft_quota *priv,
+			     bool reset)
 {
 	u32 flags = priv->invert ? NFT_QUOTA_F_INV : 0;
 	u64 consumed;
 
-	consumed = atomic64_read(&priv->consumed);
+	if (reset)
+		consumed = atomic64_xchg(&priv->consumed, 0);
+	else
+		consumed = atomic64_read(&priv->consumed);
+
 	/* Since we inconditionally increment consumed quota for each packet
 	 * that we see, don't go over the quota boundary in what we send to
 	 * userspace.
@@ -108,11 +113,12 @@ static int nft_quota_do_dump(struct sk_buff *skb, const struct nft_quota *priv)
 	return -1;
 }
 
-static int nft_quota_obj_dump(struct sk_buff *skb, const struct nft_object *obj)
+static int nft_quota_obj_dump(struct sk_buff *skb, struct nft_object *obj,
+			      bool reset)
 {
 	struct nft_quota *priv = nft_obj_data(obj);
 
-	return nft_quota_do_dump(skb, priv);
+	return nft_quota_do_dump(skb, priv, reset);
 }
 
 static struct nft_object_type nft_quota_obj __read_mostly = {
@@ -146,9 +152,9 @@ static int nft_quota_init(const struct nft_ctx *ctx,
 
 static int nft_quota_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
-	const struct nft_quota *priv = nft_expr_priv(expr);
+	struct nft_quota *priv = nft_expr_priv(expr);
 
-	return nft_quota_do_dump(skb, priv);
+	return nft_quota_do_dump(skb, priv, false);
 }
 
 static struct nft_expr_type nft_quota_type;
-- 
2.1.4

