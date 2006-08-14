From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [IPv4]: FIB configuration using struct fib_config
Date: Tue, 15 Aug 2006 00:00:01 +0200
Message-ID: <20060815145945.706143664@postel.suug.ch>
References: <20060815145723.147333034@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:11237 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932775AbWHOPAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 11:00:32 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv4_route_fib_config
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces struct fib_config replacing the ugly struct kern_rta
prone to ordering issues. Avoids creating faked netlink messages
for auto generated routes or requests via ioctl.

A new interface net/nexthop.h is added to help navigate through
nexthop configuration arrays.

A new struct nl_info will be used to carry the necessary netlink
information to be used for notifications later on.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/include/net/ip_fib.h
===================================================================
--- net-2.6.19.git.orig/include/net/ip_fib.h
+++ net-2.6.19.git/include/net/ip_fib.h
@@ -20,25 +20,32 @@
 #include <linux/seq_file.h>
 #include <net/fib_rules.h>
 
-/* WARNING: The ordering of these elements must match ordering
- *          of RTA_* rtnetlink attribute numbers.
- */
-struct kern_rta {
-	void		*rta_dst;
-	void		*rta_src;
-	int		*rta_iif;
-	int		*rta_oif;
-	void		*rta_gw;
-	u32		*rta_priority;
-	void		*rta_prefsrc;
-	struct rtattr	*rta_mx;
-	struct rtattr	*rta_mp;
-	unsigned char	*rta_protoinfo;
-	u32		*rta_flow;
-	struct rta_cacheinfo *rta_ci;
-	struct rta_session *rta_sess;
-	u32		*rta_mp_alg;
-};
+struct fib_config {
+	u8			fc_family;
+	u8			fc_dst_len;
+	u8			fc_src_len;
+	u8			fc_tos;
+	u8			fc_protocol;
+	u8			fc_scope;
+	u8			fc_type;
+	/* 1 byte unused */
+	u32			fc_table;
+	u32			fc_dst;
+	u32			fc_src;
+	u32			fc_gw;
+	int			fc_oif;
+	u32			fc_flags;
+	u32			fc_priority;
+	u32			fc_prefsrc;
+	struct nlattr		*fc_mx;
+	struct rtnexthop	*fc_mp;
+	int			fc_mx_len;
+	int			fc_mp_len;
+	u32			fc_flow;
+	u32			fc_mp_alg;
+	u32			fc_nlflags;
+	struct nl_info		fc_nlinfo;
+ };
 
 struct fib_info;
 
