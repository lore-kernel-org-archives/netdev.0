From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 8/8] tou: Support for GSO
Date: Thu, 16 Jun 2016 10:52:02 -0700
Message-ID: <1466099522-690741-9-git-send-email-tom@herbertland.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59264 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755188AbcFPRwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:31 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHpiUZ005853
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kyrn8bg9-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:30 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 18590fbe33eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:30 -0700
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SKB_GSO_TOU. In udp[64]_ufo_fragment check for SKB_GSO_TOU. If this
is set call skb_udp_tou_segment. skb_udp_tou_segment is very similar
to skb_udp_tunnel_segment except that we only need to deal with the
L4 headers.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdev_features.h  |   3 +-
 include/linux/netdevice.h        |   1 +
 include/linux/skbuff.h           |   2 +-
 include/net/udp.h                |   2 +
 net/ipv4/fou.c                   |   2 +
 net/ipv4/ip_output.c             |   2 +
 net/ipv4/udp_offload.c           | 163 +++++++++++++++++++++++++++++++++++++--
 net/ipv6/inet6_connection_sock.c |   3 +
 net/ipv6/udp_offload.c           | 128 +++++++++++++++---------------
 9 files changed, 237 insertions(+), 69 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index ab15c6a..ffc4e0a 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -37,7 +37,7 @@ enum {
 	NETIF_F_TSO_BIT			/* ... TCPv4 segmentation */
 		= NETIF_F_GSO_SHIFT,
 	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
-	NETIF_F_GSO_RSVD,		/* ... Reserved */
+	NETIF_F_GSO_TOU_BIT,		/* ... Transports over UDP */
 	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
 	NETIF_F_TSO_MANGLEID_BIT,	/* ... IPV4 ID mangling allowed */
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
@@ -131,6 +131,7 @@ enum {
 #define NETIF_F_GSO_PARTIAL	 __NETIF_F(GSO_PARTIAL)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
 #define NETIF_F_GSO_SCTP	__NETIF_F(GSO_SCTP)
+#define NETIF_F_GSO_TOU		__NETIF_F(GSO_TOU)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5969028..624d169 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4023,6 +4023,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_TOU     != (NETIF_F_GSO_TOU >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_FIXEDID != (NETIF_F_TSO_MANGLEID >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index be34e06..9f85a7d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -463,7 +463,7 @@ enum {
 	SKB_GSO_TCPV4 = 1 << 0,
 	SKB_GSO_UDP = 1 << 1,
 
-	SKB_GSO_RSVD = 1 << 2,
+	SKB_GSO_TOU = 1 << 2,
 
 	/* This indicates the tcp segment has CWR set. */
 	SKB_GSO_TCP_ECN = 1 << 3,
diff --git a/include/net/udp.h b/include/net/udp.h
index 8894d71..48b767f 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -262,6 +262,8 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				       netdev_features_t features,
 				       bool is_ipv6);
+struct sk_buff *skb_udp_tou_segment(struct sk_buff *skb,
+				    netdev_features_t features, bool is_ipv6);
 int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, int __user *optlen);
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 9cd9168..3cdc060 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -435,6 +435,8 @@ next_proto:
 	/* Flag this frame as already having an outer encap header */
 	NAPI_GRO_CB(skb)->is_fou = 1;
 
+	skb_set_transport_header(skb, skb_gro_offset(skb));
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 11cf4de..090cede 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -410,6 +410,8 @@ int ip_queue_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl)
 			res = -EINVAL;
 			goto fail;
 		}
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TOU;
+		skb_set_inner_ipproto(skb, sk->sk_protocol);
 	} else {
 		dport = inet->inet_dport;
 		sport = inet->inet_sport;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 81f253b..8e56a21 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -184,6 +184,155 @@ out_unlock:
 }
 EXPORT_SYMBOL(skb_udp_tunnel_segment);
 
