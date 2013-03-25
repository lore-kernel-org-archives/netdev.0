From: pablo@netfilter.org
Subject: [PATCH 09/12] netfilter: ctnetlink: allow to dump expectation per master conntrack
Date: Mon, 25 Mar 2013 13:15:49 +0100
Message-ID: <1364213752-3934-10-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the ability to dump all existing expectations
per master conntrack.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |  100 ++++++++++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9904b15..6d0f8a1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2409,6 +2409,92 @@ out:
 	return skb->len;
 }
 
+static int
+ctnetlink_exp_ct_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct nf_conntrack_expect *exp, *last;
+	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
+	struct nf_conn *ct = cb->data;
+	struct nf_conn_help *help = nfct_help(ct);
+	u_int8_t l3proto = nfmsg->nfgen_family;
+
+	if (cb->args[0])
+		return 0;
+
+	rcu_read_lock();
+	last = (struct nf_conntrack_expect *)cb->args[1];
+restart:
+	hlist_for_each_entry(exp, &help->expectations, lnode) {
+		if (l3proto && exp->tuple.src.l3num != l3proto)
+			continue;
+		if (cb->args[1]) {
+			if (exp != last)
+				continue;
+			cb->args[1] = 0;
+		}
+		if (ctnetlink_exp_fill_info(skb, NETLINK_CB(cb->skb).portid,
+					    cb->nlh->nlmsg_seq,
+					    IPCTNL_MSG_EXP_NEW,
+					    exp) < 0) {
+			if (!atomic_inc_not_zero(&exp->use))
+				continue;
+			cb->args[1] = (unsigned long)exp;
+			goto out;
+		}
+	}
+	if (cb->args[1]) {
+		cb->args[1] = 0;
+		goto restart;
+	}
+	cb->args[0] = 1;
+out:
+	rcu_read_unlock();
+	if (last)
+		nf_ct_expect_put(last);
+
+	return skb->len;
+}
+
+static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
+				 const struct nlmsghdr *nlh,
+				 const struct nlattr * const cda[])
+{
+	int err;
+	struct net *net = sock_net(ctnl);
+	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
+	u_int8_t u3 = nfmsg->nfgen_family;
+	struct nf_conntrack_tuple tuple;
+	struct nf_conntrack_tuple_hash *h;
+	struct nf_conn *ct;
+	u16 zone = 0;
+	struct netlink_dump_control c = {
+		.dump = ctnetlink_exp_ct_dump_table,
+		.done = ctnetlink_exp_done,
+	};
+
+	err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_MASTER, u3);
+	if (err < 0)
+		return err;
+
+	if (cda[CTA_EXPECT_ZONE]) {
+		err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
+		if (err < 0)
+			return err;
+	}
+
+	h = nf_conntrack_find_get(net, zone, &tuple);
+	if (!h)
+		return -ENOENT;
+
+	ct = nf_ct_tuplehash_to_ctrack(h);
+	c.data = ct;
+
+	err = netlink_dump_start(ctnl, skb, nlh, &c);
+	nf_ct_put(ct);
+
+	return err;
+}
+
 static const struct nla_policy exp_nla_policy[CTA_EXPECT_MAX+1] = {
 	[CTA_EXPECT_MASTER]	= { .type = NLA_NESTED },
 	[CTA_EXPECT_TUPLE]	= { .type = NLA_NESTED },
@@ -2439,11 +2525,15 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
-		struct netlink_dump_control c = {
-			.dump = ctnetlink_exp_dump_table,
-			.done = ctnetlink_exp_done,
-		};
-		return netlink_dump_start(ctnl, skb, nlh, &c);
+		if (cda[CTA_EXPECT_MASTER])
+			return ctnetlink_dump_exp_ct(ctnl, skb, nlh, cda);
+		else {
+			struct netlink_dump_control c = {
+				.dump = ctnetlink_exp_dump_table,
+				.done = ctnetlink_exp_done,
+			};
+			return netlink_dump_start(ctnl, skb, nlh, &c);
+		}
 	}
 
 	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
-- 
1.7.10.4

