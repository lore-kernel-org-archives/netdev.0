From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 1/3 net-next] tcp: refactor F-RTO
Date: Wed,  6 Mar 2013 12:52:08 -0800
Message-ID: <1362603130-16501-1-git-send-email-ycheng@google.com>
Cc: ilpo.jarvinen@cs.helsinki.fi, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f201.google.com ([209.85.161.201]:52308 "EHLO
	mail-gg0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539Ab3CFUwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 15:52:21 -0500
Received: by mail-gg0-f201.google.com with SMTP id l2so913813ggn.2
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 12:52:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series refactor the F-RTO feature (RFC4138/5682).

This is to simplify the loss recovery processing. Existing F-RTO
was developed during the experimental stage (RFC4138) and has
many experimental features.  It takes a separate code path from
the traditional timeout processing by overloading CA_Disorder
instead of using CA_Loss state. This complicates CA_Disorder state
handling because it's also used for handling dubious ACKs and undos.
While the algorithm in the RFC does not change the congestion control,
the implementation intercepts congestion control in various places
(e.g., frto_cwnd in tcp_ack()).

The new code implements newer F-RTO RFC5682 using CA_Loss processing
path.  F-RTO becomes a small extension in the timeout processing
and interfaces with congestion control and Eifel undo modules.
It lets congestion control (module) determines how many to send
independently.  F-RTO only chooses what to send in order to detect
spurious retranmission. If timeout is found spurious it invokes
existing Eifel undo algorithms like DSACK or TCP timestamp based
detection.

The first patch removes all F-RTO code except the sysctl_tcp_frto is
left for the new implementation.  Since CA_EVENT_FRTO is removed, TCP
westwood now computes ssthresh on regular timeout CA_EVENT_LOSS event.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 Documentation/networking/ip-sysctl.txt |  17 --
 include/linux/tcp.h                    |   6 +-
 include/net/tcp.h                      |   4 -
 net/ipv4/sysctl_net_ipv4.c             |   7 -
 net/ipv4/tcp_input.c                   | 375 +--------------------------------
 net/ipv4/tcp_minisocks.c               |   3 -
 net/ipv4/tcp_output.c                  |  11 +-
 net/ipv4/tcp_timer.c                   |   6 +-
 net/ipv4/tcp_westwood.c                |   2 +-
 9 files changed, 10 insertions(+), 421 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dc2dc87..df03fcb 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -243,23 +243,6 @@ tcp_frto - INTEGER
 	interacts badly with the packet counting of the SACK enabled TCP
 	flow.
 
-tcp_frto_response - INTEGER
-	When F-RTO has detected that a TCP retransmission timeout was
-	spurious (i.e, the timeout would have been avoided had TCP set a
-	longer retransmission timeout), TCP has several options what to do
-	next. Possible values are:
-		0 Rate halving based; a smooth and conservative response,
-		  results in halved cwnd and ssthresh after one RTT
-		1 Very conservative response; not recommended because even
-		  though being valid, it interacts poorly with the rest of
-		  Linux TCP, halves cwnd and ssthresh immediately
-		2 Aggressive response; undoes congestion control measures
-		  that are now known to be unnecessary (ignoring the
-		  possibility of a lost retransmission that would require
-		  TCP to be more cautious), cwnd and ssthresh are restored
-		  to the values prior timeout
-	Default: 0 (rate halving based)
-
 tcp_keepalive_time - INTEGER
 	How often TCP sends out keepalive messages when keepalive is enabled.
 	Default: 2hours.
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f28408c..7319831 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -191,14 +191,12 @@ struct tcp_sock {
 	u32	window_clamp;	/* Maximal window to advertise		*/
 	u32	rcv_ssthresh;	/* Current window clamp			*/
 
-	u32	frto_highmark;	/* snd_nxt when RTO occurred */
 	u16	advmss;		/* Advertised MSS			*/
-	u8	frto_counter;	/* Number of new acks after RTO */
+	u8	unused;
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
-		repair      : 1,
-		unused      : 1;
+		repair      : 1;
 	u8	repair_queue;
 	u8	do_early_retrans:1,/* Enable RFC5827 early-retransmit  */
 		early_retrans_delayed:1, /* Delayed ER timer installed */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cf0694d..f537e23 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -273,7 +273,6 @@ extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
-extern int sysctl_tcp_frto_response;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_dma_copybreak;
 extern int sysctl_tcp_nometrics_save;
@@ -425,8 +424,6 @@ extern struct sock * tcp_check_req(struct sock *sk,struct sk_buff *skb,
 				   bool fastopen);
 extern int tcp_child_process(struct sock *parent, struct sock *child,
 			     struct sk_buff *skb);
-extern bool tcp_use_frto(struct sock *sk);
-extern void tcp_enter_frto(struct sock *sk);
 extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
@@ -756,7 +753,6 @@ enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
 	CA_EVENT_CWND_RESTART,	/* congestion window restart */
 	CA_EVENT_COMPLETE_CWR,	/* end of congestion recovery */
-	CA_EVENT_FRTO,		/* fast recovery timeout */
 	CA_EVENT_LOSS,		/* loss timeout */
 	CA_EVENT_FAST_ACK,	/* in sequence ack */
 	CA_EVENT_SLOW_ACK,	/* other ack */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 960fd29..bfb8fda 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -592,13 +592,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_frto_response",
-		.data		= &sysctl_tcp_frto_response,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0d9bdac..9933b6b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -93,7 +93,6 @@ int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
-int sysctl_tcp_frto_response __read_mostly;
 
 int sysctl_tcp_thin_dupack __read_mostly;
 
@@ -108,17 +107,14 @@ int sysctl_tcp_early_retrans __read_mostly = 2;
 #define FLAG_DATA_SACKED	0x20 /* New SACK.				*/
 #define FLAG_ECE		0x40 /* ECE in this ACK				*/
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
-#define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent before RTO */
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
 #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info */
-#define FLAG_NONHEAD_RETRANS_ACKED	0x1000 /* Non-head rexmitted data was ACKed */
 #define FLAG_SACK_RENEGING	0x2000 /* snd_una advanced to a sacked seq */
 
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
 #define FLAG_CA_ALERT		(FLAG_DATA_SACKED|FLAG_ECE)
 #define FLAG_FORWARD_PROGRESS	(FLAG_ACKED|FLAG_DATA_SACKED)
-#define FLAG_ANY_PROGRESS	(FLAG_FORWARD_PROGRESS|FLAG_SND_UNA_ADVANCED)
 
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_PSH)
 #define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))
@@ -1159,10 +1155,6 @@ static u8 tcp_sacktag_one(struct sock *sk,
 					   tcp_highest_sack_seq(tp)))
 					state->reord = min(fack_count,
 							   state->reord);
