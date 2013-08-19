From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [RFC 2/2] Account acked_out in sack, if the sack is invalid
Date: Mon, 19 Aug 2013 21:29:28 +0200
Message-ID: <1376940568-16512-3-git-send-email-christoph.paasch@uclouvain.be>
References: <1376935800.4226.71.camel@edumazet-glaptop>
 <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59664 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3HST3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 15:29:47 -0400
In-Reply-To: <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of a sequence-number rewriting firewall (e.g., a Cisco Firewall:
https://supportforums.cisco.com/docs/DOC-12668#TCP_Sequence_Number_Randomization_and_SACK)
the SACK-blocks are not rewritten.
As we receive these ACK-packets, the sackblock is marked as invalid in
tcp_is_sackblock_valid(), and sacked_out will not be incremented.
Thus, fast-retransmit will not trigger and the stack will timeout after an
RTO. This completly kills the performance across this kind of firewalls.

This patch allows acked_out to increase, in case a sackblog is marked as
invalid. Further, it considers acked_out in the accounting when SACK has
been enabled on the connection.

Tested-by: Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_input.c  | 59 ++++++++++++++++++++++++++++++++++++++-------------
 net/ipv4/tcp_output.c |  4 ++--
 2 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index af764d0..ea99017 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -75,6 +75,8 @@
 #include <asm/unaligned.h>
 #include <net/netdma.h>
 
+static void tcp_add_reno_sack(struct sock *sk);
+
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_sack __read_mostly = 1;
@@ -1542,7 +1544,7 @@ static int tcp_sack_cache_ok(const struct tcp_sock *tp, const struct tcp_sack_bl
 
 static int
 tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
-			u32 prior_snd_una, s32 *sack_rtt)
+			u32 prior_snd_una, s32 *sack_rtt, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const unsigned char *ptr = (skb_transport_header(ack_skb) +
@@ -1554,7 +1556,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	struct sk_buff *skb;
 	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
 	int used_sacks;
-	bool found_dup_sack = false;
+	bool found_dup_sack = false, first = true;
 	int i, j;
 	int first_sack_index;
 
@@ -1562,7 +1564,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	state.reord = tp->packets_out;
 	state.rtt = -1;
 
-	if (!tp->sacked_out) {
+	if (!tp->sacked_out && !tp->acked_out) {
 		if (WARN_ON(tp->fackets_out))
 			tp->fackets_out = 0;
 		tcp_highest_sack_reset(sk);
@@ -1612,6 +1614,29 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 			NET_INC_STATS_BH(sock_net(sk), mib_idx);
 			if (i == 0)
 				first_sack_index = -1;
+
+			/* 1. Only account the dup-ack once.
+			 *
+			 * 2. If we are coming from tcp_ack, with an old_ack, we
+			 * should not increase acked_out, as the ack is old :)
+			 *
+			 * 3. Only increase acked_out, if this is really a
+			 * duplicate ack. Check is similar to the one in
+			 * tcp_ack, when setting is_dupack.
+			 *
+			 * 4. We have to reproduce the first check of
+			 * tcp_is_sackblock_valid, because we don't want to
+			 * account dup-acks if the sack-blog is corrupted.
+			 */
+			if (first &&
+			    !before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una) &&
+			    !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP)) &&
+			    before(sp[used_sacks].start_seq, sp[used_sacks].end_seq)) {
+				first = false;
+				/* Disable FACK, as we can't trust SACKs anymore */
+				tcp_disable_fack(tp);
+				tcp_add_reno_sack(sk);
+			}
 			continue;
 		}
 
@@ -1740,6 +1765,7 @@ out:
 
 #if FASTRETRANS_DEBUG > 0
 	WARN_ON((int)tp->sacked_out < 0);
+	WARN_ON((int)tp->acked_out < 0);
 	WARN_ON((int)tp->lost_out < 0);
 	WARN_ON((int)tp->retrans_out < 0);
 	WARN_ON((int)tcp_packets_in_flight(tp) < 0);
@@ -1852,7 +1878,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 
 	tcp_clear_retrans_partial(tp);
 
-	if (tcp_is_reno(tp))
+	if (tcp_is_reno(tp) || tp->acked_out)
 		tcp_reset_reno_sack(tp);
 
 	tp->undo_marker = tp->snd_una;
