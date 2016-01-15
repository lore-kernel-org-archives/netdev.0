From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: update skb->csum when CE mark is propagated
Date: Fri, 15 Jan 2016 04:56:56 -0800
Message-ID: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35031 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbcAOM46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 07:56:58 -0500
Received: by mail-pf0-f176.google.com with SMTP id 65so117491387pff.2
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 04:56:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When a tunnel decapsulates the outer header, it has to comply
with RFC 6080 and eventually propagate CE mark into inner header.

It turns out IP6_ECN_set_ce() does not correctly update skb->csum
for CHECKSUM_COMPLETE packets, triggering infamous "hw csum failure"
messages and stack traces.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_ecn.h       |   19 ++++++++++++++++---
 net/ipv6/xfrm6_mode_tunnel.c |    2 +-
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 84b20835b736..0dc0a51da38f 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -111,11 +111,24 @@ static inline void ipv4_copy_dscp(unsigned int dscp, struct iphdr *inner)
 
 struct ipv6hdr;
 
-static inline int IP6_ECN_set_ce(struct ipv6hdr *iph)
+/* Note:
+ * IP_ECN_set_ce() has to tweak IPV4 checksum when setting CE,
+ * meaning both changes have no effect on skb->csum if/when CHECKSUM_COMPLETE
+ * In IPv6 case, no checksum compensates the change in IPv6 header,
+ * so we have to update skb->csum.
+ */
+static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
 {
+	__be32 from, to;
+
 	if (INET_ECN_is_not_ect(ipv6_get_dsfield(iph)))
 		return 0;
-	*(__be32*)iph |= htonl(INET_ECN_CE << 20);
+
+	from = *(__be32 *)iph;
+	to = from | htonl(INET_ECN_CE << 20);
+	*(__be32 *)iph = to;
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(csum_sub(skb->csum, from), to);
 	return 1;
 }
 
@@ -142,7 +155,7 @@ static inline int INET_ECN_set_ce(struct sk_buff *skb)
 	case cpu_to_be16(ETH_P_IPV6):
 		if (skb_network_header(skb) + sizeof(struct ipv6hdr) <=
 		    skb_tail_pointer(skb))
-			return IP6_ECN_set_ce(ipv6_hdr(skb));
+			return IP6_ECN_set_ce(skb, ipv6_hdr(skb));
 		break;
 	}
 
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index f7fbdbabe50e..372855eeaf42 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -23,7 +23,7 @@ static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 	struct ipv6hdr *inner_iph = ipipv6_hdr(skb);
 
 	if (INET_ECN_is_ce(XFRM_MODE_SKB_CB(skb)->tos))
-		IP6_ECN_set_ce(inner_iph);
+		IP6_ECN_set_ce(skb, inner_iph);
 }
 
 /* Add encapsulation header.
