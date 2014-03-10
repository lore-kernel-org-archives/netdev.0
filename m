From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Mon, 10 Mar 2014 01:03:13 -0400 (EDT)
Message-ID: <20140310.010313.703650662340510015.davem@davemloft.net>
References: <20140308080616.GB5493@order.stressinduktion.org>
	<20140309.202658.205858191881011540.davem@davemloft.net>
	<20140310005220.GD5493@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbaCJFDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 01:03:17 -0400
In-Reply-To: <20140310005220.GD5493@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 10 Mar 2014 01:52:20 +0100

> So we need to change __ip6_ins_rt to take fib6_config as the second
> argument instead, still have the info pointer in fc_nlinfo and only have
> to wrap the info pointer in ip6_ins_rt into another structure. fib6_add
> seems to be straightforward from there.

fib6_config is too large to place on the stack I think, I was more
thinking something along these lines:

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aca0c27..9bcb220 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -284,7 +284,8 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info);
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len);
 
 int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..941df4f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -643,7 +643,7 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-			    struct nl_info *info)
+			    struct nl_info *info, struct nlattr *mx, int mx_len)
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
@@ -743,6 +743,30 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		BUG_ON(rt6i_nsiblings != rt->rt6i_nsiblings);
 	}
 
+	if (mx) {
+		struct nlattr *nla;
+		bool was_writable;
+		int remaining;
+		u32 *mp;
+
+		was_writable = !dst_metrics_read_only(&rt->dst);
+		mp = dst_metrics_write_ptr(&rt->dst);
+
+		if (was_writable)
+			memset(mp, 0, RTAX_MAX * sizeof(u32));
+
+		nla_for_each_attr(nla, mx, mx_len, remaining) {
+			int type = nla_type(nla);
+
+			if (type) {
+				if (type > RTAX_MAX)
+					return -EINVAL;
+
+				mp[type - 1] = nla_get_u32(nla);
+			}
+		}
+	}
+
 	/*
 	 *	insert node
 	 */
@@ -806,7 +830,8 @@ void fib6_force_start_gc(struct net *net)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -900,7 +925,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, info);
+	err = fib6_add_rt2node(fn, rt, info, mx, mx_len);
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fba54a4..a39d3da 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -857,14 +857,15 @@ EXPORT_SYMBOL(rt6_lookup);
    be destroyed.
  */
 
-static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
+static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
+			struct nlattr *mx, int mx_len)
 {
 	int err;
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-	err = fib6_add(&table->tb6_root, rt, info);
+	err = fib6_add(&table->tb6_root, rt, info, mx, mx_len);
 	write_unlock_bh(&table->tb6_lock);
 
 	return err;
@@ -875,7 +876,7 @@ int ip6_ins_rt(struct rt6_info *rt)
 	struct nl_info info = {
 		.nl_net = dev_net(rt->dst.dev),
 	};
-	return __ip6_ins_rt(rt, &info);
+	return __ip6_ins_rt(rt, &info, NULL, 0);
 }
 
 static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
@@ -1546,14 +1547,6 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (rt->rt6i_dst.plen == 128)
 	       rt->dst.flags |= DST_HOST;
 
-	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
-		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
-		if (!metrics) {
-			err = -ENOMEM;
-			goto out;
-		}
-		dst_init_metrics(&rt->dst, metrics, 0);
-	}
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
 	rt->rt6i_src.plen = cfg->fc_src_len;
@@ -1672,31 +1665,13 @@ int ip6_route_add(struct fib6_config *cfg)
 	rt->rt6i_flags = cfg->fc_flags;
 
 install_route:
-	if (cfg->fc_mx) {
-		struct nlattr *nla;
-		int remaining;
-
-		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
-			int type = nla_type(nla);
-
-			if (type) {
-				if (type > RTAX_MAX) {
-					err = -EINVAL;
-					goto out;
-				}
-
-				dst_metric_set(&rt->dst, type, nla_get_u32(nla));
-			}
-		}
-	}
-
 	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
-	return __ip6_ins_rt(rt, &cfg->fc_nlinfo);
+	return __ip6_ins_rt(rt, &cfg->fc_nlinfo, cfg->fc_mx, cfg->fc_mx_len);
 
 out:
 	if (dev)
