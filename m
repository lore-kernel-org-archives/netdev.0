From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 2/7] net: replace dst_cache ip6_tunnel implementation with the generic one
Date: Fri, 12 Feb 2016 15:43:54 +0100
Message-ID: <fd2ad3eddff3905a46d59e71e44edde035fb800c.1455287867.git.pabeni@redhat.com>
References: <cover.1455287867.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbcBLOoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:44:22 -0500
In-Reply-To: <cover.1455287867.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fix a potential race into the existing tunnel code, which
could lead to the wrong dst to be permanenty cached:

CPU1:					CPU2:
  <xmit on ip6_tunnel>
  <cache lookup fails>
  dst = ip6_route_output(...)
					<tunnel params are changed via nl>
					dst_cache_reset() // no effect,
							// the cache is empty
  dst_cache_set() // the wrong dst
	// is permanenty stored
	// into the cache

With the new dst implementation the above race is not possible
since the first cache lookup after dst_cache_reset will fail due
to the timestamp check

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_tunnel.h |  14 +------
 net/ipv6/Kconfig         |   1 +
 net/ipv6/ip6_gre.c       |  12 +++---
 net/ipv6/ip6_tunnel.c    | 103 +++--------------------------------------------
 net/ipv6/ip6_vti.c       |   2 +-
 5 files changed, 16 insertions(+), 116 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 0d0ce0b..499a707 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -6,6 +6,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/ip6_tunnel.h>
 #include <net/ip_tunnels.h>
+#include <net/dst_cache.h>
 
 #define IP6TUNNEL_ERR_TIMEO (30*HZ)
 
@@ -33,12 +34,6 @@ struct __ip6_tnl_parm {
 	__be32			o_key;
 };
 
-struct ip6_tnl_dst {
-	seqlock_t lock;
-	struct dst_entry __rcu *dst;
-	u32 cookie;
-};
-
 /* IPv6 tunnel */
 struct ip6_tnl {
 	struct ip6_tnl __rcu *next;	/* next tunnel in list */
@@ -46,7 +41,7 @@ struct ip6_tnl {
 	struct net *net;	/* netns for packet i/o */
 	struct __ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
-	struct ip6_tnl_dst __percpu *dst_cache;	/* cached dst */
+	struct dst_cache dst_cache;	/* cached dst */
 
 	int err_count;
 	unsigned long err_time;
@@ -66,11 +61,6 @@ struct ipv6_tlv_tnl_enc_lim {
 	__u8 encap_limit;	/* tunnel encapsulation limit   */
 } __packed;
 
-struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t);
-int ip6_tnl_dst_init(struct ip6_tnl *t);
-void ip6_tnl_dst_destroy(struct ip6_tnl *t);
-void ip6_tnl_dst_reset(struct ip6_tnl *t);
-void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst);
 int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		const struct in6_addr *raddr);
 int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 40c8975..11e875f 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -207,6 +207,7 @@ config IPV6_NDISC_NODETYPE
 config IPV6_TUNNEL
 	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
 	select INET6_TUNNEL
+	select DST_CACHE
 	---help---
 	  Support for IPv6-in-IPv6 and IPv4-in-IPv6 tunnels described in
 	  RFC 2473.
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f37f18b..a94e506 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -360,7 +360,7 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 	struct ip6gre_net *ign = net_generic(t->net, ip6gre_net_id);
 
 	ip6gre_tunnel_unlink(ign, t);
-	ip6_tnl_dst_reset(t);
+	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
 }
 
@@ -633,7 +633,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	}
 
 	if (!fl6->flowi6_mark)
-		dst = ip6_tnl_dst_get(tunnel);
+		dst = dst_cache_get(&tunnel->dst_cache);
 
 	if (!dst) {
 		dst = ip6_route_output(net, NULL, fl6);
@@ -702,7 +702,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	}
 
 	if (!fl6->flowi6_mark && ndst)
-		ip6_tnl_dst_set(tunnel, ndst);
+		dst_cache_set_ip6(&tunnel->dst_cache, ndst, &fl6->saddr);
 	skb_dst_set(skb, dst);
 
 	proto = NEXTHDR_GRE;
@@ -1009,7 +1009,7 @@ static int ip6gre_tnl_change(struct ip6_tnl *t,
 	t->parms.o_key = p->o_key;
 	t->parms.i_flags = p->i_flags;
 	t->parms.o_flags = p->o_flags;
-	ip6_tnl_dst_reset(t);
+	dst_cache_reset(&t->dst_cache);
 	ip6gre_tnl_link_config(t, set_mtu);
 	return 0;
 }
