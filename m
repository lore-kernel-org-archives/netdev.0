From: David Miller <davem@davemloft.net>
Subject: ipv6: Kill rt6i_dev and rt6i_expires defines.
Date: Wed, 28 Dec 2011 20:19:46 -0500 (EST)
Message-ID: <20111228.201946.1520800066762055324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010Ab1L2BTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 20:19:50 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBT1JlBR004299
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 17:19:49 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It just obscures that the netdevice pointer and the expires value are
implemented in the dst_entry sub-object of the ipv6 route.

And it makes grepping for dst_entry member uses much harder too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next

 include/net/ip6_fib.h           |    3 --
 net/ipv6/addrconf.c             |    8 +++---
 net/ipv6/anycast.c              |    2 +-
 net/ipv6/ip6_fib.c              |   10 +++---
 net/ipv6/ip6_tunnel.c           |   10 +++---
 net/ipv6/mcast.c                |    4 +-
 net/ipv6/ndisc.c                |    2 +-
 net/ipv6/route.c                |   58 +++++++++++++++++++-------------------
 net/netfilter/ipvs/ip_vs_ctl.c  |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |    2 +-
 10 files changed, 49 insertions(+), 52 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 5735a0f..1e8a89f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -86,9 +86,6 @@ struct fib6_table;
 struct rt6_info {
 	struct dst_entry		dst;
 
-#define rt6i_dev			dst.dev
-#define rt6i_expires			dst.expires
-
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
 	 * and these elements (rarely used in hot path) are in
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 85421cc..647e6cb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -797,7 +797,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 				ip6_del_rt(rt);
 				rt = NULL;
 			} else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
-				rt->rt6i_expires = expires;
+				rt->dst.expires = expires;
 				rt->rt6i_flags |= RTF_EXPIRES;
 			}
 		}
@@ -1723,7 +1723,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	if (!fn)
 		goto out;
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
-		if (rt->rt6i_dev->ifindex != dev->ifindex)
+		if (rt->dst.dev->ifindex != dev->ifindex)
 			continue;
 		if ((rt->rt6i_flags & flags) != flags)
 			continue;
@@ -1881,11 +1881,11 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 				rt = NULL;
 			} else if (addrconf_finite_timeout(rt_expires)) {
 				/* not infinity */
-				rt->rt6i_expires = jiffies + rt_expires;
+				rt->dst.expires = jiffies + rt_expires;
 				rt->rt6i_flags |= RTF_EXPIRES;
 			} else {
 				rt->rt6i_flags &= ~RTF_EXPIRES;
-				rt->rt6i_expires = 0;
+				rt->dst.expires = 0;
 			}
 		} else if (valid_lft) {
 			clock_t expires = 0;
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index cc540f9..59402b4 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -83,7 +83,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
-			dev = rt->rt6i_dev;
+			dev = rt->dst.dev;
 			dst_release(&rt->dst);
 		} else if (ishost) {
 			err = -EADDRNOTAVAIL;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 2783631..246d8e4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -667,16 +667,16 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 				break;
 			}
 
