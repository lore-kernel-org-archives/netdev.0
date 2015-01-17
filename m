From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 2/2] vxlan: Eliminate dependency on UDP socket in transmit path
Date: Sat, 17 Jan 2015 10:18:20 -0800
Message-ID: <1421518700-22460-3-git-send-email-therbert@google.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:64480 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbAQSSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 13:18:47 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so8125358iga.1
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 10:18:47 -0800 (PST)
In-Reply-To: <1421518700-22460-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the vxlan transmit path there is no need to reference the socket
for a tunnel which is needed for the receive side. We do, however,
need the vxlan_dev flags. This patch eliminate references
to the socket in the transmit path, and changes VXLAN_F_UNSHAREABLE
to be VXLAN_F_RCV_FLAGS. This mask is used to store the flags
applicable to receive (GBP, CSUM6_RX, and REMCSUM_RX) in the
vxlan_sock flags.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c           | 60 ++++++++++++++++++++-----------------------
 include/net/vxlan.h           | 13 ++++++----
 net/openvswitch/vport-vxlan.c |  6 ++---
 3 files changed, 38 insertions(+), 41 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4fb4205..fb7805b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -270,12 +270,13 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
 					  __be16 port, u32 flags)
 {
 	struct vxlan_sock *vs;
-	u32 match_flags = flags & VXLAN_F_UNSHAREABLE;
+
+	flags &= VXLAN_F_RCV_FLAGS;
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
 		if (inet_sk(vs->sock->sk)->inet_sport == port &&
 		    inet_sk(vs->sock->sk)->sk.sk_family == family &&
-		    (vs->flags & VXLAN_F_UNSHAREABLE) == match_flags)
+		    vs->flags == flags)
 			return vs;
 	}
 	return NULL;
@@ -1668,7 +1669,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, struct vxlan_sock *vs,
+static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 				struct vxlan_metadata *md)
 {
 	struct vxlanhdr_gbp *gbp;
@@ -1686,21 +1687,20 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, struct vxlan_sock *vs,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static int vxlan6_xmit_skb(struct vxlan_sock *vs,
-			   struct dst_entry *dst, struct sk_buff *skb,
+static int vxlan6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
 			   __be16 src_port, __be16 dst_port,
-			   struct vxlan_metadata *md, bool xnet)
+			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
+	bool udp_sum = !(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	u16 hdrlen = sizeof(struct vxlanhdr);
 
-	if ((vs->flags & VXLAN_F_REMCSUM_TX) &&
+	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
 		int csum_start = skb_checksum_start_offset(skb);
 
@@ -1758,14 +1758,14 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 		}
 	}
 
-	if (vs->flags & VXLAN_F_GBP)
-		vxlan_build_gbp_hdr(vxh, vs, md);
+	if (vxflags & VXLAN_F_GBP)
+		vxlan_build_gbp_hdr(vxh, vxflags, md);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(dst, skb, dev, saddr, daddr, prio,
 			     ttl, src_port, dst_port,
-			     udp_get_no_check6_tx(vs->sock->sk));
+			     !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
 	return 0;
 err:
 	dst_release(dst);
@@ -1773,20 +1773,19 @@ err:
 }
 #endif
 
-int vxlan_xmit_skb(struct vxlan_sock *vs,
-		   struct rtable *rt, struct sk_buff *skb,
+int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port,
-		   struct vxlan_metadata *md, bool xnet)
+		   struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
 	int min_headroom;
 	int err;
-	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
+	bool udp_sum = !!(vxflags & VXLAN_F_UDP_CSUM);
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	u16 hdrlen = sizeof(struct vxlanhdr);
 
-	if ((vs->flags & VXLAN_F_REMCSUM_TX) &&
+	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
 		int csum_start = skb_checksum_start_offset(skb);
 
@@ -1838,14 +1837,14 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		}
 	}
 
-	if (vs->flags & VXLAN_F_GBP)
-		vxlan_build_gbp_hdr(vxh, vs, md);
+	if (vxflags & VXLAN_F_GBP)
+		vxlan_build_gbp_hdr(vxh, vxflags, md);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	return udp_tunnel_xmit_skb(rt, skb, src, dst, tos,
 				   ttl, df, src_port, dst_port, xnet,
-				   vs->sock->sk->sk_no_check_tx);
+				   !(vxflags & VXLAN_F_UDP_CSUM));
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1977,10 +1976,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		md.vni = htonl(vni << 8);
 		md.gbp = skb->mark;
 
-		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
-				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port, &md,
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = vxlan_xmit_skb(rt, skb, fl4.saddr,
+				     dst->sin.sin_addr.s_addr, tos, ttl, df,
+				     src_port, dst_port, &md,
+				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
+				     vxlan->flags);
 		if (err < 0) {
 			/* skb is already freed. */
 			skb = NULL;
@@ -2036,10 +2036,10 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		md.vni = htonl(vni << 8);
 		md.gbp = skb->mark;
 
-		err = vxlan6_xmit_skb(vxlan->vn_sock, ndst, skb,
-				      dev, &fl6.saddr, &fl6.daddr, 0, ttl,
-				      src_port, dst_port, &md,
-				      !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = vxlan6_xmit_skb(ndst, skb, dev, &fl6.saddr, &fl6.daddr,
+				      0, ttl, src_port, dst_port, &md,
+				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
+				      vxlan->flags);
 #endif
 	}
 
@@ -2511,15 +2511,11 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
-		udp_conf.use_udp6_tx_checksums =
-		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
 		udp_conf.use_udp6_rx_checksums =
 		    !(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 	} else {
 		udp_conf.family = AF_INET;
 		udp_conf.local_ip.s_addr = INADDR_ANY;
-		udp_conf.use_udp_checksums =
-		    !!(flags & VXLAN_F_UDP_CSUM);
 	}
 
 	udp_conf.local_udp_port = port;
@@ -2563,7 +2559,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
-	vs->flags = flags;
+	vs->flags = (flags & VXLAN_F_RCV_FLAGS);
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 7be8c34..2927d62 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -129,8 +129,12 @@ struct vxlan_sock {
 #define VXLAN_F_REMCSUM_RX		0x400
 #define VXLAN_F_GBP			0x800
 
-/* These flags must match in order for a socket to be shareable */
-#define VXLAN_F_UNSHAREABLE		VXLAN_F_GBP
+/* Flags that are used in the receive patch. These flags must match in
+ * order for a socket to be shareable
+ */
+#define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
+					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
+					 VXLAN_F_REMCSUM_RX)
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
@@ -138,11 +142,10 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 void vxlan_sock_release(struct vxlan_sock *vs);
 
-int vxlan_xmit_skb(struct vxlan_sock *vs,
-		   struct rtable *rt, struct sk_buff *skb,
+int vxlan_xmit_skb(struct rtable *rt, struct sk_buff *skb,
 		   __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
 		   __be16 src_port, __be16 dst_port, struct vxlan_metadata *md,
-		   bool xnet);
+		   bool xnet, u32 vxflags);
 
 static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 						     netdev_features_t features)
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 8a2d54c..3cc983b 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -252,12 +252,10 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
 	md.gbp = vxlan_ext_gbp(skb);
 
-	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
-			     fl.saddr, tun_key->ipv4_dst,
+	err = vxlan_xmit_skb(rt, skb, fl.saddr, tun_key->ipv4_dst,
 			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df,
 			     src_port, dst_port,
-			     &md,
-			     false);
+			     &md, false, vxlan_port->exts);
 	if (err < 0)
 		ip_rt_put(rt);
 	return err;
-- 
2.2.0.rc0.207.ga3a616c
