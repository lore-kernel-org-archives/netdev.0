From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 05/11] GSO: Support partial segmentation offload
Date: Thu, 07 Apr 2016 18:32:24 -0400
Message-ID: <20160407223224.11142.80677.stgit@ahduyck-xeon-server>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34384 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863AbcDGWc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:32:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id fe3so62580057pab.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:32:27 -0700 (PDT)
In-Reply-To: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for something I am referring to as GSO partial.
The basic idea is that we can support a broader range of devices for
segmentation if we use fixed outer headers and have the hardware only
really deal with segmenting the inner header.  The idea behind the naming
is due to the fact that everything before csum_start will be fixed headers,
and everything after will be the region that is handled by hardware.

With the current implementation it allows us to add support for the
following GSO types with an inner TSO_FIXEDID or TSO6 offload:
NETIF_F_GSO_GRE
NETIF_F_GSO_GRE_CSUM
NETIF_F_GSO_IPIP
NETIF_F_GSO_SIT
NETIF_F_UDP_TUNNEL
NETIF_F_UDP_TUNNEL_CSUM

In the case of hardware that already supports tunneling we may be able to
extend this further to support TSO_TCPV4 without TSO_FIXEDID if the
hardware can support updating inner IPv4 headers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdev_features.h |    5 +++++
 include/linux/netdevice.h       |    2 ++
 include/linux/skbuff.h          |    9 +++++++--
 net/core/dev.c                  |   31 ++++++++++++++++++++++++++++++-
 net/core/ethtool.c              |    1 +
 net/core/skbuff.c               |   29 ++++++++++++++++++++++++++++-
 net/ipv4/af_inet.c              |   20 ++++++++++++++++----
 net/ipv4/gre_offload.c          |   26 +++++++++++++++++++++-----
 net/ipv4/tcp_offload.c          |   10 ++++++++--
 net/ipv4/udp_offload.c          |   27 +++++++++++++++++++++------
 net/ipv6/ip6_offload.c          |   10 +++++++++-
 11 files changed, 148 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 5d7da1ac6df5..6ef549ec5b13 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -48,6 +48,10 @@ enum {
 	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
+	NETIF_F_GSO_PARTIAL_BIT,	/* ... Only segment inner-most L4
+					 *     in hardware and all other
+					 *     headers in software.
+					 */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
 		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
@@ -122,6 +126,7 @@ enum {
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_TSO_FIXEDID	__NETIF_F(TSO_FIXEDID)
+#define NETIF_F_GSO_PARTIAL	 __NETIF_F(GSO_PARTIAL)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index abf8cc2d9bfb..36a079598034 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1656,6 +1656,7 @@ struct net_device {
 	netdev_features_t	vlan_features;
 	netdev_features_t	hw_enc_features;
 	netdev_features_t	mpls_features;
+	netdev_features_t	gso_partial_features;
 
 	int			ifindex;
 	int			group;
@@ -4023,6 +4024,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_PARTIAL != (NETIF_F_GSO_PARTIAL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5fba16658f9d..da0ace389fec 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -483,7 +483,9 @@ enum {
 
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 12,
 
-	SKB_GSO_TUNNEL_REMCSUM = 1 << 13,
+	SKB_GSO_PARTIAL = 1 << 13,
+
+	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
 };
 
 #if BITS_PER_LONG > 32
@@ -3591,7 +3593,10 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
  * Keeps track of level of encapsulation of network headers.
  */
 struct skb_gso_cb {
-	int	mac_offset;
+	union {
+		int	mac_offset;
+		int	data_offset;
+	};
 	int	encap_level;
 	__wsum	csum;
 	__u16	csum_start;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4ed2852b3706..53b216b617c3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2711,6 +2711,19 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 			return ERR_PTR(err);
 	}
 
+	/* Only report GSO partial support if it will enable us to
+	 * support segmentation on this frame without needing additional
+	 * work.
+	 */
+	if (features & NETIF_F_GSO_PARTIAL) {
+		netdev_features_t partial_features = NETIF_F_GSO_ROBUST;
+		struct net_device *dev = skb->dev;
+
+		partial_features |= dev->features & dev->gso_partial_features;
+		if (!skb_gso_ok(skb, features | partial_features))
+			features &= ~NETIF_F_GSO_PARTIAL;
+	}
+
 	BUILD_BUG_ON(SKB_SGO_CB_OFFSET +
 		     sizeof(*SKB_GSO_CB(skb)) > sizeof(skb->cb));
 
@@ -2841,6 +2854,14 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
+	/* Support for GSO partial features requires software intervention
+	 * before we can actually process the packets so we need to strip
+	 * support for any partial features now and we can pull them back
+	 * in after we have partially segmented the frame.
+	 */
+	if (skb_is_gso(skb) && !(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL))
+		features &= ~dev->gso_partial_features;
+
 	if (skb_vlan_tagged(skb))
 		features = netdev_intersect_features(features,
 						     dev->vlan_features |
@@ -6707,6 +6728,14 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		}
 	}
 
+	/* GSO partial features require GSO partial be set */
+	if ((features & dev->gso_partial_features) &&
+	    !(features & NETIF_F_GSO_PARTIAL)) {
+		netdev_dbg(dev,
+			   "Dropping partially supported GSO features since no GSO partial.\n");
+		features &= ~dev->gso_partial_features;
+	}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	if (dev->netdev_ops->ndo_busy_poll)
 		features |= NETIF_F_BUSY_POLL;
@@ -6987,7 +7016,7 @@ int register_netdevice(struct net_device *dev)
 
 	/* Make NETIF_F_SG inheritable to tunnel devices.
 	 */
-	dev->hw_enc_features |= NETIF_F_SG;
+	dev->hw_enc_features |= NETIF_F_SG | NETIF_F_GSO_PARTIAL;
 
 	/* Make NETIF_F_SG inheritable to MPLS.
 	 */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 5340c9dbc318..005478851118 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -88,6 +88,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
+	[NETIF_F_GSO_PARTIAL_BIT] =	 "tx-gso-partial",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CRC_BIT] =        "tx-checksum-sctp",
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d04c2d1c8c87..4cc594cdaada 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3076,8 +3076,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	struct sk_buff *frag_skb = head_skb;
 	unsigned int offset = doffset;
 	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
+	unsigned int partial_segs = 0;
 	unsigned int headroom;
-	unsigned int len;
+	unsigned int len = head_skb->len;
 	__be16 proto;
 	bool csum;
 	int sg = !!(features & NETIF_F_SG);
@@ -3094,6 +3095,15 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 
 	csum = !!can_checksum_protocol(features, proto);
 
+	/* GSO partial only requires that we trim off any excess that
+	 * doesn't fit into an MSS sized block, so take care of that
+	 * now.
+	 */
+	if (features & NETIF_F_GSO_PARTIAL) {
+		partial_segs = len / mss;
+		mss *= partial_segs;
+	}
+
 	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
 
@@ -3281,6 +3291,23 @@ perform_csum_check:
 	 */
 	segs->prev = tail;
 
+	/* Update GSO info on first skb in partial sequence. */
+	if (partial_segs) {
+		int type = skb_shinfo(head_skb)->gso_type;
+
+		/* Update type to add partial and then remove dodgy if set */
+		type |= SKB_GSO_PARTIAL;
+		type &= ~SKB_GSO_DODGY;
+
+		/* Update GSO info and prepare to start updating headers on
+		 * our way back down the stack of protocols.
+		 */
+		skb_shinfo(segs)->gso_size = skb_shinfo(head_skb)->gso_size;
+		skb_shinfo(segs)->gso_segs = partial_segs;
+		skb_shinfo(segs)->gso_type = type;
+		SKB_GSO_CB(segs)->data_offset = skb_headroom(segs) + doffset;
+	}
+
 	/* Following permits correct backpressure, for protocols
 	 * using skb_set_owner_w().
 	 * Idea is to tranfert ownership from head_skb to last segment.
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 98fe04b99e01..22b03eb07740 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1200,7 +1200,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	const struct net_offload *ops;
 	unsigned int offset = 0;
 	struct iphdr *iph;
-	int proto;
+	int proto, tot_len;
 	int nhoff;
 	int ihl;
 	int id;
@@ -1219,6 +1219,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_TCP_FIXEDID |
 		       SKB_GSO_TUNNEL_REMCSUM |
+		       SKB_GSO_PARTIAL |
 		       0)))
 		goto out;
 
@@ -1273,10 +1274,21 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 			if (skb->next)
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
-		} else if (!fixedid) {
-			iph->id = htons(id++);
+			tot_len = skb->len - nhoff;
+		} else if (skb_is_gso(skb)) {
+			if (!fixedid) {
+				iph->id = htons(id);
+				id += skb_shinfo(skb)->gso_segs;
+			}
+			tot_len = skb_shinfo(skb)->gso_size +
+				  SKB_GSO_CB(skb)->data_offset +
+				  skb->head - (unsigned char *)iph;
+		} else {
+			if (!fixedid)
+				iph->id = htons(id++);
+			tot_len = skb->len - nhoff;
 		}
-		iph->tot_len = htons(skb->len - nhoff);
+		iph->tot_len = htons(tot_len);
 		ip_send_check(iph);
 		if (encap)
 			skb_reset_inner_headers(skb);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 6376b0cdf693..20557f211408 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -36,7 +36,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_GRE |
 				  SKB_GSO_GRE_CSUM |
 				  SKB_GSO_IPIP |
-				  SKB_GSO_SIT)))
+				  SKB_GSO_SIT |
+				  SKB_GSO_PARTIAL)))
 		goto out;
 
 	if (!skb->encapsulation)
@@ -87,7 +88,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	do {
 		struct gre_base_hdr *greh;
-		__be32 *pcsum;
+		__sum16 *pcsum;
 
 		/* Set up inner headers if we are offloading inner checksum */
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -107,10 +108,25 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 			continue;
 
 		greh = (struct gre_base_hdr *)skb_transport_header(skb);
-		pcsum = (__be32 *)(greh + 1);
+		pcsum = (__sum16 *)(greh + 1);
+
+		if (skb_is_gso(skb)) {
+			unsigned int partial_adj;
+
+			/* Adjust checksum to account for the fact that
+			 * the partial checksum is based on actual size
+			 * whereas headers should be based on MSS size.
+			 */
+			partial_adj = skb->len + skb_headroom(skb) -
+				      SKB_GSO_CB(skb)->data_offset -
+				      skb_shinfo(skb)->gso_size;
+			*pcsum = ~csum_fold((__force __wsum)htonl(partial_adj));
+		} else {
+			*pcsum = 0;
+		}
 
-		*pcsum = 0;
-		*(__sum16 *)pcsum = gso_make_checksum(skb, 0);
+		*(pcsum + 1) = 0;
+		*pcsum = gso_make_checksum(skb, 0);
 	} while ((skb = skb->next));
 out:
 	return segs;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index d1ffd55289bd..02737b607aa7 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -109,6 +109,12 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 		goto out;
 	}
 
