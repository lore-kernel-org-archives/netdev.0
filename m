From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/2] Revert "Merge branch 'ipv6-overflow-arith'"
Date: Wed, 28 Oct 2015 13:21:03 +0100
Message-ID: <1446034864-14022-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47796 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932178AbbJ1MVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 08:21:11 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id CD40A2011F
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 08:21:10 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus dislikes these changes. To not hold up the net-merge let's revert
it for now and fix the bug like Linus suggested.

This reverts commit ec3661b42257d9a06cf0d318175623ac7a660113, reversing
changes made to c80dbe04612986fd6104b4a1be21681b113b5ac9.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Sorry for delaying the net pull request!

 include/linux/compiler-gcc.h   |  4 ----
 include/linux/overflow-arith.h | 18 ------------------
 net/ipv6/ip6_output.c          |  6 +-----
 3 files changed, 1 insertion(+), 27 deletions(-)
 delete mode 100644 include/linux/overflow-arith.h

diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index 82c159e..dfaa7b3 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -237,10 +237,6 @@
 #define KASAN_ABI_VERSION 3
 #endif
 
-#if GCC_VERSION >= 50000
-#define CC_HAVE_BUILTIN_OVERFLOW
-#endif
-
 #endif	/* gcc version >= 40000 specific checks */
 
 #if !defined(__noclone)
diff --git a/include/linux/overflow-arith.h b/include/linux/overflow-arith.h
deleted file mode 100644
index e12ccf8..0000000
--- a/include/linux/overflow-arith.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#pragma once
-
-#include <linux/kernel.h>
-
-#ifdef CC_HAVE_BUILTIN_OVERFLOW
-
-#define overflow_usub __builtin_usub_overflow
-
-#else
-
-static inline bool overflow_usub(unsigned int a, unsigned int b,
-				 unsigned int *res)
-{
-	*res = a - b;
-	return *res > a ? true : false;
-}
-
-#endif
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8dddb45..d03d6da 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -28,7 +28,6 @@
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/overflow-arith.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/net.h>
@@ -585,10 +584,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 		if (np->frag_size)
 			mtu = np->frag_size;
 	}
-
-	if (overflow_usub(mtu, hlen + sizeof(struct frag_hdr), &mtu) ||
-	    mtu <= 7)
-		goto fail_toobig;
+	mtu -= hlen + sizeof(struct frag_hdr);
 
 	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
 				    &ipv6_hdr(skb)->saddr);
-- 
2.4.3
