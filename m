From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] ip_tunnel: Move stats update to iptunnel_xmit()
Date: Tue,  8 Dec 2015 19:22:34 -0800
Message-ID: <1449631354-3701-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33645 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbLIDWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:22:37 -0500
Received: by pfnn128 with SMTP id n128so22426407pfn.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 19:22:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By moving stats update into iptunnel_xmit(), we can simplify
iptunnel_xmit() usage. With this change there is no need to
call another function (iptunnel_xmit_stats()) to update stats
in tunnel xmit code path.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c      |   18 +++++++-----------
 drivers/net/vxlan.c       |    9 ++++-----
 include/net/ip6_tunnel.h  |   17 ++++-------------
 include/net/ip_tunnels.h  |   18 ++++++++----------
 include/net/udp_tunnel.h  |    8 ++++----
 net/ipv4/ip_gre.c         |    7 +++----
 net/ipv4/ip_tunnel.c      |    7 ++-----
 net/ipv4/ip_tunnel_core.c |    9 +++++----
 net/ipv4/ip_vti.c         |    2 +-
 net/ipv4/udp_tunnel.c     |   11 +++++------
 net/ipv6/sit.c            |    7 ++-----
 net/tipc/udp_media.c      |   12 +++---------
 12 files changed, 48 insertions(+), 77 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de5c30c..99d7880 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -880,12 +880,10 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
 		df = 0;
 	}
-	err = udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
-				  tos, ttl, df, sport, geneve->dst_port,
-				  !net_eq(geneve->net, dev_net(geneve->dev)),
-				  !udp_csum);
-
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	udp_tunnel_xmit_skb(rt, gs4->sock->sk, skb, fl4.saddr, fl4.daddr,
+			    tos, ttl, df, sport, geneve->dst_port,
+			    !net_eq(geneve->net, dev_net(geneve->dev)),
+			    !udp_csum);
 	return NETDEV_TX_OK;
 
 tx_error:
@@ -964,11 +962,9 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 			ttl = 1;
 		ttl = ttl ? : ip6_dst_hoplimit(dst);
 	}
-	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
-				   &fl6.saddr, &fl6.daddr, prio, ttl,
-				   sport, geneve->dst_port, !udp_csum);
-
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev, &fl6.saddr,
+			     &fl6.daddr, prio, ttl,
+			     sport, geneve->dst_port, !udp_csum);
 	return NETDEV_TX_OK;
 
 tx_error:
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a57..5b12c38 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1843,9 +1843,10 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
-	return udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos,
-				   ttl, df, src_port, dst_port, xnet,
-				   !(vxflags & VXLAN_F_UDP_CSUM));
+	udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos, ttl, df,
+			    src_port, dst_port, xnet,
+			    !(vxflags & VXLAN_F_UDP_CSUM));
+	return 0;
 }
 
 /* Bypass encapsulation if the destination is local */
@@ -2030,8 +2031,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			skb = NULL;
 			goto rt_tx_error;
 		}
-
-		iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index ff788b6..adddf62 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -5,6 +5,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_tunnel.h>
 #include <linux/ip6_tunnel.h>
+#include <net/ip_tunnels.h>
 
 #define IP6TUNNEL_ERR_TIMEO (30*HZ)
 
@@ -83,22 +84,12 @@ int ip6_tnl_get_iflink(const struct net_device *dev);
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 				  struct net_device *dev)
 {
-	struct net_device_stats *stats = &dev->stats;
 	int pkt_len, err;
 
 	pkt_len = skb->len - skb_inner_network_offset(skb);
 	err = ip6_local_out(dev_net(skb_dst(skb)->dev), sk, skb);
-
-	if (net_xmit_eval(err) == 0) {
-		struct pcpu_sw_netstats *tstats = get_cpu_ptr(dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-		u64_stats_update_end(&tstats->syncp);
-		put_cpu_ptr(tstats);
-	} else {
-		stats->tx_errors++;
-		stats->tx_aborted_errors++;
-	}
+	if (!net_xmit_eval(err))
+		pkt_len = 0;
+	iptunnel_xmit_stats(dev, pkt_len);
 }
 #endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 62a750a..8c86d66 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -273,32 +273,30 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 }
 
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
-int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
-		  __be32 src, __be32 dst, u8 proto,
-		  u8 tos, u8 ttl, __be16 df, bool xnet);
+void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, u8 proto,
+		   u8 tos, u8 ttl, __be16 df, bool xnet);
 struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 					     gfp_t flags);
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
 					 int gso_type_mask);
 
