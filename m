From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 05/12] sock: sendmsg zerocopy notification coalescing
Date: Wed, 22 Feb 2017 11:38:54 -0500
Message-ID: <20170222163901.90834-6-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35163 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932425AbdBVQjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:22 -0500
Received: by mail-qt0-f195.google.com with SMTP id b16so1059022qte.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:21 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

In the simple case, each sendmsg() call generates data and eventually
a zerocopy ready notification N, where N indicates the Nth successful
invocation of sendmsg() with the MSG_ZEROCOPY flag on this socket.

TCP and corked sockets can cause sendmsg() calls to append to a single
sk_buff and ubuf_info. Modify the notification path to return an
inclusive range of notifications [N..N+m].

Add skb_zerocopy_realloc() to reuse ubuf_info across sendmsg() calls
and modify the notification path to return a range.

For the case of reliable ordered transmission (TCP), only the upper
value of the range to be read, as the lower value is guaranteed to
be 1 above the last read notification.

Additionally, coalesce notifications in this common case: if an
skb_uarg [1, 1] is queued while [0, 0] is already on the queue,
just modify the head of the queue to read [0, 1].

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 21 +++++++++++-
 net/core/skbuff.c      | 92 +++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 107 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c7b42272b409..eedac9fd3f0f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -406,13 +406,21 @@ enum {
 struct ubuf_info {
 	void (*callback)(struct ubuf_info *, bool zerocopy_success);
 	void *ctx;
-	unsigned long desc;
+	union {
+		unsigned long desc;
+		struct {
+			u32 id;
+			u16 len;
+		};
+	};
 	atomic_t refcnt;
 };
 
 #define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
 
 struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size);
+struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
+					struct ubuf_info *uarg);
 
 static inline void sock_zerocopy_get(struct ubuf_info *uarg)
 {
@@ -420,6 +428,7 @@ static inline void sock_zerocopy_get(struct ubuf_info *uarg)
 }
 
 void sock_zerocopy_put(struct ubuf_info *uarg);
+void sock_zerocopy_put_abort(struct ubuf_info *uarg);
 
 void sock_zerocopy_callback(struct ubuf_info *uarg, bool success);
 
@@ -1276,6 +1285,16 @@ static inline void skb_zcopy_clear(struct sk_buff *skb)
 	}
 }
 
+static inline void skb_zcopy_abort(struct sk_buff *skb)
+{
+	struct ubuf_info *uarg = skb_zcopy(skb);
+
+	if (uarg) {
+		sock_zerocopy_put_abort(uarg);
+		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
+	}
+}
+
 /**
  *	skb_queue_empty - check if a queue is empty
  *	@list: queue head
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fcbdc91b2d24..7a1d6e7703a6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -928,7 +928,8 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg = (void *)skb->cb;
 
 	uarg->callback = sock_zerocopy_callback;
-	uarg->desc = atomic_inc_return(&sk->sk_zckey) - 1;
+	uarg->id = ((u32)atomic_inc_return(&sk->sk_zckey)) - 1;
+	uarg->len = 1;
 	atomic_set(&uarg->refcnt, 0);
 	sock_hold(sk);
 
@@ -941,24 +942,94 @@ static inline struct sk_buff *skb_from_uarg(struct ubuf_info *uarg)
 	return container_of((void *)uarg, struct sk_buff, cb);
 }
 
+struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
+					struct ubuf_info *uarg)
+{
+	if (uarg) {
+		u32 next;
+
+		/* realloc only when socket is locked (TCP, UDP cork),
+		 * so uarg->len and sk_zckey access is serialized
+		 */
+		BUG_ON(!sock_owned_by_user(sk));
+
+		if (unlikely(uarg->len == USHRT_MAX - 1))
+			return NULL;
+
+		next = (u32)atomic_read(&sk->sk_zckey);
+		if ((u32)(uarg->id + uarg->len) == next) {
+			uarg->len++;
+			atomic_set(&sk->sk_zckey, ++next);
+			return uarg;
+		}
+	}
+
+	return sock_zerocopy_alloc(sk, size);
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_realloc);
+
+static bool skb_zerocopy_notify_extend(struct sk_buff *skb, u32 lo, u16 len)
+{
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
+	s64 sum_len;
+	u32 old_lo, old_hi;
+
+	old_lo = serr->ee.ee_info;
+	old_hi = serr->ee.ee_data;
+	sum_len = old_hi - old_lo + 1 + len;
+	if (old_hi < old_lo)
+		sum_len += (1ULL << 32);
+
+	if (sum_len >= (1ULL << 32))
+		return false;
+
+	if (lo != old_hi + 1)
+		return false;
+
+	serr->ee.ee_data += len;
+	return true;
+}
+
 void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
 {
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb = skb_from_uarg(uarg);
+	struct sk_buff *head, *skb = skb_from_uarg(uarg);
 	struct sock *sk = skb->sk;
-	u16 id = uarg->desc;
+	struct sk_buff_head *q = &sk->sk_error_queue;
+	unsigned long flags;
+	u32 lo, hi;
+	u16 len;
+
+	/* if !len, there was only 1 call, and it was aborted
+	 * so do not queue a completion notification
+	 */
+	if (!uarg->len)
+		goto free;
+
+	len = uarg->len;
+	lo = uarg->id;
+	hi = uarg->id + len - 1;
 
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = 0;
 	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
-	serr->ee.ee_data = id;
+	serr->ee.ee_data = hi;
+	serr->ee.ee_info = lo;
 
-	skb_queue_tail(&sk->sk_error_queue, skb);
+	spin_lock_irqsave(&q->lock, flags);
+	head = skb_peek(q);
+	if (!head || !skb_zerocopy_notify_extend(head, lo, len)) {
+		__skb_queue_tail(q, skb);
+		skb = NULL;
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_error_report(sk);
 
+free:
+	consume_skb(skb);
 	sock_put(sk);
 }
 EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
@@ -974,6 +1045,17 @@ void sock_zerocopy_put(struct ubuf_info *uarg)
 }
 EXPORT_SYMBOL_GPL(sock_zerocopy_put);
 
+/* only called when sendmsg returns with error; no notification for this call */
+void sock_zerocopy_put_abort(struct ubuf_info *uarg)
+{
+	if (uarg) {
+		uarg->len--;
+		atomic_dec(&skb_from_uarg(uarg)->sk->sk_zckey);
+		sock_zerocopy_put(uarg);
+	}
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_put_abort);
+
 bool skb_zerocopy_alloc(struct sk_buff *skb, size_t size)
 {
 	struct ubuf_info *uarg;
-- 
2.11.0.483.g087da7b7c-goog
