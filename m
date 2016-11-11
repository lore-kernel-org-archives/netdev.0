From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: fix sleeping for sk_wait_event()
Date: Fri, 11 Nov 2016 10:20:50 -0800
Message-ID: <1478888450-16985-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34478 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756861AbcKKSeN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 13:34:13 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so2105101pgc.1
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:34:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 14135f30e33c ("inet: fix sleeping inside inet_wait_for_connect()"),
sk_wait_event() needs to fix too, because release_sock() is blocking,
it changes the process state back to running after sleep, which breaks
the previous prepare_to_wait().

Switch to the new wait API.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 crypto/algif_aead.c                     |  9 ++++-----
 crypto/algif_skcipher.c                 | 18 +++++++++---------
 include/net/sock.h                      |  8 +++++---
 net/core/sock.c                         |  8 ++++----
 net/core/stream.c                       | 28 ++++++++++++++--------------
 net/decnet/af_decnet.c                  | 16 ++++++++--------
 net/llc/af_llc.c                        | 24 ++++++++++++------------
 net/phonet/pep.c                        |  9 ++++-----
 net/tipc/socket.c                       | 24 ++++++++++++------------
 net/vmw_vsock/virtio_transport_common.c | 10 +++++-----
 10 files changed, 77 insertions(+), 77 deletions(-)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 80a0f1a..8948392 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -132,28 +132,27 @@ static void aead_wmem_wakeup(struct sock *sk)
 
 static int aead_wait_for_data(struct sock *sk, unsigned flags)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct alg_sock *ask = alg_sk(sk);
 	struct aead_ctx *ctx = ask->private;
 	long timeout;
-	DEFINE_WAIT(wait);
 	int err = -ERESTARTSYS;
 
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
 	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-
