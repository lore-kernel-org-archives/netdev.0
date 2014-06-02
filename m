From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 7/7] vxlan: Add support for UDP checksums (v4 sending, v6
 zero csums)
Date: Sun, 1 Jun 2014 21:01:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406012055160.12715@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:51874 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaFBEBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:01:53 -0400
Received: by mail-ob0-f202.google.com with SMTP id wm4so871793obc.3
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 21:01:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added VXLAN link configuration for sending UDP checksums, and allowing
TX and RX of UDP6 checksums.

Also, call common iptunnel_handle_offloads and added GSO support for
checksums.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c           | 118 ++++++++++++++++++++----------------------
 include/net/vxlan.h           |  12 ++++-
 include/uapi/linux/if_link.h  |   3 ++
 net/openvswitch/vport-vxlan.c |   2 +-
 4 files changed, 72 insertions(+), 63 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e68c8eb..191dd64 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -135,7 +135,7 @@ struct vxlan_dev {
 	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
 	__u8		  ttl;
-	u32		  flags;	/* VXLAN_F_* below */
+	u32		  flags;	/* VXLAN_F_* in vxlan.h */
 
 	struct work_struct sock_work;
 	struct work_struct igmp_join;
@@ -150,13 +150,6 @@ struct vxlan_dev {
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
-#define VXLAN_F_LEARN	0x01
-#define VXLAN_F_PROXY	0x02
-#define VXLAN_F_RSC	0x04
-#define VXLAN_F_L2MISS	0x08
-#define VXLAN_F_L3MISS	0x10
-#define VXLAN_F_IPV6	0x20 /* internal flag */
-
 /* salt for hash table */
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
@@ -1601,18 +1594,11 @@ __be16 vxlan_src_port(__u16 port_min, __u16 port_max, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(vxlan_src_port);
 
-static int handle_offloads(struct sk_buff *skb)
+static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
+						    bool udp_csum)
 {
-	if (skb_is_gso(skb)) {
-		int err = skb_unclone(skb, GFP_ATOMIC);
-		if (unlikely(err))
-			return err;
-
-		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
-		skb->ip_summed = CHECKSUM_NONE;
-
-	return 0;
+	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	return iptunnel_handle_offloads(skb, udp_csum, type);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1629,10 +1615,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 
-	if (!skb->encapsulation) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb = vxlan_handle_offloads(skb, !udp_get_no_check6_tx(vs->sock->sk));
+	if (IS_ERR(skb))
+		return -EINVAL;
 
 	skb_scrub_packet(skb, xnet);
 
@@ -1666,27 +1651,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	uh->source = src_port;
 
 	uh->len = htons(skb->len);
-	uh->check = 0;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_set(skb, dst);
 
-	if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
-		__wsum csum = skb_checksum(skb, 0, skb->len, 0);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
-					    IPPROTO_UDP, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-	} else {
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_ipv6_magic(saddr, daddr,
-					     skb->len, IPPROTO_UDP, 0);
-	}
+	udp6_set_csum(vs->sock->sk, skb, saddr, daddr, skb->len);
 
 	__skb_push(skb, sizeof(*ip6h));
 	skb_reset_network_header(skb);
@@ -1702,10 +1673,6 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	ip6h->daddr	  = *daddr;
 	ip6h->saddr	  = *saddr;
 
-	err = handle_offloads(skb);
-	if (err)
-		return err;
-
 	ip6tunnel_xmit(skb, dev);
 	return 0;
 }
@@ -1721,10 +1688,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	int min_headroom;
 	int err;
 
-	if (!skb->encapsulation) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb = vxlan_handle_offloads(skb, !vs->sock->sk->sk_no_check_tx);
+	if (IS_ERR(skb))
+		return -EINVAL;
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ VXLAN_HLEN + sizeof(struct iphdr)
@@ -1756,11 +1722,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->source = src_port;
 
 	uh->len = htons(skb->len);
-	uh->check = 0;
 
-	err = handle_offloads(skb);
-	if (err)
-		return err;
+	udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);
 
 	return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
 			     tos, ttl, df, xnet);
@@ -2405,7 +2368,7 @@ static void vxlan_del_work(struct work_struct *work)
  * could be used for both IPv4 and IPv6 communications, but
  * users may set bindv6only=1.
  */
-static struct socket *create_v6_sock(struct net *net, __be16 port)
+static struct socket *create_v6_sock(struct net *net, __be16 port, u32 flags)
 {
 	struct sock *sk;
 	struct socket *sock;
@@ -2442,18 +2405,25 @@ static struct socket *create_v6_sock(struct net *net, __be16 port)
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+
+	if (flags & VXLAN_F_UDP_ZERO_CSUM6_TX)
+		udp_set_no_check6_tx(sk, true);
+
+	if (flags & VXLAN_F_UDP_ZERO_CSUM6_RX)
+		udp_set_no_check6_rx(sk, true);
+
 	return sock;
 }
 
 #else
 
