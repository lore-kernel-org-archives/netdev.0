From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/19] netfilter: nfnetlink_queue: allow to attach expectations to conntracks
Date: Tue, 20 Aug 2013 12:54:49 +0200
Message-ID: <1376996091-3964-18-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the capability to attach expectations via nfnetlink_queue.
This is required by conntrack helpers that trigger expectations based on
the first packet seen like the TFTP and the DHCPv6 user-space helpers.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h                      |    2 +
 include/net/netfilter/nfnetlink_queue.h        |    8 ++
 include/uapi/linux/netfilter/nfnetlink_queue.h |    1 +
 net/netfilter/nf_conntrack_netlink.c           |   95 ++++++++++++++++++++----
 net/netfilter/nfnetlink_queue_core.c           |    9 ++-
 net/netfilter/nfnetlink_queue_ct.c             |   15 ++++
 6 files changed, 114 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 655d5d1..e2cf786be 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -325,6 +325,8 @@ struct nfq_ct_hook {
 	size_t (*build_size)(const struct nf_conn *ct);
 	int (*build)(struct sk_buff *skb, struct nf_conn *ct);
 	int (*parse)(const struct nlattr *attr, struct nf_conn *ct);
+	int (*attach_expect)(const struct nlattr *attr, struct nf_conn *ct,
+			     u32 portid, u32 report);
 };
 extern struct nfq_ct_hook __rcu *nfq_ct_hook;
 
diff --git a/include/net/netfilter/nfnetlink_queue.h b/include/net/netfilter/nfnetlink_queue.h
index 86267a5..aff88ba 100644
--- a/include/net/netfilter/nfnetlink_queue.h
+++ b/include/net/netfilter/nfnetlink_queue.h
@@ -15,6 +15,8 @@ int nfqnl_ct_put(struct sk_buff *skb, struct nf_conn *ct,
 		 enum ip_conntrack_info ctinfo);
 void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo, int diff);
+int nfqnl_attach_expect(struct nf_conn *ct, const struct nlattr *attr,
+			u32 portid, u32 report);
 #else
 inline struct nf_conn *
 nfqnl_ct_get(struct sk_buff *entskb, size_t *size, enum ip_conntrack_info *ctinfo)
@@ -39,5 +41,11 @@ inline void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo, int diff)
 {
 }
+
+inline int nfqnl_attach_expect(struct nf_conn *ct, const struct nlattr *attr,
+			       u32 portid, u32 report)
+{
+	return 0;
+}
 #endif /* NF_CONNTRACK */
 #endif
diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include/uapi/linux/netfilter/nfnetlink_queue.h
index 3a9b921..0132bad 100644
--- a/include/uapi/linux/netfilter/nfnetlink_queue.h
+++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
@@ -46,6 +46,7 @@ enum nfqnl_attr_type {
 	NFQA_CT_INFO,			/* enum ip_conntrack_info */
 	NFQA_CAP_LEN,			/* __u32 length of captured packet */
 	NFQA_SKB_INFO,			/* __u32 skb meta information */
+	NFQA_EXP,			/* nf_conntrack_netlink.h */
 
 	__NFQA_MAX
 };
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9aaa68b..fa61fea 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1987,6 +1987,27 @@ out:
 	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
+static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
+	[CTA_EXPECT_MASTER]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_TUPLE]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_MASK]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_TIMEOUT]	= { .type = NLA_U32 },
+	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
+	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING,
+				    .len = NF_CT_HELPER_NAME_LEN - 1 },
+	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
+	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
+	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
+	[CTA_EXPECT_NAT]	= { .type = NLA_NESTED },
+	[CTA_EXPECT_FN]		= { .type = NLA_NUL_STRING },
+};
+
+static struct nf_conntrack_expect *
+ctnetlink_alloc_expect(const struct nlattr *const cda[], struct nf_conn *ct,
+		       struct nf_conntrack_helper *helper,
+		       struct nf_conntrack_tuple *tuple,
+		       struct nf_conntrack_tuple *mask);
+
 #ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 static size_t
 ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
@@ -2127,10 +2148,69 @@ ctnetlink_nfqueue_parse(const struct nlattr *attr, struct nf_conn *ct)
 	return ret;
 }
 
