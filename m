From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Tue, 11 Mar 2014 16:08:14 +0100
Message-ID: <20140311150814.GB3287@unicorn.suse.cz>
References: <20140310.010313.703650662340510015.davem@davemloft.net>
 <20140310081533.GA27052@unicorn.suse.cz>
 <20140310120016.GH5493@order.stressinduktion.org>
 <20140310.223841.953940361609160158.davem@davemloft.net>
 <20140311095309.GA3287@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57268 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753951AbaCKPIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 11:08:18 -0400
Content-Disposition: inline
In-Reply-To: <20140311095309.GA3287@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 10:53:09AM +0100, Michal Kubecek wrote:
> On Mon, Mar 10, 2014 at 10:38:41PM -0400, David Miller wrote:
> 
> > +static int fib_commit_metrics(struct dst_entry *dst, struct nlattr *mx, int mx_len)
> > +{
> > +	struct nlattr *nla;
> > +	bool was_writable;
> > +	int remaining;
> > +	u32 *mp;
> > +
> > +	was_writable = !dst_metrics_read_only(dst);
> > +	mp = dst_metrics_write_ptr(dst);
> > +
> > +	if (was_writable)
> > +		memset(mp, 0, RTAX_MAX * sizeof(u32));
> > +
> > +	nla_for_each_attr(nla, mx, mx_len, remaining) {
> > +		int type = nla_type(nla);
> > +
> > +		if (type) {
> > +			if (type > RTAX_MAX)
> > +				return -EINVAL;
> > +
> > +			mp[type - 1] = nla_get_u32(nla);
> > +		}
> > +	}
> > +	return 0;
> > +}
> 
> For DST_HOST, was_writable is always false as at this point,
> dst->_metrics still points to the shared default. I believe what we want
> to know is whether the _original_ dst_entry (the one we are replacing,
> if any) has writable metrics. Because if it has, we are reusing them, if
> not, we get new ones. For non-DST_HOST routes, we can always skip the
> memset() as we never share (writeable) metrics between old and new in
> the non-DST_HOST case.
> 
> I also believe the function should return immediately if mx is null so
> that we don't call dst_metrics_write_ptr() if no metrics are to be set
> for the new route.

Not so easy... :-( This would cause a problem if a host route is changed
twice in this way:

  ip route add fec0::1 dev eth0 rto_min 1000
  ip route change fec0::1 dev eth0
  ip route change fec0::1 dev eth0 hoplimit 10

First route has metrics in its inetpeer. This inetpeer is then inherited
by the second route but the metrics in it are not used as its dst_entry
points to the read-only default. But when it is replaced by the third
version, it inherits the inetpeer and it is not cleaned up by
ip6_cow_metrics() because it is not new.

What I ended up with is below. It uses the metrics in inetpeer if there
is one even if the new host metric doesn't have any metrics to set (in
which case it clears them first). I tested various scenarios and the
results were correct.


Changes against the previous version:

1. fib_commit_metrics() renamed to fib6_commit_metrics() for consistency

2. old_dst parameter added to it; it is set to the route we are replacing
   or null if a new route is being added

3. if no mx/mx_len are passed, do nothing except the case we are
   inheriting an inetpeer with metrics from the old route

4. zero the metrics if DST_HOST is set and the _old_ route has metrics
   writeable

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
index 075602f..8111248 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -638,12 +638,42 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
+static int fib6_commit_metrics(struct dst_entry *old_dst, struct dst_entry *dst,
+			       struct nlattr *mx, int mx_len)
+{
+	struct nlattr *nla;
+	int remaining;
+	u32 *mp;
+
+	/* no new metrics and not inheriting an inetpeer with old ones */
+	if (!mx && (!(dst->flags & DST_HOST) || !old_dst ||
+		    dst_metrics_read_only(old_dst)))
+		return 0;
+
+	mp = dst_metrics_write_ptr(dst);
+	if ((dst->flags & DST_HOST) &&
+	    old_dst && !dst_metrics_read_only(old_dst))
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
@@ -653,6 +683,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
 	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
+	int err;
 
 	ins = &fn->leaf;
 
@@ -751,6 +782,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
+		err = fib6_commit_metrics(NULL, &rt->dst, mx, mx_len);
+		if (err)
+			return err;
 		rt->dst.rt6_next = iter;
 		*ins = rt;
 		rt->rt6i_node = fn;
@@ -770,6 +804,9 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
+		err = fib6_commit_metrics(&iter->dst, &rt->dst, mx, mx_len);
+		if (err)
+			return err;
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
@@ -806,7 +843,8 @@ void fib6_force_start_gc(struct net *net)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -900,7 +938,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
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
-- 
1.8.1.4
