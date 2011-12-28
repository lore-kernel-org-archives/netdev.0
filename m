From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: detect loss above high_seq in recovery
Date: Tue, 27 Dec 2011 16:46:22 -0800
Message-ID: <1325033182-25905-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f202.google.com ([209.85.161.202]:38510 "EHLO
	mail-gx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab1L1Aqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 19:46:39 -0500
Received: by ggnv2 with SMTP id v2so1432098ggn.1
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 16:46:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correctly implement a loss detection heuristic: New sequences (above
high_seq) sent during the fast recovery are deemed lost when higher
sequences are SACKed.

Current code does not catch these losses, because tcp_mark_head_lost()
does not check packets beyond high_seq. The fix is straight-forward by
checking packets until the highest sacked packet. In addition, all the
FLAG_DATA_LOST logic are in-effective and redundant and can be removed.

The new sequences sent during fast-recovery maybe marked as lost
and/or retransmitted. It is possible these (new) losses are recovered
within the current fast recovery and the state moves back to CA_Open
without entering another fast recovery / cwnd redunction. This is
especially possible for light losses.  Note RFC 3517 (implicitly)
allows this as well.

Update the loss heuristic comments. The algorithm above is documented
as heuristic B, but it is redundant too because heuristic A already
covers B.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/linux/snmp.h |    1 -
 net/ipv4/proc.c      |    1 -
 net/ipv4/tcp_input.c |   41 +++++++++++++++--------------------------
 3 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index e16557a..c1241c42 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -192,7 +192,6 @@ enum
 	LINUX_MIB_TCPPARTIALUNDO,		/* TCPPartialUndo */
 	LINUX_MIB_TCPDSACKUNDO,			/* TCPDSACKUndo */
 	LINUX_MIB_TCPLOSSUNDO,			/* TCPLossUndo */
-	LINUX_MIB_TCPLOSS,			/* TCPLoss */
 	LINUX_MIB_TCPLOSTRETRANSMIT,		/* TCPLostRetransmit */
 	LINUX_MIB_TCPRENOFAILURES,		/* TCPRenoFailures */
 	LINUX_MIB_TCPSACKFAILURES,		/* TCPSackFailures */
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3569d8e..6afc807 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -216,7 +216,6 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPPartialUndo", LINUX_MIB_TCPPARTIALUNDO),
 	SNMP_MIB_ITEM("TCPDSACKUndo", LINUX_MIB_TCPDSACKUNDO),
 	SNMP_MIB_ITEM("TCPLossUndo", LINUX_MIB_TCPLOSSUNDO),
-	SNMP_MIB_ITEM("TCPLoss", LINUX_MIB_TCPLOSS),
 	SNMP_MIB_ITEM("TCPLostRetransmit", LINUX_MIB_TCPLOSTRETRANSMIT),
 	SNMP_MIB_ITEM("TCPRenoFailures", LINUX_MIB_TCPRENOFAILURES),
 	SNMP_MIB_ITEM("TCPSackFailures", LINUX_MIB_TCPSACKFAILURES),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2877c3e..976034f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -105,7 +105,6 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_SYN_ACKED		0x10 /* This ACK acknowledged SYN.		*/
 #define FLAG_DATA_SACKED	0x20 /* New SACK.				*/
 #define FLAG_ECE		0x40 /* ECE in this ACK				*/
-#define FLAG_DATA_LOST		0x80 /* SACK detected data lossage.		*/
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
 #define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent before RTO */
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
@@ -1040,13 +1039,11 @@ static void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
  * These 6 states form finite state machine, controlled by the following events:
  * 1. New ACK (+SACK) arrives. (tcp_sacktag_write_queue())
  * 2. Retransmission. (tcp_retransmit_skb(), tcp_xmit_retransmit_queue())
- * 3. Loss detection event of one of three flavors:
+ * 3. Loss detection event of two flavors:
  *	A. Scoreboard estimator decided the packet is lost.
  *	   A'. Reno "three dupacks" marks head of queue lost.
- *	   A''. Its FACK modfication, head until snd.fack is lost.
- *	B. SACK arrives sacking data transmitted after never retransmitted
- *	   hole was sent out.
- *	C. SACK arrives sacking SND.NXT at the moment, when the
+ *	   A''. Its FACK modification, head until snd.fack is lost.
+ *	B. SACK arrives sacking SND.NXT at the moment, when the
  *	   segment was retransmitted.
  * 4. D-SACK added new rule: D-SACK changes any tag to S.
  *
@@ -1153,7 +1150,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 }
 
 /* Check for lost retransmit. This superb idea is borrowed from "ratehalving".
- * Event "C". Later note: FACK people cheated me again 8), we have to account
+ * Event "B". Later note: FACK people cheated me again 8), we have to account
  * for reordering! Ugly, but should help.
  *
  * Search retransmitted skbs from write_queue that were sent when snd_nxt was
@@ -1844,10 +1841,6 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 		if (found_dup_sack && ((i + 1) == first_sack_index))
 			next_dup = &sp[i + 1];
 
-		/* Event "B" in the comment above. */
-		if (after(end_seq, tp->high_seq))
-			state.flag |= FLAG_DATA_LOST;
-
 		/* Skip too early cached blocks */
 		while (tcp_sack_cache_ok(tp, cache) &&
 		       !before(start_seq, cache->end_seq))
