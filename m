From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 04/10] net: Refactor vxlan driver to make use of common UDP tunnel functions
Date: Tue, 22 Jul 2014 03:19:47 -0700
Message-ID: <1406024393-6778-5-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:60344 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754335AbaGVKaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:30:19 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so10966291pdj.14
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:30:18 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor vxlan driver to make use of the common UDP tunnel
functions.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/vxlan.c           |  232 ++++++++++-------------------------------
 include/net/vxlan.h           |   14 ++-
 net/openvswitch/vport-vxlan.c |    7 +-
 3 files changed, 66 insertions(+), 187 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 93f2e40..816f42d 100644
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
@@ -51,8 +52,6 @@
 
 #define VXLAN_VERSION	"0.1"
 
-#define PORT_HASH_BITS	8
-#define PORT_HASH_SIZE  (1<<PORT_HASH_BITS)
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 #define FDB_HASH_BITS	8
@@ -91,8 +90,7 @@ static const u8 all_zeros_mac[ETH_ALEN];
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
-	struct hlist_head sock_list[PORT_HASH_SIZE];
-	spinlock_t	  sock_lock;
+	spinlock_t	  vxlan_list_lock; /* protecting vxlan_list */
 };
 
 union vxlan_addr {
@@ -253,14 +251,6 @@ static inline struct hlist_head *vni_head(struct vxlan_sock *vs, u32 id)
 	return &vs->vni_list[hash_32(id, VNI_HASH_BITS)];
 }
 
-/* Socket hash table head */
-static inline struct hlist_head *vs_head(struct net *net, __be16 port)
-{
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-
-	return &vn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
-}
-
 /* First remote destination for a forwarding entry.
  * Guaranteed to be non-NULL because remotes are never deleted.
  */
@@ -277,13 +267,7 @@ static inline struct vxlan_rdst *first_remote_rtnl(struct vxlan_fdb *fdb)
 /* Find VXLAN socket based on network namespace and UDP port */
 static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
 {
-	struct vxlan_sock *vs;
-
-	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
-		if (inet_sk(vs->sock->sk)->inet_sport == port)
-			return vs;
-	}
-	return NULL;
+	return (struct vxlan_sock *)udp_tunnel_find_sock(net, port);
 }
 
 static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, u32 id)
@@ -636,7 +620,7 @@ static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
 static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -663,7 +647,7 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
 static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
 {
 	struct net_device *dev;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	struct net *net = sock_net(sk);
 	sa_family_t sa_family = sk->sk_family;
 	__be16 port = inet_sk(sk)->inet_sport;
@@ -1056,19 +1040,11 @@ static void vxlan_sock_hold(struct vxlan_sock *vs)
 
 void vxlan_sock_release(struct vxlan_sock *vs)
 {
-	struct sock *sk = vs->sock->sk;
-	struct net *net = sock_net(sk);
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-
 	if (!atomic_dec_and_test(&vs->refcnt))
 		return;
 
-	spin_lock(&vn->sock_lock);
-	hlist_del_rcu(&vs->hlist);
-	rcu_assign_sk_user_data(vs->sock->sk, NULL);
+	udp_tunnel_sock_release(&vs->uts);
 	vxlan_notify_del_rx_port(vs);
-	spin_unlock(&vn->sock_lock);
-
 	queue_work(vxlan_wq, &vs->del_work);
 }
 EXPORT_SYMBOL_GPL(vxlan_sock_release);
@@ -1081,7 +1057,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
@@ -1110,7 +1086,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 {
 	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
 	struct vxlan_sock *vs = vxlan->vn_sock;
-	struct sock *sk = vs->sock->sk;
+	struct sock *sk = vs->uts.sock->sk;
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
@@ -1163,7 +1139,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	skb_pop_rcv_encapsulation(skb);
 
-	vs->rcv(vs, skb, vxh->vx_vni);
+	vs->uts.rcv(&vs->uts, skb, vxh->vx_vni);
 	return 0;
 
 drop:
@@ -1341,7 +1317,6 @@ out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-
 static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	struct neighbour *n, bool isrouter)
 {
@@ -1575,13 +1550,6 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
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
@@ -1590,13 +1558,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 			   __be16 src_port, __be16 dst_port, __be32 vni,
 			   bool xnet)
 {
-	struct ipv6hdr *ip6h;
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
 
-	skb = vxlan_handle_offloads(skb, !udp_get_no_check6_tx(vs->sock->sk));
+	skb = udp_tunnel_handle_offloads(skb,
+					 !udp_get_no_check6_tx(
+						 vs->uts.sock->sk));
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1624,38 +1592,8 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
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
+	udp_tunnel6_xmit_skb(vs->uts.sock, dst, skb, dev, saddr, daddr, prio,
+			     ttl, src_port, dst_port);
 	return 0;
 }
 #endif
@@ -1666,11 +1604,11 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 		   __be16 src_port, __be16 dst_port, __be32 vni, bool xnet)
 {
 	struct vxlanhdr *vxh;
-	struct udphdr *uh;
 	int min_headroom;
 	int err;
 
-	skb = vxlan_handle_offloads(skb, !vs->sock->sk->sk_no_check_tx);
+	skb = udp_tunnel_handle_offloads(skb,
+					 !vs->uts.sock->sk->sk_no_check_tx);
 	if (IS_ERR(skb))
 		return -EINVAL;
 
@@ -1696,20 +1634,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
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
+	return udp_tunnel_xmit_skb(vs->uts.sock, rt, skb, src, dst, tos,
+				   ttl, df, src_port, dst_port, xnet);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
@@ -1834,18 +1760,18 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 
-		err = vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
-				     fl4.saddr, dst->sin.sin_addr.s_addr,
-				     tos, ttl, df, src_port, dst_port,
-				     htonl(vni << 8),
-				     !net_eq(vxlan->net, dev_net(vxlan->dev)));
+		err = udp_tunnel_xmit_skb(vxlan->vn_sock->uts.sock, rt, skb,
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
@@ -2041,7 +1967,7 @@ static int vxlan_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	vs = vxlan_find_sock(vxlan->net, vxlan->dst_port);
 	if (vs) {
 		/* If we have a socket with same port already, reuse it */
@@ -2052,7 +1978,7 @@ static int vxlan_init(struct net_device *dev)
 		dev_hold(dev);
 		queue_work(vxlan_wq, &vxlan->sock_work);
 	}
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	return 0;
 }