+/* __skb_udp_tou_segment
+ *
+ * Handle segmentation of TOU (Transports Protocols over UDP). Note that this
+ * is very similar __skb_udp_tunnel_segment however here we don't need to
+ * deal with MAC or nework layers. Everything is done base on transport
+ * headers only.
+ */
+static struct sk_buff *__skb_udp_tou_segment(struct sk_buff *skb,
+	netdev_features_t features,
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features),
+	bool is_ipv6)
+{
+	int tnl_hlen = skb_inner_transport_header(skb) -
+		       skb_transport_header(skb);
+	bool remcsum, need_csum, offload_csum, ufo;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct udphdr *uh = udp_hdr(skb);
+	__wsum partial;
+
+	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
+		goto out;
+
+	/* Adjust partial header checksum to negate old length.
+	 * We cannot rely on the value contained in uh->len as it is
+	 * possible that the actual value exceeds the boundaries of the
+	 * 16 bit length field due to the header being added outside of an
+	 * IP or IPv6 frame that was already limited to 64K - 1.
+	 */
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL)
+		partial = (__force __wsum)uh->len;
+	else
+		partial = (__force __wsum)htonl(skb->len);
+	partial = csum_sub(csum_unfold(uh->check), partial);
+
+	/* Setup inner skb. Only the transport header is relevant */
+	skb->encapsulation = 0;
+	SKB_GSO_CB(skb)->encap_level = 0;
+	__skb_pull(skb, tnl_hlen);
+	skb_reset_transport_header(skb);
+
+	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
+	skb->encap_hdr_csum = need_csum;
+
+	remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
+	skb->remcsum_offload = remcsum;
+
+	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
+
+	/* Try to offload checksum if possible */
+	offload_csum = !!(need_csum &&
+			  (skb->dev->features &
+			   (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
+				      (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
+
+	features &= skb->dev->hw_enc_features;
+
+	/* The only checksum offload we care about from here on out is the
+	 * outer one so strip the existing checksum feature flags and
+	 * instead set the flag based on our outer checksum offload value.
+	 */
+	if (remcsum || ufo) {
+		features &= ~NETIF_F_CSUM_MASK;
+		if (!need_csum || offload_csum)
+			features |= NETIF_F_HW_CSUM;
+	}
+
+	/* segment inner packet. */
+	segs = gso_inner_segment(skb, features);
+	if (IS_ERR_OR_NULL(segs)) {
+		skb->encapsulation = 1;
+		skb_push(skb, tnl_hlen);
+		skb_reset_transport_header(skb);
+
+		goto out;
+	}
+
+	skb = segs;
+	do {
+		unsigned int len;
+
+		if (remcsum)
+			skb->ip_summed = CHECKSUM_NONE;
+
+		/* Adjust transport header back to UDP header */
+
+		skb->transport_header -= tnl_hlen;
+		uh = udp_hdr(skb);
+		len = skb->len - ((unsigned char *)uh - skb->data);
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
+
+		if (!need_csum)
+			continue;
+
+		uh->check = ~csum_fold(csum_add(partial,
+				       (__force __wsum)htonl(len)));
+
+		if (skb->encapsulation || !offload_csum) {
+			uh->check = gso_make_checksum(skb, ~uh->check);
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+		} else {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_transport_header(skb) - skb->head;
+			skb->csum_offset = offsetof(struct udphdr, check);
+		}
+	} while ((skb = skb->next));
+out:
+	return segs;
+}
+
+struct sk_buff *skb_udp_tou_segment(struct sk_buff *skb,
+				    netdev_features_t features,
+				    bool is_ipv6)
+{
+	const struct net_offload **offloads;
+	const struct net_offload *ops;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features);
+
+	rcu_read_lock();
+
+	offloads = is_ipv6 ? inet6_offloads : inet_offloads;
+	ops = rcu_dereference(offloads[skb->inner_ipproto]);
+	if (!ops || !ops->callbacks.gso_segment)
+		goto out_unlock;
+	gso_inner_segment = ops->callbacks.gso_segment;
+
+	segs = __skb_udp_tou_segment(skb, features, gso_inner_segment, is_ipv6);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return segs;
+}
+EXPORT_SYMBOL(skb_udp_tou_segment);
+
 static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 					 netdev_features_t features)
 {
@@ -193,11 +342,15 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	struct udphdr *uh;
 	struct iphdr *iph;
 
-	if (skb->encapsulation &&
-	    (skb_shinfo(skb)->gso_type &
-	     (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))) {
-		segs = skb_udp_tunnel_segment(skb, features, false);
-		goto out;
+	if (skb->encapsulation) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TOU) {
+			segs = skb_udp_tou_segment(skb, features, false);
+			goto out;
+		} else if ((skb_shinfo(skb)->gso_type &
+		    (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP_TUNNEL_CSUM))) {
+			segs = skb_udp_tunnel_segment(skb, features, false);
+			goto out;
+		}
 	}
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 6c971bc..7b3978a 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -189,6 +189,9 @@ int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl_unused
 			goto fail;
 		}
 
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TOU;
+		skb_set_inner_ipproto(skb, sk->sk_protocol);
+
 		/* Changing ports and protocol to be routed */
 		fl6.fl6_sport = e->sport;
 		fl6.fl6_dport = e->dport;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index ac858c4..b53486b 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -29,6 +29,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 	u8 frag_hdr_sz = sizeof(struct frag_hdr);
 	__wsum csum;
 	int tnl_hlen;
+	const struct ipv6hdr *ipv6h;
+	struct udphdr *uh;
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
@@ -47,74 +49,76 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		goto out;
 	}
 
