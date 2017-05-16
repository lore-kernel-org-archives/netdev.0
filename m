From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 1/3] net/sock: factor out dequeue/peek with offset code
Date: Tue, 16 May 2017 11:20:13 +0200
Message-ID: <503e324ecd4085f256474df1a352a92814fd29f4.1494881617.git.pabeni@redhat.com>
References: <cover.1494881617.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751156AbdEPJVL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 05:21:11 -0400
In-Reply-To: <cover.1494881617.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And update __sk_queue_drop_skb() to work on the specified queue.
This will help the udp protocol to use an additional private
rx queue in a later patch.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |  7 ++++
 include/net/sock.h     |  4 +--
 net/core/datagram.c    | 90 ++++++++++++++++++++++++++++----------------------
 3 files changed, 60 insertions(+), 41 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a098d95..bfc7892 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3056,6 +3056,13 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 
 int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
 				const struct sk_buff *skb);
+struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
+					  struct sk_buff_head *queue,
+					  unsigned int flags,
+					  void (*destructor)(struct sock *sk,
+							   struct sk_buff *skb),
+					  int *peeked, int *off, int *err,
+					  struct sk_buff **last);
 struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
 					void (*destructor)(struct sock *sk,
 							   struct sk_buff *skb),
diff --git a/include/net/sock.h b/include/net/sock.h
index 66349e4..49d226f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2035,8 +2035,8 @@ void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 
 void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
-int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
-			unsigned int flags,
+int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
+			struct sk_buff *skb, unsigned int flags,
 			void (*destructor)(struct sock *sk,
 					   struct sk_buff *skb));
 int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index db1866f2..a4592b4 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -161,6 +161,43 @@ static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
 	return skb;
 }
 
+struct sk_buff *__skb_try_recv_from_queue(struct sock *sk,
+					  struct sk_buff_head *queue,
+					  unsigned int flags,
+					  void (*destructor)(struct sock *sk,
+							   struct sk_buff *skb),
+					  int *peeked, int *off, int *err,
+					  struct sk_buff **last)
+{
+	struct sk_buff *skb;
+
+	*last = queue->prev;
+	skb_queue_walk(queue, skb) {
+		if (flags & MSG_PEEK) {
+			if (*off >= skb->len && (skb->len || *off ||
+						 skb->peeked)) {
+				*off -= skb->len;
+				continue;
+			}
+			if (!skb->len) {
+				skb = skb_set_peeked(skb);
+				if (unlikely(IS_ERR(skb))) {
+					*err = PTR_ERR(skb);
+					return skb;
+				}
+			}
+			*peeked = 1;
+			atomic_inc(&skb->users);
+		} else {
+			__skb_unlink(skb, queue);
+			if (destructor)
+				destructor(sk, skb);
+		}
+		return skb;
+	}
+	return NULL;
+}
+
 /**
  *	__skb_try_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
@@ -216,46 +253,20 @@ struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
 
 	*peeked = 0;
 	do {
+		int _off = *off;
+
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
 		 *
 		 * Look at current nfs client by the way...
 		 * However, this function was correct in any case. 8)
 		 */
-		int _off = *off;
-
-		*last = (struct sk_buff *)queue;
 		spin_lock_irqsave(&queue->lock, cpu_flags);
-		skb_queue_walk(queue, skb) {
-			*last = skb;
-			if (flags & MSG_PEEK) {
-				if (_off >= skb->len && (skb->len || _off ||
-							 skb->peeked)) {
-					_off -= skb->len;
-					continue;
-				}
-				if (!skb->len) {
-					skb = skb_set_peeked(skb);
-					if (IS_ERR(skb)) {
-						error = PTR_ERR(skb);
-						spin_unlock_irqrestore(&queue->lock,
-								       cpu_flags);
-						goto no_packet;
-					}
-				}
-				*peeked = 1;
-				atomic_inc(&skb->users);
-			} else {
-				__skb_unlink(skb, queue);
-				if (destructor)
-					destructor(sk, skb);
-			}
-			spin_unlock_irqrestore(&queue->lock, cpu_flags);
-			*off = _off;
-			return skb;
-		}
-
+		skb = __skb_try_recv_from_queue(sk, queue, flags, destructor,
+						peeked, &_off, err, last);
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
+		if (skb)
+			return skb;
 
 		if (!sk_can_busy_loop(sk))
 			break;
@@ -335,8 +346,8 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 }
 EXPORT_SYMBOL(__skb_free_datagram_locked);
 
-int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
-			unsigned int flags,
+int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
+			struct sk_buff *skb, unsigned int flags,
 			void (*destructor)(struct sock *sk,
 					   struct sk_buff *skb))
 {
@@ -344,15 +355,15 @@ int __sk_queue_drop_skb(struct sock *sk, struct sk_buff *skb,
 
 	if (flags & MSG_PEEK) {
 		err = -ENOENT;
-		spin_lock_bh(&sk->sk_receive_queue.lock);
-		if (skb == skb_peek(&sk->sk_receive_queue)) {
-			__skb_unlink(skb, &sk->sk_receive_queue);
+		spin_lock_bh(&sk_queue->lock);
+		if (skb == skb_peek(sk_queue)) {
+			__skb_unlink(skb, sk_queue);
 			atomic_dec(&skb->users);
 			if (destructor)
 				destructor(sk, skb);
 			err = 0;
 		}
-		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		spin_unlock_bh(&sk_queue->lock);
 	}
 
 	atomic_inc(&sk->sk_drops);
@@ -383,7 +394,8 @@ EXPORT_SYMBOL(__sk_queue_drop_skb);
 
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 {
-	int err = __sk_queue_drop_skb(sk, skb, flags, NULL);
+	int err = __sk_queue_drop_skb(sk, &sk->sk_receive_queue, skb, flags,
+				      NULL);
 
 	kfree_skb(skb);
 	sk_mem_reclaim_partial(sk);
-- 
2.9.3