@@ -2312,59 +2238,44 @@ static const struct ethtool_ops vxlan_ethtool_ops = {
 static void vxlan_del_work(struct work_struct *work)
 {
 	struct vxlan_sock *vs = container_of(work, struct vxlan_sock, del_work);
-
-	sk_release_kernel(vs->sock->sk);
+	sk_release_kernel(vs->uts.sock->sk);
 	kfree_rcu(vs, rcu);
 }
 
-static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
-					__be16 port, u32 flags)
+/* Create new listen socket if needed */
+static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
+					      vxlan_rcv_t *rcv, void *data,
+					      u32 flags)
 {
-	struct socket *sock;
-	struct udp_port_cfg udp_conf;
-	int err;
+	bool ipv6 = !!(flags & VXLAN_F_IPV6);
+	struct vxlan_sock *vs;
+	struct udp_tunnel_socket_cfg vxlan_ts_cfg;
+	unsigned int h;
 
-	memset(&udp_conf, 0, sizeof(udp_conf));
+	memset(&vxlan_ts_cfg, 0, sizeof(struct udp_tunnel_socket_cfg));
+
+	vxlan_ts_cfg.tunnel_type = UDP_TUNNEL_TYPE_VXLAN;
 
 	if (ipv6) {
-		udp_conf.family = AF_INET6;
-		udp_conf.use_udp6_tx_checksums =
+		vxlan_ts_cfg.port.family = AF_INET6;
+		vxlan_ts_cfg.port.use_udp6_tx_checksums =
 		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
-		udp_conf.use_udp6_rx_checksums =
+		vxlan_ts_cfg.port.use_udp6_rx_checksums =
 		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
 	} else {
-		udp_conf.family = AF_INET;
-		udp_conf.local_ip.s_addr = INADDR_ANY;
-		udp_conf.use_udp_checksums =
+		vxlan_ts_cfg.port.family = AF_INET;
+		vxlan_ts_cfg.port.local_ip.s_addr = INADDR_ANY;
+		vxlan_ts_cfg.port.use_udp_checksums =
 		    !!(flags & VXLAN_F_UDP_CSUM);
 	}
 
-	udp_conf.local_udp_port = port;
-
-	/* Open UDP socket */
-	err = udp_sock_create(net, &udp_conf, &sock);
-	if (err < 0)
-		return ERR_PTR(err);
-
-	/* Disable multicast loopback */
-	inet_sk(sock->sk)->mc_loop = 0;
-
-	return sock;
-}
+	vxlan_ts_cfg.port.local_udp_port = port;
+	vxlan_ts_cfg.rcv = (udp_tunnel_rcv_t *)rcv;
+	vxlan_ts_cfg.encap_rcv = vxlan_udp_encap_recv;
+	vxlan_ts_cfg.data = data;
 
