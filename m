From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix inet_getid() and ipv6_select_ident() bugs
Date: Thu, 29 May 2014 08:45:14 -0700
Message-ID: <1401378314.3645.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:42293 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757704AbaE2PpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 11:45:17 -0400
Received: by mail-pa0-f49.google.com with SMTP id kp14so554500pab.36
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 08:45:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I noticed we were sending wrong IPv4 ID in TCP flows when MTU discovery
is disabled.
Note how GSO/TSO packets do not have monotonically incrementing ID. 

06:37:41.575531 IP (id 14227, proto: TCP (6), length: 4396)
06:37:41.575534 IP (id 14272, proto: TCP (6), length: 65212)
06:37:41.575544 IP (id 14312, proto: TCP (6), length: 57972)
06:37:41.575678 IP (id 14317, proto: TCP (6), length: 7292)
06:37:41.575683 IP (id 14361, proto: TCP (6), length: 63764)

It appears I introduced this bug in linux-3.1.

inet_getid() must return the old value of peer->ip_id_count,
not the new one.

Lets revert this part, and remove the prevention of
a null identification field in IPv6 Fragment Extension Header,
which is dubious and not even done properly.

Fixes: 87c48fa3b463 ("ipv6: make fragment identifications less predictable")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inetpeer.h |    9 +--------
 net/ipv6/output_core.c |   11 +++--------
 2 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 6efe73c79c52..058271bde27a 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -177,16 +177,9 @@ static inline void inet_peer_refcheck(const struct inet_peer *p)
 /* can be called with or without local BH being disabled */
 static inline int inet_getid(struct inet_peer *p, int more)
 {
-	int old, new;
 	more++;
 	inet_peer_refcheck(p);
-	do {
-		old = atomic_read(&p->ip_id_count);
-		new = old + more;
-		if (!new)
-			new = 1;
-	} while (atomic_cmpxchg(&p->ip_id_count, old, new) != old);
-	return new;
+	return atomic_add_return(more, &p->ip_id_count) - more;
 }
 
 #endif /* _NET_INETPEER_H */
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 6313abd53c9d..56596ce390a1 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -12,7 +12,7 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 {
 	static atomic_t ipv6_fragmentation_id;
 	struct in6_addr addr;
-	int old, new;
+	int ident;
 
 #if IS_ENABLED(CONFIG_IPV6)
 	struct inet_peer *peer;
@@ -26,15 +26,10 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 		return;
 	}
 #endif
-	do {
-		old = atomic_read(&ipv6_fragmentation_id);
-		new = old + 1;
-		if (!new)
-			new = 1;
-	} while (atomic_cmpxchg(&ipv6_fragmentation_id, old, new) != old);
+	ident = atomic_inc_return(&ipv6_fragmentation_id);
 
 	addr = rt->rt6i_dst.addr;
-	addr.s6_addr32[0] ^= (__force __be32)new;
+	addr.s6_addr32[0] ^= (__force __be32)ident;
 	fhdr->identification = htonl(secure_ipv6_id(addr.s6_addr32));
 }
 EXPORT_SYMBOL(ipv6_select_ident);