@@ -2189,7 +2215,7 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 			lost = 1;
 		tcp_mark_head_lost(sk, lost, 0);
 	} else {
-		int sacked_upto = tp->sacked_out - tp->reordering;
+		int sacked_upto = tcp_acked_out(tp) - tp->reordering;
 		if (sacked_upto >= 0)
 			tcp_mark_head_lost(sk, sacked_upto, 0);
 		else if (fast_rexmit)
@@ -2551,7 +2577,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	if (prior_lost == tp->lost_out)
 		return;
 
-	if (tcp_is_reno(tp))
+	if (tcp_is_reno(tp) || tp->acked_out)
 		tcp_limit_reno_sacked(tp);
 
 	tcp_verify_left_out(tp);
@@ -2634,11 +2660,11 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack)
 	}
 	if (flag & FLAG_DATA_ACKED)
 		icsk->icsk_retransmits = 0;
-	if (tcp_is_reno(tp)) {
+	if (tcp_is_reno(tp) || tp->acked_out) {
 		/* A Reno DUPACK means new data in F-RTO step 2.b above are
 		 * delivered. Lower inflight to clock out (re)tranmissions.
 		 */
-		if (after(tp->snd_nxt, tp->high_seq) && is_dupack)
+		if (tcp_is_reno(tp) && after(tp->snd_nxt, tp->high_seq) && is_dupack)
 			tcp_add_reno_sack(sk);
 		else if (flag & FLAG_SND_UNA_ADVANCED)
 			tcp_reset_reno_sack(tp);
@@ -2739,7 +2765,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 			break;
 
 		case TCP_CA_Recovery:
-			if (tcp_is_reno(tp))
+			if (tcp_is_reno(tp) || tp->acked_out)
 				tcp_reset_reno_sack(tp);
 			if (tcp_try_undo_recovery(sk))
 				return;
@@ -2772,10 +2798,10 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 			return;
 		/* Fall through to processing in Open state. */
 	default:
-		if (tcp_is_reno(tp)) {
+		if (tcp_is_reno(tp) || tp->acked_out) {
 			if (flag & FLAG_SND_UNA_ADVANCED)
 				tcp_reset_reno_sack(tp);
-			if (is_dupack)
+			if (is_dupack && tcp_is_reno(tp))
 				tcp_add_reno_sack(sk);
 		}
 
@@ -2952,7 +2978,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	int flag = 0;
 	u32 pkts_acked = 0;
 	u32 reord = tp->packets_out;
-	u32 prior_sacked = tp->sacked_out;
+	u32 prior_sacked = tcp_acked_out(tp);
 	s32 seq_rtt = -1;
 	s32 ca_seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
@@ -3050,12 +3076,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		} else {
 			int delta;
 
+			if (tp->acked_out)
+				tcp_remove_reno_sacks(sk, pkts_acked);
+
 			/* Non-retransmitted hole got filled? That's reordering */
 			if (reord < prior_fackets)
 				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
 
 			delta = tcp_is_fack(tp) ? pkts_acked :
-						  prior_sacked - tp->sacked_out;
+						  prior_sacked - tcp_acked_out(tp);
 			tp->lost_cnt_hint -= min(tp->lost_cnt_hint, delta);
 		}
 
@@ -3340,7 +3369,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 		if (TCP_SKB_CB(skb)->sacked)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
-							&sack_rtt);
+							&sack_rtt, flag);
 
 		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb)))
 			flag |= FLAG_ECE;
@@ -3413,7 +3442,7 @@ old_ack:
 	 */
 	if (TCP_SKB_CB(skb)->sacked) {
 		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
-						&sack_rtt);
+						&sack_rtt, flag);
 		tcp_fastretrans_alert(sk, acked, prior_unsacked,
 				      is_dupack, flag);
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 17ebbff..2ecb943 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1008,7 +1008,7 @@ static void tcp_adjust_fackets_out(struct sock *sk, const struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (!tp->sacked_out || tcp_is_reno(tp))
+	if ((!tp->sacked_out && !tp->acked_out) || tcp_is_reno(tp))
 		return;
 
 	if (after(tcp_highest_sack_seq(tp), TCP_SKB_CB(skb)->seq))
@@ -1032,7 +1032,7 @@ static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int de
 		tp->lost_out -= decr;
 
 	/* Reno case is special. Sigh... */
-	if (tcp_is_reno(tp) && decr > 0)
+	if ((tcp_is_reno(tp) || tp->acked_out) && decr > 0)
 		tp->acked_out -= min_t(u32, tp->acked_out, decr);
 
 	tcp_adjust_fackets_out(sk, skb, decr);
-- 
1.8.1.2
