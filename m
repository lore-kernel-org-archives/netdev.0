From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] ipv6: Various cleanups in route.c
Date: Sat, 03 Dec 2011 22:24:01 -0500 (EST)
Message-ID: <20111203.222401.1347568830056423903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab1LDDYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 22:24:03 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB43O1Oi014246
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 3 Dec 2011 19:24:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) x == NULL --> !x
2) x != NULL --> x
3) (x&BIT) --> (x & BIT)
4) (BIT1|BIT2) --> (BIT1 | BIT2)
5) proper argument and struct member alignment

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |   95 +++++++++++++++++++++++++++--------------------------
 1 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0e381bb..897a13f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -247,9 +247,9 @@ static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
 {
 	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, flags);
 
-	if (rt != NULL)
+	if (rt)
 		memset(&rt->rt6i_table, 0,
-			sizeof(*rt) - sizeof(struct dst_entry));
+		       sizeof(*rt) - sizeof(struct dst_entry));
 
 	return rt;
 }
@@ -263,7 +263,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
 
-	if (idev != NULL) {
+	if (idev) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
@@ -299,10 +299,10 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	struct net_device *loopback_dev =
 		dev_net(dev)->loopback_dev;
 
-	if (dev != loopback_dev && idev != NULL && idev->dev == dev) {
+	if (dev != loopback_dev && idev && idev->dev == dev) {
 		struct inet6_dev *loopback_idev =
 			in6_dev_get(loopback_dev);
-		if (loopback_idev != NULL) {
+		if (loopback_idev) {
 			rt->rt6i_idev = loopback_idev;
 			in6_dev_put(idev);
 		}
@@ -344,7 +344,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 			if (dev->ifindex == oif)
 				return sprt;
 			if (dev->flags & IFF_LOOPBACK) {
-				if (sprt->rt6i_idev == NULL ||
+				if (!sprt->rt6i_idev ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
 					if (flags & RT6_LOOKUP_F_IFACE && oif)
 						continue;
@@ -636,7 +636,7 @@ do { \
 				goto restart; \
 		} \
 	} \
-} while(0)
+} while (0)
 
 static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 					     struct fib6_table *table,
@@ -727,7 +727,7 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 		struct neighbour *neigh;
 		int attempts = !in_softirq();
 
-		if (!(rt->rt6i_flags&RTF_GATEWAY)) {
+		if (!(rt->rt6i_flags & RTF_GATEWAY)) {
 			if (rt->rt6i_dst.plen != 128 &&
 			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
 				rt->rt6i_flags |= RTF_ANYCAST;
@@ -875,7 +875,7 @@ void ip6_route_input(struct sk_buff *skb)
 		.flowi6_iif = skb->dev->ifindex,
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
-		.flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
+		.flowlabel = (* (__be32 *) iph) & IPV6_FLOWINFO_MASK,
 		.flowi6_mark = skb->mark,
 		.flowi6_proto = iph->nexthdr,
 	};
@@ -997,7 +997,7 @@ static void ip6_link_failure(struct sk_buff *skb)
 
 	rt = (struct rt6_info *) skb_dst(skb);
 	if (rt) {
-		if (rt->rt6i_flags&RTF_CACHE) {
+		if (rt->rt6i_flags & RTF_CACHE) {
 			dst_set_expires(&rt->dst, 0);
 			rt->rt6i_flags |= RTF_EXPIRES;
 		} else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT))
@@ -1073,11 +1073,11 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	struct inet6_dev *idev = in6_dev_get(dev);
 	struct net *net = dev_net(dev);
 
-	if (unlikely(idev == NULL))
+	if (unlikely(!idev))
 		return NULL;
 
 	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
-	if (unlikely(rt == NULL)) {
+	if (unlikely(!rt)) {
 		in6_dev_put(idev);
 		goto out;
 	}
@@ -1238,23 +1238,23 @@ int ip6_route_add(struct fib6_config *cfg)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
 	err = -ENOBUFS;
-	if (NULL != cfg->fc_nlinfo.nlh &&
-	    !(cfg->fc_nlinfo.nlh->nlmsg_flags&NLM_F_CREATE)) {
+	if (cfg->fc_nlinfo.nlh &&
+	    !(cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_CREATE)) {
 		table = fib6_get_table(net, cfg->fc_table);
-		if (table == NULL) {
+		if (!table) {
 			printk(KERN_WARNING "IPv6: NLM_F_CREATE should be specified when creating new route\n");
 			table = fib6_new_table(net, cfg->fc_table);
 		}
 	} else {
 		table = fib6_new_table(net, cfg->fc_table);
 	}
-	if (table == NULL) {
+
+	if (!table)
 		goto out;
-	}
 
 	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, DST_NOCOUNT);
 
-	if (rt == NULL) {
+	if (!rt) {
 		err = -ENOMEM;
 		goto out;
 	}
@@ -1303,8 +1303,9 @@ int ip6_route_add(struct fib6_config *cfg)
 	   they would result in kernel looping; promote them to reject routes
 	 */
 	if ((cfg->fc_flags & RTF_REJECT) ||
-	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK)
-					      && !(cfg->fc_flags&RTF_LOCAL))) {
+	    (dev && (dev->flags & IFF_LOOPBACK) &&
+	     !(addr_type & IPV6_ADDR_LOOPBACK) &&
+	     !(cfg->fc_flags & RTF_LOCAL))) {
 		/* hold loopback dev/idev if we haven't done so. */
 		if (dev != net->loopback_dev) {
 			if (dev) {
@@ -1345,13 +1346,13 @@ int ip6_route_add(struct fib6_config *cfg)
 			   some exceptions. --ANK
 			 */
 			err = -EINVAL;
-			if (!(gwa_type&IPV6_ADDR_UNICAST))
+			if (!(gwa_type & IPV6_ADDR_UNICAST))
 				goto out;
 
 			grt = rt6_lookup(net, gw_addr, NULL, cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
-			if (grt == NULL)
+			if (!grt)
 				goto out;
 			if (dev) {
 				if (dev != grt->rt6i_dev) {
@@ -1364,7 +1365,7 @@ int ip6_route_add(struct fib6_config *cfg)
 				dev_hold(dev);
 				in6_dev_hold(grt->rt6i_idev);
 			}
-			if (!(grt->rt6i_flags&RTF_GATEWAY))
+			if (!(grt->rt6i_flags & RTF_GATEWAY))
 				err = 0;
 			dst_release(&grt->dst);
 
@@ -1372,12 +1373,12 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 		}
 		err = -EINVAL;
-		if (dev == NULL || (dev->flags&IFF_LOOPBACK))
+		if (!dev || (dev->flags & IFF_LOOPBACK))
 			goto out;
 	}
 
 	err = -ENODEV;
-	if (dev == NULL)
+	if (!dev)
 		goto out;
 
 	if (!ipv6_addr_any(&cfg->fc_prefsrc)) {
@@ -1474,7 +1475,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 	int err = -ESRCH;
 
 	table = fib6_get_table(cfg->fc_nlinfo.nl_net, cfg->fc_table);
-	if (table == NULL)
+	if (!table)
 		return err;
 
 	read_lock_bh(&table->tb6_lock);
@@ -1486,7 +1487,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 			if (cfg->fc_ifindex &&
-			    (rt->rt6i_dev == NULL ||
+			    (!rt->rt6i_dev ||
 			     rt->rt6i_dev->ifindex != cfg->fc_ifindex))
 				continue;
 			if (cfg->fc_flags & RTF_GATEWAY &&
@@ -1631,7 +1632,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 		goto out;
 
 	nrt = ip6_rt_copy(rt, dest);
-	if (nrt == NULL)
+	if (!nrt)
 		goto out;
 
 	nrt->rt6i_flags = RTF_GATEWAY|RTF_UP|RTF_DYNAMIC|RTF_CACHE;
@@ -1648,7 +1649,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	netevent.new = &nrt->dst;
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
-	if (rt->rt6i_flags&RTF_CACHE) {
+	if (rt->rt6i_flags & RTF_CACHE) {
 		ip6_del_rt(rt);
 		return;
 	}
@@ -1669,7 +1670,7 @@ static void rt6_do_pmtu_disc(const struct in6_addr *daddr, const struct in6_addr
 	int allfrag = 0;
 again:
 	rt = rt6_lookup(net, daddr, saddr, ifindex, 0);
-	if (rt == NULL)
+	if (!rt)
 		return;
 
 	if (rt6_check_expired(rt)) {
@@ -1817,7 +1818,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	struct fib6_table *table;
 
 	table = fib6_get_table(net, RT6_TABLE_INFO);
-	if (table == NULL)
+	if (!table)
 		return NULL;
 
 	write_lock_bh(&table->tb6_lock);
@@ -1876,7 +1877,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	struct fib6_table *table;
 
 	table = fib6_get_table(dev_net(dev), RT6_TABLE_DFLT);
-	if (table == NULL)
+	if (!table)
 		return NULL;
 
 	write_lock_bh(&table->tb6_lock);
@@ -1921,7 +1922,7 @@ void rt6_purge_dflt_routers(struct net *net)
 
 	/* NOTE: Keep consistent with rt6_get_dflt_router */
 	table = fib6_get_table(net, RT6_TABLE_DFLT);
-	if (table == NULL)
+	if (!table)
 		return;
 
 restart:
@@ -2061,7 +2062,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					    net->loopback_dev, 0);
 	struct neighbour *neigh;
 
-	if (rt == NULL) {
+	if (!rt) {
 		if (net_ratelimit())
 			pr_warning("IPv6:  Maximum number of routes reached,"
 				   " consider increasing route/max_size.\n");
@@ -2127,7 +2128,7 @@ static int fib6_remove_prefsrc(struct rt6_info *rt, void *arg)
 	struct net *net = ((struct arg_dev_net_ip *)arg)->net;
 	struct in6_addr *addr = ((struct arg_dev_net_ip *)arg)->addr;
 
-	if (((void *)rt->rt6i_dev == dev || dev == NULL) &&
+	if (((void *)rt->rt6i_dev == dev || !dev) &&
 	    rt != net->ipv6.ip6_null_entry &&
 	    ipv6_addr_equal(addr, &rt->rt6i_prefsrc.addr)) {
 		/* remove prefsrc entry */
@@ -2157,7 +2158,7 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	const struct arg_dev_net *adn = arg;
 	const struct net_device *dev = adn->dev;
 
-	if ((rt->rt6i_dev == dev || dev == NULL) &&
+	if ((rt->rt6i_dev == dev || !dev) &&
 	    rt != adn->net->ipv6.ip6_null_entry) {
 		RT6_TRACE("deleted by ifdown %p\n", rt);
 		return -1;
@@ -2194,7 +2195,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	*/
 
 	idev = __in6_dev_get(arg->dev);
-	if (idev == NULL)
+	if (!idev)
 		return 0;
 
 	/* For administrative MTU increase, there is no way to discover
@@ -2374,7 +2375,7 @@ static int rt6_fill_node(struct net *net,
 	}
 
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*rtm), flags);
-	if (nlh == NULL)
+	if (!nlh)
 		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
@@ -2388,25 +2389,25 @@ static int rt6_fill_node(struct net *net,
 		table = RT6_TABLE_UNSPEC;
 	rtm->rtm_table = table;
 	NLA_PUT_U32(skb, RTA_TABLE, table);
-	if (rt->rt6i_flags&RTF_REJECT)
+	if (rt->rt6i_flags & RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
-	else if (rt->rt6i_flags&RTF_LOCAL)
+	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
-	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
+	else if (rt->rt6i_dev && (rt->rt6i_dev->flags & IFF_LOOPBACK))
 		rtm->rtm_type = RTN_LOCAL;
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
-	if (rt->rt6i_flags&RTF_DYNAMIC)
+	if (rt->rt6i_flags & RTF_DYNAMIC)
 		rtm->rtm_protocol = RTPROT_REDIRECT;
 	else if (rt->rt6i_flags & RTF_ADDRCONF)
 		rtm->rtm_protocol = RTPROT_KERNEL;
-	else if (rt->rt6i_flags&RTF_DEFAULT)
+	else if (rt->rt6i_flags & RTF_DEFAULT)
 		rtm->rtm_protocol = RTPROT_RA;
 
-	if (rt->rt6i_flags&RTF_CACHE)
+	if (rt->rt6i_flags & RTF_CACHE)
 		rtm->rtm_flags |= RTM_F_CLONED;
 
 	if (dst) {
@@ -2546,7 +2547,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	}
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (skb == NULL) {
+	if (!skb) {
 		err = -ENOBUFS;
 		goto errout;
 	}
@@ -2581,10 +2582,10 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 	int err;
 
 	err = -ENOBUFS;
-	seq = info->nlh != NULL ? info->nlh->nlmsg_seq : 0;
+	seq = info->nlh ? info->nlh->nlmsg_seq : 0;
 
 	skb = nlmsg_new(rt6_nlmsg_size(), gfp_any());
-	if (skb == NULL)
+	if (!skb)
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-- 
1.7.7.3
