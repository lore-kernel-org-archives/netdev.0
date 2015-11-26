From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH v2] net: Generalise wq_has_sleeper helper
Date: Thu, 26 Nov 2015 13:55:39 +0800
Message-ID: <20151126055539.GA21227@gondor.apana.org.au>
References: <20151111094829.GA23202@gondor.apana.org.au>
 <20151124055423.GA31611@gondor.apana.org.au>
 <20151125091533.GX17308@twins.programming.kicks-ass.net>
 <20151125.113729.987827630302526646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterz@infradead.org, tatsu@ab.jp.nec.com, mingo@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jolsa@redhat.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50938 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbKZFz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 00:55:58 -0500
Content-Disposition: inline
In-Reply-To: <20151125.113729.987827630302526646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 11:37:29AM -0500, David Miller wrote:
>
> > Would be easier to refer to the comment that now adorns
> > waitqueue_active().
> 
> Yeah, that might be a good idea.  Herbert can you adjust this?

Sure, here is an updated patch.  Note that this patch is based
on net-next where there is actually no comment above waitqueue_active.
But hopefully this will right itself once the trees are merged.

Thanks,

---8<---
The memory barrier in the helper wq_has_sleeper is needed by just
about every user of waitqueue_active.  This patch generalises it
by making it take a wait_queue_head_t directly.  The existing
helper is renamed to skwq_has_sleeper.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 0aa6fdf..fb99f30 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -106,7 +106,7 @@ static void aead_wmem_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
 							   POLLRDNORM |
 							   POLLRDBAND);
@@ -157,7 +157,7 @@ static void aead_data_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
 							   POLLRDNORM |
 							   POLLRDBAND);
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index af31a0e..0e6702e 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -238,7 +238,7 @@ static void skcipher_wmem_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
 							   POLLRDNORM |
 							   POLLRDBAND);
@@ -288,7 +288,7 @@ static void skcipher_data_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
 							   POLLRDNORM |
 							   POLLRDBAND);
diff --git a/include/linux/wait.h b/include/linux/wait.h
index 1e1bf9f..6aa09a8 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -107,6 +107,27 @@ static inline int waitqueue_active(wait_queue_head_t *q)
 	return !list_empty(&q->task_list);
 }
 
+/**
+ * wq_has_sleeper - check if there are any waiting processes
+ * @wq: wait queue head
+ *
+ * Returns true if wq has waiting processes
+ *
+ * Please refer to the comment for waitqueue_active.
+ */
+static inline bool wq_has_sleeper(wait_queue_head_t *wq)
+{
+	/*
+	 * We need to be sure we are in sync with the
+	 * add_wait_queue modifications to the wait queue.
+	 *
+	 * This memory barrier should be paired with one on the
+	 * waiting side.
+	 */
+	smp_mb();
+	return waitqueue_active(wq);
+}
+
 extern void add_wait_queue(wait_queue_head_t *q, wait_queue_t *wait);
 extern void add_wait_queue_exclusive(wait_queue_head_t *q, wait_queue_t *wait);
 extern void remove_wait_queue(wait_queue_head_t *q, wait_queue_t *wait);
diff --git a/include/net/sock.h b/include/net/sock.h
index bbf7c2c..4adbe00 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -58,6 +58,7 @@
 #include <linux/memcontrol.h>
 #include <linux/static_key.h>
 #include <linux/sched.h>
+#include <linux/wait.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -1879,12 +1880,12 @@ static inline bool sk_has_allocations(const struct sock *sk)
 }
 
 /**
- * wq_has_sleeper - check if there are any waiting processes
+ * skwq_has_sleeper - check if there are any waiting processes
  * @wq: struct socket_wq
  *
  * Returns true if socket_wq has waiting processes
  *
- * The purpose of the wq_has_sleeper and sock_poll_wait is to wrap the memory
+ * The purpose of the skwq_has_sleeper and sock_poll_wait is to wrap the memory
  * barrier call. They were added due to the race found within the tcp code.
  *
  * Consider following tcp code paths:
@@ -1910,15 +1911,9 @@ static inline bool sk_has_allocations(const struct sock *sk)
  * data on the socket.
  *
  */