+static int ctnetlink_nfqueue_exp_parse(const struct nlattr * const *cda,
+				       const struct nf_conn *ct,
+				       struct nf_conntrack_tuple *tuple,
+				       struct nf_conntrack_tuple *mask)
+{
+	int err;
+
+	err = ctnetlink_parse_tuple(cda, tuple, CTA_EXPECT_TUPLE,
+				    nf_ct_l3num(ct));
+	if (err < 0)
+		return err;
+
+	return ctnetlink_parse_tuple(cda, mask, CTA_EXPECT_MASK,
+				     nf_ct_l3num(ct));
+}
+
+static int
+ctnetlink_nfqueue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
+				u32 portid, u32 report)
+{
+	struct nlattr *cda[CTA_EXPECT_MAX+1];
+	struct nf_conntrack_tuple tuple, mask;
+	struct nf_conntrack_helper *helper;
+	struct nf_conntrack_expect *exp;
+	int err;
+
+	err = nla_parse_nested(cda, CTA_EXPECT_MAX, attr, exp_nla_policy);
+	if (err < 0)
+		return err;
+
+	err = ctnetlink_nfqueue_exp_parse((const struct nlattr * const *)cda,
+					  ct, &tuple, &mask);
+	if (err < 0)
+		return err;
+
+	if (cda[CTA_EXPECT_HELP_NAME]) {
+		const char *helpname = nla_data(cda[CTA_EXPECT_HELP_NAME]);
+
+		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
+						    nf_ct_protonum(ct));
+		if (helper == NULL)
+			return -EOPNOTSUPP;
+	}
+
+	exp = ctnetlink_alloc_expect((const struct nlattr * const *)cda, ct,
+				     helper, &tuple, &mask);
+	if (IS_ERR(exp))
+		return PTR_ERR(exp);
+
+	err = nf_ct_expect_related_report(exp, portid, report);
+	if (err < 0) {
+		nf_ct_expect_put(exp);
+		return err;
+	}
+
+	return 0;
+}
+
 static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
 	.build_size	= ctnetlink_nfqueue_build_size,
 	.build		= ctnetlink_nfqueue_build,
 	.parse		= ctnetlink_nfqueue_parse,
+	.attach_expect	= ctnetlink_nfqueue_attach_expect,
 };
 #endif /* CONFIG_NETFILTER_NETLINK_QUEUE_CT */
 
@@ -2498,21 +2578,6 @@ static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
-static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
-	[CTA_EXPECT_MASTER]	= { .type = NLA_NESTED },
-	[CTA_EXPECT_TUPLE]	= { .type = NLA_NESTED },
-	[CTA_EXPECT_MASK]	= { .type = NLA_NESTED },
-	[CTA_EXPECT_TIMEOUT]	= { .type = NLA_U32 },
-	[CTA_EXPECT_ID]		= { .type = NLA_U32 },
-	[CTA_EXPECT_HELP_NAME]	= { .type = NLA_NUL_STRING,
-				    .len = NF_CT_HELPER_NAME_LEN - 1 },
-	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
-	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
-	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
-	[CTA_EXPECT_NAT]	= { .type = NLA_NESTED },
-	[CTA_EXPECT_FN]		= { .type = NLA_NUL_STRING },
-};
-
 static int
 ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index ec9de12..e8c9f3b 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -859,6 +859,7 @@ static const struct nla_policy nfqa_verdict_policy[NFQA_MAX+1] = {
 	[NFQA_MARK]		= { .type = NLA_U32 },
 	[NFQA_PAYLOAD]		= { .type = NLA_UNSPEC },
 	[NFQA_CT]		= { .type = NLA_UNSPEC },
+	[NFQA_EXP]		= { .type = NLA_UNSPEC },
 };
 
 static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
@@ -987,8 +988,14 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	if (entry == NULL)
 		return -ENOENT;
 
-	if (nfqa[NFQA_CT])
+	if (nfqa[NFQA_CT]) {
 		ct = nfqnl_ct_parse(entry->skb, nfqa[NFQA_CT], &ctinfo);
+		if (ct && nfqa[NFQA_EXP]) {
+			nfqnl_attach_expect(ct, nfqa[NFQA_EXP],
+					    NETLINK_CB(skb).portid,
+					    nlmsg_report(nlh));
+		}
+	}
 
 	if (nfqa[NFQA_PAYLOAD]) {
 		u16 payload_len = nla_len(nfqa[NFQA_PAYLOAD]);
diff --git a/net/netfilter/nfnetlink_queue_ct.c b/net/netfilter/nfnetlink_queue_ct.c
index ab61d66..be89303 100644
--- a/net/netfilter/nfnetlink_queue_ct.c
+++ b/net/netfilter/nfnetlink_queue_ct.c
@@ -96,3 +96,18 @@ void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
 	if ((ct->status & IPS_NAT_MASK) && diff)
 		nfq_nat_ct->seq_adjust(skb, ct, ctinfo, diff);
 }
+
+int nfqnl_attach_expect(struct nf_conn *ct, const struct nlattr *attr,
+			u32 portid, u32 report)
+{
+	struct nfq_ct_hook *nfq_ct;
+
+	if (nf_ct_is_untracked(ct))
+		return 0;
+
+	nfq_ct = rcu_dereference(nfq_ct_hook);
+	if (nfq_ct == NULL)
+		return -EOPNOTSUPP;
+
+	return nfq_ct->attach_expect(attr, ct, portid, report);
+}
-- 
1.7.10.4

