From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next-2.6] TCP: de-bloat a bit with factoring NET_INC_STATS_BH
 out
Date: Wed, 18 Jun 2008 20:03:01 +0400
Message-ID: <485931B5.2020509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33277 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984AbYFRQFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 12:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some places in TCP that select one MIB index to
bump snmp statistics like this:

	if (<something>)
		NET_INC_STATS_BH(<some_id>);
	else if (<something_else>)
		NET_INC_STATS_BH(<some_other_id>);
	...
	else
		NET_INC_STATS_BH(<default_id>);

or in a more tricky but still similar way.

On the other hand, this NET_INC_STATS_BH is a camouflaged
increment of percpu variable, which is not that small.

Factoring those cases out de-bloats 235 bytes on non-preemptible
i386 config and drives parts of the code into 80 columns.

add/remove: 0/0 grow/shrink: 0/7 up/down: 0/-235 (-235)
function                                     old     new   delta
tcp_fastretrans_alert                       1437    1424     -13
tcp_dsack_set                                137     124     -13
tcp_xmit_retransmit_queue                    690     676     -14
tcp_try_undo_recovery                        283     265     -18
tcp_sacktag_write_queue                     1550    1515     -35
tcp_update_reordering                        162     106     -56
tcp_retransmit_timer                         990     904     -86

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index de30e70..d6ea970 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -947,17 +947,21 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	if (metric > tp->reordering) {
+		int mib_idx;
+
 		tp->reordering = min(TCP_MAX_REORDERING, metric);
 
 		/* This exciting event is worth to be remembered. 8) */
 		if (ts)
-			NET_INC_STATS_BH(LINUX_MIB_TCPTSREORDER);
+			mib_idx = LINUX_MIB_TCPTSREORDER;
 		else if (tcp_is_reno(tp))
-			NET_INC_STATS_BH(LINUX_MIB_TCPRENOREORDER);
+			mib_idx = LINUX_MIB_TCPRENOREORDER;
 		else if (tcp_is_fack(tp))
-			NET_INC_STATS_BH(LINUX_MIB_TCPFACKREORDER);
+			mib_idx = LINUX_MIB_TCPFACKREORDER;
 		else
-			NET_INC_STATS_BH(LINUX_MIB_TCPSACKREORDER);
+			mib_idx = LINUX_MIB_TCPSACKREORDER;
+
+		NET_INC_STATS_BH(mib_idx);
 #if FASTRETRANS_DEBUG > 1
 		printk(KERN_DEBUG "Disorder%d %d %u f%u s%u rr%d\n",
 		       tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
@@ -1456,18 +1460,22 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 		if (!tcp_is_sackblock_valid(tp, dup_sack,
 					    sp[used_sacks].start_seq,
 					    sp[used_sacks].end_seq)) {
+			int mib_idx;
+
 			if (dup_sack) {
 				if (!tp->undo_marker)
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
+					mib_idx = LINUX_MIB_TCPDSACKIGNOREDNOUNDO;
 				else
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
+					mib_idx = LINUX_MIB_TCPDSACKIGNOREDOLD;
 			} else {
 				/* Don't count olds caused by ACK reordering */
 				if ((TCP_SKB_CB(ack_skb)->ack_seq != tp->snd_una) &&
 				    !after(sp[used_sacks].end_seq, tp->snd_una))
 					continue;
-				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+				mib_idx = LINUX_MIB_TCPSACKDISCARD;
 			}
+
+			NET_INC_STATS_BH(mib_idx);
 			if (i == 0)
 				first_sack_index = -1;
 			continue;
@@ -2380,15 +2388,19 @@ static int tcp_try_undo_recovery(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_may_undo(tp)) {
+		int mib_idx;
+
 		/* Happy end! We did not retransmit anything
 		 * or our original transmission succeeded.
 		 */
 		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
 		tcp_undo_cwr(sk, 1);
 		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
-			NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
+			mib_idx = LINUX_MIB_TCPLOSSUNDO;
 		else
-			NET_INC_STATS_BH(LINUX_MIB_TCPFULLUNDO);
+			mib_idx = LINUX_MIB_TCPFULLUNDO;
+
+		NET_INC_STATS_BH(mib_idx);
 		tp->undo_marker = 0;
 	}
 	if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
@@ -2560,7 +2572,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	int is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
-	int fast_rexmit = 0;
+	int fast_rexmit = 0, mib_idx;
 
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
@@ -2683,9 +2695,11 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 		/* Otherwise enter Recovery state */
 
 		if (tcp_is_reno(tp))
-			NET_INC_STATS_BH(LINUX_MIB_TCPRENORECOVERY);
+			mib_idx = LINUX_MIB_TCPRENORECOVERY;
 		else
-			NET_INC_STATS_BH(LINUX_MIB_TCPSACKRECOVERY);
+			mib_idx = LINUX_MIB_TCPSACKRECOVERY;
+
+		NET_INC_STATS_BH(mib_idx);
 
 		tp->high_seq = tp->snd_nxt;
 		tp->prior_ssthresh = 0;
@@ -3700,10 +3714,14 @@ static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
 static void tcp_dsack_set(struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
+		int mib_idx;
+
 		if (before(seq, tp->rcv_nxt))
-			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOLDSENT);
+			mib_idx = LINUX_MIB_TCPDSACKOLDSENT;
 		else
-			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFOSENT);
+			mib_idx = LINUX_MIB_TCPDSACKOFOSENT;
+
+		NET_INC_STATS_BH(mib_idx);
 
 		tp->rx_opt.dsack = 1;
 		tp->duplicate_sack[0].start_seq = seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8f83ab4..edef2af 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1985,14 +1985,17 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
+					int mib_idx;
+
 					if (tcp_retransmit_skb(sk, skb)) {
 						tp->retransmit_skb_hint = NULL;
 						return;
 					}
 					if (icsk->icsk_ca_state != TCP_CA_Loss)
-						NET_INC_STATS_BH(LINUX_MIB_TCPFASTRETRANS);
+						mib_idx = LINUX_MIB_TCPFASTRETRANS;
 					else
-						NET_INC_STATS_BH(LINUX_MIB_TCPSLOWSTARTRETRANS);
+						mib_idx = LINUX_MIB_TCPSLOWSTARTRETRANS;
+					NET_INC_STATS_BH(mib_idx);
 
 					if (skb == tcp_write_queue_head(sk))
 						inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 3e358cb..6a480d1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -326,24 +326,27 @@ static void tcp_retransmit_timer(struct sock *sk)
 		goto out;
 
 	if (icsk->icsk_retransmits == 0) {
+		int mib_idx;
+
 		if (icsk->icsk_ca_state == TCP_CA_Disorder ||
 		    icsk->icsk_ca_state == TCP_CA_Recovery) {
 			if (tcp_is_sack(tp)) {
 				if (icsk->icsk_ca_state == TCP_CA_Recovery)
-					NET_INC_STATS_BH(LINUX_MIB_TCPSACKRECOVERYFAIL);
+					mib_idx = LINUX_MIB_TCPSACKRECOVERYFAIL;
 				else
-					NET_INC_STATS_BH(LINUX_MIB_TCPSACKFAILURES);
+					mib_idx = LINUX_MIB_TCPSACKFAILURES;
 			} else {
 				if (icsk->icsk_ca_state == TCP_CA_Recovery)
-					NET_INC_STATS_BH(LINUX_MIB_TCPRENORECOVERYFAIL);
+					mib_idx = LINUX_MIB_TCPRENORECOVERYFAIL;
 				else
-					NET_INC_STATS_BH(LINUX_MIB_TCPRENOFAILURES);
+					mib_idx = LINUX_MIB_TCPRENOFAILURES;
 			}
 		} else if (icsk->icsk_ca_state == TCP_CA_Loss) {
-			NET_INC_STATS_BH(LINUX_MIB_TCPLOSSFAILURES);
+			mib_idx = LINUX_MIB_TCPLOSSFAILURES;
 		} else {
-			NET_INC_STATS_BH(LINUX_MIB_TCPTIMEOUTS);
+			mib_idx = LINUX_MIB_TCPTIMEOUTS;
 		}
+		NET_INC_STATS_BH(mib_idx);
 	}
 
 	if (tcp_use_frto(sk)) {
