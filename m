From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] sock: deduplicate errqueue dequeue
Date: Sun, 31 Aug 2014 21:30:27 -0400
Message-ID: <1409535027-16963-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:57154 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbaIABac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 21:30:32 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so1867115pab.4
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 18:30:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk->sk_error_queue is dequeued in four locations. All share the
exact same logic. Deduplicate.

Also collapse the two critical sections for dequeue (at the top of
the recv handler) and signal (at the bottom).

This moves signal generation for the next packet forward, which should
be harmless.

It also changes the behavior if the recv handler exits early with an
error. Previously, a signal for follow-up packets on the errqueue
would then not be scheduled. The new behavior, to always signal, is
arguably a bug fix.

For rxrpc, the change causes the same function to be called repeatedly
for each queued packet (because the recv handler == sk_error_report).
It is likely that all packets will fail for the same reason (e.g.,
memory exhaustion).

This code runs without sk_lock held, so it is not safe to trust that
sk->sk_err is immutable inbetween releasing q->lock and the subsequent
test. Introduce int err just to avoid this potential race.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h     |  1 +
 net/core/skbuff.c      | 20 ++++++++++++++++++++
 net/core/sock.c        | 14 ++------------
 net/ipv4/ip_sockglue.c | 15 ++-------------
 net/ipv6/datagram.c    | 15 ++-------------
 net/rxrpc/ar-error.c   | 14 +-------------
 6 files changed, 28 insertions(+), 51 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f2ab72..3fde613 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2041,6 +2041,7 @@ void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
 int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
+struct sk_buff *sock_dequeue_err_skb(struct sock *sk);
 
 /*
  *	Recover an error report and clear atomically
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 163b673..53ce536 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3491,6 +3491,26 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
 
+struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
+{
+	struct sk_buff_head *q = &sk->sk_error_queue;
+	struct sk_buff *skb, *skb_next;
+	int err = 0;
+
+	spin_lock_bh(&q->lock);
+	skb = __skb_dequeue(q);
+	if (skb && (skb_next = skb_peek(q)))
+		err = SKB_EXT_ERR(skb_next)->ee.ee_errno;
+	spin_unlock_bh(&q->lock);
+
+	sk->sk_err = err;
+	if (err)
+		sk->sk_error_report(sk);
+
+	return skb;
+}
+EXPORT_SYMBOL(sock_dequeue_err_skb);
+
 void __skb_tstamp_tx(struct sk_buff *orig_skb,
 		     struct skb_shared_hwtstamps *hwtstamps,
 		     struct sock *sk, int tstype)
diff --git a/net/core/sock.c b/net/core/sock.c
index f7f2352..f1a638e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2488,11 +2488,11 @@ int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
 		       int level, int type)
 {
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb, *skb2;
+	struct sk_buff *skb;
 	int copied, err;
 
 	err = -EAGAIN;
-	skb = skb_dequeue(&sk->sk_error_queue);
+	skb = sock_dequeue_err_skb(sk);
 	if (skb == NULL)
 		goto out;
 
@@ -2513,16 +2513,6 @@ int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
 	msg->msg_flags |= MSG_ERRQUEUE;
 	err = copied;
 
-	/* Reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
-		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-
 out_free_skb:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5cb830c..455e75b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -405,7 +405,7 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
 int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 {
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb, *skb2;
+	struct sk_buff *skb;
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct {
 		struct sock_extended_err ee;
@@ -415,7 +415,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	int copied;
 
 	err = -EAGAIN;
-	skb = skb_dequeue(&sk->sk_error_queue);
+	skb = sock_dequeue_err_skb(sk);
 	if (skb == NULL)
 		goto out;
 
@@ -462,17 +462,6 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	msg->msg_flags |= MSG_ERRQUEUE;
 	err = copied;
 
-	/* Reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	skb2 = skb_peek(&sk->sk_error_queue);
-	if (skb2 != NULL) {
-		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-
 out_free_skb:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 1844e87..2cdc383 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -332,7 +332,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sock_exterr_skb *serr;
-	struct sk_buff *skb, *skb2;
+	struct sk_buff *skb;
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin, msg->msg_name);
 	struct {
 		struct sock_extended_err ee;
@@ -342,7 +342,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	int copied;
 
 	err = -EAGAIN;
-	skb = skb_dequeue(&sk->sk_error_queue);
+	skb = sock_dequeue_err_skb(sk);
 	if (skb == NULL)
 		goto out;
 
@@ -415,17 +415,6 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	msg->msg_flags |= MSG_ERRQUEUE;
 	err = copied;
 
-	/* Reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
-		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else {
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-	}
-
 out_free_skb:
 	kfree_skb(skb);
 out:
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index db57458..74c0fcd 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -37,7 +37,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 
 	_enter("%p{%d}", sk, local->debug_id);
 
-	skb = skb_dequeue(&sk->sk_error_queue);
+	skb = sock_dequeue_err_skb(sk);
 	if (!skb) {
 		_leave("UDP socket errqueue empty");
 		return;
@@ -111,18 +111,6 @@ void rxrpc_UDP_error_report(struct sock *sk)
 	skb_queue_tail(&trans->error_queue, skb);
 	rxrpc_queue_work(&trans->error_handler);
 
-	/* reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	skb = skb_peek(&sk->sk_error_queue);
-	if (skb) {
-		sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else {
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-	}
-
 	_leave("");
 }
 
-- 
2.1.0.rc2.206.gedb03e5
