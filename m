From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/7] ip_tunnel: replace dst_cache with generic implementation
Date: Thu, 11 Feb 2016 11:11:59 +0100
Message-ID: <dbe9eb8532b43aca86444aab6e99544d310e174c.1455184959.git.pabeni@redhat.com>
References: <cover.1455184959.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbcBKKNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 05:13:17 -0500
In-Reply-To: <cover.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current ip_tunnel cache implementation is prone to a race
that will cause the wrong dst to be cached on cuncurrent dst cache
miss and ip tunnel update via netlink.

Replacing with the generic implementation fix the issue.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip_tunnels.h |  9 ++----
 net/ipv4/Kconfig         |  1 +
 net/ipv4/ip_tunnel.c     | 78 ++++++++----------------------------------------
 net/ipv6/sit.c           | 17 ++++++-----
 4 files changed, 25 insertions(+), 80 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 6db96ea..d66797e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -13,6 +13,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/lwtunnel.h>
+#include <net/dst_cache.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -85,11 +86,6 @@ struct ip_tunnel_prl_entry {
 	struct rcu_head			rcu_head;
 };
 
-struct ip_tunnel_dst {
-	struct dst_entry __rcu 		*dst;
-	__be32				 saddr;
-};
-
 struct metadata_dst;
 
 struct ip_tunnel {
@@ -108,7 +104,7 @@ struct ip_tunnel {
 	int		tun_hlen;	/* Precalculated header length */
 	int		mlink;
 
-	struct ip_tunnel_dst __percpu *dst_cache;
+	struct dst_cache dst_cache;
 
 	struct ip_tunnel_parm parms;
 
@@ -247,7 +243,6 @@ int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
 int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
 		      struct ip_tunnel_parm *p);
 void ip_tunnel_setup(struct net_device *dev, int net_id);
-void ip_tunnel_dst_reset_all(struct ip_tunnel *t);
 int ip_tunnel_encap_setup(struct ip_tunnel *t,
 			  struct ip_tunnel_encap *ipencap);
 
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7758247..395d827 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -186,6 +186,7 @@ config NET_IPGRE_DEMUX
 
 config NET_IP_TUNNEL
 	tristate
+	select DST_CACHE
 	default n
 
 config NET_IPGRE
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index c7bd72e..4569da7 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -68,61 +68,6 @@ static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
 			 IP_TNL_HASH_BITS);
 }
 
-static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
-			     struct dst_entry *dst, __be32 saddr)
-{
-	struct dst_entry *old_dst;
-
-	dst_clone(dst);
-	old_dst = xchg((__force struct dst_entry **)&idst->dst, dst);
-	dst_release(old_dst);
-	idst->saddr = saddr;
-}
-
-static noinline void tunnel_dst_set(struct ip_tunnel *t,
-			   struct dst_entry *dst, __be32 saddr)
-{
-	__tunnel_dst_set(raw_cpu_ptr(t->dst_cache), dst, saddr);
-}
-
-static void tunnel_dst_reset(struct ip_tunnel *t)
-{
-	tunnel_dst_set(t, NULL, 0);
-}
-
-void ip_tunnel_dst_reset_all(struct ip_tunnel *t)
-{
-	int i;
-
-	for_each_possible_cpu(i)
-		__tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL, 0);
-}
-EXPORT_SYMBOL(ip_tunnel_dst_reset_all);
-
-static struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
-					u32 cookie, __be32 *saddr)
-{
-	struct ip_tunnel_dst *idst;
-	struct dst_entry *dst;
-
-	rcu_read_lock();
-	idst = raw_cpu_ptr(t->dst_cache);
-	dst = rcu_dereference(idst->dst);
-	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
-		dst = NULL;
-	if (dst) {
-		if (!dst->obsolete || dst->ops->check(dst, cookie)) {
-			*saddr = idst->saddr;
-		} else {
-			tunnel_dst_reset(t);
-			dst_release(dst);
-			dst = NULL;
-		}
-	}
-	rcu_read_unlock();
-	return (struct rtable *)dst;
-}
-
 static bool ip_tunnel_key_match(const struct ip_tunnel_parm *p,
 				__be16 flags, __be32 key)
 {
@@ -381,7 +326,8 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
-			tunnel_dst_set(tunnel, &rt->dst, fl4.saddr);
+			dst_cache_set_ip4(&tunnel->dst_cache, &rt->dst,
+					  fl4.saddr);
 			ip_rt_put(rt);
 		}
 		if (dev->type != ARPHRD_ETHER)
