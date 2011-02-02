From: kaber@trash.net
Subject: [PATCH 2/4] netfilter: xt_iprange: Incorrect xt_iprange boundary check for IPv6
Date: Thu,  3 Feb 2011 00:45:28 +0100
Message-ID: <1296690330-9887-3-git-send-email-kaber@trash.net>
References: <1296690330-9887-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45197 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390Ab1BBXpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:45:47 -0500
In-Reply-To: <1296690330-9887-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Jacob <jacob@internet24.de>

iprange_ipv6_sub was substracting 2 unsigned ints and then casting
the result to int to find out whether they are lt, eq or gt each
other, this doesn't work if the full 32 bits of each part
can be used in IPv6 addresses. Patch should remedy that without
significant performance penalties. Also number of ntohl
calls can be reduced this way (Jozsef Kadlecsik).

Signed-off-by: Thomas Jacob <jacob@internet24.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_iprange.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 88f7c35..73c33a4 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -53,15 +53,13 @@ iprange_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 }
 
 static inline int
-iprange_ipv6_sub(const struct in6_addr *a, const struct in6_addr *b)
+iprange_ipv6_lt(const struct in6_addr *a, const struct in6_addr *b)
 {
 	unsigned int i;
-	int r;
 
 	for (i = 0; i < 4; ++i) {
-		r = ntohl(a->s6_addr32[i]) - ntohl(b->s6_addr32[i]);
-		if (r != 0)
-			return r;
+		if (a->s6_addr32[i] != b->s6_addr32[i])
+			return ntohl(a->s6_addr32[i]) < ntohl(b->s6_addr32[i]);
 	}
 
 	return 0;
@@ -75,15 +73,15 @@ iprange_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	bool m;
 
 	if (info->flags & IPRANGE_SRC) {
-		m  = iprange_ipv6_sub(&iph->saddr, &info->src_min.in6) < 0;
-		m |= iprange_ipv6_sub(&iph->saddr, &info->src_max.in6) > 0;
+		m  = iprange_ipv6_lt(&iph->saddr, &info->src_min.in6);
+		m |= iprange_ipv6_lt(&info->src_max.in6, &iph->saddr);
 		m ^= !!(info->flags & IPRANGE_SRC_INV);
 		if (m)
 			return false;
 	}
 	if (info->flags & IPRANGE_DST) {
-		m  = iprange_ipv6_sub(&iph->daddr, &info->dst_min.in6) < 0;
-		m |= iprange_ipv6_sub(&iph->daddr, &info->dst_max.in6) > 0;
+		m  = iprange_ipv6_lt(&iph->daddr, &info->dst_min.in6);
+		m |= iprange_ipv6_lt(&info->dst_max.in6, &iph->daddr);
 		m ^= !!(info->flags & IPRANGE_DST_INV);
 		if (m)
 			return false;
-- 
1.7.2.3

