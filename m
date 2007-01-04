From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] fib6: Fix fn->leaf == NULL race when inserting new nodes in fib6 tree
Date: Thu, 4 Jan 2007 10:39:21 +0100
Message-ID: <20070104093921.GC8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56932 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932351AbXADJjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 04:39:01 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When inserting new nodes into a fib6 tree, the leaf pointer
is first to NULL and later corrected when the key gets
assigned. However, the tree is not locked for this period
of time, therefore nodes with an invalid leaf pointer
are accessible. Lookups that occur during this period of time
expect a valid leaf pointer and thus crash.

This patch sets the leaf pointer to ip6_null_entry during
this critical period of time.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6_fib.c	2007-01-04 10:01:43.000000000 +0100
+++ net-2.6/net/ipv6/ip6_fib.c	2007-01-04 10:17:05.000000000 +0100
@@ -150,9 +150,19 @@ static __inline__ struct fib6_node * nod
 {
 	struct fib6_node *fn;
 
-	if ((fn = kmem_cache_alloc(fib6_node_kmem, GFP_ATOMIC)) != NULL)
+	if ((fn = kmem_cache_alloc(fib6_node_kmem, GFP_ATOMIC)) != NULL) {
 		memset(fn, 0, sizeof(struct fib6_node));
 
+		/*
+		 * leaf is set to ip6_null_entry to provide a valid leaf
+		 * during the time period between inserting the node into
+		 * the tree and assigning the key. This is necessary because
+		 * the node is accessible during this period of time.
+		 */
+		fn->leaf = &ip6_null_entry;
+		fn->fn_flags |= RTN_TEMP_LEAF;
+	}
+
 	return fn;
 }
 
@@ -551,6 +561,7 @@ insert_above:
 		in->parent = pn;
 		in->leaf = fn->leaf;
 		atomic_inc(&in->leaf->rt6i_ref);
+		in->fn_flags &= ~RTN_TEMP_LEAF;
 
 		in->fn_sernum = sernum;
 
@@ -620,6 +631,12 @@ static int fib6_add_rt2node(struct fib6_
 
 	ins = &fn->leaf;
 
+	/* Avoid duplicate checks for temporary leafs */
+	if (fn->fn_flags & RTN_TEMP_LEAF) {
+		fn->fn_flags &= ~RTN_TEMP_LEAF;
+		goto out;
+	}
+
 	if (fn->fn_flags&RTN_TL_ROOT &&
 	    fn->leaf == &ip6_null_entry &&
 	    !(rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ){
Index: net-2.6/include/net/ip6_fib.h
===================================================================
--- net-2.6.orig/include/net/ip6_fib.h	2007-01-04 10:07:05.000000000 +0100
+++ net-2.6/include/net/ip6_fib.h	2007-01-04 10:09:04.000000000 +0100
@@ -135,6 +135,7 @@ struct rt6_statistics {
 #define RTN_TL_ROOT	0x0001
 #define RTN_ROOT	0x0002		/* tree root node		*/
 #define RTN_RTINFO	0x0004		/* node with valid routing info	*/
+#define RTN_TEMP_LEAF	0x0008		/* leaf is temporary		*/
 
 /*
  *	priority levels (or metrics)
