From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v5 2/3] vxlan: Refactor vxlan driver to make use of the common UDP tunnel functions.
Date: Wed, 10 Sep 2014 20:29:52 -0700
Message-ID: <1410406193-6185-3-git-send-email-azhou@nicira.com>
References: <1410406193-6185-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:48977 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751109AbaIKDfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 23:35:33 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so12450108pde.19
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 20:35:33 -0700 (PDT)
In-Reply-To: <1410406193-6185-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/vxlan.c           |  174 +++++++++++++++++------------------------
 include/net/vxlan.h           |   17 ++--
 net/openvswitch/vport-vxlan.c |    6 +-
 3 files changed, 84 insertions(+), 113 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 53c3ec1..d915669 100644
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
@@ -280,7 +281,7 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 	struct vxlan_sock *vs;
 
 	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
-		if (inet_sk(vs->sock->sk)->inet_sport == port)
+		if (inet_sk(vs->uts.sock->sk)->inet_sport == port)
 			return vs;
 	}
 	return NULL;
@@ -636,7 +637,7 @@ static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
 static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -661,7 +662,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -1053,7 +1054,7 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
 
 void vxlan_sock_release(struct vxlan_sock *vs)
 {
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
@@ -1062,7 +1063,6 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 
 	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
-	rcu_assign_sk_user_data(vs->sock->sk, NULL);
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
@@ -1078,7 +1078,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
@@ -1107,7 +1107,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
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
+	bool udp_sum = !udp_get_no_check6_tx(vs->uts.sock->sk);
 
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
+	udp_tunnel6_xmit_skb(&vs->uts, dst, skb, dev, saddr, daddr, prio,
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
+	bool udp_sum = !vs->uts.sock->sk->sk_no_check_tx;
 
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
+	return udp_tunnel_xmit_skb(&vs->uts, rt, skb, src, dst, tos,
+				   ttl, df, src_port, dst_port, xnet);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1829,18 +1778,18 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
-				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8),
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = udp_tunnel_xmit_skb(&vxlan->vn_sock->uts, rt, skb,
+					  fl4.saddr, dst->sin.sin_addr.s_addr,
+					  tos, ttl, df, src_port, dst_port,
+					  !net_eq(vxlan->net,
+						  dev_net(vxlan->dev)));
 
 		if (err < 0)
 			goto rt_tx_error;
 		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		struct sock *sk = vxlan->vn_sock->sock->sk;
+		struct sock *sk = vxlan->vn_sock->uts.sock->sk;
 		struct dst_entry *ndst;
 		struct flowi6 fl6;
 		u32 flags;
@@ -2202,8 +2151,8 @@ void vxlan_get_rx_port(struct net_device *dev)
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
-			port = inet_sk(vs->sock->sk)->inet_sport;
-			sa_family = vs->sock->sk->sk_family;
+			port = inet_sk(vs->uts.sock->sk)->inet_sport;
+			sa_family = vs->uts.sock->sk->sk_family;
 			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
 							    port);
 		}
@@ -2330,12 +2279,18 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
+static void free_vxlan_sock_rcu(struct rcu_head *rcu)
+{
+	struct vxlan_sock *vs = container_of(rcu, struct vxlan_sock, rcu);
+
+	udp_tunnel_sock_free(&vs->uts);
+}
+
 static void vxlan_del_work(struct work_struct *work)
 {
 	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-
-	sk_release_kernel(vs->sock->sk);
-	kfree_rcu(vs, rcu);
+	udp_tunnel_sock_release(&vs->uts);
+	call_rcu(&vs->rcu, free_vxlan_sock_rcu);
 }
 
 static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
@@ -2375,39 +2330,60 @@ static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
 	return sock;
 }
 
