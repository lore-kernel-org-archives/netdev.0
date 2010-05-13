From: kaber@trash.net
Subject: [PATCH 03/12] netfilter: xtables: dissolve do_match function
Date: Thu, 13 May 2010 18:16:16 +0200
Message-ID: <1273767385-18225-4-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58078 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758971Ab0EMQQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:16:31 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/ip_tables.c  |   22 +++++-----------------
 net/ipv6/netfilter/ip6_tables.c |   22 +++++-----------------
 2 files changed, 10 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index f92818f..265cedf 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -173,21 +173,6 @@ ipt_error(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-/* Performance critical - called for every packet */
-static inline bool
-do_match(const struct ipt_entry_match *m, const struct sk_buff *skb,
-	 struct xt_match_param *par)
-{
-	par->match     = m->u.kernel.match;
-	par->matchinfo = m->data;
-
-	/* Stop iteration if it doesn't match */
-	if (!m->u.kernel.match->match(skb, par))
-		return true;
-	else
-		return false;
-}
-
 /* Performance critical */
 static inline struct ipt_entry *
 get_entry(const void *base, unsigned int offset)
@@ -379,9 +364,12 @@ ipt_do_table(struct sk_buff *skb,
 			continue;
 		}
 
-		xt_ematch_foreach(ematch, e)
-			if (do_match(ematch, skb, &mtpar) != 0)
+		xt_ematch_foreach(ematch, e) {
+			mtpar.match     = ematch->u.kernel.match;
+			mtpar.matchinfo = ematch->data;
+			if (!mtpar.match->match(skb, &mtpar))
 				goto no_match;
+		}
 
 		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 7afa117..f8ac4a0 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -205,21 +205,6 @@ ip6t_error(struct sk_buff *skb, const struct xt_target_param *par)
 	return NF_DROP;
 }
 
-/* Performance critical - called for every packet */
-static inline bool
-do_match(const struct ip6t_entry_match *m, const struct sk_buff *skb,
-	 struct xt_match_param *par)
-{
-	par->match     = m->u.kernel.match;
-	par->matchinfo = m->data;
-
-	/* Stop iteration if it doesn't match */
-	if (!m->u.kernel.match->match(skb, par))
-		return true;
-	else
-		return false;
-}
-
 static inline struct ip6t_entry *
 get_entry(const void *base, unsigned int offset)
 {
@@ -402,9 +387,12 @@ ip6t_do_table(struct sk_buff *skb,
 			continue;
 		}
 
-		xt_ematch_foreach(ematch, e)
-			if (do_match(ematch, skb, &mtpar) != 0)
+		xt_ematch_foreach(ematch, e) {
+			mtpar.match     = ematch->u.kernel.match;
+			mtpar.matchinfo = ematch->data;
+			if (!mtpar.match->match(skb, &mtpar))
 				goto no_match;
+		}
 
 		ADD_COUNTER(e->counters,
 			    ntohs(ipv6_hdr(skb)->payload_len) +
-- 
1.7.0.4

