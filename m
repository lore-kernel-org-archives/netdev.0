From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 2/5] udp: Expand UDP tunnel common APIs
Date: Fri,  1 Aug 2014 14:54:42 -0700
Message-ID: <1406930085-26445-3-git-send-email-azhou@nicira.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:41051 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756375AbaHAV7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:46 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so6233358pdb.5
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:41 -0700 (PDT)
In-Reply-To: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added create_udp_tunnel_socket(), packet receive and transmit,  and
other related common functions for UDP tunnels.

Per net open UDP tunnel ports are tracked in this common layer to
prevent sharing of a single port with more than one UDP tunnel.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/udp_tunnel.h |   53 +++++++++
 net/ipv4/udp_tunnel.c    |  267 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 319 insertions(+), 1 deletion(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index ffd69cb..600744f 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -1,6 +1,8 @@
 #ifndef __NET_UDP_TUNNEL_H
 #define __NET_UDP_TUNNEL_H
 
+#include <net/ip_tunnels.h>
+
 struct udp_port_cfg {
 	u8			family;
 
@@ -26,7 +28,58 @@ struct udp_port_cfg {
 				use_udp6_rx_checksums:1;
 };
 
+struct udp_tunnel_sock;
+
+typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff *skb);
+typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
+
+struct udp_tunnel_socket_cfg {
+	struct udp_port_cfg port;
+	netdev_features_t protocol_bit;
+
+	/* Used for setting up udp_sock fields, see udp.h for details */
+	__u8  encap_type;
+	udp_tunnel_encap_rcv_t encap_rcv;
+	udp_tunnel_encap_destroy_t encap_destroy;
+};
+
+struct udp_tunnel_sock {
+	struct hlist_node hlist;
+	struct socket *sock;
+	netdev_features_t protocol_bit;
+};
+
 int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
 		    struct socket **sockp);
 
+struct udp_tunnel_sock *create_udp_tunnel_sock(struct net *net, size_t size,
+					       struct socket *sock,
+					       struct udp_tunnel_socket_cfg
+							*socket_cfg);
+
+struct udp_tunnel_sock *udp_tunnel_find_sock(struct net *net, __be16 port);
+
+int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
+			struct sk_buff *skb, __be32 src, __be32 dst,
+			__u8 tos, __u8 ttl, __be16 df, __be16 src_port,
+			__be16 dst_port, bool xnet);
+
+#if IS_ENABLED(CONFIG_IPV6)
+int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
+		struct sk_buff *skb, struct net_device *dev,
+		struct in6_addr *saddr, struct in6_addr *daddr,
+		__u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port);
+
+#endif
+
+void udp_tunnel_sock_release(struct udp_tunnel_sock *uts);
+void udp_tunnel_get_rx_port(struct net_device *dev);
+
+static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
+							 bool udp_csum)
+{
+	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	return iptunnel_handle_offloads(skb, udp_csum, type);
+}
 #endif
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 61ec1a6..8d22ecd 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -7,6 +7,23 @@
 #include <net/udp.h>
 #include <net/udp_tunnel.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
+#endif
+
+#define PORT_HASH_BITS 8
+#define PORT_HASH_SIZE (1 << PORT_HASH_BITS)
+
+static int udp_tunnel_net_id;
+
+struct udp_tunnel_net {
+	struct hlist_head sock_list[PORT_HASH_SIZE];
+	spinlock_t  sock_lock;   /* Protecting the sock_list */
+};
 
 int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
 		    struct socket **sockp)
@@ -82,7 +99,6 @@ int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
 		return -EPFNOSUPPORT;
 	}
 
-
 	*sockp = sock;
 
 	return 0;
@@ -97,4 +113,253 @@ error:
 }
 EXPORT_SYMBOL(udp_sock_create);
 