-static inline void iptunnel_xmit_stats(int err,
-				       struct net_device_stats *err_stats,
-				       struct pcpu_sw_netstats __percpu *stats)
+static inline void iptunnel_xmit_stats(struct net_device *dev, int err)
 {
 	if (err > 0) {
-		struct pcpu_sw_netstats *tstats = get_cpu_ptr(stats);
+		struct pcpu_sw_netstats *tstats = get_cpu_ptr(dev->tstats);
 
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->tx_bytes += err;
 		tstats->tx_packets++;
 		u64_stats_update_end(&tstats->syncp);
 		put_cpu_ptr(tstats);
-	} else if (err < 0) {
+	} else {
+		struct net_device_stats *err_stats = &dev->stats;
+
 		err_stats->tx_errors++;
 		err_stats->tx_aborted_errors++;
-	} else {
-		err_stats->tx_dropped++;
 	}
 }
 
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index cb2f89f..cca2ad3 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -78,10 +78,10 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 			   struct udp_tunnel_sock_cfg *sock_cfg);
 
 /* Transmit the skb using UDP encapsulation. */
-int udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-			__be32 src, __be32 dst, __u8 tos, __u8 ttl,
-			__be16 df, __be16 src_port, __be16 dst_port,
-			bool xnet, bool nocheck);
+void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
+			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
+			 __be16 df, __be16 src_port, __be16 dst_port,
+			 bool xnet, bool nocheck);
 
 #if IS_ENABLED(CONFIG_IPV6)
 int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 04a48c0..7c51c4e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -561,10 +561,9 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 		     tunnel_id_to_key(tun_info->key.tun_id), 0);
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
-	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			    key->u.ipv4.dst, IPPROTO_GRE,
-			    key->tos, key->ttl, df, false);
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+
+	iptunnel_xmit(skb->sk, rt, skb, fl.saddr, key->u.ipv4.dst, IPPROTO_GRE,
+		      key->tos, key->ttl, df, false);
 	return;
 
 err_free_rt:
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 0f6e9ee..c7bd72e 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -656,7 +656,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;		/* Route to the other host */
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
-	int err;
 	bool connected;
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
@@ -794,10 +793,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		return;
 	}
 
-	err = iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, protocol,
-			    tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)));
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
-
+	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, protocol, tos, ttl,
+		      df, !net_eq(tunnel->net, dev_net(dev)));
 	return;
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 1db8418..eb52ce9 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -47,12 +47,13 @@
 #include <net/rtnetlink.h>
 #include <net/dst_metadata.h>
 
-int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
-		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
+void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
+		   __be32 src, __be32 dst, __u8 proto,
+		   __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
 	int pkt_len = skb->len - skb_inner_network_offset(skb);
 	struct net *net = dev_net(rt->dst.dev);
+	struct net_device *dev = skb->dev;
 	struct iphdr *iph;
 	int err;
 
@@ -81,7 +82,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	err = ip_local_out(net, sk, skb);
 	if (unlikely(net_xmit_eval(err)))
 		pkt_len = 0;
-	return pkt_len;
+	iptunnel_xmit_stats(dev, pkt_len);
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
 
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 02d9c21..5cf10b7 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -199,7 +199,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 	err = dst_output(tunnel->net, skb->sk, skb);
 	if (net_xmit_eval(err) == 0)
 		err = skb->len;
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	iptunnel_xmit_stats(dev, err);
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index aba4286..0ec0881 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -74,10 +74,10 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
 
-int udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
-			__be32 src, __be32 dst, __u8 tos, __u8 ttl,
-			__be16 df, __be16 src_port, __be16 dst_port,
-			bool xnet, bool nocheck)
+void udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
+			 __be32 src, __be32 dst, __u8 tos, __u8 ttl,
+			 __be16 df, __be16 src_port, __be16 dst_port,
+			 bool xnet, bool nocheck)
 {
 	struct udphdr *uh;
 
@@ -91,8 +91,7 @@ int udp_tunnel_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 
 	udp_set_csum(nocheck, skb, src, dst, skb->len);
 
-	return iptunnel_xmit(sk, rt, skb, src, dst, IPPROTO_UDP,
-			     tos, ttl, df, xnet);
+	iptunnel_xmit(sk, rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df, xnet);
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_xmit_skb);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dcccae8..e794ef6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -820,7 +820,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	const struct in6_addr *addr6;
 	int addr_type;
 	u8 ttl;
-	int err;
 	u8 protocol = IPPROTO_IPV6;
 	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
@@ -983,10 +982,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
 
-	err = iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr,
-			    protocol, tos, ttl, df,
-			    !net_eq(tunnel->net, dev_net(dev)));
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
+	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, protocol, tos, ttl,
+		      df, !net_eq(tunnel->net, dev_net(dev)));
 	return NETDEV_TX_OK;
 
 tx_error_icmp:
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 6af78c6..d63a911 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -182,15 +182,9 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 			goto tx_error;
 		}
 		ttl = ip4_dst_hoplimit(&rt->dst);
-		err = udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb,
-					  src->ipv4.s_addr,
-					  dst->ipv4.s_addr, 0, ttl, 0,
-					  src->udp_port, dst->udp_port,
-					  false, true);
-		if (err < 0) {
-			ip_rt_put(rt);
-			goto tx_error;
-		}
+		udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb, src->ipv4.s_addr,
+				    dst->ipv4.s_addr, 0, ttl, 0, src->udp_port,
+				    dst->udp_port, false, true);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		struct dst_entry *ndst;
-- 
1.7.1
