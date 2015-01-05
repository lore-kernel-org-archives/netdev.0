From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 2/6] net: fib6: convert cfg metric to u32 outside of table write lock
Date: Mon,  5 Jan 2015 23:57:44 +0100
Message-ID: <1420498668-4660-3-git-send-email-dborkman@redhat.com>
References: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbbAEW6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:01 -0500
In-Reply-To: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Do the nla validation earlier, outside the write lock.

This is needed by followup patch which needs to be able to call
request_module (which can sleep) if needed.

Joint work with Daniel Borkmann.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/ip6_fib.h | 10 +++++---
 net/ipv6/ip6_fib.c    | 69 +++++++++++++++++++++++++++------------------------
 net/ipv6/route.c      | 57 ++++++++++++++++++++++++++++++++++--------
 3 files changed, 90 insertions(+), 46 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 8eea35d..20e80fa 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -74,6 +74,11 @@ struct fib6_node {
 #define FIB6_SUBTREE(fn)	((fn)->subtree)
 #endif
 
+struct mx6_config {
+	const u32 *mx;
+	DECLARE_BITMAP(mx_valid, RTAX_MAX);
+};
+
 /*
  *	routing information
  *
@@ -291,9 +296,8 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
-	     struct nlattr *mx, int mx_len);
-
+int fib6_add(struct fib6_node *root, struct rt6_info *rt,
+	     struct nl_info *info, struct mx6_config *mxc);
 int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
 void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index db4984e..03c520a 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -630,31 +630,35 @@ static bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
-static int fib6_commit_metrics(struct dst_entry *dst,
-			       struct nlattr *mx, int mx_len)
+static void fib6_copy_metrics(u32 *mp, const struct mx6_config *mxc)
 {
-	bool dst_host = dst->flags & DST_HOST;
-	struct nlattr *nla;
-	int remaining;
-	u32 *mp;
+	int i;
 
-	mp = dst_host ? dst_metrics_write_ptr(dst) :
-			kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
-	if (unlikely(!mp))
-		return -ENOMEM;
-	if (!dst_host)
-		dst_init_metrics(dst, mp, 0);
+	for (i = 0; i < RTAX_MAX; i++) {
+		if (test_bit(i, mxc->mx_valid))
+			mp[i] = mxc->mx[i];
+	}
+}
+
+static int fib6_commit_metrics(struct dst_entry *dst, struct mx6_config *mxc)
+{
+	if (!mxc->mx)
+		return 0;
 
-	nla_for_each_attr(nla, mx, mx_len, remaining) {
-		int type = nla_type(nla);
+	if (dst->flags & DST_HOST) {
+		u32 *mp = dst_metrics_write_ptr(dst);
 
-		if (type) {
-			if (type > RTAX_MAX)
-				return -EINVAL;
+		if (unlikely(!mp))
+			return -ENOMEM;
 
-			mp[type - 1] = nla_get_u32(nla);
-		}
+		fib6_copy_metrics(mp, mxc);
+	} else {
+		dst_init_metrics(dst, mxc->mx, false);
+
+		/* We've stolen mx now. */
+		mxc->mx = NULL;
 	}
+
 	return 0;
 }
 
@@ -663,7 +667,7 @@ static int fib6_commit_metrics(struct dst_entry *dst,
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-			    struct nl_info *info, struct nlattr *mx, int mx_len)
+			    struct nl_info *info, struct mx6_config *mxc)
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
@@ -772,11 +776,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
-		if (mx) {
-			err = fib6_commit_metrics(&rt->dst, mx, mx_len);
-			if (err)
-				return err;
-		}
+		err = fib6_commit_metrics(&rt->dst, mxc);
+		if (err)
+			return err;
+
 		rt->dst.rt6_next = iter;
 		*ins = rt;
 		rt->rt6i_node = fn;
@@ -796,11 +799,11 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
-		if (mx) {
-			err = fib6_commit_metrics(&rt->dst, mx, mx_len);
-			if (err)
-				return err;
-		}
+
+		err = fib6_commit_metrics(&rt->dst, mxc);
+		if (err)
+			return err;
+
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
@@ -837,8 +840,8 @@ void fib6_force_start_gc(struct net *net)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
-	     struct nlattr *mx, int mx_len)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt,
+	     struct nl_info *info, struct mx6_config *mxc)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -933,7 +936,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, info, mx, mx_len);
+	err = fib6_add_rt2node(fn, rt, info, mxc);
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c910831..454771d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -853,14 +853,14 @@ EXPORT_SYMBOL(rt6_lookup);
  */
 
 static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
-			struct nlattr *mx, int mx_len)
+			struct mx6_config *mxc)
 {
 	int err;
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-	err = fib6_add(&table->tb6_root, rt, info, mx, mx_len);
+	err = fib6_add(&table->tb6_root, rt, info, mxc);
 	write_unlock_bh(&table->tb6_lock);
 
 	return err;
@@ -868,10 +868,10 @@ static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
 
 int ip6_ins_rt(struct rt6_info *rt)
 {
-	struct nl_info info = {
-		.nl_net = dev_net(rt->dst.dev),
-	};
-	return __ip6_ins_rt(rt, &info, NULL, 0);
+	struct nl_info info = {	.nl_net = dev_net(rt->dst.dev), };
+	struct mx6_config mxc = { .mx = NULL, };
+
+	return __ip6_ins_rt(rt, &info, &mxc);
 }
 
 static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
@@ -1470,9 +1470,39 @@ out:
 	return entries > rt_max_size;
 }
 
-/*
- *
- */
+static int ip6_convert_metrics(struct mx6_config *mxc,
+			       const struct fib6_config *cfg)
+{
+	struct nlattr *nla;
+	int remaining;
+	u32 *mp;
+
+	if (cfg->fc_mx == NULL)
+		return 0;
+
+	mp = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+	if (unlikely(!mp))
+		return -ENOMEM;
+
+	nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
+		int type = nla_type(nla);
+
+		if (type) {
+			if (unlikely(type > RTAX_MAX))
+				goto err;
+
+			mp[type - 1] = nla_get_u32(nla);
+			__set_bit(type - 1, mxc->mx_valid);
+		}
+	}
+
+	mxc->mx = mp;
+
+	return 0;
+ err:
+	kfree(mp);
+	return -EINVAL;
+}
 
 int ip6_route_add(struct fib6_config *cfg)
 {
@@ -1482,6 +1512,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	struct fib6_table *table;
+	struct mx6_config mxc = { .mx = NULL, };
 	int addr_type;
 
 	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
@@ -1677,8 +1708,14 @@ install_route:
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
-	return __ip6_ins_rt(rt, &cfg->fc_nlinfo, cfg->fc_mx, cfg->fc_mx_len);
+	err = ip6_convert_metrics(&mxc, cfg);
+	if (err)
+		goto out;
+
+	err = __ip6_ins_rt(rt, &cfg->fc_nlinfo, &mxc);
 
+	kfree(mxc.mx);
+	return err;
 out:
 	if (dev)
 		dev_put(dev);
-- 
1.7.11.7
