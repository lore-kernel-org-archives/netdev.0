From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/2] udp: Do not require sock in udp_tunnel_xmit_skb
Date: Sat, 17 Jan 2015 10:18:19 -0800
Message-ID: <1421518700-22460-2-git-send-email-therbert@google.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:59340 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbbAQSSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 13:18:42 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so25599739ieb.7
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2015 10:18:41 -0800 (PST)
In-Reply-To: <1421518700-22460-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP tunnel transmit functions udp_tunnel_xmit_skb and
udp_tunnel6_xmit_skb include a socket argument. The socket being
passed to the functions (from VXLAN) is a UDP created for receive
side. The only thing that the socket is used for in the transmit
functions is to get the setting for checksum (enabled or zero).
This patch removes the argument and and adds a nocheck argument
for checksum setting. This eliminates the unnecessary dependency
on a UDP socket for UDP tunnel transmit.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c       | 10 ++++++----
 include/net/udp_tunnel.h  | 16 ++++++++--------
 net/ipv4/udp_tunnel.c     | 12 ++++++------
 net/ipv6/ip6_udp_tunnel.c | 12 ++++++------
 4 files changed, 26 insertions(+), 24 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6b6b456..4fb4205 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1763,8 +1763,9 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
-	udp_tunnel6_xmit_skb(vs->sock, dst, skb, dev, saddr, daddr, prio,
-			     ttl, src_port, dst_port);
+	udp_tunnel6_xmit_skb(dst, skb, dev, saddr, daddr, prio,
+			     ttl, src_port, dst_port,
+			     udp_get_no_check6_tx(vs->sock->sk));
 	return 0;
 err:
 	dst_release(dst);
@@ -1842,8 +1843,9 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
-	return udp_tunnel_xmit_skb(vs->sock, rt, skb, src, dst, tos,
-				   ttl, df, src_port, dst_port, xnet);
+	return udp_tunnel_xmit_skb(rt, skb, src, dst, tos,
+				   ttl, df, src_port, dst_port, xnet,
+				   vs->sock->sk->sk_no_check_tx);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 2a50a70..1a20d33 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -77,17 +77,17 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 			   struct udp_tunnel_sock_cfg *sock_cfg);
 
 /* Transmit the skb using UDP encapsulation. */
-int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
-			struct sk_buff *skb, __be32 src, __be32 dst,
-			__u8 tos, __u8 ttl, __be16 df, __be16 src_port,
-			__be16 dst_port, bool xnet);
+int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
+			__be32 src, __be32 dst, __u8 tos, __u8 ttl,
+			__be16 df, __be16 src_port, __be16 dst_port,
+			bool xnet, bool nocheck);
 
 #if IS_ENABLED(CONFIG_IPV6)
-int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
-			 struct sk_buff *skb, struct net_device *dev,
-			 struct in6_addr *saddr, struct in6_addr *daddr,
+int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
+			 struct net_device *dev, struct in6_addr *saddr,
+			 struct in6_addr *daddr,
 			 __u8 prio, __u8 ttl, __be16 src_port,
-			 __be16 dst_port);
+			 __be16 dst_port, bool nocheck);
 #endif
 
 void udp_tunnel_sock_release(struct socket *sock);
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 9996e63..c83b354 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -75,10 +75,10 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 
-int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
-			struct sk_buff *skb, __be32 src, __be32 dst,
-			__u8 tos, __u8 ttl, __be16 df, __be16 src_port,
-			__be16 dst_port, bool xnet)
+int udp_tunnel_xmit_skb(struct rtable *rt, struct sk_buff *skb,
+			__be32 src, __be32 dst, __u8 tos, __u8 ttl,
+			__be16 df, __be16 src_port, __be16 dst_port,
+			bool xnet, bool nocheck)
 {
 	struct udphdr *uh;
 
@@ -90,9 +90,9 @@ int udp_tunnel_xmit_skb(struct socket *sock, struct rtable *rt,
 	uh->source = src_port;
 	uh->len = htons(skb->len);
 
-	udp_set_csum(sock->sk->sk_no_check_tx, skb, src, dst, skb->len);
+	udp_set_csum(nocheck, skb, src, dst, skb->len);
 
-	return iptunnel_xmit(sock->sk, rt, skb, src, dst, IPPROTO_UDP,
+	return iptunnel_xmit(skb->sk, rt, skb, src, dst, IPPROTO_UDP,
 			     tos, ttl, df, xnet);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index 8db6c98..32d9b26 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -62,14 +62,14 @@ error:
 }
 EXPORT_SYMBOL_GPL(udp_sock_create6);
 
-int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
-			 struct sk_buff *skb, struct net_device *dev,
-			 struct in6_addr *saddr, struct in6_addr *daddr,
-			 __u8 prio, __u8 ttl, __be16 src_port, __be16 dst_port)
+int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sk_buff *skb,
+			 struct net_device *dev, struct in6_addr *saddr,
+			 struct in6_addr *daddr,
+			 __u8 prio, __u8 ttl, __be16 src_port,
+			 __be16 dst_port, bool nocheck)
 {
 	struct udphdr *uh;
 	struct ipv6hdr *ip6h;
-	struct sock *sk = sock->sk;
 
 	__skb_push(skb, sizeof(*uh));
 	skb_reset_transport_header(skb);
@@ -85,7 +85,7 @@ int udp_tunnel6_xmit_skb(struct socket *sock, struct dst_entry *dst,
 			    | IPSKB_REROUTED);
 	skb_dst_set(skb, dst);
 
-	udp6_set_csum(udp_get_no_check6_tx(sk), skb, saddr, daddr, skb->len);
+	udp6_set_csum(nocheck, skb, saddr, daddr, skb->len);
 
 	__skb_push(skb, sizeof(*ip6h));
 	skb_reset_network_header(skb);
-- 
2.2.0.rc0.207.ga3a616c
