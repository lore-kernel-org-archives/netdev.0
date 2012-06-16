From: pablo@netfilter.org
Subject: [PATCH 4/7] netfilter: add glue code to integrate nfnetlink_queue and ctnetlink
Date: Sat, 16 Jun 2012 17:49:53 +0200
Message-ID: <1339861796-2676-5-git-send-email-pablo@netfilter.org>
References: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33053 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab2FPPvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 11:51:38 -0400
In-Reply-To: <1339861796-2676-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows you to include the conntrack information together
with the packet that is sent to user-space via NFQUEUE.

Previously, there was no integration between ctnetlink and
nfnetlink_queue. If you wanted to access conntrack information
from your libnetfilter_queue program, you required to query
ctnetlink from user-space to obtain it. Thus, delaying the packet
processing even more.

Including the conntrack information is optional, you can set it
via NFQA_CFG_F_CONNTRACK flag with the new NFQA_CFG_FLAGS attribute.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h                 |   10 ++
 include/linux/netfilter/nfnetlink_queue.h |    3 +
 net/netfilter/core.c                      |    4 +
 net/netfilter/nf_conntrack_netlink.c      |  144 ++++++++++++++++++++++++++++-
 net/netfilter/nfnetlink_queue.c           |   48 ++++++++++
 5 files changed, 208 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 4541f33..ba65bfb 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -393,6 +393,16 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 extern void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *) __rcu;
 extern void nf_ct_attach(struct sk_buff *, struct sk_buff *);
 extern void (*nf_ct_destroy)(struct nf_conntrack *) __rcu;
+
+struct nf_conn;
+struct nlattr;
+
+struct nfq_ct_hook {
+	size_t (*build_size)(const struct nf_conn *ct);
+	int (*build)(struct sk_buff *skb, struct nf_conn *ct);
+	int (*parse)(const struct nlattr *attr, struct nf_conn *ct);
+};
+extern struct nfq_ct_hook *nfq_ct_hook;
 #else
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netfilter/nfnetlink_queue.h
index a6c1dda..e0d8fd8 100644
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -42,6 +42,8 @@ enum nfqnl_attr_type {
 	NFQA_IFINDEX_PHYSOUTDEV,	/* __u32 ifindex */
 	NFQA_HWADDR,			/* nfqnl_msg_packet_hw */
 	NFQA_PAYLOAD,			/* opaque data payload */
+	NFQA_CT,			/* nf_conntrack_netlink.h */
+	NFQA_CT_INFO,			/* enum ip_conntrack_info */
 
 	__NFQA_MAX
 };
