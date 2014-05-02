From: Tom Herbert <therbert@google.com>
Subject: [PATCH 7/8 v4] net: Call skb_checksum_init in IPv6
Date: Fri, 2 May 2014 16:29:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405021529500.20133@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:58747 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaEBXg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 19:36:28 -0400
Received: by mail-ob0-f201.google.com with SMTP id wn1so41509obc.2
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 16:36:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_checksum_init instead of private functions.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip6_checksum.h |  7 +++++++
 net/ipv6/ip6_checksum.c    | 11 +----------
 net/ipv6/tcp_ipv6.c        | 21 +--------------------
 3 files changed, 9 insertions(+), 30 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 9e3c540..8ac5c21 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -41,6 +41,13 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			__wsum csum);
 #endif
 
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
