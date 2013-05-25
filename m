From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2 V2] tcp: Remove another indentation level in
 tcp_rcv_state_process
Date: Fri, 24 May 2013 21:36:13 -0700
Message-ID: <1369456573.2080.15.camel@joe-AO722>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	 <1369324525.3301.384.camel@edumazet-glaptop>
	 <1369443834.3301.464.camel@edumazet-glaptop>
	 <1369454556.2080.4.camel@joe-AO722>
	 <1369455898.3301.466.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35479 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750747Ab3EYEgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 May 2013 00:36:15 -0400
In-Reply-To: <1369455898.3301.466.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

case TCP_SYN_RECV: can have another indentation level removed
by converting

	if (acceptable) {
		...;
	} else {
		return 1;
	}

to
	if (!acceptable)
		return 1;
	...;

Reflow code and comments to fit 80 columns.

Another pure cleanup patch.

Signed-off-by: Joe Perches <joe@perches.com>
Improved-by: Eric Dumazet <eric.dumazet@gmail.com>
---

On Fri, 2013-05-24 at 21:24 -0700, Eric Dumazet wrote:
> +		tp->snd_wnd = ntohs(th->window) <<
> > +			tp->rx_opt.snd_wscale;
> single line ?

Right.  Resubmitting, Thanks Eric.

 net/ipv4/tcp_input.c | 110 ++++++++++++++++++++++++---------------------------
 1 file changed, 51 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4061425..413b480 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5612,70 +5612,62 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 	switch (sk->sk_state) {
 	case TCP_SYN_RECV:
-		if (acceptable) {
-			/* Once we leave TCP_SYN_RECV, we no longer
-			 * need req so release it.
-			 */
-			if (req) {
-				tcp_synack_rtt_meas(sk, req);
-				tp->total_retrans = req->num_retrans;
+		if (!acceptable)
+			return 1;
 
-				reqsk_fastopen_remove(sk, req, false);
-			} else {
-				/* Make sure socket is routed, for
-				 * correct metrics.
-				 */
-				icsk->icsk_af_ops->rebuild_header(sk);
-				tcp_init_congestion_control(sk);
+		/* Once we leave TCP_SYN_RECV, we no longer need req
+		 * so release it.
+		 */
+		if (req) {
+			tcp_synack_rtt_meas(sk, req);
+			tp->total_retrans = req->num_retrans;
 
-				tcp_mtup_init(sk);
-				tcp_init_buffer_space(sk);
-				tp->copied_seq = tp->rcv_nxt;
-			}
-			smp_mb();
-			tcp_set_state(sk, TCP_ESTABLISHED);
-			sk->sk_state_change(sk);
-
-			/* Note, that this wakeup is only for marginal
-			 * crossed SYN case. Passively open sockets
-			 * are not waked up, because sk->sk_sleep ==
-			 * NULL and sk->sk_socket == NULL.
-			 */
-			if (sk->sk_socket)
-				sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
-
-			tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
-			tp->snd_wnd = ntohs(th->window) <<
-					tp->rx_opt.snd_wscale;
-			tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
-
-			if (tp->rx_opt.tstamp_ok)
-				tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
-
-			if (req) {
-				/* Re-arm the timer because data may
-				 * have been sent out. This is similar
-				 * to the regular data transmission case
-				 * when new data has just been ack'ed.
-				 *
-				 * (TFO) - we could try to be more aggressive
-				 * and retransmitting any data sooner based
-				 * on when they are sent out.
-				 */
-				tcp_rearm_rto(sk);
-			} else
-				tcp_init_metrics(sk);
+			reqsk_fastopen_remove(sk, req, false);
+		} else {
+			/* Make sure socket is routed, for correct metrics. */
+			icsk->icsk_af_ops->rebuild_header(sk);
+			tcp_init_congestion_control(sk);
+
+			tcp_mtup_init(sk);
+			tcp_init_buffer_space(sk);
+			tp->copied_seq = tp->rcv_nxt;
+		}
+		smp_mb();
+		tcp_set_state(sk, TCP_ESTABLISHED);
+		sk->sk_state_change(sk);
 
-			/* Prevent spurious tcp_cwnd_restart() on
-			 * first data packet.
+		/* Note, that this wakeup is only for marginal crossed SYN case.
+		 * Passively open sockets are not waked up, because
+		 * sk->sk_sleep == NULL and sk->sk_socket == NULL.
+		 */
+		if (sk->sk_socket)
+			sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
+
+		tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
+		tp->snd_wnd = ntohs(th->window) << tp->rx_opt.snd_wscale;
+		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
+
+		if (tp->rx_opt.tstamp_ok)
+			tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
+
+		if (req) {
+			/* Re-arm the timer because data may have been sent out.
+			 * This is similar to the regular data transmission case
+			 * when new data has just been ack'ed.
+			 *
+			 * (TFO) - we could try to be more aggressive and
+			 * retransmitting any data sooner based on when they
+			 * are sent out.
 			 */
-			tp->lsndtime = tcp_time_stamp;
+			tcp_rearm_rto(sk);
+		} else
+			tcp_init_metrics(sk);
 
-			tcp_initialize_rcv_mss(sk);
-			tcp_fast_path_on(tp);
-		} else {
-			return 1;
-		}
+		/* Prevent spurious tcp_cwnd_restart() on first data packet */
+		tp->lsndtime = tcp_time_stamp;
+
+		tcp_initialize_rcv_mss(sk);
+		tcp_fast_path_on(tp);
 		break;
 
 	case TCP_FIN_WAIT1:
-- 
1.8.1.2.459.gbcd45b4.dirty
