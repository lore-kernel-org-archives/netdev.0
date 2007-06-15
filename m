From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6 3/3] [TCP]: Move sack_ok access to obviously named funcs & cleanup
Date: Fri, 15 Jun 2007 14:10:30 +0300
Message-ID: <11819058313595-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11819058302343-git-send-email-ilpo.jarvinen@helsinki.fi> <11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi> <11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50114 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbXFOLKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 07:10:32 -0400
In-Reply-To: <11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Previously code had IsReno/IsFack defined as macros that were
local to tcp_input.c though sack_ok field has users elsewhere
too for the same purpose. This changes them to static inlines as
preferred according the current coding style and unifies the
access to sack_ok across multiple files. Magic bitops of sack_ok
for FACK and DSACK are also abstracted to functions with
appropriate names.

Note:
- One sack_ok =3D 1 remains but that's self explanary, i.e., it
  enables sack
- Couple of !IsReno cases are changed to tcp_is_sack
- There were no users for IsDSack =3D> I dropped it

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h        |   28 ++++++++++++
 net/ipv4/tcp.c           |    2 +-
 net/ipv4/tcp_input.c     |  103 +++++++++++++++++++++++++-------------=
--------
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv4/tcp_output.c    |    6 +-
 net/ipv4/tcp_timer.c     |    2 +-
 6 files changed, 90 insertions(+), 53 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d12154a..dd9749e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -715,6 +715,34 @@ static inline void tcp_ca_event(struct sock *sk, c=
onst enum tcp_ca_event event)
 		icsk->icsk_ca_ops->cwnd_event(sk, event);
 }
=20
+/* These functions determine how the current flow behaves in respect o=
f SACK
+ * handling. SACK is negotiated with the peer, and therefore it can va=
ry
+ * between different flows.
+ *
+ * tcp_is_sack - SACK enabled
+ * tcp_is_reno - No SACK
+ * tcp_is_fack - FACK enabled, implies SACK enabled
+ */
+static inline int tcp_is_sack(const struct tcp_sock *tp)
+{
+	return tp->rx_opt.sack_ok;
+}
+
+static inline int tcp_is_reno(const struct tcp_sock *tp)
+{
+	return !tcp_is_sack(tp);
+}
+
+static inline int tcp_is_fack(const struct tcp_sock *tp)
+{
+	return tp->rx_opt.sack_ok & 2;
+}
+
+static inline void tcp_enable_fack(struct tcp_sock *tp)
+{
+	tp->rx_opt.sack_ok |=3D 2;
+}
+
 /* This determines how many packets are "in the network" to the best
  * of our knowledge.  In many cases it is conservative, but where
  * detailed information is available from the receiver (via SACK
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd4c295..e3de919 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2000,7 +2000,7 @@ void tcp_get_info(struct sock *sk, struct tcp_inf=
o *info)
=20
 	if (tp->rx_opt.tstamp_ok)
 		info->tcpi_options |=3D TCPI_OPT_TIMESTAMPS;
-	if (tp->rx_opt.sack_ok)
+	if (tcp_is_sack(tp))
 		info->tcpi_options |=3D TCPI_OPT_SACK;
 	if (tp->rx_opt.wscale_ok) {
 		info->tcpi_options |=3D TCPI_OPT_WSCALE;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f3942c3..3efd4f5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -108,11 +108,6 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_CA_ALERT		(FLAG_DATA_SACKED|FLAG_ECE)
 #define FLAG_FORWARD_PROGRESS	(FLAG_ACKED|FLAG_DATA_SACKED)
=20
-#define IsReno(tp) ((tp)->rx_opt.sack_ok =3D=3D 0)
-#define IsFack(tp) ((tp)->rx_opt.sack_ok & 2)
-#define IsDSack(tp) ((tp)->rx_opt.sack_ok & 4)
-#define Is3517Sack(tp) (!IsReno(tp) && !IsFack(tp))
-
 #define IsSackFrto() (sysctl_tcp_frto =3D=3D 0x2)
=20
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_P=
SH)
@@ -840,6 +835,21 @@ void tcp_enter_cwr(struct sock *sk, const int set_=
ssthresh)
 	}
 }
=20
+/*
+ * Packet counting of FACK is based on in-order assumptions, therefore=
 TCP
+ * disables it when reordering is detected
+ */
+static void tcp_disable_fack(struct tcp_sock *tp)
+{
+	tp->rx_opt.sack_ok &=3D ~2;
+}
+
+/* Take a notice that peer is sending DSACKs */
+static void tcp_dsack_seen(struct tcp_sock *tp)
+{
+	tp->rx_opt.sack_ok |=3D 4;
+}
+
 /* Initialize metrics on socket. */
