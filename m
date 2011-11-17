From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] IPV6 Fix a crash when trying to replace non
 existing route
Date: Thu, 17 Nov 2011 03:19:07 -0500 (EST)
Message-ID: <20111117.031907.303673173524299734.davem@davemloft.net>
References: <1321514282.1858.125.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab1KQITQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:19:16 -0500
In-Reply-To: <1321514282.1858.125.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Thu, 17 Nov 2011 09:18:02 +0200

> 
> This patch fixes a crash when non existing IPv6 route is tried to be changed.
> 
> When new destination node was inserted in middle of FIB6 tree, no relevant
> sanity checks were performed. Later route insertion might have been prevented
> due to invalid request, causing node with no rt info being left in tree. 
> When this node was accessed, a crash occurred.
> 
> Patch adds missing checks in fib6_add_1()
> 
> Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

Applied.

I also added the following patch, I should have caught this in your
original submission.

--------------------
[PATCH] ipv6: Use pr_warn() in ip6_fib.c

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_fib.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e7b26dc..424f063 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -451,12 +451,12 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit)) {
 			if (!allow_create) {
 				if (replace_required) {
-					printk(KERN_WARNING
-					    "IPv6: Can't replace route, no match found\n");
+					pr_warn("IPv6: Can't replace route, "
+						"no match found\n");
 					return ERR_PTR(-ENOENT);
 				}
-				printk(KERN_WARNING
-				    "IPv6: NLM_F_CREATE should be set when creating new route\n");
+				pr_warn("IPv6: NLM_F_CREATE should be set "
+					"when creating new route\n");
 			}
 			goto insert_above;
 		}
@@ -499,11 +499,11 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		 * That would keep IPv6 consistent with IPv4
 		 */
 		if (replace_required) {
-			printk(KERN_WARNING
-			    "IPv6: Can't replace route, no match found\n");
+			pr_warn("IPv6: Can't replace route, no match found\n");
 			return ERR_PTR(-ENOENT);
 		}
-		printk(KERN_WARNING "IPv6: NLM_F_CREATE should be set when creating new route\n");
+		pr_warn("IPv6: NLM_F_CREATE should be set "
+			"when creating new route\n");
 	}
 	/*
 	 *	We walked to the bottom of tree.
@@ -697,7 +697,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	 */
 	if (!replace) {
 		if (!add)
-			printk(KERN_WARNING "IPv6: NLM_F_CREATE should be set when creating new route\n");
+			pr_warn("IPv6: NLM_F_CREATE should be set when creating new route\n");
 
 add:
 		rt->dst.rt6_next = iter;
@@ -716,7 +716,7 @@ add:
 		if (!found) {
 			if (add)
 				goto add;
-			printk(KERN_WARNING "IPv6: NLM_F_REPLACE set, but no existing node found!\n");
+			pr_warn("IPv6: NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
 		*ins = rt;
@@ -768,7 +768,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 			replace_required = 1;
 	}
 	if (!allow_create && !replace_required)
-		printk(KERN_WARNING "IPv6: RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
+		pr_warn("IPv6: RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
 		    rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
-- 
1.7.6.4
