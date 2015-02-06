From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next] net: silence sparse endianness warnings in checksums
Date: Fri,  6 Feb 2015 15:43:52 +0100
Message-ID: <1423233832-8229-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	therbert@google.com, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:42006 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590AbbBFOoX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 09:44:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __skb_checksum_validate_complete and its callers, we only test that
the return value is non-zero, so it's safe to __force the type.

Callers of gso_make_checksum pass a __sum16, use that.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/linux/skbuff.h  | 8 ++++----
 net/ipv4/udp.c          | 4 ++--
 net/ipv6/ip6_checksum.c | 4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 111e665455c3..7b35b4884f58 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3019,7 +3019,7 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 		}
 	} else if (skb->csum_bad) {
 		/* ip_summed == CHECKSUM_NONE in this case */
-		return 1;
+		return (__force __sum16) 1;
 	}
 
 	skb->csum = psum;
@@ -3308,15 +3308,15 @@ static inline int gso_pskb_expand_head(struct sk_buff *skb, int extra)
  * is in the res argument (i.e. normally zero or ~ of checksum of a pseudo
  * header.
  */
-static inline __sum16 gso_make_checksum(struct sk_buff *skb, __wsum res)
+static inline __sum16 gso_make_checksum(struct sk_buff *skb, __sum16 res)
 {
 	int plen = SKB_GSO_CB(skb)->csum_start - skb_headroom(skb) -
 	    skb_transport_offset(skb);
-	__u16 csum;
+	__sum16 csum;
 
 	csum = csum_fold(csum_partial(skb_transport_header(skb),
 				      plen, skb->csum));
-	skb->csum = res;
+	skb->csum = (__force __wsum) res;
 	SKB_GSO_CB(skb)->csum_start -= plen;
 
 	return csum;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 97ef1f8b7be8..1f1ff4eaa34b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1738,8 +1738,8 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 			return err;
 	}
 
-	return skb_checksum_init_zero_check(skb, proto, uh->check,
-					    inet_compute_pseudo);
+	return (__force int)skb_checksum_init_zero_check(skb, proto, uh->check,
+							 inet_compute_pseudo);
 }
 
 /*
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index 9a4d7322fb22..9a1c766a84f0 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -80,8 +80,8 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 	 * for the UDP packet we'll check if that socket allows zero checksum
 	 * for IPv6 (set by socket option).
 	 */
-	return skb_checksum_init_zero_check(skb, proto, uh->check,
-					   ip6_compute_pseudo);
+	return (__force int)skb_checksum_init_zero_check(skb, proto, uh->check,
+							 ip6_compute_pseudo);
 }
 EXPORT_SYMBOL(udp6_csum_init);
 
-- 
2.3.0
