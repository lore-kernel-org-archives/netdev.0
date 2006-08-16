From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5] [IPv6] route: FIB6 configuration using struct fib6_config
Date: Thu, 17 Aug 2006 00:00:03 +0200
Message-ID: <20060816234343.091299066@postel.suug.ch>
References: <20060816234038.106537101@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57761 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751259AbWHPXpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 19:45:05 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ip6_fib6_config
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaces the struct in6_rtmsg based interface orignating from
the ioctl interface with a struct fib6_config based on. Allows
changing the interface without breaking the ioctl interface
and avoids passing on tons of parameters.

The recently introduced struct nl_info is used to pass on
netlink authorship information for notifications.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/ip6_fib.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip6_fib.h
+++ net-2.6.19.git/include/net/ip6_fib.h
@@ -16,14 +16,35 @@
 #ifdef __KERNEL__
 
 #include <linux/ipv6_route.h>
-
-#include <net/dst.h>
-#include <net/flow.h>
 #include <linux/rtnetlink.h>
 #include <linux/spinlock.h>
+#include <net/dst.h>
+#include <net/flow.h>
+#include <net/netlink.h>
 
 struct rt6_info;
 
+struct fib6_config
+{
+	u32		fc_table;
+	u32		fc_metric;
+	int		fc_dst_len;
+	int		fc_src_len;
+	int		fc_ifindex;
+	u32		fc_flags;
+	u32		fc_protocol;
+
+	struct in6_addr	fc_dst;
+	struct in6_addr	fc_src;
+	struct in6_addr	fc_gateway;
+
+	unsigned long	fc_expires;
+	struct nlattr	*fc_mx;
+	int		fc_mx_len;
+
+	struct nl_info	fc_nlinfo;
+};
+
 struct fib6_node
 {
 	struct fib6_node	*parent;
@@ -175,18 +196,13 @@ extern void			fib6_clean_all(int (*func)
 
 extern int			fib6_add(struct fib6_node *root,
 					 struct rt6_info *rt,
-					 struct nlmsghdr *nlh,
-					 void *rtattr,
-					 struct netlink_skb_parms *req);
+					 struct nl_info *info);
 
 extern int			fib6_del(struct rt6_info *rt,
-					 struct nlmsghdr *nlh,
-					 void *rtattr,
-					 struct netlink_skb_parms *req);
+					 struct nl_info *info);
 
 extern void			inet6_rt_notify(int event, struct rt6_info *rt,
-						struct nlmsghdr *nlh,
-						struct netlink_skb_parms *req);
+						struct nl_info *info);
 
 extern void			fib6_run_gc(unsigned long dummy);
 
