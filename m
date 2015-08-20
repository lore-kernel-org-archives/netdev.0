From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 04/10] sock: sendmsg zerocopy notification coalescing
Date: Thu, 20 Aug 2015 10:36:43 -0400
Message-ID: <1440081408-12302-5-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36595 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbHTOgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:55 -0400
Received: by qgeb6 with SMTP id b6so29095964qge.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:55 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support coalescing of zerocopy notifications.

In the simple case, each sendmsg() call generates data and eventually
a zerocopy ready notification N, where N indicates the Nth successful
invocation of sendmsg() with the MSG_ZEROCOPY flag on this socket.

TCP and corked sockets can cause sendmsg() calls to append to a single
sk_buff and ubuf_info. Modify the notification path to return an
inclusive range of notifications [N..N+m].

Add skb_zerocopy_realloc() to reuse ubuf_info across sendmsg() calls.

Additionally, revise sock_zerocopy_callback() to coalesce consecutive
notifications: if an skb_uarg [1, 1] is freed while [0, 0] is on the
notification queue, modified the head of the queue to read [0, 1] and
drop the second separate notification.

For the case of reliable ordered transmission (TCP), only the upper
value of the range to be read, as the lower value is guaranteed to
be 1 above the last read notification.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h | 11 ++++++-
 net/core/skbuff.c      | 83 ++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 87 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3372f1c..99de112 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -323,13 +323,21 @@ enum {
 struct ubuf_info {
 	void (*callback)(struct ubuf_info *, bool zerocopy_success);
 	void *ctx;
-	unsigned long desc;
+	union {
+		unsigned long desc;
+		struct {
+			u16 id;
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
@@ -337,6 +345,7 @@ static inline void sock_zerocopy_get(struct ubuf_info *uarg)
 }
 
 void sock_zerocopy_put(struct ubuf_info *uarg);
+void sock_zerocopy_put_abort(struct ubuf_info *uarg);
 
 void sock_zerocopy_callback(struct ubuf_info *uarg, bool success);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6ee7282..4ae60ee 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -854,7 +854,8 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 	uarg = (void *)skb->cb;
 
 	uarg->callback = sock_zerocopy_callback;
-	uarg->desc = atomic_inc_return(&sk->sk_zckey) - 1;
+	uarg->id = ((u16)atomic_inc_return(&sk->sk_zckey)) - 1;
+	uarg->len = 1;
 	atomic_set(&uarg->refcnt, 0);
 
 	return uarg;
@@ -863,20 +864,79 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_alloc);
 
 #define skb_from_uarg(skb)	container_of((void *)uarg, struct sk_buff, cb)
 
+struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
+					struct ubuf_info *uarg)
+{
+	if (uarg) {
+		u16 next;
+
+		/* realloc only when socket is locked (TCP, UDP cork),
+		 * so uarg->len and sk_zckey access is serialized
+		 */
+		BUG_ON(!sock_owned_by_user(sk));
+
+		if (unlikely(uarg->len == USHRT_MAX - 1))
+			return NULL;
+
+		next = atomic_read(&sk->sk_zckey);
+		if ((u16)(uarg->id + uarg->len) == next) {
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
+static bool skb_zerocopy_notify_extend(struct sk_buff *skb, u16 lo, u16 len)
+{
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
+	long sum_len;
+	u16 old_lo, old_hi;
+
+	old_lo = serr->ee.ee_data & 0xFFFF;
+	old_hi = serr->ee.ee_data >> 16;
+	sum_len = old_hi - old_lo + 1 + len;
+	if (old_hi < old_lo)
+		sum_len += (1 << 16);
+
+	if (lo != old_hi + 1 || sum_len >= (1 << 16))
+		return false;
+
+	old_hi += len;
+	serr->ee.ee_data = (old_hi << 16) | old_lo;
+	return true;
+}
+
 void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
 {
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb = skb_from_uarg(skb);
+	struct sk_buff *head, *skb = skb_from_uarg(skb);
 	struct sock *sk = skb->sk;
-	u16 id = uarg->desc;
+	struct sk_buff_head *q = &sk->sk_error_queue;
+	unsigned long flags;
+	u16 len, lo, hi;
+
+	len = uarg->len;
+	lo = uarg->id;
+	hi = uarg->id + len - 1;
 
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = 0;
 	serr->ee.ee_origin = SO_EE_ORIGIN_ZEROCOPY;
-	serr->ee.ee_data = id;
+	serr->ee.ee_data = (hi << 16) | lo;
 
-	skb_queue_tail(&sk->sk_error_queue, skb);
+	spin_lock_irqsave(&q->lock, flags);
+	head = skb_peek(q);
+	if (!head || !skb_zerocopy_notify_extend(head, lo, len)) {
+		__skb_queue_tail(q, skb);
+		skb = NULL;
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+	consume_skb(skb);
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_error_report(sk);
@@ -886,7 +946,8 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
-		if (uarg->callback)
+		/* if !len, there was only 1 call, and it was aborted */
+		if (uarg->callback && uarg->len)
 			uarg->callback(uarg, true);
 		else
 			consume_skb(skb_from_uarg(uarg));
@@ -894,6 +955,16 @@ void sock_zerocopy_put(struct ubuf_info *uarg)
 }
 EXPORT_SYMBOL_GPL(sock_zerocopy_put);
 
+/* only called when sendmsg returns with error; no notification for this call */
+void sock_zerocopy_put_abort(struct ubuf_info *uarg)
+{
+	if (uarg) {
+		uarg->len--;
+		sock_zerocopy_put(uarg);
+	}
+}
+EXPORT_SYMBOL_GPL(sock_zerocopy_put_abort);
+
 bool skb_zerocopy_alloc(struct sk_buff *skb, size_t size)
 {
 	struct ubuf_info *uarg;
-- 
2.5.0.276.gf5e568e