@@ -92,5 +94,6 @@ enum nfqnl_attr_config {
 
 /* Flags for NFQA_CFG_FLAGS */
 #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
+#define NFQA_CFG_F_CONNTRACK			(1 << 1)
 
 #endif /* _NFNETLINK_QUEUE_H */
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e19f365..7eef845 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -264,6 +264,10 @@ void nf_conntrack_destroy(struct nf_conntrack *nfct)
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL(nf_conntrack_destroy);
+
+struct nfq_ct_hook *nfq_ct_hook;
+EXPORT_SYMBOL_GPL(nfq_ct_hook);
+
 #endif /* CONFIG_NF_CONNTRACK */
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a088920..d304d59 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1620,6 +1620,140 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
+#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
+    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+static size_t
+ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
+{
+	return 3 * nla_total_size(0) /* CTA_TUPLE_ORIG|REPL|MASTER */
+	       + 3 * nla_total_size(0) /* CTA_TUPLE_IP */
+	       + 3 * nla_total_size(0) /* CTA_TUPLE_PROTO */
+	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
+	       + nla_total_size(0) /* CTA_PROTOINFO */
+	       + nla_total_size(0) /* CTA_HELP */
+	       + nla_total_size(NF_CT_HELPER_NAME_LEN) /* CTA_HELP_NAME */
+	       + ctnetlink_secctx_size(ct)
+#ifdef CONFIG_NF_NAT_NEEDED
+	       + 2 * nla_total_size(0) /* CTA_NAT_SEQ_ADJ_ORIG|REPL */
+	       + 6 * nla_total_size(sizeof(u_int32_t)) /* CTA_NAT_SEQ_OFFSET */
+#endif
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	       + nla_total_size(sizeof(u_int32_t)) /* CTA_MARK */
+#endif
+	       + ctnetlink_proto_size(ct)
+	       ;
+}
+
+static int
+ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct)
+{
+	struct nlattr *nest_parms;
+
+	rcu_read_lock();
+	nest_parms = nla_nest_start(skb, CTA_TUPLE_ORIG | NLA_F_NESTED);
+	if (!nest_parms)
+		goto nla_put_failure;
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_ORIGINAL)) < 0)
+		goto nla_put_failure;
+	nla_nest_end(skb, nest_parms);
+
+	nest_parms = nla_nest_start(skb, CTA_TUPLE_REPLY | NLA_F_NESTED);
+	if (!nest_parms)
+		goto nla_put_failure;
+	if (ctnetlink_dump_tuples(skb, nf_ct_tuple(ct, IP_CT_DIR_REPLY)) < 0)
+		goto nla_put_failure;
+	nla_nest_end(skb, nest_parms);
+
+	if (nf_ct_zone(ct)) {
+		if (nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
+			goto nla_put_failure;
+	}
+
+	if (ctnetlink_dump_id(skb, ct) < 0)
+		goto nla_put_failure;
+
+	if (ctnetlink_dump_status(skb, ct) < 0)
+		goto nla_put_failure;
+
+	if (ctnetlink_dump_timeout(skb, ct) < 0)
+		goto nla_put_failure;
+
+	if (ctnetlink_dump_protoinfo(skb, ct) < 0)
+		goto nla_put_failure;
+
+	if (ctnetlink_dump_helpinfo(skb, ct) < 0)
+		goto nla_put_failure;
+
+#ifdef CONFIG_NF_CONNTRACK_SECMARK
+	if (ct->secmark && ctnetlink_dump_secctx(skb, ct) < 0)
+		goto nla_put_failure;
+#endif
+	if (ct->master && ctnetlink_dump_master(skb, ct) < 0)
+		goto nla_put_failure;
+
+	if ((ct->status & IPS_SEQ_ADJUST) &&
+	    ctnetlink_dump_nat_seq_adj(skb, ct) < 0)
+		goto nla_put_failure;
+
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	if (ct->mark && ctnetlink_dump_mark(skb, ct) < 0)
+		goto nla_put_failure;
+#endif
+	rcu_read_unlock();
+	return 0;
+
+nla_put_failure:
+	rcu_read_unlock();
+	return -ENOSPC;
+}
+
+static int
+ctnetlink_nfqueue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
+{
+	int err;
+
+	if (cda[CTA_TIMEOUT]) {
+		err = ctnetlink_change_timeout(ct, cda);
+		if (err < 0)
+			return err;
+	}
+	if (cda[CTA_STATUS]) {
+		err = ctnetlink_change_status(ct, cda);
+		if (err < 0)
+			return err;
+	}
+	if (cda[CTA_HELP]) {
+		err = ctnetlink_change_helper(ct, cda);
+		if (err < 0)
+			return err;
+	}
+#if defined(CONFIG_NF_CONNTRACK_MARK)
+	if (cda[CTA_MARK])
+		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
+#endif
+	return 0;
+}
+
+static int
+ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
+{
+	struct nlattr *cda[CTA_MAX+1];
+
+	nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
+
+	return ctnetlink_nfqueue_parse_ct((const struct nlattr **)cda, ct);
+}
+
+static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
+	.build_size	= ctnetlink_nfqueue_build_size,
+	.build		= ctnetlink_nfqueue_build,
+	.parse		= ctnetlink_nfqueue_parse,
+};
+#endif /* CONFIG_NETFILTER_NETLINK_QUEUE */
+
 /***********************************************************************
  * EXPECT
  ***********************************************************************/
@@ -2424,7 +2558,11 @@ static int __init ctnetlink_init(void)
 		pr_err("ctnetlink_init: cannot register pernet operations\n");
 		goto err_unreg_exp_subsys;
 	}
-
+#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
+    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+	/* setup interaction between nf_queue and nf_conntrack_netlink. */
+	RCU_INIT_POINTER(nfq_ct_hook, &ctnetlink_nfqueue_hook);
+#endif
 	return 0;
 
 err_unreg_exp_subsys:
