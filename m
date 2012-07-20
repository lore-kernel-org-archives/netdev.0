From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: improve latencies of timer triggered events
Date: Fri, 20 Jul 2012 17:45:50 +0200
Message-ID: <1342799150.2626.7574.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	John Heffner <johnwheffner@gmail.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34092 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab2GTPp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:45:58 -0400
Received: by bkwj10 with SMTP id j10so3522843bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 08:45:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Modern TCP stack highly depends on tcp_write_timer() having a small
latency, but current implementation doesn't exactly meet the
expectations.

When a timer fires but finds the socket is owned by the user, it rearms
itself for an additional delay hoping next run will be more
successful.

tcp_write_timer() for example uses a 50ms delay for next try, and it
defeats many attempts to get predictable TCP behavior in term of
latencies.

Use the recently introduced tcp_release_cb(), so that the user owning
the socket will call various handlers right before socket release.

This will permit us to post a followup patch to address the
tcp_tso_should_defer() syndrome (some deferred packets have to wait
RTO timer to be transmitted, while cwnd should allow us to send them
sooner)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: John Heffner <johnwheffner@gmail.com>
---
 include/linux/tcp.h   |    4 +-
 include/net/tcp.h     |    2 +
 net/ipv4/tcp_output.c |   46 ++++++++++++++++----------
 net/ipv4/tcp_timer.c  |   70 +++++++++++++++++++++-------------------
 4 files changed, 71 insertions(+), 51 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 9febfb6..2761856 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -515,7 +515,9 @@ struct tcp_sock {
 enum tsq_flags {
 	TSQ_THROTTLED,
 	TSQ_QUEUED,
-	TSQ_OWNED, /* tcp_tasklet_func() found socket was locked */
+	TCP_TSQ_DEFERRED,	   /* tcp_tasklet_func() found socket was owned */
+	TCP_WRITE_TIMER_DEFERRED,  /* tcp_write_timer() found socket was owned */
+	TCP_DELACK_TIMER_DEFERRED, /* tcp_delack_timer() found socket was owned */
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index bc7c134..e19124b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -350,6 +350,8 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags);
 extern void tcp_release_cb(struct sock *sk);
+extern void tcp_write_timer_handler(struct sock *sk);
+extern void tcp_delack_timer_handler(struct sock *sk);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 const struct tcphdr *th, unsigned int len);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 27a32ac..950aebf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -837,6 +837,13 @@ struct tsq_tasklet {
 };
 static DEFINE_PER_CPU(struct tsq_tasklet, tsq_tasklet);
 
+static void tcp_tsq_handler(struct sock *sk)
+{
+	if ((1 << sk->sk_state) &
+	    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 | TCPF_CLOSING |
+	     TCPF_CLOSE_WAIT  | TCPF_LAST_ACK))
+		tcp_write_xmit(sk, tcp_current_mss(sk), 0, 0, GFP_ATOMIC);
+}
 /*
  * One tasklest per cpu tries to send more skbs.
  * We run in tasklet context but need to disable irqs when
@@ -864,16 +871,10 @@ static void tcp_tasklet_func(unsigned long data)
 		bh_lock_sock(sk);
 
 		if (!sock_owned_by_user(sk)) {
-			if ((1 << sk->sk_state) &
-			    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
-			     TCPF_CLOSING | TCPF_CLOSE_WAIT | TCPF_LAST_ACK))
-				tcp_write_xmit(sk,
-					       tcp_current_mss(sk),
-					       0, 0,
-					       GFP_ATOMIC);
+			tcp_tsq_handler(sk);
 		} else {
 			/* defer the work to tcp_release_cb() */
-			set_bit(TSQ_OWNED, &tp->tsq_flags);
+			set_bit(TCP_TSQ_DEFERRED, &tp->tsq_flags);
 		}
 		bh_unlock_sock(sk);
 
@@ -882,6 +883,9 @@ static void tcp_tasklet_func(unsigned long data)
 	}
 }
 