@@ -154,12 +161,8 @@ struct fib_table {
 	u32		tb_id;
 	unsigned	tb_stamp;
 	int		(*tb_lookup)(struct fib_table *tb, const struct flowi *flp, struct fib_result *res);
-	int		(*tb_insert)(struct fib_table *table, struct rtmsg *r,
-				     struct kern_rta *rta, struct nlmsghdr *n,
-				     struct netlink_skb_parms *req);
-	int		(*tb_delete)(struct fib_table *table, struct rtmsg *r,
-				     struct kern_rta *rta, struct nlmsghdr *n,
-				     struct netlink_skb_parms *req);
+	int		(*tb_insert)(struct fib_table *, struct fib_config *);
+	int		(*tb_delete)(struct fib_table *, struct fib_config *);
 	int		(*tb_dump)(struct fib_table *table, struct sk_buff *skb,
 				     struct netlink_callback *cb);
 	int		(*tb_flush)(struct fib_table *table);
@@ -228,8 +231,6 @@ struct rtentry;
 extern int ip_fib_check_default(u32 gw, struct net_device *dev);
 extern int fib_sync_down(u32 local, struct net_device *dev, int force);
 extern int fib_sync_up(struct net_device *dev);
-extern int fib_convert_rtentry(int cmd, struct nlmsghdr *nl, struct rtmsg *rtm,
-			       struct kern_rta *rta, struct rtentry *r);
 extern u32  __fib_res_prefsrc(struct fib_result *res);
 
 /* Exported by fib_hash.c */
Index: net-2.6.19.git/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_frontend.c
+++ net-2.6.19.git/net/ipv4/fib_frontend.c
@@ -253,42 +253,190 @@ e_inval:
 
 #ifndef CONFIG_IP_NOSIOCRT
 
+static inline u32 sk_extract_addr(struct sockaddr *addr)
+{
+	return ((struct sockaddr_in *) addr)->sin_addr.s_addr;
+}
+
+static int put_rtax(struct nlattr *mx, int len, int type, u32 value)
+{
+	struct nlattr *nla;
+
+	nla = (struct nlattr *) ((char *) mx + len);
+	nla->nla_type = type;
+	nla->nla_len = nla_attr_size(4);
+	*(u32 *) nla_data(nla) = value;
+
+	return len + nla_total_size(4);
+}
+
+static int rtentry_to_fib_config(int cmd, struct rtentry *rt,
+				 struct fib_config *cfg)
+{
+	u32 addr;
+	int plen;
+
+	memset(cfg, 0, sizeof(*cfg));
+
+	if (rt->rt_dst.sa_family != AF_INET)
+		return -EAFNOSUPPORT;
+
+	/*
+	 * Check mask for validity:
+	 * a) it must be contiguous.
+	 * b) destination must have all host bits clear.
+	 * c) if application forgot to set correct family (AF_INET),
+	 *    reject request unless it is absolutely clear i.e.
+	 *    both family and mask are zero.
+	 */
+	plen = 32;
+	addr = sk_extract_addr(&rt->rt_dst);
+	if (!(rt->rt_flags & RTF_HOST)) {
+		u32 mask = sk_extract_addr(&rt->rt_genmask);
+
+		if (rt->rt_genmask.sa_family != AF_INET) {
+			if (mask || rt->rt_genmask.sa_family)
+				return -EAFNOSUPPORT;
+		}
+
+		if (bad_mask(mask, addr))
+			return -EINVAL;
+
+		plen = inet_mask_len(mask);
+	}
+
+	cfg->fc_dst_len = plen;
+	cfg->fc_dst = addr;
+
+	if (cmd != SIOCDELRT) {
+		cfg->fc_nlflags = NLM_F_CREATE;
+		cfg->fc_protocol = RTPROT_BOOT;
+	}
+
+	if (rt->rt_metric)
+		cfg->fc_priority = rt->rt_metric - 1;
+
+	if (rt->rt_flags & RTF_REJECT) {
+		cfg->fc_scope = RT_SCOPE_HOST;
+		cfg->fc_type = RTN_UNREACHABLE;
+		return 0;
+	}
+
+	cfg->fc_scope = RT_SCOPE_NOWHERE;
+	cfg->fc_type = RTN_UNICAST;
+
+	if (rt->rt_dev) {
+		char *colon;
+		struct net_device *dev;
+		char devname[IFNAMSIZ];
+
+		if (copy_from_user(devname, rt->rt_dev, IFNAMSIZ-1))
+			return -EFAULT;
+
+		devname[IFNAMSIZ-1] = 0;
+		colon = strchr(devname, ':');
+		if (colon)
+			*colon = 0;
+		dev = __dev_get_by_name(devname);
+		if (!dev)
+			return -ENODEV;
+		cfg->fc_oif = dev->ifindex;
+		if (colon) {
+			struct in_ifaddr *ifa;
+			struct in_device *in_dev = __in_dev_get_rtnl(dev);
+			if (!in_dev)
+				return -ENODEV;
+			*colon = ':';
+			for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next)
+				if (strcmp(ifa->ifa_label, devname) == 0)
+					break;
+			if (ifa == NULL)
+				return -ENODEV;
+			cfg->fc_prefsrc = ifa->ifa_local;
+		}
+	}
+
+	addr = sk_extract_addr(&rt->rt_gateway);
+	if (rt->rt_gateway.sa_family == AF_INET && addr) {
+		cfg->fc_gw = addr;
+		if (rt->rt_flags & RTF_GATEWAY &&
+		    inet_addr_type(addr) == RTN_UNICAST)
+			cfg->fc_scope = RT_SCOPE_UNIVERSE;
+	}
+
+	if (cmd == SIOCDELRT)
+		return 0;
+
+	if (rt->rt_flags & RTF_GATEWAY && !cfg->fc_gw)
+		return -EINVAL;
+
+	if (cfg->fc_scope == RT_SCOPE_NOWHERE)
+		cfg->fc_scope = RT_SCOPE_LINK;
+
+	if (rt->rt_flags & (RTF_MTU | RTF_WINDOW | RTF_IRTT)) {
+		struct nlattr *mx;
+		int len = 0;
+
+		mx = kzalloc(3 * nla_total_size(4), GFP_KERNEL);
+ 		if (mx == NULL)
+			return -ENOMEM;
+
+		if (rt->rt_flags & RTF_MTU)
+			len = put_rtax(mx, len, RTAX_ADVMSS, rt->rt_mtu - 40);
+
+		if (rt->rt_flags & RTF_WINDOW)
+			len = put_rtax(mx, len, RTAX_WINDOW, rt->rt_window);
+
+		if (rt->rt_flags & RTF_IRTT)
+			len = put_rtax(mx, len, RTAX_RTT, rt->rt_irtt << 3);
+
+		cfg->fc_mx = mx;
+		cfg->fc_mx_len = len;
+	}
+
+	return 0;
+}
+
 /*
  *	Handle IP routing ioctl calls. These are used to manipulate the routing tables
  */
  
 int ip_rt_ioctl(unsigned int cmd, void __user *arg)
 {
+	struct fib_config cfg;
+	struct rtentry rt;
 	int err;
-	struct kern_rta rta;
-	struct rtentry  r;
-	struct {
-		struct nlmsghdr nlh;
-		struct rtmsg	rtm;
-	} req;
 
 	switch (cmd) {
 	case SIOCADDRT:		/* Add a route */
 	case SIOCDELRT:		/* Delete a route */
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (copy_from_user(&r, arg, sizeof(struct rtentry)))
+
+		if (copy_from_user(&rt, arg, sizeof(rt)))
 			return -EFAULT;
+
 		rtnl_lock();
-		err = fib_convert_rtentry(cmd, &req.nlh, &req.rtm, &rta, &r);
+		err = rtentry_to_fib_config(cmd, &rt, &cfg);
 		if (err == 0) {
+			struct fib_table *tb;
+
 			if (cmd == SIOCDELRT) {
-				struct fib_table *tb = fib_get_table(req.rtm.rtm_table);
-				err = -ESRCH;
+				tb = fib_get_table(cfg.fc_table);
 				if (tb)
-					err = tb->tb_delete(tb, &req.rtm, &rta, &req.nlh, NULL);
+					err = tb->tb_delete(tb, &cfg);
+				else
+					err = -ESRCH;
 			} else {
-				struct fib_table *tb = fib_new_table(req.rtm.rtm_table);
-				err = -ENOBUFS;
+				tb = fib_new_table(cfg.fc_table);
 				if (tb)
-					err = tb->tb_insert(tb, &req.rtm, &rta, &req.nlh, NULL);
+					err = tb->tb_insert(tb, &cfg);
+				else
+					err = -ENOBUFS;
 			}
-			kfree(rta.rta_mx);
+
+			/* allocated by rtentry_to_fib_config() */
+			kfree(cfg.fc_mx);
 		}
 		rtnl_unlock();
 		return err;
@@ -305,51 +453,134 @@ int ip_rt_ioctl(unsigned int cmd, void *
 
 #endif
 
-static int inet_check_attr(struct rtmsg *r, struct rtattr **rta)
-{
-	int i;
+static struct nla_policy rtm_ipv4_policy[RTA_MAX+1] __read_mostly = {
+	[RTA_DST]		= { .type = NLA_U32 },
+	[RTA_SRC]		= { .type = NLA_U32 },
+	[RTA_IIF]		= { .type = NLA_U32 },
+	[RTA_OIF]		= { .type = NLA_U32 },
+	[RTA_GATEWAY]		= { .type = NLA_U32 },
+	[RTA_PRIORITY]		= { .type = NLA_U32 },
+	[RTA_PREFSRC]		= { .type = NLA_U32 },
+	[RTA_METRICS]		= { .type = NLA_NESTED },
+	[RTA_MULTIPATH]		= { .minlen = sizeof(struct rtnexthop) },
+	[RTA_PROTOINFO]		= { .type = NLA_U32 },
+	[RTA_FLOW]		= { .type = NLA_U32 },
+	[RTA_MP_ALGO]		= { .type = NLA_U32 },
+};
 
-	for (i=1; i<=RTA_MAX; i++, rta++) {
-		struct rtattr *attr = *rta;
-		if (attr) {
-			if (RTA_PAYLOAD(attr) < 4)
-				return -EINVAL;
-			if (i != RTA_MULTIPATH && i != RTA_METRICS &&
-			    i != RTA_TABLE)
-				*rta = (struct rtattr*)RTA_DATA(attr);
+static int rtm_to_fib_config(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct fib_config *cfg)
+{
+	struct nlattr *attr;
+	int err, remaining;
+	struct rtmsg *rtm;
+
+	err = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipv4_policy);
+	if (err < 0)
+		goto errout;
+
+	memset(cfg, 0, sizeof(*cfg));
+
+	rtm = nlmsg_data(nlh);
+	cfg->fc_family = rtm->rtm_family;
+	cfg->fc_dst_len = rtm->rtm_dst_len;
+	cfg->fc_src_len = rtm->rtm_src_len;
+	cfg->fc_tos = rtm->rtm_tos;
+	cfg->fc_table = rtm->rtm_table;
+	cfg->fc_protocol = rtm->rtm_protocol;
+	cfg->fc_scope = rtm->rtm_scope;
+	cfg->fc_type = rtm->rtm_type;
+	cfg->fc_flags = rtm->rtm_flags;
+	cfg->fc_nlflags = nlh->nlmsg_flags;
+
+	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
+	cfg->fc_nlinfo.nlh = nlh;
+
+	nlmsg_for_each_attr(attr, nlh, sizeof(struct rtmsg), remaining) {
+		switch (attr->nla_type) {
+		case RTA_DST:
+			cfg->fc_dst = nla_get_u32(attr);
+			break;
+		case RTA_SRC:
+			cfg->fc_src = nla_get_u32(attr);
+			break;
+		case RTA_OIF:
+			cfg->fc_oif = nla_get_u32(attr);
+			break;
+		case RTA_GATEWAY:
+			cfg->fc_gw = nla_get_u32(attr);
+			break;
+		case RTA_PRIORITY:
+			cfg->fc_priority = nla_get_u32(attr);
+			break;
+		case RTA_PREFSRC:
+			cfg->fc_prefsrc = nla_get_u32(attr);
+			break;
+		case RTA_METRICS:
+			cfg->fc_mx = nla_data(attr);
+			cfg->fc_mx_len = nla_len(attr);
+			break;
+		case RTA_MULTIPATH:
+			cfg->fc_mp = nla_data(attr);
+			cfg->fc_mp_len = nla_len(attr);
+			break;
+		case RTA_FLOW:
+			cfg->fc_flow = nla_get_u32(attr);
+			break;
+		case RTA_MP_ALGO:
+			cfg->fc_mp_alg = nla_get_u32(attr);
+			break;
+		case RTA_TABLE:
+			cfg->fc_table = nla_get_u32(attr);
+			break;
 		}
 	}
+
 	return 0;
+errout:
+	return err;
 }
 
 int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct fib_table * tb;
-	struct rtattr **rta = arg;
-	struct rtmsg *r = NLMSG_DATA(nlh);
+	struct fib_config cfg;
+	struct fib_table *tb;
+	int err;
 
-	if (inet_check_attr(r, rta))
-		return -EINVAL;
+	err = rtm_to_fib_config(skb, nlh, &cfg);
+	if (err < 0)
+		goto errout;
+
+	tb = fib_get_table(cfg.fc_table);
+	if (tb == NULL) {
+		err = -ESRCH;
+		goto errout;
+	}
 
-	tb = fib_get_table(rtm_get_table(rta, r->rtm_table));
-	if (tb)
-		return tb->tb_delete(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
-	return -ESRCH;
+	err = tb->tb_delete(tb, &cfg);
+errout:
+	return err;
 }
 
 int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct fib_table * tb;
-	struct rtattr **rta = arg;
-	struct rtmsg *r = NLMSG_DATA(nlh);
+	struct fib_config cfg;
+	struct fib_table *tb;
+	int err;
 
-	if (inet_check_attr(r, rta))
-		return -EINVAL;
+	err = rtm_to_fib_config(skb, nlh, &cfg);
+	if (err < 0)
+		goto errout;
+
+	tb = fib_new_table(cfg.fc_table);
+	if (tb == NULL) {
+		err = -ENOBUFS;
+		goto errout;
+	}
 
-	tb = fib_new_table(rtm_get_table(rta, r->rtm_table));
-	if (tb)
-		return tb->tb_insert(tb, r, (struct kern_rta*)rta, nlh, &NETLINK_CB(skb));
-	return -ENOBUFS;
+	err = tb->tb_insert(tb, &cfg);
+errout:
+	return err;
 }
 
 int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
@@ -396,17 +627,19 @@ out:
    only when netlink is already locked.
  */
 
-static void fib_magic(int cmd, int type, u32 dst, int dst_len, struct in_ifaddr *ifa)
+static void fib_magic(int cmd, int type, u32 dst, int dst_len,
+		      struct in_ifaddr *ifa)
 {
-	struct fib_table * tb;
-	struct {
-		struct nlmsghdr	nlh;
-		struct rtmsg	rtm;
-	} req;
-	struct kern_rta rta;
-
-	memset(&req.rtm, 0, sizeof(req.rtm));
-	memset(&rta, 0, sizeof(rta));
+	struct fib_table *tb;
+	struct fib_config cfg = {
+		.fc_protocol = RTPROT_KERNEL,
+		.fc_type = type,
+		.fc_dst = dst,
+		.fc_dst_len = dst_len,
+		.fc_prefsrc = ifa->ifa_local,
+		.fc_oif = ifa->ifa_dev->dev->ifindex,
+		.fc_nlflags = NLM_F_CREATE | NLM_F_APPEND,
+	};
 
 	if (type == RTN_UNICAST)
 		tb = fib_new_table(RT_TABLE_MAIN);
@@ -416,26 +649,17 @@ static void fib_magic(int cmd, int type,
 	if (tb == NULL)
 		return;
 
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = cmd;
-	req.nlh.nlmsg_flags = NLM_F_REQUEST|NLM_F_CREATE|NLM_F_APPEND;
-	req.nlh.nlmsg_pid = 0;
-	req.nlh.nlmsg_seq = 0;
-
-	req.rtm.rtm_dst_len = dst_len;
-	req.rtm.rtm_table = tb->tb_id;
-	req.rtm.rtm_protocol = RTPROT_KERNEL;
-	req.rtm.rtm_scope = (type != RTN_LOCAL ? RT_SCOPE_LINK : RT_SCOPE_HOST);
-	req.rtm.rtm_type = type;
-
-	rta.rta_dst = &dst;
-	rta.rta_prefsrc = &ifa->ifa_local;
-	rta.rta_oif = &ifa->ifa_dev->dev->ifindex;
+	cfg.fc_table = tb->tb_id;
+
+	if (type != RTN_LOCAL)
+		cfg.fc_scope = RT_SCOPE_LINK;
+	else
+		cfg.fc_scope = RT_SCOPE_HOST;
 
 	if (cmd == RTM_NEWROUTE)
-		tb->tb_insert(tb, &req.rtm, &rta, &req.nlh, NULL);
+		tb->tb_insert(tb, &cfg);
 	else
-		tb->tb_delete(tb, &req.rtm, &rta, &req.nlh, NULL);
+		tb->tb_delete(tb, &cfg);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
Index: net-2.6.19.git/net/ipv4/fib_semantics.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_semantics.c
+++ net-2.6.19.git/net/ipv4/fib_semantics.c
@@ -44,6 +44,7 @@
 #include <net/ip_fib.h>
 #include <net/ip_mp_alg.h>
 #include <net/netlink.h>
+#include <net/nexthop.h>
 
 #include "fib_lookup.h"
 
@@ -273,27 +274,27 @@ int ip_fib_check_default(u32 gw, struct 
 }
 
 void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
-	       int z, u32 tb_id,
-	       struct nlmsghdr *n, struct netlink_skb_parms *req)
+	       int dst_len, u32 tb_id, struct nl_info *info)
 {
 	struct sk_buff *skb;
-	u32 pid = req ? req->pid : n->nlmsg_pid;
 	int payload = sizeof(struct rtmsg) + 256;
+	u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
-	err = fib_dump_info(skb, pid, n->nlmsg_seq, event, tb_id,
-			    fa->fa_type, fa->fa_scope, &key, z, fa->fa_tos,
-			    fa->fa_info, 0);
+	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
+			    fa->fa_type, fa->fa_scope, &key, dst_len,
+			    fa->fa_tos, fa->fa_info, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
 	}
 
-	err = rtnl_notify(skb, pid, RTNLGRP_IPV4_ROUTE, n, GFP_KERNEL);
+	err = rtnl_notify(skb, info->pid, RTNLGRP_IPV4_ROUTE,
+			  info->nlh, GFP_KERNEL);
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(RTNLGRP_IPV4_ROUTE, err);
@@ -342,102 +343,100 @@ int fib_detect_death(struct fib_info *fi
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
-static u32 fib_get_attr32(struct rtattr *attr, int attrlen, int type)
-{
-	while (RTA_OK(attr,attrlen)) {
-		if (attr->rta_type == type)
-			return *(u32*)RTA_DATA(attr);
-		attr = RTA_NEXT(attr, attrlen);
-	}
-	return 0;
-}
-
-static int
-fib_count_nexthops(struct rtattr *rta)
+static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
 {
 	int nhs = 0;
-	struct rtnexthop *nhp = RTA_DATA(rta);
-	int nhlen = RTA_PAYLOAD(rta);
 
-	while (nhlen >= (int)sizeof(struct rtnexthop)) {
-		if ((nhlen -= nhp->rtnh_len) < 0)
-			return 0;
+	while (rtnh_ok(rtnh, remaining)) {
 		nhs++;
-		nhp = RTNH_NEXT(nhp);
-	};
-	return nhs;
+		rtnh = rtnh_next(rtnh, &remaining);
+	}
+
+	/* leftover implies invalid nexthop configuration, discard it */
+	return remaining > 0 ? 0 : nhs;
 }
 
-static int
-fib_get_nhs(struct fib_info *fi, const struct rtattr *rta, const struct rtmsg *r)
+static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
+		       int remaining, struct fib_config *cfg)
 {
-	struct rtnexthop *nhp = RTA_DATA(rta);
-	int nhlen = RTA_PAYLOAD(rta);
-
 	change_nexthops(fi) {
-		int attrlen = nhlen - sizeof(struct rtnexthop);
-		if (attrlen < 0 || (nhlen -= nhp->rtnh_len) < 0)
+		int attrlen;
+
+		if (!rtnh_ok(rtnh, remaining))
 			return -EINVAL;
-		nh->nh_flags = (r->rtm_flags&~0xFF) | nhp->rtnh_flags;
-		nh->nh_oif = nhp->rtnh_ifindex;
-		nh->nh_weight = nhp->rtnh_hops + 1;
-		if (attrlen) {
-			nh->nh_gw = fib_get_attr32(RTNH_DATA(nhp), attrlen, RTA_GATEWAY);
+
+		nh->nh_flags = (cfg->fc_flags & ~0xFF) | rtnh->rtnh_flags;
+		nh->nh_oif = rtnh->rtnh_ifindex;
+		nh->nh_weight = rtnh->rtnh_hops + 1;
+
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen > 0) {
+			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
+
+			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
+			nh->nh_gw = nla ? nla_get_u32(nla) : 0;
 #ifdef CONFIG_NET_CLS_ROUTE
-			nh->nh_tclassid = fib_get_attr32(RTNH_DATA(nhp), attrlen, RTA_FLOW);
+			nla = nla_find(attrs, attrlen, RTA_FLOW);
+			nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
 #endif
 		}
-		nhp = RTNH_NEXT(nhp);
+
+		rtnh = rtnh_next(rtnh, &remaining);
 	} endfor_nexthops(fi);
+
 	return 0;
 }
 
 #endif
 
-int fib_nh_match(struct rtmsg *r, struct nlmsghdr *nlh, struct kern_rta *rta,
-		 struct fib_info *fi)
+int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	struct rtnexthop *nhp;
-	int nhlen;
+	struct rtnexthop *rtnh;
+	int remaining;
 #endif
 
-	if (rta->rta_priority &&
-	    *rta->rta_priority != fi->fib_priority)
+	if (cfg->fc_priority && cfg->fc_priority != fi->fib_priority)
 		return 1;
 
-	if (rta->rta_oif || rta->rta_gw) {
-		if ((!rta->rta_oif || *rta->rta_oif == fi->fib_nh->nh_oif) &&
-		    (!rta->rta_gw  || memcmp(rta->rta_gw, &fi->fib_nh->nh_gw, 4) == 0))
+	if (cfg->fc_oif || cfg->fc_gw) {
+		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
+		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw))
 			return 0;
 		return 1;
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (rta->rta_mp == NULL)
+	if (cfg->fc_mp == NULL)
 		return 0;
-	nhp = RTA_DATA(rta->rta_mp);
-	nhlen = RTA_PAYLOAD(rta->rta_mp);
+
+	rtnh = cfg->fc_mp;
+	remaining = cfg->fc_mp_len;
 	
 	for_nexthops(fi) {
-		int attrlen = nhlen - sizeof(struct rtnexthop);
-		u32 gw;
+		int attrlen;
 
-		if (attrlen < 0 || (nhlen -= nhp->rtnh_len) < 0)
+		if (!rtnh_ok(rtnh, remaining))
 			return -EINVAL;
-		if (nhp->rtnh_ifindex && nhp->rtnh_ifindex != nh->nh_oif)
+
+		if (rtnh->rtnh_ifindex && rtnh->rtnh_ifindex != nh->nh_oif)
 			return 1;
-		if (attrlen) {
-			gw = fib_get_attr32(RTNH_DATA(nhp), attrlen, RTA_GATEWAY);
-			if (gw && gw != nh->nh_gw)
+
+		attrlen = rtnh_attrlen(rtnh);
+		if (attrlen < 0) {
+			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
+
+			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
+			if (nla && nla_get_u32(nla) != nh->nh_gw)
 				return 1;
 #ifdef CONFIG_NET_CLS_ROUTE
-			gw = fib_get_attr32(RTNH_DATA(nhp), attrlen, RTA_FLOW);
-			if (gw && gw != nh->nh_tclassid)
+			nla = nla_find(attrs, attrlen, RTA_FLOW);
+			if (nla && nla_get_u32(nla) != nh->nh_tclassid)
 				return 1;
 #endif
 		}
-		nhp = RTNH_NEXT(nhp);
+
+		rtnh = rtnh_next(rtnh, &remaining);
 	} endfor_nexthops(fi);
 #endif
 	return 0;
@@ -488,7 +487,8 @@ int fib_nh_match(struct rtmsg *r, struct
 						|-> {local prefix} (terminal node)
  */
 
-static int fib_check_nh(const struct rtmsg *r, struct fib_info *fi, struct fib_nh *nh)
+static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
+			struct fib_nh *nh)
 {
 	int err;
 
@@ -502,7 +502,7 @@ static int fib_check_nh(const struct rtm
 		if (nh->nh_flags&RTNH_F_ONLINK) {
 			struct net_device *dev;
 
-			if (r->rtm_scope >= RT_SCOPE_LINK)
+			if (cfg->fc_scope >= RT_SCOPE_LINK)
 				return -EINVAL;
 			if (inet_addr_type(nh->nh_gw) != RTN_UNICAST)
 				return -EINVAL;
@@ -516,10 +516,15 @@ static int fib_check_nh(const struct rtm
 			return 0;
 		}
 		{
-			struct flowi fl = { .nl_u = { .ip4_u =
-						      { .daddr = nh->nh_gw,
-							.scope = r->rtm_scope + 1 } },
-					    .oif = nh->nh_oif };
+			struct flowi fl = {
+				.nl_u = {
+					.ip4_u = {
+						.daddr = nh->nh_gw,
+						.scope = cfg->fc_scope + 1,
+					},
+				},
+				.oif = nh->nh_oif,
+			};
 
 			/* It is not necessary, but requires a bit of thinking */
 			if (fl.fl4_scope < RT_SCOPE_LINK)
@@ -646,39 +651,28 @@ static void fib_hash_move(struct hlist_h
 	fib_hash_free(old_laddrhash, bytes);
 }
 
-struct fib_info *
-fib_create_info(const struct rtmsg *r, struct kern_rta *rta,
-		const struct nlmsghdr *nlh, int *errp)
+struct fib_info *fib_create_info(struct fib_config *cfg)
 {
 	int err;
 	struct fib_info *fi = NULL;
 	struct fib_info *ofi;
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int nhs = 1;
-#else
-	const int nhs = 1;
-#endif
-#ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
-	u32 mp_alg = IP_MP_ALG_NONE;
-#endif
 
 	/* Fast check to catch the most weird cases */
-	if (fib_props[r->rtm_type].scope > r->rtm_scope)
+	if (fib_props[cfg->fc_type].scope > cfg->fc_scope)
 		goto err_inval;
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (rta->rta_mp) {
-		nhs = fib_count_nexthops(rta->rta_mp);
+	if (cfg->fc_mp) {
+		nhs = fib_count_nexthops(cfg->fc_mp, cfg->fc_mp_len);
 		if (nhs == 0)
 			goto err_inval;
 	}
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
-	if (rta->rta_mp_alg) {
-		mp_alg = *rta->rta_mp_alg;
-
-		if (mp_alg < IP_MP_ALG_NONE ||
-		    mp_alg > IP_MP_ALG_MAX)
+	if (cfg->fc_mp_alg) {
+		if (cfg->fc_mp_alg < IP_MP_ALG_NONE ||
+		    cfg->fc_mp_alg > IP_MP_ALG_MAX)
 			goto err_inval;
 	}
 #endif
@@ -714,43 +708,42 @@ fib_create_info(const struct rtmsg *r, s
 		goto failure;
 	fib_info_cnt++;
 
-	fi->fib_protocol = r->rtm_protocol;
+	fi->fib_protocol = cfg->fc_protocol;
+	fi->fib_flags = cfg->fc_flags;
+	fi->fib_priority = cfg->fc_priority;
+	fi->fib_prefsrc = cfg->fc_prefsrc;
 
 	fi->fib_nhs = nhs;
 	change_nexthops(fi) {
 		nh->nh_parent = fi;
 	} endfor_nexthops(fi)
 
-	fi->fib_flags = r->rtm_flags;
-	if (rta->rta_priority)
-		fi->fib_priority = *rta->rta_priority;
-	if (rta->rta_mx) {
-		int attrlen = RTA_PAYLOAD(rta->rta_mx);
-		struct rtattr *attr = RTA_DATA(rta->rta_mx);
-
-		while (RTA_OK(attr, attrlen)) {
-			unsigned flavor = attr->rta_type;
-			if (flavor) {
-				if (flavor > RTAX_MAX)
+	if (cfg->fc_mx) {
+		struct nlattr *nla;
+		int remaining;
+
+		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
+			int type = nla->nla_type;
+
+			if (type) {
+				if (type > RTAX_MAX)
 					goto err_inval;
-				fi->fib_metrics[flavor-1] = *(unsigned*)RTA_DATA(attr);
+				fi->fib_metrics[type - 1] = nla_get_u32(nla);
 			}
-			attr = RTA_NEXT(attr, attrlen);
 		}
 	}
-	if (rta->rta_prefsrc)
-		memcpy(&fi->fib_prefsrc, rta->rta_prefsrc, 4);
 
-	if (rta->rta_mp) {
+	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-		if ((err = fib_get_nhs(fi, rta->rta_mp, r)) != 0)
+		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
+		if (err != 0)
 			goto failure;
-		if (rta->rta_oif && fi->fib_nh->nh_oif != *rta->rta_oif)
+		if (cfg->fc_oif && fi->fib_nh->nh_oif != cfg->fc_oif)
 			goto err_inval;
-		if (rta->rta_gw && memcmp(&fi->fib_nh->nh_gw, rta->rta_gw, 4))
+		if (cfg->fc_gw && fi->fib_nh->nh_gw != cfg->fc_gw)
 			goto err_inval;
 #ifdef CONFIG_NET_CLS_ROUTE
-		if (rta->rta_flow && memcmp(&fi->fib_nh->nh_tclassid, rta->rta_flow, 4))
+		if (cfg->fc_flow && fi->fib_nh->nh_tclassid != cfg->fc_flow)
 			goto err_inval;
 #endif
 #else
@@ -758,34 +751,32 @@ fib_create_info(const struct rtmsg *r, s
 #endif
 	} else {
 		struct fib_nh *nh = fi->fib_nh;
-		if (rta->rta_oif)
-			nh->nh_oif = *rta->rta_oif;
-		if (rta->rta_gw)
-			memcpy(&nh->nh_gw, rta->rta_gw, 4);
+
+		nh->nh_oif = cfg->fc_oif;
+		nh->nh_gw = cfg->fc_gw;
+		nh->nh_flags = cfg->fc_flags;
 #ifdef CONFIG_NET_CLS_ROUTE
-		if (rta->rta_flow)
-			memcpy(&nh->nh_tclassid, rta->rta_flow, 4);
+		nh->nh_tclassid = cfg->fc_flow;
 #endif
-		nh->nh_flags = r->rtm_flags;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		nh->nh_weight = 1;
 #endif
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
-	fi->fib_mp_alg = mp_alg;
+	fi->fib_mp_alg = cfg->fc_mp_alg;
 #endif
 
-	if (fib_props[r->rtm_type].error) {
-		if (rta->rta_gw || rta->rta_oif || rta->rta_mp)
+	if (fib_props[cfg->fc_type].error) {
+		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
 			goto err_inval;
 		goto link_it;
 	}
 
-	if (r->rtm_scope > RT_SCOPE_HOST)
+	if (cfg->fc_scope > RT_SCOPE_HOST)
 		goto err_inval;
 
-	if (r->rtm_scope == RT_SCOPE_HOST) {
+	if (cfg->fc_scope == RT_SCOPE_HOST) {
 		struct fib_nh *nh = fi->fib_nh;
 
 		/* Local address is added. */
@@ -798,14 +789,14 @@ fib_create_info(const struct rtmsg *r, s
 			goto failure;
 	} else {
 		change_nexthops(fi) {
-			if ((err = fib_check_nh(r, fi, nh)) != 0)
+			if ((err = fib_check_nh(cfg, fi, nh)) != 0)
 				goto failure;
 		} endfor_nexthops(fi)
 	}
 
 	if (fi->fib_prefsrc) {
-		if (r->rtm_type != RTN_LOCAL || rta->rta_dst == NULL ||
-		    memcmp(&fi->fib_prefsrc, rta->rta_dst, 4))
+		if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
+		    fi->fib_prefsrc != cfg->fc_dst)
 			if (inet_addr_type(fi->fib_prefsrc) != RTN_LOCAL)
 				goto err_inval;
 	}
@@ -846,12 +837,12 @@ err_inval:
 	err = -EINVAL;
 
 failure:
-        *errp = err;
         if (fi) {
 		fi->fib_dead = 1;
 		free_fib_info(fi);
 	}
-	return NULL;
+
+	return ERR_PTR(err);
 }
 
 /* Note! fib_semantic_match intentionally uses  RCU list functions. */
@@ -1012,150 +1003,6 @@ rtattr_failure:
 	return -1;
 }
 
-#ifndef CONFIG_IP_NOSIOCRT
-
-int
-fib_convert_rtentry(int cmd, struct nlmsghdr *nl, struct rtmsg *rtm,
-		    struct kern_rta *rta, struct rtentry *r)
-{
-	int    plen;
-	u32    *ptr;
-
-	memset(rtm, 0, sizeof(*rtm));
-	memset(rta, 0, sizeof(*rta));
-
-	if (r->rt_dst.sa_family != AF_INET)
-		return -EAFNOSUPPORT;
-
-	/* Check mask for validity:
-	   a) it must be contiguous.
-	   b) destination must have all host bits clear.
-	   c) if application forgot to set correct family (AF_INET),
-	      reject request unless it is absolutely clear i.e.
-	      both family and mask are zero.
-	 */
-	plen = 32;
-	ptr = &((struct sockaddr_in*)&r->rt_dst)->sin_addr.s_addr;
-	if (!(r->rt_flags&RTF_HOST)) {
-		u32 mask = ((struct sockaddr_in*)&r->rt_genmask)->sin_addr.s_addr;
-		if (r->rt_genmask.sa_family != AF_INET) {
-			if (mask || r->rt_genmask.sa_family)
-				return -EAFNOSUPPORT;
-		}
-		if (bad_mask(mask, *ptr))
-			return -EINVAL;
-		plen = inet_mask_len(mask);
-	}
-
-	nl->nlmsg_flags = NLM_F_REQUEST;
-	nl->nlmsg_pid = 0;
-	nl->nlmsg_seq = 0;
-	nl->nlmsg_len = NLMSG_LENGTH(sizeof(*rtm));
-	if (cmd == SIOCDELRT) {
-		nl->nlmsg_type = RTM_DELROUTE;
-		nl->nlmsg_flags = 0;
-	} else {
-		nl->nlmsg_type = RTM_NEWROUTE;
-		nl->nlmsg_flags = NLM_F_REQUEST|NLM_F_CREATE;
-		rtm->rtm_protocol = RTPROT_BOOT;
-	}
-
-	rtm->rtm_dst_len = plen;
-	rta->rta_dst = ptr;
-
-	if (r->rt_metric) {
-		*(u32*)&r->rt_pad3 = r->rt_metric - 1;
-		rta->rta_priority = (u32*)&r->rt_pad3;
-	}
-	if (r->rt_flags&RTF_REJECT) {
-		rtm->rtm_scope = RT_SCOPE_HOST;
-		rtm->rtm_type = RTN_UNREACHABLE;
-		return 0;
-	}
-	rtm->rtm_scope = RT_SCOPE_NOWHERE;
-	rtm->rtm_type = RTN_UNICAST;
-
-	if (r->rt_dev) {
-		char *colon;
-		struct net_device *dev;
-		char   devname[IFNAMSIZ];
-
-		if (copy_from_user(devname, r->rt_dev, IFNAMSIZ-1))
-			return -EFAULT;
-		devname[IFNAMSIZ-1] = 0;
-		colon = strchr(devname, ':');
-		if (colon)
-			*colon = 0;
-		dev = __dev_get_by_name(devname);
-		if (!dev)
-			return -ENODEV;
-		rta->rta_oif = &dev->ifindex;
-		if (colon) {
-			struct in_ifaddr *ifa;
-			struct in_device *in_dev = __in_dev_get_rtnl(dev);
-			if (!in_dev)
-				return -ENODEV;
-			*colon = ':';
-			for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next)
-				if (strcmp(ifa->ifa_label, devname) == 0)
-					break;
-			if (ifa == NULL)
-				return -ENODEV;
-			rta->rta_prefsrc = &ifa->ifa_local;
-		}
-	}
-
-	ptr = &((struct sockaddr_in*)&r->rt_gateway)->sin_addr.s_addr;
-	if (r->rt_gateway.sa_family == AF_INET && *ptr) {
-		rta->rta_gw = ptr;
-		if (r->rt_flags&RTF_GATEWAY && inet_addr_type(*ptr) == RTN_UNICAST)
-			rtm->rtm_scope = RT_SCOPE_UNIVERSE;
-	}
-
-	if (cmd == SIOCDELRT)
-		return 0;
-
-	if (r->rt_flags&RTF_GATEWAY && rta->rta_gw == NULL)
-		return -EINVAL;
-
-	if (rtm->rtm_scope == RT_SCOPE_NOWHERE)
-		rtm->rtm_scope = RT_SCOPE_LINK;
-
-	if (r->rt_flags&(RTF_MTU|RTF_WINDOW|RTF_IRTT)) {
-		struct rtattr *rec;
-		struct rtattr *mx = kmalloc(RTA_LENGTH(3*RTA_LENGTH(4)), GFP_KERNEL);
-		if (mx == NULL)
-			return -ENOMEM;
-		rta->rta_mx = mx;
-		mx->rta_type = RTA_METRICS;
-		mx->rta_len  = RTA_LENGTH(0);
-		if (r->rt_flags&RTF_MTU) {
-			rec = (void*)((char*)mx + RTA_ALIGN(mx->rta_len));
-			rec->rta_type = RTAX_ADVMSS;
-			rec->rta_len = RTA_LENGTH(4);
-			mx->rta_len += RTA_LENGTH(4);
-			*(u32*)RTA_DATA(rec) = r->rt_mtu - 40;
-		}
-		if (r->rt_flags&RTF_WINDOW) {
-			rec = (void*)((char*)mx + RTA_ALIGN(mx->rta_len));
-			rec->rta_type = RTAX_WINDOW;
-			rec->rta_len = RTA_LENGTH(4);
-			mx->rta_len += RTA_LENGTH(4);
-			*(u32*)RTA_DATA(rec) = r->rt_window;
-		}
-		if (r->rt_flags&RTF_IRTT) {
-			rec = (void*)((char*)mx + RTA_ALIGN(mx->rta_len));
-			rec->rta_type = RTAX_RTT;
-			rec->rta_len = RTA_LENGTH(4);
-			mx->rta_len += RTA_LENGTH(4);
-			*(u32*)RTA_DATA(rec) = r->rt_irtt<<3;
-		}
-	}
-	return 0;
-}
-
-#endif
-
 /*
    Update FIB if:
    - local address disappeared -> we must delete all the entries
Index: net-2.6.19.git/include/net/nexthop.h
===================================================================
--- /dev/null
+++ net-2.6.19.git/include/net/nexthop.h
@@ -0,0 +1,33 @@
+#ifndef __NET_NEXTHOP_H
+#define __NET_NEXTHOP_H
+
+#include <linux/rtnetlink.h>
+#include <net/netlink.h>
+
+static inline int rtnh_ok(const struct rtnexthop *rtnh, int remaining)
+{
+	return remaining >= sizeof(*rtnh) &&
+	       rtnh->rtnh_len >= sizeof(*rtnh) &&
+	       rtnh->rtnh_len <= remaining;
+}
+
+static inline struct rtnexthop *rtnh_next(const struct rtnexthop *rtnh,
+                                         int *remaining)
+{
+	int totlen = NLA_ALIGN(rtnh->rtnh_len);
+
+	*remaining -= totlen;
+	return (struct rtnexthop *) ((char *) rtnh + totlen);
+}
+
+static inline struct nlattr *rtnh_attrs(const struct rtnexthop *rtnh)
+{
+	return (struct nlattr *) ((char *) rtnh + NLA_ALIGN(sizeof(*rtnh)));
+}
+
+static inline int rtnh_attrlen(const struct rtnexthop *rtnh)
+{
+	return rtnh->rtnh_len - NLA_ALIGN(sizeof(*rtnh));
+}
+
+#endif
Index: net-2.6.19.git/net/ipv4/fib_hash.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_hash.c
+++ net-2.6.19.git/net/ipv4/fib_hash.c
@@ -379,42 +379,39 @@ static struct fib_node *fib_find_node(st
 	return NULL;
 }
 
-static int
-fn_hash_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-	       struct nlmsghdr *n, struct netlink_skb_parms *req)
+static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fib_node *new_f, *f;
 	struct fib_alias *fa, *new_fa;
 	struct fn_zone *fz;
 	struct fib_info *fi;
-	int z = r->rtm_dst_len;
-	int type = r->rtm_type;
-	u8 tos = r->rtm_tos;
+	u8 tos = cfg->fc_tos;
 	u32 key;
 	int err;
 
-	if (z > 32)
+	if (cfg->fc_dst_len > 32)
 		return -EINVAL;
-	fz = table->fn_zones[z];
-	if (!fz && !(fz = fn_new_zone(table, z)))
+
+	fz = table->fn_zones[cfg->fc_dst_len];
+	if (!fz && !(fz = fn_new_zone(table, cfg->fc_dst_len)))
 		return -ENOBUFS;
 
 	key = 0;
-	if (rta->rta_dst) {
-		u32 dst;
-		memcpy(&dst, rta->rta_dst, 4);
-		if (dst & ~FZ_MASK(fz))
+	if (cfg->fc_dst) {
+		if (cfg->fc_dst & ~FZ_MASK(fz))
 			return -EINVAL;
-		key = fz_key(dst, fz);
+		key = fz_key(cfg->fc_dst, fz);
 	}
 
-	if  ((fi = fib_create_info(r, rta, n, &err)) == NULL)
-		return err;
+	fi = fib_create_info(cfg);
+	if (IS_ERR(fi))
+		return PTR_ERR(fi);
 
 	if (fz->fz_nent > (fz->fz_divisor<<1) &&
 	    fz->fz_divisor < FZ_MAX_DIVISOR &&
-	    (z==32 || (1<<z) > fz->fz_divisor))
+	    (cfg->fc_dst_len == 32 ||
+	     (1 << cfg->fc_dst_len) > fz->fz_divisor))
 		fn_rehash_zone(fz);
 
 	f = fib_find_node(fz, key);
@@ -440,18 +437,18 @@ fn_hash_insert(struct fib_table *tb, str
 		struct fib_alias *fa_orig;
 
 		err = -EEXIST;
-		if (n->nlmsg_flags & NLM_F_EXCL)
+		if (cfg->fc_nlflags & NLM_F_EXCL)
 			goto out;
 
-		if (n->nlmsg_flags & NLM_F_REPLACE) {
+		if (cfg->fc_nlflags & NLM_F_REPLACE) {
 			struct fib_info *fi_drop;
 			u8 state;
 
 			write_lock_bh(&fib_hash_lock);
 			fi_drop = fa->fa_info;
 			fa->fa_info = fi;
-			fa->fa_type = type;
-			fa->fa_scope = r->rtm_scope;
+			fa->fa_type = cfg->fc_type;
+			fa->fa_scope = cfg->fc_scope;
 			state = fa->fa_state;
 			fa->fa_state &= ~FA_S_ACCESSED;
 			fib_hash_genid++;
@@ -474,17 +471,17 @@ fn_hash_insert(struct fib_table *tb, str
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
-			if (fa->fa_type == type &&
-			    fa->fa_scope == r->rtm_scope &&
+			if (fa->fa_type == cfg->fc_type &&
+			    fa->fa_scope == cfg->fc_scope &&
 			    fa->fa_info == fi)
 				goto out;
 		}
-		if (!(n->nlmsg_flags & NLM_F_APPEND))
+		if (!(cfg->fc_nlflags & NLM_F_APPEND))
 			fa = fa_orig;
 	}
 
 	err = -ENOENT;
-	if (!(n->nlmsg_flags&NLM_F_CREATE))
+	if (!(cfg->fc_nlflags & NLM_F_CREATE))
 		goto out;
 
 	err = -ENOBUFS;
@@ -506,8 +503,8 @@ fn_hash_insert(struct fib_table *tb, str
 
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
-	new_fa->fa_type = type;
-	new_fa->fa_scope = r->rtm_scope;
+	new_fa->fa_type = cfg->fc_type;
+	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
 
 	/*
@@ -526,7 +523,8 @@ fn_hash_insert(struct fib_table *tb, str
 		fz->fz_nent++;
 	rt_cache_flush(-1);
 
-	rtmsg_fib(RTM_NEWROUTE, key, new_fa, z, tb->tb_id, n, req);
+	rtmsg_fib(RTM_NEWROUTE, key, new_fa, cfg->fc_dst_len, tb->tb_id,
+		  &cfg->fc_nlinfo);
 	return 0;
 
 out_free_new_fa:
@@ -537,30 +535,25 @@ out:
 }
 
 
-static int
-fn_hash_delete(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-	       struct nlmsghdr *n, struct netlink_skb_parms *req)
+static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
 	struct fib_node *f;
 	struct fib_alias *fa, *fa_to_delete;
-	int z = r->rtm_dst_len;
 	struct fn_zone *fz;
 	u32 key;
-	u8 tos = r->rtm_tos;
 
-	if (z > 32)
+	if (cfg->fc_dst_len > 32)
 		return -EINVAL;
-	if ((fz  = table->fn_zones[z]) == NULL)
+
+	if ((fz  = table->fn_zones[cfg->fc_dst_len]) == NULL)
 		return -ESRCH;
 
 	key = 0;
-	if (rta->rta_dst) {
-		u32 dst;
-		memcpy(&dst, rta->rta_dst, 4);
-		if (dst & ~FZ_MASK(fz))
+	if (cfg->fc_dst) {
+		if (cfg->fc_dst & ~FZ_MASK(fz))
 			return -EINVAL;
-		key = fz_key(dst, fz);
+		key = fz_key(cfg->fc_dst, fz);
 	}
 
 	f = fib_find_node(fz, key);
@@ -568,7 +561,7 @@ fn_hash_delete(struct fib_table *tb, str
 	if (!f)
 		fa = NULL;
 	else
-		fa = fib_find_alias(&f->fn_alias, tos, 0);
+		fa = fib_find_alias(&f->fn_alias, cfg->fc_tos, 0);
 	if (!fa)
 		return -ESRCH;
 
@@ -577,16 +570,16 @@ fn_hash_delete(struct fib_table *tb, str
 	list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
-		if (fa->fa_tos != tos)
+		if (fa->fa_tos != cfg->fc_tos)
 			break;
 
-		if ((!r->rtm_type ||
-		     fa->fa_type == r->rtm_type) &&
-		    (r->rtm_scope == RT_SCOPE_NOWHERE ||
-		     fa->fa_scope == r->rtm_scope) &&
-		    (!r->rtm_protocol ||
-		     fi->fib_protocol == r->rtm_protocol) &&
-		    fib_nh_match(r, n, rta, fi) == 0) {
+		if ((!cfg->fc_type ||
+		     fa->fa_type == cfg->fc_type) &&
+		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
+		     fa->fa_scope == cfg->fc_scope) &&
+		    (!cfg->fc_protocol ||
+		     fi->fib_protocol == cfg->fc_protocol) &&
+		    fib_nh_match(cfg, fi) == 0) {
 			fa_to_delete = fa;
 			break;
 		}
@@ -596,7 +589,8 @@ fn_hash_delete(struct fib_table *tb, str
 		int kill_fn;
 
 		fa = fa_to_delete;
-		rtmsg_fib(RTM_DELROUTE, key, fa, z, tb->tb_id, n, req);
+		rtmsg_fib(RTM_DELROUTE, key, fa, cfg->fc_dst_len,
+			  tb->tb_id, &cfg->fc_nlinfo);
 
 		kill_fn = 0;
 		write_lock_bh(&fib_hash_lock);
Index: net-2.6.19.git/net/ipv4/fib_trie.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_trie.c
+++ net-2.6.19.git/net/ipv4/fib_trie.c
@@ -1124,17 +1124,14 @@ err:
 	return fa_head;
 }
 
-static int
-fn_trie_insert(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-	       struct nlmsghdr *nlhdr, struct netlink_skb_parms *req)
+static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *new_fa;
 	struct list_head *fa_head = NULL;
 	struct fib_info *fi;
-	int plen = r->rtm_dst_len;
-	int type = r->rtm_type;
-	u8 tos = r->rtm_tos;
+	int plen = cfg->fc_dst_len;
+	u8 tos = cfg->fc_tos;
 	u32 key, mask;
 	int err;
 	struct leaf *l;
@@ -1142,11 +1139,7 @@ fn_trie_insert(struct fib_table *tb, str
 	if (plen > 32)
 		return -EINVAL;
 
-	key = 0;
-	if (rta->rta_dst)
-		memcpy(&key, rta->rta_dst, 4);
-
-	key = ntohl(key);
+	key = ntohl(cfg->fc_dst);
 
 	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
 
@@ -1157,10 +1150,11 @@ fn_trie_insert(struct fib_table *tb, str
 
 	key = key & mask;
 
-	fi = fib_create_info(r, rta, nlhdr, &err);
-
-	if (!fi)
+	fi = fib_create_info(cfg);
+	if (IS_ERR(fi)) {
+		err = PTR_ERR(fi);
 		goto err;
+	}
 
 	l = fib_find_node(t, key);
 	fa = NULL;
@@ -1185,10 +1179,10 @@ fn_trie_insert(struct fib_table *tb, str
 		struct fib_alias *fa_orig;
 
 		err = -EEXIST;
-		if (nlhdr->nlmsg_flags & NLM_F_EXCL)
+		if (cfg->fc_nlflags & NLM_F_EXCL)
 			goto out;
 
-		if (nlhdr->nlmsg_flags & NLM_F_REPLACE) {
+		if (cfg->fc_nlflags & NLM_F_REPLACE) {
 			struct fib_info *fi_drop;
 			u8 state;
 
@@ -1200,8 +1194,8 @@ fn_trie_insert(struct fib_table *tb, str
 			fi_drop = fa->fa_info;
 			new_fa->fa_tos = fa->fa_tos;
 			new_fa->fa_info = fi;
-			new_fa->fa_type = type;
-			new_fa->fa_scope = r->rtm_scope;
+			new_fa->fa_type = cfg->fc_type;
+			new_fa->fa_scope = cfg->fc_scope;
 			state = fa->fa_state;
 			new_fa->fa_state &= ~FA_S_ACCESSED;
 
@@ -1224,17 +1218,17 @@ fn_trie_insert(struct fib_table *tb, str
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
-			if (fa->fa_type == type &&
-			    fa->fa_scope == r->rtm_scope &&
+			if (fa->fa_type == cfg->fc_type &&
+			    fa->fa_scope == cfg->fc_scope &&
 			    fa->fa_info == fi) {
 				goto out;
 			}
 		}
-		if (!(nlhdr->nlmsg_flags & NLM_F_APPEND))
+		if (!(cfg->fc_nlflags & NLM_F_APPEND))
 			fa = fa_orig;
 	}
 	err = -ENOENT;
-	if (!(nlhdr->nlmsg_flags & NLM_F_CREATE))
+	if (!(cfg->fc_nlflags & NLM_F_CREATE))
 		goto out;
 
 	err = -ENOBUFS;
@@ -1244,8 +1238,8 @@ fn_trie_insert(struct fib_table *tb, str
 
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
-	new_fa->fa_type = type;
-	new_fa->fa_scope = r->rtm_scope;
+	new_fa->fa_type = cfg->fc_type;
+	new_fa->fa_scope = cfg->fc_scope;
 	new_fa->fa_state = 0;
 	/*
 	 * Insert new entry to the list.
@@ -1262,7 +1256,8 @@ fn_trie_insert(struct fib_table *tb, str
 			  (fa ? &fa->fa_list : fa_head));
 
 	rt_cache_flush(-1);
-	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id, nlhdr, req);
+	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
+		  &cfg->fc_nlinfo);
 succeeded:
 	return 0;
 
@@ -1548,28 +1543,21 @@ static int trie_leaf_remove(struct trie 
 	return 1;
 }
 
-static int
-fn_trie_delete(struct fib_table *tb, struct rtmsg *r, struct kern_rta *rta,
-		struct nlmsghdr *nlhdr, struct netlink_skb_parms *req)
+static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	u32 key, mask;
-	int plen = r->rtm_dst_len;
-	u8 tos = r->rtm_tos;
+	int plen = cfg->fc_dst_len;
+	u8 tos = cfg->fc_tos;
 	struct fib_alias *fa, *fa_to_delete;
 	struct list_head *fa_head;
 	struct leaf *l;
 	struct leaf_info *li;
 
-
 	if (plen > 32)
 		return -EINVAL;
 
-	key = 0;
-	if (rta->rta_dst)
-		memcpy(&key, rta->rta_dst, 4);
-
-	key = ntohl(key);
+	key = ntohl(cfg->fc_dst);
 	mask = ntohl(inet_make_mask(plen));
 
 	if (key & ~mask)
@@ -1598,13 +1586,12 @@ fn_trie_delete(struct fib_table *tb, str
 		if (fa->fa_tos != tos)
 			break;
 
-		if ((!r->rtm_type ||
-		     fa->fa_type == r->rtm_type) &&
-		    (r->rtm_scope == RT_SCOPE_NOWHERE ||
-		     fa->fa_scope == r->rtm_scope) &&
-		    (!r->rtm_protocol ||
-		     fi->fib_protocol == r->rtm_protocol) &&
-		    fib_nh_match(r, nlhdr, rta, fi) == 0) {
+		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
+		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
+		     fa->fa_scope == cfg->fc_scope) &&
+		    (!cfg->fc_protocol ||
+		     fi->fib_protocol == cfg->fc_protocol) &&
+		    fib_nh_match(cfg, fi) == 0) {
 			fa_to_delete = fa;
 			break;
 		}
@@ -1614,7 +1601,8 @@ fn_trie_delete(struct fib_table *tb, str
 		return -ESRCH;
 
 	fa = fa_to_delete;
-	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id, nlhdr, req);
+	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
+		  &cfg->fc_nlinfo);
 
 	l = fib_find_node(t, key);
 	li = find_leaf_info(l, plen);
Index: net-2.6.19.git/net/ipv4/fib_lookup.h
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_lookup.h
+++ net-2.6.19.git/net/ipv4/fib_lookup.h
@@ -23,19 +23,14 @@ extern int fib_semantic_match(struct lis
 			      struct fib_result *res, __u32 zone, __u32 mask,
 				int prefixlen);
 extern void fib_release_info(struct fib_info *);
-extern struct fib_info *fib_create_info(const struct rtmsg *r,
-					struct kern_rta *rta,
-					const struct nlmsghdr *,
-					int *err);
-extern int fib_nh_match(struct rtmsg *r, struct nlmsghdr *,
-			struct kern_rta *rta, struct fib_info *fi);
+extern struct fib_info *fib_create_info(struct fib_config *cfg);
+extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			 u32 tb_id, u8 type, u8 scope, void *dst,
 			 int dst_len, u8 tos, struct fib_info *fi,
 			 unsigned int);
 extern void rtmsg_fib(int event, u32 key, struct fib_alias *fa,
-		      int z, u32 tb_id,
-		      struct nlmsghdr *n, struct netlink_skb_parms *req);
+		      int dst_len, u32 tb_id, struct nl_info *info);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
 extern int fib_detect_death(struct fib_info *fi, int order,
Index: net-2.6.19.git/include/net/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/netlink.h
+++ net-2.6.19.git/include/net/netlink.h
@@ -192,6 +192,16 @@ struct nla_policy {
 	u16		minlen;
 };
 
+/**
+ * struct nl_info - netlink source information
+ * @nlh: Netlink message header of original request
+ * @pid: Netlink PID of requesting application
+ */
+struct nl_info {
+	struct nlmsghdr		*nlh;
+	u32			pid;
+};
+
 extern void		netlink_run_queue(struct sock *sk, unsigned int *qlen,
 					  int (*cb)(struct sk_buff *,
 						    struct nlmsghdr *, int *));