=20
 static void tcp_init_metrics(struct sock *sk)
@@ -861,7 +871,7 @@ static void tcp_init_metrics(struct sock *sk)
 	}
 	if (dst_metric(dst, RTAX_REORDERING) &&
 	    tp->reordering !=3D dst_metric(dst, RTAX_REORDERING)) {
-		tp->rx_opt.sack_ok &=3D ~2;
+		tcp_disable_fack(tp);
 		tp->reordering =3D dst_metric(dst, RTAX_REORDERING);
 	}
=20
@@ -923,9 +933,9 @@ static void tcp_update_reordering(struct sock *sk, =
const int metric,
 		/* This exciting event is worth to be remembered. 8) */
 		if (ts)
 			NET_INC_STATS_BH(LINUX_MIB_TCPTSREORDER);
-		else if (IsReno(tp))
+		else if (tcp_is_reno(tp))
 			NET_INC_STATS_BH(LINUX_MIB_TCPRENOREORDER);
-		else if (IsFack(tp))
+		else if (tcp_is_fack(tp))
 			NET_INC_STATS_BH(LINUX_MIB_TCPFACKREORDER);
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPSACKREORDER);
@@ -937,8 +947,7 @@ static void tcp_update_reordering(struct sock *sk, =
const int metric,
 		       tp->sacked_out,
 		       tp->undo_marker ? tp->undo_retrans : 0);
 #endif
-		/* Disable FACK yet. */
-		tp->rx_opt.sack_ok &=3D ~2;
+		tcp_disable_fack(tp);
 	}
 }
=20
@@ -1009,7 +1018,7 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
=20
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
 		dup_sack =3D 1;
-		tp->rx_opt.sack_ok |=3D 4;
+		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
 		u32 end_seq_1 =3D ntohl(get_unaligned(&sp[1].end_seq));
@@ -1018,7 +1027,7 @@ static int tcp_check_dsack(struct tcp_sock *tp, s=
truct sk_buff *ack_skb,
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
 			dup_sack =3D 1;
-			tp->rx_opt.sack_ok |=3D 4;
+			tcp_dsack_seen(tp);
 			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
 		}
 	}
@@ -1319,7 +1328,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 	 * we have to account for reordering! Ugly,
 	 * but should help.
 	 */