-
-				/* SACK enhanced F-RTO (RFC4138; Appendix B) */
-				if (!after(end_seq, tp->frto_highmark))
-					state->flag |= FLAG_ONLY_ORIG_SACKED;
 			}
 
 			if (sacked & TCPCB_LOST) {
@@ -1555,7 +1547,6 @@ static int
 tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 			u32 prior_snd_una)
 {
-	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	const unsigned char *ptr = (skb_transport_header(ack_skb) +
 				    TCP_SKB_CB(ack_skb)->sacked);
@@ -1728,12 +1719,6 @@ walk:
 				       start_seq, end_seq, dup_sack);
 
 advance_sp:
-		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
-		 * due to in-order walk
-		 */
-		if (after(end_seq, tp->frto_highmark))
-			state.flag &= ~FLAG_ONLY_ORIG_SACKED;
-
 		i++;
 	}
 
@@ -1750,8 +1735,7 @@ advance_sp:
 	tcp_verify_left_out(tp);
 
 	if ((state.reord < tp->fackets_out) &&
-	    ((icsk->icsk_ca_state != TCP_CA_Loss) || tp->undo_marker) &&
-	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
+	    ((inet_csk(sk)->icsk_ca_state != TCP_CA_Loss) || tp->undo_marker))
 		tcp_update_reordering(sk, tp->fackets_out - state.reord, 0);
 
 out:
@@ -1825,197 +1809,6 @@ static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 	tp->sacked_out = 0;
 }
 
