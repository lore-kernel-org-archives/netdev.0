From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netns xfrm: deal with dst entries in netns
Date: Sun, 24 Jan 2010 17:40:14 +0200
Message-ID: <20100124154014.GA6124@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:59876 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab0AXPkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 10:40:16 -0500
Received: by fxm7 with SMTP id 7so1118413fxm.28
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2010 07:40:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GC is non-existent in netns, so after you hit GC threshold, no new
dst entries will be created until someone triggers cleanup in init_net.

Make xfrm4_dst_ops and xfrm6_dst_ops per-netns.
This is not done in a generic way, because it woule waste
(AF_MAX - 2) * sizeof(struct dst_ops) bytes per-netns.

Reorder GC threshold initialization so it'd be done before registering
XFRM policies.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/xfrm.h |    6 ++++
 net/ipv4/xfrm4_policy.c  |   14 ++++++-----
 net/ipv6/xfrm6_policy.c  |   25 +++++++++++--------
 net/xfrm/xfrm_policy.c   |   59 ++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 84 insertions(+), 20 deletions(-)

--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -5,6 +5,7 @@
 #include <linux/wait.h>
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
+#include <net/dst_ops.h>
 
 struct ctl_table_header;
 
@@ -42,6 +43,11 @@ struct netns_xfrm {
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 	struct work_struct	policy_hash_work;
 
+	struct dst_ops		xfrm4_dst_ops;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct dst_ops		xfrm6_dst_ops;
+#endif
+
 	struct sock		*nlsk;
 	struct sock		*nlsk_stash;
 
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -15,7 +15,6 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 
-static struct dst_ops xfrm4_dst_ops;
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
 static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
@@ -190,8 +189,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 {
-	xfrm4_policy_afinfo.garbage_collect(&init_net);
-	return (atomic_read(&xfrm4_dst_ops.entries) > xfrm4_dst_ops.gc_thresh*2);
+	struct net *net = container_of(ops, struct net, xfrm.xfrm4_dst_ops);
+
+	xfrm4_policy_afinfo.garbage_collect(net);
+	return (atomic_read(&ops->entries) > ops->gc_thresh * 2);
 }
 
 static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -268,7 +269,7 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 static struct ctl_table xfrm4_policy_table[] = {
 	{
 		.procname       = "xfrm4_gc_thresh",
-		.data           = &xfrm4_dst_ops.gc_thresh,
+		.data           = &init_net.xfrm.xfrm4_dst_ops.gc_thresh,
 		.maxlen         = sizeof(int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
@@ -295,8 +296,6 @@ static void __exit xfrm4_policy_fini(void)
 
 void __init xfrm4_init(int rt_max_size)
 {
-	xfrm4_state_init();
-	xfrm4_policy_init();
 	/*
 	 * Select a default value for the gc_thresh based on the main route
 	 * table hash size.  It seems to me the worst case scenario is when
@@ -308,6 +307,9 @@ void __init xfrm4_init(int rt_max_size)
 	 * and start cleaning when were 1/2 full
 	 */
 	xfrm4_dst_ops.gc_thresh = rt_max_size/2;
+
+	xfrm4_state_init();
+	xfrm4_policy_init();
 #ifdef CONFIG_SYSCTL
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path,
 						xfrm4_policy_table);
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -24,7 +24,6 @@
 #include <net/mip6.h>
 #endif
 
-static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
 static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
@@ -224,8 +223,10 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 {
-	xfrm6_policy_afinfo.garbage_collect(&init_net);
-	return (atomic_read(&xfrm6_dst_ops.entries) > xfrm6_dst_ops.gc_thresh*2);
+	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
+
+	xfrm6_policy_afinfo.garbage_collect(net);
+	return (atomic_read(&ops->entries) > ops->gc_thresh * 2);
 }
 
 static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -310,7 +311,7 @@ static void xfrm6_policy_fini(void)
 static struct ctl_table xfrm6_policy_table[] = {
 	{
 		.procname       = "xfrm6_gc_thresh",
-		.data	   	= &xfrm6_dst_ops.gc_thresh,
+		.data	   	= &init_net.xfrm.xfrm6_dst_ops.gc_thresh,
 		.maxlen	 	= sizeof(int),
 		.mode	   	= 0644,
 		.proc_handler   = proc_dointvec,
@@ -326,13 +327,6 @@ int __init xfrm6_init(void)
 	int ret;
 	unsigned int gc_thresh;
 
-	ret = xfrm6_policy_init();
-	if (ret)
-		goto out;
-
-	ret = xfrm6_state_init();
-	if (ret)
-		goto out_policy;
 	/*
 	 * We need a good default value for the xfrm6 gc threshold.
 	 * In ipv4 we set it to the route hash table size * 8, which
@@ -346,6 +340,15 @@ int __init xfrm6_init(void)
 	 */
 	gc_thresh = FIB6_TABLE_HASHSZ * 8;
 	xfrm6_dst_ops.gc_thresh = (gc_thresh < 1024) ? 1024 : gc_thresh;
+
+	ret = xfrm6_policy_init();
+	if (ret)
+		goto out;
+
+	ret = xfrm6_state_init();
+	if (ret)
+		goto out_policy;
+
 #ifdef CONFIG_SYSCTL
 	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv6_ctl_path,
 						xfrm6_policy_table);
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1309,15 +1309,28 @@ static inline int xfrm_get_tos(struct flowi *fl, int family)
 	return tos;
 }
 
-static inline struct xfrm_dst *xfrm_alloc_dst(int family)
+static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	struct dst_ops *dst_ops;
 	struct xfrm_dst *xdst;
 
 	if (!afinfo)
 		return ERR_PTR(-EINVAL);
 
-	xdst = dst_alloc(afinfo->dst_ops) ?: ERR_PTR(-ENOBUFS);
+	switch (family) {
+	case AF_INET:
+		dst_ops = &net->xfrm.xfrm4_dst_ops;
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		dst_ops = &net->xfrm.xfrm6_dst_ops;
+		break;
+#endif
+	default:
+		BUG();
+	}
+	xdst = dst_alloc(dst_ops) ?: ERR_PTR(-ENOBUFS);
 
 	xfrm_policy_put_afinfo(afinfo);
 
@@ -1366,6 +1379,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 					    struct flowi *fl,
 					    struct dst_entry *dst)
 {
+	struct net *net = xp_net(policy);
 	unsigned long now = jiffies;
 	struct net_device *dev;
 	struct dst_entry *dst_prev = NULL;
@@ -1389,7 +1403,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	dst_hold(dst);
 
 	for (; i < nx; i++) {
-		struct xfrm_dst *xdst = xfrm_alloc_dst(family);
+		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
 		struct dst_entry *dst1 = &xdst->u.dst;
 
 		err = PTR_ERR(xdst);
@@ -2279,6 +2293,7 @@ EXPORT_SYMBOL(xfrm_bundle_ok);
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
+	struct net *net;
 	int err = 0;
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
@@ -2302,6 +2317,27 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		xfrm_policy_afinfo[afinfo->family] = afinfo;
 	}
 	write_unlock_bh(&xfrm_policy_afinfo_lock);
+
+	rtnl_lock();
+	for_each_net(net) {
+		struct dst_ops *xfrm_dst_ops;
+
+		switch (afinfo->family) {
+		case AF_INET:
+			xfrm_dst_ops = &net->xfrm.xfrm4_dst_ops;
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case AF_INET6:
+			xfrm_dst_ops = &net->xfrm.xfrm6_dst_ops;
+			break;
+#endif
+		default:
+			BUG();
+		}
+		*xfrm_dst_ops = *afinfo->dst_ops;
+	}
+	rtnl_unlock();
+
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_register_afinfo);
@@ -2332,6 +2368,22 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
+static void __net_init xfrm_dst_ops_init(struct net *net)
+{
+	struct xfrm_policy_afinfo *afinfo;
+
+	read_lock_bh(&xfrm_policy_afinfo_lock);
+	afinfo = xfrm_policy_afinfo[AF_INET];
+	if (afinfo)
+		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	afinfo = xfrm_policy_afinfo[AF_INET6];
+	if (afinfo)
+		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
+#endif
+	read_unlock_bh(&xfrm_policy_afinfo_lock);
+}
+
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo;
@@ -2494,6 +2546,7 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_policy_init(net);
 	if (rv < 0)
 		goto out_policy;
+	xfrm_dst_ops_init(net);
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
