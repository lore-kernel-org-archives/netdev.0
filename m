From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 3/4] tunnels: harmonize cleanup done on skb on xmit path
Date: Wed, 28 Aug 2013 17:20:09 +0200
Message-ID: <1377703210-7021-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, jesse@nicira.com, dev@openvswitch.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38410 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754329Ab3H1PUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:20:18 -0400
In-Reply-To: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to harmonize cleanup done on a skbuff on xmit path.
Before this patch, behaviors were different depending of the tunnel type.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c         | 3 ++-
 include/net/ip6_tunnel.h    | 1 -
 include/net/ip_tunnels.h    | 2 +-
 net/ipv4/ip_tunnel.c        | 6 ++----
 net/ipv4/ip_tunnel_core.c   | 7 +++----
 net/ipv6/ip6_gre.c          | 4 ++--
 net/ipv6/ip6_tunnel.c       | 4 +---
 net/ipv6/sit.c              | 5 +----
 net/openvswitch/vport-gre.c | 2 +-
 9 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3bc27c2ca569..aaf9a8f5ee55 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1171,7 +1171,8 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
 	if (err)
 		return err;
 
-	return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df);
+	return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df,
+			     false);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 2265b0bf97e5..6d1549c4893c 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -75,7 +75,6 @@ static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_device_stats *stats = &dev->stats;
 	int pkt_len, err;
 
-	nf_reset(skb);
 	pkt_len = skb->len;
 	err = ip6_local_out(skb);
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 94fe8fd07bc9..a0a4a100f5c9 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -148,7 +148,7 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df);
+		  __u8 tos, __u8 ttl, __be16 df, bool xnet);
 
 static inline void iptunnel_xmit_stats(int err,
 				       struct net_device_stats *err_stats,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b0e74e17088f..88d7d7d1eccb 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -614,9 +614,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (!net_eq(tunnel->net, dev_net(dev)))
-		skb_scrub_packet(skb, true);
-
 	if (tunnel->err_count > 0) {
 		if (time_before(jiffies,
 				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
@@ -655,7 +652,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
-			    ip_tunnel_ecn_encap(tos, inner_iph, skb), ttl, df);
+			    ip_tunnel_ecn_encap(tos, inner_iph, skb), ttl, df,
+			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
 	return;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index e82045842351..d6c856b17fd4 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -48,16 +48,15 @@
 
 int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
-		  __u8 tos, __u8 ttl, __be16 df)
+		  __u8 tos, __u8 ttl, __be16 df, bool xnet)
 {
 	int pkt_len = skb->len;
 	struct iphdr *iph;
 	int err;
 
-	nf_reset(skb);
-	secpath_reset(skb);
+	skb_scrub_packet(skb, xnet);
+
 	skb->rxhash = 0;
-	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f2d0a42f8057..f179ff1f56ec 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -694,6 +694,8 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 			tunnel->err_count = 0;
 	}
 
+	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
+
 	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
@@ -710,8 +712,6 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		skb = new_skb;
 	}
 
-	skb_dst_drop(skb);
-
 	if (fl6->flowi6_mark) {
 		skb_dst_set(skb, dst);
 		ndst = NULL;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 72372ac90159..ecbcdbd4bc4f 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1001,8 +1001,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		goto tx_err_dst_release;
 	}
 
-	if (!net_eq(t->net, dev_net(dev)))
-		skb_scrub_packet(skb, true);
+	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
 
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
@@ -1021,7 +1020,6 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		consume_skb(skb);
 		skb = new_skb;
 	}
-	skb_dst_drop(skb);
 	if (fl6->flowi6_mark) {
 		skb_dst_set(skb, dst);
 		ndst = NULL;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b2e44f478e14..82b425b9b7d2 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -860,9 +860,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			tunnel->err_count = 0;
 	}
 
-	if (!net_eq(tunnel->net, dev_net(dev)))
-		skb_scrub_packet(skb, true);
-
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
@@ -889,7 +886,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
-			    ttl, df);
+			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 9b3713ef831e..c99dea543d64 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -179,7 +179,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	return iptunnel_xmit(rt, skb, fl.saddr,
 			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
 			     OVS_CB(skb)->tun_key->ipv4_tos,
-			     OVS_CB(skb)->tun_key->ipv4_ttl, df);
+			     OVS_CB(skb)->tun_key->ipv4_ttl, df, false);
 err_free_rt:
 	ip_rt_put(rt);
 error:
-- 
1.8.2.1