@@ -2442,6 +2580,10 @@ static void __exit ctnetlink_exit(void)
 	unregister_pernet_subsys(&ctnetlink_net_ops);
 	nfnetlink_subsys_unregister(&ctnl_exp_subsys);
 	nfnetlink_subsys_unregister(&ctnl_subsys);
+#if defined(CONFIG_NETFILTER_NETLINK_QUEUE) ||	\
+    defined(CONFIG_NETFILTER_NETLINK_QUEUE_MODULE)
+	RCU_INIT_POINTER(nfq_ct_hook, NULL);
+#endif
 }
 
 module_init(ctnetlink_init);
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 630da3d..647923a 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -30,6 +30,7 @@
 #include <linux/list.h>
 #include <net/sock.h>
 #include <net/netfilter/nf_queue.h>
+#include <net/netfilter/nf_conntrack.h>
 
 #include <linux/atomic.h>
 
@@ -233,6 +234,9 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	struct sk_buff *entskb = entry->skb;
 	struct net_device *indev;
 	struct net_device *outdev;
+	struct nfq_ct_hook *nfq_ct;
+	struct nf_conn *ct = NULL;
+	enum ip_conntrack_info uninitialized_var(ctinfo);
 
 	size =    NLMSG_SPACE(sizeof(struct nfgenmsg))
 		+ nla_total_size(sizeof(struct nfqnl_msg_packet_hdr))
@@ -266,6 +270,17 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		break;
 	}
 
+	/* rcu_read_lock()ed by __nf_queue already. */
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct != NULL && (queue->flags & NFQA_CFG_F_CONNTRACK)) {
+		ct = nf_ct_get(entskb, &ctinfo);
+		if (ct) {
+			if (!nf_ct_is_untracked(ct))
+				size += nfq_ct->build_size(ct);
+			else
+				ct = NULL;
+		}
+	}
 
 	skb = alloc_skb(size, GFP_ATOMIC);
 	if (!skb)
@@ -389,6 +404,24 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 			BUG();
 	}
 
+	if (ct) {
+		struct nlattr *nest_parms;
+		u_int32_t tmp;
+
+		nest_parms = nla_nest_start(skb, NFQA_CT | NLA_F_NESTED);
+		if (!nest_parms)
+			goto nla_put_failure;
+
+		if (nfq_ct->build(skb, ct) < 0)
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest_parms);
+
+		tmp = ctinfo;
+		if (nla_put_u32(skb, NFQA_CT_INFO, htonl(ctinfo)))
+			goto nla_put_failure;
+	}
+
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
 
@@ -632,6 +665,7 @@ static const struct nla_policy nfqa_verdict_policy[NFQA_MAX+1] = {
 	[NFQA_VERDICT_HDR]	= { .len = sizeof(struct nfqnl_msg_verdict_hdr) },
 	[NFQA_MARK]		= { .type = NLA_U32 },
 	[NFQA_PAYLOAD]		= { .type = NLA_UNSPEC },
+	[NFQA_CT]		= { .type = NLA_UNSPEC },
 };
 
 static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
@@ -732,6 +766,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	struct nfqnl_instance *queue;
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
+	struct nfq_ct_hook *nfq_ct;
 
 	queue = instance_lookup(queue_num);
 	if (!queue)
@@ -750,6 +785,19 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	if (entry == NULL)
 		return -ENOENT;
 
+	rcu_read_lock();
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct != NULL &&
+	    (queue->flags & NFQA_CFG_F_CONNTRACK) && nfqa[NFQA_CT]) {
+		enum ip_conntrack_info ctinfo;
+		struct nf_conn *ct;
+
+		ct = nf_ct_get(entry->skb, &ctinfo);
+		if (ct && !nf_ct_is_untracked(ct))
+			nfq_ct->parse(nfqa[NFQA_CT], ct);
+	}
+	rcu_read_unlock();
+
 	if (nfqa[NFQA_PAYLOAD]) {
 		if (nfqnl_mangle(nla_data(nfqa[NFQA_PAYLOAD]),
 				 nla_len(nfqa[NFQA_PAYLOAD]), entry) < 0)
-- 
1.7.10