+	add_wait_queue(sk_sleep(sk), &wait);
 	for (;;) {
 		if (signal_pending(current))
 			break;
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		timeout = MAX_SCHEDULE_TIMEOUT;
-		if (sk_wait_event(sk, &timeout, !ctx->more)) {
+		if (sk_wait_event(sk, &timeout, !ctx->more, &wait)) {
 			err = 0;
 			break;
 		}
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 
 	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 28556fc..1e38aaa 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -199,26 +199,26 @@ static void skcipher_free_sgl(struct sock *sk)
 
 static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
 {
-	long timeout;
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	int err = -ERESTARTSYS;
+	long timeout;
 
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
 	sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
+	add_wait_queue(sk_sleep(sk), &wait);
 	for (;;) {
 		if (signal_pending(current))
 			break;
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		timeout = MAX_SCHEDULE_TIMEOUT;
-		if (sk_wait_event(sk, &timeout, skcipher_writable(sk))) {
+		if (sk_wait_event(sk, &timeout, skcipher_writable(sk), &wait)) {
 			err = 0;
 			break;
 		}
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 
 	return err;
 }
@@ -242,10 +242,10 @@ static void skcipher_wmem_wakeup(struct sock *sk)
 
 static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct alg_sock *ask = alg_sk(sk);
 	struct skcipher_ctx *ctx = ask->private;
 	long timeout;
-	DEFINE_WAIT(wait);
 	int err = -ERESTARTSYS;
 
 	if (flags & MSG_DONTWAIT) {
@@ -254,17 +254,17 @@ static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 
 	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
+	add_wait_queue(sk_sleep(sk), &wait);
 	for (;;) {
 		if (signal_pending(current))
 			break;
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		timeout = MAX_SCHEDULE_TIMEOUT;
-		if (sk_wait_event(sk, &timeout, ctx->used)) {
+		if (sk_wait_event(sk, &timeout, ctx->used, &wait)) {
 			err = 0;
 			break;
 		}
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 
 	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index cf617ee..9d905ed 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -915,14 +915,16 @@ static inline void sock_rps_reset_rxhash(struct sock *sk)
 #endif
 }
 
-#define sk_wait_event(__sk, __timeo, __condition)			\
+#define sk_wait_event(__sk, __timeo, __condition, __wait)		\
 	({	int __rc;						\
 		release_sock(__sk);					\
 		__rc = __condition;					\
 		if (!__rc) {						\
-			*(__timeo) = schedule_timeout(*(__timeo));	\
+			*(__timeo) = wait_woken(__wait,			\
+						TASK_INTERRUPTIBLE,	\
+						*(__timeo));		\
 		}							\
-		sched_annotate_sleep();						\
+		sched_annotate_sleep();					\
 		lock_sock(__sk);					\
 		__rc = __condition;					\
 		__rc;							\
diff --git a/net/core/sock.c b/net/core/sock.c
index 40dbc13..0397928 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2078,14 +2078,14 @@ void __sk_flush_backlog(struct sock *sk)
  */
 int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	int rc;
-	DEFINE_WAIT(wait);
 
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	add_wait_queue(sk_sleep(sk), &wait);
 	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-	rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb);
+	rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb, &wait);
 	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return rc;
 }
 EXPORT_SYMBOL(sk_wait_data);
diff --git a/net/core/stream.c b/net/core/stream.c
index 1086c8b..f575bcf 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -53,8 +53,8 @@ void sk_stream_write_space(struct sock *sk)
  */
 int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct task_struct *tsk = current;
-	DEFINE_WAIT(wait);
 	int done;
 
 	do {
@@ -68,13 +68,13 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 		if (signal_pending(tsk))
 			return sock_intr_errno(*timeo_p);
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		add_wait_queue(sk_sleep(sk), &wait);
 		sk->sk_write_pending++;
 		done = sk_wait_event(sk, timeo_p,
 				     !sk->sk_err &&
 				     !((1 << sk->sk_state) &
-				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
-		finish_wait(sk_sleep(sk), &wait);
+				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 		sk->sk_write_pending--;
 	} while (!done);
 	return 0;
@@ -94,16 +94,16 @@ static inline int sk_stream_closing(struct sock *sk)
 void sk_stream_wait_close(struct sock *sk, long timeout)
 {
 	if (timeout) {
-		DEFINE_WAIT(wait);
+		DEFINE_WAIT_FUNC(wait, woken_wake_function);
+
+		add_wait_queue(sk_sleep(sk), &wait);
 
 		do {
-			prepare_to_wait(sk_sleep(sk), &wait,
-					TASK_INTERRUPTIBLE);
-			if (sk_wait_event(sk, &timeout, !sk_stream_closing(sk)))
+			if (sk_wait_event(sk, &timeout, !sk_stream_closing(sk), &wait))
 				break;
 		} while (!signal_pending(current) && timeout);
 
-		finish_wait(sk_sleep(sk), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	}
 }
 EXPORT_SYMBOL(sk_stream_wait_close);
@@ -119,16 +119,16 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 	long vm_wait = 0;
 	long current_timeo = *timeo_p;
 	bool noblock = (*timeo_p ? false : true);
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 	if (sk_stream_memory_free(sk))
 		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
 
+	add_wait_queue(sk_sleep(sk), &wait);
+
 	while (1) {
 		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-
 		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 			goto do_error;
 		if (!*timeo_p) {
@@ -147,7 +147,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		sk_wait_event(sk, &current_timeo, sk->sk_err ||
 						  (sk->sk_shutdown & SEND_SHUTDOWN) ||
 						  (sk_stream_memory_free(sk) &&
-						  !vm_wait));
+						  !vm_wait), &wait);
 		sk->sk_write_pending--;
 
 		if (vm_wait) {
@@ -161,7 +161,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		*timeo_p = current_timeo;
 	}
 out:
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return err;
 
 do_error:
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 13d6b1a..a90ed67 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1718,7 +1718,7 @@ static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 	 * See if there is data ready to read, sleep if there isn't
 	 */
 	for(;;) {
-		DEFINE_WAIT(wait);
+		DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 		if (sk->sk_err)
 			goto out;
@@ -1749,11 +1749,11 @@ static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 			goto out;
 		}
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		add_wait_queue(sk_sleep(sk), &wait);
 		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target));
+		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target), &wait);
 		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-		finish_wait(sk_sleep(sk), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	}
 
 	skb_queue_walk_safe(queue, skb, n) {
@@ -1999,19 +1999,19 @@ static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 		 * size.
 		 */
 		if (dn_queue_too_long(scp, queue, flags)) {
-			DEFINE_WAIT(wait);
+			DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 			if (flags & MSG_DONTWAIT) {
 				err = -EWOULDBLOCK;
 				goto out;
 			}
 
-			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+			add_wait_queue(sk_sleep(sk), &wait);
 			sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 			sk_wait_event(sk, &timeo,
-				      !dn_queue_too_long(scp, queue, flags));
+				      !dn_queue_too_long(scp, queue, flags), &wait);
 			sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
-			finish_wait(sk_sleep(sk), &wait);
+			remove_wait_queue(sk_sleep(sk), &wait);
 			continue;
 		}
 
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index db916cf..5e92963 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -532,12 +532,12 @@ static int llc_ui_listen(struct socket *sock, int backlog)
 
 static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
 {
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	int rc = 0;
 
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (1) {
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		if (sk_wait_event(sk, &timeout, sk->sk_state == TCP_CLOSE))
+		if (sk_wait_event(sk, &timeout, sk->sk_state == TCP_CLOSE, &wait))
 			break;
 		rc = -ERESTARTSYS;
 		if (signal_pending(current))
@@ -547,39 +547,39 @@ static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
 			break;
 		rc = 0;
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return rc;
 }
 
 static bool llc_ui_wait_for_conn(struct sock *sk, long timeout)
 {
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (1) {
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		if (sk_wait_event(sk, &timeout, sk->sk_state != TCP_SYN_SENT))
+		if (sk_wait_event(sk, &timeout, sk->sk_state != TCP_SYN_SENT, &wait))
 			break;
 		if (signal_pending(current) || !timeout)
 			break;
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return timeout;
 }
 
 static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout)
 {
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct llc_sock *llc = llc_sk(sk);
 	int rc;
 
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (1) {
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		rc = 0;
 		if (sk_wait_event(sk, &timeout,
 				  (sk->sk_shutdown & RCV_SHUTDOWN) ||
 				  (!llc_data_accept_state(llc->state) &&
 				   !llc->remote_busy_flag &&
-				   !llc->p_flag)))
+				   !llc->p_flag), &wait))
 			break;
 		rc = -ERESTARTSYS;
 		if (signal_pending(current))
@@ -588,7 +588,7 @@ static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout)
 		if (!timeout)
 			break;
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return rc;
 }
 
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 850a86c..8bad562 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -1167,7 +1167,7 @@ static int pep_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	/* Wait until flow control allows TX */
 	done = atomic_read(&pn->tx_credits);
 	while (!done) {
-		DEFINE_WAIT(wait);
+		DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
 		if (!timeo) {
 			err = -EAGAIN;
@@ -1178,10 +1178,9 @@ static int pep_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			goto out;
 		}
 
-		prepare_to_wait(sk_sleep(sk), &wait,
-				TASK_INTERRUPTIBLE);
-		done = sk_wait_event(sk, &timeo, atomic_read(&pn->tx_credits));
-		finish_wait(sk_sleep(sk), &wait);
+		add_wait_queue(sk_sleep(sk), &wait);
+		done = sk_wait_event(sk, &timeo, atomic_read(&pn->tx_credits), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 
 		if (sk->sk_state != TCP_ESTABLISHED)
 			goto disabled;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1493963..22d92f0 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -876,9 +876,9 @@ static void tipc_sk_proto_rcv(struct tipc_sock *tsk, struct sk_buff *skb,
 
 static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	DEFINE_WAIT(wait);
 	int done;
 
 	do {
@@ -892,9 +892,9 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 		if (signal_pending(current))
 			return sock_intr_errno(*timeo_p);
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		done = sk_wait_event(sk, timeo_p, !tsk->link_cong);
-		finish_wait(sk_sleep(sk), &wait);
+		add_wait_queue(sk_sleep(sk), &wait);
+		done = sk_wait_event(sk, timeo_p, !tsk->link_cong, &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
 }
@@ -1031,9 +1031,9 @@ static int __tipc_sendmsg(struct socket *sock, struct msghdr *m, size_t dsz)
 
 static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	DEFINE_WAIT(wait);
 	int done;
 
 	do {
@@ -1049,12 +1049,12 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 		if (signal_pending(current))
 			return sock_intr_errno(*timeo_p);
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		add_wait_queue(sk_sleep(sk), &wait);
 		done = sk_wait_event(sk, timeo_p,
 				     (!tsk->link_cong &&
 				      !tsk_conn_cong(tsk)) ||
-				      !tipc_sk_connected(sk));
-		finish_wait(sk_sleep(sk), &wait);
+				      !tipc_sk_connected(sk), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
 }
@@ -1929,8 +1929,8 @@ void tipc_sk_rcv(struct net *net, struct sk_buff_head *inputq)
 
 static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
 {
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 	struct sock *sk = sock->sk;
-	DEFINE_WAIT(wait);
 	int done;
 
 	do {
@@ -1942,10 +1942,10 @@ static int tipc_wait_for_connect(struct socket *sock, long *timeo_p)
 		if (signal_pending(current))
 			return sock_intr_errno(*timeo_p);
 
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+		add_wait_queue(sk_sleep(sk), &wait);
 		done = sk_wait_event(sk, timeo_p,
-				     sk->sk_state != TIPC_CONNECTING);
-		finish_wait(sk_sleep(sk), &wait);
+				     sk->sk_state != TIPC_CONNECTING, &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
 }
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index a53b3a1..687e9fd 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -619,17 +619,17 @@ static int virtio_transport_reset_no_sock(struct virtio_vsock_pkt *pkt)
 static void virtio_transport_wait_close(struct sock *sk, long timeout)
 {
 	if (timeout) {
-		DEFINE_WAIT(wait);
+		DEFINE_WAIT_FUNC(wait, woken_wake_function);
+
+		add_wait_queue(sk_sleep(sk), &wait);
 
 		do {
-			prepare_to_wait(sk_sleep(sk), &wait,
-					TASK_INTERRUPTIBLE);
 			if (sk_wait_event(sk, &timeout,
-					  sock_flag(sk, SOCK_DONE)))
+					  sock_flag(sk, SOCK_DONE), &wait))
 				break;
 		} while (!signal_pending(current) && timeout);
 
-		finish_wait(sk_sleep(sk), &wait);
+		remove_wait_queue(sk_sleep(sk), &wait);
 	}
 }
 
-- 
2.1.0
