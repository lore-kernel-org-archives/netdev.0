From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/4] net: ipv6: Plumb extack through route add functions
Date: Sun, 21 May 2017 10:12:04 -0600
Message-ID: <20170521161205.36720-4-dsahern@gmail.com>
References: <20170521161205.36720-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35773 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756727AbdEUQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:12:30 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so14777603pfd.2
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:12:29 -0700 (PDT)
In-Reply-To: <20170521161205.36720-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Plumb extack argument down to route add functions.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip6_fib.h   |  3 ++-
 include/net/ip6_route.h |  2 +-
 net/ipv6/addrconf.c     |  4 ++--
 net/ipv6/ip6_fib.c      | 14 +++++++-----
 net/ipv6/route.c        | 57 +++++++++++++++++++++++++++----------------------
 5 files changed, 46 insertions(+), 34 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c979c878df1c..aa50e2e6fa2a 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -277,7 +277,8 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
 
 int fib6_add(struct fib6_node *root, struct rt6_info *rt,
-	     struct nl_info *info, struct mx6_config *mxc);
+	     struct nl_info *info, struct mx6_config *mxc,
+	     struct netlink_ext_ack *extack);
 int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
 void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f5e625f53367..f3da9dd2a8db 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -90,7 +90,7 @@ void ip6_route_cleanup(void);
 
 int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg);
 
-int ip6_route_add(struct fib6_config *cfg);
+int ip6_route_add(struct fib6_config *cfg, struct netlink_ext_ack *extack);
 int ip6_ins_rt(struct rt6_info *);
 int ip6_del_rt(struct rt6_info *);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a4fb1e629fb..25443fd946a8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2280,7 +2280,7 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		cfg.fc_flags |= RTF_NONEXTHOP;
 #endif
 
-	ip6_route_add(&cfg);
+	ip6_route_add(&cfg, NULL);
 }
 
 
@@ -2335,7 +2335,7 @@ static void addrconf_add_mroute(struct net_device *dev)
 
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
 
-	ip6_route_add(&cfg);
+	ip6_route_add(&cfg, NULL);
 }
 
 static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d4bf2c68a545..c1197e167d3e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -473,7 +473,8 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
 				     struct in6_addr *addr, int plen,
 				     int offset, int allow_create,
-				     int replace_required, int sernum)
+				     int replace_required, int sernum,
+				     struct netlink_ext_ack *extack)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -964,7 +965,8 @@ void fib6_force_start_gc(struct net *net)
  */
 
 int fib6_add(struct fib6_node *root, struct rt6_info *rt,
-	     struct nl_info *info, struct mx6_config *mxc)
+	     struct nl_info *info, struct mx6_config *mxc,
+	     struct netlink_ext_ack *extack)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -987,7 +989,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
-			replace_required, sernum);
+			replace_required, sernum, extack);
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
 		fn = NULL;
@@ -1028,7 +1030,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required, sernum);
+					allow_create, replace_required, sernum,
+					extack);
 
 			if (IS_ERR(sn)) {
 				/* If it is failed, discard just allocated
@@ -1047,7 +1050,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required, sernum);
+					allow_create, replace_required, sernum,
+					extack);
 
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc61b0b5e64e..ca754ec4054a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -938,14 +938,15 @@ EXPORT_SYMBOL(rt6_lookup);
  */
 
 static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
-			struct mx6_config *mxc)
+			struct mx6_config *mxc,
+			struct netlink_ext_ack *extack)
 {
 	int err;
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-	err = fib6_add(&table->tb6_root, rt, info, mxc);
+	err = fib6_add(&table->tb6_root, rt, info, mxc, extack);
 	write_unlock_bh(&table->tb6_lock);
 
 	return err;
@@ -956,7 +957,7 @@ int ip6_ins_rt(struct rt6_info *rt)
 	struct nl_info info = {	.nl_net = dev_net(rt->dst.dev), };
 	struct mx6_config mxc = { .mx = NULL, };
 
-	return __ip6_ins_rt(rt, &info, &mxc);
+	return __ip6_ins_rt(rt, &info, &mxc, NULL);
 }
 
 static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
@@ -1844,7 +1845,8 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
 	return rt;
 }
 
-static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
+static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg,
+					      struct netlink_ext_ack *extack)
 {
 	struct net *net = cfg->fc_nlinfo.nl_net;
 	struct rt6_info *rt = NULL;
@@ -2111,13 +2113,14 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 	return ERR_PTR(err);
 }
 
-int ip6_route_add(struct fib6_config *cfg)
+int ip6_route_add(struct fib6_config *cfg,
+		  struct netlink_ext_ack *extack)
 {
 	struct mx6_config mxc = { .mx = NULL, };
 	struct rt6_info *rt;
 	int err;
 
-	rt = ip6_route_info_create(cfg);
+	rt = ip6_route_info_create(cfg, extack);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		rt = NULL;
@@ -2128,7 +2131,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (err)
 		goto out;
 
-	err = __ip6_ins_rt(rt, &cfg->fc_nlinfo, &mxc);
+	err = __ip6_ins_rt(rt, &cfg->fc_nlinfo, &mxc, extack);
 
 	kfree(mxc.mx);
 
@@ -2222,7 +2225,8 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 	return err;
 }
 