@@ -1219,7 +1219,7 @@ static void ip6gre_dev_free(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
-	ip6_tnl_dst_destroy(t);
+	dst_cache_destroy(&t->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1257,7 +1257,7 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	ret = ip6_tnl_dst_init(tunnel);
+	ret = dst_cache_init(&tunnel->dst_cache, GFP_KERNEL);
 	if (ret) {
 		free_percpu(dev->tstats);
 		dev->tstats = NULL;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 137fca4..3f3aabd 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -122,97 +122,6 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
-/*
- * Locking : hash tables are protected by RCU and RTNL
- */
-
-static void ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
-				    struct dst_entry *dst)
-{
-	write_seqlock_bh(&idst->lock);
-	dst_release(rcu_dereference_protected(
-			    idst->dst,
-			    lockdep_is_held(&idst->lock.lock)));
-	if (dst) {
-		dst_hold(dst);
-		idst->cookie = rt6_get_cookie((struct rt6_info *)dst);
-	} else {
-		idst->cookie = 0;
-	}
-	rcu_assign_pointer(idst->dst, dst);
-	write_sequnlock_bh(&idst->lock);
-}
-
-struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t)
-{
-	struct ip6_tnl_dst *idst;
-	struct dst_entry *dst;
-	unsigned int seq;
-	u32 cookie;
-
-	idst = raw_cpu_ptr(t->dst_cache);
-
-	rcu_read_lock();
-	do {
-		seq = read_seqbegin(&idst->lock);
-		dst = rcu_dereference(idst->dst);
-		cookie = idst->cookie;
-	} while (read_seqretry(&idst->lock, seq));
-
-	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
-		dst = NULL;
-	rcu_read_unlock();
-
-	if (dst && dst->obsolete && !dst->ops->check(dst, cookie)) {
-		ip6_tnl_per_cpu_dst_set(idst, NULL);
-		dst_release(dst);
-		dst = NULL;
-	}
-	return dst;
-}
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_get);
-
-void ip6_tnl_dst_reset(struct ip6_tnl *t)
-{
-	int i;
-
-	for_each_possible_cpu(i)
-		ip6_tnl_per_cpu_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
-}
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
-
-void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst)
-{
-	ip6_tnl_per_cpu_dst_set(raw_cpu_ptr(t->dst_cache), dst);
-
-}
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_set);
-
-void ip6_tnl_dst_destroy(struct ip6_tnl *t)
-{
-	if (!t->dst_cache)
-		return;
-
-	ip6_tnl_dst_reset(t);
-	free_percpu(t->dst_cache);
-}
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_destroy);
-
-int ip6_tnl_dst_init(struct ip6_tnl *t)
-{
-	int i;
-
-	t->dst_cache = alloc_percpu(struct ip6_tnl_dst);
-	if (!t->dst_cache)
-		return -ENOMEM;
-
-	for_each_possible_cpu(i)
-		seqlock_init(&per_cpu_ptr(t->dst_cache, i)->lock);
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ip6_tnl_dst_init);
-
 /**
  * ip6_tnl_lookup - fetch tunnel matching the end-point addresses
  *   @remote: the address of the tunnel exit-point
@@ -329,7 +238,7 @@ static void ip6_dev_free(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
-	ip6_tnl_dst_destroy(t);
+	dst_cache_destroy(&t->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -462,7 +371,7 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
 	else
 		ip6_tnl_unlink(ip6n, t);
-	ip6_tnl_dst_reset(t);
+	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
 }
 
@@ -1069,7 +978,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
 		neigh_release(neigh);
 	} else if (!fl6->flowi6_mark)
-		dst = ip6_tnl_dst_get(t);
+		dst = dst_cache_get(&t->dst_cache);
 
 	if (!ip6_tnl_xmit_ctl(t, &fl6->saddr, &fl6->daddr))
 		goto tx_err_link_failure;
@@ -1133,7 +1042,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	}
 
 	if (!fl6->flowi6_mark && ndst)
-		ip6_tnl_dst_set(t, ndst);
+		dst_cache_set_ip6(&t->dst_cache, ndst, &fl6->saddr);
 	skb_dst_set(skb, dst);
 
 	skb->transport_header = skb->network_header;
@@ -1366,7 +1275,7 @@ ip6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 	t->parms.flowinfo = p->flowinfo;
 	t->parms.link = p->link;
 	t->parms.proto = p->proto;
-	ip6_tnl_dst_reset(t);
+	dst_cache_reset(&t->dst_cache);
 	ip6_tnl_link_config(t);
 	return 0;
 }
@@ -1637,7 +1546,7 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	ret = ip6_tnl_dst_init(t);
+	ret = dst_cache_init(&t->dst_cache, GFP_KERNEL);
 	if (ret) {
 		free_percpu(dev->tstats);
 		dev->tstats = NULL;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 0a8610b..d90a11f 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -640,7 +640,7 @@ vti6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 	t->parms.i_key = p->i_key;
 	t->parms.o_key = p->o_key;
 	t->parms.proto = p->proto;
-	ip6_tnl_dst_reset(t);
+	dst_cache_reset(&t->dst_cache);
 	vti6_link_config(t);
 	return 0;
 }
-- 
1.8.3.1
