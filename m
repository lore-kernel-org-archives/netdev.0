From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH 2/2] IPv6 - support for NLM_F_* flags at IPv6 routing
 requests
Date: Thu, 03 Nov 2011 09:16:19 +0200
Message-ID: <1320304579.2755.1.camel@lakki>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: davem <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:10243 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754580Ab1KCHRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 03:17:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The support for NLM_F_* flags at IPv6 routing requests.

If NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
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



Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

diff -uNr linux-3.1-rc4.orig/net/ipv6/ip6_fib.c linux-3.1-rc4.new/net/ipv6/ip6_fib.c
--- linux-3.1-rc4.orig/net/ipv6/ip6_fib.c	2011-11-01 14:01:55.000000000 +0200
+++ linux-3.1-rc4.new/net/ipv6/ip6_fib.c	2011-11-03 08:34:51.000000000 +0200
@@ -429,7 +429,8 @@
 
 static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 				     int addrlen, int plen,
-				     int offset)
+				     int offset, int allow_create,
+				     int replace_required)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -451,8 +452,12 @@
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
@@ -481,10 +486,26 @@
 		fn = dir ? fn->right: fn->left;
 	} while (fn);
 
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
+		return ERR_PTR(-ENOENT);
+	}
 	/*
 	 *	We walked to the bottom of tree.
 	 *	Create new leaf node without children.
 	 */
+	if (!allow_create)
+		printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
 
 	ln = node_alloc();
 
@@ -618,6 +639,12 @@
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
 
@@ -630,6 +657,13 @@
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
@@ -659,17 +693,40 @@
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
 
 	return 0;
@@ -700,9 +757,25 @@
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
+	int allow_create = 1;
+	int replace_required = 0;
+	if (NULL != info && NULL != info->nlh) {
+		if (!(info->nlh->nlmsg_flags&NLM_F_CREATE))
+			allow_create = 0;
+		if ((info->nlh->nlmsg_flags&NLM_F_REPLACE))
+			replace_required = 1;
+	}
+	if (!allow_create && !replace_required)
+		printk(KERN_WARNING "RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
-			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst));
+		    rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
+		    allow_create, replace_required);
+
+	if (IS_ERR(fn)) {
+		err = PTR_ERR(fn);
+		fn = NULL;
+	}
 
 	if (fn == NULL)
 		goto out;
@@ -740,7 +813,8 @@
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					offsetof(struct rt6_info, rt6i_src));
+					offsetof(struct rt6_info, rt6i_src),
+					allow_create, replace_required);
 
 			if (sn == NULL) {
 				/* If it is failed, discard just allocated
@@ -757,8 +831,13 @@
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					offsetof(struct rt6_info, rt6i_src));
+					offsetof(struct rt6_info, rt6i_src),
+					allow_create, replace_required);
 
+			if (IS_ERR(sn)) {
+				err = PTR_ERR(sn);
+				sn = NULL;
+			}
 			if (sn == NULL)
 				goto st_failure;
 		}
