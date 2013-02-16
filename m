From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/4] tunneling: Add generic UDP-Tunnel TSO.
Date: Fri, 15 Feb 2013 17:06:14 -0800
Message-ID: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:55502 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751156Ab3BPBEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:04:32 -0500
Received: by mail-yh0-f69.google.com with SMTP id w68so4877749yhw.8
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:04:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds generic tunneling TCP segment offloading support for IPv4-UDP
based tunnels.
GSO type is added to request this offload for a skb.
netdev feature NETIF_F_UDP_TUNNEL is added for hardware offloaded
udp-tunnel support. Currently no device supports this feature,
software offload is used.

This can be used by tunneling protocols like VXLAN.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdev_features.h |    7 ++-
 include/linux/skbuff.h          |    2 +
 net/ipv4/af_inet.c              |    6 ++-
 net/ipv4/tcp.c                  |    1 +
 net/ipv4/udp.c                  |  113 ++++++++++++++++++++++++++++++---------
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |   10 +++-
 7 files changed, 109 insertions(+), 31 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 3dd3934..6d7c474 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -42,9 +42,9 @@ enum {
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
-	/**/NETIF_F_GSO_LAST,		/* [can't be last bit, see GSO_MASK] */
-	NETIF_F_GSO_RESERVED2		/* ... free (fill GSO_MASK to 8 bits) */
-		= NETIF_F_GSO_LAST,
+	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
+	/**/NETIF_F_GSO_LAST = 		/* last bit, see GSO_MASK */
+		NETIF_F_GSO_UDP_TUNNEL_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
@@ -103,6 +103,7 @@ enum {
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GRE_GSO		__NETIF_F(GSO_GRE)
+#define NETIF_F_UDP_TUNNEL	__NETIF_F(UDP_TUNNEL)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d7f96ff..eb2106f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -316,6 +316,8 @@ enum {
 	SKB_GSO_FCOE = 1 << 5,
 
 	SKB_GSO_GRE = 1 << 6,
+
+	SKB_GSO_UDP_TUNNEL = 1 << 7,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e225a4e..57831a7 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1278,6 +1278,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	int ihl;
 	int id;
 	unsigned int offset = 0;
+	bool tunnel;
 
 	if (!(features & NETIF_F_V4_CSUM))
 		features &= ~NETIF_F_SG;
@@ -1288,6 +1289,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_UDP_TUNNEL |
 		       0)))
 		goto out;
 
@@ -1302,6 +1304,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	if (unlikely(!pskb_may_pull(skb, ihl)))
 		goto out;
 
+	tunnel = !!skb->encapsulation;
+
 	__skb_pull(skb, ihl);
 	skb_reset_transport_header(skb);
 	iph = ip_hdr(skb);