-static int tcp_is_sackfrto(const struct tcp_sock *tp)
-{
-	return (sysctl_tcp_frto == 0x2) && !tcp_is_reno(tp);
-}
-
-/* F-RTO can only be used if TCP has never retransmitted anything other than
- * head (SACK enhanced variant from Appendix B of RFC4138 is more robust here)
- */
-bool tcp_use_frto(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct sk_buff *skb;
-
-	if (!sysctl_tcp_frto)
-		return false;
-
-	/* MTU probe and F-RTO won't really play nicely along currently */
-	if (icsk->icsk_mtup.probe_size)
-		return false;
-
-	if (tcp_is_sackfrto(tp))
-		return true;
-
-	/* Avoid expensive walking of rexmit queue if possible */
-	if (tp->retrans_out > 1)
-		return false;
-
-	skb = tcp_write_queue_head(sk);
-	if (tcp_skb_is_last(sk, skb))
-		return true;
-	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
-	tcp_for_write_queue_from(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
-			return false;
-		/* Short-circuit when first non-SACKed skb has been checked */
-		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-			break;
-	}
-	return true;
-}
-
-/* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
- * recovery a bit and use heuristics in tcp_process_frto() to detect if
- * the RTO was spurious. Only clear SACKED_RETRANS of the head here to
- * keep retrans_out counting accurate (with SACK F-RTO, other than head
- * may still have that bit set); TCPCB_LOST and remaining SACKED_RETRANS
- * bits are handled if the Loss state is really to be entered (in
- * tcp_enter_frto_loss).
- *
- * Do like tcp_enter_loss() would; when RTO expires the second time it
- * does:
- *  "Reduce ssthresh if it has not yet been made inside this window."
- */
-void tcp_enter_frto(struct sock *sk)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-
-	if ((!tp->frto_counter && icsk->icsk_ca_state <= TCP_CA_Disorder) ||
-	    tp->snd_una == tp->high_seq ||
-	    ((icsk->icsk_ca_state == TCP_CA_Loss || tp->frto_counter) &&
-	     !icsk->icsk_retransmits)) {
-		tp->prior_ssthresh = tcp_current_ssthresh(sk);
-		/* Our state is too optimistic in ssthresh() call because cwnd
-		 * is not reduced until tcp_enter_frto_loss() when previous F-RTO
-		 * recovery has not yet completed. Pattern would be this: RTO,
-		 * Cumulative ACK, RTO (2xRTO for the same segment does not end
-		 * up here twice).
-		 * RFC4138 should be more specific on what to do, even though
-		 * RTO is quite unlikely to occur after the first Cumulative ACK
-		 * due to back-off and complexity of triggering events ...
-		 */
-		if (tp->frto_counter) {
-			u32 stored_cwnd;
-			stored_cwnd = tp->snd_cwnd;
-			tp->snd_cwnd = 2;
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-			tp->snd_cwnd = stored_cwnd;
-		} else {
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
-		}
-		/* ... in theory, cong.control module could do "any tricks" in
-		 * ssthresh(), which means that ca_state, lost bits and lost_out
-		 * counter would have to be faked before the call occurs. We
-		 * consider that too expensive, unlikely and hacky, so modules
-		 * using these in ssthresh() must deal these incompatibility
-		 * issues if they receives CA_EVENT_FRTO and frto_counter != 0
-		 */
-		tcp_ca_event(sk, CA_EVENT_FRTO);
-	}
-
-	tp->undo_marker = tp->snd_una;
-	tp->undo_retrans = 0;
-
-	skb = tcp_write_queue_head(sk);
-	if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
-		tp->undo_marker = 0;
-	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
-		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-		tp->retrans_out -= tcp_skb_pcount(skb);
-	}
-	tcp_verify_left_out(tp);
-
-	/* Too bad if TCP was application limited */
-	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp) + 1);
-
-	/* Earlier loss recovery underway (see RFC4138; Appendix B).
-	 * The last condition is necessary at least in tp->frto_counter case.
-	 */
-	if (tcp_is_sackfrto(tp) && (tp->frto_counter ||
-	    ((1 << icsk->icsk_ca_state) & (TCPF_CA_Recovery|TCPF_CA_Loss))) &&
-	    after(tp->high_seq, tp->snd_una)) {
-		tp->frto_highmark = tp->high_seq;
-	} else {
-		tp->frto_highmark = tp->snd_nxt;
-	}
-	tcp_set_ca_state(sk, TCP_CA_Disorder);
-	tp->high_seq = tp->snd_nxt;
-	tp->frto_counter = 1;
-}
-
-/* Enter Loss state after F-RTO was applied. Dupack arrived after RTO,
- * which indicates that we should follow the traditional RTO recovery,
- * i.e. mark everything lost and do go-back-N retransmission.
- */
-static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-
-	tp->lost_out = 0;
-	tp->retrans_out = 0;
-	if (tcp_is_reno(tp))
-		tcp_reset_reno_sack(tp);
-
-	tcp_for_write_queue(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-
-		TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
-		/*
-		 * Count the retransmission made on RTO correctly (only when
-		 * waiting for the first ACK and did not get it)...
-		 */
-		if ((tp->frto_counter == 1) && !(flag & FLAG_DATA_ACKED)) {
-			/* For some reason this R-bit might get cleared? */
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
-				tp->retrans_out += tcp_skb_pcount(skb);
-			/* ...enter this if branch just for the first segment */
-			flag |= FLAG_DATA_ACKED;
-		} else {
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
-				tp->undo_marker = 0;
-			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
-		}
-
-		/* Marking forward transmissions that were made after RTO lost
-		 * can cause unnecessary retransmissions in some scenarios,
-		 * SACK blocks will mitigate that in some but not in all cases.
-		 * We used to not mark them but it was causing break-ups with
-		 * receivers that do only in-order receival.
-		 *
-		 * TODO: we could detect presence of such receiver and select
-		 * different behavior per flow.
-		 */
-		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
-			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-			tp->lost_out += tcp_skb_pcount(skb);
-			tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
-		}
-	}
-	tcp_verify_left_out(tp);
-
-	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
-	tp->snd_cwnd_cnt = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-	tp->frto_counter = 0;
-
-	tp->reordering = min_t(unsigned int, tp->reordering,
-			       sysctl_tcp_reordering);
-	tcp_set_ca_state(sk, TCP_CA_Loss);
-	tp->high_seq = tp->snd_nxt;
-	TCP_ECN_queue_cwr(tp);
-
-	tcp_clear_all_retrans_hints(tp);
-}
-
 static void tcp_clear_retrans_partial(struct tcp_sock *tp)
 {
 	tp->retrans_out = 0;
@@ -2090,8 +1883,6 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
-	/* Abort F-RTO algorithm if one is in progress */
-	tp->frto_counter = 0;
 }
 
 /* If ACK arrived pointing to a remembered SACK, it means that our
@@ -2274,10 +2065,6 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
 
-	/* Do not perform any recovery during F-RTO algorithm */
-	if (tp->frto_counter)
-		return false;
-
 	/* Trick#1: The loss is proven. */
 	if (tp->lost_out)
 		return true;