+	/* GSO partial only requires splitting the frame into an MSS
+	 * multiple and possibly a remainder.  So update the mss now.
+	 */
+	if (features & NETIF_F_GSO_PARTIAL)
+		mss = skb->len - (skb->len % mss);
+
 	copy_destructor = gso_skb->destructor == tcp_wfree;
 	ooo_okay = gso_skb->ooo_okay;
 	/* All segments but the first should have ooo_okay cleared */
@@ -133,7 +139,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
 					       (__force u32)delta));
 
-	do {
+	while (skb->next) {
 		th->fin = th->psh = 0;
 		th->check = newcheck;
 
@@ -153,7 +159,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 
 		th->seq = htonl(seq);
 		th->cwr = 0;
-	} while (skb->next);
+	}
 
 	/* Following permits TCP Small Queues to work well with GSO :
 	 * The callback to TCP stack will be called at the time last frag
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 0ed2dafb7cc4..454e9e70d460 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -51,8 +51,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	 * 16 bit length field due to the header being added outside of an
 	 * IP or IPv6 frame that was already limited to 64K - 1.
 	 */
-	partial = csum_sub(csum_unfold(uh->check),
-			   (__force __wsum)htonl(skb->len));
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL)
+		partial = (__force __wsum)uh->len;
+	else
+		partial = (__force __wsum)htonl(skb->len);
+	partial = csum_sub(csum_unfold(uh->check), partial);
 
 	/* setup inner skb. */
 	skb->encapsulation = 0;