+static struct vxlan_sock *vxlan_create_tunnel_sock(struct net *net,
+						   struct socket *sock)
+{
+	struct udp_tunnel_sock_cfg cfg;
+	struct udp_tunnel_sock *uts;
+	struct vxlan_sock *vs;
+
+	cfg.sock = sock;
+	cfg.encap_type = 1;
+	cfg.encap_rcv = vxlan_udp_encap_recv;
+	cfg.encap_destroy = NULL;
+
+	uts = create_udp_tunnel_sock(net, sizeof(*vs), &cfg);
+
+	if (IS_ERR(uts))
+		vs = ERR_CAST(uts);
+	else
+		vs = container_of(uts, struct vxlan_sock, uts);
+
+	return vs;
+}
+
 /* Create new listen socket if needed */
 static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data,
+					      vxlan_rcv_t rcv, void *data,
 					      u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 	struct socket *sock;
-	struct sock *sk;
-	unsigned int h;
 	bool ipv6 = !!(flags & VXLAN_F_IPV6);
+	unsigned int h;
 
-	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
-	if (!vs)
-		return ERR_PTR(-ENOMEM);
+	sock = vxlan_create_sock(net, ipv6, port, flags);
+	if (IS_ERR(sock))
+		return ERR_CAST(sock);
+
+	vs = vxlan_create_tunnel_sock(net, sock);
+	if (IS_ERR(vs))
+		return vs;
 
 	for (h = 0; h < VNI_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vs->vni_list[h]);
 
-	INIT_WORK(&vs->del_work, vxlan_del_work);
+	spin_lock(&vn->sock_lock);
+	list_add(&vs->next, &vn->vxlan_list);
+	spin_unlock(&vn->sock_lock);
 
-	sock = vxlan_create_sock(net, ipv6, port, flags);
-	if (IS_ERR(sock)) {
-		kfree(vs);
-		return ERR_CAST(sock);
-	}
+	INIT_WORK(&vs->del_work, vxlan_del_work);
 
-	vs->sock = sock;
-	sk = sock->sk;
 	atomic_set(&vs->refcnt, 1);
+
 	vs->rcv = rcv;
-	vs->data = data;
-	rcu_assign_sk_user_data(vs->sock->sk, vs);
+	vs->rcv_data = data;
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
@@ -2419,21 +2395,11 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 	vxlan_notify_add_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
 
-	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (ipv6)
-		ipv6_stub->udpv6_encap_enable();
-	else
-#endif
-		udp_encap_enable();
-
 	return vs;
 }
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
+				  vxlan_rcv_t rcv, void *data,
 				  bool no_share, u32 flags)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d5f59f3..b1dd547 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -4,23 +4,27 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/udp.h>
+#include <net/udp_tunnel.h>
 
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
 struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
 
-/* per UDP socket information */
+typedef void (*vxlan_rcv_t)(struct vxlan_sock *vs, struct sk_buff *skb,
+			    __be32 key);
+
+/* per vxlan socket information */
 struct vxlan_sock {
+	struct udp_tunnel_sock uts;  /* Must be the first member */
 	struct hlist_node hlist;
-	vxlan_rcv_t	 *rcv;
-	void		 *data;
+	struct list_head next;
 	struct work_struct del_work;
-	struct socket	 *sock;
 	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
+	vxlan_rcv_t	  rcv;
+	void		  *rcv_data;
 	struct udp_offload udp_offloads;
 };
 
@@ -35,7 +39,7 @@ struct vxlan_sock {
 #define VXLAN_F_UDP_ZERO_CSUM6_RX	0x100
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
-				  vxlan_rcv_t *rcv, void *data,
+				  vxlan_rcv_t rcv, void *data,
 				  bool no_share, u32 flags);
 
 void vxlan_sock_release(struct vxlan_sock *vs);
@@ -57,4 +61,5 @@ static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
 }
 #endif
+
 #endif
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d8b7e24..7599efd 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -59,7 +59,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
 	struct ovs_key_ipv4_tunnel tun_key;
-	struct vport *vport = vs->data;
+	struct vport *vport = vs->rcv_data;
 	struct iphdr *iph;
 	__be64 key;
 
@@ -74,7 +74,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 {
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	__be16 dst_port = inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
 
 	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
 		return -EMSGSIZE;
@@ -139,7 +139,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
-	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	__be16 dst_port = inet_sk(vxlan_port->vs->uts.sock->sk)->inet_sport;
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
-- 
1.7.9.5