@@ -2758,7 +2545,7 @@ static void tcp_try_to_open(struct sock *sk, int flag, int newly_acked_sacked)
 
 	tcp_verify_left_out(tp);
 
-	if (!tp->frto_counter && !tcp_any_retrans_done(sk))
+	if (!tcp_any_retrans_done(sk))
 		tp->retrans_stamp = 0;
 
 	if (flag & FLAG_ECE)
@@ -3195,8 +2982,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			flag |= FLAG_RETRANS_DATA_ACKED;
 			ca_seq_rtt = -1;
 			seq_rtt = -1;
-			if ((flag & FLAG_DATA_ACKED) || (acked_pcount > 1))
-				flag |= FLAG_NONHEAD_RETRANS_ACKED;
 		} else {
 			ca_seq_rtt = now - scb->when;
 			last_ackt = skb->tstamp;
@@ -3405,150 +3190,6 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 	return flag;
 }
 
-/* A very conservative spurious RTO response algorithm: reduce cwnd and
- * continue in congestion avoidance.
- */
-static void tcp_conservative_spur_to_response(struct tcp_sock *tp)
-{
-	tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
-	tp->snd_cwnd_cnt = 0;
-	TCP_ECN_queue_cwr(tp);
-	tcp_moderate_cwnd(tp);
-}
-
-/* A conservative spurious RTO response algorithm: reduce cwnd using
- * PRR and continue in congestion avoidance.
- */
-static void tcp_cwr_spur_to_response(struct sock *sk)
-{
-	tcp_enter_cwr(sk, 0);
-}
-
-static void tcp_undo_spur_to_response(struct sock *sk, int flag)
-{
-	if (flag & FLAG_ECE)
-		tcp_cwr_spur_to_response(sk);
-	else
-		tcp_undo_cwr(sk, true);
-}
-
-/* F-RTO spurious RTO detection algorithm (RFC4138)
- *
- * F-RTO affects during two new ACKs following RTO (well, almost, see inline
- * comments). State (ACK number) is kept in frto_counter. When ACK advances
- * window (but not to or beyond highest sequence sent before RTO):
- *   On First ACK,  send two new segments out.
- *   On Second ACK, RTO was likely spurious. Do spurious response (response
- *                  algorithm is not part of the F-RTO detection algorithm
- *                  given in RFC4138 but can be selected separately).
- * Otherwise (basically on duplicate ACK), RTO was (likely) caused by a loss
- * and TCP falls back to conventional RTO recovery. F-RTO allows overriding
- * of Nagle, this is done using frto_counter states 2 and 3, when a new data
- * segment of any size sent during F-RTO, state 2 is upgraded to 3.
- *
- * Rationale: if the RTO was spurious, new ACKs should arrive from the
- * original window even after we transmit two new data segments.
- *
- * SACK version:
- *   on first step, wait until first cumulative ACK arrives, then move to
- *   the second step. In second step, the next ACK decides.
- *
- * F-RTO is implemented (mainly) in four functions:
- *   - tcp_use_frto() is used to determine if TCP is can use F-RTO
- *   - tcp_enter_frto() prepares TCP state on RTO if F-RTO is used, it is
- *     called when tcp_use_frto() showed green light
- *   - tcp_process_frto() handles incoming ACKs during F-RTO algorithm
- *   - tcp_enter_frto_loss() is called if there is not enough evidence
- *     to prove that the RTO is indeed spurious. It transfers the control
- *     from F-RTO to the conventional RTO recovery
- */
-static bool tcp_process_frto(struct sock *sk, int flag)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	tcp_verify_left_out(tp);
-
-	/* Duplicate the behavior from Loss state (fastretrans_alert) */
-	if (flag & FLAG_DATA_ACKED)
-		inet_csk(sk)->icsk_retransmits = 0;
-
-	if ((flag & FLAG_NONHEAD_RETRANS_ACKED) ||
-	    ((tp->frto_counter >= 2) && (flag & FLAG_RETRANS_DATA_ACKED)))
-		tp->undo_marker = 0;
-
-	if (!before(tp->snd_una, tp->frto_highmark)) {
-		tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3), flag);
-		return true;
-	}
-
-	if (!tcp_is_sackfrto(tp)) {
-		/* RFC4138 shortcoming in step 2; should also have case c):
-		 * ACK isn't duplicate nor advances window, e.g., opposite dir
-		 * data, winupdate
-		 */
-		if (!(flag & FLAG_ANY_PROGRESS) && (flag & FLAG_NOT_DUP))
-			return true;
-
-		if (!(flag & FLAG_DATA_ACKED)) {
-			tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 0 : 3),
-					    flag);
-			return true;
-		}
-	} else {
-		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
-			if (!tcp_packets_in_flight(tp)) {
-				tcp_enter_frto_loss(sk, 2, flag);
-				return true;
-			}
-
-			/* Prevent sending of new data. */
-			tp->snd_cwnd = min(tp->snd_cwnd,
-					   tcp_packets_in_flight(tp));
-			return true;
-		}
-
-		if ((tp->frto_counter >= 2) &&
-		    (!(flag & FLAG_FORWARD_PROGRESS) ||
-		     ((flag & FLAG_DATA_SACKED) &&
-		      !(flag & FLAG_ONLY_ORIG_SACKED)))) {
-			/* RFC4138 shortcoming (see comment above) */
-			if (!(flag & FLAG_FORWARD_PROGRESS) &&
-			    (flag & FLAG_NOT_DUP))
-				return true;
-
-			tcp_enter_frto_loss(sk, 3, flag);
-			return true;
-		}
-	}
-
-	if (tp->frto_counter == 1) {
-		/* tcp_may_send_now needs to see updated state */
-		tp->snd_cwnd = tcp_packets_in_flight(tp) + 2;
-		tp->frto_counter = 2;
-
-		if (!tcp_may_send_now(sk))
-			tcp_enter_frto_loss(sk, 2, flag);
-
-		return true;
-	} else {
-		switch (sysctl_tcp_frto_response) {
-		case 2:
-			tcp_undo_spur_to_response(sk, flag);
-			break;
-		case 1:
-			tcp_conservative_spur_to_response(tp);
-			break;
-		default:
-			tcp_cwr_spur_to_response(sk);
-			break;
-		}
-		tp->frto_counter = 0;
-		tp->undo_marker = 0;
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSPURIOUSRTOS);
-	}
-	return false;
-}
-
 /* RFC 5961 7 [ACK Throttling] */
 static void tcp_send_challenge_ack(struct sock *sk)
 {
@@ -3581,7 +3222,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	int prior_packets;
 	int prior_sacked = tp->sacked_out;
 	int pkts_acked = 0;
-	bool frto_cwnd = false;
 
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
@@ -3654,22 +3294,15 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	pkts_acked = prior_packets - tp->packets_out;
 
-	if (tp->frto_counter)
-		frto_cwnd = tcp_process_frto(sk, flag);
-	/* Guarantee sacktag reordering detection against wrap-arounds */
-	if (before(tp->frto_highmark, tp->snd_una))
-		tp->frto_highmark = 0;
-
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
-		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
-		    tcp_may_raise_cwnd(sk, flag))
+		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 		tcp_fastretrans_alert(sk, pkts_acked, prior_sacked,
 				      is_dupack, flag);
 	} else {
-		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
+		if (flag & FLAG_DATA_ACKED)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
 	}
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b83a49c..344f185 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -449,9 +449,6 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->snd_cwnd = TCP_INIT_CWND;
 		newtp->snd_cwnd_cnt = 0;
 
