From: pablo@netfilter.org
Subject: [PATCH 3/6] netfilter: ctnetlink: dump entries from the dying and unconfirmed lists
Date: Tue,  4 Dec 2012 18:31:30 +0100
Message-ID: <1354642293-4114-4-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54446 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754229Ab2LDRb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:56 -0500
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds a new operation to dump the content of the dying and
unconfirmed lists.

Under some situations, the global conntrack counter can be inconsistent
with the number of entries that we can dump from the conntrack table.
The way to resolve this is to allow dumping the content of the unconfirmed
and dying lists, so far it was not possible to look at its content.

This provides some extra instrumentation to resolve problematic situations
in which anyone suspects memory leaks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    2 +
 net/netfilter/nf_conntrack_netlink.c               |  108 ++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index 43bfe3e..86e930c 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -9,6 +9,8 @@ enum cntl_msg_types {
 	IPCTNL_MSG_CT_GET_CTRZERO,
 	IPCTNL_MSG_CT_GET_STATS_CPU,
 	IPCTNL_MSG_CT_GET_STATS,
+	IPCTNL_MSG_CT_GET_DYING,
+	IPCTNL_MSG_CT_GET_UNCONFIRMED,
 
 	IPCTNL_MSG_MAX
 };
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 34370a9..c24a00a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1089,6 +1089,112 @@ out:
 	return err == -EAGAIN ? -ENOBUFS : err;
 }
 
+static int ctnetlink_done_list(struct netlink_callback *cb)
+{
+	if (cb->args[1])
+		nf_ct_put((struct nf_conn *)cb->args[1]);
+	return 0;
+}
+
+static int
+ctnetlink_dump_list(struct sk_buff *skb, struct netlink_callback *cb,
+		    struct hlist_nulls_head *list)
+{
+	struct nf_conn *ct, *last;
+	struct nf_conntrack_tuple_hash *h;
+	struct hlist_nulls_node *n;
+	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
+	u_int8_t l3proto = nfmsg->nfgen_family;
+	int res;
+
+	if (cb->args[2])
+		return 0;
+
+	spin_lock_bh(&nf_conntrack_lock);
+	last = (struct nf_conn *)cb->args[1];
+restart:
+	hlist_nulls_for_each_entry(h, n, list, hnnode) {
+		ct = nf_ct_tuplehash_to_ctrack(h);
+		if (l3proto && nf_ct_l3num(ct) != l3proto)
+			continue;
+		if (cb->args[1]) {
+			if (ct != last)
+				continue;
+			cb->args[1] = 0;
+		}
+		rcu_read_lock();
+		res = ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).portid,
+					  cb->nlh->nlmsg_seq,
+					  NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
+					  ct);
+		rcu_read_unlock();
+		if (res < 0) {
+			nf_conntrack_get(&ct->ct_general);
+			cb->args[1] = (unsigned long)ct;
+			goto out;
+		}
+	}
+	if (cb->args[1]) {
+		cb->args[1] = 0;
+		goto restart;
+	} else
+		cb->args[2] = 1;
+out:
+	spin_unlock_bh(&nf_conntrack_lock);
+	if (last)
+		nf_ct_put(last);
+
+	return skb->len;
+}
+
+static int
+ctnetlink_dump_dying(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+
+	return ctnetlink_dump_list(skb, cb, &net->ct.dying);
+}
+
+static int
+ctnetlink_get_ct_dying(struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const cda[])
+{
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_dump_dying,
+			.done = ctnetlink_done_list,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int
+ctnetlink_dump_unconfirmed(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+
+	return ctnetlink_dump_list(skb, cb, &net->ct.unconfirmed);
+}
+
+static int
+ctnetlink_get_ct_unconfirmed(struct sock *ctnl, struct sk_buff *skb,
+			     const struct nlmsghdr *nlh,
+			     const struct nlattr * const cda[])
+{
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_dump_unconfirmed,
+			.done = ctnetlink_done_list,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
+
+	return -EOPNOTSUPP;
+}
+
 #ifdef CONFIG_NF_NAT_NEEDED
 static int
 ctnetlink_parse_nat_setup(struct nf_conn *ct,
@@ -2712,6 +2818,8 @@ static const struct nfnl_callback ctnl_cb[IPCTNL_MSG_MAX] = {
 					    .policy = ct_nla_policy },
 	[IPCTNL_MSG_CT_GET_STATS_CPU]	= { .call = ctnetlink_stat_ct_cpu },
 	[IPCTNL_MSG_CT_GET_STATS]	= { .call = ctnetlink_stat_ct },
+	[IPCTNL_MSG_CT_GET_DYING]	= { .call = ctnetlink_get_ct_dying },
+	[IPCTNL_MSG_CT_GET_UNCONFIRMED]	= { .call = ctnetlink_get_ct_unconfirmed },
 };
 
 static const struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_EXP_MAX] = {
-- 
1.7.10.4
