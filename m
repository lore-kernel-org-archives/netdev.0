From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: ctnetlink: support kernel-space dump filtering by ctmark
Date: Sat, 25 Feb 2012 01:30:17 +0100
Message-ID: <1330129817-28199-4-git-send-email-pablo@netfilter.org>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42614 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756835Ab2BYAaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 19:30:30 -0500
In-Reply-To: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds CTA_MARK_MASK which, together with CTA_MARK, allows
you to selectively send conntrack entries to user-space by
returning those that match mark & mask.

With this, we can save cycles in the building and the parsing of
the entries that may be later on filtered out in user-space by using
the ctmark & mask.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/netfilter/nf_conntrack_netlink.c          |   32 +++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 5ec1abc..e58e4b9 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -43,6 +43,7 @@ enum ctattr_type {
 	CTA_ZONE,
 	CTA_SECCTX,
 	CTA_TIMESTAMP,
+	CTA_MARK_MASK,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dd4aaba..5874917 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -691,9 +691,18 @@ static int ctnetlink_done(struct netlink_callback *cb)
 {
 	if (cb->args[1])
 		nf_ct_put((struct nf_conn *)cb->args[1]);
+	if (cb->data)
+		kfree(cb->data);
 	return 0;
 }
 
+struct ctnetlink_dump_filter {
+	struct {
+		u_int32_t val;
+		u_int32_t mask;
+	} mark;
+};
+
 static int
 ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -703,6 +712,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
+	const struct ctnetlink_dump_filter *filter = cb->data;
 
 	spin_lock_bh(&nf_conntrack_lock);
 	last = (struct nf_conn *)cb->args[1];
@@ -723,6 +733,12 @@ restart:
 					continue;
 				cb->args[1] = 0;
 			}
+#ifdef CONFIG_NF_CONNTRACK_MARK
+			if (filter && !((ct->mark & filter->mark.mask) ==
+					filter->mark.val)) {
+				continue;
+			}
+#endif
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
 						NFNL_MSG_TYPE(
@@ -894,6 +910,7 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_NAT_DST]		= { .type = NLA_NESTED },
 	[CTA_TUPLE_MASTER]	= { .type = NLA_NESTED },
 	[CTA_ZONE]		= { .type = NLA_U16 },
+	[CTA_MARK_MASK]		= { .type = NLA_U32 },
 };
 
 static int
@@ -982,6 +999,21 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			.dump = ctnetlink_dump_table,
 			.done = ctnetlink_done,
 		};
+#ifdef CONFIG_NF_CONNTRACK_MARK
+		if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
+			struct ctnetlink_dump_filter *filter;
+
+			filter = kzalloc(sizeof(struct ctnetlink_dump_filter),
+					 GFP_ATOMIC);
+			if (filter == NULL)
+				return -ENOMEM;
+
+			filter->mark.val = ntohl(nla_get_be32(cda[CTA_MARK]));
+			filter->mark.mask =
+				ntohl(nla_get_be32(cda[CTA_MARK_MASK]));
+			c.data = filter;
+		}
+#endif
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
 
-- 
1.7.7.3
