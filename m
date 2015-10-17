From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/35] netfilter: nfnetlink_queue: rename related to nfqueue attaching conntrack info
Date: Sat, 17 Oct 2015 13:32:41 +0200
Message-ID: <1445081590-2924-7-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

The idea of this series of patch is to attach conntrack information to
nflog like nfqueue has already done. nfqueue conntrack info attaching
basis is generic, rename those names to generic one, glue.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h            |  4 +--
 net/netfilter/core.c                 |  4 +--
 net/netfilter/nf_conntrack_netlink.c | 60 ++++++++++++++++++------------------
 net/netfilter/nfnetlink_queue.c      | 30 +++++++++---------
 4 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 3e5e8f2..27747de 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -377,7 +377,7 @@ struct nf_conn;
 enum ip_conntrack_info;
 struct nlattr;
 
-struct nfq_ct_hook {
+struct nfnl_ct_hook {
 	struct nf_conn *(*get_ct)(struct sk_buff *skb,
 				  enum ip_conntrack_info *ctinfo);
 	size_t (*build_size)(const struct nf_conn *ct);
@@ -390,7 +390,7 @@ struct nfq_ct_hook {
 	void (*seq_adjust)(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo, s32 off);
 };
-extern struct nfq_ct_hook __rcu *nfq_ct_hook;
+extern struct nfnl_ct_hook __rcu *nfnl_ct_hook;
 
 /**
  * nf_skb_duplicated - TEE target has sent a packet
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 1412e36..32a2894 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -351,8 +351,8 @@ EXPORT_SYMBOL(skb_make_writable);
 /* This needs to be compiled in any case to avoid dependencies between the
  * nfnetlink_queue code and nf_conntrack.
  */
-struct nfq_ct_hook __rcu *nfq_ct_hook __read_mostly;
-EXPORT_SYMBOL_GPL(nfq_ct_hook);
+struct nfnl_ct_hook __rcu *nfnl_ct_hook __read_mostly;
+EXPORT_SYMBOL_GPL(nfnl_ct_hook);
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 /* This does not belong here, but locally generated errors need it if connection
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index eb67bf8..704f29b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2135,7 +2135,7 @@ ctnetlink_alloc_expect(const struct nlattr *const cda[], struct nf_conn *ct,
 
 #ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 static size_t
-ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
+ctnetlink_glue_build_size(const struct nf_conn *ct)
 {
 	return 3 * nla_total_size(0) /* CTA_TUPLE_ORIG|REPL|MASTER */
 	       + 3 * nla_total_size(0) /* CTA_TUPLE_IP */
@@ -2162,8 +2162,8 @@ ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
 	       ;
 }
 
-static struct nf_conn *ctnetlink_nfqueue_get_ct(struct sk_buff *skb,
-						enum ip_conntrack_info *ctinfo)
+static struct nf_conn *ctnetlink_glue_get_ct(struct sk_buff *skb,
+					     enum ip_conntrack_info *ctinfo)
 {
 	struct nf_conn *ct;
 
@@ -2174,7 +2174,7 @@ static struct nf_conn *ctnetlink_nfqueue_get_ct(struct sk_buff *skb,
 	return ct;
 }
 
-static int __ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct)
+static int __ctnetlink_glue_build(struct sk_buff *skb, struct nf_conn *ct)
 {
 	const struct nf_conntrack_zone *zone;
 	struct nlattr *nest_parms;
@@ -2247,9 +2247,9 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct,
-			enum ip_conntrack_info ctinfo,
-			u_int16_t ct_attr, u_int16_t ct_info_attr)
+ctnetlink_glue_build(struct sk_buff *skb, struct nf_conn *ct,
+		     enum ip_conntrack_info ctinfo,
+		     u_int16_t ct_attr, u_int16_t ct_info_attr)
 {
 	struct nlattr *nest_parms;
 
@@ -2257,7 +2257,7 @@ ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct,
 	if (!nest_parms)
 		goto nla_put_failure;
 
-	if (__ctnetlink_nfqueue_build(skb, ct) < 0)
+	if (__ctnetlink_glue_build(skb, ct) < 0)
 		goto nla_put_failure;
 
 	nla_nest_end(skb, nest_parms);
@@ -2272,7 +2272,7 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_nfqueue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
+ctnetlink_glue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 {
 	int err;
 
@@ -2312,7 +2312,7 @@ ctnetlink_nfqueue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 }
 
 static int
-ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
+ctnetlink_glue_parse(const struct nlattr *attr, struct nf_conn *ct)
 {
 	struct nlattr *cda[CTA_MAX+1];
 	int ret;
@@ -2322,16 +2322,16 @@ ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 		return ret;
 
 	spin_lock_bh(&nf_conntrack_expect_lock);
-	ret = ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
+	ret = ctnetlink_glue_parse_ct((const struct nlattr **)cda, ct);
 	spin_unlock_bh(&nf_conntrack_expect_lock);
 
 	return ret;
 }
 
-static int ctnetlink_nfqueue_exp_parse(const struct nlattr * const *cda,
-				       const struct nf_conn *ct,
-				       struct nf_conntrack_tuple *tuple,
-				       struct nf_conntrack_tuple *mask)
+static int ctnetlink_glue_exp_parse(const struct nlattr * const *cda,
+				    const struct nf_conn *ct,
+				    struct nf_conntrack_tuple *tuple,
+				    struct nf_conntrack_tuple *mask)
 {
 	int err;
 
@@ -2345,8 +2345,8 @@ static int ctnetlink_nfqueue_exp_parse(const struct nlattr * const *cda,
 }
 
 static int
-ctnetlink_nfqueue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
-				u32 portid, u32 report)
+ctnetlink_glue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
+			     u32 portid, u32 report)
 {
 	struct nlattr *cda[CTA_EXPECT_MAX+1];
 	struct nf_conntrack_tuple tuple, mask;
@@ -2358,8 +2358,8 @@ ctnetlink_nfqueue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
 	if (err < 0)
 		return err;
 
-	err = ctnetlink_nfqueue_exp_parse((const struct nlattr * const *)cda,
-					  ct, &tuple, &mask);
+	err = ctnetlink_glue_exp_parse((const struct nlattr * const *)cda,
+				       ct, &tuple, &mask);
 	if (err < 0)
 		return err;
 
@@ -2386,8 +2386,8 @@ ctnetlink_nfqueue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
 	return 0;
 }
 
-static void ctnetlink_nfqueue_seqadj(struct sk_buff *skb, struct nf_conn *ct,
-				     enum ip_conntrack_info ctinfo, int diff)
+static void ctnetlink_glue_seqadj(struct sk_buff *skb, struct nf_conn *ct,
+				  enum ip_conntrack_info ctinfo, int diff)
 {
 	if (!(ct->status & IPS_NAT_MASK))
 		return;
@@ -2395,13 +2395,13 @@ static void ctnetlink_nfqueue_seqadj(struct sk_buff *skb, struct nf_conn *ct,
 	nf_ct_tcp_seqadj_set(skb, ct, ctinfo, diff);
 }
 
-static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
-	.get_ct		= ctnetlink_nfqueue_get_ct,
-	.build_size	= ctnetlink_nfqueue_build_size,
-	.build		= ctnetlink_nfqueue_build,
-	.parse		= ctnetlink_nfqueue_parse,
-	.attach_expect	= ctnetlink_nfqueue_attach_expect,
-	.seq_adjust	= ctnetlink_nfqueue_seqadj,
+static struct nfnl_ct_hook ctnetlink_glue_hook = {
+	.get_ct		= ctnetlink_glue_get_ct,
+	.build_size	= ctnetlink_glue_build_size,
+	.build		= ctnetlink_glue_build,
+	.parse		= ctnetlink_glue_parse,
+	.attach_expect	= ctnetlink_glue_attach_expect,
+	.seq_adjust	= ctnetlink_glue_seqadj,
 };
 #endif /* CONFIG_NETFILTER_NETLINK_QUEUE_CT */
 
@@ -3389,7 +3389,7 @@ static int __init ctnetlink_init(void)
 	}
 #ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 	/* setup interaction between nf_queue and nf_conntrack_netlink. */
-	RCU_INIT_POINTER(nfq_ct_hook, &ctnetlink_nfqueue_hook);
+	RCU_INIT_POINTER(nfnl_ct_hook, &ctnetlink_glue_hook);
 #endif
 	return 0;
 
@@ -3409,7 +3409,7 @@ static void __exit ctnetlink_exit(void)
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
 #ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
-	RCU_INIT_POINTER(nfq_ct_hook, NULL);
+	RCU_INIT_POINTER(nfnl_ct_hook, NULL);
 #endif
 }
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 0d2e856..a659e57 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -313,7 +313,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	struct net_device *outdev;
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfq_ct_hook *nfq_ct;
+	struct nfnl_ct_hook *nfnl_ct;
 	bool csum_verify;
 	char *secdata = NULL;
 	u32 seclen = 0;
