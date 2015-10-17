From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 7/7] tcp: use RACK to detect losses
Date: Fri, 16 Oct 2015 21:57:47 -0700
Message-ID: <1445057867-32257-8-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36591 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbbJQE6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:10 -0400
Received: by pacfv9 with SMTP id fv9so40621025pac.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:10 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the second half of RACK that uses the the most
recent transmit time among all delivered packets to detect losses.

tcp_rack_mark_lost() is called upon receiving a dubious ACK.
It then checks if an not-yet-sacked packet was sent at least
"reo_wnd" prior to the sent time of the most recently delivered.
If so the packet is deemed lost.

The "reo_wnd" reordering window starts with 1msec for fast loss
detection and changes to min-RTT/4 when reordering is observed.
We found 1msec accommodates well on tiny degree of reordering
(<3 pkts) on faster links. We use min-RTT instead of SRTT because
reordering is more of a path property but SRTT can be inflated by
self-inflicated congestion. The factor of 4 is borrowed from the
delayed early retransmit and seems to work reasonably well.

Since RACK is still experimental, it is now used as a supplemental
loss detection on top of existing algorithms. It is only effective
after the fast recovery starts or after the timeout occurs. The
fast recovery is still triggered by FACK and/or dupack threshold
instead of RACK.

We introduce a new sysctl net.ipv4.tcp_recovery for future
experiments of loss recoveries. For now RACK can be disabled by
setting it to 0.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |  9 ++++
 include/net/tcp.h                      |  9 ++++
 net/ipv4/sysctl_net_ipv4.c             |  7 ++++
 net/ipv4/tcp_input.c                   |  9 +++-
 net/ipv4/tcp_recovery.c                | 77 ++++++++++++++++++++++++++++++++++
 5 files changed, 109 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 502d6a5..85752c8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -433,6 +433,15 @@ tcp_orphan_retries - INTEGER
 	you should think about lowering this value, such sockets
 	may consume significant resources. Cf. tcp_max_orphans.
 
+tcp_recovery - INTEGER
+	This value is a bitmap to enable various experimental loss recovery
+	features.
+
+	RACK: 0x1 enables the RACK loss detection for fast detection of lost
+	      retransmissions and tail drops.
+
+	Default: 0x1
+
 tcp_reordering - INTEGER
 	Initial reordering level of packets in a TCP stream.
 	TCP stack can then dynamically adjust flow reordering level
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aee5f23..f615789 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -567,6 +567,7 @@ void tcp_resume_early_retransmit(struct sock *sk);
 void tcp_rearm_rto(struct sock *sk);
 void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req);
 void tcp_reset(struct sock *sk);
+void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_buff *skb);
 
 /* tcp_timer.c */
 void tcp_init_xmit_timers(struct sock *);
@@ -1752,6 +1753,14 @@ void tcp_init(void);
 
 /* tcp_recovery.c */
 
+/* Flags to enable various loss recovery features. See below */
+extern int sysctl_tcp_recovery;
+
+/* Use TCP RACK to detect (some) tail and retransmit losses */
+#define TCP_RACK_LOST_RETRANS  0x1
+
+extern int tcp_rack_mark_lost(struct sock *sk);
+
 extern void tcp_rack_advance(struct tcp_sock *tp,
 			     const struct skb_mstamp *xmit_time, u8 sacked);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 13ab434..25300c5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -496,6 +496,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "tcp_recovery",
+		.data		= &sysctl_tcp_recovery,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "tcp_reordering",
 		.data		= &sysctl_tcp_reordering,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21a9ea4..cf0f954 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -881,6 +881,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 
 	if (metric > 0)
 		tcp_disable_early_retrans(tp);
+	tp->rack.reord = 1;
 }
 
 /* This must be called before lost_out is incremented */
@@ -906,8 +907,7 @@ static void tcp_skb_mark_lost(struct tcp_sock *tp, struct sk_buff *skb)
 	}
 }
 
-static void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
-					    struct sk_buff *skb)
+void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp, struct sk_buff *skb)
 {
 	tcp_verify_retransmit_hint(tp, skb);
 
@@ -2806,6 +2806,11 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 		}
 	}
 
