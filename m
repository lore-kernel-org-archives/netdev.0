From: Daniel Slot <slot.daniel@gmail.com>
Subject: [PATCH] net/ipv4, linux-2.6.30.4
Date: Wed, 12 Aug 2009 20:59:49 +0200
Message-ID: <bb6e06c00908121159m60545632n172305ce206816a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:45344 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbZHLS7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 14:59:49 -0400
Received: by ewy10 with SMTP id 10so246805ewy.37
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2009 11:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
In the absence of explicit congestion notification from the network,
TCP uses loss as an indication of congestion.
One of the ways TCP detects loss is using the arrival of three
duplicate acknowledgments.
However, this heuristic is not always correct, notably in the case
when network paths reorder segments (for whatever reason), resulting
in degraded performance.
TCP-NCR is designed to mitigate this degraded performance by
increasing the number of duplicate acknowledgments required to trigger
loss recovery,
based on the current state of the connection, in an effort to better
disambiguate true segment loss from segment reordering.
This document specifies the changes to TCP, as well as the costs and
benefits of these modifications.

This patch adds TCP-NCR as socket option to the Linux kernel (version 2.6.30.4).
To use TCP-NCR in careful mode (resp. aggressive mode),
an application has to set the TCP-NCR socket option (23) to the value
1 (resp. 2) \
when it starts a TCP connection.

Written by Daniel Slot, Email: slot.daniel(at)gmail.com

---------------------------

diff -uprN linux-2.6.30.4/include/linux/tcp.h
linux-2.6.30.4-NCR/include/linux/tcp.h
--- /include/linux/tcp.h	2009-07-31 00:34:47.000000000 +0200
+++ /include/linux/tcp.h	2009-08-12 20:15:18.000000000 +0200
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_NCR         23  /* TCP NCR (RFC4653) */

 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -408,6 +409,13 @@ struct tcp_sock {
 #endif

 	int			linger2;
+
+/* TCP NCR extension information */
+    u8  tcp_ncr_flag;
+    u8  elt_flag;
+    u8  dupthresh;
+    u8  LT_F;
+    u32 priorFlightSize;
 };

 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff -uprN linux-2.6.30.4/net/ipv4/tcp.c linux-2.6.30.4-NCR/net/ipv4/tcp.c
--- /net/ipv4/tcp.c	2009-07-31 00:34:47.000000000 +0200
+++ /net/ipv4/tcp.c	2009-08-12 20:15:18.000000000 +0200
@@ -2208,6 +2208,17 @@ static int do_tcp_setsockopt(struct sock
 		break;
 #endif

+    case TCP_NCR:
+        /* TCP-NCR : val equal 1 for careful mode, val equal 2 for
aggressive mode */
+        if (val){
+            tp->tcp_ncr_flag = 1;
+            if (val==1) tp->LT_F = 3;
+            if (val==2) tp->LT_F = 4;
+        } else {
+            tp->tcp_ncr_flag = 0;
+        }
+        break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
diff -uprN linux-2.6.30.4/net/ipv4/tcp_input.c
linux-2.6.30.4-NCR/net/ipv4/tcp_input.c
--- /net/ipv4/tcp_input.c	2009-07-31 00:34:47.000000000 +0200
+++ /net/ipv4/tcp_input.c	2009-08-12 20:15:18.000000000 +0200
@@ -1003,6 +1003,45 @@ static void tcp_skb_mark_lost_uncond_ver
 	}
 }

+/* TCP-NCR: Test if TCP-NCR may be used
+ * (Following RFC 4653 recommendations)
+ */
+static int tcp_ncr_test(struct tcp_sock *tp)
+{
+    return (tp->tcp_ncr_flag && tcp_is_sack(tp) && !(tp->nonagle &
TCP_NAGLE_OFF));
+}
+
+/* TCP-NCR: Initiate Extended Limited Transmit
+ * (RFC 4653 Initialization)
+ * */
+static void tcp_ncr_elt_init(struct tcp_sock *tp, int how)
+{
+    if (!how) tp->priorFlightSize = tp->packets_out;
+    tp->elt_flag = 1;
+    tp->dupthresh = max_t(u32, ((2 * tp->packets_out)/tp->LT_F), 3);
+}
+
+/* TCP-NCR Extended Limited Transmit
+ * (RFC 4653 Termination)
+ */
+static void tcp_ncr_elt_end(struct tcp_sock *tp, int flag , int how)
+{
+    if (how){
+        /* New cumulative ACK during ELT, it is reordering. */
+        tp->snd_ssthresh = tp->priorFlightSize;
+        tp->snd_cwnd = min(tp->packets_out+1, tp->priorFlightSize);
+        tp->snd_cwnd_stamp = tcp_time_stamp;
+        if (flag & FLAG_DATA_SACKED) tcp_ncr_elt_init(tp, 1);
+        else tp->elt_flag = 0;
+    } else {
+        /* Dupthresh is reached, start recovery */
+        tp->snd_ssthresh = (tp->priorFlightSize/2);
+        tp->snd_cwnd = tp->snd_ssthresh;
+        tp->snd_cwnd_stamp = tcp_time_stamp;
+        tp->elt_flag = 0;
+    }
+}
+
 /* This procedure tags the retransmission queue when SACKs arrive.
  *
  * We have three tag bits: SACKED(S), RETRANS(R) and LOST(L).
@@ -1346,6 +1385,9 @@ static u8 tcp_sacktag_one(struct sk_buff
 			}
 		}

+        /* TCP-NCR: Initialization */
+        if (tcp_ncr_test(tp) && (!tp->elt_flag) && (tp->sacked_out ==
0)) tcp_ncr_elt_init(tp, 0);
+
 		sacked |= TCPCB_SACKED_ACKED;
 		state->flag |= FLAG_DATA_SACKED;
 		tp->sacked_out += pcount;
