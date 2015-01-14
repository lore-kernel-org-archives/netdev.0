From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/8] netfilter: conntrack: Flush connections with a given mark
Date: Wed, 14 Jan 2015 21:34:48 +0100
Message-ID: <1421267689-24894-8-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kristian Evensen <kristian.evensen@gmail.com>

This patch adds support for selective flushing of conntrack mappings.
By adding CTA_MARK and CTA_MARK_MASK to a delete-message, the mark (and
mask) is checked before a connection is deleted while flushing.

Configuring the flush is moved out of ctnetlink_del_conntrack(), and
instead of calling nf_conntrack_flush_report(), we always call
nf_ct_iterate_cleanup().  This enables us to only make one call from the
new ctnetlink_flush_conntrack() and makes it easy to add more filter
parameters.

Filtering is done in the ctnetlink_filter_match()-function, which is
also called from ctnetlink_dump_table(). ctnetlink_dump_filter has been
renamed ctnetlink_filter, to indicated that it is no longer only used
when dumping conntrack entries.

Moreover, reject mark filters with -EOPNOTSUPP if no ct mark support is
available.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   89 ++++++++++++++++++++++++----------
 1 file changed, 64 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1bd9ed9..d1c2394 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -749,13 +749,47 @@ static int ctnetlink_done(struct netlink_callback *cb)
 	return 0;
 }
 
-struct ctnetlink_dump_filter {
+struct ctnetlink_filter {
 	struct {
 		u_int32_t val;
 		u_int32_t mask;
 	} mark;
 };
 
+static struct ctnetlink_filter *
+ctnetlink_alloc_filter(const struct nlattr * const cda[])
+{
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	struct ctnetlink_filter *filter;
+
+	filter = kzalloc(sizeof(*filter), GFP_KERNEL);
+	if (filter == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	filter->mark.val = ntohl(nla_get_be32(cda[CTA_MARK]));
+	filter->mark.mask = ntohl(nla_get_be32(cda[CTA_MARK_MASK]));
+
+	return filter;
+#else
+	return ERR_PTR(-EOPNOTSUPP);
+#endif
+}
+
+static int ctnetlink_filter_match(struct nf_conn *ct, void *data)
+{
+	struct ctnetlink_filter *filter = data;
+
+	if (filter == NULL)
+		return 1;
+
+#ifdef CONFIG_NF_CONNTRACK_MARK
+	if ((ct->mark & filter->mark.mask) == filter->mark.val)
+		return 1;
+#endif
+
+	return 0;
+}
+
 static int
 ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -768,10 +802,6 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	int res;
 	spinlock_t *lockp;
 
-#ifdef CONFIG_NF_CONNTRACK_MARK
-	const struct ctnetlink_dump_filter *filter = cb->data;
-#endif
-
 	last = (struct nf_conn *)cb->args[1];
 
 	local_bh_disable();
@@ -798,12 +828,9 @@ restart:
 					continue;
 				cb->args[1] = 0;
 			}
-#ifdef CONFIG_NF_CONNTRACK_MARK
-			if (filter && !((ct->mark & filter->mark.mask) ==
-					filter->mark.val)) {
+			if (!ctnetlink_filter_match(ct, cb->data))
 				continue;
-			}
-#endif
+
 			rcu_read_lock();
 			res =
 			ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).portid,
@@ -1001,6 +1028,25 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 				    .len = NF_CT_LABELS_MAX_SIZE },
 };
 
+static int ctnetlink_flush_conntrack(struct net *net,
+				     const struct nlattr * const cda[],
+				     u32 portid, int report)
+{
+	struct ctnetlink_filter *filter = NULL;
+
+	if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
+		filter = ctnetlink_alloc_filter(cda);
+		if (IS_ERR(filter))
+			return PTR_ERR(filter);
+	}
+
+	nf_ct_iterate_cleanup(net, ctnetlink_filter_match, filter,
+			      portid, report);
+	kfree(filter);
+
+	return 0;
+}
+
 static int
 ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
@@ -1024,11 +1070,9 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	else if (cda[CTA_TUPLE_REPLY])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
-		/* Flush the whole table */
-		nf_conntrack_flush_report(net,
-					 NETLINK_CB(skb).portid,
-					 nlmsg_report(nlh));
-		return 0;
+		return ctnetlink_flush_conntrack(net, cda,
+						 NETLINK_CB(skb).portid,
+						 nlmsg_report(nlh));
 	}
 
 	if (err < 0)
@@ -1076,21 +1120,16 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			.dump = ctnetlink_dump_table,
 			.done = ctnetlink_done,
 		};
-#ifdef CONFIG_NF_CONNTRACK_MARK
+
 		if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
-			struct ctnetlink_dump_filter *filter;
+			struct ctnetlink_filter *filter;
 
-			filter = kzalloc(sizeof(struct ctnetlink_dump_filter),
-					 GFP_ATOMIC);
-			if (filter == NULL)
-				return -ENOMEM;
+			filter = ctnetlink_alloc_filter(cda);
+			if (IS_ERR(filter))
+				return PTR_ERR(filter);
 
-			filter->mark.val = ntohl(nla_get_be32(cda[CTA_MARK]));
-			filter->mark.mask =
-				ntohl(nla_get_be32(cda[CTA_MARK_MASK]));
 			c.data = filter;
 		}
-#endif
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
 
-- 
1.7.10.4