Index: net-2.6.19.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/addrconf.c
+++ net-2.6.19.git/net/ipv6/addrconf.c
@@ -1509,59 +1509,56 @@ static void
 addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		      unsigned long expires, u32 flags)
 {
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg = {
+		.fc_table = RT6_TABLE_PREFIX,
+		.fc_metric = IP6_RT_PRIO_ADDRCONF,
+		.fc_ifindex = dev->ifindex,
+		.fc_expires = expires,
+		.fc_dst_len = plen,
+		.fc_flags = RTF_UP | flags,
+	};
 
-	memset(&rtmsg, 0, sizeof(rtmsg));
-	ipv6_addr_copy(&rtmsg.rtmsg_dst, pfx);
-	rtmsg.rtmsg_dst_len = plen;
-	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_info = expires;
-	rtmsg.rtmsg_flags = RTF_UP|flags;
-	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
+	ipv6_addr_copy(&cfg.fc_dst, pfx);
 
 	/* Prevent useless cloning on PtP SIT.
 	   This thing is done here expecting that the whole
 	   class of non-broadcast devices need not cloning.
 	 */
-	if (dev->type == ARPHRD_SIT && (dev->flags&IFF_POINTOPOINT))
-		rtmsg.rtmsg_flags |= RTF_NONEXTHOP;
+	if (dev->type == ARPHRD_SIT && (dev->flags & IFF_POINTOPOINT))
+		cfg.fc_flags |= RTF_NONEXTHOP;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_PREFIX);
+	ip6_route_add(&cfg);
 }
 
 /* Create "default" multicast route to the interface */
 
 static void addrconf_add_mroute(struct net_device *dev)
 {
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg = {
+		.fc_table = RT6_TABLE_LOCAL,
+		.fc_metric = IP6_RT_PRIO_ADDRCONF,
+		.fc_ifindex = dev->ifindex,
+		.fc_dst_len = 8,
+		.fc_flags = RTF_UP,
+	};
 
-	memset(&rtmsg, 0, sizeof(rtmsg));
-	ipv6_addr_set(&rtmsg.rtmsg_dst,
-		      htonl(0xFF000000), 0, 0, 0);
-	rtmsg.rtmsg_dst_len = 8;
-	rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-	rtmsg.rtmsg_ifindex = dev->ifindex;
-	rtmsg.rtmsg_flags = RTF_UP;
-	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_LOCAL);
+	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
+
+	ip6_route_add(&cfg);
 }
 
 static void sit_route_add(struct net_device *dev)
 {
-	struct in6_rtmsg rtmsg;
-
-	memset(&rtmsg, 0, sizeof(rtmsg));
-
-	rtmsg.rtmsg_type	= RTMSG_NEWROUTE;
-	rtmsg.rtmsg_metric	= IP6_RT_PRIO_ADDRCONF;
+	struct fib6_config cfg = {
+		.fc_table = RT6_TABLE_MAIN,
+		.fc_metric = IP6_RT_PRIO_ADDRCONF,
+		.fc_ifindex = dev->ifindex,
+		.fc_dst_len = 96,
+		.fc_flags = RTF_UP | RTF_NONEXTHOP,
+	};
 
 	/* prefix length - 96 bits "::d.d.d.d" */
-	rtmsg.rtmsg_dst_len	= 96;
-	rtmsg.rtmsg_flags	= RTF_UP|RTF_NONEXTHOP;
-	rtmsg.rtmsg_ifindex	= dev->ifindex;
-
-	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_MAIN);
+	ip6_route_add(&cfg);
 }
 
 static void addrconf_add_lroute(struct net_device *dev)