@@ -366,11 +366,11 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	}
 
 	if (queue->flags & NFQA_CFG_F_CONNTRACK) {
-		nfq_ct = rcu_dereference(nfq_ct_hook);
-		if (nfq_ct != NULL) {
-			ct = nfq_ct->get_ct(entskb, &ctinfo);
+		nfnl_ct = rcu_dereference(nfnl_ct_hook);
+		if (nfnl_ct != NULL) {
+			ct = nfnl_ct->get_ct(entskb, &ctinfo);
 			if (ct != NULL)
-				size += nfq_ct->build_size(ct);
+				size += nfnl_ct->build_size(ct);
 		}
 	}
 
@@ -516,7 +516,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	if (seclen && nla_put(skb, NFQA_SECCTX, seclen, secdata))
 		goto nla_put_failure;
 
-	if (ct && nfq_ct->build(skb, ct, ctinfo, NFQA_CT, NFQA_CT_INFO) < 0)
+	if (ct && nfnl_ct->build(skb, ct, ctinfo, NFQA_CT, NFQA_CT_INFO) < 0)
 		goto nla_put_failure;
 
 	if (cap_len > data_len &&
@@ -1009,7 +1009,7 @@ nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
 	return 0;
 }
 
-static struct nf_conn *nfqnl_ct_parse(struct nfq_ct_hook *nfq_ct,
+static struct nf_conn *nfqnl_ct_parse(struct nfnl_ct_hook *nfnl_ct,
 				      const struct nlmsghdr *nlh,
 				      const struct nlattr * const nfqa[],
 				      struct nf_queue_entry *entry,
@@ -1017,15 +1017,15 @@ static struct nf_conn *nfqnl_ct_parse(struct nfq_ct_hook *nfq_ct,
 {
 	struct nf_conn *ct;
 
-	ct = nfq_ct->get_ct(entry->skb, ctinfo);
+	ct = nfnl_ct->get_ct(entry->skb, ctinfo);
 	if (ct == NULL)
 		return NULL;
 
-	if (nfq_ct->parse(nfqa[NFQA_CT], ct) < 0)
+	if (nfnl_ct->parse(nfqa[NFQA_CT], ct) < 0)
 		return NULL;
 
 	if (nfqa[NFQA_EXP])
-		nfq_ct->attach_expect(nfqa[NFQA_EXP], ct,
+		nfnl_ct->attach_expect(nfqa[NFQA_EXP], ct,
 				      NETLINK_CB(entry->skb).portid,
 				      nlmsg_report(nlh));
 	return ct;
@@ -1044,7 +1044,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfq_ct_hook *nfq_ct;
+	struct nfnl_ct_hook *nfnl_ct;
 	struct nf_conn *ct = NULL;
 
 	struct net *net = sock_net(ctnl);
@@ -1069,9 +1069,9 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 
 	if (nfqa[NFQA_CT]) {
 		/* rcu lock already held from nfnl->call_rcu. */
-		nfq_ct = rcu_dereference(nfq_ct_hook);
-		if (nfq_ct != NULL)
-			ct = nfqnl_ct_parse(nfq_ct, nlh, nfqa, entry, &ctinfo);
+		nfnl_ct = rcu_dereference(nfnl_ct_hook);
+		if (nfnl_ct != NULL)
+			ct = nfqnl_ct_parse(nfnl_ct, nlh, nfqa, entry, &ctinfo);
 	}
 
 	if (nfqa[NFQA_PAYLOAD]) {
@@ -1083,7 +1083,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 			verdict = NF_DROP;
 
 		if (ct && diff)
-			nfq_ct->seq_adjust(entry->skb, ct, ctinfo, diff);
+			nfnl_ct->seq_adjust(entry->skb, ct, ctinfo, diff);
 	}
 
 	if (nfqa[NFQA_MARK])
-- 
2.1.4