+#define TCP_DEFERRED_ALL ((1UL << TCP_TSQ_DEFERRED) |		\
+			  (1UL << TCP_WRITE_TIMER_DEFERRED) |	\
+			  (1UL << TCP_DELACK_TIMER_DEFERRED))
 /**
  * tcp_release_cb - tcp release_sock() callback
  * @sk: socket
@@ -892,16 +896,24 @@ static void tcp_tasklet_func(unsigned long data)
 void tcp_release_cb(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned long flags, nflags;
 
-	if (test_and_clear_bit(TSQ_OWNED, &tp->tsq_flags)) {
-		if ((1 << sk->sk_state) &
-		    (TCPF_ESTABLISHED | TCPF_FIN_WAIT1 |
-		     TCPF_CLOSING | TCPF_CLOSE_WAIT | TCPF_LAST_ACK))
-			tcp_write_xmit(sk,
-				       tcp_current_mss(sk),
-				       0, 0,
-				       GFP_ATOMIC);
-	}
+	/* perform an atomic operation only if at least one flag is set */
+	do {
+		flags = tp->tsq_flags;
+		if (!(flags & TCP_DEFERRED_ALL))
+			return;
+		nflags = flags & ~TCP_DEFERRED_ALL;
+	} while (cmpxchg(&tp->tsq_flags, flags, nflags) != flags);
+
+	if (flags & (1UL << TCP_TSQ_DEFERRED))
+		tcp_tsq_handler(sk);
+
+	if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED))
+		tcp_write_timer_handler(sk);
+
+	if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED))
+		tcp_delack_timer_handler(sk);
 }
 EXPORT_SYMBOL(tcp_release_cb);
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index e911e6c..6df36ad 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -32,17 +32,6 @@ int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
-static void tcp_write_timer(unsigned long);
-static void tcp_delack_timer(unsigned long);
-static void tcp_keepalive_timer (unsigned long data);
-
-void tcp_init_xmit_timers(struct sock *sk)
-{
-	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
-				  &tcp_keepalive_timer);
-}
-EXPORT_SYMBOL(tcp_init_xmit_timers);
-
 static void tcp_write_err(struct sock *sk)
 {
 	sk->sk_err = sk->sk_err_soft ? : ETIMEDOUT;
@@ -205,21 +194,11 @@ static int tcp_write_timeout(struct sock *sk)
 	return 0;
 }
 
-static void tcp_delack_timer(unsigned long data)
+void tcp_delack_timer_handler(struct sock *sk)
 {
-	struct sock *sk = (struct sock *)data;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
-	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk)) {
-		/* Try again later. */
-		icsk->icsk_ack.blocked = 1;
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
-		sk_reset_timer(sk, &icsk->icsk_delack_timer, jiffies + TCP_DELACK_MIN);
-		goto out_unlock;
-	}
-
 	sk_mem_reclaim_partial(sk);
 
 	if (sk->sk_state == TCP_CLOSE || !(icsk->icsk_ack.pending & ICSK_ACK_TIMER))
@@ -260,7 +239,21 @@ static void tcp_delack_timer(unsigned long data)
 out:
 	if (sk_under_memory_pressure(sk))
 		sk_mem_reclaim(sk);
-out_unlock:
+}
+
+static void tcp_delack_timer(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk)) {
+		tcp_delack_timer_handler(sk);
+	} else {
+		inet_csk(sk)->icsk_ack.blocked = 1;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
+		/* deleguate our work to tcp_release_cb() */
+		set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
+	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
@@ -450,19 +443,11 @@ out_reset_timer:
 out:;
 }
 
-static void tcp_write_timer(unsigned long data)
+void tcp_write_timer_handler(struct sock *sk)
 {
-	struct sock *sk = (struct sock *)data;
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int event;
 
-	bh_lock_sock(sk);
-	if (sock_owned_by_user(sk)) {
-		/* Try again later */
-		sk_reset_timer(sk, &icsk->icsk_retransmit_timer, jiffies + (HZ / 20));
-		goto out_unlock;
-	}
-
 	if (sk->sk_state == TCP_CLOSE || !icsk->icsk_pending)
 		goto out;
 
@@ -485,7 +470,19 @@ static void tcp_write_timer(unsigned long data)
 
 out:
 	sk_mem_reclaim(sk);
-out_unlock:
+}
+
+static void tcp_write_timer(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk)) {
+		tcp_write_timer_handler(sk);
+	} else {
+		/* deleguate our work to tcp_release_cb() */
+		set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
+	}
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
@@ -602,3 +599,10 @@ out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
+
+void tcp_init_xmit_timers(struct sock *sk)
+{
+	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
+				  &tcp_keepalive_timer);
+}
+EXPORT_SYMBOL(tcp_init_xmit_timers);
