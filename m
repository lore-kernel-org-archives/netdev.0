From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: nf_tables: set NLM_F_DUMP_INTR if netlink dumping is stale
Date: Tue, 15 Jul 2014 16:05:21 +0200
Message-ID: <1405433122-7440-4-git-send-email-pablo@netfilter.org>
References: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57069 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbaGOOFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 10:05:37 -0400
In-Reply-To: <1405433122-7440-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An updater may interfer with the dumping of any of the object lists.
Fix this by using a per-net generation counter and use the
nl_dump_check_consistent() interface so the NLM_F_DUMP_INTR flag is set
to notify userspace that it has to restart the dump since an updater
has interfered.

This patch also replaces the existing consistency checking code in the
rule dumping path since it is broken. Basically, the value that the
dump callback returns is not propagated to userspace via
netlink_dump_start().

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/nftables.h  |    2 +-
 net/netfilter/nf_tables_api.c |   30 +++++++++++++++++++++++-------
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/nftables.h b/include/net/netns/nftables.h
index 26a394c..eee608b 100644
--- a/include/net/netns/nftables.h
+++ b/include/net/netns/nftables.h
@@ -13,8 +13,8 @@ struct netns_nftables {
 	struct nft_af_info	*inet;
 	struct nft_af_info	*arp;
 	struct nft_af_info	*bridge;
+	unsigned int		base_seq;
 	u8			gencursor;
-	u8			genctr;
 };
 
 #endif
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index a27a7c5..ac03d74 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -278,6 +278,8 @@ static int nf_tables_dump_tables(struct sk_buff *skb,
 	int family = nfmsg->nfgen_family;
 
 	rcu_read_lock();
+	cb->seq = net->nft.base_seq;
+
 	list_for_each_entry_rcu(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
@@ -295,6 +297,8 @@ static int nf_tables_dump_tables(struct sk_buff *skb,
 						      NLM_F_MULTI,
 						      afi->family, table) < 0)
 				goto done;
+
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
@@ -767,6 +771,8 @@ static int nf_tables_dump_chains(struct sk_buff *skb,
 	int family = nfmsg->nfgen_family;
 
 	rcu_read_lock();
+	cb->seq = net->nft.base_seq;
+
 	list_for_each_entry_rcu(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
@@ -784,6 +790,8 @@ static int nf_tables_dump_chains(struct sk_buff *skb,
 							      NLM_F_MULTI,
 							      afi->family, table, chain) < 0)
 					goto done;
+
+				nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 				idx++;
 			}
@@ -1555,10 +1563,10 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 	unsigned int idx = 0, s_idx = cb->args[0];
 	struct net *net = sock_net(skb->sk);
 	int family = nfmsg->nfgen_family;
-	u8 genctr = ACCESS_ONCE(net->nft.genctr);
-	u8 gencursor = ACCESS_ONCE(net->nft.gencursor);
 
 	rcu_read_lock();
+	cb->seq = net->nft.base_seq;
+
 	list_for_each_entry_rcu(afi, &net->nft.af_info, list) {
 		if (family != NFPROTO_UNSPEC && family != afi->family)
 			continue;
@@ -1579,6 +1587,8 @@ static int nf_tables_dump_rules(struct sk_buff *skb,
 								      NLM_F_MULTI | NLM_F_APPEND,
 								      afi->family, table, chain, rule) < 0)
 						goto done;
+
+					nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 					idx++;
 				}
@@ -1588,10 +1598,6 @@ cont:
 done:
 	rcu_read_unlock();
 
-	/* Invalidate this dump, a transition to the new generation happened */
-	if (gencursor != net->nft.gencursor || genctr != net->nft.genctr)
-		return -EBUSY;
-
 	cb->args[0] = idx;
 	return skb->len;
 }
@@ -2244,6 +2250,8 @@ static int nf_tables_dump_sets_table(struct nft_ctx *ctx, struct sk_buff *skb,
 		return skb->len;
 
 	rcu_read_lock();
+	cb->seq = ctx->net->nft.base_seq;
+
 	list_for_each_entry_rcu(set, &ctx->table->sets, list) {
 		if (idx < s_idx)
 			goto cont;
@@ -2252,6 +2260,7 @@ static int nf_tables_dump_sets_table(struct nft_ctx *ctx, struct sk_buff *skb,
 			cb->args[0] = idx;
 			goto done;
 		}
+		nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 		idx++;
 	}
@@ -2272,6 +2281,8 @@ static int nf_tables_dump_sets_family(struct nft_ctx *ctx, struct sk_buff *skb,
 		return skb->len;
 
 	rcu_read_lock();
+	cb->seq = ctx->net->nft.base_seq;
+
 	list_for_each_entry_rcu(table, &ctx->afi->tables, list) {
 		if (cur_table) {
 			if (cur_table != table)
@@ -2290,6 +2301,7 @@ static int nf_tables_dump_sets_family(struct nft_ctx *ctx, struct sk_buff *skb,
 				cb->args[2] = (unsigned long) table;
 				goto done;
 			}
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
@@ -2314,6 +2326,8 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 		return skb->len;
 
 	rcu_read_lock();
+	cb->seq = net->nft.base_seq;
+
 	list_for_each_entry_rcu(afi, &net->nft.af_info, list) {
 		if (cur_family) {
 			if (afi->family != cur_family)
@@ -2344,6 +2358,7 @@ static int nf_tables_dump_sets_all(struct nft_ctx *ctx, struct sk_buff *skb,
 					cb->args[3] = afi->family;
 					goto done;
 				}
+				nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 				idx++;
 			}
@@ -3361,7 +3376,7 @@ static int nf_tables_commit(struct sk_buff *skb)
 	struct nft_set *set;
 
 	/* Bump generation counter, invalidate any dump in progress */
-	net->nft.genctr++;
+	while (++net->nft.base_seq == 0);
 
 	/* A new generation has just started */
 	net->nft.gencursor = gencursor_next(net);
@@ -3966,6 +3981,7 @@ static int nf_tables_init_net(struct net *net)
 {
 	INIT_LIST_HEAD(&net->nft.af_info);
 	INIT_LIST_HEAD(&net->nft.commit_list);
+	net->nft.base_seq = 1;
 	return 0;
 }
 
-- 
1.7.10.4
