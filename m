From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 1/5] udp: Generalize skb_udp_segment
Date: Mon, 29 Sep 2014 20:22:29 -0700
Message-ID: <1412047353-28502-2-git-send-email-therbert@google.com>
References: <1412047353-28502-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36821 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbaI3DWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 23:22:53 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so5540927pab.5
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 20:22:52 -0700 (PDT)
In-Reply-To: <1412047353-28502-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_udp_segment is the function called from udp4_ufo_fragment to
segment a UDP tunnel packet. This function currently assumes
segmentation is transparent Ethernet bridging (i.e. VXLAN
encapsulation). This patch generalizes the function to
operate on either Ethertype or IP protocol.

The inner_protocol field must be set to the protocol of the inner
header. This can now be either an Ethertype or an IP protocol
(in a union). A new flag in the skbuff indicates which type is
effective. skb_set_inner_protocol and skb_set_inner_ipproto
helper functions were added to set the inner_protocol. These
functions are called from the point where the tunnel encapsulation
is occuring.

When skb_udp_tunnel_segment is called, the function to segment the
inner packet is selected based on the inner IP or Ethertype. In the
case of an IP protocol encapsulation, the function is derived from
inet[6]_offloads. In the case of Ethertype, skb->protocol is
set to the inner_protocol and skb_mac_gso_segment is called. (GRE
currently does this, but it might be possible to lookup the protocol
in offload_base and call the appropriate segmenation function
directly).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 26 +++++++++++++++++++++++--
 include/net/udp.h      |  3 ++-
 net/ipv4/udp_offload.c | 51 +++++++++++++++++++++++++++++++++++++++++++++-----
 net/ipv6/udp_offload.c |  2 +-
 4 files changed, 73 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 262efdb..49bc464 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -596,7 +596,8 @@ struct sk_buff {
 	__u8			ndisc_nodetype:2;
 #endif
 	__u8			ipvs_property:1;
-	/* 5 or 7 bit hole */
+	__u8			inner_protocol_type:1;
+	/* 4 or 6 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
@@ -632,7 +633,11 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
-	__be16			inner_protocol;
+	union {
+		__be16		inner_protocol;
+		__u8		inner_ipproto;
+	};
+
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
 	__u16			inner_mac_header;
@@ -1737,6 +1742,23 @@ static inline void skb_reserve(struct sk_buff *skb, int len)
 	skb->tail += len;
 }
 
+#define ENCAP_TYPE_ETHER	0
+#define ENCAP_TYPE_IPPROTO	1
+
+static inline void skb_set_inner_protocol(struct sk_buff *skb,
+					  __be16 protocol)
+{
+	skb->inner_protocol = protocol;
+	skb->inner_protocol_type = ENCAP_TYPE_ETHER;
+}
+
+static inline void skb_set_inner_ipproto(struct sk_buff *skb,
+					 __u8 ipproto)
+{
+	skb->inner_ipproto = ipproto;
+	skb->inner_protocol_type = ENCAP_TYPE_IPPROTO;
+}
+
 static inline void skb_reset_inner_headers(struct sk_buff *skb)
 {
 	skb->inner_mac_header = skb->mac_header;
diff --git a/include/net/udp.h b/include/net/udp.h
index 16f4e80..07f9b70 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -239,7 +239,8 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 int udp_disconnect(struct sock *sk, int flags);
 unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
 struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
-				       netdev_features_t features);
+				       netdev_features_t features,
+				       bool is_ipv6);
 int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, int __user *optlen);
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 19ebe6a..8c35f2c 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -25,8 +25,11 @@ struct udp_offload_priv {
 	struct udp_offload_priv __rcu *next;
 };
 
-struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
-				       netdev_features_t features)
+static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
+	netdev_features_t features,
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features),
+	__be16 new_protocol)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	u16 mac_offset = skb->mac_header;
@@ -48,7 +51,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
-	skb->protocol = htons(ETH_P_TEB);
+	skb->protocol = new_protocol;
 
 	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
 	if (need_csum)
@@ -56,7 +59,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
-	segs = skb_mac_gso_segment(skb, enc_features);
+	segs = gso_inner_segment(skb, enc_features);
 	if (IS_ERR_OR_NULL(segs)) {
 		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
 				     mac_len);
@@ -101,6 +104,44 @@ out:
 	return segs;
 }
 
+struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
+				       netdev_features_t features,
+				       bool is_ipv6)
+{
+	__be16 protocol = skb->protocol;
+	const struct net_offload **offloads;
+	const struct net_offload *ops;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features);
+
+	rcu_read_lock();
+
+	switch (skb->inner_protocol_type) {
+	case ENCAP_TYPE_ETHER:
+		protocol = skb->inner_protocol;
+		gso_inner_segment = skb_mac_gso_segment;
+		break;
+	case ENCAP_TYPE_IPPROTO:
+		offloads = is_ipv6 ? inet6_offloads : inet_offloads;
+		ops = rcu_dereference(offloads[skb->inner_ipproto]);
+		if (!ops || !ops->callbacks.gso_segment)
+			goto out_unlock;
+		gso_inner_segment = ops->callbacks.gso_segment;
+		break;
+	default:
+		goto out_unlock;
+	}
+
+	segs = __skb_udp_tunnel_segment(skb, features, gso_inner_segment,
+					protocol);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return segs;
+}
+
 static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 					 netdev_features_t features)
 {
@@ -113,7 +154,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	if (skb->encapsulation &&
 	    (skb_shinfo(skb)->gso_type &
 	     (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))) {
-		segs = skb_udp_tunnel_segment(skb, features);
+		segs = skb_udp_tunnel_segment(skb, features, false);
 		goto out;
 	}
 
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 212ebfc..8f96988 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -58,7 +58,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 
 	if (skb->encapsulation && skb_shinfo(skb)->gso_type &
 	    (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))
-		segs = skb_udp_tunnel_segment(skb, features);
+		segs = skb_udp_tunnel_segment(skb, features, true);
 	else {
 		const struct ipv6hdr *ipv6h;
 		struct udphdr *uh;
-- 
2.1.0.rc2.206.gedb03e5
