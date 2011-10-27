From: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
	<matti.vaittinen.ext@nsn.com>
Subject: [PATCH] IPv6: NLM_F_* flag support for route creation/changing when using netlink.
Date: Thu, 27 Oct 2011 09:26:05 +0300
Message-ID: <82C9FC7ED59434458AD4E09AFF2DE230BF099B@FIESEXC006.nsn-intra.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:12118 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab1J0G0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 02:26:15 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi!

This patch enables checks for NLM_F_CREATE, NLM_F_REPLACE and NLM_F_EXCL
flags for IPv6 route creation. Checks are performed if netlink header in
info structure is non NULL. Patch is created against Linux 3.1.0-rc4
(Downloaded from kernel.org).

In a nutshell:
NLM_F_CREATE flag is required if new IPv6 route is being created.
If route with same key and metric exists, the route will be changed if
NLM_F_REPLACE flag is given. Else -EEXIST is returned.
Either NLM_F_CREATE or NLM_F_REPLACE must be specified in RTM_NEWROUTE
messages.


Thing to consider:
Will requiring NLM_F_CREATE break lots of existing userspace software?
Anyways, I believe this is justified. Especially in cases where user
wants to change route if it exists, but not create new one if no route
exists. And anyways, creating new routes when NLM_F_CREATE is not
specified is unexpected.



Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
---
diff -uNr linux-3.1-rc4.orig/net/ipv6/ip6_fib.c
linux-3.1-rc4.new/net/ipv6/ip6_fib.c
--- linux-3.1-rc4.orig/net/ipv6/ip6_fib.c	2011-10-26
13:15:17.000000000 +0300
+++ linux-3.1-rc4.new/net/ipv6/ip6_fib.c	2011-10-26
14:03:25.000000000 +0300
@@ -39,6 +39,7 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
 
+#define RT6_CANT_CREATE ((int)-1)
 #define RT6_DEBUG 2
 
 #if RT6_DEBUG >= 3
@@ -429,7 +430,7 @@
 
 static struct fib6_node * fib6_add_1(struct fib6_node *root, void
*addr,
 				     int addrlen, int plen,
-				     int offset)
+				     int offset, int allow_create)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -451,8 +452,11 @@
 		 *	Prefix match
 		 */
 		if (plen < fn->fn_bit ||
-		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
+		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
+			if (!allow_create)
+				return (struct fib6_node
*)RT6_CANT_CREATE;
 			goto insert_above;
+		}
 
 		/*
 		 *	Exact match ?
@@ -485,6 +489,8 @@
 	 *	We walked to the bottom of tree.
 	 *	Create new leaf node without children.
 	 */
+	if (!allow_create)
+		return (struct fib6_node *)RT6_CANT_CREATE;
 
 	ln = node_alloc();
 
@@ -618,6 +624,12 @@
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
+	int replace = (NULL != info &&
+	    NULL != info->nlh &&
+	    (info->nlh->nlmsg_flags&NLM_F_REPLACE));
+	int add = ((NULL == info || NULL == info->nlh) ||
+	    (info->nlh->nlmsg_flags&NLM_F_CREATE));
+	int found = 0;
 
 	ins = &fn->leaf;
 
@@ -630,6 +642,13 @@
 			/*
 			 *	Same priority level
 			 */