-	if (IsFack(tp) && state.lost_retrans && icsk->icsk_ca_state =3D=3D TC=
P_CA_Recovery) {
+	if (tcp_is_fack(tp) && state.lost_retrans &&
+	    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
 		struct sk_buff *skb;
=20
 		tcp_for_write_queue(skb, sk) {
@@ -1331,7 +1341,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb,
 				continue;
 			if ((TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) &&
 			    after(state.lost_retrans, TCP_SKB_CB(skb)->ack_seq) &&
-			    (IsFack(tp) ||
+			    (tcp_is_fack(tp) ||
 			     !before(state.lost_retrans,
 				     TCP_SKB_CB(skb)->ack_seq + tp->reordering *
 				     tp->mss_cache))) {
@@ -1529,7 +1539,7 @@ static void tcp_enter_frto_loss(struct sock *sk, =
int allowed_segments, int flag)
=20
 	tp->lost_out =3D 0;
 	tp->retrans_out =3D 0;
-	if (IsReno(tp))
+	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
=20
 	tcp_for_write_queue(skb, sk) {
@@ -1669,8 +1679,7 @@ static int tcp_check_sack_reneging(struct sock *s=
k)
=20
 static inline int tcp_fackets_out(struct tcp_sock *tp)
 {
-	return (IsReno(tp) || Is3517Sack(tp)) ? tp->sacked_out + 1 :
-						tp->fackets_out;
+	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
 }
=20
 static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *sk=
b)
@@ -1799,7 +1808,7 @@ static int tcp_time_to_recover(struct sock *sk)
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
-	if (IsFack(tp) && tcp_head_timedout(sk))
+	if (tcp_is_fack(tp) && tcp_head_timedout(sk))
 		return 1;
=20
 	/* Trick#4: It is still not OK... But will it be useful to delay
@@ -1924,7 +1933,7 @@ static struct sk_buff *tcp_update_scoreboard_fack=
(struct sock *sk,
 		}
=20
 		timedout_continue =3D NULL;
-		if (IsFack(tp) && tcp_skb_timedout(sk, skb) &&
+		if (tcp_is_fack(tp) && tcp_skb_timedout(sk, skb) &&
 		    (tp->fackets_out < tp->packets_out)) {
 			timedout_continue =3D tcp_write_queue_next(sk, skb);
 			if (!after(entry_seq, tp->high_seq)) {
@@ -1935,7 +1944,7 @@ static struct sk_buff *tcp_update_scoreboard_fack=
(struct sock *sk,
 		}
=20
 	} else {
-		unsigned int reord_count =3D IsFack(tp) ? 0 : 1;
+		unsigned int reord_count =3D tcp_is_fack(tp) ? 0 : 1;
=20
 		skb =3D tcp_write_queue_find(sk, entry_seq);
 		/* If this ever becomes expensive, it can be delayed */
@@ -1948,12 +1957,12 @@ static struct sk_buff *tcp_update_scoreboard_fa=
ck(struct sock *sk,
 			    (TCP_SKB_CB(skb)->sacked & TCPCB_LOST))
 				goto backwards_walk_done;
=20
-			if (IsFack(tp) && tcp_skb_timedout(sk, skb))
+			if (tcp_is_fack(tp) && tcp_skb_timedout(sk, skb))
 				break;
 			else
 				timedout_continue =3D NULL;
=20
-			if (IsFack(tp) ||
+			if (tcp_is_fack(tp) ||
 			    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 				reord_count +=3D tcp_skb_pcount(skb);
 			if (reord_count > tp->reordering) {
@@ -1989,7 +1998,7 @@ static struct sk_buff *tcp_update_scoreboard_fack=
(struct sock *sk,
 	}
=20
 	/* Phase III: Nothing is still marked?, mark head then */
-	if ((IsFack(tp) || fast_rexmit) && !tp->lost_out)
+	if ((tcp_is_fack(tp) || fast_rexmit) && !tp->lost_out)
 		tcp_mark_head_lost_single(sk);
=20
 backwards_walk_done:
@@ -2003,9 +2012,9 @@ static void tcp_update_scoreboard(struct sock *sk=
, u32 sack_entry_seq,
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb =3D NULL;
=20
-	if (!IsReno(tp)) {
+	if (tcp_is_sack(tp)) {
 		if (!tp->sacked_out) {
-			if (IsFack(tp) || fast_rexmit) {
+			if (tcp_is_fack(tp) || fast_rexmit) {
 				tcp_mark_head_lost_single(sk);
 				skb =3D tcp_write_queue_head(sk);
 				skb =3D tcp_write_queue_next(sk, skb);
@@ -2015,7 +2024,7 @@ static void tcp_update_scoreboard(struct sock *sk=
, u32 sack_entry_seq,
 							 fast_rexmit);
=20
 		/* Continue with timedout work */
-		if (IsFack(tp) && (skb !=3D NULL))
+		if (tcp_is_fack(tp) && (skb !=3D NULL))
 			tcp_timedout_mark_forward(sk, skb);
=20
 	} else
@@ -2139,7 +2148,7 @@ static int tcp_try_undo_recovery(struct sock *sk)
 			NET_INC_STATS_BH(LINUX_MIB_TCPFULLUNDO);
 		tp->undo_marker =3D 0;
 	}
-	if (tp->snd_una =3D=3D tp->high_seq && IsReno(tp)) {
+	if (tp->snd_una =3D=3D tp->high_seq && tcp_is_reno(tp)) {
 		/* Hold old state until something *above* high_seq
 		 * is ACKed. For Reno it is MUST to prevent false
 		 * fast retransmits (RFC2582). SACK TCP is safe. */
@@ -2169,7 +2178,7 @@ static int tcp_try_undo_partial(struct sock *sk, =
int acked)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Partial ACK arrived. Force Hoe's retransmit. */
-	int failed =3D IsReno(tp) || (tcp_fackets_out(tp) > tp->reordering);
+	int failed =3D tcp_is_reno(tp) || (tcp_fackets_out(tp) > tp->reorderi=
ng);
=20
 	if (tcp_may_undo(tp)) {
 		/* Plain luck! Hole if filled with delayed
@@ -2214,7 +2223,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
 		inet_csk(sk)->icsk_retransmits =3D 0;
 		tp->undo_marker =3D 0;
-		if (!IsReno(tp))
+		if (tcp_is_sack(tp))
 			tcp_set_ca_state(sk, TCP_CA_Open);
 		return 1;
 	}
@@ -2321,7 +2330,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
 		return;
=20
 	/* C. Process data loss notification, provided it is valid. */
-	if (IsFack(tp) && (flag&FLAG_DATA_LOST) &&
+	if (tcp_is_fack(tp) && (flag&FLAG_DATA_LOST) &&
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
@@ -2359,14 +2368,14 @@ tcp_fastretrans_alert(struct sock *sk, u32 prio=
r_snd_una,
 			if (!tp->undo_marker ||
 			    /* For SACK case do not Open to allow to undo
 			     * catching for all duplicate ACKs. */
-			    IsReno(tp) || tp->snd_una !=3D tp->high_seq) {
+			    tcp_is_reno(tp) || tp->snd_una !=3D tp->high_seq) {
 				tp->undo_marker =3D 0;
 				tcp_set_ca_state(sk, TCP_CA_Open);
 			}
 			break;
=20
 		case TCP_CA_Recovery:
-			if (IsReno(tp))
+			if (tcp_is_reno(tp))
 				tcp_reset_reno_sack(tp);
 			if (tcp_try_undo_recovery(sk))
 				return;
@@ -2379,11 +2388,11 @@ tcp_fastretrans_alert(struct sock *sk, u32 prio=
r_snd_una,
 	switch (icsk->icsk_ca_state) {
 	case TCP_CA_Recovery:
 		if (prior_snd_una =3D=3D tp->snd_una) {
-			if (IsReno(tp) && is_dupack)
+			if (tcp_is_reno(tp) && is_dupack)
 				tcp_add_reno_sack(sk);
 		} else {
 			int acked =3D prior_packets - tp->packets_out;
-			if (IsReno(tp))
+			if (tcp_is_reno(tp))
 				tcp_remove_reno_sacks(sk, acked);
 			is_dupack =3D tcp_try_undo_partial(sk, acked);
 		}
@@ -2400,7 +2409,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
 			return;
 		/* Loss is undone; fall through to processing in Open state. */
 	default:
-		if (IsReno(tp)) {
+		if (tcp_is_reno(tp)) {
 			if (tp->snd_una !=3D prior_snd_una)
 				tcp_reset_reno_sack(tp);
 			if (is_dupack)
@@ -2428,7 +2437,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
=20
 		/* Otherwise enter Recovery state */
=20
-		if (IsReno(tp))
+		if (tcp_is_reno(tp))
 			NET_INC_STATS_BH(LINUX_MIB_TCPRENORECOVERY);
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPSACKRECOVERY);
@@ -2451,7 +2460,7 @@ tcp_fastretrans_alert(struct sock *sk, u32 prior_=
snd_una,
 		fast_rexmit =3D 1;
 	}
=20
-	if (is_dupack || (IsFack(tp) && tcp_head_timedout(sk)))
+	if (is_dupack || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, mark_lost_entry_seq, fast_rexmit);
 	tcp_cwnd_down(sk);
 	tcp_xmit_retransmit_queue(sk);
@@ -2691,7 +2700,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, _=
_s32 *seq_rtt_p)
 	BUG_TRAP((int)tp->sacked_out >=3D 0);
 	BUG_TRAP((int)tp->lost_out >=3D 0);
 	BUG_TRAP((int)tp->retrans_out >=3D 0);
-	if (!tp->packets_out && tp->rx_opt.sack_ok) {
+	if (!tp->packets_out && tcp_is_sack(tp)) {
 		const struct inet_connection_sock *icsk =3D inet_csk(sk);
 		if (tp->lost_out) {
 			printk(KERN_DEBUG "Leak l=3D%u %d\n",
@@ -2871,7 +2880,7 @@ static int tcp_process_frto(struct sock *sk, u32 =
prior_snd_una, int flag)
 		return 1;
 	}
=20
-	if (!IsSackFrto() || IsReno(tp)) {
+	if (!IsSackFrto() || tcp_is_reno(tp)) {
 		/* RFC4138 shortcoming in step 2; should also have case c):
 		 * ACK isn't duplicate nor advances window, e.g., opposite dir
 		 * data, winupdate
@@ -3356,7 +3365,7 @@ static void tcp_fin(struct sk_buff *skb, struct s=
ock *sk, struct tcphdr *th)
 	 * Probably, we should reset in this case. For now drop them.
 	 */
 	__skb_queue_purge(&tp->out_of_order_queue);
-	if (tp->rx_opt.sack_ok)
+	if (tcp_is_sack(tp))
 		tcp_sack_reset(&tp->rx_opt);
 	sk_stream_mem_reclaim(sk);
=20
@@ -3386,7 +3395,7 @@ static inline int tcp_sack_extend(struct tcp_sack=
_block *sp, u32 seq, u32 end_se
=20
 static void tcp_dsack_set(struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
-	if (tp->rx_opt.sack_ok && sysctl_tcp_dsack) {
+	if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
 		if (before(seq, tp->rcv_nxt))
 			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOLDSENT);
 		else
@@ -3416,7 +3425,7 @@ static void tcp_send_dupack(struct sock *sk, stru=
ct sk_buff *skb)
 		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOST);
 		tcp_enter_quickack_mode(sk);
=20
-		if (tp->rx_opt.sack_ok && sysctl_tcp_dsack) {
+		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
 			u32 end_seq =3D TCP_SKB_CB(skb)->end_seq;
=20
 			if (after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))
@@ -3732,7 +3741,7 @@ drop:
=20
 	if (!skb_peek(&tp->out_of_order_queue)) {
 		/* Initial out of order segment, build 1 SACK. */
-		if (tp->rx_opt.sack_ok) {
+		if (tcp_is_sack(tp)) {
 			tp->rx_opt.num_sacks =3D 1;
 			tp->rx_opt.dsack     =3D 0;
 			tp->rx_opt.eff_sacks =3D 1;
@@ -3797,7 +3806,7 @@ drop:
 		}
=20
 add_sack:
-		if (tp->rx_opt.sack_ok)
+		if (tcp_is_sack(tp))
 			tcp_sack_new_ofo_skb(sk, seq, end_seq);
 	}
 }
@@ -3986,7 +3995,7 @@ static int tcp_prune_queue(struct sock *sk)
 		 * is in a sad state like this, we care only about integrity
 		 * of the connection not performance.
 		 */
-		if (tp->rx_opt.sack_ok)
+		if (tcp_is_sack(tp))
 			tcp_sack_reset(&tp->rx_opt);
 		sk_stream_mem_reclaim(sk);
 	}
@@ -4687,8 +4696,8 @@ static int tcp_rcv_synsent_state_process(struct s=
ock *sk, struct sk_buff *skb,
 			tp->tcp_header_len =3D sizeof(struct tcphdr);
 		}
=20
-		if (tp->rx_opt.sack_ok && sysctl_tcp_fack)
-			tp->rx_opt.sack_ok |=3D 2;
+		if (tcp_is_sack(tp) && sysctl_tcp_fack)
+			tcp_enable_fack(tp);
=20
 		tcp_mtup_init(sk);
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ad4f36..2bd0625 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -446,7 +446,7 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->rx_opt.tstamp_ok =3D ireq->tstamp_ok;
 		if ((newtp->rx_opt.sack_ok =3D ireq->sack_ok) !=3D 0) {
 			if (sysctl_tcp_fack)
-				newtp->rx_opt.sack_ok |=3D 2;
+				tcp_enable_fack(newtp);
 		}
 		newtp->window_clamp =3D req->window_clamp;
 		newtp->rcv_ssthresh =3D req->rcv_wnd;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c8be1c8..25804a3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -737,7 +737,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
=20
 		if (diff > 0) {
 			/* Adjust Reno SACK estimate. */
-			if (!tp->rx_opt.sack_ok) {
+			if (tcp_is_reno(tp)) {
 				tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
 				tcp_sync_left_out(tp);
 			}
@@ -1722,7 +1722,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST)
 			tp->lost_out -=3D tcp_skb_pcount(next_skb);
 		/* Reno case is special. Sigh... */
-		if (!tp->rx_opt.sack_ok && tp->sacked_out)
+		if (tcp_is_reno(tp) && tp->sacked_out)
 			tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
=20
 		/* Not quite right: it can be > snd.fack, but
@@ -1970,7 +1970,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		return;
=20
 	/* No forward retransmissions in Reno are possible. */
-	if (!tp->rx_opt.sack_ok)
+	if (tcp_is_reno(tp))
 		return;
=20
 	/* Yeah, we have to make difficult choice between forward transmissio=
n
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 2ca97b2..a664a76 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -317,7 +317,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 	if (icsk->icsk_retransmits =3D=3D 0) {
 		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder ||
 		    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
-			if (tp->rx_opt.sack_ok) {
+			if (tcp_is_sack(tp)) {
 				if (icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
 					NET_INC_STATS_BH(LINUX_MIB_TCPSACKRECOVERYFAIL);
 				else
--=20
1.5.0.6

