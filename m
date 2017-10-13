From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next] ipv6: check fn before doing FIB6_SUBTREE(fn)
Date: Fri, 13 Oct 2017 15:01:08 -0700
Message-ID: <20171013220108.88710-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:49459 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdJMWBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 18:01:17 -0400
Received: by mail-pf0-f176.google.com with SMTP id l188so11382766pfc.6
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 15:01:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In fib6_locate(), we need to first make sure fn is not NULL before doing
FIB6_SUBTREE(fn) to avoid crash.

This fixes the following static checker warning:
net/ipv6/ip6_fib.c:1462 fib6_locate()
         warn: variable dereferenced before check 'fn' (see line 1459)

net/ipv6/ip6_fib.c
  1458          if (src_len) {
  1459                  struct fib6_node *subtree = FIB6_SUBTREE(fn);
                                                    ^^^^^^^^^^^^^^^^
We shifted this dereference

  1460
  1461                  WARN_ON(saddr == NULL);
  1462                  if (fn && subtree)
                            ^^
before the check for NULL.

  1463                          fn = fib6_locate_1(subtree, saddr, src_len,
  1464                                             offsetof(struct rt6_info, rt6i_src)

Fixes: 66f5d6ce53e6 ("ipv6: replace rwlock with rcu and spinlock in fib6_table")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c2ecd5ec638a..548af48212fc 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1456,13 +1456,16 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
-		struct fib6_node *subtree = FIB6_SUBTREE(fn);
-
 		WARN_ON(saddr == NULL);
-		if (fn && subtree)
-			fn = fib6_locate_1(subtree, saddr, src_len,
+		if (fn) {
+			struct fib6_node *subtree = FIB6_SUBTREE(fn);
+
+			if (subtree) {
+				fn = fib6_locate_1(subtree, saddr, src_len,
 					   offsetof(struct rt6_info, rt6i_src),
 					   exact_match);
+			}
+		}
 	}
 #endif
 
-- 
2.15.0.rc0.271.g36b669edcc-goog
