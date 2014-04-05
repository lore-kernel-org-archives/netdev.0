From: Tom Herbert <therbert@google.com>
Subject: [PATCH next-next 4/6] net: Call skb_checksum_init in IPv4
Date: Fri, 4 Apr 2014 17:27:36 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041721170.21628@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:60299 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbaDEAdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:33:09 -0400
Received: by mail-vc0-f201.google.com with SMTP id ik5so598299vcb.2
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:33:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested by running 20 netperf TCP_STREAMs with combinations of
LRO on/off, rx-csum-offload on/off, device provide checksum-complete
(emulated) with occasional incorrect value.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip.h    |  2 ++
 net/ipv4/af_inet.c  |  7 +++++++
 net/ipv4/tcp_ipv4.c | 25 ++-----------------------
 net/ipv4/udp.c      | 19 ++-----------------
 4 files changed, 13 insertions(+), 40 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 25064c2..6929a45 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -337,6 +337,8 @@ static inline void ip_select_ident_more(struct sk_buff *skb, struct dst_entry *d
 		__ip_select_ident(iph, dst, more);
 }
 
+__wsum inet_pseudo_compute(struct sk_buff *skb, int proto);
+
 /*
  *	Map a multicast IP onto multicast MAC for type ethernet.
  */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870..c51b96a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1454,6 +1454,13 @@ out_unlock:
 	return err;
 }
 
+__wsum inet_pseudo_compute(struct sk_buff *skb, int proto)
+{
+	return csum_tcpudp_nofold(ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				  skb->len, proto, 0);
+}
+EXPORT_SYMBOL(inet_pseudo_compute);
+
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 unsigned short type, unsigned char protocol,
 			 struct net *net)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6379894..ab5128c 100644
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
+	if (skb_checksum_init(skb, IPPROTO_TCP, inet_pseudo_compute))
 		goto csum_error;
 
 	th = tcp_hdr(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..d5e3a76 100644
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
+					    inet_pseudo_compute);
 }
 
 /*
-- 
1.9.1.423.g4596e3a