@@ -101,7 +104,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	udp_offset = outer_hlen - tnl_hlen;
 	skb = segs;
 	do {
-		__be16 len;
+		unsigned int len;
 
 		if (remcsum)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -119,14 +122,26 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		skb_reset_mac_header(skb);
 		skb_set_network_header(skb, mac_len);
 		skb_set_transport_header(skb, udp_offset);
-		len = htons(skb->len - udp_offset);
+		len = skb->len - udp_offset;
 		uh = udp_hdr(skb);
-		uh->len = len;
+
+		/* If we are only performing partial GSO the inner header
+		 * will be using a length value equal to only one MSS sized
+		 * segment instead of the entire frame.
+		 */
+		if (skb_is_gso(skb)) {
+			uh->len = htons(skb_shinfo(skb)->gso_size +
+					SKB_GSO_CB(skb)->data_offset +
+					skb->head - (unsigned char *)uh);
+		} else {
+			uh->len = htons(len);
+		}
 
 		if (!need_csum)
 			continue;
 
-		uh->check = ~csum_fold(csum_add(partial, (__force __wsum)len));
+		uh->check = ~csum_fold(csum_add(partial,
+				       (__force __wsum)htonl(len)));
 
 		if (skb->encapsulation || !offload_csum) {
 			uh->check = gso_make_checksum(skb, ~uh->check);
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index e9479499f58c..ad3a6bd4a7f7 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -63,6 +63,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	int proto;
 	struct frag_hdr *fptr;
 	unsigned int unfrag_ip6hlen;
+	unsigned int payload_len;
 	u8 *prevhdr;
 	int offset = 0;
 	bool encap, udpfrag;
@@ -82,6 +83,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
 		       SKB_GSO_TUNNEL_REMCSUM |
+		       SKB_GSO_PARTIAL |
 		       0)))
 		goto out;
 
@@ -118,7 +120,13 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
-		ipv6h->payload_len = htons(skb->len - nhoff - sizeof(*ipv6h));
+		if (skb_is_gso(skb))
+			payload_len = skb_shinfo(skb)->gso_size +
+				      SKB_GSO_CB(skb)->data_offset +
+				      skb->head - (unsigned char *)(ipv6h + 1);
+		else
+			payload_len = skb->len - nhoff - sizeof(*ipv6h);
+		ipv6h->payload_len = htons(payload_len);
 		skb->network_header = (u8 *)ipv6h - skb->head;
 
 		if (udpfrag) {
