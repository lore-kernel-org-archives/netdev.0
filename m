From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH rfc] sock: return error when sk_error_queue is not empty
Date: Tue,  2 Sep 2014 22:39:13 -0400
Message-ID: <1409711953-30543-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, hannes@redhat.com, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:56460 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbaICCjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 22:39:16 -0400
Received: by mail-ob0-f202.google.com with SMTP id wp18so1360824obc.3
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 19:39:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[rfc related to http://patchwork.ozlabs.org/patch/384606/]

Sockets can have two types of errors: those set in sk->sk_err and
those queued onto sk->sk_error_queue. When either is non-zero,
regular socket syscall processing must aborted and the error handled.

Ensure consistent behavior by introducing two new helper functions:

  sock_has_error:    test for both types of errors
  sock_peek_err_skb: extract the first errno from sk_error_queue

and update the existing codepaths to use this. In particular, change
sock_error to call sock_peek_err_skb.

Previously, errnos of queued errors would be mirrored onto sk->sk_err
in some cases to return them. Now that the queue is checked directly,
remove this assignment.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h           | 18 ++++++++++++++++++
 net/bluetooth/af_bluetooth.c |  2 +-
 net/core/datagram.c          |  2 +-
 net/core/skbuff.c            | 21 +++++++++++++++------
 net/core/sock.c              |  2 +-
 net/core/stream.c            |  2 +-
 net/ipv4/tcp.c               | 17 ++++++++---------
 net/iucv/af_iucv.c           |  2 +-
 net/nfc/llcp_sock.c          |  2 +-
 net/rxrpc/ar-output.c        |  2 +-
 net/sctp/socket.c            |  2 +-
 net/unix/af_unix.c           |  2 +-
 12 files changed, 50 insertions(+), 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3fde613..c27e2cd 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2041,8 +2041,22 @@ void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
 int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
+int sock_dequeue_and_peek_err_skb(struct sock *sk, struct sk_buff **skb);
 struct sk_buff *sock_dequeue_err_skb(struct sock *sk);
 
+static inline bool sock_has_error(struct sock *sk)
+{
+	return sk->sk_err || !skb_queue_empty(&sk->sk_error_queue);
+}
+
+static inline int sock_peek_err_skb(struct sock *sk)
+{
+	if (unlikely(!skb_queue_empty(&sk->sk_error_queue)))
+		return sock_dequeue_and_peek_err_skb(sk, NULL);
+
+	return 0;
+}
+
 /*
  *	Recover an error report and clear atomically
  */
@@ -2050,6 +2064,10 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk);
 static inline int sock_error(struct sock *sk)
 {
 	int err;
+
+	err = sock_peek_err_skb(sk);
+	if (err)
+		return err;
 	if (likely(!sk->sk_err))
 		return 0;
 	err = xchg(&sk->sk_err, 0);
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 4dca029..345dbc7 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -415,7 +415,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock,
 	if (sk->sk_state == BT_LISTEN)
 		return bt_accept_poll(sk);
 
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 488dd1a..2d585e9 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -851,7 +851,7 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	mask = 0;
 
 	/* exceptional events? */
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 53ce536..170a076 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3491,20 +3491,29 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
 
-struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
+int sock_dequeue_and_peek_err_skb(struct sock *sk, struct sk_buff **skb)
 {
 	struct sk_buff_head *q = &sk->sk_error_queue;
-	struct sk_buff *skb, *skb_next;
+	struct sk_buff *skb_next;
 	int err = 0;
 
 	spin_lock_bh(&q->lock);
-	skb = __skb_dequeue(q);
-	if (skb && (skb_next = skb_peek(q)))
+	if (skb)
+		*skb = __skb_dequeue(q);
+	skb_next = skb_peek(q);
+	if (skb_next)
 		err = SKB_EXT_ERR(skb_next)->ee.ee_errno;
 	spin_unlock_bh(&q->lock);
 
-	sk->sk_err = err;
-	if (err)
+	return err;
+}
+EXPORT_SYMBOL(sock_dequeue_and_peek_err_skb);
+
+struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	if (sock_dequeue_and_peek_err_skb(sk, &skb))
 		sk->sk_error_report(sk);
 
 	return skb;
diff --git a/net/core/sock.c b/net/core/sock.c
index f1a638e..b5a7baa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1739,7 +1739,7 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 			break;
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			break;
-		if (sk->sk_err)
+		if (sock_has_error(sk))
 			break;
 		timeo = schedule_timeout(timeo);
 	}
diff --git a/net/core/stream.c b/net/core/stream.c
index 301c05f..1554648 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -129,7 +129,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
-		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		if (sock_has_error(sk) || (sk->sk_shutdown & SEND_SHUTDOWN))
 			goto do_error;
 		if (!*timeo_p)
 			goto do_nonblock;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 541f26a..4723ff9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -534,7 +534,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	}
 	/* This barrier is coupled with smp_wmb() in tcp_reset() */
 	smp_rmb();
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR;
 
 	return mask;
@@ -757,10 +757,9 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 				break;
 			if (sock_flag(sk, SOCK_DONE))
 				break;
-			if (sk->sk_err) {
-				ret = sock_error(sk);
+			ret = sock_error(sk);
+			if (ret)
 				break;
-			}
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 			if (sk->sk_state == TCP_CLOSE) {
@@ -791,7 +790,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 		release_sock(sk);
 		lock_sock(sk);
 
-		if (sk->sk_err || sk->sk_state == TCP_CLOSE ||
+		if (sock_has_error(sk) || sk->sk_state == TCP_CLOSE ||
 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current))
 			break;
@@ -914,7 +913,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	copied = 0;
 
 	err = -EPIPE;
-	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+	if (sock_has_error(sk) || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
 	while (size > 0) {
@@ -1142,7 +1141,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	copied = 0;
 
 	err = -EPIPE;
-	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+	if (sock_has_error(sk) || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
@@ -1739,7 +1738,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			break;
 
 		if (copied) {
-			if (sk->sk_err ||
+			if (sock_has_error(sk) ||
 			    sk->sk_state == TCP_CLOSE ||
 			    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 			    !timeo ||
@@ -1749,7 +1748,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			if (sock_flag(sk, SOCK_DONE))
 				break;
 
-			if (sk->sk_err) {
+			if (sock_has_error(sk)) {
 				copied = sock_error(sk);
 				break;
 			}
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a089b6b..5ef473c 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1465,7 +1465,7 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 	if (sk->sk_state == IUCV_LISTEN)
 		return iucv_accept_poll(sk);
 
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 51f077a..06e0411 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -553,7 +553,7 @@ static unsigned int llcp_sock_poll(struct file *file, struct socket *sock,
 	if (sk->sk_state == LLCP_LISTEN)
 		return llcp_accept_poll(sk);
 
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 0b4b9a7..d663ed8 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -544,7 +544,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	/* this should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
-	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+	if (sock_has_error(sk) || (sk->sk_shutdown & SEND_SHUTDOWN))
 		return -EPIPE;
 
 	iov = msg->msg_iov;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index eb71d49..6609f17 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6437,7 +6437,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	mask = 0;
 
 	/* Is there any exceptional events?  */
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e968843..e9957fd 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2220,7 +2220,7 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	mask = 0;
 
 	/* exceptional events? */
-	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
+	if (sock_has_error(sk))
 		mask |= POLLERR |
 			(sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0);
 
-- 
2.1.0.rc2.206.gedb03e5