@@ -2515,8 +2508,11 @@ static void tcp_timeout_skbs(struct sock *sk)
 	tcp_verify_left_out(tp);
 }
 
-/* Mark head of queue up as lost. With RFC3517 SACK, the packets is
- * is against sacked "cnt", otherwise it's against facked "cnt"
+/* Detect loss in event "A" above by marking head of queue up as lost.
+ * For FACK or non-SACK(Reno) senders, the first "packets" number of segments
+ * are considered lost. For RFC3517 SACK, a segment is considered lost if it
+ * has at least tp->reordering SACKed seqments above it; "packets" refers to
+ * the maximum SACKed segments to pass before reaching this limit.
  */
 static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 {
@@ -2525,6 +2521,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 	int cnt, oldcnt;
 	int err;
 	unsigned int mss;
+	/* Use SACK to deduce losses of new sequences sent during recovery */
+	const u32 loss_high = tcp_is_sack(tp) ?  tp->snd_nxt : tp->high_seq;
 
 	WARN_ON(packets > tp->packets_out);
 	if (tp->lost_skb_hint) {
@@ -2546,7 +2544,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 		tp->lost_skb_hint = skb;
 		tp->lost_cnt_hint = cnt;
 
-		if (after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
+		if (after(TCP_SKB_CB(skb)->end_seq, loss_high))
 			break;
 
 		oldcnt = cnt;
@@ -3033,19 +3031,10 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 	if (tcp_check_sack_reneging(sk, flag))
 		return;
 
-	/* C. Process data loss notification, provided it is valid. */
-	if (tcp_is_fack(tp) && (flag & FLAG_DATA_LOST) &&
-	    before(tp->snd_una, tp->high_seq) &&
-	    icsk->icsk_ca_state != TCP_CA_Open &&
-	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering, 0);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSS);
-	}
-
-	/* D. Check consistency of the current state. */
+	/* C. Check consistency of the current state. */
 	tcp_verify_left_out(tp);
 
-	/* E. Check state exit conditions. State can be terminated
+	/* D. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
 	if (icsk->icsk_ca_state == TCP_CA_Open) {
 		WARN_ON(tp->retrans_out != 0);
@@ -3077,7 +3066,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
 		}
 	}
 
-	/* F. Process state. */
+	/* E. Process state. */
 	switch (icsk->icsk_ca_state) {
 	case TCP_CA_Recovery:
 		if (!(flag & FLAG_SND_UNA_ADVANCED)) {
-- 
1.7.3.1
