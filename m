From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 07/12] sock: sendmsg zerocopy limit bytes per notification
Date: Wed, 22 Feb 2017 11:38:56 -0500
Message-ID: <20170222163901.90834-8-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35175 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932523AbdBVQjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:25 -0500
Received: by mail-qt0-f193.google.com with SMTP id b16so1059287qte.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:19 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Zerocopy can coalesce notifications of up to 65535 send calls.
Excessive coalescing increases notification latency and process
working set size.

Experiments showed trains of 75 syscalls holding around 8 MB of data
per notification. On servers with many slower clients, this causes
many GB of user data waiting for acknowledgment and many seconds of
latency between send and notification reception.

Introduce a notification byte limit.

Implementation notes:
- Due to space constraints in struct ubuf_info, the internal
  calculation is approximate, in Kilobytes and capped to 64MB.

- The field is accessed only on initial allocation of ubuf_info, when
  the struct is private, or under the tcp lock.

- When breaking a chain, we create a new notification structure uarg.
  A chain can be broken in the middle of a large sendmsg. Each skbuff
  can only point to a single uarg, so skb_zerocopy_add_frags_iter will
  fail after breaking a chain. The (next) TCP patch is changed in v2
  to detect failure (EEXIST) and jump to new_segment to create a new
  skbuff that can point to the new uarg. As a result, packetization of
  the bytestream may differ from a send without zerocopy.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a38308b10d76..6ad1724ceb60 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -411,6 +411,7 @@ struct ubuf_info {
 		struct {
 			u32 id;
 			u16 len;
+			u16 kbytelen;
 		};
 	};
 	atomic_t refcnt;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b86e196d6dec..6a07a20a91ed 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -974,6 +974,7 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg->callback = sock_zerocopy_callback;
 	uarg->id = ((u32)atomic_inc_return(&sk->sk_zckey)) - 1;
 	uarg->len = 1;
+	uarg->kbytelen = min_t(size_t, DIV_ROUND_UP(size, 1024u), USHRT_MAX);
 	atomic_set(&uarg->refcnt, 0);
 	sock_hold(sk);
 
@@ -990,6 +991,8 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 					struct ubuf_info *uarg)
 {
 	if (uarg) {
+		const size_t limit_kb = 512;	/* consider a sysctl */
+		size_t kbytelen;
 		u32 next;
 
 		/* realloc only when socket is locked (TCP, UDP cork),
@@ -997,8 +1000,13 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 		 */
 		BUG_ON(!sock_owned_by_user(sk));
 
+		kbytelen = uarg->kbytelen + DIV_ROUND_UP(size, 1024u);
+		if (unlikely(kbytelen > limit_kb))
+			goto new_alloc;
+		uarg->kbytelen = kbytelen;
+
 		if (unlikely(uarg->len == USHRT_MAX - 1))
-			return NULL;
+			goto new_alloc;
 
 		next = (u32)atomic_read(&sk->sk_zckey);
 		if ((u32)(uarg->id + uarg->len) == next) {
@@ -1010,6 +1018,7 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 		}
 	}
 
+new_alloc:
 	return sock_zerocopy_alloc(sk, size);
 }
 EXPORT_SYMBOL_GPL(sock_zerocopy_realloc);
-- 
2.11.0.483.g087da7b7c-goog
