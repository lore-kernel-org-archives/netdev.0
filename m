From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 1/2] ipv6: Initialize the struct rt6_info behind
 the dst_enty field
Date: Fri, 6 Jul 2012 11:37:09 +0200
Message-ID: <20120706093709.GH1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42045 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549Ab2GFJhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 05:37:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We start initializing the struct rt6_info at the first field
behind the struct dst_enty. This is error prone because it
might leave a new field uninitialized. So start initializing
the struct rt6_info right behind the dst_entry.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6cc6c88..1d8459b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -273,8 +273,9 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					0, 0, flags);
 
 	if (rt) {
-		memset(&rt->n, 0,
-		       sizeof(*rt) - sizeof(struct dst_entry));
+		struct dst_entry *dst = (struct dst_entry *)rt;
+
+		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 	}
 	return rt;
@@ -975,10 +976,10 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
 	if (rt) {
-		memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
-		rt6_init_peer(rt, net->ipv6.peers);
+		new = (struct dst_entry *)rt;
 
-		new = &rt->dst;
+		memset(new + 1, 0, sizeof(*rt) - sizeof(*new));
+		rt6_init_peer(rt, net->ipv6.peers);
 
 		new->__use = 1;
 		new->input = dst_discard;
-- 
1.7.0.4
