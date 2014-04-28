From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] net: ipv6: more places need LOOPBACK_IFINDEX for flowi6_iif
Date: Mon, 28 Apr 2014 10:51:56 +0300
Message-ID: <1398671516-8842-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33363 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751808AbaD1HwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 03:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To properly match iif in ip rules we have to provide
LOOPBACK_IFINDEX in flowi6_iif, not 0. Some ip6mr_fib_lookup
and fib6_rule_lookup callers need such fix.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/ip6mr.c                   | 2 +-
 net/ipv6/netfilter/ip6t_rpfilter.c | 1 +
 net/ipv6/route.c                   | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 8659067..8250474 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1633,7 +1633,7 @@ struct sock *mroute6_socket(struct net *net, struct sk_buff *skb)
 {
 	struct mr6_table *mrt;
 	struct flowi6 fl6 = {
-		.flowi6_iif	= skb->skb_iif,
+		.flowi6_iif	= skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi6_oif	= skb->dev->ifindex,
 		.flowi6_mark	= skb->mark,
 	};
diff --git a/net/ipv6/netfilter/ip6t_rpfilter.c b/net/ipv6/netfilter/ip6t_rpfilter.c
index e0983f3..790e0c6 100644
--- a/net/ipv6/netfilter/ip6t_rpfilter.c
+++ b/net/ipv6/netfilter/ip6t_rpfilter.c
@@ -33,6 +33,7 @@ static bool rpfilter_lookup_reverse6(const struct sk_buff *skb,
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	bool ret = false;
 	struct flowi6 fl6 = {
+		.flowi6_iif = LOOPBACK_IFINDEX,
 		.flowlabel = (* (__be32 *) iph) & IPV6_FLOWINFO_MASK,
 		.flowi6_proto = iph->nexthdr,
 		.daddr = iph->saddr,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4011617..004fffb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1273,6 +1273,7 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
 	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_iif = LOOPBACK_IFINDEX;
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
 	fl6.daddr = iph->daddr;
@@ -1294,6 +1295,7 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	struct flowi6 fl6;
 
 	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_iif = LOOPBACK_IFINDEX;
 	fl6.flowi6_oif = oif;
 	fl6.flowi6_mark = mark;
 	fl6.daddr = msg->dest;
-- 
1.9.0
