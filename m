From: Tom Herbert <therbert@google.com>
Subject: [PATCH 6/7] gre: Call gso_make_checksum
Date: Wed, 28 May 2014 21:24:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405282112030.3279@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:43910 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbaE2EYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 00:24:19 -0400
Received: by mail-vc0-f201.google.com with SMTP id ij19so2104397vcb.2
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 21:24:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call gso_make_checksum. This should have the benefit of using a
checksum that may have been previously computed for the packet.

This also adds NETIF_F_GSO_GRE_CSUM to differentiate devices that
offload GRE GSO with and without the GRE checksum offloaed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdev_features.h |  2 ++
 include/linux/skbuff.h          |  2 ++
 include/net/gre.h               |  5 +++--
 net/ipv4/af_inet.c              |  1 +
 net/ipv4/gre_demux.c            |  3 ++-
 net/ipv4/gre_offload.c          | 10 ++++++++--
 net/ipv4/tcp_offload.c          |  1 +
 net/ipv4/udp_offload.c          |  3 ++-
 net/ipv6/ip6_offload.c          |  1 +
 net/ipv6/udp_offload.c          |  1 +
 net/mpls/mpls_gso.c             |  1 +
 11 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index f1338e0..e5a5894 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -42,6 +42,7 @@ enum {
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
+	NETIF_F_GSO_GRE_CSUM_BIT,	/* ... GRE with csum with TSO */
 	NETIF_F_GSO_IPIP_BIT,		/* ... IPIP tunnel with TSO */
 	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
@@ -112,6 +113,7 @@ enum {
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
+#define NETIF_F_GSO_GRE_CSUM	__NETIF_F(GSO_GRE_CSUM)
 #define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5a6d10a..c705808 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -347,6 +347,8 @@ enum {
 	SKB_GSO_MPLS = 1 << 10,
 
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
+
+	SKB_GSO_GRE_CSUM = 1 << 12,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/include/net/gre.h b/include/net/gre.h
index 70046a0..b531820 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -37,9 +37,10 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		      int hdr_len);
 
 static inline struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
-						  bool gre_csum)
+						  bool csum)
 {
-	return iptunnel_handle_offloads(skb, gre_csum, SKB_GSO_GRE);
+	return iptunnel_handle_offloads(skb, csum,
+					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
 
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0070ab8..d5e6836 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1254,6 +1254,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_GRE_CSUM |
 		       SKB_GSO_IPIP |
 		       SKB_GSO_SIT |
 		       SKB_GSO_TCPV6 |
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index fbfd829..4e9619b 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -84,7 +84,8 @@ void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			ptr--;
 		}
 		if (tpi->flags&TUNNEL_CSUM &&
-		    !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
+		    !(skb_shinfo(skb)->gso_type &
+		      (SKB_GSO_GRE|SKB_GSO_GRE_CSUM))) {
 			*ptr = 0;
 			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
 								 skb->len, 0));
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index f1d3228..24deb39 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -42,6 +42,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_DODGY |
 				  SKB_GSO_TCP_ECN |
 				  SKB_GSO_GRE |
+				  SKB_GSO_GRE_CSUM |
 				  SKB_GSO_IPIP)))
 		goto out;
 
@@ -55,6 +56,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		goto out;
 
 	csum = !!(greh->flags & GRE_CSUM);
+	if (csum)
+		skb->encap_hdr_csum = 1;
 
 	if (unlikely(!pskb_may_pull(skb, ghl)))
 		goto out;
@@ -94,10 +97,13 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				}
 			}
 
-			greh = (struct gre_base_hdr *)(skb->data);
+			skb_reset_transport_header(skb);
+
+			greh = (struct gre_base_hdr *)
+			    skb_transport_header(skb);
 			pcsum = (__be32 *)(greh + 1);
 			*pcsum = 0;
-			*(__sum16 *)pcsum = csum_fold(skb_checksum(skb, 0, skb->len, 0));
+			*(__sum16 *)pcsum = gso_make_checksum(skb, 0);
 		}
 		__skb_push(skb, tnl_hlen - ghl);
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index c02f2d2..4e86c59 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -57,6 +57,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
+			       SKB_GSO_GRE_CSUM |
 			       SKB_GSO_IPIP |
 			       SKB_GSO_SIT |
 			       SKB_GSO_MPLS |
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 5c23f47..7b18401 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -74,7 +74,8 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_UDP_TUNNEL_CSUM |
 				      SKB_GSO_IPIP |
-				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
+				      SKB_GSO_GRE | SKB_GSO_GRE_CSUM |
+				      SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index d54c574..65eda2a 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -97,6 +97,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_GRE_CSUM |
 		       SKB_GSO_IPIP |
 		       SKB_GSO_SIT |
 		       SKB_GSO_UDP_TUNNEL |
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 79da8b3..0ae3d98 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -65,6 +65,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_UDP_TUNNEL_CSUM |
 				      SKB_GSO_GRE |
+				      SKB_GSO_GRE_CSUM |
 				      SKB_GSO_IPIP |
 				      SKB_GSO_SIT |
 				      SKB_GSO_MPLS) ||
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 851cd88..6b38d08 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -33,6 +33,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_DODGY |
 				  SKB_GSO_TCP_ECN |
 				  SKB_GSO_GRE |
+				  SKB_GSO_GRE_CSUM |
 				  SKB_GSO_IPIP |
 				  SKB_GSO_MPLS)))
 		goto out;
-- 
1.9.1.423.g4596e3a
