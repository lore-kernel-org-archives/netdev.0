From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v6 2/4] udp-tunnel: Expand UDP tunnel APIs
Date: Fri, 12 Sep 2014 19:21:58 -0700
Message-ID: <1410574920-16486-3-git-send-email-azhou@nicira.com>
References: <1410574920-16486-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:38317 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752041AbaIMC1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 22:27:33 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so2519376pad.7
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 19:27:32 -0700 (PDT)
In-Reply-To: <1410574920-16486-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added common udp tunnel socket creation, and packet transmission APIs
API that can be used by other UDP based tunneling protocol
implementation.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/udp_tunnel.h  |   56 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_tunnel.c     |    4 ++--
 net/ipv6/ip6_udp_tunnel.c |   42 ++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 0b9e017..9c58c23 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -1,6 +1,14 @@
 #ifndef __NET_UDP_TUNNEL_H
 #define __NET_UDP_TUNNEL_H
 
+#include <net/ip_tunnels.h>
+#include <net/udp.h>
+
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/addrconf.h>
+#endif
+
 struct udp_port_cfg {
 	u8			family;
 
@@ -53,4 +61,52 @@ static inline int udp_sock_create(struct net *net,
 	return -EPFNOSUPPORT;
 }
 
+typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff *skb);
+typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
+
+struct udp_tunnel_sock_cfg {
+	struct socket *sock;	/* The socket UDP tunnel will attach to */
+	void *sk_user_data;     /* user data used by encap_rcv call back */
+	/* Used for setting up udp_sock fields, see udp.h for details */
+	__u8  encap_type;
+	udp_tunnel_encap_rcv_t encap_rcv;
+	udp_tunnel_encap_destroy_t encap_destroy;
+};
+
+void setup_udp_tunnel_sock(struct net *net,
+			   struct udp_tunnel_sock_cfg *sock_cfg);
+
+int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
+			struct sk_buff *skb, __be32 src, __be32 dst,
+			__u8 tos, __u8 ttl, __be16 df, __be16 src_port,
+			__be16 dst_port, bool xnet);
+
+#if IS_ENABLED(CONFIG_IPV6)
+int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
+			 struct sk_buff *skb, struct net_device *dev,
+			 struct in6_addr *saddr, struct in6_addr *daddr,
+			 __u8 prio, __u8 ttl, __be16 src_port,
+			 __be16 dst_port);
+#endif
+
+void udp_tunnel_sock_release(struct socket *sock);
+
+static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
+							 bool udp_csum)
+{
+	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+
+	return iptunnel_handle_offloads(skb, udp_csum, type);
+}
+
+static inline void udp_tunnel_encap_enable(struct socket *sock)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sock->sk->sk_family == PF_INET6)
+		ipv6_stub->udpv6_encap_enable();
+	else
+#endif
+		udp_encap_enable();
+}
+
 #endif
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 93ef133..db73ce8 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -11,7 +11,7 @@
 int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 		     struct socket **sockp)
 {
-	int err = -EINVAL;
+	int err;
 	struct socket *sock = NULL;
 	struct sockaddr_in udp_addr;
 
@@ -62,7 +62,7 @@ void setup_udp_tunnel_sock(struct net *net, struct udp_tunnel_sock_cfg *cfg)
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
 
-	/* Enable CHECKSUM_UNNECESSAY to CHECSUM_COMPLETE conversion */
+	/* Enable CHECKSUM_UNNECESSARY to CHECKSUM_COMPLETE conversion */
 	udp_set_convert_csum(sk, true);
 
 	rcu_assign_sk_user_data(sk, cfg->sk_user_data);
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index bcfbb4b..cbc9907 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -61,3 +61,45 @@ error:
 	return err;
 }
 EXPORT_SYMBOL_GPL(udp_sock_create6);
+
+int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
+			 struct sk_buff *skb, struct net_device *dev,
+			 struct in6_addr *saddr, struct in6_addr *daddr,
+			 __u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port)
+{
+	struct udphdr *uh;
+	struct ipv6hdr *ip6h;
+	struct sock *sk = sock->sk;
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
+	udp6_set_csum(udp_get_no_check6_tx(sk), skb, &inet6_sk(sk)->saddr,
+		      &sk->sk_v6_daddr, skb->len);
+
+	__skb_push(skb, sizeof(*ip6h));
+	skb_reset_network_header(skb);
+	ip6h		  = ipv6_hdr(skb);
+	ip6_flow_hdr(ip6h, prio, htonl(0));
+	ip6h->payload_len = htons(skb->len);
+	ip6h->nexthdr     = IPPROTO_UDP;
+	ip6h->hop_limit   = ttl;
+	ip6h->daddr	  = *daddr;
+	ip6h->saddr	  = *saddr;
+
+	ip6tunnel_xmit(skb, dev);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(udp_tunnel6_xmit_skb);
-- 
1.7.9.5