-static inline bool wq_has_sleeper(struct socket_wq *wq)
+static inline bool skwq_has_sleeper(struct socket_wq *wq)
 {
-	/* We need to be sure we are in sync with the
-	 * add_wait_queue modifications to the wait queue.
-	 *
-	 * This memory barrier is paired in the sock_poll_wait.
-	 */
-	smp_mb();
-	return wq && waitqueue_active(&wq->wait);
+	return wq && wq_has_sleeper(&wq->wait);
 }
 
 /**
diff --git a/net/atm/common.c b/net/atm/common.c
index 49a872d..6dc1230 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -96,7 +96,7 @@ static void vcc_def_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up(&wq->wait);
 	rcu_read_unlock();
 }
@@ -117,7 +117,7 @@ static void vcc_write_space(struct sock *sk)
 
 	if (vcc_writable(sk)) {
 		wq = rcu_dereference(sk->sk_wq);
-		if (wq_has_sleeper(wq))
+		if (skwq_has_sleeper(wq))
 			wake_up_interruptible(&wq->wait);
 
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54..2769bd3a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2283,7 +2283,7 @@ static void sock_def_wakeup(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_all(&wq->wait);
 	rcu_read_unlock();
 }
@@ -2294,7 +2294,7 @@ static void sock_def_error_report(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_poll(&wq->wait, POLLERR);
 	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
 	rcu_read_unlock();
@@ -2306,7 +2306,7 @@ static void sock_def_readable(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
@@ -2324,7 +2324,7 @@ static void sock_def_write_space(struct sock *sk)
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <= sk->sk_sndbuf) {
 		wq = rcu_dereference(sk->sk_wq);
-		if (wq_has_sleeper(wq))
+		if (skwq_has_sleeper(wq))
 			wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 
diff --git a/net/core/stream.c b/net/core/stream.c
index d70f77a..8ff9d63 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -35,7 +35,7 @@ void sk_stream_write_space(struct sock *sk)
 
 		rcu_read_lock();
 		wq = rcu_dereference(sk->sk_wq);
-		if (wq_has_sleeper(wq))
+		if (skwq_has_sleeper(wq))
 			wake_up_interruptible_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 4ce912e..b66c84d 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -201,7 +201,7 @@ void dccp_write_space(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible(&wq->wait);
 	/* Should agree with poll, otherwise some programs break */
 	if (sock_writeable(sk))
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index fcb2752..4f0aa91 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -303,7 +303,7 @@ static void iucv_sock_wake_msglim(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_all(&wq->wait);
 	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	rcu_read_unlock();
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 1f8a144..7e2d105 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -67,7 +67,7 @@ static void rxrpc_write_space(struct sock *sk)
 	if (rxrpc_writable(sk)) {
 		struct socket_wq *wq = rcu_dereference(sk->sk_wq);
 
-		if (wq_has_sleeper(wq))
+		if (skwq_has_sleeper(wq))
 			wake_up_interruptible(&wq->wait);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 897c01c..ec10b66 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6978,7 +6978,7 @@ void sctp_data_ready(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 552dbab..525acf6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1492,7 +1492,7 @@ static void tipc_write_space(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 	rcu_read_unlock();
@@ -1509,7 +1509,7 @@ static void tipc_data_ready(struct sock *sk)
 
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
-	if (wq_has_sleeper(wq))
+	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	rcu_read_unlock();
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aaa0b58..0446ff1 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -339,7 +339,7 @@ static void unix_write_space(struct sock *sk)
 	rcu_read_lock();
 	if (unix_writable(sk)) {
 		wq = rcu_dereference(sk->sk_wq);
-		if (wq_has_sleeper(wq))
+		if (skwq_has_sleeper(wq))
 			wake_up_interruptible_sync_poll(&wq->wait,
 				POLLOUT | POLLWRNORM | POLLWRBAND);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
