From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/6] tcp: retransmit after recovery processing and congestion control
Date: Thu, 14 Jan 2016 15:43:29 -0800
Message-ID: <1452815014-601-2-git-send-email-ycheng@google.com>
References: <1452815014-601-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36594 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641AbcANXoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:44:15 -0500
Received: by mail-pf0-f175.google.com with SMTP id n128so107469319pfn.3
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 15:44:15 -0800 (PST)
In-Reply-To: <1452815014-601-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The retransmission and F-RTO transmission currently happen inside
recovery state processing (tcp_fastretrans_alert) but before
congestion control.  This refactoring moves the logic after both
s.t. we can determine how much to send (cwnd) before deciding what to
send.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 58 +++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 46 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0003d40..482c0b4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -126,6 +126,10 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_PSH)
 #define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))
 
+#define REXMIT_NONE	0 /* no loss recovery to do */
+#define REXMIT_LOST	1 /* retransmit packets marked lost */
+#define REXMIT_NEW	2 /* FRTO-style transmit of unsent/new packets */
+
 /* Adapt the MSS value used to make delayed ack decision to the
  * real world.
  */
@@ -2664,7 +2668,8 @@ static void tcp_enter_recovery(struct sock *sk, bool ece_ack)
 /* Process an ACK in CA_Loss state. Move to CA_Open if lost data are
  * recovered or spurious. Otherwise retransmits more on partial ACKs.
  */
-static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
+static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack,
+			     int *rexmit)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	bool recovered = !before(tp->snd_una, tp->high_seq);
@@ -2686,10 +2691,15 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 				tp->frto = 0; /* Step 3.a. loss was real */
 		} else if (flag & FLAG_SND_UNA_ADVANCED && !recovered) {
 			tp->high_seq = tp->snd_nxt;
-			__tcp_push_pending_frames(sk, tcp_current_mss(sk),
-						  TCP_NAGLE_OFF);
-			if (after(tp->snd_nxt, tp->high_seq))
-				return; /* Step 2.b */
+			/* Step 2.b. Try send new data (but deferred until cwnd
+			 * is updated in tcp_ack()). Otherwise fall back to
+			 * the conventional recovery.
+			 */
+			if (tcp_send_head(sk) &&
+			    after(tcp_wnd_end(tp), tp->snd_nxt)) {
+				*rexmit = REXMIT_NEW;
+				return;
+			}
 			tp->frto = 0;
 		}
 	}
@@ -2708,7 +2718,7 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 		else if (flag & FLAG_SND_UNA_ADVANCED)
 			tcp_reset_reno_sack(tp);
 	}
-	tcp_xmit_retransmit_queue(sk);
+	*rexmit = REXMIT_LOST;
 }
 
 /* Undo during fast recovery after partial ACK. */
@@ -2758,7 +2768,7 @@ static bool tcp_try_undo_partial(struct sock *sk, const int acked,
  */
 static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 				  const int prior_unsacked,
-				  bool is_dupack, int flag)
+				  bool is_dupack, int flag, int *rexmit)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -2833,7 +2843,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		}
 		break;
 	case TCP_CA_Loss:
-		tcp_process_loss(sk, flag, is_dupack);
+		tcp_process_loss(sk, flag, is_dupack, rexmit);
 		if (icsk->icsk_ca_state != TCP_CA_Open &&
 		    !(flag & FLAG_LOST_RETRANS))
 			return;
@@ -2873,7 +2883,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	if (do_lost)
 		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_reduction(sk, prior_unsacked, fast_rexmit, flag);
-	tcp_xmit_retransmit_queue(sk);
+	*rexmit = REXMIT_LOST;
 }
 
 /* Kathleen Nichols' algorithm for tracking the minimum value of
@@ -3508,6 +3518,27 @@ static inline void tcp_in_ack_event(struct sock *sk, u32 flags)
 		icsk->icsk_ca_ops->in_ack_event(sk, flags);
 }
 
+/* Congestion control has updated the cwnd already. So if we're in
+ * loss recovery then now we do any new sends (for FRTO) or
+ * retransmits (for CA_Loss or CA_recovery) that make sense.
+ */
+static void tcp_xmit_recovery(struct sock *sk, int rexmit)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (rexmit == REXMIT_NONE)
+		return;
+
+	if (unlikely(rexmit == 2)) {
+		__tcp_push_pending_frames(sk, tcp_current_mss(sk),
+					  TCP_NAGLE_OFF);
+		if (after(tp->snd_nxt, tp->high_seq))
+			return;
+		tp->frto = 0;
+	}
+	tcp_xmit_retransmit_queue(sk);
+}
+
 /* This routine deals with incoming acks, but not outgoing ones. */
 static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 {
@@ -3522,6 +3553,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	int prior_packets = tp->packets_out;
 	const int prior_unsacked = tp->packets_out - tp->sacked_out;
 	int acked = 0; /* Number of packets newly acked */
+	int rexmit = REXMIT_NONE; /* Flag to (re)transmit to recover losses */
 
 	sack_state.first_sackt.v64 = 0;
 
@@ -3618,7 +3650,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (tcp_ack_is_dubious(sk, flag)) {
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
-				      is_dupack, flag);
+				      is_dupack, flag, &rexmit);
 	}
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
@@ -3636,13 +3668,14 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
 		tcp_schedule_loss_probe(sk);
 	tcp_update_pacing_rate(sk);
+	tcp_xmit_recovery(sk, rexmit);
 	return 1;
 
 no_queue:
 	/* If data was DSACKed, see if we can undo a cwnd reduction. */
 	if (flag & FLAG_DSACKING_ACK)
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
-				      is_dupack, flag);
+				      is_dupack, flag, &rexmit);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
@@ -3666,7 +3699,8 @@ old_ack:
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
 						&sack_state);
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
-				      is_dupack, flag);
+				      is_dupack, flag, &rexmit);
+		tcp_xmit_recovery(sk, rexmit);
 	}
 
 	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
2.6.0.rc2.230.g3dd15c0
