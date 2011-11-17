From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH net-next] IPV6 Fix a crash when trying to replace non
 existing route
Date: Thu, 17 Nov 2011 09:18:02 +0200
Message-ID: <1321514282.1858.125.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:13980 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab1KQHGU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:06:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a crash when non existing IPv6 route is tried to be changed.

When new destination node was inserted in middle of FIB6 tree, no relevant
sanity checks were performed. Later route insertion might have been prevented
due to invalid request, causing node with no rt info being left in tree. 
When this node was accessed, a crash occurred.

Patch adds missing checks in fib6_add_1()


Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
--
diff -uNr net-next-229a66e.orig/net/ipv6/ip6_fib.c net-next-229a66e.new/net/ipv6/ip6_fib.c
--- net-next-229a66e.orig/net/ipv6/ip6_fib.c	2011-11-16 16:03:27.000000000 +0200
+++ net-next-229a66e.new/net/ipv6/ip6_fib.c	2011-11-16 16:15:25.000000000 +0200
@@ -449,9 +449,15 @@
 		 */
 		if (plen < fn->fn_bit ||
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
-			if (!allow_create)
+			if (!allow_create) {
+				if (replace_required) {
+					printk(KERN_WARNING
+					    "IPv6: Can't replace route, no match found\n");
+					return ERR_PTR(-ENOENT);
+				}
 				printk(KERN_WARNING
 				    "IPv6: NLM_F_CREATE should be set when creating new route\n");
+			}
 			goto insert_above;
 		}
 
@@ -482,7 +488,7 @@
 		fn = dir ? fn->right: fn->left;
 	} while (fn);
 
-	if (replace_required && !allow_create) {
+	if (!allow_create) {
 		/* We should not create new node because
 		 * NLM_F_REPLACE was specified without NLM_F_CREATE
 		 * I assume it is safe to require NLM_F_CREATE when
@@ -492,16 +498,17 @@
 		 * MUST be specified if new route is created.
 		 * That would keep IPv6 consistent with IPv4
 		 */
-		printk(KERN_WARNING
-		    "IPv6: NLM_F_CREATE should be set when creating new route - ignoring request\n");
-		return ERR_PTR(-ENOENT);
+		if (replace_required) {
+			printk(KERN_WARNING
+			    "IPv6: Can't replace route, no match found\n");
+			return ERR_PTR(-ENOENT);
+		}
+		printk(KERN_WARNING "IPv6: NLM_F_CREATE should be set when creating new route\n");
 	}
 	/*
 	 *	We walked to the bottom of tree.
 	 *	Create new leaf node without children.
 	 */
-	if (!allow_create)
-		printk(KERN_WARNING "IPv6: NLM_F_CREATE should be set when creating new route\n");
 
 	ln = node_alloc();
 
