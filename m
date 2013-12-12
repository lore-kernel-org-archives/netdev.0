From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: Cache route in IP tunnels
Date: Wed, 11 Dec 2013 22:17:29 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f73.google.com ([209.85.212.73]:54066 "EHLO
	mail-vb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab3LLGRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 01:17:30 -0500
Received: by mail-vb0-f73.google.com with SMTP id m10so374180vbh.2
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 22:17:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid doing a route lookup on every packet being tunneled.

In ip_tunnel.c cache the route returned from ip_route_output if
the tunnel is "connected", that is all the routing parameters are
taken from tunnel parms for a packet. Specifically, not NBMA tunnel
and tos is from tunnel parms (not inner packet).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h |   3 ++
 net/ipv4/ip_tunnel.c     | 106 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 86 insertions(+), 23 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 732f8c6..bde50fc 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -54,6 +54,9 @@ struct ip_tunnel {
 	int		hlen;		/* Precalculated header length */
 	int		mlink;
 
+	struct		dst_entry __rcu *dst_cache;
+	spinlock_t	dst_lock;
+
 	struct ip_tunnel_parm parms;
 
 	/* for SIT */
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 90ff957..c4db0cc 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -68,6 +68,50 @@ static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
 			 IP_TNL_HASH_BITS);
 }
 
+static inline void
+tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
+{
+	struct dst_entry *old_dst;
+
+	spin_lock(&t->dst_lock);
+	old_dst = rcu_dereference_raw(t->dst_cache);
+	rcu_assign_pointer(t->dst_cache, dst);
+	dst_release(old_dst);
+	spin_unlock(&t->dst_lock);
+}
+
+static inline void
+tunnel_dst_reset(struct ip_tunnel *t)
+{
+	tunnel_dst_set(t, NULL);
+}
+
+static inline struct dst_entry *
+tunnel_dst_get(struct ip_tunnel *t)
+{
+	struct dst_entry *dst;
+
+	rcu_read_lock();
+	dst = rcu_dereference(t->dst_cache);
+	if (dst)
+		dst_hold(dst);
+	rcu_read_unlock();
+	return dst;
+}
+
+struct dst_entry *tunnel_dst_check(struct ip_tunnel *t, u32 cookie)
+{
+	struct dst_entry *dst = tunnel_dst_get(t);
+
+	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+		tunnel_dst_reset(t);
+		dst_release(dst);
+		return NULL;
+	}
+
+	return dst;
+}
+
 /* Often modified stats are per cpu, other are shared (netdev->stats) */
 struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 						struct rtnl_link_stats64 *tot)
@@ -318,11 +362,9 @@ failed:
 	return ERR_PTR(err);
 }
 
-static inline struct rtable *ip_route_output_tunnel(struct net *net,
-						    struct flowi4 *fl4,
-						    int proto,
-						    __be32 daddr, __be32 saddr,
-						    __be32 key, __u8 tos, int oif)
+static inline void init_tunnel_flow(struct flowi4 *fl4, int proto,
+				    __be32 daddr, __be32 saddr,
+				    __be32 key, __u8 tos, int oif)
 {
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_oif = oif;
@@ -331,7 +373,6 @@ static inline struct rtable *ip_route_output_tunnel(struct net *net,
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_proto = proto;
 	fl4->fl4_gre_key = key;
-	return ip_route_output_key(net, fl4);
 }
 
 static int ip_tunnel_bind_dev(struct net_device *dev)
@@ -350,12 +391,11 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 		struct flowi4 fl4;
 		struct rtable *rt;
 
-		rt = ip_route_output_tunnel(tunnel->net, &fl4,
-					    tunnel->parms.iph.protocol,
-					    iph->daddr, iph->saddr,
-					    tunnel->parms.o_key,
-					    RT_TOS(iph->tos),
-					    tunnel->parms.link);
+		init_tunnel_flow(&fl4, iph->protocol, iph->daddr,
+				 iph->saddr, tunnel->parms.o_key,
+				 RT_TOS(iph->tos), tunnel->parms.link);
+		rt = ip_route_output_key(tunnel->net, &fl4);
+
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
 			ip_rt_put(rt);
@@ -532,6 +572,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
 	int err;
+	bool connected = true;
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
@@ -581,26 +622,39 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 #endif
 		else
 			goto tx_error;
+
+		connected = false;
 	}
 
 	tos = tnl_params->tos;
 	if (tos & 0x1) {
 		tos &= ~0x1;
-		if (skb->protocol == htons(ETH_P_IP))
+		if (skb->protocol == htons(ETH_P_IP)) {
 			tos = inner_iph->tos;
-		else if (skb->protocol == htons(ETH_P_IPV6))
+			connected = false;
+		} else if (skb->protocol == htons(ETH_P_IPV6)) {
 			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
+			connected = false;
+		}
 	}
 
-	rt = ip_route_output_tunnel(tunnel->net, &fl4,
-				    protocol,
-				    dst, tnl_params->saddr,
-				    tunnel->parms.o_key,
-				    RT_TOS(tos),
-				    tunnel->parms.link);
-	if (IS_ERR(rt)) {
-		dev->stats.tx_carrier_errors++;
-		goto tx_error;
+	init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
+			 tunnel->parms.o_key, RT_TOS(tos), tunnel->parms.link);
+
+	if (connected)
+		rt = (struct rtable *)tunnel_dst_check(tunnel, 0);
+	else
+		rt = NULL;
+
+	if (!rt) {
+		rt = ip_route_output_key(tunnel->net, &fl4);
+
+		if (IS_ERR(rt)) {
+			dev->stats.tx_carrier_errors++;
+			goto tx_error;
+		}
+		if (connected)
+			tunnel_dst_set(tunnel, dst_clone(&rt->dst));
 	}
 	if (rt->dst.dev == dev) {
 		ip_rt_put(rt);
@@ -696,6 +750,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 		if (set_mtu)
 			dev->mtu = mtu;
 	}
+	tunnel_dst_reset(t);
 	netdev_state_change(dev);
 }
 
@@ -1001,6 +1056,9 @@ int ip_tunnel_init(struct net_device *dev)
 	iph->version		= 4;
 	iph->ihl		= 5;
 
+	tunnel->dst_cache = NULL;
+	spin_lock_init(&tunnel->dst_lock);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init);
@@ -1015,6 +1073,8 @@ void ip_tunnel_uninit(struct net_device *dev)
 	/* fb_tunnel_dev will be unregisted in net-exit call. */
 	if (itn->fb_tunnel_dev != dev)
 		ip_tunnel_del(netdev_priv(dev));
+
+	tunnel_dst_reset(tunnel);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
-- 
1.8.5.1