-/* Create new listen socket if needed */
-static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
-					      vxlan_rcv_t *rcv, void *data,
-					      u32 flags)
-{
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_sock *vs;
-	struct socket *sock;
-	struct sock *sk;
-	unsigned int h;
-	bool ipv6 = !!(flags & VXLAN_F_IPV6);
-
-	vs = kzalloc(sizeof(*vs), GFP_KERNEL);
+	vs = (struct vxlan_sock *)create_udp_tunnel_socket(net, sizeof(*vs),
+							   &vxlan_ts_cfg);
 	if (!vs)
 		return ERR_PTR(-ENOMEM);
 
@@ -2373,38 +2284,14 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	INIT_WORK(&vs->del_work, vxlan_del_work);
 
-	sock = vxlan_create_sock(net, ipv6, port, flags);
-	if (IS_ERR(sock)) {
-		kfree(vs);
-		return ERR_CAST(sock);
-	}
-
-	vs->sock = sock;
-	sk = sock->sk;
 	atomic_set(&vs->refcnt, 1);
-	vs->rcv = rcv;
-	vs->data = data;
-	rcu_assign_sk_user_data(vs->sock->sk, vs);
 
 	/* Initialize the vxlan udp offloads structure */
 	vs->udp_offloads.port = port;
 	vs->udp_offloads.callbacks.gro_receive  = vxlan_gro_receive;
 	vs->udp_offloads.callbacks.gro_complete = vxlan_gro_complete;
 
-	spin_lock(&vn->sock_lock);
-	hlist_add_head_rcu(&vs->hlist, vs_head(net, port));
 	vxlan_notify_add_rx_port(vs);
-	spin_unlock(&vn->sock_lock);
-
-	/* Mark socket as an encapsulation socket. */
-	udp_sk(sk)->encap_type = 1;
-	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
-#if IS_ENABLED(CONFIG_IPV6)
-	if (ipv6)
-		ipv6_stub->udpv6_encap_enable();
-	else
-#endif
-		udp_encap_enable();
 
 	return vs;
 }
@@ -2413,7 +2300,6 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
 				  bool no_share, u32 flags)
 {
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 	struct vxlan_sock *vs;
 
 	vs = vxlan_socket_create(net, port, rcv, data, flags);
@@ -2423,15 +2309,13 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 	if (no_share)	/* Return error if sharing is not allowed. */
 		return vs;
 
-	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, port);
 	if (vs) {
-		if (vs->rcv == rcv)
+		if (vs->uts.rcv == (udp_tunnel_rcv_t *)rcv)
 			atomic_inc(&vs->refcnt);
 		else
 			vs = ERR_PTR(-EBUSY);
 	}
-	spin_unlock(&vn->sock_lock);
 
 	if (!vs)
 		vs = ERR_PTR(-EINVAL);
@@ -2450,10 +2334,10 @@ static void vxlan_sock_work(struct work_struct *work)
 	struct vxlan_sock *nvs;
 
 	nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	if (!IS_ERR(nvs))
 		vxlan_vs_add_dev(nvs, vxlan);
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	dev_put(vxlan->dev);
 }
@@ -2620,10 +2504,10 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
-	spin_lock(&vn->sock_lock);
+	spin_lock(&vn->vxlan_list_lock);
 	if (!hlist_unhashed(&vxlan->hlist))
 		hlist_del_rcu(&vxlan->hlist);
-	spin_unlock(&vn->sock_lock);
+	spin_unlock(&vn->vxlan_list_lock);
 
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
@@ -2781,13 +2665,9 @@ static struct notifier_block vxlan_notifier_block __read_mostly = {
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	unsigned int h;
 
 	INIT_LIST_HEAD(&vn->vxlan_list);
-	spin_lock_init(&vn->sock_lock);
-
-	for (h = 0; h < PORT_HASH_SIZE; ++h)
-		INIT_HLIST_HEAD(&vn->sock_list[h]);
+	spin_lock_init(&vn->vxlan_list_lock);
 
 	return 0;
 }
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 60f9d4d..81ce6a0 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -4,26 +4,24 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/udp.h>
+#include <net/udp_tunnel.h>
 
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
 
-struct vxlan_sock;
-typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
-
-/* per UDP socket information */
+/* per vxlan socket information */
 struct vxlan_sock {
-	struct hlist_node hlist;
-	vxlan_rcv_t	 *rcv;
-	void		 *data;
+	struct udp_tunnel_sock uts;  /* Must be the first member */
 	struct work_struct del_work;
-	struct socket	 *sock;
 	struct rcu_head	  rcu;
 	struct hlist_head vni_list[VNI_HASH_SIZE];
 	atomic_t	  refcnt;
 	struct udp_offload udp_offloads;
 };
 
+typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb,
+			   __be32 key);
+
 #define VXLAN_F_LEARN			0x01
 #define VXLAN_F_PROXY			0x02
 #define VXLAN_F_RSC			0x04
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d8b7e24..d523e74 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -59,7 +59,7 @@ static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 {
 	struct ovs_key_ipv4_tunnel tun_key;
-	struct vport *vport = vs->data;
+	struct vport *vport = vs->uts.data;
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
@@ -105,6 +105,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 		err = -EINVAL;
 		goto error;
 	}
+
 	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
 	if (a && nla_len(a) == sizeof(u16)) {
 		dst_port = nla_get_u16(a);
@@ -139,7 +140,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
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
