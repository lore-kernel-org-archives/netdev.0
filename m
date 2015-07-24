From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] tcp: fix recv with flags MSG_WAITALL | MSG_PEEK
Date: Fri, 24 Jul 2015 18:19:25 +0200
Message-ID: <20150724161925.GA12489@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Enrico Scholz <rh-bugzilla@ensc.de>,
	Dan Searle <dan@censornet.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754445AbbGXQT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 12:19:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, tcp_recvmsg enters a busy loop in sk_wait_data if called
with flags = MSG_WAITALL | MSG_PEEK.

sk_wait_data waits for sk_receive_queue not empty, but in this case,
the receive queue is not empty, but does not contain any skb that we
can use.

Add a "last skb seen on receive queue" argument to sk_wait_data, so
that it sleeps until the receive queue has new skbs.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=99461
Link: https://sourceware.org/bugzilla/show_bug.cgi?id=18493
Link: https://bugzilla.redhat.com/show_bug.cgi?id=1205258
Reported-by: Enrico Scholz <rh-bugzilla@ensc.de>
Reported-by: Dan Searle <dan@censornet.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/net/sock.h |  2 +-
 net/core/sock.c    |  5 +++--
 net/dccp/proto.c   |  2 +-
 net/ipv4/tcp.c     | 11 +++++++----
 net/llc/af_llc.c   |  4 ++--
 5 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 05a8c1aea251..f21f0708ec59 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -902,7 +902,7 @@ void sk_stream_kill_queues(struct sock *sk);
 void sk_set_memalloc(struct sock *sk);
 void sk_clear_memalloc(struct sock *sk);
 
-int sk_wait_data(struct sock *sk, long *timeo);
+int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb);
 
 struct request_sock_ops;
 struct timewait_sock_ops;
diff --git a/net/core/sock.c b/net/core/sock.c
index 08f16db46070..8a14f1285fc4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1967,20 +1967,21 @@ static void __release_sock(struct sock *sk)
  * sk_wait_data - wait for data to arrive at sk_receive_queue
  * @sk:    sock to wait on
  * @timeo: for how long
+ * @skb:   last skb seen on sk_receive_queue
  *
  * Now socket state including sk->sk_err is changed only under lock,
  * hence we may omit checks after joining wait queue.
  * We check receive queue before schedule() only as optimization;
  * it is very likely that release_sock() added new data.
  */
-int sk_wait_data(struct sock *sk, long *timeo)
+int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 {
 	int rc;
 	DEFINE_WAIT(wait);
 
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-	rc = sk_wait_event(sk, timeo, !skb_queue_empty(&sk->sk_receive_queue));
+	rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb);
 	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	finish_wait(sk_sleep(sk), &wait);
 	return rc;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 52a94016526d..b5cf13a28009 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -886,7 +886,7 @@ verify_sock_status:
 			break;
 		}
 
-		sk_wait_data(sk, &timeo);
+		sk_wait_data(sk, &timeo, NULL);
 		continue;
 	found_ok_skb:
 		if (len > skb->len)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7f4056785acc..45534a5ab430 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -780,7 +780,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 				ret = -EAGAIN;
 				break;
 			}
-			sk_wait_data(sk, &timeo);
+			sk_wait_data(sk, &timeo, NULL);
 			if (signal_pending(current)) {
 				ret = sock_intr_errno(timeo);
 				break;
@@ -1575,7 +1575,7 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 	int target;		/* Read at least this many bytes */
 	long timeo;
 	struct task_struct *user_recv = NULL;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *last;
 	u32 urg_hole = 0;
 
 	if (unlikely(flags & MSG_ERRQUEUE))
@@ -1635,7 +1635,9 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 
 		/* Next get a buffer. */
 
+		last = skb_peek_tail(&sk->sk_receive_queue);
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
+			last = skb;
 			/* Now that we have two receive queues this
 			 * shouldn't happen.
 			 */
@@ -1754,8 +1756,9 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 			/* Do not sleep, just process backlog. */
 			release_sock(sk);
 			lock_sock(sk);
-		} else
-			sk_wait_data(sk, &timeo);
+		} else {
+			sk_wait_data(sk, &timeo, last);
+		}
 
 		if (user_recv) {
 			int chunk;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8fd9febaa5ba..8dab4e569571 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -613,7 +613,7 @@ static int llc_wait_data(struct sock *sk, long timeo)
 		if (signal_pending(current))
 			break;
 		rc = 0;
-		if (sk_wait_data(sk, &timeo))
+		if (sk_wait_data(sk, &timeo, NULL))
 			break;
 	}
 	return rc;
@@ -802,7 +802,7 @@ static int llc_ui_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			release_sock(sk);
 			lock_sock(sk);
 		} else
-			sk_wait_data(sk, &timeo);
+			sk_wait_data(sk, &timeo, NULL);
 
 		if ((flags & MSG_PEEK) && peek_seq != llc->copied_seq) {
 			net_dbg_ratelimited("LLC(%s:%d): Application bug, race in MSG_PEEK\n",
-- 
2.4.6
