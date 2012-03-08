From: pablo@netfilter.org
Subject: [PATCH 08/23] netfilter: ctnetlink: add NAT support for expectations
Date: Thu,  8 Mar 2012 02:00:57 +0100
Message-ID: <1331168472-5820-9-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the missing bits to create expectations that
are created in NAT setups.
---
 include/linux/netfilter/nfnetlink_conntrack.h |    9 +++
 net/netfilter/nf_conntrack_netlink.c          |   68 ++++++++++++++++++++++++-
 2 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 557a0cf..a2f1f48 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -174,10 +174,19 @@ enum ctattr_expect {
 	CTA_EXPECT_ZONE,
 	CTA_EXPECT_FLAGS,
 	CTA_EXPECT_CLASS,
+	CTA_EXPECT_NAT,
 	__CTA_EXPECT_MAX
 };
 #define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
 
+enum ctattr_expect_nat {
+	CTA_EXPECT_NAT_UNSPEC,
+	CTA_EXPECT_NAT_DIR,
+	CTA_EXPECT_NAT_TUPLE,
+	__CTA_EXPECT_NAT_MAX
+};
+#define CTA_EXPECT_NAT_MAX (__CTA_EXPECT_NAT_MAX - 1)
+
 enum ctattr_help {
 	CTA_HELP_UNSPEC,
 	CTA_HELP_NAME,
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b6ea397..845c8ca 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1675,7 +1675,10 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 	struct nf_conn *master = exp->master;
 	long timeout = ((long)exp->timeout.expires - (long)jiffies) / HZ;
 	struct nf_conn_help *help;
-
+#ifdef CONFIG_NF_NAT_NEEDED
+	struct nlattr *nest_parms;
+	struct nf_conntrack_tuple nat_tuple = {};
+#endif
 	if (timeout < 0)
 		timeout = 0;
 
@@ -1688,6 +1691,25 @@ ctnetlink_exp_dump_expect(struct sk_buff *skb,
 				 CTA_EXPECT_MASTER) < 0)
 		goto nla_put_failure;
 
+#ifdef CONFIG_NF_NAT_NEEDED
+	if (exp->saved_ip || exp->saved_proto.all) {
+		nest_parms = nla_nest_start(skb, CTA_EXPECT_NAT | NLA_F_NESTED);
+		if (!nest_parms)
+			goto nla_put_failure;
+
+		NLA_PUT_BE32(skb, CTA_EXPECT_NAT_DIR, htonl(exp->dir));
+
+		nat_tuple.src.l3num = nf_ct_l3num(master);
+		nat_tuple.src.u3.ip = exp->saved_ip;
+		nat_tuple.dst.protonum = nf_ct_protonum(master);
+		nat_tuple.src.u = exp->saved_proto;
+
+		if (ctnetlink_exp_dump_tuple(skb, &nat_tuple,
+						CTA_EXPECT_NAT_TUPLE) < 0)
+	                goto nla_put_failure;
+	        nla_nest_end(skb, nest_parms);
+	}
+#endif
 	NLA_PUT_BE32(skb, CTA_EXPECT_TIMEOUT, htonl(timeout));
 	NLA_PUT_BE32(skb, CTA_EXPECT_ID, htonl((unsigned long)exp));
 	NLA_PUT_BE32(skb, CTA_EXPECT_FLAGS, htonl(exp->flags));
@@ -1858,6 +1880,7 @@ static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_ZONE]	= { .type = NLA_U16 },
 	[CTA_EXPECT_FLAGS]	= { .type = NLA_U32 },
 	[CTA_EXPECT_CLASS]	= { .type = NLA_U32 },
+	[CTA_EXPECT_NAT]	= { .type = NLA_NESTED },
 };
 
 static int
@@ -2033,6 +2056,41 @@ ctnetlink_change_expect(struct nf_conntrack_expect *x,
 	return -EOPNOTSUPP;
 }
 
+static const struct nla_policy exp_nat_nla_policy[CTA_EXPECT_NAT_MAX+1] = {
+	[CTA_EXPECT_NAT_DIR]	= { .type = NLA_U32 },
+	[CTA_EXPECT_NAT_TUPLE]	= { .type = NLA_NESTED },
+};
+
+static int
+ctnetlink_parse_expect_nat(const struct nlattr *attr,
+			   struct nf_conntrack_expect *exp,
+			   u_int8_t u3)
+{
+#ifdef CONFIG_NF_NAT_NEEDED
+	struct nlattr *tb[CTA_EXPECT_NAT_MAX+1];
+	struct nf_conntrack_tuple nat_tuple = {};
+	int err;
+
+	nla_parse_nested(tb, CTA_EXPECT_NAT_MAX, attr, exp_nat_nla_policy);
+
+	if (!tb[CTA_EXPECT_NAT_DIR] || !tb[CTA_EXPECT_NAT_TUPLE])
+		return -EINVAL;
+
+	err = ctnetlink_parse_tuple((const struct nlattr * const *)tb,
+					&nat_tuple, CTA_EXPECT_NAT_TUPLE, u3);
+	if (err < 0)
+		return err;
+
+	exp->saved_ip = nat_tuple.src.u3.ip;
+	exp->saved_proto = nat_tuple.src.u;
+	exp->dir = ntohl(nla_get_be32(tb[CTA_EXPECT_NAT_DIR]));
+
+	return 0;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
 static int
 ctnetlink_create_expect(struct net *net, u16 zone,
 			const struct nlattr * const cda[],
@@ -2133,9 +2191,15 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	memcpy(&exp->mask.src.u3, &mask.src.u3, sizeof(exp->mask.src.u3));
 	exp->mask.src.u.all = mask.src.u.all;
 
+	if (cda[CTA_EXPECT_NAT]) {
+		err = ctnetlink_parse_expect_nat(cda[CTA_EXPECT_NAT],
+						 exp, u3);
+		if (err < 0)
+			goto err_out;
+	}
 	err = nf_ct_expect_related_report(exp, pid, report);
+err_out:
 	nf_ct_expect_put(exp);
-
 out:
 	nf_ct_put(nf_ct_tuplehash_to_ctrack(h));
 	return err;
-- 
1.7.7.3

