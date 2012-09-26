From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: [PATCH net] ipv6: return errno pointers consistently for
 fib6_add_1()
Date: Wed, 26 Sep 2012 09:17:07 +0800
Message-ID: <1348622227.4935.1.camel@minggr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:55800 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab2IZBTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 21:19:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib6_add_1() should consistently return errno pointers,
rather than a mixture of NULL and errno pointers.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 net/ipv6/ip6_fib.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 286acfc..24995a9 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -514,7 +514,7 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 	ln = node_alloc();
 
 	if (!ln)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	ln->fn_bit = plen;
 
 	ln->parent = pn;
@@ -561,7 +561,7 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 				node_free(in);
 			if (ln)
 				node_free(ln);
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 		}
 
 		/*
@@ -611,7 +611,7 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		ln = node_alloc();
 
 		if (!ln)
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 
 		ln->fn_bit = plen;
 
@@ -777,11 +777,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
-		fn = NULL;
-	}
-
-	if (!fn)
 		goto out;
+	}
 
 	pn = fn;
 
@@ -820,15 +817,12 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 					allow_create, replace_required);
 
 			if (IS_ERR(sn)) {
-				err = PTR_ERR(sn);
-				sn = NULL;
-			}
-			if (!sn) {
 				/* If it is failed, discard just allocated
 				   root, and then (in st_failure) stale node
 				   in main tree.
 				 */
 				node_free(sfn);
+				err = PTR_ERR(sn);
 				goto st_failure;
 			}
 
@@ -843,10 +837,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
-				sn = NULL;
-			}
-			if (!sn)
 				goto st_failure;
+			}
 		}
 
 		if (!fn->leaf) {
-- 
1.7.2.5