-		newtp->frto_counter = 0;
-		newtp->frto_highmark = 0;
-
 		if (newicsk->icsk_ca_ops != &tcp_init_congestion_ops &&
 		    !try_module_get(newicsk->icsk_ca_ops->owner))
 			newicsk->icsk_ca_ops = &tcp_init_congestion_ops;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e2b4461..5756ada 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -80,10 +80,6 @@ static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 
-	/* Don't override Nagle indefinitely with F-RTO */
-	if (tp->frto_counter == 2)
-		tp->frto_counter = 3;
-
 	tp->packets_out += tcp_skb_pcount(skb);
 	if (!prior_packets || tp->early_retrans_delayed)
 		tcp_rearm_rto(sk);
@@ -1633,11 +1629,8 @@ static inline bool tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buf
 	if (nonagle & TCP_NAGLE_PUSH)
 		return true;
 
-	/* Don't use the nagle rule for urgent data (or for the final FIN).
-	 * Nagle can be ignored during F-RTO too (see RFC4138).
-	 */
-	if (tcp_urg_mode(tp) || (tp->frto_counter == 2) ||
-	    (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
+	/* Don't use the nagle rule for urgent data (or for the final FIN). */
+	if (tcp_urg_mode(tp) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		return true;
 
 	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b78aac3..a846ca1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -418,11 +418,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 	}
 
-	if (tcp_use_frto(sk)) {
-		tcp_enter_frto(sk);
-	} else {
-		tcp_enter_loss(sk, 0);
-	}
+	tcp_enter_loss(sk, 0);
 
 	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
 		/* Retransmission failed because of local congestion,
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 1b91bf4..76a1e23 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -236,7 +236,7 @@ static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
 		tp->snd_cwnd = tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		break;
 
-	case CA_EVENT_FRTO:
+	case CA_EVENT_LOSS:
 		tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		/* Update RTT_min when next ack arrives */
 		w->reset_rtt_min = 1;
-- 
1.8.1.3
