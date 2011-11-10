From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH RESUBMITTED net-next 2/2] IPv6 - support for NLM_F_* flags
 at IPv6 routing requests
Date: Thu, 10 Nov 2011 12:07:17 +0200
Message-ID: <1320919637.17667.1.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:11313 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458Ab1KJJzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 04:55:17 -0500
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

Patch created against linux-3.2-rc1


Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
--
diff -uNr Linux-3.2-rc1.orig/net/ipv6/ip6_fib.c Linux-3.2-rc1.new/net/ipv6/ip6_fib.c
--- Linux-3.2-rc1.orig/net/ipv6/ip6_fib.c	2011-11-10 08:44:18.000000000 +0200
+++ Linux-3.2-rc1.new/net/ipv6/ip6_fib.c	2011-11-10 08:46:00.000000000 +0200
@@ -425,7 +425,8 @@
 
 static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 				     int addrlen, int plen,
-				     int offset)
+				     int offset, int allow_create,
+				     int replace_required)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -447,8 +448,12 @@
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
@@ -477,10 +482,26 @@
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
 
@@ -614,6 +635,12 @@
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
 
@@ -626,6 +653,13 @@
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
@@ -655,17 +689,40 @@
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
@@ -696,9 +753,25 @@
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
@@ -736,7 +809,8 @@
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
-					offsetof(struct rt6_info, rt6i_src));
+					offsetof(struct rt6_info, rt6i_src),
+					allow_create, replace_required);
 
 			if (sn == NULL) {
 				/* If it is failed, discard just allocated
@@ -753,8 +827,13 @@
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





-- 
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
...but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
