From: Tom Herbert <therbert@google.com>
Subject: [PATCH next-next 5/6] net: Call skb_checksum_init in IPv6
Date: Fri, 4 Apr 2014 17:28:09 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041721050.21509@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:61927 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbaDEA2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:28:10 -0400
Received: by mail-ie0-f202.google.com with SMTP id lx4so727711iec.5
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:28:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested by running 20 netperf TCP_STREAMs with combinations of
LRO on/off, rx-csum-offload on/off, device provide checksum-complete
(emulated) with occasional incorrect value.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip6_checksum.h |  2 ++
 net/core/checksum.c        |  1 +
 net/ipv6/ip6_checksum.c    | 19 +++++++++----------
 net/ipv6/tcp_ipv6.c        | 21 +--------------------
 4 files changed, 13 insertions(+), 30 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 9e3c540..2df805b 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -41,6 +41,8 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			__wsum csum);
 #endif
 
+__wsum ip6_pseudo_compute(struct sk_buff *skb, int proto);
+
 static __inline__ __sum16 tcp_v6_check(int len,
 				   const struct in6_addr *saddr,
 				   const struct in6_addr *daddr,
diff --git a/net/core/checksum.c b/net/core/checksum.c
index b0df8c7..33249c3 100644
--- a/net/core/checksum.c
+++ b/net/core/checksum.c
@@ -56,3 +56,4 @@ __sum16 __skb_checksum_validate(struct sk_buff *skb, int proto, bool complete,
 
 	return 0;
 }
+EXPORT_SYMBOL(__skb_checksum_validate);
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index ee7a97f..6105b8f 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -62,6 +62,14 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 EXPORT_SYMBOL(csum_ipv6_magic);
 #endif
 
+__wsum ip6_pseudo_compute(struct sk_buff *skb, int proto)
+{
+	return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					    &ipv6_hdr(skb)->daddr,
+					    skb->len, proto, 0));
+}
+EXPORT_SYMBOL(ip6_pseudo_compute);
+
 int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 {
 	int err;
@@ -84,16 +92,7 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 			       &ipv6_hdr(skb)->daddr, ntohs(uh->dest));
 		return 1;
 	}
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
-			     skb->len, proto, skb->csum))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-	if (!skb_csum_unnecessary(skb))
-		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							 &ipv6_hdr(skb)->daddr,
-							 skb->len, proto, 0));
 
-	return 0;
+	return skb_checksum_init(skb, IPPROTO_UDP, ip6_pseudo_compute);
 }
 EXPORT_SYMBOL(udp6_csum_init);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ca56ce..ee873e1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1294,25 +1294,6 @@ out:
 	return NULL;
 }
 
-static __sum16 tcp_v6_checksum_init(struct sk_buff *skb)
-{
-	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!tcp_v6_check(skb->len, &ipv6_hdr(skb)->saddr,
-				  &ipv6_hdr(skb)->daddr, skb->csum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			return 0;
-		}
-	}
-
-	skb->csum = ~csum_unfold(tcp_v6_check(skb->len,
-					      &ipv6_hdr(skb)->saddr,
-					      &ipv6_hdr(skb)->daddr, 0));
-
-	if (skb->len <= 76)
-		return __skb_checksum_complete(skb);
-	return 0;
-}
-
 /* The socket must have it's spinlock held when we get
  * here.
  *
@@ -1486,7 +1467,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, th->doff*4))
 		goto discard_it;
 
-	if (!skb_csum_unnecessary(skb) && tcp_v6_checksum_init(skb))
+	if (skb_checksum_init(skb, IPPROTO_TCP, ip6_pseudo_compute))
 		goto csum_error;
 
 	th = tcp_hdr(skb);
-- 
1.9.1.423.g4596e3a
