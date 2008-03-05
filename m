From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 5/9][NETNS][IPV6] addrconf - make addrconf per namespace
Date: Wed, 05 Mar 2008 18:56:54 +0100
Message-ID: <20080305180200.664742731@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:57091 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753433AbYCESCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:05 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25I248T339586
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:04 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I24WI2142382
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:04 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I243I012003
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:04 GMT
Content-Disposition: inline; filename=addrconf-truly-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the infrastructure to propagate the network namespace
information is ready. Make use of it.

There is a special case here between the initial network namespace
and the other namespaces:

* When ipv6 is initialized at boot time (aka in the init_net), it 
registers to the notifier callback. So addrconf_notify will be called
as many time as there are network devices setup on the system and the
function will add ipv6 addresses to the network devices. But the first
device which needs to have its ipv6 address setup is the loopback, 
unfortunatly this is not the case. So the loopback address is setup
manually in the ipv6 init function.

* With the network namespace, this ordering problem does not appears
because notifier is already setup and active, so as soon as we register
the loopback the ipv6 address is setup and it will be the first device.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/addrconf.c |  113 +++++++++++++++++++++++-----------------------------
 1 file changed, 50 insertions(+), 63 deletions(-)

Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -561,7 +561,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
-	if (ipv6_chk_same_addr(&init_net, addr, idev->dev)) {
+	if (ipv6_chk_same_addr(idev->dev->nd_net, addr, idev->dev)) {
 		ADBG(("ipv6_add_addr: already assigned\n"));
 		err = -EEXIST;
 		goto out;
@@ -751,9 +751,9 @@ static void ipv6_del_addr(struct inet6_i
 	if ((ifp->flags & IFA_F_PERMANENT) && onlink < 1) {
 		struct in6_addr prefix;
 		struct rt6_info *rt;
-
+		struct net *net = ifp->idev->dev->nd_net;
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-		rt = rt6_lookup(&init_net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
+		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
@@ -905,6 +905,7 @@ int ipv6_dev_get_saddr(struct net_device
 {
 	struct ipv6_saddr_score hiscore;
 	struct inet6_ifaddr *ifa_result = NULL;
+	struct net *net = daddr_dev->nd_net;
 	int daddr_type = __ipv6_addr_type(daddr);
 	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
 	int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;
@@ -916,7 +917,7 @@ int ipv6_dev_get_saddr(struct net_device
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
 
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		struct inet6_dev *idev;
 		struct inet6_ifaddr *ifa;
 
@@ -1555,7 +1556,7 @@ addrconf_prefix_route(struct in6_addr *p
 		.fc_expires = expires,
 		.fc_dst_len = plen,
 		.fc_flags = RTF_UP | flags,
-		.fc_nlinfo.nl_net = &init_net,
+		.fc_nlinfo.nl_net = dev->nd_net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, pfx);
@@ -1582,7 +1583,7 @@ static void addrconf_add_mroute(struct n
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
 		.fc_flags = RTF_UP,
-		.fc_nlinfo.nl_net = &init_net,
+		.fc_nlinfo.nl_net = dev->nd_net,
 	};
 
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
@@ -1599,7 +1600,7 @@ static void sit_route_add(struct net_dev
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 96,
 		.fc_flags = RTF_UP | RTF_NONEXTHOP,
-		.fc_nlinfo.nl_net = &init_net,
+		.fc_nlinfo.nl_net = dev->nd_net,
 	};
 
 	/* prefix length - 96 bits "::d.d.d.d" */
@@ -1700,7 +1701,8 @@ void addrconf_prefix_rcv(struct net_devi
 
 	if (pinfo->onlink) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(&init_net, &pinfo->prefix, NULL, dev->ifindex, 1);
+		rt = rt6_lookup(dev->nd_net, &pinfo->prefix, NULL,
+				dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (rt->rt6i_flags&RTF_EXPIRES) {
@@ -1743,7 +1745,7 @@ void addrconf_prefix_rcv(struct net_devi
 
 ok:
 
-		ifp = ipv6_get_ifaddr(&init_net, &addr, dev, 1);
+		ifp = ipv6_get_ifaddr(dev->nd_net, &addr, dev, 1);
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
@@ -2066,6 +2068,7 @@ static void sit_add_v4_addrs(struct inet
 	struct inet6_ifaddr * ifp;
 	struct in6_addr addr;
 	struct net_device *dev;
+	struct net *net = idev->dev->nd_net;
 	int scope;
 
 	ASSERT_RTNL();
@@ -2092,7 +2095,7 @@ static void sit_add_v4_addrs(struct inet
 		return;
 	}
 
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		struct in_device * in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev && (dev->flags & IFF_UP)) {
 			struct in_ifaddr * ifa;
@@ -2255,15 +2258,16 @@ ipv6_inherit_linklocal(struct inet6_dev 
 static void ip6_tnl_add_linklocal(struct inet6_dev *idev)
 {
 	struct net_device *link_dev;
+	struct net *net = idev->dev->nd_net;
 
 	/* first try to inherit the link-local address from the link device */
 	if (idev->dev->iflink &&
-	    (link_dev = __dev_get_by_index(&init_net, idev->dev->iflink))) {
+	    (link_dev = __dev_get_by_index(net, idev->dev->iflink))) {
 		if (!ipv6_inherit_linklocal(idev, link_dev))
 			return;
 	}
 	/* then try to inherit it from any device */
-	for_each_netdev(&init_net, link_dev) {
+	for_each_netdev(net, link_dev) {
 		if (!ipv6_inherit_linklocal(idev, link_dev))
 			return;
 	}
@@ -2296,9 +2300,6 @@ static int addrconf_notify(struct notifi
 	int run_pending = 0;
 	int err;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch(event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
@@ -3056,9 +3057,6 @@ inet6_rtm_deladdr(struct sk_buff *skb, s
 	struct in6_addr *pfx;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
@@ -3121,9 +3119,6 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	u8 ifa_flags;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		return err;
@@ -3324,12 +3319,13 @@ static int inet6_dump_addr(struct sk_buf
 	struct inet6_ifaddr *ifa;
 	struct ifmcaddr6 *ifmca;
 	struct ifacaddr6 *ifaca;
+	struct net *net = skb->sk->sk_net;
 
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
 
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (idx < s_idx)
 			goto cont;
 		if (idx > s_idx)
@@ -3396,35 +3392,23 @@ cont:
 
 static int inet6_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
 	enum addr_type_t type = UNICAST_ADDR;
 
-	if (net != &init_net)
-		return 0;
-
 	return inet6_dump_addr(skb, cb, type);
 }
 
 static int inet6_dump_ifmcaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
 	enum addr_type_t type = MULTICAST_ADDR;
 
-	if (net != &init_net)
-		return 0;
-
 	return inet6_dump_addr(skb, cb, type);
 }
 
 
 static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = skb->sk->sk_net;
 	enum addr_type_t type = ANYCAST_ADDR;
 
-	if (net != &init_net)
-		return 0;
-
 	return inet6_dump_addr(skb, cb, type);
 }
 
@@ -3440,9 +3424,6 @@ static int inet6_rtm_getaddr(struct sk_b
 	struct sk_buff *skb;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
 	if (err < 0)
 		goto errout;
@@ -3455,7 +3436,7 @@ static int inet6_rtm_getaddr(struct sk_b
 
 	ifm = nlmsg_data(nlh);
 	if (ifm->ifa_index)
-		dev = __dev_get_by_index(&init_net, ifm->ifa_index);
+		dev = __dev_get_by_index(net, ifm->ifa_index);
 
 	if ((ifa = ipv6_get_ifaddr(net, addr, dev, 1)) == NULL) {
 		err = -EADDRNOTAVAIL;
@@ -3475,7 +3456,7 @@ static int inet6_rtm_getaddr(struct sk_b
 		kfree_skb(skb);
 		goto errout_ifa;
 	}
-	err = rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
 errout_ifa:
 	in6_ifa_put(ifa);
 errout:
@@ -3485,6 +3466,7 @@ errout:
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
+	struct net *net = ifa->idev->dev->nd_net;
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
@@ -3498,10 +3480,10 @@ static void inet6_ifa_notify(int event, 
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_IPV6_IFADDR, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
 }
 
 static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
@@ -3666,12 +3648,9 @@ static int inet6_dump_ifinfo(struct sk_b
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	if (net != &init_net)
-		return 0;
-
 	read_lock(&dev_base_lock);
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (idx < s_idx)
 			goto cont;
 		if ((idev = in6_dev_get(dev)) == NULL)
@@ -3693,6 +3672,7 @@ cont:
 void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 {
 	struct sk_buff *skb;
+	struct net *net = idev->dev->nd_net;
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_if_nlmsg_size(), GFP_ATOMIC);
@@ -3706,10 +3686,10 @@ void inet6_ifinfo_notify(int event, stru
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_IPV6_IFADDR, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
 }
 
 static inline size_t inet6_prefix_nlmsg_size(void)
@@ -3762,6 +3742,7 @@ static void inet6_prefix_notify(int even
 			 struct prefix_info *pinfo)
 {
 	struct sk_buff *skb;
+	struct net *net = idev->dev->nd_net;
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(inet6_prefix_nlmsg_size(), GFP_ATOMIC);
@@ -3775,10 +3756,10 @@ static void inet6_prefix_notify(int even
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
+	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_IPV6_PREFIX, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_PREFIX, err);
 }
 
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
@@ -4276,7 +4257,26 @@ static int addrconf_net_init(struct net 
 
 static void addrconf_net_exit(struct net *net)
 {
-	;
+	struct net_device *dev;
+
+	/*
+	 * Remove loopback references from default routing entries
+	 */
+/* 	in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev); */
+/* #ifdef CONFIG_IPV6_MULTIPLE_TABLES */
+/* 	in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev); */
+/* 	in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev); */
+/* #endif */
+
+	rtnl_lock();
+	/* clean dev list */
+	for_each_netdev(net, dev) {
+		if (__in6_dev_get(dev) == NULL)
+			continue;
+		addrconf_ifdown(dev, 1);
+	}
+	addrconf_ifdown(net->loopback_dev, 2);
+	rtnl_unlock();
 }
 
 static struct pernet_operations addrconf_net_ops = {
@@ -4357,7 +4357,6 @@ errlo:
 
 void addrconf_cleanup(void)
 {
-	struct net_device *dev;
 	struct inet6_ifaddr *ifa;
 	int i;
 
@@ -4369,20 +4368,8 @@ void addrconf_cleanup(void)
 	rtnl_lock();
 
 	/*
-	 *	clean dev list.
-	 */
-
-	for_each_netdev(&init_net, dev) {
-		if (__in6_dev_get(dev) == NULL)
-			continue;
-		addrconf_ifdown(dev, 1);
-	}
-	addrconf_ifdown(init_net.loopback_dev, 2);
-
-	/*
 	 *	Check hash table.
 	 */
-
 	write_lock_bh(&addrconf_hash_lock);
 	for (i=0; i < IN6_ADDR_HSIZE; i++) {
 		for (ifa=inet6_addr_lst[i]; ifa; ) {

-- 