+	/* Use RACK to detect loss */
+	if (sysctl_tcp_recovery & TCP_RACK_LOST_RETRANS &&
+	    tcp_rack_mark_lost(sk))
+		flag |= FLAG_LOST_RETRANS;
+
 	/* E. Process state. */
 	switch (icsk->icsk_ca_state) {
 	case TCP_CA_Recovery:
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index 8f66a65..5353085 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -1,6 +1,83 @@
 #include <linux/tcp.h>
 #include <net/tcp.h>
 
+int sysctl_tcp_recovery __read_mostly = TCP_RACK_LOST_RETRANS;
+
+/* Marks a packet lost, if some packet sent later has been (s)acked.
+ * The underlying idea is similar to the traditional dupthresh and FACK
+ * but they look at different metrics:
+ *
+ * dupthresh: 3 OOO packets delivered (packet count)
+ * FACK: sequence delta to highest sacked sequence (sequence space)
+ * RACK: sent time delta to the latest delivered packet (time domain)
+ *
+ * The advantage of RACK is it applies to both original and retransmitted
+ * packet and therefore is robust against tail losses. Another advantage
+ * is being more resilient to reordering by simply allowing some
+ * "settling delay", instead of tweaking the dupthresh.
+ *
+ * The current version is only used after recovery starts but can be
+ * easily extended to detect the first loss.
+ */
+int tcp_rack_mark_lost(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	u32 reo_wnd, prior_retrans = tp->retrans_out;
+
+	if (inet_csk(sk)->icsk_ca_state < TCP_CA_Recovery || !tp->rack.advanced)
+		return 0;
+
+	/* Reset the advanced flag to avoid unnecessary queue scanning */
+	tp->rack.advanced = 0;
+
+	/* To be more reordering resilient, allow min_rtt/4 settling delay
+	 * (lower-bounded to 1000uS). We use min_rtt instead of the smoothed
+	 * RTT because reordering is often a path property and less related
+	 * to queuing or delayed ACKs.
+	 *
+	 * TODO: measure and adapt to the observed reordering delay, and
+	 * use a timer to retransmit like the delayed early retransmit.
+	 */
+	reo_wnd = 1000;
+	if (tp->rack.reord && tcp_min_rtt(tp) != ~0U)
+		reo_wnd = max(tcp_min_rtt(tp) >> 2, reo_wnd);
+
+	tcp_for_write_queue(skb, sk) {
+		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
+
+		if (skb == tcp_send_head(sk))
+			break;
+
+		/* Skip ones already (s)acked */
+		if (!after(scb->end_seq, tp->snd_una) ||
+		    scb->sacked & TCPCB_SACKED_ACKED)
+			continue;
+
+		if (skb_mstamp_after(&tp->rack.mstamp, &skb->skb_mstamp)) {
+
+			if (skb_mstamp_us_delta(&tp->rack.mstamp,
+						&skb->skb_mstamp) <= reo_wnd)
+				continue;
+
+			/* skb is lost if packet sent later is sacked */
+			tcp_skb_mark_lost_uncond_verify(tp, skb);
+			if (scb->sacked & TCPCB_SACKED_RETRANS) {
+				scb->sacked &= ~TCPCB_SACKED_RETRANS;
+				tp->retrans_out -= tcp_skb_pcount(skb);
+				NET_INC_STATS_BH(sock_net(sk),
+						 LINUX_MIB_TCPLOSTRETRANSMIT);
+			}
+		} else if (!(scb->sacked & TCPCB_RETRANS)) {
+			/* Original data are sent sequentially so stop early
+			 * b/c the rest are all sent after rack_sent
+			 */
+			break;
+		}
+	}
+	return prior_retrans - tp->retrans_out;
+}
+
 /* Record the most recently (re)sent time among the (s)acked packets */
 void tcp_rack_advance(struct tcp_sock *tp,
 		      const struct skb_mstamp *xmit_time, u8 sacked)
-- 
2.6.0.rc2.230.g3dd15c0
