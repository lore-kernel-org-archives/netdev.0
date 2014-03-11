From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Mon, 10 Mar 2014 22:38:41 -0400 (EDT)
Message-ID: <20140310.223841.953940361609160158.davem@davemloft.net>
References: <20140310.010313.703650662340510015.davem@davemloft.net>
	<20140310081533.GA27052@unicorn.suse.cz>
	<20140310120016.GH5493@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbaCKCin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 22:38:43 -0400
In-Reply-To: <20140310120016.GH5493@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 10 Mar 2014 13:00:16 +0100

> On Mon, Mar 10, 2014 at 09:15:33AM +0100, Michal Kubecek wrote:
 ...
> Full ACK, we must only intantiate inetpeers for DST_HOST dsts but it seems to
> be possible at this point, too.
 ...
>> Other than that, I believe this should work. Actually, I was also 
>> considering this approach but I wasn't brave enough to propose passing 
>> those extra parameters all the way down to rt6_add_rt2node(). But if you
>> are OK with it, I agree that saving the extra kzalloc()/kfree() is worth
>> that bit of ugliness. We could also extract the metrics from the info 
>> parameter we already have but it would be inefficient to parse the whole
>> message again.
> 
> Great! :)

Does this version address everyone's concerns?  Michal can you test it
for me?

Changes since my original patch:

1) non-DST_HOST routes keep getting the private, non-inetpeer, kzalloc()'d
   metrics

2) only instantiate the inetpeer when we really do commit to linking
   the route into the tree

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
index 075602f..d342086 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -638,12 +638,38 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
+static int fib_commit_metrics(struct dst_entry *dst, struct nlattr *mx, int mx_len)
+{
+	struct nlattr *nla;
+	bool was_writable;
+	int remaining;
+	u32 *mp;
+
+	was_writable = !dst_metrics_read_only(dst);
+	mp = dst_metrics_write_ptr(dst);
+
+	if (was_writable)
+		memset(mp, 0, RTAX_MAX * sizeof(u32));
+
+	nla_for_each_attr(nla, mx, mx_len, remaining) {
+		int type = nla_type(nla);
+
+		if (type) {
+			if (type > RTAX_MAX)
+				return -EINVAL;
+
+			mp[type - 1] = nla_get_u32(nla);
+		}
+	}
+	return 0;
+}
+
 /*
  *	Insert routing information in a node.
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-			    struct nl_info *info)
+			    struct nl_info *info, struct nlattr *mx, int mx_len)
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
@@ -653,6 +679,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
 	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
+	int err;
 
 	ins = &fn->leaf;
 
@@ -751,6 +778,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
+		err = fib_commit_metrics(&rt->dst, mx, mx_len);
+		if (err)
+			return err;
 		rt->dst.rt6_next = iter;
 		*ins = rt;
 		rt->rt6i_node = fn;
@@ -770,6 +800,9 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
+		err = fib_commit_metrics(&rt->dst, mx, mx_len);
+		if (err)
+			return err;
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
@@ -806,7 +839,8 @@ void fib6_force_start_gc(struct net *net)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -900,7 +934,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, info);
+	err = fib6_add_rt2node(fn, rt, info, mx, mx_len);
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fba54a4..d6aead7 100644
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
@@ -1672,31 +1673,13 @@ int ip6_route_add(struct fib6_config *cfg)
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