-			if (iter->rt6i_dev == rt->rt6i_dev &&
+			if (iter->dst.dev == rt->dst.dev &&
 			    iter->rt6i_idev == rt->rt6i_idev &&
 			    ipv6_addr_equal(&iter->rt6i_gateway,
 					    &rt->rt6i_gateway)) {
 				if (!(iter->rt6i_flags & RTF_EXPIRES))
 					return -EEXIST;
-				iter->rt6i_expires = rt->rt6i_expires;
+				iter->dst.expires = rt->dst.expires;
 				if (!(rt->rt6i_flags & RTF_EXPIRES)) {
 					iter->rt6i_flags &= ~RTF_EXPIRES;
-					iter->rt6i_expires = 0;
+					iter->dst.expires = 0;
 				}
 				return -EEXIST;
 			}
@@ -1521,8 +1521,8 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 	 *	only if they are not in use now.
 	 */
 
-	if (rt->rt6i_flags & RTF_EXPIRES && rt->rt6i_expires) {
-		if (time_after(now, rt->rt6i_expires)) {
+	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {
+		if (time_after(now, rt->dst.expires)) {
 			RT6_TRACE("expiring %p\n", rt);
 			return -1;
 		}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index f5f98f5..e1f7761 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -653,8 +653,8 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr,
 				NULL, 0, 0);
 
-		if (rt && rt->rt6i_dev)
-			skb2->dev = rt->rt6i_dev;
+		if (rt && rt->dst.dev)
+			skb2->dev = rt->dst.dev;
 
 		icmpv6_send(skb2, rel_type, rel_code, rel_info);
 
@@ -1185,11 +1185,11 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 		if (rt == NULL)
 			return;
 
-		if (rt->rt6i_dev) {
-			dev->hard_header_len = rt->rt6i_dev->hard_header_len +
+		if (rt->dst.dev) {
+			dev->hard_header_len = rt->dst.dev->hard_header_len +
 				sizeof (struct ipv6hdr);
 
-			dev->mtu = rt->rt6i_dev->mtu - sizeof (struct ipv6hdr);
+			dev->mtu = rt->dst.dev->mtu - sizeof (struct ipv6hdr);
 			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 				dev->mtu-=8;
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index ea34d58..b853f06 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -162,7 +162,7 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		struct rt6_info *rt;
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
-			dev = rt->rt6i_dev;
+			dev = rt->dst.dev;
 			dst_release(&rt->dst);
 		}
 	} else
@@ -256,7 +256,7 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
 		struct rt6_info *rt = rt6_lookup(net, group, NULL, 0, 0);
 
 		if (rt) {
-			dev = rt->rt6i_dev;
+			dev = rt->dst.dev;
 			dev_hold(dev);
 			dst_release(&rt->dst);
 		}
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 538a619..3b1fe4b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1258,7 +1258,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	}
 
 	if (rt)
-		rt->rt6i_expires = jiffies + (HZ * lifetime);
+		rt->dst.expires = jiffies + (HZ * lifetime);
 
 	if (ra_msg->icmph.icmp6_hop_limit) {
 		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6bf6094..0940729 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -314,7 +314,7 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 static __inline__ int rt6_check_expired(const struct rt6_info *rt)
 {
 	return (rt->rt6i_flags & RTF_EXPIRES) &&
-		time_after(jiffies, rt->rt6i_expires);
+		time_after(jiffies, rt->dst.expires);
 }
 
 static inline int rt6_need_strict(const struct in6_addr *daddr)
@@ -340,7 +340,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 		goto out;
 
 	for (sprt = rt; sprt; sprt = sprt->dst.rt6_next) {
-		struct net_device *dev = sprt->rt6i_dev;
+		struct net_device *dev = sprt->dst.dev;
 
 		if (oif) {
 			if (dev->ifindex == oif)
@@ -401,7 +401,7 @@ static void rt6_probe(struct rt6_info *rt)
 
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(rt->rt6i_dev, NULL, target, &mcaddr, NULL);
+		ndisc_send_ns(rt->dst.dev, NULL, target, &mcaddr, NULL);
 	} else {
 		read_unlock_bh(&neigh->lock);
 	}
@@ -419,7 +419,7 @@ static inline void rt6_probe(struct rt6_info *rt)
  */
 static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 {
-	struct net_device *dev = rt->rt6i_dev;
+	struct net_device *dev = rt->dst.dev;
 	if (!oif || dev->ifindex == oif)
 		return 2;
 	if ((dev->flags & IFF_LOOPBACK) &&
@@ -538,7 +538,7 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 			fn->rr_ptr = next;
 	}
 
-	net = dev_net(rt0->rt6i_dev);
+	net = dev_net(rt0->dst.dev);
 	return match ? match : net->ipv6.ip6_null_entry;
 }
 
@@ -607,7 +607,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		if (!addrconf_finite_timeout(lifetime)) {
 			rt->rt6i_flags &= ~RTF_EXPIRES;
 		} else {
-			rt->rt6i_expires = jiffies + HZ * lifetime;
+			rt->dst.expires = jiffies + HZ * lifetime;
 			rt->rt6i_flags |= RTF_EXPIRES;
 		}
 		dst_release(&rt->dst);
@@ -709,7 +709,7 @@ static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
 int ip6_ins_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = dev_net(rt->rt6i_dev),
+		.nl_net = dev_net(rt->dst.dev),
 	};
 	return __ip6_ins_rt(rt, &info);
 }
@@ -747,7 +747,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 
 	retry:
 		if (rt6_bind_neighbour(rt)) {
-			struct net *net = dev_net(rt->rt6i_dev);
+			struct net *net = dev_net(rt->dst.dev);
 			int saved_rt_min_interval =
 				net->ipv6.sysctl.ip6_rt_gc_min_interval;
 			int saved_rt_elasticity =
@@ -931,7 +931,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
-		rt->rt6i_expires = 0;
+		rt->dst.expires = 0;
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
@@ -1265,7 +1265,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	}
 
 	rt->dst.obsolete = -1;
-	rt->rt6i_expires = (cfg->fc_flags & RTF_EXPIRES) ?
+	rt->dst.expires = (cfg->fc_flags & RTF_EXPIRES) ?
 				jiffies + clock_t_to_jiffies(cfg->fc_expires) :
 				0;
 
@@ -1360,12 +1360,12 @@ int ip6_route_add(struct fib6_config *cfg)
 			if (!grt)
 				goto out;
 			if (dev) {
-				if (dev != grt->rt6i_dev) {
+				if (dev != grt->dst.dev) {
 					dst_release(&grt->dst);
 					goto out;
 				}
 			} else {
-				dev = grt->rt6i_dev;
+				dev = grt->dst.dev;
 				idev = grt->rt6i_idev;
 				dev_hold(dev);
 				in6_dev_hold(grt->rt6i_idev);
@@ -1445,7 +1445,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 {
 	int err;
 	struct fib6_table *table;
-	struct net *net = dev_net(rt->rt6i_dev);
+	struct net *net = dev_net(rt->dst.dev);
 
 	if (rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
@@ -1464,7 +1464,7 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 int ip6_del_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = dev_net(rt->rt6i_dev),
+		.nl_net = dev_net(rt->dst.dev),
 	};
 	return __ip6_del_rt(rt, &info);
 }
@@ -1489,8 +1489,8 @@ static int ip6_route_del(struct fib6_config *cfg)
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 			if (cfg->fc_ifindex &&
-			    (!rt->rt6i_dev ||
-			     rt->rt6i_dev->ifindex != cfg->fc_ifindex))
+			    (!rt->dst.dev ||
+			     rt->dst.dev->ifindex != cfg->fc_ifindex))
 				continue;
 			if (cfg->fc_flags & RTF_GATEWAY &&
 			    !ipv6_addr_equal(&cfg->fc_gateway, &rt->rt6i_gateway))
@@ -1552,7 +1552,7 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if (fl6->flowi6_oif != rt->rt6i_dev->ifindex)
+		if (fl6->flowi6_oif != rt->dst.dev->ifindex)
 			continue;
 		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;
@@ -1778,7 +1778,7 @@ void rt6_pmtu_discovery(const struct in6_addr *daddr, const struct in6_addr *sad
 static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 				    const struct in6_addr *dest)
 {
-	struct net *net = dev_net(ort->rt6i_dev);
+	struct net *net = dev_net(ort->dst.dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
 					    ort->dst.dev, 0);
 
@@ -1795,7 +1795,7 @@ static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
 		rt->dst.lastuse = jiffies;
-		rt->rt6i_expires = 0;
+		rt->dst.expires = 0;
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
@@ -1829,7 +1829,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		goto out;
 
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
-		if (rt->rt6i_dev->ifindex != ifindex)
+		if (rt->dst.dev->ifindex != ifindex)
 			continue;
 		if ((rt->rt6i_flags & (RTF_ROUTEINFO|RTF_GATEWAY)) != (RTF_ROUTEINFO|RTF_GATEWAY))
 			continue;
@@ -1884,7 +1884,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 
 	write_lock_bh(&table->tb6_lock);
 	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
-		if (dev == rt->rt6i_dev &&
+		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
 			break;
@@ -2128,7 +2128,7 @@ static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
 	struct net *net = ((struct arg_dev_net_ip *)arg)->net;
 	struct in6_addr *addr = ((struct arg_dev_net_ip *)arg)->addr;
 
-	if (((void *)rt->rt6i_dev == dev || !dev) &&
+	if (((void *)rt->dst.dev == dev || !dev) &&
 	    rt != net->ipv6.ip6_null_entry &&
 	    ipv6_addr_equal(addr, &rt->rt6i_prefsrc.addr)) {
 		/* remove prefsrc entry */
@@ -2158,7 +2158,7 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	const struct arg_dev_net *adn = arg;
 	const struct net_device *dev = adn->dev;
 
-	if ((rt->rt6i_dev == dev || !dev) &&
+	if ((rt->dst.dev == dev || !dev) &&
 	    rt != adn->net->ipv6.ip6_null_entry)
 		return -1;
 
@@ -2211,7 +2211,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	   also have the lowest MTU, TOO BIG MESSAGE will be lead to
 	   PMTU discouvery.
 	 */
-	if (rt->rt6i_dev == arg->dev &&
+	if (rt->dst.dev == arg->dev &&
 	    !dst_metric_locked(&rt->dst, RTAX_MTU) &&
 	    (dst_mtu(&rt->dst) >= arg->mtu ||
 	     (dst_mtu(&rt->dst) < arg->mtu &&
@@ -2392,7 +2392,7 @@ static int rt6_fill_node(struct net *net,
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
-	else if (rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
+	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
 		rtm->rtm_type = RTN_LOCAL;
 	else
 		rtm->rtm_type = RTN_UNICAST;
@@ -2460,14 +2460,14 @@ static int rt6_fill_node(struct net *net,
 	rcu_read_unlock();
 
 	if (rt->dst.dev)
-		NLA_PUT_U32(skb, RTA_OIF, rt->rt6i_dev->ifindex);
+		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
 
 	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
 
 	if (!(rt->rt6i_flags & RTF_EXPIRES))
 		expires = 0;
-	else if (rt->rt6i_expires - jiffies < INT_MAX)
-		expires = rt->rt6i_expires - jiffies;
+	else if (rt->dst.expires - jiffies < INT_MAX)
+		expires = rt->dst.expires - jiffies;
 	else
 		expires = INT_MAX;
 
@@ -2661,7 +2661,7 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_printf(m, " %08x %08x %08x %08x %8s\n",
 		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
 		   rt->dst.__use, rt->rt6i_flags,
-		   rt->rt6i_dev ? rt->rt6i_dev->name : "");
+		   rt->dst.dev ? rt->dst.dev->name : "");
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 008bf97..03df505 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -85,7 +85,7 @@ static int __ip_vs_addr_is_local_v6(struct net *net,
 	};
 
 	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
-	if (rt && rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
+	if (rt && rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
 		return 1;
 
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 72b82b8..7fd66de 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -207,7 +207,7 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 
 static inline int __ip_vs_is_local_route6(struct rt6_info *rt)
 {
-	return rt->rt6i_dev && rt->rt6i_dev->flags & IFF_LOOPBACK;
+	return rt->dst.dev && rt->dst.dev->flags & IFF_LOOPBACK;
 }
 
 static struct dst_entry *
-- 
1.7.7.4
