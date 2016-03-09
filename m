From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] ip_tunnel: add support for setting flow label via collect metadata
Date: Wed,  9 Mar 2016 03:00:02 +0100
Message-ID: <048c342f924a59757d950668c490809a792ad592.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45214 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbcCICAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:00:10 -0500
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends udp_tunnel6_xmit_skb() to pass in the IPv6 flow label
from call sites. Currently, there's no such option and it's always set to
zero when writing ip6_flow_hdr(). Add a label member to ip_tunnel_key, so
that flow-based tunnels via collect metadata frontends can make use of it.
vxlan and geneve will be converted to add flow label support separately.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/geneve.c       | 2 +-
 drivers/net/vxlan.c        | 2 +-
 include/net/dst_metadata.h | 5 ++++-
 include/net/ip_tunnels.h   | 4 +++-
 include/net/udp_tunnel.h   | 4 ++--
 net/ipv6/ip6_udp_tunnel.c  | 6 +++---
 net/tipc/udp_media.c       | 2 +-
 7 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 6a0cbbe..89ccff7 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1054,7 +1054,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		ttl = ttl ? : ip6_dst_hoplimit(dst);
 	}
 	udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
-			     &fl6.saddr, &fl6.daddr, prio, ttl,
+			     &fl6.saddr, &fl6.daddr, prio, ttl, 0,
 			     sport, geneve->dst_port,
 			     !!(flags & GENEVE_F_UDP_ZERO_CSUM6_TX));
 	return NETDEV_TX_OK;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2399099..8bdcd5e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2066,7 +2066,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
-				     &saddr, &dst->sin6.sin6_addr, tos, ttl,
+				     &saddr, &dst->sin6.sin6_addr, tos, ttl, 0,
 				     src_port, dst_port, !udp_sum);
 #endif
 	}
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 84b833a..5db9f59 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -126,7 +126,7 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
 
 	ip_tunnel_key_init(&tun_dst->u.tun_info.key,
 			   iph->saddr, iph->daddr, iph->tos, iph->ttl,
-			   0, 0, tunnel_id, flags);
+			   0, 0, 0, tunnel_id, flags);
 	return tun_dst;
 }
 
@@ -152,8 +152,11 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 
 	info->key.u.ipv6.src = ip6h->saddr;
 	info->key.u.ipv6.dst = ip6h->daddr;
+
 	info->key.tos = ipv6_get_dsfield(ip6h);
 	info->key.ttl = ip6h->hop_limit;
+	info->key.label = ip6_flowlabel(ip6h);
+
 	return tun_dst;
 }
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 0acd80f..5dc2e45 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -48,6 +48,7 @@ struct ip_tunnel_key {
 	__be16			tun_flags;
 	u8			tos;		/* TOS for IPv4, TC for IPv6 */
 	u8			ttl;		/* TTL for IPv4, HL for IPv6 */
+	__be32			label;		/* Flow Label for IPv6 */
 	__be16			tp_src;
 	__be16			tp_dst;
 };
@@ -181,7 +182,7 @@ int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
 
 static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
 				      __be32 saddr, __be32 daddr,
-				      u8 tos, u8 ttl,
+				      u8 tos, u8 ttl, __be32 label,
 				      __be16 tp_src, __be16 tp_dst,
 				      __be64 tun_id, __be16 tun_flags)
 {
@@ -192,6 +193,7 @@ static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
 	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
 	key->tos = tos;
 	key->ttl = ttl;
+	key->label = label;
 	key->tun_flags = tun_flags;
 
 	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 97f5adb..b831140 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -88,8 +88,8 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			 struct sk_buff *skb,
 			 struct net_device *dev, struct in6_addr *saddr,
 			 struct in6_addr *daddr,
-			 __u8 prio, __u8 ttl, __be16 src_port,
-			 __be16 dst_port, bool nocheck);
+			 __u8 prio, __u8 ttl, __be32 label,
+			 __be16 src_port, __be16 dst_port, bool nocheck);
 #endif
 
 void udp_tunnel_sock_release(struct socket *sock);
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index 14dacf1..a752052 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -73,8 +73,8 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			 struct sk_buff *skb,
 			 struct net_device *dev, struct in6_addr *saddr,
 			 struct in6_addr *daddr,
-			 __u8 prio, __u8 ttl, __be16 src_port,
-			 __be16 dst_port, bool nocheck)
+			 __u8 prio, __u8 ttl, __be32 label,
+			 __be16 src_port, __be16 dst_port, bool nocheck)
 {
 	struct udphdr *uh;
 	struct ipv6hdr *ip6h;
@@ -98,7 +98,7 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 	__skb_push(skb, sizeof(*ip6h));
 	skb_reset_network_header(skb);
 	ip6h		  = ipv6_hdr(skb);
-	ip6_flow_hdr(ip6h, prio, htonl(0));
+	ip6_flow_hdr(ip6h, prio, label);
 	ip6h->payload_len = htons(skb->len);
 	ip6h->nexthdr     = IPPROTO_UDP;
 	ip6h->hop_limit   = ttl;
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 49b3c2e..c94f9a1 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -196,7 +196,7 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 		ttl = ip6_dst_hoplimit(ndst);
 		err = udp_tunnel6_xmit_skb(ndst, ub->ubsock->sk, skb,
 					   ndst->dev, &src->ipv6,
-					   &dst->ipv6, 0, ttl, src->udp_port,
+					   &dst->ipv6, 0, ttl, 0, src->udp_port,
 					   dst->udp_port, false);
 #endif
 	}
-- 
1.9.3
