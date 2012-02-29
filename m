From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/2] tcp: Initial repair mode
Date: Wed, 29 Feb 2012 19:14:22 +0400
Message-ID: <4F4E40CE.9080205@parallels.com>
References: <4F4E4084.9080804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32610 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031133Ab2B2POd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 10:14:33 -0500
In-Reply-To: <4F4E4084.9080804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This includes (according the the previous description):

* TCP_REPAIR sockoption
* Sequences sockoptions
* Ability to forcibly bind a socket to a port
* Immediate connect modification
* Silent close modification

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/tcp.h             |    6 ++++-
 net/ipv4/inet_connection_sock.c |    3 ++
 net/ipv4/tcp.c                  |   43 ++++++++++++++++++++++++++++++++++++++-
 net/ipv4/tcp_ipv4.c             |   19 ++++++++++++++--
 net/ipv4/tcp_output.c           |    1 -
 5 files changed, 66 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 115389e..0b2e01c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -106,6 +106,9 @@ enum {
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
 #define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
+#define TCP_REPAIR		19	/* TCP sock is under repair right now */
+#define TCP_WRITE_SEQ		20
+#define TCP_RCV_NXT		21
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
@@ -353,7 +356,8 @@ struct tcp_sock {
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
-		unused      : 2;
+		repair      : 1,
+		unused      : 1;
 
 /* RTT measurement */
 	u32	srtt;		/* smoothed round trip time << 3	*/
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
index 22ef5f9..768306d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1932,7 +1932,9 @@ void tcp_close(struct sock *sk, long timeout)
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
@@ -2071,6 +2073,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	/* ABORT function of RFC793 */
 	if (old_state == TCP_LISTEN) {
 		inet_csk_listen_stop(sk);
+	} else if (unlikely(tp->repair)) {
+		sk->sk_err = ECONNABORTED;
 	} else if (tcp_need_reset(old_state) ||
 		   (tp->snd_nxt != tp->write_seq &&
 		    (1 << old_state) & (TCPF_CLOSING | TCPF_LAST_ACK))) {
@@ -2294,6 +2298,33 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			tp->thin_dupack = val;
 		break;
 
+	case TCP_REPAIR:
+		if (!capable(CAP_SYS_ADMIN))
+			err = -EPERM;
+		else if (val < 0 || val > 1)
+			err = -EINVAL;
+		else {
+			tp->repair = val;
+			sk->sk_reuse = (val << 1);
+			if (val == 0)
+				tcp_send_window_probe(sk);
+		}
+		break;
+
+	case TCP_WRITE_SEQ:
+		if (!tp->repair)
+			err = -EPERM;
+		else
+			tp->write_seq = val;
+		break;
+
+	case TCP_RCV_NXT:
+		if (!tp->repair)
+			err = -EPERM;
+		else
+			tp->copied_seq = tp->rcv_nxt = val;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
@@ -2629,6 +2658,18 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = tp->thin_dupack;
 		break;
 
+	case TCP_REPAIR:
+		val = tp->repair;
+		break;
+
+	case TCP_WRITE_SEQ:
+		val = tp->write_seq;
+		break;
+
+	case TCP_RCV_NXT:
+		val = tp->rcv_nxt;
+		break;
+
 	case TCP_USER_TIMEOUT:
 		val = jiffies_to_msecs(icsk->icsk_user_timeout);
 		break;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 94abee8..6118486 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -137,6 +137,14 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
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
@@ -195,7 +203,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		/* Reset inherited state */
 		tp->rx_opt.ts_recent	   = 0;
 		tp->rx_opt.ts_recent_stamp = 0;
-		tp->write_seq		   = 0;
+		if (!tp->repair)
+			tp->write_seq	   = 0;
 	}
 
 	if (tcp_death_row.sysctl_tw_recycle &&
@@ -246,7 +255,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq)
+	if (!tp->write_seq && !tp->repair)
 		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
 							   inet->inet_sport,
@@ -254,7 +263,11 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
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
-- 
1.5.5.6