+			if (NULL != info->nlh &&
+			    (info->nlh->nlmsg_flags&NLM_F_EXCL))
+				return -EEXIST;
+			if (replace) {
+				found++;
+				break;
+			}
 
 			if (iter->rt6i_dev == rt->rt6i_dev &&
 			    iter->rt6i_idev == rt->rt6i_idev &&
@@ -659,19 +678,37 @@
 	/*
 	 *	insert node
 	 */
+	if (!replace) {
+		if (!add)
+			return -EINVAL;
+		rt->dst.rt6_next = iter;
+		*ins = rt;
+		rt->rt6i_node = fn;
+		atomic_inc(&rt->rt6i_ref);
+		inet6_rt_notify(RTM_NEWROUTE, rt, info);
+		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
+
+		if ((fn->fn_flags & RTN_RTINFO) == 0) {
+			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
+			fn->fn_flags |= RTN_RTINFO;
+		}
 
-	rt->dst.rt6_next = iter;
-	*ins = rt;
-	rt->rt6i_node = fn;
-	atomic_inc(&rt->rt6i_ref);
-	inet6_rt_notify(RTM_NEWROUTE, rt, info);
-	info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
-
-	if ((fn->fn_flags & RTN_RTINFO) == 0) {
-		info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
-		fn->fn_flags |= RTN_RTINFO;
+	} else {
+		if (!found)
+			return -ENOENT;
+		*ins = rt;
+		rt->rt6i_node = fn;
+		rt->dst.rt6_next = iter->dst.rt6_next;
+		atomic_inc(&rt->rt6i_ref);
+		inet6_rt_notify(RTM_NEWROUTE, rt, info);
+		rt6_release(iter);
+		if ((fn->fn_flags & RTN_RTINFO) == 0) {
+			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
+			fn->fn_flags |= RTN_RTINFO;
+		}
 	}
 
+
 	return 0;
 }
 
@@ -701,9 +738,31 @@
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
 
+	int allow_create = 1;
+	int allow_replace = 1;
+	if (NULL != info &&
+	    NULL != info->nlh &&
+	    !(info->nlh->nlmsg_flags&NLM_F_REPLACE)) {
+		allow_replace = 0;
+	}
+	if (NULL != info &&
+	    NULL != info->nlh &&
+	    !(info->nlh->nlmsg_flags&NLM_F_CREATE)) {
+			allow_create = 0;
+	}
+	if (!(allow_replace || allow_create)) {
+		err = -EINVAL;
+		fn = NULL;
+		goto out;
+	}
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct
in6_addr),
-			rt->rt6i_dst.plen, offsetof(struct rt6_info,
rt6i_dst));
+		    rt->rt6i_dst.plen, offsetof(struct rt6_info,
rt6i_dst),
+		    allow_create);
 
+	if (RT6_CANT_CREATE == (int)fn) {
+		err = -EINVAL;
+		fn = NULL;
+	}
 	if (fn == NULL)
 		goto out;
 
@@ -716,6 +775,11 @@
 		if (fn->subtree == NULL) {
 			struct fib6_node *sfn;
 
+			if (!allow_create) {
+				err = -EINVAL;
+				fn = NULL;
+				goto out;
+			}
 			/*
 			 * Create subtree.
 			 *
@@ -740,7 +804,7 @@
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr),
rt->rt6i_src.plen,
-					offsetof(struct rt6_info,
rt6i_src));
+					offsetof(struct rt6_info,
rt6i_src), 1);
 
 			if (sn == NULL) {
 				/* If it is failed, discard just
allocated
@@ -757,8 +821,13 @@
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr),
rt->rt6i_src.plen,
-					offsetof(struct rt6_info,
rt6i_src));
+					offsetof(struct rt6_info,
rt6i_src),
+					allow_create);
 
+			if (RT6_CANT_CREATE == (int)sn) {
+				err = -EINVAL;
+				sn = NULL;
+			}
 			if (sn == NULL)
 				goto st_failure;
 		}
diff -uNr linux-3.1-rc4.orig/net/ipv6/route.c
linux-3.1-rc4.new/net/ipv6/route.c
--- linux-3.1-rc4.orig/net/ipv6/route.c	2011-10-26 13:15:17.000000000
+0300
+++ linux-3.1-rc4.new/net/ipv6/route.c	2011-10-26 14:04:29.000000000
+0300
@@ -1223,9 +1223,15 @@
 	if (cfg->fc_metric == 0)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(net, cfg->fc_table);
+	if (NULL != cfg->fc_nlinfo.nlh &&
+	    !(cfg->fc_nlinfo.nlh->nlmsg_flags&NLM_F_CREATE)) {
+		err = -EINVAL;
+		table = fib6_get_table(net, cfg->fc_table);
+	} else {
+		err = -ENOBUFS;
+		table = fib6_new_table(net, cfg->fc_table);
+	}
 	if (table == NULL) {
-		err = -ENOBUFS;
 		goto out;
 	}
 








--
- Matti Vaittinen


Theory:
Theoretical approach means that everything is well known, but still
nothing works.
Practice:
Practical approach means that everything works but no one knows why.

Thank God we have theory and practice balanced here. Nothing works, and
no one knows why...