Index: net-2.6.19.git/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/ip6_fib.c
+++ net-2.6.19.git/net/ipv6/ip6_fib.c
@@ -610,7 +610,7 @@ insert_above:
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-		struct nlmsghdr *nlh,  struct netlink_skb_parms *req)
+			    struct nl_info *info)
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
@@ -665,7 +665,7 @@ out:
 	*ins = rt;
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
-	inet6_rt_notify(RTM_NEWROUTE, rt, nlh, req);
+	inet6_rt_notify(RTM_NEWROUTE, rt, info);
 	rt6_stats.fib_rt_entries++;
 
 	if ((fn->fn_flags & RTN_RTINFO) == 0) {
@@ -695,8 +695,7 @@ void fib6_force_start_gc(void)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, 
-		struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 {
 	struct fib6_node *fn;
 	int err = -ENOMEM;
@@ -769,7 +768,7 @@ int fib6_add(struct fib6_node *root, str
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, nlh, req);
+	err = fib6_add_rt2node(fn, rt, info);
 
 	if (err == 0) {
 		fib6_start_gc(rt);
@@ -1076,7 +1075,7 @@ static struct fib6_node * fib6_repair_tr
 }
 
 static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
-    struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
+			   struct nl_info *info)
 {
 	struct fib6_walker_t *w;
 	struct rt6_info *rt = *rtp;
@@ -1132,11 +1131,11 @@ static void fib6_del_route(struct fib6_n
 		if (atomic_read(&rt->rt6i_ref) != 1) BUG();
 	}
 
-	inet6_rt_notify(RTM_DELROUTE, rt, nlh, req);
+	inet6_rt_notify(RTM_DELROUTE, rt, info);
 	rt6_release(rt);
 }
 
-int fib6_del(struct rt6_info *rt, struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
+int fib6_del(struct rt6_info *rt, struct nl_info *info)
 {
 	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
@@ -1161,7 +1160,7 @@ int fib6_del(struct rt6_info *rt, struct
 
 	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->u.next) {
 		if (*rtp == rt) {
-			fib6_del_route(fn, rtp, nlh, _rtattr, req);
+			fib6_del_route(fn, rtp, info);
 			return 0;
 		}
 	}
@@ -1290,7 +1289,7 @@ static int fib6_clean_node(struct fib6_w
 		res = c->func(rt, c->arg);
 		if (res < 0) {
 			w->leaf = rt;
-			res = fib6_del(rt, NULL, NULL, NULL);
+			res = fib6_del(rt, NULL);
 			if (res) {
 #if RT6_DEBUG >= 2
 				printk(KERN_DEBUG "fib6_clean_node: del failed: rt=%p@%p err=%d\n", rt, rt->rt6i_node, res);
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -546,15 +546,14 @@ struct rt6_info *rt6_lookup(struct in6_a
    be destroyed.
  */
 
-static int __ip6_ins_rt(struct rt6_info *rt, struct nlmsghdr *nlh,
-			void *_rtattr, struct netlink_skb_parms *req)
+static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
 {
 	int err;
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-	err = fib6_add(&table->tb6_root, rt, nlh, _rtattr, req);
+	err = fib6_add(&table->tb6_root, rt, info);
 	write_unlock_bh(&table->tb6_lock);
 
 	return err;
@@ -562,7 +561,7 @@ static int __ip6_ins_rt(struct rt6_info 
 
 int ip6_ins_rt(struct rt6_info *rt)
 {
-	return __ip6_ins_rt(rt, NULL, NULL, NULL);
+	return __ip6_ins_rt(rt, NULL);
 }
 
 static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, struct in6_addr *daddr,
@@ -1014,30 +1013,24 @@ int ipv6_get_hoplimit(struct net_device 
  *
  */
 
-int ip6_route_add(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh, 
-		  void *_rtattr, struct netlink_skb_parms *req,
-		  u32 table_id)
+int ip6_route_add(struct fib6_config *cfg)
 {
 	int err;
-	struct rtmsg *r;
-	struct rtattr **rta;
 	struct rt6_info *rt = NULL;
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	struct fib6_table *table;
 	int addr_type;
 
-	rta = (struct rtattr **) _rtattr;
-
-	if (rtmsg->rtmsg_dst_len > 128 || rtmsg->rtmsg_src_len > 128)
+	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
 		return -EINVAL;
 #ifndef CONFIG_IPV6_SUBTREES
-	if (rtmsg->rtmsg_src_len)
+	if (cfg->fc_src_len)
 		return -EINVAL;
 #endif
-	if (rtmsg->rtmsg_ifindex) {
+	if (cfg->fc_ifindex) {
 		err = -ENODEV;
-		dev = dev_get_by_index(rtmsg->rtmsg_ifindex);
+		dev = dev_get_by_index(cfg->fc_ifindex);
 		if (!dev)
 			goto out;
 		idev = in6_dev_get(dev);
@@ -1045,10 +1038,10 @@ int ip6_route_add(struct in6_rtmsg *rtms
 			goto out;
 	}
 
-	if (rtmsg->rtmsg_metric == 0)
-		rtmsg->rtmsg_metric = IP6_RT_PRIO_USER;
+	if (cfg->fc_metric == 0)
+		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(table_id);
+	table = fib6_new_table(cfg->fc_table);
 	if (table == NULL) {
 		err = -ENOBUFS;
 		goto out;
@@ -1062,14 +1055,13 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	}
 
 	rt->u.dst.obsolete = -1;
-	rt->rt6i_expires = jiffies + clock_t_to_jiffies(rtmsg->rtmsg_info);
-	if (nlh && (r = NLMSG_DATA(nlh))) {
-		rt->rt6i_protocol = r->rtm_protocol;
-	} else {
-		rt->rt6i_protocol = RTPROT_BOOT;
-	}
+	rt->rt6i_expires = jiffies + clock_t_to_jiffies(cfg->fc_expires);
+
+	if (cfg->fc_protocol == RTPROT_UNSPEC)
+		cfg->fc_protocol = RTPROT_BOOT;
+	rt->rt6i_protocol = cfg->fc_protocol;
 
-	addr_type = ipv6_addr_type(&rtmsg->rtmsg_dst);
+	addr_type = ipv6_addr_type(&cfg->fc_dst);
 
 	if (addr_type & IPV6_ADDR_MULTICAST)
 		rt->u.dst.input = ip6_mc_input;
@@ -1078,24 +1070,22 @@ int ip6_route_add(struct in6_rtmsg *rtms
 
 	rt->u.dst.output = ip6_output;
 
-	ipv6_addr_prefix(&rt->rt6i_dst.addr, 
-			 &rtmsg->rtmsg_dst, rtmsg->rtmsg_dst_len);
-	rt->rt6i_dst.plen = rtmsg->rtmsg_dst_len;
+	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
+	rt->rt6i_dst.plen = cfg->fc_dst_len;
 	if (rt->rt6i_dst.plen == 128)
 	       rt->u.dst.flags = DST_HOST;
 
 #ifdef CONFIG_IPV6_SUBTREES
-	ipv6_addr_prefix(&rt->rt6i_src.addr, 
-			 &rtmsg->rtmsg_src, rtmsg->rtmsg_src_len);
-	rt->rt6i_src.plen = rtmsg->rtmsg_src_len;
+	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
+	rt->rt6i_src.plen = cfg->fc_src_len;
 #endif
 
-	rt->rt6i_metric = rtmsg->rtmsg_metric;
+	rt->rt6i_metric = cfg->fc_metric;
 
 	/* We cannot add true routes via loopback here,
 	   they would result in kernel looping; promote them to reject routes
 	 */
-	if ((rtmsg->rtmsg_flags&RTF_REJECT) ||
+	if ((cfg->fc_flags & RTF_REJECT) ||
 	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
 		/* hold loopback dev/idev if we haven't done so. */
 		if (dev != &loopback_dev) {
@@ -1118,12 +1108,12 @@ int ip6_route_add(struct in6_rtmsg *rtms
 		goto install_route;
 	}
 
-	if (rtmsg->rtmsg_flags & RTF_GATEWAY) {
+	if (cfg->fc_flags & RTF_GATEWAY) {
 		struct in6_addr *gw_addr;
 		int gwa_type;
 
-		gw_addr = &rtmsg->rtmsg_gateway;
-		ipv6_addr_copy(&rt->rt6i_gateway, &rtmsg->rtmsg_gateway);
+		gw_addr = &cfg->fc_gateway;
+		ipv6_addr_copy(&rt->rt6i_gateway, gw_addr);
 		gwa_type = ipv6_addr_type(gw_addr);
 
 		if (gwa_type != (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)) {
@@ -1140,7 +1130,7 @@ int ip6_route_add(struct in6_rtmsg *rtms
 			if (!(gwa_type&IPV6_ADDR_UNICAST))
 				goto out;
 
-			grt = rt6_lookup(gw_addr, NULL, rtmsg->rtmsg_ifindex, 1);
+			grt = rt6_lookup(gw_addr, NULL, cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
 			if (grt == NULL)
@@ -1172,7 +1162,7 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	if (dev == NULL)
 		goto out;
 
-	if (rtmsg->rtmsg_flags & (RTF_GATEWAY|RTF_NONEXTHOP)) {
+	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
 		rt->rt6i_nexthop = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
 		if (IS_ERR(rt->rt6i_nexthop)) {
 			err = PTR_ERR(rt->rt6i_nexthop);
@@ -1181,24 +1171,24 @@ int ip6_route_add(struct in6_rtmsg *rtms
 		}
 	}
 
-	rt->rt6i_flags = rtmsg->rtmsg_flags;
+	rt->rt6i_flags = cfg->fc_flags;
 
 install_route:
-	if (rta && rta[RTA_METRICS-1]) {
-		int attrlen = RTA_PAYLOAD(rta[RTA_METRICS-1]);
-		struct rtattr *attr = RTA_DATA(rta[RTA_METRICS-1]);
-
-		while (RTA_OK(attr, attrlen)) {
-			unsigned flavor = attr->rta_type;
-			if (flavor) {
-				if (flavor > RTAX_MAX) {
+	if (cfg->fc_mx) {
+		struct nlattr *nla;
+		int remaining;
+
+		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
+			int type = nla->nla_type;
+
+			if (type) {
+				if (type > RTAX_MAX) {
 					err = -EINVAL;
 					goto out;
 				}
-				rt->u.dst.metrics[flavor-1] =
-					*(u32 *)RTA_DATA(attr);
+
+				rt->u.dst.metrics[type - 1] = nla_get_u32(nla);
 			}
-			attr = RTA_NEXT(attr, attrlen);
 		}
 	}
 
@@ -1211,7 +1201,7 @@ install_route:
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
-	return __ip6_ins_rt(rt, nlh, _rtattr, req);
+	return __ip6_ins_rt(rt, &cfg->fc_nlinfo);
 
 out:
 	if (dev)
@@ -1223,8 +1213,7 @@ out:
 	return err;
 }
 
-static int __ip6_del_rt(struct rt6_info *rt, struct nlmsghdr *nlh,
-			void *_rtattr, struct netlink_skb_parms *req)
+static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 {
 	int err;
 	struct fib6_table *table;
@@ -1235,7 +1224,7 @@ static int __ip6_del_rt(struct rt6_info 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
 
-	err = fib6_del(rt, nlh, _rtattr, req);
+	err = fib6_del(rt, info);
 	dst_release(&rt->u.dst);
 
 	write_unlock_bh(&table->tb6_lock);
@@ -1245,44 +1234,41 @@ static int __ip6_del_rt(struct rt6_info 
 
 int ip6_del_rt(struct rt6_info *rt)
 {
-	return __ip6_del_rt(rt, NULL, NULL, NULL);
+	return __ip6_del_rt(rt, NULL);
 }
 
-static int ip6_route_del(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh,
-			 void *_rtattr, struct netlink_skb_parms *req,
-			 u32 table_id)
+static int ip6_route_del(struct fib6_config *cfg)
 {
 	struct fib6_table *table;
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 	int err = -ESRCH;
 
-	table = fib6_get_table(table_id);
+	table = fib6_get_table(cfg->fc_table);
 	if (table == NULL)
 		return err;
 
 	read_lock_bh(&table->tb6_lock);
 
 	fn = fib6_locate(&table->tb6_root,
-			 &rtmsg->rtmsg_dst, rtmsg->rtmsg_dst_len,
-			 &rtmsg->rtmsg_src, rtmsg->rtmsg_src_len);
+			 &cfg->fc_dst, cfg->fc_dst_len,
+			 &cfg->fc_src, cfg->fc_src_len);
 	
 	if (fn) {
 		for (rt = fn->leaf; rt; rt = rt->u.next) {
-			if (rtmsg->rtmsg_ifindex &&
+			if (cfg->fc_ifindex &&
 			    (rt->rt6i_dev == NULL ||
-			     rt->rt6i_dev->ifindex != rtmsg->rtmsg_ifindex))
+			     rt->rt6i_dev->ifindex != cfg->fc_ifindex))
 				continue;
-			if (rtmsg->rtmsg_flags&RTF_GATEWAY &&
-			    !ipv6_addr_equal(&rtmsg->rtmsg_gateway, &rt->rt6i_gateway))
+			if (cfg->fc_flags & RTF_GATEWAY &&
+			    !ipv6_addr_equal(&cfg->fc_gateway, &rt->rt6i_gateway))
 				continue;
-			if (rtmsg->rtmsg_metric &&
-			    rtmsg->rtmsg_metric != rt->rt6i_metric)
+			if (cfg->fc_metric && cfg->fc_metric != rt->rt6i_metric)
 				continue;
 			dst_hold(&rt->u.dst);
 			read_unlock_bh(&table->tb6_lock);
 
-			return __ip6_del_rt(rt, nlh, _rtattr, req);
+			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
@@ -1565,21 +1551,23 @@ static struct rt6_info *rt6_add_route_in
 					   struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref)
 {
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg = {
+		.fc_table	= RT6_TABLE_INFO,
+		.fc_metric	= 1024,
+		.fc_ifindex	= ifindex,
+		.fc_dst_len	= prefixlen,
+		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
+				  RTF_UP | RTF_PREF(pref),
+	};
+
+	ipv6_addr_copy(&cfg.fc_dst, prefix);
+	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
 
-	memset(&rtmsg, 0, sizeof(rtmsg));
-	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-	ipv6_addr_copy(&rtmsg.rtmsg_dst, prefix);
-	rtmsg.rtmsg_dst_len = prefixlen;
-	ipv6_addr_copy(&rtmsg.rtmsg_gateway, gwaddr);
-	rtmsg.rtmsg_metric = 1024;
-	rtmsg.rtmsg_flags = RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO | RTF_UP | RTF_PREF(pref);
 	/* We should treat it as a default route if prefix length is 0. */
 	if (!prefixlen)
-		rtmsg.rtmsg_flags |= RTF_DEFAULT;
-	rtmsg.rtmsg_ifindex = ifindex;
+		cfg.fc_flags |= RTF_DEFAULT;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_INFO);
+	ip6_route_add(&cfg);
 
 	return rt6_get_route_info(prefix, prefixlen, gwaddr, ifindex);
 }
@@ -1611,18 +1599,18 @@ struct rt6_info *rt6_add_dflt_router(str
 				     struct net_device *dev,
 				     unsigned int pref)
 {
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg = {
+		.fc_table	= RT6_TABLE_DFLT,
+		.fc_metric	= 1024,
+		.fc_ifindex	= dev->ifindex,
+		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
+				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
+	};
 
-	memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
-	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-	ipv6_addr_copy(&rtmsg.rtmsg_gateway, gwaddr);
-	rtmsg.rtmsg_metric = 1024;
-	rtmsg.rtmsg_flags = RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT | RTF_UP | RTF_EXPIRES |
-			    RTF_PREF(pref);
+	ipv6_addr_copy(&cfg.fc_gateway, gwaddr);
 
-	rtmsg.rtmsg_ifindex = dev->ifindex;
+	ip6_route_add(&cfg);
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_DFLT);
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
@@ -1649,8 +1637,27 @@ restart:
 	read_unlock_bh(&table->tb6_lock);
 }
 
+static void rtmsg_to_fib6_config(struct in6_rtmsg *rtmsg,
+				 struct fib6_config *cfg)
+{
+	memset(cfg, 0, sizeof(*cfg));
+
+	cfg->fc_table = RT6_TABLE_MAIN;
+	cfg->fc_ifindex = rtmsg->rtmsg_ifindex;
+	cfg->fc_metric = rtmsg->rtmsg_metric;
+	cfg->fc_expires = rtmsg->rtmsg_info;
+	cfg->fc_dst_len = rtmsg->rtmsg_dst_len;
+	cfg->fc_src_len = rtmsg->rtmsg_src_len;
+	cfg->fc_flags = rtmsg->rtmsg_flags;
+
+	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
+	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
+	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);
+}
+
 int ipv6_route_ioctl(unsigned int cmd, void __user *arg)
 {
+	struct fib6_config cfg;
 	struct in6_rtmsg rtmsg;
 	int err;
 
@@ -1663,16 +1670,16 @@ int ipv6_route_ioctl(unsigned int cmd, v
 				     sizeof(struct in6_rtmsg));
 		if (err)
 			return -EFAULT;
-			
+
+		rtmsg_to_fib6_config(&rtmsg, &cfg);
+
 		rtnl_lock();
 		switch (cmd) {
 		case SIOCADDRT:
-			err = ip6_route_add(&rtmsg, NULL, NULL, NULL,
-					    RT6_TABLE_MAIN);
+			err = ip6_route_add(&cfg);
 			break;
 		case SIOCDELRT:
-			err = ip6_route_del(&rtmsg, NULL, NULL, NULL,
-					    RT6_TABLE_MAIN);
+			err = ip6_route_del(&cfg);
 			break;
 		default:
 			err = -EINVAL;
@@ -1819,66 +1826,104 @@ void rt6_mtu_change(struct net_device *d
 	fib6_clean_all(rt6_mtu_change_route, 0, &arg);
 }
 
-static int inet6_rtm_to_rtmsg(struct rtmsg *r, struct rtattr **rta,
-			      struct in6_rtmsg *rtmsg)
+static struct nla_policy rtm_ipv6_policy[RTA_MAX+1] __read_mostly = {
+	[RTA_GATEWAY]           = { .minlen = sizeof(struct in6_addr) },
+	[RTA_OIF]               = { .type = NLA_U32 },
+	[RTA_PRIORITY]          = { .type = NLA_U32 },
+	[RTA_METRICS]           = { .type = NLA_NESTED },
+};
+
+static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
+			      struct fib6_config *cfg)
 {
-	memset(rtmsg, 0, sizeof(*rtmsg));
+	struct rtmsg *rtm;
+	struct nlattr *tb[RTA_MAX+1];
+	int err;
 
-	rtmsg->rtmsg_dst_len = r->rtm_dst_len;
-	rtmsg->rtmsg_src_len = r->rtm_src_len;
-	rtmsg->rtmsg_flags = RTF_UP;
-	if (r->rtm_type == RTN_UNREACHABLE)
-		rtmsg->rtmsg_flags |= RTF_REJECT;
-
-	if (rta[RTA_GATEWAY-1]) {
-		if (rta[RTA_GATEWAY-1]->rta_len != RTA_LENGTH(16))
-			return -EINVAL;
-		memcpy(&rtmsg->rtmsg_gateway, RTA_DATA(rta[RTA_GATEWAY-1]), 16);
-		rtmsg->rtmsg_flags |= RTF_GATEWAY;
-	}
-	if (rta[RTA_DST-1]) {
-		if (RTA_PAYLOAD(rta[RTA_DST-1]) < ((r->rtm_dst_len+7)>>3))
-			return -EINVAL;
-		memcpy(&rtmsg->rtmsg_dst, RTA_DATA(rta[RTA_DST-1]), ((r->rtm_dst_len+7)>>3));
-	}
-	if (rta[RTA_SRC-1]) {
-		if (RTA_PAYLOAD(rta[RTA_SRC-1]) < ((r->rtm_src_len+7)>>3))
-			return -EINVAL;
-		memcpy(&rtmsg->rtmsg_src, RTA_DATA(rta[RTA_SRC-1]), ((r->rtm_src_len+7)>>3));
-	}
-	if (rta[RTA_OIF-1]) {
-		if (rta[RTA_OIF-1]->rta_len != RTA_LENGTH(sizeof(int)))
-			return -EINVAL;
-		memcpy(&rtmsg->rtmsg_ifindex, RTA_DATA(rta[RTA_OIF-1]), sizeof(int));
-	}
-	if (rta[RTA_PRIORITY-1]) {
-		if (rta[RTA_PRIORITY-1]->rta_len != RTA_LENGTH(4))
-			return -EINVAL;
-		memcpy(&rtmsg->rtmsg_metric, RTA_DATA(rta[RTA_PRIORITY-1]), 4);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
+	if (err < 0)
+		goto errout;
+
+	err = -EINVAL;
+	rtm = nlmsg_data(nlh);
+	memset(cfg, 0, sizeof(*cfg));
+
+	cfg->fc_table = rtm->rtm_table;
+	cfg->fc_dst_len = rtm->rtm_dst_len;
+	cfg->fc_src_len = rtm->rtm_src_len;
+	cfg->fc_flags = RTF_UP;
+	cfg->fc_protocol = rtm->rtm_protocol;
+
+	if (rtm->rtm_type == RTN_UNREACHABLE)
+		cfg->fc_flags |= RTF_REJECT;
+
+	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
+	cfg->fc_nlinfo.nlh = nlh;
+
+	if (tb[RTA_GATEWAY]) {
+		nla_memcpy(&cfg->fc_gateway, tb[RTA_GATEWAY], 16);
+		cfg->fc_flags |= RTF_GATEWAY;
 	}
-	return 0;
+
+	if (tb[RTA_DST]) {
+		int plen = (rtm->rtm_dst_len + 7) >> 3;
+
+		if (nla_len(tb[RTA_DST]) < plen)
+			goto errout;
+
+		nla_memcpy(&cfg->fc_dst, tb[RTA_DST], plen);
+	}
+
+	if (tb[RTA_SRC]) {
+		int plen = (rtm->rtm_src_len + 7) >> 3;
+
+		if (nla_len(tb[RTA_SRC]) < plen)
+			goto errout;
+
+		nla_memcpy(&cfg->fc_src, tb[RTA_SRC], plen);
+	}
+
+	if (tb[RTA_OIF])
+		cfg->fc_ifindex = nla_get_u32(tb[RTA_OIF]);
+
+	if (tb[RTA_PRIORITY])
+		cfg->fc_metric = nla_get_u32(tb[RTA_PRIORITY]);
+
+	if (tb[RTA_METRICS]) {
+		cfg->fc_mx = nla_data(tb[RTA_METRICS]);
+		cfg->fc_mx_len = nla_len(tb[RTA_METRICS]);
+	}
+
+	if (tb[RTA_TABLE])
+		cfg->fc_table = nla_get_u32(tb[RTA_TABLE]);
+
+	err = 0;
+errout:
+	return err;
 }
 
 int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct rtmsg *r = NLMSG_DATA(nlh);
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg;
+	int err;
 
-	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
-		return -EINVAL;
-	return ip6_route_del(&rtmsg, nlh, arg, &NETLINK_CB(skb),
-			     rtm_get_table(arg, r->rtm_table));
+	err = rtm_to_fib6_config(skb, nlh, &cfg);
+	if (err < 0)
+		return err;
+
+	return ip6_route_del(&cfg);
 }
 
 int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct rtmsg *r = NLMSG_DATA(nlh);
-	struct in6_rtmsg rtmsg;
+	struct fib6_config cfg;
+	int err;
 
-	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
-		return -EINVAL;
-	return ip6_route_add(&rtmsg, nlh, arg, &NETLINK_CB(skb),
-			     rtm_get_table(arg, r->rtm_table));
+	err = rtm_to_fib6_config(skb, nlh, &cfg);
+	if (err < 0)
+		return err;
+
+	return ip6_route_add(&cfg);
 }
 
 static int rt6_fill_node(struct sk_buff *skb, struct rt6_info *rt,
@@ -2059,15 +2104,21 @@ out_free:
 	goto out;	
 }
 
-void inet6_rt_notify(int event, struct rt6_info *rt, struct nlmsghdr *nlh, 
-			struct netlink_skb_parms *req)
+void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 {
 	struct sk_buff *skb;
-	u32 pid = req ? req->pid : 0;
-	u32 seq = nlh ? nlh->nlmsg_seq : 0;
+	u32 pid = 0, seq = 0;
+	struct nlmsghdr *nlh = NULL;
 	int payload = sizeof(struct rtmsg) + 256;
 	int err = -ENOBUFS;
 
+	if (info) {
+		pid = info->pid;
+		nlh = info->nlh;
+		if (nlh)
+			seq = nlh->nlmsg_seq;
+	}
+
 	skb = nlmsg_new(nlmsg_total_size(payload), gfp_any());
 	if (skb == NULL)
 		goto errout;
Index: net-2.6.19.git/include/net/ip6_route.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip6_route.h
+++ net-2.6.19.git/include/net/ip6_route.h
@@ -60,11 +60,7 @@ extern void			ip6_route_cleanup(void);
 
 extern int			ipv6_route_ioctl(unsigned int cmd, void __user *arg);
 
-extern int			ip6_route_add(struct in6_rtmsg *rtmsg,
-					      struct nlmsghdr *,
-					      void *rtattr,
-					      struct netlink_skb_parms *req,
-					      u32 table_id);
+extern int			ip6_route_add(struct fib6_config *cfg);
 extern int			ip6_ins_rt(struct rt6_info *);
 extern int			ip6_del_rt(struct rt6_info *);
 