@@ -2425,9 +2467,13 @@ static int tcp_time_to_recover(struct so
 	if (tp->lost_out)
 		return 1;

-	/* Not-A-Trick#2 : Classic rule... */
-	if (tcp_dupack_heurestics(tp) > tp->reordering)
-		return 1;
+    /* Not-A-Trick#2 : Classic rule...
+     * (Option to use TCP-NCR dupthresh instead)
+     */
+    if (tp->elt_flag && (tcp_dupack_heurestics(tp) > tp->dupthresh))
+        return 1;
+    if (!tp->elt_flag && (tcp_dupack_heurestics(tp) > tp->reordering))
+        return 1;

 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
@@ -2603,6 +2649,17 @@ static void tcp_cwnd_down(struct sock *s
 	}
 }

+/* TCP-NCR: Extended Limited Transmit
+ * (RFC 4653 Main Part)
+ */
+static void tcp_ncr_elt(struct sock *sk, int flag)
+{
+    struct tcp_sock *tp = tcp_sk(sk);
+
+    if (tp->LT_F == 3) tcp_cwnd_down(sk, flag);
+    tp->dupthresh = max_t(u32, ((2 * tp->packets_out)/tp->LT_F), 3);
+}
+
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
@@ -2812,7 +2869,7 @@ static void tcp_try_to_open(struct sock

 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		tcp_try_keep_open(sk);
-		tcp_moderate_cwnd(tp);
+        if (!tcp_ncr_test(tp)) tcp_moderate_cwnd(tp);
 	} else {
 		tcp_cwnd_down(sk, flag);
 	}
@@ -2920,6 +2977,9 @@ static void tcp_fastretrans_alert(struct
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
 		tp->fackets_out = 0;

+    /* TCP-NCR: Extended Limited Transmit */
+    if (tp->elt_flag && (flag & FLAG_DATA_SACKED)) tcp_ncr_elt(sk, flag);
+
 	/* Now state machine starts.
 	 * A. ECE, hence prohibit cwnd undoing, the reduction is required. */
 	if (flag & FLAG_ECE)
@@ -3050,7 +3110,8 @@ static void tcp_fastretrans_alert(struct
 		if (icsk->icsk_ca_state < TCP_CA_CWR) {
 			if (!(flag & FLAG_ECE))
 				tp->prior_ssthresh = tcp_current_ssthresh(sk);
-			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
+            if (tp->elt_flag) tcp_ncr_elt_end(tp, flag, 0);
+            else tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
 			TCP_ECN_queue_cwr(tp);
 		}

@@ -3062,8 +3123,8 @@ static void tcp_fastretrans_alert(struct

 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
-	tcp_cwnd_down(sk, flag);
-	tcp_xmit_retransmit_queue(sk);
+    if (!tcp_ncr_test(tp))tcp_cwnd_down(sk, flag);
+    tcp_xmit_retransmit_queue(sk);
 }

 static void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
@@ -3285,8 +3346,10 @@ static int tcp_clean_rtx_queue(struct so
 			int delta;

 			/* Non-retransmitted hole got filled? That's reordering */
-			if (reord < prior_fackets)
+			if (reord < prior_fackets){
 				tcp_update_reordering(sk, tp->fackets_out - reord, 0);
+                if (tp->elt_flag) tcp_ncr_elt_end(tp, flag, 1);
+            }

 			delta = tcp_is_fack(tp) ? pkts_acked :
 						  prior_sacked - tp->sacked_out;
diff -uprN linux-2.6.30.4/net/ipv4/tcp_ipv4.c
linux-2.6.30.4-NCR/net/ipv4/tcp_ipv4.c
--- /net/ipv4/tcp_ipv4.c	2009-07-31 00:34:47.000000000 +0200
+++ /net/ipv4/tcp_ipv4.c	2009-08-12 20:15:18.000000000 +0200
@@ -1774,6 +1774,11 @@ static int tcp_v4_init_sock(struct sock
 	tp->mss_cache = 536;

 	tp->reordering = sysctl_tcp_reordering;
+
+    /* TCP-NCR: Initiate some variables */
+    tp->dupthresh = TCP_FASTRETRANS_THRESH;
+    tp->elt_flag = 0;
+
 	icsk->icsk_ca_ops = &tcp_init_congestion_ops;

 	sk->sk_state = TCP_CLOSE;
---------------------------