-static struct socket *create_v6_sock(struct net *net, __be16 port)
+static struct socket *create_v6_sock(struct net *net, __be16 port, u32 flags)
 {
 		return ERR_PTR(-EPFNOSUPPORT);
 }
 #endif
 
-static struct socket *create_v4_sock(struct net *net, __be16 port)
+static struct socket *create_v4_sock(struct net *net, __be16 port, u32 flags)
 {
 	struct sock *sk;
 	struct socket *sock;
@@ -2486,18 +2456,24 @@ static struct socket *create_v4_sock(struct net *net, __be16 port)
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+
+	if (!(flags & VXLAN_F_UDP_CSUM))
+		sock->sk->sk_no_check_tx = 1;
+
 	return sock;
 }
 
 /* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data, bool ipv6)
+					      vxlan_rcv_t *rcv, void *data,
+					      u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct socket *sock;
 	struct sock *sk;
 	unsigned int h;
+	bool ipv6 = !!(flags & VXLAN_F_IPV6);
 
 	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
 	if (!vs)
@@ -2509,9 +2485,9 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	INIT_WORK(&vs->del_work, vxlan_del_work);
 
 	if (ipv6)
-		sock = create_v6_sock(net, port);
+		sock = create_v6_sock(net, port, flags);
 	else
-		sock = create_v4_sock(net, port);
+		sock = create_v4_sock(net, port, flags);
 	if (IS_ERR(sock)) {
 		kfree(vs);
 		return ERR_CAST(sock);
@@ -2549,12 +2525,12 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, bool ipv6)
+				  bool no_share, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
-	vs = vxlan_socket_create(net, port, rcv, data, ipv6);
+	vs = vxlan_socket_create(net, port, rcv, data, flags);
 	if (!IS_ERR(vs))
 		return vs;
 
@@ -2587,7 +2563,7 @@ static void vxlan_sock_work(struct work_struct *work)
 	__be16 port = vxlan->dst_port;
 	struct vxlan_sock *nvs;
 
-	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags & VXLAN_F_IPV6);
+	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
 	spin_lock(&vn->sock_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
@@ -2711,6 +2687,17 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_VXLAN_PORT])
 		vxlan->dst_port = nla_get_be16(data[IFLA_VXLAN_PORT]);
 
+	if (data[IFLA_VXLAN_UDP_CSUM] && nla_get_u8(data[IFLA_VXLAN_UDP_CSUM]))
+		vxlan->flags |= VXLAN_F_UDP_CSUM;
+
+	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
+	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
+		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
+
+	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
+	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
+		vxlan->flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
+
 	if (vxlan_find_vni(net, vni, vxlan->dst_port)) {
 		pr_info("duplicate VNI %u\n", vni);
 		return -EEXIST;
@@ -2774,7 +2761,10 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
-		nla_total_size(sizeof(__be16))+ /* IFLA_VXLAN_PORT */
+		nla_total_size(sizeof(__be16)) + /* IFLA_VXLAN_PORT */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_CSUM */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_TX */
+		nla_total_size(sizeof(__u8)) + /* IFLA_VXLAN_UDP_ZERO_CSUM6_RX */
 		0;
 }
 
@@ -2834,7 +2824,13 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
-	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port))
+	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port) ||
+	    nla_put_u8(skb, IFLA_VXLAN_UDP_CSUM,
+			!!(vxlan->flags & VXLAN_F_UDP_CSUM)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
+			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 7bb4084..12196ce6 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -24,9 +24,19 @@ struct vxlan_sock {
 	struct udp_offload udp_offloads;
 };
 
+#define VXLAN_F_LEARN			0x01
+#define VXLAN_F_PROXY			0x02
+#define VXLAN_F_RSC			0x04
+#define VXLAN_F_L2MISS			0x08
+#define VXLAN_F_L3MISS			0x10
+#define VXLAN_F_IPV6			0x20
+#define VXLAN_F_UDP_CSUM		0x40
+#define VXLAN_F_UDP_ZERO_CSUM6_TX	0x80
+#define VXLAN_F_UDP_ZERO_CSUM6_RX	0x100
+
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
-				  bool no_share, bool ipv6);
+				  bool no_share, u32 flags);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 622e7910..b385348 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -319,6 +319,9 @@ enum {
 	IFLA_VXLAN_PORT,	/* destination port */
 	IFLA_VXLAN_GROUP6,
 	IFLA_VXLAN_LOCAL6,
+	IFLA_VXLAN_UDP_CSUM,
+	IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
+	IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index a93efa3..0edbd95 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -122,7 +122,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	vxlan_port = vxlan_vport(vport);
 	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
 
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, false);
+	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0);
 	if (IS_ERR(vs)) {
 		ovs_vport_free(vport);
 		return (void *)vs;
-- 
1.9.1.423.g4596e3a
