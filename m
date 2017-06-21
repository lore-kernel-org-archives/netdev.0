From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v2 06/13] sock: MSG_ZEROCOPY notification coalescing
Date: Wed, 21 Jun 2017 16:36:45 -0400
Message-ID: <20170621203652.15306-7-willemdebruijn.kernel@gmail.com>
References: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33421 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFUUhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:37:02 -0400
In-Reply-To: <20170621203652.15306-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

In the simple case, each sendmsg() call generates data and eventually
a zerocopy ready notification N, where N indicates the Nth successful
invocation of sendmsg() with the MSG_ZEROCOPY flag on this socket.

TCP and corked sockets can cause send() calls to append new data to an
existing sk_buff and, thus, ubuf_info. In that case the notification
must hold a range. odify ubuf_info to store a inclusive range [N..N+m]
and add skb_zerocopy_realloc() to optionally extend an existing range.

Also coalesce notifications in this common case: if a notification
[1, 1] is about to be queued while [0, 0] is the queue tail, just modify
the head of the queue to read [0, 1].

Coalescing is limited to a few TSO frames worth of data to bound
notification latency.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 15 ++++++--
 net/core/skbuff.c      | 98 ++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 104 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0be25226b725..1d842860f074 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -408,14 +408,25 @@ enum {
  */
 struct ubuf_info {
 	void (*callback)(struct ubuf_info *, bool zerocopy_success);
-	void *ctx;
-	unsigned long desc;
+	union {
+		struct {
+			unsigned long desc;
+			void *ctx;
+		};
+		struct {
+			u32 id;
+			u16 len;
+			u32 bytelen;
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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 89ba5ad024a5..41fedc4e651f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -941,7 +941,9 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg = (void *)skb->cb;
 
 	uarg->callback = sock_zerocopy_callback;
-	uarg->desc = atomic_inc_return(&sk->sk_zckey) - 1;
+	uarg->id = ((u32)atomic_inc_return(&sk->sk_zckey)) - 1;
+	uarg->len = 1;
+	uarg->bytelen = size;
 	atomic_set(&uarg->refcnt, 0);
 	sock_hold(sk);
 
@@ -954,24 +956,98 @@ static inline struct sk_buff *skb_from_uarg(struct ubuf_info *uarg)
 	return container_of((void *)uarg, struct sk_buff, cb);
 }
 
+struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
+					struct ubuf_info *uarg)
+{
+	if (uarg) {
+		const u32 byte_limit = 1 << 19;		/* limit to a few TSO */
+		u32 bytelen, next;
+
+		/* realloc only when socket is locked (TCP, UDP cork),
+		 * so uarg->len and sk_zckey access is serialized
+		 */
+		if (!sock_owned_by_user(sk)) {
+			WARN_ON_ONCE(1);
+			return NULL;
+		}
+
+		bytelen = uarg->bytelen + size;
+		if (uarg->len == USHRT_MAX - 1 || bytelen > byte_limit) {
+			/* TCP can create new skb to attach new uarg */
+			if (sk->sk_type == SOCK_STREAM)
+				goto new_alloc;
+			return NULL;
+		}
+
+		next = (u32)atomic_read(&sk->sk_zckey);
+		if ((u32)(uarg->id + uarg->len) == next) {
+			uarg->len++;
+			uarg->bytelen = bytelen;
+			atomic_set(&sk->sk_zckey, ++next);
+			return uarg;
+		}
+	}
+
+new_alloc:
+	return sock_zerocopy_alloc(sk, size);
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_realloc);
+
+static bool skb_zerocopy_notify_extend(struct sk_buff *skb, u32 lo, u16 len)
+{
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
+	u64 sum_len;
+	u32 old_lo, old_hi;
+
+	old_lo = serr->ee.ee_info;
+	old_hi = serr->ee.ee_data;
+	sum_len = old_hi - old_lo + 1ULL + len;
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
+	struct sk_buff *tail, *skb = skb_from_uarg(uarg);
 	struct sock *sk = skb->sk;
-	u16 id = uarg->desc;
+	struct sk_buff_head *q = &sk->sk_error_queue;
+	unsigned long flags;
+	u32 lo, hi;
+	u16 len;
 
-	if (sock_flag(sk, SOCK_DEAD))
+	/* if !len, there was only 1 call, and it was aborted
+	 * so do not queue a completion notification
+	 */
+	if (!uarg->len || sock_flag(sk, SOCK_DEAD))
 		goto release;
 
+	len = uarg->len;
+	lo = uarg->id;
+	hi = uarg->id + len - 1;
+
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = 0;
 	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
-	serr->ee.ee_data = id;
+	serr->ee.ee_data = hi;
+	serr->ee.ee_info = lo;
 
-	skb_queue_tail(&sk->sk_error_queue, skb);
-	skb = NULL;
+	spin_lock_irqsave(&q->lock, flags);
+	tail = skb_peek_tail(q);
+	if (!tail || SKB_EXT_ERR(tail)->ee.ee_origin != SO_EE_ORIGIN_ZEROCOPY ||
+	    !skb_zerocopy_notify_extend(tail, lo, len)) {
+		__skb_queue_tail(q, skb);
+		skb = NULL;
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
 
 	sk->sk_error_report(sk);
 
@@ -998,6 +1074,7 @@ void sock_zerocopy_put_abort(struct ubuf_info *uarg)
 		struct sock *sk = skb_from_uarg(uarg)->sk;
 
 		atomic_dec(&sk->sk_zckey);
+		uarg->len--;
 
 		/* sock_zerocopy_put expects a ref. Most sockets take one per
 		 * skb, which is zero on abort. tcp_sendmsg holds one extra, to
@@ -1045,9 +1122,16 @@ int skb_zerocopy_iter_stream(struct sock *sk, struct sk_buff *skb,
 			     struct msghdr *msg, int len,
 			     struct ubuf_info *uarg)
 {
+	struct ubuf_info *orig_uarg = skb_zcopy(skb);
 	struct iov_iter orig_iter = msg->msg_iter;
 	int err, orig_len = skb->len;
 
+	/* An skb can only point to one uarg. This edge case happens when
+	 * TCP appends to an skb, but zerocopy_realloc triggered a new alloc.
+	 */
+	if (orig_uarg && uarg != orig_uarg)
+		return -EEXIST;
+
 	err = __zerocopy_sg_from_iter(sk, skb, &msg->msg_iter, len);
 	if (err == -EFAULT || (err == -EMSGSIZE && skb->len == orig_len)) {
 		/* Streams do not free skb on error. Reset to prev state. */
-- 
2.13.1.611.g7e3b11ae1-goog
