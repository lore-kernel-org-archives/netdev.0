From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: ctnetlink: support kernel-space dump
 filtering by ctmark
Date: Sat, 25 Feb 2012 01:41:50 +0100
Message-ID: <20120225004150.GA13494@1984>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
 <1330129817-28199-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330129817-28199-4-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Feb 25, 2012 at 01:30:17AM +0100, pablo@netfilter.org wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This patch adds CTA_MARK_MASK which, together with CTA_MARK, allows
> you to selectively send conntrack entries to user-space by
> returning those that match mark & mask.
> 
> With this, we can save cycles in the building and the parsing of
> the entries that may be later on filtered out in user-space by using
> the ctmark & mask.

Minor glitch in this patch. One ifdef was missing that would spot an
unused variable warning if CONFIG_NF_CONNTRACK_MARK is disabled.

New patch for ctnetlink attached.

--J/dobhs11T7y2rNN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0003-netfilter-ctnetlink-support-kernel-space-dump-filter.patch"

>From 604bb5f7385bcde5be0e0a5f3f52fa05ef21d3bc Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 25 Feb 2012 00:48:38 +0100
Subject: [PATCH 3/3] netfilter: ctnetlink: support kernel-space dump
 filtering by ctmark

This patch adds CTA_MARK_MASK which, together with CTA_MARK, allows
you to selectively send conntrack entries to user-space by
returning those that match mark & mask.

With this, we can save cycles in the building and the parsing of
the entries that may be later on filtered out in user-space by using
the ctmark & mask.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/netfilter/nf_conntrack_netlink.c          |   35 ++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 1 deletions(-)

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
index dd4aaba..800ec17 100644
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
@@ -703,7 +712,9 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_nulls_node *n;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	u_int8_t l3proto = nfmsg->nfgen_family;
-
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	const struct ctnetlink_dump_filter *filter = cb->data;
+#endif
 	spin_lock_bh(&nf_conntrack_lock);
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
@@ -723,6 +734,12 @@ restart:
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
@@ -894,6 +911,7 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_NAT_DST]		= { .type = NLA_NESTED },
 	[CTA_TUPLE_MASTER]	= { .type = NLA_NESTED },
 	[CTA_ZONE]		= { .type = NLA_U16 },
+	[CTA_MARK_MASK]		= { .type = NLA_U32 },
 };
 
 static int
@@ -982,6 +1000,21 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
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


--J/dobhs11T7y2rNN--
