From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/3] tcp: Initial repair mode
Date: Wed, 28 Mar 2012 19:37:16 +0400
Message-ID: <4F73302C.9030209@parallels.com>
References: <4F732FE1.9040906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34424 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754734Ab2C1PhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 11:37:23 -0400
In-Reply-To: <4F732FE1.9040906@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes (according the the previous description):

* TCP_REPAIR sockoption

This one just puts the socket in/out of the repair mode.
Allowed for CAP_NET_ADMIN and for closed/establised sockets only.
When repair mode is turned off and the socket happens to be in
the established state the window probe is sent to the peer to
'unlock' the connection.

* TCP_REPAIR_QUEUE sockoption

This one sets the queue which we're about to repair. The
'no-queue' is set by default.

* TCP_QUEUE_SEQ socoption

Sets the write_seq/rcv_nxt of a selected repaired queue.
Allowed for TCP_CLOSE-d sockets only. When the socket changes
its state the other seq-s are changed by the kernel according
to the protocol rules (most of the existing code is actually
reused).

* Ability to forcibly bind a socket to a port

The sk->sk_reuse is set to 2 denoting, that the socket is question
should be bound as if all the others in the system are configured
with the SO_REUSEADDR option.

* Immediate connect modification

The connect syscall initializes the connection, then directly jumps
to the code which finalizes it.

* Silent close modification

The close just aborts the connection (similar to SO_LINGER with 0
time) but without sending any FIN/RST-s to peer.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/tcp.h             |   14 +++++++-
 include/net/tcp.h               |    2 +
 net/ipv4/inet_connection_sock.c |    3 ++
 net/ipv4/tcp.c                  |   68 ++++++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_ipv4.c             |   19 +++++++++--
 net/ipv4/tcp_output.c           |   16 +++++++--
 6 files changed, 114 insertions(+), 8 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b6c62d2..4e90e6a 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,16 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_REPAIR		19	/* TCP sock is under repair right now */