@@ -729,7 +675,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0)
 		goto tx_error;
 
-	rt = connected ? tunnel_rtable_get(tunnel, 0, &fl4.saddr) : NULL;
+	rt = connected ? dst_cache_get_ip4(&tunnel->dst_cache, &fl4.saddr) :
+			 NULL;
 
 	if (!rt) {
 		rt = ip_route_output_key(tunnel->net, &fl4);
@@ -739,7 +686,8 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 			goto tx_error;
 		}
 		if (connected)
-			tunnel_dst_set(tunnel, &rt->dst, fl4.saddr);
+			dst_cache_set_ip4(&tunnel->dst_cache, &rt->dst,
+					  fl4.saddr);
 	}
 
 	if (rt->dst.dev == dev) {
@@ -836,7 +784,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 		if (set_mtu)
 			dev->mtu = mtu;
 	}
-	ip_tunnel_dst_reset_all(t);
+	dst_cache_reset(&t->dst_cache);
 	netdev_state_change(dev);
 }
 
@@ -961,7 +909,7 @@ static void ip_tunnel_dev_free(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	gro_cells_destroy(&tunnel->gro_cells);
-	free_percpu(tunnel->dst_cache);
+	dst_cache_destroy(&tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1155,15 +1103,15 @@ int ip_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
-	if (!tunnel->dst_cache) {
+	err = dst_cache_init(&tunnel->dst_cache, GFP_KERNEL);
+	if (err) {
 		free_percpu(dev->tstats);
-		return -ENOMEM;
+		return err;
 	}
 
 	err = gro_cells_init(&tunnel->gro_cells, dev);
 	if (err) {
-		free_percpu(tunnel->dst_cache);
+		dst_cache_destroy(&tunnel->dst_cache);
 		free_percpu(dev->tstats);
 		return err;
 	}
@@ -1193,7 +1141,7 @@ void ip_tunnel_uninit(struct net_device *dev)
 	if (itn->fb_tunnel_dev != dev)
 		ip_tunnel_del(itn, netdev_priv(dev));
 
-	ip_tunnel_dst_reset_all(tunnel);
+	dst_cache_reset(&tunnel->dst_cache);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2066d1c..801b735 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -475,7 +475,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 		ipip6_tunnel_unlink(sitn, tunnel);
 		ipip6_tunnel_del_prl(tunnel, NULL);
 	}
-	ip_tunnel_dst_reset_all(tunnel);
+	dst_cache_reset(&tunnel->dst_cache);
 	dev_put(dev);
 }
 
@@ -1093,7 +1093,7 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 		t->parms.link = p->link;
 		ipip6_tunnel_bind_dev(t->dev);
 	}
-	ip_tunnel_dst_reset_all(t);
+	dst_cache_reset(&t->dst_cache);
 	netdev_state_change(t->dev);
 }
 
@@ -1124,7 +1124,7 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 	t->ip6rd.relay_prefix = relay_prefix;
 	t->ip6rd.prefixlen = ip6rd->prefixlen;
 	t->ip6rd.relay_prefixlen = ip6rd->relay_prefixlen;
-	ip_tunnel_dst_reset_all(t);
+	dst_cache_reset(&t->dst_cache);
 	netdev_state_change(t->dev);
 	return 0;
 }
@@ -1278,7 +1278,7 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
 			break;
 		}
-		ip_tunnel_dst_reset_all(t);
+		dst_cache_reset(&t->dst_cache);
 		netdev_state_change(dev);
 		break;
 
@@ -1339,7 +1339,7 @@ static void ipip6_dev_free(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
-	free_percpu(tunnel->dst_cache);
+	dst_cache_destroy(&tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1372,6 +1372,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 static int ipip6_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int err;
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
@@ -1382,10 +1383,10 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
-	if (!tunnel->dst_cache) {
+	err = dst_cache_init(&tunnel->dst_cache, GFP_KERNEL);
+	if (err) {
 		free_percpu(dev->tstats);
-		return -ENOMEM;
+		return err;
 	}
 
 	return 0;
-- 
1.8.3.1
