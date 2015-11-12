From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Thu, 12 Nov 2015 08:43:18 -0800
Message-ID: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33299 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999AbbKLQnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 11:43:20 -0500
Received: by pabfh17 with SMTP id fh17so69751203pab.0
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2015 08:43:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some functions access TCP sockets without holding a lock and
might output non consistent data, depending on compiler and or
architecture.

tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...

Introduce sk_state_load() and sk_state_store() to fix the issues,
and more clearly document where this lack of locking is happening.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h              |   25 +++++++++++++++++++++++++
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/tcp.c                  |   21 +++++++++++----------
 net/ipv4/tcp_diag.c             |    2 +-
 net/ipv4/tcp_ipv4.c             |   14 ++++++++------
 net/ipv6/tcp_ipv6.c             |   19 +++++++++++++++----
 6 files changed, 62 insertions(+), 23 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index bbf7c2cf15b4..7f89e4ba18d1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2226,6 +2226,31 @@ static inline bool sk_listener(const struct sock *sk)
 	return (1 << sk->sk_state) & (TCPF_LISTEN | TCPF_NEW_SYN_RECV);
 }
 
+/**
+ * sk_state_load - read sk->sk_state for lockless contexts
+ * @sk: socket pointer
+ *
+ * Paired with sk_state_store(). Used in places we do not hold socket lock :
+ * tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...
+ */
+static inline int sk_state_load(const struct sock *sk)
+{
+	return smp_load_acquire(&sk->sk_state);
+}
+
+/**
+ * sk_state_store - update sk->sk_state
+ * @sk: socket pointer
+ * @newstate: new state
+ *
+ * Paired with sk_state_load(). Should be used in contexts where
+ * state change might impact lockless readers.
+ */
+static inline void sk_state_store(struct sock *sk, int newstate)
+{
+	smp_store_release(&sk->sk_state, newstate);
+}
+
 void sock_enable_timestamp(struct sock *sk, int flag);
 int sock_get_timestamp(struct sock *, struct timeval __user *);
 int sock_get_timestampns(struct sock *, struct timespec __user *);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 1feb15f23de8..46b9c887bede 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -563,7 +563,7 @@ static void reqsk_timer_handler(unsigned long data)
 	int max_retries, thresh;
 	u8 defer_accept;
 
-	if (sk_listener->sk_state != TCP_LISTEN)
+	if (sk_state_load(sk_listener) != TCP_LISTEN)
 		goto drop;
 
 	max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
@@ -749,7 +749,7 @@ int inet_csk_listen_start(struct sock *sk, int backlog)
 	 * It is OK, because this socket enters to hash table only
 	 * after validation is complete.
 	 */
