From: Tom Herbert <therbert@google.com>
Subject: [PATCH 6/9 v2] net: Call skb_checksum_init in IPv4
Date: Sat, 26 Apr 2014 14:25:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261401050.26921@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:35865 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaDZVZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:25:45 -0400
Received: by mail-qa0-f74.google.com with SMTP id w8so811259qac.3
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:25:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_checksum_init instead of private functions.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h    |  6 ++++++
 net/ipv4/tcp_ipv4.c | 25 ++-----------------------
 net/ipv4/udp.c      | 19 ++-----------------
 3 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 3ec2b0f..1988cef 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -342,6 +342,12 @@ static inline void ip_select_ident_more(struct sk_buff *skb, struct dst_entry *d
 		__ip_select_ident(iph, dst, more);
 }
 
+static inline __wsum inet_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	return csum_tcpudp_nofold(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				  skb->len, proto, 0);
+}
+
 /*
  *	Map a multicast IP onto multicast MAC for type ethernet.
  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 438f3b9..ad166dc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1744,28 +1744,6 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	return sk;
 }
 
-static __sum16 tcp_v4_checksum_init(struct sk_buff *skb)
-{
-	const struct iphdr *iph = ip_hdr(skb);
-
-	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!tcp_v4_check(skb->len, iph->saddr,
-				  iph->daddr, skb->csum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			return 0;
-		}
-	}
-
-	skb->csum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
-				       skb->len, IPPROTO_TCP, 0);
-
-	if (skb->len <= 76) {
-		return __skb_checksum_complete(skb);
-	}
-	return 0;
-}
-
-
 /* The socket must have it's spinlock held when we get
  * here.
  *
@@ -1960,7 +1938,8 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	 * Packet length and doff are validated by header prediction,
 	 * provided case of th->doff==0 is eliminated.
 	 * So, we defer the checks. */
-	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
+
+	if (skb_checksum_init(skb, IPPROTO_TCP, inet_compute_pseudo))
 		goto csum_error;
 
 	th = tcp_hdr(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..f2d05d7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1672,7 +1672,6 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 				 int proto)
 {
-	const struct iphdr *iph;
 	int err;
 
 	UDP_SKB_CB(skb)->partial_cov = 0;
@@ -1684,22 +1683,8 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 			return err;
 	}
 
-	iph = ip_hdr(skb);
-	if (uh->check == 0) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
-				      proto, skb->csum))
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
-	if (!skb_csum_unnecessary(skb))
-		skb->csum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
-					       skb->len, proto, 0);
-	/* Probably, we should checksum udp header (it should be in cache
-	 * in any case) and data in tiny packets (< rx copybreak).
-	 */
-
-	return 0;
+	return skb_checksum_init_zero_check(skb, proto, uh->check,
+					    inet_compute_pseudo);
 }
 
 /*
-- 
1.9.1.423.g4596e3a
