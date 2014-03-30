From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: strengthen fallback fragmentation id generation
Date: Sun, 30 Mar 2014 18:28:03 +0200
Message-ID: <20140330162803.GG11063@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40400 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaC3Q2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 12:28:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First off, we don't need to check for non-NULL rt any more, as we are
guaranteed to always get a valid rt6_info. Drop the check.

In case we couldn't allocate an inet_peer for fragmentation information
we currently generate strictly incrementing fragmentation ids for all
destination. This is done to maximize the cycle and avoid collisions.

Those fragmentation ids are very predictable. At least we should try to
mix in the destination address.

While it should make no difference to simply use a PRNG at this point,
secure_ipv6_id ensures that we don't leak information from prandom,
so its internal state could be recoverable.

This fallback function should normally not get used thus this should
not affect performance at all. It is just meant as a safety net.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/output_core.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index d1b35d3..6313abd 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -6,24 +6,24 @@
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/addrconf.h>
+#include <net/secure_seq.h>
 
 void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 {
 	static atomic_t ipv6_fragmentation_id;
+	struct in6_addr addr;
 	int old, new;
 
 #if IS_ENABLED(CONFIG_IPV6)
-	if (rt) {
-		struct inet_peer *peer;
-		struct net *net;
-
-		net = dev_net(rt->dst.dev);
-		peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
-		if (peer) {
-			fhdr->identification = htonl(inet_getid(peer, 0));
-			inet_putpeer(peer);
-			return;
-		}
+	struct inet_peer *peer;
+	struct net *net;
+
+	net = dev_net(rt->dst.dev);
+	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, 1);
+	if (peer) {
+		fhdr->identification = htonl(inet_getid(peer, 0));
+		inet_putpeer(peer);
+		return;
 	}
 #endif
 	do {
@@ -32,7 +32,10 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 		if (!new)
 			new = 1;
 	} while (atomic_cmpxchg(&ipv6_fragmentation_id, old, new) != old);
-	fhdr->identification = htonl(new);
+
+	addr = rt->rt6i_dst.addr;
+	addr.s6_addr32[0] ^= (__force __be32)new;
+	fhdr->identification = htonl(secure_ipv6_id(addr.s6_addr32));
 }
 EXPORT_SYMBOL(ipv6_select_ident);
 
-- 
1.9.0
