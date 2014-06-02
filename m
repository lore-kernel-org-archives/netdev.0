From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 5/7] net: Add GSO support for UDP tunnels with checksum
Date: Sun, 1 Jun 2014 21:01:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406012049500.13379@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:49947 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaFBEBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:01:40 -0400
Received: by mail-oa0-f74.google.com with SMTP id m1so871359oag.5
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 21:01:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added a new netif feature for GSO_UDP_TUNNEL_CSUM. This indicates
that a device is capable of computing the UDP checksum in the
encapsulating header of a UDP tunnel.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdev_features.h |  1 +
 include/linux/skbuff.h          |  2 ++
 net/ipv4/af_inet.c              |  1 +
 net/ipv4/tcp_offload.c          |  1 +
 net/ipv4/udp.c                  | 40 +++++++++++++++++++---------------------
 net/ipv4/udp_offload.c          |  4 +++-
 net/ipv6/ip6_offload.c          |  1 +
 net/ipv6/udp_offload.c          |  4 +++-
 8 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index c26d0ec..f1338e0 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -45,6 +45,7 @@ enum {
 	NETIF_F_GSO_IPIP_BIT,		/* ... IPIP tunnel with TSO */
 	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
+	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
 		NETIF_F_GSO_MPLS_BIT,
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d8d397a..5a6d10a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -345,6 +345,8 @@ enum {
 	SKB_GSO_UDP_TUNNEL = 1 << 9,
 
 	SKB_GSO_MPLS = 1 << 10,
+
+	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0e9bb08..0070ab8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1258,6 +1258,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_SIT |
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
+		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_MPLS |
 		       0)))
 		goto out;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index d8de7b9..c02f2d2 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -61,6 +61,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_SIT |
 			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
+			       SKB_GSO_UDP_TUNNEL_CSUM |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e07d52b..faf5e6a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2491,7 +2491,11 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
 	netdev_features_t enc_features;
-	int outer_hlen;
+	int udp_offset, outer_hlen;
+	unsigned int oldlen;
+	bool need_csum;
+
+	oldlen = (u16)~skb->len;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
@@ -2503,6 +2507,10 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = htons(ETH_P_TEB);
 
+	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
+	if (need_csum)
+		skb->encap_hdr_csum = 1;
+
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
@@ -2513,10 +2521,11 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	}
 
 	outer_hlen = skb_tnl_header_len(skb);
+	udp_offset = outer_hlen - tnl_hlen;
 	skb = segs;
 	do {
 		struct udphdr *uh;
-		int udp_offset = outer_hlen - tnl_hlen;
+		int len;
 
 		skb_reset_inner_headers(skb);
 		skb->encapsulation = 1;
@@ -2527,31 +2536,20 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 		skb_reset_mac_header(skb);
 		skb_set_network_header(skb, mac_len);
 		skb_set_transport_header(skb, udp_offset);
+		len = skb->len - udp_offset;
 		uh = udp_hdr(skb);
-		uh->len = htons(skb->len - udp_offset);
-
-		/* csum segment if tunnel sets skb with csum. */
-		if (protocol == htons(ETH_P_IP) && unlikely(uh->check)) {
-			struct iphdr *iph = ip_hdr(skb);
+		uh->len = htons(len);
 
-			uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-						       skb->len - udp_offset,
-						       IPPROTO_UDP, 0);
-			uh->check = csum_fold(skb_checksum(skb, udp_offset,
-							   skb->len - udp_offset, 0));
-			if (uh->check == 0)
-				uh->check = CSUM_MANGLED_0;
+		if (need_csum) {
+			__be32 delta = htonl(oldlen + len);
 
-		} else if (protocol == htons(ETH_P_IPV6)) {
-			struct ipv6hdr *ipv6h = ipv6_hdr(skb);
-			u32 len = skb->len - udp_offset;
+			uh->check = ~csum_fold((__force __wsum)
+					       ((__force u32)uh->check +
+						(__force u32)delta));
+			uh->check = gso_make_checksum(skb, ~uh->check);
 
-			uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
-						     len, IPPROTO_UDP, 0);
-			uh->check = csum_fold(skb_checksum(skb, udp_offset, len, 0));
 			if (uh->check == 0)
 				uh->check = CSUM_MANGLED_0;
-			skb->ip_summed = CHECKSUM_NONE;
 		}
 
 		skb->protocol = protocol;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 88b4023..5c23f47 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -56,7 +56,8 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	__wsum csum;
 
 	if (skb->encapsulation &&
-	    skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) {
+	    (skb_shinfo(skb)->gso_type &
+	     (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))) {
 		segs = skb_udp_tunnel_segment(skb, features);
 		goto out;
 	}
@@ -71,6 +72,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 
 		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
+				      SKB_GSO_UDP_TUNNEL_CSUM |
 				      SKB_GSO_IPIP |
 				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index b2f0915..d54c574 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -100,6 +100,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_IPIP |
 		       SKB_GSO_SIT |
 		       SKB_GSO_UDP_TUNNEL |
+		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
 		       0)))
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index b261ee8..79da8b3 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -63,6 +63,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		if (unlikely(type & ~(SKB_GSO_UDP |
 				      SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
+				      SKB_GSO_UDP_TUNNEL_CSUM |
 				      SKB_GSO_GRE |
 				      SKB_GSO_IPIP |
 				      SKB_GSO_SIT |
@@ -76,7 +77,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		goto out;
 	}
 
-	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
+	if (skb->encapsulation && skb_shinfo(skb)->gso_type &
+	    (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))
 		segs = skb_udp_tunnel_segment(skb, features);
 	else {
 		/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
-- 
1.9.1.423.g4596e3a