+
+/* Socket hash table head */
+static inline struct hlist_head *uts_head(struct net *net, const __be16 port)
+{
+	struct udp_tunnel_net *utn = net_generic(net, udp_tunnel_net_id);
+
+	return &utn->sock_list[hash_32(ntohs(port), PORT_HASH_BITS)];
+}
+
+static int handle_offloads(struct sk_buff *skb)
+{
+	if (skb_is_gso(skb)) {
+		int err = skb_unclone(skb, GFP_ATOMIC);
+
+		if (unlikely(err))
+			return err;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
+	} else {
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
+			skb->ip_summed = CHECKSUM_NONE;
+	}
+
+	return 0;
+}
+
+struct udp_tunnel_sock *create_udp_tunnel_sock(struct net *net, size_t size,
+					       struct socket *sock,
+					       struct udp_tunnel_socket_cfg
+						      *cfg)
+{
+	struct udp_tunnel_net *utn = net_generic(net, udp_tunnel_net_id);
+	struct udp_tunnel_sock *uts;
+	struct sock *sk;
+	const __be16 port = cfg->port.local_udp_port;
+	const int ipv6 = (cfg->port.family == AF_INET6);
+	int err;
+
+	if (!sock)
+		err = udp_sock_create(net, &cfg->port, &sock);
+	else
+		err = (sock->sk->sk_protocol == IPPROTO_UDP) ?
+			0 : -EPROTONOSUPPORT;
+
+	if (err)
+		return NULL;
+
+	uts = kzalloc(size, GFP_KERNEL);
+	if (!uts)
+		return ERR_PTR(-ENOMEM);
+
+	sk = sock->sk;
+
+	/* Disable multicast loopback */
+	inet_sk(sk)->mc_loop = 0;
+
+	rcu_assign_sk_user_data(sk, uts);
+
+	udp_sk(sk)->encap_type = cfg->encap_type;
+	udp_sk(sk)->encap_rcv = cfg->encap_rcv;
+	udp_sk(sk)->encap_destroy = cfg->encap_destroy;
+
+	uts->sock = sock;
+	if ((cfg->protocol_bit & NETIF_F_RX_UT_ALL) &&
+	    (hweight64(cfg->protocol_bit) == 1))
+		/* There should be at most one of NETIF_F_RX_UT_ bit set.
+		 * Otherwise, turn off UDP tunnel acceleration for this port.
+		 */
+		uts->protocol_bit = cfg->protocol_bit;
+
+	spin_lock(&utn->sock_lock);
+	hlist_add_head_rcu(&uts->hlist, uts_head(net, port));
+	spin_unlock(&utn->sock_lock);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (ipv6)
+		ipv6_stub->udpv6_encap_enable();
+	else
+#endif
+		udp_encap_enable();
+
+	return uts;
+}
+EXPORT_SYMBOL_GPL(create_udp_tunnel_sock);
+
+int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
+			struct sk_buff *skb, __be32 src, __be32 dst,
+			__u8 tos, __u8 ttl, __be16 df, __be16 src_port,
+			__be16 dst_port, bool xnet)
+{
+	struct udphdr *uh;
+
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
+
+	uh->dest = dst_port;
+	uh->source = src_port;
+	uh->len = htons(skb->len);
+
+	udp_set_csum(sock->sk->sk_no_check_tx, skb, src, dst, skb->len);
+
+	return iptunnel_xmit(sock->sk, rt, skb, src, dst, IPPROTO_UDP,
+			     tos, ttl, df, xnet);
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
+
+#if IS_ENABLED(CONFIG_IPV6)
+int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
+			 struct sk_buff *skb, struct net_device *dev,
+			 struct in6_addr *saddr, struct in6_addr *daddr,
+			 __u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port)
+{
+	struct udphdr *uh;
+	struct ipv6hdr *ip6h;
+	int err;
+
+	__skb_push(skb, sizeof(*uh));
+	skb_reset_transport_header(skb);
+	uh = udp_hdr(skb);
+
+	uh->dest = dst_port;
+	uh->source = src_port;
+
+	uh->len = htons(skb->len);
+	uh->check = 0;
+
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED
+			    | IPSKB_REROUTED);
+	skb_dst_set(skb, dst);
+
+	if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
+		__wsum csum = skb_checksum(skb, 0, skb->len, 0);
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
+				IPPROTO_UDP, csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = ~csum_ipv6_magic(saddr, daddr,
+				skb->len, IPPROTO_UDP, 0);
+	}
+
+	__skb_push(skb, sizeof(*ip6h));
+	skb_reset_network_header(skb);
+	ip6h		  = ipv6_hdr(skb);
+	ip6h->version	  = 6;
+	ip6h->priority	  = prio;
+	ip6h->flow_lbl[0] = 0;
+	ip6h->flow_lbl[1] = 0;
+	ip6h->flow_lbl[2] = 0;
+	ip6h->payload_len = htons(skb->len);
+	ip6h->nexthdr     = IPPROTO_UDP;
+	ip6h->hop_limit   = ttl;
+	ip6h->daddr	  = *daddr;
+	ip6h->saddr	  = *saddr;
+
+	err = handle_offloads(skb);
+	if (err)
+		return err;
+
+	ip6tunnel_xmit(skb, dev);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_tunnel6_xmit_skb);
+#endif
+
+struct udp_tunnel_sock *udp_tunnel_find_sock(struct net *net, __be16 port)
+{
+	struct udp_tunnel_sock *uts;
+
+	hlist_for_each_entry_rcu(uts, uts_head(net, port), hlist) {
+		if (inet_sk(uts->sock->sk)->inet_sport == port)
+			return uts;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_find_sock);
+
+void udp_tunnel_sock_release(struct udp_tunnel_sock *uts)
+{
+	struct sock *sk = uts->sock->sk;
+	struct net *net = sock_net(sk);
+	struct udp_tunnel_net *utn = net_generic(net, udp_tunnel_net_id);
+
+	spin_lock(&utn->sock_lock);
+	hlist_del_rcu(&uts->hlist);
+	rcu_assign_sk_user_data(uts->sock->sk, NULL);
+	spin_unlock(&utn->sock_lock);
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
+
+/* Calls the ndo_add_tunnel_port of the caller in order to
+ * supply the listening udp tunnel ports. Callers are expected
+ * to implement the ndo_add_tunnle_port.
+ */
+void udp_tunnel_get_rx_port(struct net_device *dev)
+{
+	struct udp_tunnel_sock *uts;
+	struct net *net = dev_net(dev);
+	struct udp_tunnel_net *utn = net_generic(net, udp_tunnel_net_id);
+	sa_family_t sa_family;
+	__be16 port;
+	unsigned int i;
+
+	spin_lock(&utn->sock_lock);
+	for (i = 0; i < PORT_HASH_SIZE; ++i) {
+		hlist_for_each_entry_rcu(uts, &utn->sock_list[i], hlist) {
+			port = inet_sk(uts->sock->sk)->inet_sport;
+			sa_family = uts->sock->sk->sk_family;
+			dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
+							    port);
+		}
+	}
+	spin_unlock(&utn->sock_lock);
+}
+EXPORT_SYMBOL_GPL(udp_tunnel_get_rx_port);
+
+static int __net_init udp_tunnel_init_net(struct net *net)
+{
+	struct udp_tunnel_net *utn = net_generic(net, udp_tunnel_net_id);
+	unsigned int h;
+
+	spin_lock_init(&utn->sock_lock);
+
+	for (h = 0; h < PORT_HASH_SIZE; h++)
+		INIT_HLIST_HEAD(&utn->sock_list[h]);
+
+	return 0;
+}
+
+static struct pernet_operations udp_tunnel_net_ops = {
+	.init = udp_tunnel_init_net,
+	.exit = NULL,
+	.id = &udp_tunnel_net_id,
+	.size = sizeof(struct udp_tunnel_net),
+};
+
+static int __init udp_tunnel_init(void)
+{
+	return register_pernet_subsys(&udp_tunnel_net_ops);
+}
+late_initcall(udp_tunnel_init);
+
 MODULE_LICENSE("GPL");
-- 
1.7.9.5
