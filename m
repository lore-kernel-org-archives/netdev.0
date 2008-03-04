From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 06/12][NETNS][IPV6] route6 - make route6 per namespace
Date: Tue, 04 Mar 2008 22:03:32 +0100
Message-ID: <20080304211023.817913201@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:44544 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbYCDVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LD1rV074212
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:01 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LD0Pg2031658
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:13:00 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LD0Lg014877
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:00 GMT
Content-Disposition: inline; filename=route6-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the routing engine use the network namespaces
to access routing informations:
Add a network namespace parameter to ipv6_route_ioctl and 
propagate the network namespace value to all the routing code
that have not yet been changed.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h |    4 +
 net/ipv6/af_inet6.c     |    3 -
 net/ipv6/route.c        |   98 ++++++++++++++++++++++++------------------------
 3 files changed, 54 insertions(+), 51 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -49,7 +49,9 @@ extern struct dst_entry *	ip6_route_outp
 extern int			ip6_route_init(void);
 extern void			ip6_route_cleanup(void);
 
-extern int			ipv6_route_ioctl(unsigned int cmd, void __user *arg);
+extern int			ipv6_route_ioctl(struct net *net,
+						 unsigned int cmd,
+						 void __user *arg);
 
 extern int			ip6_route_add(struct fib6_config *cfg);
 extern int			ip6_ins_rt(struct rt6_info *);
Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -440,6 +440,7 @@ EXPORT_SYMBOL(inet6_getname);
 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sk->sk_net;
 
 	switch(cmd)
 	{
@@ -452,7 +453,7 @@ int inet6_ioctl(struct socket *sock, uns
 	case SIOCADDRT:
 	case SIOCDELRT:
 
-		return(ipv6_route_ioctl(cmd,(void __user *)arg));
+		return(ipv6_route_ioctl(net, cmd, (void __user *)arg));
 
 	case SIOCSIFADDR:
 		return addrconf_add_ifaddr((void __user *) arg);
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -609,7 +609,7 @@ static int __ip6_ins_rt(struct rt6_info 
 int ip6_ins_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = &init_net,
+		.nl_net = rt->rt6i_dev->nd_net,
 	};
 	return __ip6_ins_rt(rt, &info);
 }
@@ -746,6 +746,7 @@ static struct rt6_info *ip6_pol_route_in
 void ip6_route_input(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct net *net = skb->dev->nd_net;
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi fl = {
 		.iif = skb->dev->ifindex,
@@ -763,7 +764,7 @@ void ip6_route_input(struct sk_buff *skb
 	if (rt6_need_strict(&iph->daddr))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	skb->dst = fib6_rule_lookup(&init_net, &fl, flags, ip6_pol_route_input);
+	skb->dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input);
 }
 
 static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
@@ -891,12 +892,12 @@ static void ip6_rt_update_pmtu(struct ds
 
 static int ipv6_get_mtu(struct net_device *dev);
 
-static inline unsigned int ipv6_advmss(unsigned int mtu)
+static inline unsigned int ipv6_advmss(struct net *net, unsigned int mtu)
 {
 	mtu -= sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
 
-	if (mtu < init_net.ipv6.sysctl.ip6_rt_min_advmss)
-		mtu = init_net.ipv6.sysctl.ip6_rt_min_advmss;
+	if (mtu < net->ipv6.sysctl.ip6_rt_min_advmss)
+		mtu = net->ipv6.sysctl.ip6_rt_min_advmss;
 
 	/*
 	 * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and
@@ -918,6 +919,7 @@ struct dst_entry *icmp6_dst_alloc(struct
 {
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);
+	struct net *net = dev->nd_net;
 
 	if (unlikely(idev == NULL))
 		return NULL;
@@ -940,7 +942,7 @@ struct dst_entry *icmp6_dst_alloc(struct
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
 	rt->u.dst.output  = ip6_output;
 
 #if 0	/* there's no chance to use these for ndisc */
@@ -956,7 +958,7 @@ struct dst_entry *icmp6_dst_alloc(struct
 	icmp6_dst_gc_list = &rt->u.dst;
 	spin_unlock_bh(&icmp6_dst_lock);
 
-	fib6_force_start_gc(dev->nd_net);
+	fib6_force_start_gc(net);
 
 out:
 	return &rt->u.dst;
@@ -1049,6 +1051,7 @@ int ipv6_get_hoplimit(struct net_device 
 int ip6_route_add(struct fib6_config *cfg)
 {
 	int err;
+	struct net *net = cfg->fc_nlinfo.nl_net;
 	struct rt6_info *rt = NULL;
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
@@ -1063,7 +1066,7 @@ int ip6_route_add(struct fib6_config *cf
 #endif
 	if (cfg->fc_ifindex) {
 		err = -ENODEV;
-		dev = dev_get_by_index(&init_net, cfg->fc_ifindex);
+		dev = dev_get_by_index(net, cfg->fc_ifindex);
 		if (!dev)
 			goto out;
 		idev = in6_dev_get(dev);
@@ -1074,7 +1077,7 @@ int ip6_route_add(struct fib6_config *cf
 	if (cfg->fc_metric == 0)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(&init_net, cfg->fc_table);
+	table = fib6_new_table(net, cfg->fc_table);
 	if (table == NULL) {
 		err = -ENOBUFS;
 		goto out;
@@ -1121,12 +1124,12 @@ int ip6_route_add(struct fib6_config *cf
 	if ((cfg->fc_flags & RTF_REJECT) ||
 	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
 		/* hold loopback dev/idev if we haven't done so. */
-		if (dev != init_net.loopback_dev) {
+		if (dev != net->loopback_dev) {
 			if (dev) {
 				dev_put(dev);
 				in6_dev_put(idev);
 			}
-			dev = init_net.loopback_dev;
+			dev = net->loopback_dev;
 			dev_hold(dev);
 			idev = in6_dev_get(dev);
 			if (!idev) {
@@ -1163,7 +1166,7 @@ int ip6_route_add(struct fib6_config *cf
 			if (!(gwa_type&IPV6_ADDR_UNICAST))
 				goto out;
 
-			grt = rt6_lookup(&init_net, gw_addr, NULL, cfg->fc_ifindex, 1);
+			grt = rt6_lookup(net, gw_addr, NULL, cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
 			if (grt == NULL)
@@ -1230,7 +1233,7 @@ install_route:
 	if (!rt->u.dst.metrics[RTAX_MTU-1])
 		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
 	if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
+		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
@@ -1271,7 +1274,7 @@ static int __ip6_del_rt(struct rt6_info 
 int ip6_del_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
-		.nl_net = &init_net,
+		.nl_net = rt->rt6i_dev->nd_net,
 	};
 	return __ip6_del_rt(rt, &info);
 }
@@ -1283,7 +1286,7 @@ static int ip6_route_del(struct fib6_con
 	struct rt6_info *rt;
 	int err = -ESRCH;
 
-	table = fib6_get_table(&init_net, cfg->fc_table);
+	table = fib6_get_table(cfg->fc_nlinfo.nl_net, cfg->fc_table);
 	if (table == NULL)
 		return err;
 
@@ -1382,6 +1385,7 @@ static struct rt6_info *ip6_route_redire
 					   struct net_device *dev)
 {
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
+	struct net *net = dev->nd_net;
 	struct ip6rd_flowi rdfl = {
 		.fl = {
 			.oif = dev->ifindex,
@@ -1398,8 +1402,7 @@ static struct rt6_info *ip6_route_redire
 	if (rt6_need_strict(dest))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	return (struct rt6_info *)fib6_rule_lookup(&init_net,
-						   (struct flowi *)&rdfl,
+	return (struct rt6_info *)fib6_rule_lookup(net, (struct flowi *)&rdfl,
 						   flags, __ip6_route_redirect);
 }
 
@@ -1457,7 +1460,8 @@ void rt6_redirect(struct in6_addr *dest,
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
 	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&nrt->u.dst));
+	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(neigh->dev->nd_net,
+							dst_mtu(&nrt->u.dst));
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1485,9 +1489,10 @@ void rt6_pmtu_discovery(struct in6_addr 
 			struct net_device *dev, u32 pmtu)
 {
 	struct rt6_info *rt, *nrt;
+	struct net *net = dev->nd_net;
 	int allfrag = 0;
 
-	rt = rt6_lookup(dev->nd_net, daddr, saddr, dev->ifindex, 0);
+	rt = rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
 	if (rt == NULL)
 		return;
 
@@ -1520,7 +1525,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 		rt->u.dst.metrics[RTAX_MTU-1] = pmtu;
 		if (allfrag)
 			rt->u.dst.metrics[RTAX_FEATURES-1] |= RTAX_FEATURE_ALLFRAG;
-		dst_set_expires(&rt->u.dst, init_net.ipv6.sysctl.ip6_rt_mtu_expires);
+		dst_set_expires(&rt->u.dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		rt->rt6i_flags |= RTF_MODIFIED|RTF_EXPIRES;
 		goto out;
 	}
@@ -1546,7 +1551,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 		 * which is 10 mins. After 10 mins the decreased pmtu is expired
 		 * and detecting PMTU increase will be automatically happened.
 		 */
-		dst_set_expires(&nrt->u.dst, init_net.ipv6.sysctl.ip6_rt_mtu_expires);
+		dst_set_expires(&nrt->u.dst, net->ipv6.sysctl.ip6_rt_mtu_expires);
 		nrt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
 
 		ip6_ins_rt(nrt);
@@ -1659,7 +1664,7 @@ struct rt6_info *rt6_get_dflt_router(str
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
-	table = fib6_get_table(&init_net, RT6_TABLE_DFLT);
+	table = fib6_get_table(dev->nd_net, RT6_TABLE_DFLT);
 	if (table == NULL)
 		return NULL;
 
@@ -1688,6 +1693,9 @@ struct rt6_info *rt6_add_dflt_router(str
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
 				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.nl_net = dev->nd_net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
@@ -1720,7 +1728,8 @@ restart:
 	read_unlock_bh(&table->tb6_lock);
 }
 
-static void rtmsg_to_fib6_config(struct in6_rtmsg *rtmsg,
+static void rtmsg_to_fib6_config(struct net *net,
+				 struct in6_rtmsg *rtmsg,
 				 struct fib6_config *cfg)
 {
 	memset(cfg, 0, sizeof(*cfg));
@@ -1733,14 +1742,14 @@ static void rtmsg_to_fib6_config(struct 
 	cfg->fc_src_len = rtmsg->rtmsg_src_len;
 	cfg->fc_flags = rtmsg->rtmsg_flags;
 
-	cfg->fc_nlinfo.nl_net = &init_net;
+	cfg->fc_nlinfo.nl_net = net;
 
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
 }
 
-int ipv6_route_ioctl(unsigned int cmd, void __user *arg)
+int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 {
 	struct fib6_config cfg;
 	struct in6_rtmsg rtmsg;
@@ -1756,7 +1765,7 @@ int ipv6_route_ioctl(unsigned int cmd, v
 		if (err)
 			return -EFAULT;
 
-		rtmsg_to_fib6_config(&rtmsg, &cfg);
+		rtmsg_to_fib6_config(net, &rtmsg, &cfg);
 
 		rtnl_lock();
 		switch (cmd) {
@@ -1835,21 +1844,22 @@ struct rt6_info *addrconf_dst_alloc(stru
 				    const struct in6_addr *addr,
 				    int anycast)
 {
+	struct net *net = idev->dev->nd_net;
 	struct rt6_info *rt = ip6_dst_alloc();
 
 	if (rt == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	dev_hold(init_net.loopback_dev);
+	dev_hold(net->loopback_dev);
 	in6_dev_hold(idev);
 
 	rt->u.dst.flags = DST_HOST;
 	rt->u.dst.input = ip6_input;
 	rt->u.dst.output = ip6_output;
-	rt->rt6i_dev = init_net.loopback_dev;
+	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
 	rt->u.dst.obsolete = -1;
 
@@ -1866,7 +1876,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
-	rt->rt6i_table = fib6_get_table(&init_net, RT6_TABLE_LOCAL);
+	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);
 
 	atomic_set(&rt->u.dst.__refcnt, 1);
 
@@ -1898,6 +1908,7 @@ static int rt6_mtu_change_route(struct r
 {
 	struct rt6_mtu_change_arg *arg = (struct rt6_mtu_change_arg *) p_arg;
 	struct inet6_dev *idev;
+	struct net *net = arg->dev->nd_net;
 
 	/* In IPv6 pmtu discovery is not optional,
 	   so that RTAX_MTU lock cannot disable it.
@@ -1929,7 +1940,7 @@ static int rt6_mtu_change_route(struct r
 	     (dst_mtu(&rt->u.dst) < arg->mtu &&
 	      dst_mtu(&rt->u.dst) == idev->cnf.mtu6))) {
 		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(arg->mtu);
+		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, arg->mtu);
 	}
 	return 0;
 }
@@ -2024,13 +2035,9 @@ errout:
 
 static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
 	struct fib6_config cfg;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
@@ -2040,13 +2047,9 @@ static int inet6_rtm_delroute(struct sk_
 
 static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct net *net = skb->sk->sk_net;
 	struct fib6_config cfg;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib6_config(skb, nlh, &cfg);
 	if (err < 0)
 		return err;
@@ -2190,9 +2193,6 @@ static int inet6_rtm_getroute(struct sk_
 	struct flowi fl;
 	int err, iif = 0;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
 	if (err < 0)
 		goto errout;
@@ -2222,7 +2222,7 @@ static int inet6_rtm_getroute(struct sk_
 
 	if (iif) {
 		struct net_device *dev;
-		dev = __dev_get_by_index(&init_net, iif);
+		dev = __dev_get_by_index(net, iif);
 		if (!dev) {
 			err = -ENODEV;
 			goto errout;
@@ -2252,7 +2252,7 @@ static int inet6_rtm_getroute(struct sk_
 		goto errout;
 	}
 
-	err = rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
 errout:
 	return err;
 }
@@ -2260,6 +2260,7 @@ errout:
 void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 {
 	struct sk_buff *skb;
+	struct net *net = info->nl_net;
 	u32 seq;
 	int err;
 
@@ -2278,11 +2279,11 @@ void inet6_rt_notify(int event, struct r
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, info->pid,
-				RTNLGRP_IPV6_ROUTE, info->nlh, gfp_any());
+	err = rtnl_notify(skb, net, info->pid, RTNLGRP_IPV6_ROUTE,
+			  info->nlh, gfp_any());
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_IPV6_ROUTE, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_ROUTE, err);
 }
 
 /*
@@ -2544,6 +2545,7 @@ static void ip6_route_net_exit(struct ne
 	proc_net_remove(net, "ipv6_route");
 	proc_net_remove(net, "rt6_stats");
 #endif
+	rt6_ifdown(net, NULL);
 }
 
 static struct pernet_operations ip6_route_net_ops = {
@@ -2592,7 +2594,6 @@ fib6_rules_init:
 xfrm6_init:
 	xfrm6_fini();
 out_fib6_init:
-	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();
 out_kmem_cache:
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
@@ -2604,7 +2605,6 @@ void ip6_route_cleanup(void)
 	unregister_pernet_subsys(&ip6_route_net_ops);
 	fib6_rules_cleanup();
 	xfrm6_fini();
-	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 }

-- 
