From: Andy Zhou <azhou@nicira.com>
Subject: [v8 net-next 3/4] vxlan: Refactor vxlan driver to make use of the common UDP tunnel functions.
Date: Tue, 16 Sep 2014 17:31:18 -0700
Message-ID: <1410913879-31688-3-git-send-email-azhou@nicira.com>
References: <1410913879-31688-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:34758 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753934AbaIQAg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 20:36:57 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so873966pdj.16
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:36:57 -0700 (PDT)
In-Reply-To: <1410913879-31688-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify vxlan implementation using common UDP tunnel APIs.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/vxlan.c |  105 +++++++++++----------------------------------------
 1 file changed, 22 insertions(+), 83 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 53c3ec1..39c8653 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -42,6 +42,7 @@
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
 #include <net/protocol.h>
+#include <net/udp_tunnel.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -1062,7 +1063,6 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
-	rcu_assign_sk_user_data(vs->sock->sk, NULL);
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
@@ -1336,7 +1336,6 @@ out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-
 static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	struct neighbour *n, bool isrouter)
 {
@@ -1570,13 +1569,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 	return false;
 }
 
-static inline struct sk_buff *vxlan_handle_offloads(struct sk_buff *skb,
-						    bool udp_csum)
-{
-	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-	return iptunnel_handle_offloads(skb, udp_csum, type);
-}
-
 #if IS_ENABLED(CONFIG_IPV6)
 static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   struct dst_entry *dst, struct sk_buff *skb,
@@ -1585,13 +1577,12 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   __be16 src_port, __be16 dst_port, __be32 vni,
 			   bool xnet)
 {
-	struct ipv6hdr *ip6h;
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
+	bool udp_sum = !udp_get_no_check6_tx(vs->sock->sk);
 
-	skb = vxlan_handle_offloads(skb, !udp_get_no_check6_tx(vs->sock->sk));
+	skb = udp_tunnel_handle_offloads(skb, udp_sum);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1619,38 +1610,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	uh->dest = dst_port;
-	uh->source = src_port;
-
-	uh->len = htons(skb->len);
-
-	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
-			      IPSKB_REROUTED);
-	skb_dst_set(skb, dst);
-
-	udp6_set_csum(udp_get_no_check6_tx(vs->sock->sk), skb,
-		      saddr, daddr, skb->len);
-
-	__skb_push(skb, sizeof(*ip6h));
-	skb_reset_network_header(skb);
-	ip6h		  = ipv6_hdr(skb);
-	ip6h->version	  = 6;
-	ip6h->priority	  = prio;
-	ip6h->flow_lbl[0] = 0;
-	ip6h->flow_lbl[1] = 0;
-	ip6h->flow_lbl[2] = 0;
-	ip6h->payload_len = htons(skb->len);
-	ip6h->nexthdr     = IPPROTO_UDP;
-	ip6h->hop_limit   = ttl;
-	ip6h->daddr	  = *daddr;
-	ip6h->saddr	  = *saddr;
-
-	ip6tunnel_xmit(skb, dev);
+	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
+			     ttl, src_port, dst_port);
 	return 0;
 }
 #endif
@@ -1661,11 +1622,11 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
 {
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
+	bool udp_sum = !vs->sock->sk->sk_no_check_tx;
 
-	skb = vxlan_handle_offloads(skb, !vs->sock->sk->sk_no_check_tx);
+	skb = udp_tunnel_handle_offloads(skb, udp_sum);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1691,20 +1652,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	vxh->vx_flags = htonl(VXLAN_FLAGS);
 	vxh->vx_vni = vni;
 
-	__skb_push(skb, sizeof(*uh));
-	skb_reset_transport_header(skb);
-	uh = udp_hdr(skb);
-
-	uh->dest = dst_port;
-	uh->source = src_port;
-
-	uh->len = htons(skb->len);
-
-	udp_set_csum(vs->sock->sk->sk_no_check_tx, skb,
-		     src, dst, skb->len);
-
-	return iptunnel_xmit(vs->sock->sk, rt, skb, src, dst, IPPROTO_UDP,
-			     tos, ttl, df, xnet);
+	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
+				   ttl, df, src_port, dst_port, xnet);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1829,11 +1778,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
-				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8),
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = udp_tunnel_xmit_skb(vxlan->vn_sock->sock, rt, skb,
+					  fl4.saddr, dst->sin.sin_addr.s_addr,
+					  tos, ttl, df, src_port, dst_port,
+					  !net_eq(vxlan->net,
+						  dev_net(vxlan->dev)));
 
 		if (err < 0)
 			goto rt_tx_error;
@@ -2333,8 +2282,7 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 static void vxlan_del_work(struct work_struct *work)
 {
 	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-
-	sk_release_kernel(vs->sock->sk);
+	udp_tunnel_sock_release(vs->sock);
 	kfree_rcu(vs, rcu);
 }
 
@@ -2367,11 +2315,6 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 	if (err < 0)
 		return ERR_PTR(err);
 
-	/* Disable multicast loopback */
-	inet_sk(sock->sk)->mc_loop = 0;
-
-	udp_set_convert_csum(sock->sk, true);
-
 	return sock;
 }
 
@@ -2383,9 +2326,9 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct socket *sock;
-	struct sock *sk;
 	unsigned int h;
 	bool ipv6 = !!(flags & VXLAN_F_IPV6);
+	struct udp_tunnel_sock_cfg tunnel_cfg;
 
 	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
 	if (!vs)
@@ -2403,11 +2346,9 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	}
 
 	vs->sock = sock;
-	sk = sock->sk;
 	atomic_set(&vs->refcnt, 1);
 	vs->rcv = rcv;
 	vs->data = data;
-	rcu_assign_sk_user_data(vs->sock->sk, vs);
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
@@ -2420,14 +2361,12 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	spin_unlock(&vn->sock_lock);
 
 	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (ipv6)
-		ipv6_stub->udpv6_encap_enable();
-	else
-#endif
-		udp_encap_enable();
+	tunnel_cfg.sk_user_data = vs;
+	tunnel_cfg.encap_type = 1;
+	tunnel_cfg.encap_rcv = vxlan_udp_encap_recv;
+	tunnel_cfg.encap_destroy = NULL;
+
+	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
 	return vs;
 }
-- 
1.7.9.5
