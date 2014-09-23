From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: abort orphan sockets stalling on zero window probes
Date: Mon, 22 Sep 2014 20:52:13 -0700
Message-ID: <1411444333-6013-1-git-send-email-ycheng@google.com>
Cc: edumazet@google.com, andrey.dmitrov@oktetlabs.ru,
	ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:35667 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaIWDwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 23:52:47 -0400
Received: by mail-pa0-f73.google.com with SMTP id ey11so1255710pad.4
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 20:52:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have two different policies for orphan sockets
that repeatedly stall on zero window ACKs. If a socket gets
a zero window ACK when it is transmitting data, the RTO is
used to probe the window. The socket is aborted after roughly
tcp_orphan_retries() retries (as in tcp_write_timeout()).

But if the socket was idle when it received the zero window ACK,
and later wants to send more data, we use the probe timer to
probe the window. If the receiver always returns zero window ACKs,
icsk_probes keeps getting reset in tcp_ack() and the orphan socket
can stall forever until the system reaches the orphan limit (as
commented in tcp_probe_timer()). This opens up a simple attack
to create lots of hanging orphan sockets to burn the memory
and the CPU, as demonstrated in the recent netdev post "TCP
connection will hang in FIN_WAIT1 after closing if zero window is
advertised." http://www.spinics.net/lists/netdev/msg296539.html

This patch follows the design in RTO-based probe: we abort an orphan
socket stalling on zero window when the probe timer reaches both
the maximum backoff and the maximum RTO. For example, an 100ms RTT
connection will timeout after roughly 153 seconds (0.3 + 0.6 +
.... + 76.8) if the receiver keeps the window shut.

In addition, we change TCP_USER_TIMEOUT to cover (life or dead)
sockets stalled on zero-window probes. This changes the semantics
of TCP_USER_TIMEOUT slightly because it previously only applies
when the socket has pending transmission.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
---
 net/ipv4/tcp.c       |  2 +-
 net/ipv4/tcp_timer.c | 35 ++++++++++++++++++-----------------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 070aeff..965a197 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2693,7 +2693,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 #endif
 	case TCP_USER_TIMEOUT:
-		/* Cap the max timeout in ms TCP will retry/retrans
+		/* Cap the max time in ms TCP will retry or probe the window
 		 * before giving up and aborting (ETIMEDOUT) a connection.
 		 */
 		if (val < 0)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b24360f..aa6773a 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -270,40 +270,41 @@ static void tcp_probe_timer(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int max_probes;
+	u32 start_ts;
 
 	if (tp->packets_out || !tcp_send_head(sk)) {
 		icsk->icsk_probes_out = 0;
 		return;
 	}
 
-	/* *WARNING* RFC 1122 forbids this
-	 *
-	 * It doesn't AFAIK, because we kill the retransmit timer -AK
-	 *
-	 * FIXME: We ought not to do it, Solaris 2.5 actually has fixing
-	 * this behaviour in Solaris down as a bug fix. [AC]
-	 *
-	 * Let me to explain. icsk_probes_out is zeroed by incoming ACKs
-	 * even if they advertise zero window. Hence, connection is killed only
-	 * if we received no ACKs for normal connection timeout. It is not killed
-	 * only because window stays zero for some time, window may be zero
-	 * until armageddon and even later. We are in full accordance
-	 * with RFCs, only probe timer combines both retransmission timeout
-	 * and probe timeout in one bottle.				--ANK
+	/* RFC 1122 4.2.2.17 requires the sender to stay open indefinitely as
+	 * long as the receiver continues to respond probes. We support this by
+	 * default and reset icsk_probes_out with incoming ACKs. But if the
+	 * socket is orphaned or the user specifies TCP_USER_TIMEOUT, we
+	 * kill the socket when the retry count and the time exceeds the
+	 * corresponding system limit. We also implement similar policy when
+	 * we use RTO to probe window in tcp_retransmit_timer().
 	 */
-	max_probes = sysctl_tcp_retries2;
+	start_ts = tcp_skb_timestamp(tcp_send_head(sk));
+	if (!start_ts)
+		skb_mstamp_get(&tcp_send_head(sk)->skb_mstamp);
+	else if (icsk->icsk_user_timeout &&
+		 (s32)(tcp_time_stamp - start_ts) > icsk->icsk_user_timeout)
+		goto abort;
 
+	max_probes = sysctl_tcp_retries2;
 	if (sock_flag(sk, SOCK_DEAD)) {
 		const int alive = inet_csk_rto_backoff(icsk, TCP_RTO_MAX) < TCP_RTO_MAX;
 
 		max_probes = tcp_orphan_retries(sk, alive);
-
+		if (!alive && icsk->icsk_backoff >= max_probes)
+			goto abort;
 		if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
 			return;
 	}
 
 	if (icsk->icsk_probes_out > max_probes) {
-		tcp_write_err(sk);
+abort:		tcp_write_err(sk);
 	} else {
 		/* Only send another probe if we didn't close things up. */
 		tcp_send_probe0(sk);
-- 
2.1.0.rc2.206.gedb03e5
