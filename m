From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 6/7] tcp: track the packet timings in RACK
Date: Fri, 16 Oct 2015 21:57:46 -0700
Message-ID: <1445057867-32257-7-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36580 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbJQE6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:09 -0400
Received: by pacfv9 with SMTP id fv9so40620720pac.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:09 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is the first half of the RACK loss recovery.

RACK loss recovery uses the notion of time instead
of packet sequence (FACK) or counts (dupthresh). It's inspired by the
previous FACK heuristic in tcp_mark_lost_retrans(): when a limited
transmit (new data packet) is sacked, then current retransmitted
sequence below the newly sacked sequence must been lost,
since at least one round trip time has elapsed.

But it has several limitations:
1) can't detect tail drops since it depends on limited transmit
2) is disabled upon reordering (assumes no reordering)
3) only enabled in fast recovery ut not timeout recovery

RACK (Recently ACK) addresses these limitations with the notion
of time instead: a packet P1 is lost if a later packet P2 is s/acked,
as at least one round trip has passed.

Since RACK cares about the time sequence instead of the data sequence
of packets, it can detect tail drops when later retransmission is
s/acked while FACK or dupthresh can't. For reordering RACK uses a
dynamically adjusted reordering window ("reo_wnd") to reduce false
positives on ever (small) degree of reordering.

This patch implements tcp_advanced_rack() which tracks the
most recent transmission time among the packets that have been
delivered (ACKed or SACKed) in tp->rack.mstamp. This timestamp
is the key to determine which packet has been lost.

Consider an example that the sender sends six packets:
T1: P1 (lost)
T2: P2
T3: P3
T4: P4
T100: sack of P2. rack.mstamp = T2
T101: retransmit P1
T102: sack of P2,P3,P4. rack.mstamp = T4
T205: ACK of P4 since the hole is repaired. rack.mstamp = T101

We need to be careful about spurious retransmission because it may
falsely advance tp->rack.mstamp by an RTT or an RTO, causing RACK
to falsely mark all packets lost, just like a spurious timeout.

We identify spurious retransmission by the ACK's TS echo value.
If TS option is not applicable but the retransmission is acknowledged
less than min-RTT ago, it is likely to be spurious. We refrain from
using the transmission time of these spurious retransmissions.

The second half is implemented in the next patch that marks packet
lost using RACK timestamp.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h      |  6 ++++++
 include/net/tcp.h        |  5 +++++
 net/ipv4/Makefile        |  1 +
 net/ipv4/tcp_input.c     | 14 ++++++++++++++
 net/ipv4/tcp_minisocks.c |  2 ++
 net/ipv4/tcp_recovery.c  | 32 ++++++++++++++++++++++++++++++++
 6 files changed, 60 insertions(+)
 create mode 100644 net/ipv4/tcp_recovery.c

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 8c54863..5dce970 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -194,6 +194,12 @@ struct tcp_sock {
 	u32	window_clamp;	/* Maximal window to advertise		*/
 	u32	rcv_ssthresh;	/* Current window clamp			*/
 
+	/* Information of the most recently (s)acked skb */
+	struct tcp_rack {
+		struct skb_mstamp mstamp; /* (Re)sent time of the skb */
+		u8 advanced; /* mstamp advanced since last lost marking */
+		u8 reord;    /* reordering detected */
+	} rack;
 	u16	advmss;		/* Advertised MSS			*/
 	u8	unused;
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4575f0e..aee5f23 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1750,6 +1750,11 @@ int tcpv4_offload_init(void);
 void tcp_v4_init(void);
 void tcp_init(void);
 
+/* tcp_recovery.c */
+
+extern void tcp_rack_advance(struct tcp_sock *tp,
+			     const struct skb_mstamp *xmit_time, u8 sacked);
+
 /*
  * Save and compile IPv4 options, return a pointer to it
  */
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 89aacb6..c29809f 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -8,6 +8,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
 	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
+	     tcp_recovery.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c304b5f..21a9ea4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1173,6 +1173,8 @@ static u8 tcp_sacktag_one(struct sock *sk,
 		return sacked;
 
 	if (!(sacked & TCPCB_SACKED_ACKED)) {
+		tcp_rack_advance(tp, xmit_time, sacked);
+
 		if (sacked & TCPCB_SACKED_RETRANS) {
 			/* If the segment is not tagged as lost,
 			 * we do not clear RETRANS, believing
@@ -2256,6 +2258,16 @@ static bool tcp_tsopt_ecr_before(const struct tcp_sock *tp, u32 when)
 	       before(tp->rx_opt.rcv_tsecr, when);
 }
 
+/* skb is spurious retransmitted if the returned timestamp echo
+ * reply is prior to the skb transmission time
+ */
+static bool tcp_skb_spurious_retrans(const struct tcp_sock *tp,
+				     const struct sk_buff *skb)
+{
+	return (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS) &&
+	       tcp_tsopt_ecr_before(tp, tcp_skb_timestamp(skb));
+}
+
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
@@ -3135,6 +3147,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 		if (sacked & TCPCB_SACKED_ACKED)
 			tp->sacked_out -= acked_pcount;
+		else if (tcp_is_sack(tp) && !tcp_skb_spurious_retrans(tp, skb))
+			tcp_rack_advance(tp, &skb->skb_mstamp, sacked);
 		if (sacked & TCPCB_LOST)
 			tp->lost_out -= acked_pcount;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b875c28..1fd5d41 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -548,6 +548,8 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		tcp_ecn_openreq_child(newtp, req);
 		newtp->fastopen_rsk = NULL;
 		newtp->syn_data_acked = 0;
+		newtp->rack.mstamp.v64 = 0;
+		newtp->rack.advanced = 0;
 
 		newtp->saved_syn = req->saved_syn;
 		req->saved_syn = NULL;
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
new file mode 100644
index 0000000..8f66a65
--- /dev/null
+++ b/net/ipv4/tcp_recovery.c
@@ -0,0 +1,32 @@
+#include <linux/tcp.h>
+#include <net/tcp.h>
+
+/* Record the most recently (re)sent time among the (s)acked packets */
+void tcp_rack_advance(struct tcp_sock *tp,
+		      const struct skb_mstamp *xmit_time, u8 sacked)
+{
+	if (tp->rack.mstamp.v64 &&
+	    !skb_mstamp_after(xmit_time, &tp->rack.mstamp))
+		return;
+
+	if (sacked & TCPCB_RETRANS) {
+		struct skb_mstamp now;
+
+		/* If the sacked packet was retransmitted, it's ambiguous
+		 * whether the retransmission or the original (or the prior
+		 * retransmission) was sacked.
+		 *
+		 * If the original is lost, there is no ambiguity. Otherwise
+		 * we assume the original can be delayed up to aRTT + min_rtt.
+		 * the aRTT term is bounded by the fast recovery or timeout,
+		 * so it's at least one RTT (i.e., retransmission is at least
+		 * an RTT later).
+		 */
+		skb_mstamp_get(&now);
+		if (skb_mstamp_us_delta(&now, xmit_time) < tcp_min_rtt(tp))
+			return;
+	}
+
+	tp->rack.mstamp = *xmit_time;
+	tp->rack.advanced = 1;
+}
-- 
2.6.0.rc2.230.g3dd15c0