-	sk->sk_state = TCP_LISTEN;
+	sk_state_store(sk, TCP_LISTEN);
 	if (!sk->sk_prot->get_port(sk, inet->inet_num)) {
 		inet->inet_sport = htons(inet->inet_num);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0cfa7c0c1e80..c1728771cf89 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -451,11 +451,14 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	unsigned int mask;
 	struct sock *sk = sock->sk;
 	const struct tcp_sock *tp = tcp_sk(sk);
+	int state;
 
 	sock_rps_record_flow(sk);
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
-	if (sk->sk_state == TCP_LISTEN)
+
+	state = sk_state_load(sk);
+	if (state == TCP_LISTEN)
 		return inet_csk_listen_poll(sk);
 
 	/* Socket is not locked. We are protected from async events
@@ -492,14 +495,14 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	 * NOTE. Check for TCP_CLOSE is added. The goal is to prevent
 	 * blocking on fresh not-connected or disconnected socket. --ANK
 	 */
-	if (sk->sk_shutdown == SHUTDOWN_MASK || sk->sk_state == TCP_CLOSE)
+	if (sk->sk_shutdown == SHUTDOWN_MASK || state == TCP_CLOSE)
 		mask |= POLLHUP;
 	if (sk->sk_shutdown & RCV_SHUTDOWN)
 		mask |= POLLIN | POLLRDNORM | POLLRDHUP;
 
 	/* Connected or passive Fast Open socket? */
-	if (sk->sk_state != TCP_SYN_SENT &&
-	    (sk->sk_state != TCP_SYN_RECV || tp->fastopen_rsk)) {
+	if (state != TCP_SYN_SENT &&
+	    (state != TCP_SYN_RECV || tp->fastopen_rsk)) {
 		int target = sock_rcvlowat(sk, 0, INT_MAX);
 
 		if (tp->urg_seq == tp->copied_seq &&
@@ -507,9 +510,6 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 		    tp->urg_data)
 			target++;
 
-		/* Potential race condition. If read of tp below will
-		 * escape above sk->sk_state, we can be illegally awaken
-		 * in SYN_* states. */
 		if (tp->rcv_nxt - tp->copied_seq >= target)
 			mask |= POLLIN | POLLRDNORM;
 
@@ -1934,7 +1934,7 @@ void tcp_set_state(struct sock *sk, int state)
 	/* Change state AFTER socket is unhashed to avoid closed
 	 * socket sitting in hash tables.
 	 */
-	sk->sk_state = state;
+	sk_state_store(sk, state);
 
 #ifdef STATE_TRACE
 	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n", sk, statename[oldstate], statename[state]);
@@ -2644,7 +2644,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	if (sk->sk_type != SOCK_STREAM)
 		return;
 
-	info->tcpi_state = sk->sk_state;
+	info->tcpi_state = sk_state_load(sk);
+
 	info->tcpi_ca_state = icsk->icsk_ca_state;
 	info->tcpi_retransmits = icsk->icsk_retransmits;
 	info->tcpi_probes = icsk->icsk_probes_out;
@@ -2672,7 +2673,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_snd_mss = tp->mss_cache;
 	info->tcpi_rcv_mss = icsk->icsk_ack.rcv_mss;
 
-	if (sk->sk_state == TCP_LISTEN) {
+	if (info->tcpi_state == TCP_LISTEN) {
 		info->tcpi_unacked = sk->sk_ack_backlog;
 		info->tcpi_sacked = sk->sk_max_ack_backlog;
 	} else {
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 479f34946177..b31604086edd 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -21,7 +21,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 {
 	struct tcp_info *info = _info;
 
-	if (sk->sk_state == TCP_LISTEN) {
+	if (sk_state_load(sk) == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
 		r->idiag_wqueue = sk->sk_max_ack_backlog;
 	} else if (sk->sk_type == SOCK_STREAM) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 950e28c0cdf2..5183172dd6b5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2158,6 +2158,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 	__u16 destp = ntohs(inet->inet_dport);
 	__u16 srcp = ntohs(inet->inet_sport);
 	int rx_queue;
+	int state;
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS ||
 	    icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
@@ -2175,17 +2176,18 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 		timer_expires = jiffies;
 	}
 
-	if (sk->sk_state == TCP_LISTEN)
+	state = sk_state_load(sk);
+	if (state == TCP_LISTEN)
 		rx_queue = sk->sk_ack_backlog;
 	else
-		/*
-		 * because we dont lock socket, we might find a transient negative value
+		/* Because we don't lock the socket,
+		 * we might find a transient negative value.
 		 */
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d",
-		i, src, srcp, dest, destp, sk->sk_state,
+		i, src, srcp, dest, destp, state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
 		timer_active,
@@ -2199,8 +2201,8 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 		jiffies_to_clock_t(icsk->icsk_ack.ato),
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
-		sk->sk_state == TCP_LISTEN ?
-		    (fastopenq ? fastopenq->max_qlen : 0) :
+		state == TCP_LISTEN ?
+		    fastopenq->max_qlen :
 		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh));
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5baa8e754e41..3349da9a2996 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1690,6 +1690,8 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	const struct tcp_sock *tp = tcp_sk(sp);
 	const struct inet_connection_sock *icsk = inet_csk(sp);
 	const struct fastopen_queue *fastopenq = &icsk->icsk_accept_queue.fastopenq;
+	int rx_queue;
+	int state;
 
 	dest  = &sp->sk_v6_daddr;
 	src   = &sp->sk_v6_rcv_saddr;
@@ -1710,6 +1712,15 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		timer_expires = jiffies;
 	}
 
+	state = sk_state_load(sp);
+	if (state == TCP_LISTEN)
+		rx_queue = sp->sk_ack_backlog;
+	else
+		/* Because we don't lock the socket,
+		 * we might find a transient negative value.
+		 */
+		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
+
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
 		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %lu %lu %u %u %d\n",
@@ -1718,9 +1729,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
-		   sp->sk_state,
-		   tp->write_seq-tp->snd_una,
-		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
+		   state,
+		   tp->write_seq - tp->snd_una,
+		   rx_queue,
 		   timer_active,
 		   jiffies_delta_to_clock_t(timer_expires - jiffies),
 		   icsk->icsk_retransmits,
@@ -1732,7 +1743,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd,
-		   sp->sk_state == TCP_LISTEN ?
+		   state == TCP_LISTEN ?
 			fastopenq->max_qlen :
 			(tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh)
 		   );