-	if (skb->encapsulation && skb_shinfo(skb)->gso_type &
-	    (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))
-		segs = skb_udp_tunnel_segment(skb, features, true);
-	else {
-		const struct ipv6hdr *ipv6h;
-		struct udphdr *uh;
-
-		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+	if (skb->encapsulation) {
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TOU) {
+			segs = skb_udp_tou_segment(skb, features, true);
+			goto out;
+		} else if (skb_shinfo(skb)->gso_type &
+			   (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP_TUNNEL_CSUM)) {
+			segs = skb_udp_tunnel_segment(skb, features, true);
 			goto out;
-
-		/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
-		 * do checksum of UDP packets sent as multiple IP fragments.
-		 */
-
-		uh = udp_hdr(skb);
-		ipv6h = ipv6_hdr(skb);
-
-		uh->check = 0;
-		csum = skb_checksum(skb, 0, skb->len, 0);
-		uh->check = udp_v6_check(skb->len, &ipv6h->saddr,
-					  &ipv6h->daddr, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		skb->ip_summed = CHECKSUM_NONE;
-
-		/* If there is no outer header we can fake a checksum offload
-		 * due to the fact that we have already done the checksum in
-		 * software prior to segmenting the frame.
-		 */
-		if (!skb->encap_hdr_csum)
-			features |= NETIF_F_HW_CSUM;
-
-		/* Check if there is enough headroom to insert fragment header. */
-		tnl_hlen = skb_tnl_header_len(skb);
-		if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
-			if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
-				goto out;
 		}
+	}
 
-		/* Find the unfragmentable header and shift it left by frag_hdr_sz
-		 * bytes to insert fragment header.
-		 */
-		unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
-		nexthdr = *prevhdr;
-		*prevhdr = NEXTHDR_FRAGMENT;
-		unfrag_len = (skb_network_header(skb) - skb_mac_header(skb)) +
-			     unfrag_ip6hlen + tnl_hlen;
-		packet_start = (u8 *) skb->head + SKB_GSO_CB(skb)->mac_offset;
-		memmove(packet_start-frag_hdr_sz, packet_start, unfrag_len);
-
-		SKB_GSO_CB(skb)->mac_offset -= frag_hdr_sz;
-		skb->mac_header -= frag_hdr_sz;
-		skb->network_header -= frag_hdr_sz;
-
-		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
-		fptr->nexthdr = nexthdr;
-		fptr->reserved = 0;
-		if (!skb_shinfo(skb)->ip6_frag_id)
-			ipv6_proxy_select_ident(dev_net(skb->dev), skb);
-		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
+	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
+		goto out;
 
-		/* Fragment the skb. ipv6 header and the remaining fields of the
-		 * fragment header are updated in ipv6_gso_segment()
-		 */
-		segs = skb_segment(skb, features);
+	/* Do software UFO. Complete and fill in the UDP checksum as HW cannot
+	 * do checksum of UDP packets sent as multiple IP fragments.
+	 */
+
+	uh = udp_hdr(skb);
+	ipv6h = ipv6_hdr(skb);
+
+	uh->check = 0;
+	csum = skb_checksum(skb, 0, skb->len, 0);
+	uh->check = udp_v6_check(skb->len, &ipv6h->saddr,
+				  &ipv6h->daddr, csum);
+	if (uh->check == 0)
+		uh->check = CSUM_MANGLED_0;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* If there is no outer header we can fake a checksum offload
+	 * due to the fact that we have already done the checksum in
+	 * software prior to segmenting the frame.
+	 */
+	if (!skb->encap_hdr_csum)
+		features |= NETIF_F_HW_CSUM;
+
+	/* Check if there is enough headroom to insert fragment header. */
+	tnl_hlen = skb_tnl_header_len(skb);
+	if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
+		if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
+			goto out;
 	}
 
+	/* Find the unfragmentable header and shift it left by frag_hdr_sz
+	 * bytes to insert fragment header.
+	 */
+	unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
+	nexthdr = *prevhdr;
+	*prevhdr = NEXTHDR_FRAGMENT;
+	unfrag_len = (skb_network_header(skb) - skb_mac_header(skb)) +
+		     unfrag_ip6hlen + tnl_hlen;
+	packet_start = (u8 *)skb->head + SKB_GSO_CB(skb)->mac_offset;
+	memmove(packet_start - frag_hdr_sz, packet_start, unfrag_len);
+
+	SKB_GSO_CB(skb)->mac_offset -= frag_hdr_sz;
+	skb->mac_header -= frag_hdr_sz;
+	skb->network_header -= frag_hdr_sz;
+
+	fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
+	fptr->nexthdr = nexthdr;
+	fptr->reserved = 0;
+	if (!skb_shinfo(skb)->ip6_frag_id)
+		ipv6_proxy_select_ident(dev_net(skb->dev), skb);
+	fptr->identification = skb_shinfo(skb)->ip6_frag_id;
+
+	/* Fragment the skb. ipv6 header and the remaining fields of the
+	 * fragment header are updated in ipv6_gso_segment()
+	 */
+	segs = skb_segment(skb, features);
 out:
 	return segs;
 }
-- 
2.8.0.rc2
