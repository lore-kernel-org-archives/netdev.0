From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fib_trie: remove potential out of bound access
Date: Mon, 05 Aug 2013 11:18:49 -0700
Message-ID: <1375726729.4457.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57738 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237Ab3HESSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:18:50 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so3591791pab.38
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 11:18:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

AddressSanitizer [1] dynamic checker pointed a potential
out of bound access in leaf_walk_rcu()

We could allocate one more slot in tnode_new() to leave the prefetch()
in-place but it looks not worth the pain.

Bug added in commit 82cfbb008572b ("[IPV4] fib_trie: iterator recode")

[1] :
https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
---
 net/ipv4/fib_trie.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 108a1e9c..3df6d3e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -71,7 +71,6 @@
 #include <linux/init.h>
 #include <linux/list.h>
 #include <linux/slab.h>
-#include <linux/prefetch.h>
 #include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
@@ -1761,10 +1760,8 @@ static struct leaf *leaf_walk_rcu(struct tnode *p, struct rt_trie_node *c)
 			if (!c)
 				continue;
 
-			if (IS_LEAF(c)) {
-				prefetch(rcu_dereference_rtnl(p->child[idx]));
+			if (IS_LEAF(c))
 				return (struct leaf *) c;
-			}
 
 			/* Rescan start scanning in new node */
 			p = (struct tnode *) c;
