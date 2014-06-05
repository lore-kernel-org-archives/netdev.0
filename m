From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 2/7] l2tp: call udp{6}_set_csum
Date: Wed, 4 Jun 2014 17:19:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406041705510.14536@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f202.google.com ([209.85.128.202]:46705 "EHLO
	mail-ve0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432AbaFEAT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 20:19:57 -0400
Received: by mail-ve0-f202.google.com with SMTP id pa12so75259veb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 17:19:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call common functions to set checksum for UDP tunnel.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/l2tp/l2tp_core.c | 54 +++++-----------------------------------------------
 1 file changed, 5 insertions(+), 49 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 3795580..bea2590 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1095,33 +1095,6 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
-				int udp_len)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct udphdr *uh = udp_hdr(skb);
-
-	if (udp_get_no_check6_tx(sk))
-		skb->ip_summed = CHECKSUM_NONE;
-	else if (!skb_dst(skb) || !skb_dst(skb)->dev ||
-	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
-		__wsum csum = skb_checksum(skb, 0, udp_len, 0);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		uh->check = csum_ipv6_magic(&np->saddr, &sk->sk_v6_daddr, udp_len,
-					    IPPROTO_UDP, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-	} else {
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_ipv6_magic(&np->saddr, &sk->sk_v6_daddr,
-					     udp_len, IPPROTO_UDP, 0);
-	}
-}
-#endif
-
 /* If caller requires the skb to have a ppp header, the header must be
  * inserted in the skb data before calling this function.
  */
@@ -1133,7 +1106,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	struct flowi *fl;
 	struct udphdr *uh;
 	struct inet_sock *inet;
-	__wsum csum;
 	int headroom;
 	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	int udp_len;
@@ -1182,33 +1154,17 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		uh->dest = inet->inet_dport;
 		udp_len = uhlen + hdr_len + data_len;
 		uh->len = htons(udp_len);
-		uh->check = 0;
 
 		/* Calculate UDP checksum if configured to do so */
 #if IS_ENABLED(CONFIG_IPV6)
 		if (sk->sk_family == PF_INET6 && !tunnel->v4mapped)
-			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
+			udp6_set_csum(udp_get_no_check6_tx(sk),
+				      skb, &inet6_sk(sk)->saddr,
+				      &sk->sk_v6_daddr, udp_len);
 		else
 #endif
-		if (sk->sk_no_check_tx)
-			skb->ip_summed = CHECKSUM_NONE;
-		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&
-			 (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM))) {
-			skb->ip_summed = CHECKSUM_COMPLETE;
-			csum = skb_checksum(skb, 0, udp_len, 0);
-			uh->check = csum_tcpudp_magic(inet->inet_saddr,
-						      inet->inet_daddr,
-						      udp_len, IPPROTO_UDP, csum);
-			if (uh->check == 0)
-				uh->check = CSUM_MANGLED_0;
-		} else {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_transport_header(skb) - skb->head;
-			skb->csum_offset = offsetof(struct udphdr, check);
-			uh->check = ~csum_tcpudp_magic(inet->inet_saddr,
-						       inet->inet_daddr,
-						       udp_len, IPPROTO_UDP, 0);
-		}
+		udp_set_csum(sk->sk_no_check_tx, skb, inet->inet_saddr,
+			     inet->inet_daddr, udp_len);
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
-- 
2.0.0.526.g5318336
