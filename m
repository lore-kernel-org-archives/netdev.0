From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH] IPv6 - support for NLM_F_* flags at IPv6 routing requests
Date: Tue, 01 Nov 2011 16:22:27 +0200
Message-ID: <1320157347.11816.3.camel@lakki>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:14635 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab1KAOyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 10:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi dee Ho again.

Here's the support for NLM_F_* flags at IPv6 routing requests once again.

This time if no NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
warning is printed, but no error is returned. Instead new route is added.

Exception is when NLM_F_REPLACE flag is given without NLM_F_CREATE, and
no matching route is found. In this case it should be safe to assume
that the request issuer is familiar with NLM_F_* flags, and does really
not want route to be created.

Specifying NLM_F_REPLACE flag will now make the kernel to search for
matching route, and replace it with new one. If no route is found and
NLM_F_CREATE is specified as well, then new route is created.

Also, specifying NLM_F_EXCL will yield returning of error if matching route 
is found.

Patch is created against linux-3.1-rc4


Best Regards 
Matti Vaittinen





Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
---
diff -uNr linux-3.1-rc4.orig/net/ipv6/ip6_fib.c linux-3.1-rc4.new/net/ipv6/ip6_fib.c
--- linux-3.1-rc4.orig/net/ipv6/ip6_fib.c	2011-11-01 14:01:55.000000000 +0200
+++ linux-3.1-rc4.new/net/ipv6/ip6_fib.c	2011-11-01 14:12:28.000000000 +0200
@@ -39,6 +39,7 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
 
+#define RT6_CANT_CREATE ((int)-1)
 #define RT6_DEBUG 2
 
 #if RT6_DEBUG >= 3
@@ -429,17 +430,34 @@
 
 static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 				     int addrlen, int plen,
-				     int offset)
+				     int offset, struct nl_info *info)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
 	struct rt6key *key;
 	int	bit;
+
+
+	int allow_create = 1;
+	int replace_required = 0;
+
+
 	__be32	dir = 0;
 	__u32	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
+	if (NULL != info &&
+	    NULL != info->nlh &&
+	    (info->nlh->nlmsg_flags&NLM_F_REPLACE)) {
+		replace_required = 1;
+	}
+	if (NULL != info &&
+	    NULL != info->nlh &&
+	    !(info->nlh->nlmsg_flags&NLM_F_CREATE)) {
+			allow_create = 0;
+	}
+
 	/* insert node in tree */
 
 	fn = root;
@@ -451,8 +469,12 @@
 		 *	Prefix match
 		 */
 		if (plen < fn->fn_bit ||
-		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
+		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
+			if (!allow_create)
+				printk(KERN_WARNING
+				    "NLM_F_CREATE should be specified when creating new rt\n");
 			goto insert_above;
+		}
 
 		/*
 		 *	Exact match ?
@@ -481,10 +503,27 @@
 		fn = dir ? fn->right: fn->left;
 	} while (fn);
 
+
+	if (replace_required && !allow_create) {
+		/* We should not create new node because
+		 * NLM_F_REPLACE was specified without NLM_F_CREATE
+		 * I assume it is safe to require NLM_F_CREATE when
+		 * REPLACE flag is used! Later we may want to remove the
+		 * check for replace_required, because according
+		 * to netlink specification, NLM_F_CREATE
+		 * MUST be specified if new route is created.
+		 * That would keep IPv6 consistent with IPv4
+		 */
+		printk(KERN_WARNING
+		    "NLM_F_CREATE should be specified when creating new rt - ignoring request\n");
+		return (struct fib6_node *)RT6_CANT_CREATE;
+	}
 	/*
 	 *	We walked to the bottom of tree.
 	 *	Create new leaf node without children.
 	 */
+	if (!allow_create)
+		printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
 
 	ln = node_alloc();
 
@@ -567,7 +606,6 @@
 		fn->parent = in;
 
 		ln->fn_sernum = sernum;
-
 		if (addr_bit_set(addr, bit)) {
 			in->right = ln;
 			in->left  = fn;
@@ -585,6 +623,7 @@
 
 		ln = node_alloc();
 
+
 		if (ln == NULL)
 			return NULL;
 
@@ -618,6 +657,12 @@
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
 
@@ -630,6 +675,13 @@
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
@@ -659,19 +711,41 @@
 	/*
 	 *	insert node
 	 */
+	if (!replace) {
+		if (!add)
+			printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
+
+add:
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
+		if (!found) {
+			if (add)
+				goto add;
+			printk(KERN_WARNING "add rtinfo to node - NLM_F_REPLACE specified, but no existing node found! bailing out\n");
+			return -ENOENT;
+		}
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
-
 	return 0;
 }
 
@@ -700,10 +774,29 @@
 {
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
+	if (!allow_create && !allow_replace)
+		printk(KERN_WARNING "RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
-			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst));
+		    rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
+		    info);
 
+	if (RT6_CANT_CREATE == (int)fn) {
+		err = -EINVAL;
+		fn = NULL;
+	}
 	if (fn == NULL)
 		goto out;
 
@@ -716,6 +809,8 @@
 		if (fn->subtree == NULL) {
 			struct fib6_node *sfn;
 
+			if (!allow_create)
+				printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
 			/*
 			 * Create subtree.
 			 *
@@ -740,7 +835,8 @@
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					offsetof(struct rt6_info, rt6i_src));
+					offsetof(struct rt6_info, rt6i_src),
+				    info);
 
 			if (sn == NULL) {
 				/* If it is failed, discard just allocated
@@ -757,8 +853,13 @@
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					offsetof(struct rt6_info, rt6i_src));
+					offsetof(struct rt6_info, rt6i_src),
+					info);
 
+			if (RT6_CANT_CREATE == (int)sn) {
+				err = -EINVAL;
+				sn = NULL;
+			}
 			if (sn == NULL)
 				goto st_failure;
 		}
diff -uNr linux-3.1-rc4.orig/net/ipv6/route.c linux-3.1-rc4.new/net/ipv6/route.c
--- linux-3.1-rc4.orig/net/ipv6/route.c	2011-11-01 14:01:55.000000000 +0200
+++ linux-3.1-rc4.new/net/ipv6/route.c	2011-10-27 10:45:05.000000000 +0300
@@ -1223,9 +1223,18 @@
 	if (cfg->fc_metric == 0)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(net, cfg->fc_table);
+	err = -ENOBUFS;
+	if (NULL != cfg->fc_nlinfo.nlh &&
+	    !(cfg->fc_nlinfo.nlh->nlmsg_flags&NLM_F_CREATE)) {
+		table = fib6_get_table(net, cfg->fc_table);
+		if (table == NULL) {
+			printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
+			table = fib6_new_table(net, cfg->fc_table);
+		}
+	} else {
+		table = fib6_new_table(net, cfg->fc_table);
+	}
 	if (table == NULL) {
-		err = -ENOBUFS;
 		goto out;
 	}
 
