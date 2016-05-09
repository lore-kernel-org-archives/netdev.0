From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/36] netfilter: conntrack: check netns when walking expect hash
Date: Mon,  9 May 2016 20:46:49 +0200
Message-ID: <1462819614-5402-32-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45822 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbcEISrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 583CCE8E84
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3BBC613470E
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2053E13471A
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:31 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |  3 +++
 net/netfilter/nf_conntrack_expect.c                   | 19 +++++++++++++++----
 net/netfilter/nf_conntrack_netlink.c                  | 12 ++++++++++++
 3 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index f8fc7ab..2b4c729 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -301,6 +301,9 @@ static int exp_seq_show(struct seq_file *s, void *v)
 
 	exp = hlist_entry(n, struct nf_conntrack_expect, hnode);
 
+	if (!net_eq(nf_ct_net(exp->master), seq_file_net(s)))
+		return 0;
+
 	if (exp->tuple.src.l3num != AF_INET)
 		return 0;
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index c2f7c4f..da95d74 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -86,6 +86,17 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 	return reciprocal_scale(hash, nf_ct_expect_hsize);
 }
 
+static bool
+nf_ct_exp_equal(const struct nf_conntrack_tuple *tuple,
+		const struct nf_conntrack_expect *i,
+		const struct nf_conntrack_zone *zone,
+		const struct net *net)
+{
+	return nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
+	       net_eq(net, nf_ct_net(i->master)) &&
+	       nf_ct_zone_equal_any(i->master, zone);
+}
+
 struct nf_conntrack_expect *
 __nf_ct_expect_find(struct net *net,
 		    const struct nf_conntrack_zone *zone,
@@ -99,8 +110,7 @@ __nf_ct_expect_find(struct net *net,
 
 	h = nf_ct_expect_dst_hash(tuple);
 	hlist_for_each_entry_rcu(i, &net->ct.expect_hash[h], hnode) {
-		if (nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
-		    nf_ct_zone_equal_any(i->master, zone))
+		if (nf_ct_exp_equal(tuple, i, zone, net))
 			return i;
 	}
 	return NULL;
@@ -141,8 +151,7 @@ nf_ct_find_expectation(struct net *net,
 	h = nf_ct_expect_dst_hash(tuple);
 	hlist_for_each_entry(i, &net->ct.expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
-		    nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
-		    nf_ct_zone_equal_any(i->master, zone)) {
+		    nf_ct_exp_equal(tuple, i, zone, net)) {
 			exp = i;
 			break;
 		}
@@ -222,6 +231,7 @@ static inline int expect_clash(const struct nf_conntrack_expect *a,
 	}
 
 	return nf_ct_tuple_mask_cmp(&a->tuple, &b->tuple, &intersect_mask) &&
+	       net_eq(nf_ct_net(a->master), nf_ct_net(b->master)) &&
 	       nf_ct_zone_equal_any(a->master, nf_ct_zone(b->master));
 }
 
@@ -231,6 +241,7 @@ static inline int expect_matches(const struct nf_conntrack_expect *a,
 	return a->master == b->master && a->class == b->class &&
 	       nf_ct_tuple_equal(&a->tuple, &b->tuple) &&
 	       nf_ct_tuple_mask_equal(&a->mask, &b->mask) &&
+	       net_eq(nf_ct_net(a->master), nf_ct_net(b->master)) &&
 	       nf_ct_zone_equal_any(a->master, nf_ct_zone(b->master));
 }
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e00f178..5dfb84d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2636,6 +2636,10 @@ restart:
 				     hnode) {
 			if (l3proto && exp->tuple.src.l3num != l3proto)
 				continue;
+
+			if (!net_eq(nf_ct_net(exp->master), net))
+				continue;
+
 			if (cb->args[1]) {
 				if (exp != last)
 					continue;
@@ -2888,6 +2892,10 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
 						  hnode) {
+
+				if (!net_eq(nf_ct_exp_net(exp), net))
+					continue;
+
 				m_help = nfct_help(exp->master);
 				if (!strcmp(m_help->helper->name, name) &&
 				    del_timer(&exp->timeout)) {
@@ -2906,6 +2914,10 @@ static int ctnetlink_del_expect(struct net *net, struct sock *ctnl,
 			hlist_for_each_entry_safe(exp, next,
 						  &net->ct.expect_hash[i],
 						  hnode) {
+
+				if (!net_eq(nf_ct_exp_net(exp), net))
+					continue;
+
 				if (del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect_report(exp,
 							NETLINK_CB(skb).portid,
-- 
2.1.4
