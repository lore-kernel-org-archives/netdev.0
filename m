From: Tom Herbert <therbert@google.com>
Subject: [PATCH 7/9 v2] net: Call skb_checksum_init in IPv6
Date: Sat, 26 Apr 2014 14:26:09 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261401410.27080@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:43547 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaDZV0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:26:10 -0400
Received: by mail-oa0-f73.google.com with SMTP id m1so1162002oag.2
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:26:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_checksum_init instead of private functions.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip6_checksum.h |  8 ++++++++
 net/ipv6/ip6_checksum.c    | 11 +----------
 net/ipv6/tcp_ipv6.c        | 21 +--------------------
 3 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 9e3c540..dd6fc1f 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -41,6 +41,14 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			__wsum csum);
 #endif
 
+
+static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					    &ipv6_hdr(skb)->daddr,
+					    skb->len, proto, 0));
+}
+
 static __inline__ __sum16 tcp_v6_check(int len,
 				   const struct in6_addr *saddr,
 				   const struct in6_addr *daddr,
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index ee7a97f..c69fe37 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -84,16 +84,7 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 			       &ipv6_hdr(skb)->daddr, ntohs(uh->dest));
 		return 1;
 	}
-	if (skb->ip_summed == CHECKSUM_COMPLETE &&
-	    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
-			     skb->len, proto, skb->csum))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (!skb_csum_unnecessary(skb))
-		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							 &ipv6_hdr(skb)->daddr,
-							 skb->len, proto, 0));
-
-	return 0;
+	return skb_checksum_init(skb, IPPROTO_UDP, ip6_compute_pseudo);
 }
 EXPORT_SYMBOL(udp6_csum_init);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e289830..7fa6743 100644
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
+	if (skb_checksum_init(skb, IPPROTO_TCP, ip6_compute_pseudo))
 		goto csum_error;
 
 	th = tcp_hdr(skb);
-- 
1.9.1.423.g4596e3a