+#define TCP_REPAIR_QUEUE	20
+#define TCP_QUEUE_SEQ		21
+
+enum {
+	TCP_NO_QUEUE,
+	TCP_RECV_QUEUE,
+	TCP_SEND_QUEUE,
+	TCP_QUEUES_NR,
+};
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
@@ -353,7 +363,9 @@ struct tcp_sock {
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
-		unused      : 2;
+		repair      : 1,
+		unused      : 1;
+	u8	repair_queue;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c7a00eb..f577052 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -612,6 +612,8 @@ static inline u32 tcp_receive_window(const struct tcp_sock *tp)
  */
 extern u32 __tcp_select_window(struct sock *sk);
 
+void tcp_send_window_probe(struct sock *sk);
+
 /* TCP timestamps are only 32-bits, this causes a slight
  * complication on 64-bit systems since we store a snapshot
  * of jiffies in the buffer control blocks below.  We decided
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19d66ce..92788af 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -172,6 +172,9 @@ have_snum:
 	goto tb_not_found;
 tb_found:
 	if (!hlist_empty(&tb->owners)) {
+		if (sk->sk_reuse == 2)
+			goto success;
+
 		if (tb->fastreuse > 0 &&
 		    sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
 		    smallest_size == -1) {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9e7f9ba..65ae921 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1935,7 +1935,9 @@ void tcp_close(struct sock *sk, long timeout)
 	 * advertise a zero window, then kill -9 the FTP client, wheee...
 	 * Note: timeout is always zero in such a case.
 	 */
-	if (data_was_unread) {
+	if (tcp_sk(sk)->repair) {
+		sk->sk_prot->disconnect(sk, 0);
+	} else if (data_was_unread) {
 		/* Unread data was tossed, zap the connection. */
 		NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
 		tcp_set_state(sk, TCP_CLOSE);
@@ -2074,6 +2076,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	/* ABORT function of RFC793 */
 	if (old_state == TCP_LISTEN) {
 		inet_csk_listen_stop(sk);
+	} else if (unlikely(tp->repair)) {
+		sk->sk_err = ECONNABORTED;
 	} else if (tcp_need_reset(old_state) ||
 		   (tp->snd_nxt != tp->write_seq &&
 		    (1 << old_state) & (TCPF_CLOSING | TCPF_LAST_ACK))) {
@@ -2125,6 +2129,12 @@ int tcp_disconnect(struct sock *sk, int flags)
 }
 EXPORT_SYMBOL(tcp_disconnect);
 
+static inline int tcp_can_repair_sock(struct sock *sk)
+{
+	return capable(CAP_NET_ADMIN) &&
+		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
+}
+
 /*
  *	Socket option code for TCP.
  */
@@ -2297,6 +2307,42 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			tp->thin_dupack = val;
 		break;
 
+	case TCP_REPAIR:
+		if (!tcp_can_repair_sock(sk))
+			err = -EPERM;
+		else if (val == 1) {
+			tp->repair = 1;
+			sk->sk_reuse = 2;
+			tp->repair_queue = TCP_NO_QUEUE;
+		} else if (val == 0) {
+			tp->repair = 0;
+			sk->sk_reuse = 0;
+			tcp_send_window_probe(sk);
+		} else
+			err = -EINVAL;
+
+		break;
+
+	case TCP_REPAIR_QUEUE:
+		if (!tp->repair)
+			err = -EPERM;
+		else if (val <= TCP_QUEUES_NR)
+			tp->repair_queue = val;
+		else
+			err = -EINVAL;
+		break;
+
+	case TCP_QUEUE_SEQ:
+		if (sk->sk_state != TCP_CLOSE)
+			err = -EPERM;
+		else if (tp->repair_queue == TCP_SEND_QUEUE)
+			tp->write_seq = val;
+		else if (tp->repair_queue == TCP_RECV_QUEUE)
+			tp->rcv_nxt = val;
+		else
+			err = -EINVAL;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
@@ -2632,6 +2678,26 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = tp->thin_dupack;
 		break;
 
+	case TCP_REPAIR:
+		val = tp->repair;
+		break;
+
+	case TCP_REPAIR_QUEUE:
+		if (tp->repair)
+			val = tp->repair_queue;
+		else
+			return -EINVAL;
+		break;
+
+	case TCP_QUEUE_SEQ:
+		if (tp->repair_queue == TCP_SEND_QUEUE)
+			val = tp->write_seq;
+		else if (tp->repair_queue == TCP_RECV_QUEUE)
+			val = tp->rcv_nxt;
+		else
+			return -EINVAL;
+		break;
+
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a25cf7..69190a9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -138,6 +138,14 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_unique);
 
+static int tcp_repair_connect(struct sock *sk)
+{
+	tcp_connect_init(sk);
+	tcp_finish_connect(sk, NULL);
+
+	return 0;
+}
+
 /* This will initiate an outgoing connection. */
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 {
@@ -196,7 +204,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		/* Reset inherited state */
 		tp->rx_opt.ts_recent	   = 0;
 		tp->rx_opt.ts_recent_stamp = 0;
-		tp->write_seq		   = 0;
+		if (!tp->repair)
+			tp->write_seq	   = 0;
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
@@ -247,7 +256,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq)
+	if (!tp->write_seq && !tp->repair)
 		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
 							   inet->inet_sport,
@@ -255,7 +264,11 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	inet->inet_id = tp->write_seq ^ jiffies;
 
-	err = tcp_connect(sk);
+	if (likely(!tp->repair))
+		err = tcp_connect(sk);
+	else
+		err = tcp_repair_connect(sk);
+
 	rt = NULL;
 	if (err)
 		goto failure;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1db25af..4e2ce39 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2617,9 +2617,11 @@ void tcp_connect_init(struct sock *sk)
 	tp->snd_sml = tp->write_seq;
 	tp->snd_up = tp->write_seq;
 	tp->snd_nxt = tp->write_seq;
-	tp->rcv_nxt = 0;
-	tp->rcv_wup = 0;
-	tp->copied_seq = 0;
+
+	if (!tp->repair)
+		tp->rcv_nxt = 0;
+	tp->rcv_wup = tp->rcv_nxt;
+	tp->copied_seq = tp->rcv_nxt;
 
 	inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
 	inet_csk(sk)->icsk_retransmits = 0;
@@ -2790,6 +2792,14 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
+void tcp_send_window_probe(struct sock *sk)
+{
+	if (sk->sk_state == TCP_ESTABLISHED) {
+		tcp_sk(sk)->snd_wl1 = tcp_sk(sk)->rcv_nxt - 1;
+		tcp_xmit_probe_skb(sk, 0);
+	}
+}
+
 /* Initiate keepalive or window probe from timer. */
 int tcp_write_wakeup(struct sock *sk)
 {
-- 
1.5.5.6
