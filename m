From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Use ip6_dst_hoplimit() instead of direct
 dst_metric() calls.
Date: Sun, 12 Dec 2010 21:16:48 -0800 (PST)
Message-ID: <20101212.211648.233707091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750974Ab0LMFQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 00:16:20 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2E53D24C088
	for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 21:16:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

I just noticed this while hacking on metrics.  IPV6 has to use
this special function because the default has a dynamic
per-interface value.  So it can't do the same trick ipv4 does
by pre-seeding the cached route metric.

 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/route.c                 |    1 +
 net/ipv6/xfrm6_mode_tunnel.c     |    3 ++-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 2933396..bf998fe 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -124,7 +124,7 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	skb_reset_network_header(nskb);
 	ip6h = ipv6_hdr(nskb);
 	ip6h->version = 6;
-	ip6h->hop_limit = dst_metric(dst, RTAX_HOPLIMIT);
+	ip6h->hop_limit = ip6_dst_hoplimit(dst);
 	ip6h->nexthdr = IPPROTO_TCP;
 	ipv6_addr_copy(&ip6h->saddr, &oip6h->daddr);
 	ipv6_addr_copy(&ip6h->daddr, &oip6h->saddr);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4aed081..9b2d7bc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1119,6 +1119,7 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 	}
 	return hoplimit;
 }
+EXPORT_SYMBOL(ip6_dst_hoplimit);
 
 /*
  *
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index b809812..645cb96 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -14,6 +14,7 @@
 #include <net/dsfield.h>
 #include <net/dst.h>
 #include <net/inet_ecn.h>
+#include <net/ip6_route.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
@@ -53,7 +54,7 @@ static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (x->props.flags & XFRM_STATE_NOECN)
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
-	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
+	top_iph->hop_limit = ip6_dst_hoplimit(dst->child);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 	return 0;
-- 
1.7.3.2