-static int ip6_route_del(struct fib6_config *cfg)
+static int ip6_route_del(struct fib6_config *cfg,
+			 struct netlink_ext_ack *extack)
 {
 	struct fib6_table *table;
 	struct fib6_node *fn;
@@ -2483,7 +2487,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 	if (!prefixlen)
 		cfg.fc_flags |= RTF_DEFAULT;
 
-	ip6_route_add(&cfg);
+	ip6_route_add(&cfg, NULL);
 
 	return rt6_get_route_info(net, prefix, prefixlen, gwaddr, dev);
 }
@@ -2529,7 +2533,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 
 	cfg.fc_gateway = *gwaddr;
 
-	if (!ip6_route_add(&cfg)) {
+	if (!ip6_route_add(&cfg, NULL)) {
 		struct fib6_table *table;
 
 		table = fib6_get_table(dev_net(dev), cfg.fc_table);
@@ -2622,10 +2626,10 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		rtnl_lock();
 		switch (cmd) {
 		case SIOCADDRT:
-			err = ip6_route_add(&cfg);
+			err = ip6_route_add(&cfg, NULL);
 			break;
 		case SIOCDELRT:
-			err = ip6_route_del(&cfg);
+			err = ip6_route_del(&cfg, NULL);
 			break;
 		default:
 			err = -EINVAL;
@@ -2903,7 +2907,8 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
-			      struct fib6_config *cfg)
+			      struct fib6_config *cfg,
+			      struct netlink_ext_ack *extack)
 {
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
@@ -3097,7 +3102,8 @@ static void ip6_route_mpath_notify(struct rt6_info *rt,
 		inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 }
 
-static int ip6_route_multipath_add(struct fib6_config *cfg)
+static int ip6_route_multipath_add(struct fib6_config *cfg,
+				   struct netlink_ext_ack *extack)
 {
 	struct rt6_info *rt_notif = NULL, *rt_last = NULL;
 	struct nl_info *info = &cfg->fc_nlinfo;
@@ -3145,7 +3151,7 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 				r_cfg.fc_encap_type = nla_get_u16(nla);
 		}
 
-		rt = ip6_route_info_create(&r_cfg);
+		rt = ip6_route_info_create(&r_cfg, extack);
 		if (IS_ERR(rt)) {
 			err = PTR_ERR(rt);
 			rt = NULL;
@@ -3170,7 +3176,7 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 	err_nh = NULL;
 	list_for_each_entry(nh, &rt6_nh_list, next) {
 		rt_last = nh->rt6_info;
-		err = __ip6_ins_rt(nh->rt6_info, info, &nh->mxc);
+		err = __ip6_ins_rt(nh->rt6_info, info, &nh->mxc, extack);
 		/* save reference to first route for notification */
 		if (!rt_notif && !err)
 			rt_notif = nh->rt6_info;
@@ -3212,7 +3218,7 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 	list_for_each_entry(nh, &rt6_nh_list, next) {
 		if (err_nh == nh)
 			break;
-		ip6_route_del(&nh->r_cfg);
+		ip6_route_del(&nh->r_cfg, extack);
 	}
 
 cleanup:
@@ -3227,7 +3233,8 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 	return err;
 }
 
-static int ip6_route_multipath_del(struct fib6_config *cfg)
+static int ip6_route_multipath_del(struct fib6_config *cfg,
+				   struct netlink_ext_ack *extack)
 {
 	struct fib6_config r_cfg;
 	struct rtnexthop *rtnh;
@@ -3254,7 +3261,7 @@ static int ip6_route_multipath_del(struct fib6_config *cfg)
 				r_cfg.fc_flags |= RTF_GATEWAY;
 			}
 		}
-		err = ip6_route_del(&r_cfg);
+		err = ip6_route_del(&r_cfg, extack);
 		if (err)
 			last_err = err;
 
@@ -3270,15 +3277,15 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct fib6_config cfg;
 	int err;
 
-	err = rtm_to_fib6_config(skb, nlh, &cfg);
+	err = rtm_to_fib6_config(skb, nlh, &cfg, extack);
 	if (err < 0)
 		return err;
 
 	if (cfg.fc_mp)
-		return ip6_route_multipath_del(&cfg);
+		return ip6_route_multipath_del(&cfg, extack);
 	else {
 		cfg.fc_delete_all_nh = 1;
-		return ip6_route_del(&cfg);
+		return ip6_route_del(&cfg, extack);
 	}
 }
 
@@ -3288,14 +3295,14 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct fib6_config cfg;
 	int err;
 
-	err = rtm_to_fib6_config(skb, nlh, &cfg);
+	err = rtm_to_fib6_config(skb, nlh, &cfg, extack);
 	if (err < 0)
 		return err;
 
 	if (cfg.fc_mp)
-		return ip6_route_multipath_add(&cfg);
+		return ip6_route_multipath_add(&cfg, extack);
 	else
-		return ip6_route_add(&cfg);
+		return ip6_route_add(&cfg, extack);
 }
 
 static size_t rt6_nlmsg_size(struct rt6_info *rt)
-- 
2.11.0 (Apple Git-81)
