From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] net: convert (struct ubuf_info)->refcnt to refcount_t
Date: Thu, 31 Aug 2017 13:30:13 -0700
Message-ID: <20170831203013.9219-3-edumazet@google.com>
References: <20170831203013.9219-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36916 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdHaUaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 16:30:25 -0400
Received: by mail-pg0-f52.google.com with SMTP id 83so2018808pgb.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 13:30:25 -0700 (PDT)
In-Reply-To: <20170831203013.9219-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h | 5 +++--
 net/core/skbuff.c      | 8 ++++----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7594e19bce622a38dc39c054093c3da15b99b67b..316a92b45351f53709886ee0099cbc83b66f1b15 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -22,6 +22,7 @@
 #include <linux/cache.h>
 #include <linux/rbtree.h>
 #include <linux/socket.h>
+#include <linux/refcount.h>
 
 #include <linux/atomic.h>
 #include <asm/types.h>
@@ -456,7 +457,7 @@ struct ubuf_info {
 			u32 bytelen;
 		};
 	};
-	atomic_t refcnt;
+	refcount_t refcnt;
 
 	struct mmpin {
 		struct user_struct *user;
@@ -472,7 +473,7 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 
 static inline void sock_zerocopy_get(struct ubuf_info *uarg)
 {
-	atomic_inc(&uarg->refcnt);
+	refcount_inc(&uarg->refcnt);
 }
 
 void sock_zerocopy_put(struct ubuf_info *uarg);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65b9ca3945f8fd2b1bef4aef5dd774be04e5d128..ed86ca9afd9d8d1ac47983acf6006c179285a612 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -963,7 +963,7 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg->len = 1;
 	uarg->bytelen = size;
 	uarg->zerocopy = 1;
-	atomic_set(&uarg->refcnt, 1);
+	refcount_set(&uarg->refcnt, 1);
 	sock_hold(sk);
 
 	return uarg;
@@ -1086,7 +1086,7 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
-	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+	if (uarg && refcount_dec_and_test(&uarg->refcnt)) {
 		if (uarg->callback)
 			uarg->callback(uarg, uarg->zerocopy);
 		else
@@ -1108,7 +1108,7 @@ void sock_zerocopy_put_abort(struct ubuf_info *uarg)
 		 * avoid an skb send inside the main loop triggering uarg free.
 		 */
 		if (sk->sk_type != SOCK_STREAM)
-			atomic_inc(&uarg->refcnt);
+			refcount_inc(&uarg->refcnt);
 
 		sock_zerocopy_put(uarg);
 	}
@@ -1490,7 +1490,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		if (skb_orphan_frags(skb, gfp_mask))
 			goto nofrags;
 		if (skb_zcopy(skb))
-			atomic_inc(&skb_uarg(skb)->refcnt);
+			refcount_inc(&skb_uarg(skb)->refcnt);
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			skb_frag_ref(skb, i);
 
-- 
2.14.1.581.gf28d330327-goog