@@ -1321,7 +1325,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	do {
 		iph = ip_hdr(skb);
-		if (proto == IPPROTO_UDP) {
+		if (!tunnel && proto == IPPROTO_UDP) {
 			iph->id = htons(id);
 			iph->frag_off = htons(offset >> 3);
 			if (skb->next != NULL)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7a5ba48..8fe8ee9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3044,6 +3044,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
+			       SKB_GSO_UDP_TUNNEL |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 39a5e7a..9802408 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2272,31 +2272,86 @@ void __init udp_init(void)
 
 int udp4_ufo_send_check(struct sk_buff *skb)
 {
-	const struct iphdr *iph;
-	struct udphdr *uh;
-
-	if (!pskb_may_pull(skb, sizeof(*uh)))
+	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 		return -EINVAL;
 
-	iph = ip_hdr(skb);
-	uh = udp_hdr(skb);
+	if (!skb->encapsulation) {
+		const struct iphdr *iph;
+		struct udphdr *uh;
 
-	uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
-				       IPPROTO_UDP, 0);
-	skb->csum_start = skb_transport_header(skb) - skb->head;
-	skb->csum_offset = offsetof(struct udphdr, check);
-	skb->ip_summed = CHECKSUM_PARTIAL;
+		iph = ip_hdr(skb);
+		uh = udp_hdr(skb);
+
+		uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len,
+				IPPROTO_UDP, 0);
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		skb->ip_summed = CHECKSUM_PARTIAL;
+	}
 	return 0;
 }
 
+static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
+		netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	int mac_len = skb->mac_len;
+	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
+	int outer_hlen;
+
+	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
+		goto out;
+
+	skb->encapsulation = 0;
+	__skb_pull(skb, tnl_hlen);
+	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb_inner_network_offset(skb));
+	skb->mac_len = skb_inner_network_offset(skb);
+
+	/* segment inner packet. */
+	segs = skb_mac_gso_segment(skb, skb->dev->hw_enc_features);
+	if (!segs || IS_ERR(segs))
+		goto out;
+
+	outer_hlen = skb_tnl_header_len(skb);
+	skb = segs;
+	do {
+		struct udphdr *uh;
+		int udp_offset = outer_hlen - tnl_hlen;
+
+		skb->mac_len = mac_len;
+
+		skb_push(skb, outer_hlen);
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb_set_transport_header(skb, udp_offset);
+		uh = udp_hdr(skb);
+		uh->len = htons(skb->len - udp_offset);
+
+		/* csum segment if tunnel sets skb with csum. */
+		if (uh->check) {
+			struct iphdr *iph = ip_hdr(skb);
+
+			uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+						       skb->len - udp_offset,
+						       IPPROTO_UDP, 0);
+			uh->check = csum_fold(skb_checksum(skb, udp_offset,
+							   skb->len - udp_offset, 0));
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+
+		}
+		skb->ip_summed = CHECKSUM_NONE;
+	} while ((skb = skb->next));
+out:
+	return segs;
+}
+
 struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	unsigned int mss;
-	int offset;
-	__wsum csum;
-
 	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
 		goto out;
@@ -2306,6 +2361,7 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		int type = skb_shinfo(skb)->gso_type;
 
 		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
@@ -2316,20 +2372,27 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		goto out;
 	}
 
-	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
-	 * do checksum of UDP packets sent as multiple IP fragments.
-	 */
-	offset = skb_checksum_start_offset(skb);
-	csum = skb_checksum(skb, offset, skb->len - offset, 0);
-	offset += skb->csum_offset;
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-	skb->ip_summed = CHECKSUM_NONE;
-
 	/* Fragment the skb. IP headers of the fragments are updated in
 	 * inet_gso_segment()
 	 */
-	segs = skb_segment(skb, features);
+	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
+		segs = skb_udp_tunnel_segment(skb, features);
+	else {
+		int offset;
+		__wsum csum;
+
+		/* Do software UFO. Complete and fill in the UDP checksum as
+		 * HW cannot do checksum of UDP packets sent as multiple
+		 * IP fragments.
+		 */
+		offset = skb_checksum_start_offset(skb);
+		csum = skb_checksum(skb, offset, skb->len - offset, 0);
+		offset += skb->csum_offset;
+		*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+		skb->ip_summed = CHECKSUM_NONE;
+
+		segs = skb_segment(skb, features);
+	}
 out:
 	return segs;
 }
-
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 8234c1d..e02a65a 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -100,6 +100,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
+		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index cf05cf0..3ced14e 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -21,6 +21,10 @@ static int udp6_ufo_send_check(struct sk_buff *skb)
 	const struct ipv6hdr *ipv6h;
 	struct udphdr *uh;
 
+	/* UDP Tunnel offload on ipv6 is not yet supported. */
+	if (skb->encapsulation)
+		return -EINVAL;
+
 	if (!pskb_may_pull(skb, sizeof(*uh)))
 		return -EINVAL;
 
@@ -56,8 +60,10 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type = skb_shinfo(skb)->gso_type;
 
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
-				      SKB_GSO_GRE) ||
+		if (unlikely(type & ~(SKB_GSO_UDP |
+				      SKB_GSO_DODGY |
+				      SKB_GSO_UDP_TUNNEL |
+ 				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
-- 
1.7.1
