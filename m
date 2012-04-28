From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v2 2/3] RFC tcp: early retransmit
Date: Sat, 28 Apr 2012 11:46:20 -0700
Message-ID: <1335638781-960-2-git-send-email-ycheng@google.com>
References: <1335638781-960-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, nanditad@google.com, edumazet@gmail.com,
	netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f74.google.com ([209.85.215.74]:36891 "EHLO
	mail-lpp01m010-f74.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939Ab2D1Sqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 14:46:34 -0400
Received: by laai8 with SMTP id i8so87459laa.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 11:46:32 -0700 (PDT)
In-Reply-To: <1335638781-960-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements RFC 5827 early retransmit (ER) for TCP.
It reduces DUPACK threshold (dupthresh) if outstanding packets are
less than 4 to recover losses by fast recovery instead of timeout.

While the algorithm is simple, small but frequent network reordering
makes this feature dangerous: the connection repeatedly enter
false recovery and degrade performance. Therefore we implement
a mitigation suggested in the appendix of the RFC that delays
entering fast recovery by a small interval, i.e., RTT/4. But when
the network reordering degree is too large, i.e., 3 packets,
ER is disabled to avoid false fast recoveries for the rest of
the connection. The performance impact of ER is summarized in
section 6 of the paper "Proportional Rate Reduction for TCP=E2=80=9D,
IMC 2011. http://conferences.sigcomm.org/imc/2011/docs/p155.pdf

Note that Linux has a similar feature called THIN_DUPACK. The
differences are THIN_DUPACK do not mitigate reorderings and is only
used after slow start. Currently ER is disabled if THIN_DUPACK is
enabled. I would be happy to merge THIN_DUPACK feature with ER if
people think it's a good idea.

ER is enabled by sysctl_tcp_early_retrans:
  0: Disables ER

  1: Reduce dupthresh to packets_out - 1 when outstanding packets < 4.

  2: (Default) reduce dupthresh like mode 1. In addition, delay
     entering fast recovery by RTT/4.

Note: mode 2 is implemented in the third part of this patch series.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 Documentation/networking/ip-sysctl.txt |   14 ++++++++++++++
 include/linux/tcp.h                    |    7 ++++---
 include/net/tcp.h                      |   15 +++++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |   10 ++++++++++
 net/ipv4/tcp.c                         |    3 +++
 net/ipv4/tcp_input.c                   |   13 +++++++++++++
 net/ipv4/tcp_minisocks.c               |    1 +
 7 files changed, 60 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index 9b569a2..23ebeae 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -202,6 +202,20 @@ tcp_ecn - INTEGER
 		  not support ECN, behavior is like with ECN disabled.
 	Default: 2
=20
+tcp_early_retrans - INTEGER
+	Enable Early Retransmit (ER), per RFC 5827. ER lowers the threshold=20
+	for triggering fast retransmit when the amount of outstanding data is
+	small and when no previously unsent data can be transmitted (such
+	that limited transmit could be used).
+	Possible values:
+		0 disables ER
+		1 enables ER
+		2 enables ER but delays fast recovery and fast retransmit
+		  by a fourth of RTT. This mitigates connection falsely
+		  recovers when network has a small degree of reordering
+		  (less than 3 packets).
+	Default: 2
+
 tcp_fack - BOOLEAN
 	Enable FACK congestion avoidance and fast retransmission.
 	The value is not used, if tcp_sack is not enabled.
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 278af9e..7d08a79 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -365,12 +365,13 @@ struct tcp_sock {
=20
 	u32	frto_highmark;	/* snd_nxt when RTO occurred */
 	u16	advmss;		/* Advertised MSS			*/
-	u8	frto_counter;	/* Number of new acks after RTO */
-	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
+	u16	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
 		repair      : 1,
-		unused      : 1;
+		do_early_retrans: 1;/* Enable RFC5827 early-retransmit  */
+
+	u8	frto_counter;	/* Number of new acks after RTO */
 	u8	repair_queue;
=20
 /* RTT measurement */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0fb84de..685437a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -252,6 +252,7 @@ extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_early_retrans;
=20
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -797,6 +798,20 @@ static inline void tcp_enable_fack(struct tcp_sock=
 *tp)
 	tp->rx_opt.sack_ok |=3D TCP_FACK_ENABLED;
 }
=20
+/* TCP early-retransmit (ER) is similar to but more conservative than
+ * the thin-dupack feature.  Enable ER only if thin-dupack is disabled=
=2E
+ */
+static inline void tcp_enable_early_retrans(struct tcp_sock *tp)
+{
+	tp->do_early_retrans =3D sysctl_tcp_early_retrans &&
+		!sysctl_tcp_thin_dupack && sysctl_tcp_reordering =3D=3D 3;
+}
+
+static inline void tcp_disable_early_retrans(struct tcp_sock *tp)
+{
+	tp->do_early_retrans =3D 0;
+}
+
 static inline unsigned int tcp_left_out(const struct tcp_sock *tp)
 {
 	return tp->sacked_out + tp->lost_out;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 33417f8..ef32956 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -27,6 +27,7 @@
 #include <net/tcp_memcontrol.h>
=20
 static int zero;
+static int two =3D 2;
 static int tcp_retr1_max =3D 255;
 static int ip_local_port_range_min[] =3D { 1, 1 };
 static int ip_local_port_range_max[] =3D { 65535, 65535 };
@@ -677,6 +678,15 @@ static struct ctl_table ipv4_table[] =3D {
 		.proc_handler   =3D proc_dointvec
 	},
 	{
+		.procname	=3D "tcp_early_retrans",
+		.data		=3D &sysctl_tcp_early_retrans,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &zero,
+		.extra2		=3D &two,
+	},
+	{
 		.procname	=3D "udp_mem",
 		.data		=3D &sysctl_udp_mem,
 		.maxlen		=3D sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9670af3..6802c89 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -395,6 +395,7 @@ void tcp_init_sock(struct sock *sk)
 	tp->mss_cache =3D TCP_MSS_DEFAULT;
=20
 	tp->reordering =3D sysctl_tcp_reordering;
+	tcp_enable_early_retrans(tp);
 	icsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
=20
 	sk->sk_state =3D TCP_CLOSE;
@@ -2495,6 +2496,8 @@ static int do_tcp_setsockopt(struct sock *sk, int=
 level,
 			err =3D -EINVAL;
 		else
 			tp->thin_dupack =3D val;
+			if (tp->thin_dupack)
+				tcp_disable_early_retrans(tp);
 		break;
=20
 	case TCP_REPAIR:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 22df826..98c586d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -99,6 +99,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
=20
 int sysctl_tcp_moderate_rcvbuf __read_mostly =3D 1;
 int sysctl_tcp_abc __read_mostly;
+int sysctl_tcp_early_retrans __read_mostly =3D 2;
=20
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -906,6 +907,7 @@ static void tcp_init_metrics(struct sock *sk)
 	if (dst_metric(dst, RTAX_REORDERING) &&
 	    tp->reordering !=3D dst_metric(dst, RTAX_REORDERING)) {
 		tcp_disable_fack(tp);
+		tcp_disable_early_retrans(tp);
 		tp->reordering =3D dst_metric(dst, RTAX_REORDERING);
 	}
=20
@@ -987,6 +989,7 @@ static void tcp_update_reordering(struct sock *sk, =
const int metric,
 		       tp->undo_marker ? tp->undo_retrans : 0);
 #endif
 		tcp_disable_fack(tp);
+		tcp_disable_early_retrans(tp);
 	}
 }
=20
@@ -2492,6 +2495,16 @@ static int tcp_time_to_recover(struct sock *sk)
 	    tcp_is_sack(tp) && !tcp_send_head(sk))
 		return 1;
=20
+	/* Trick#6: TCP early retransmit, per RFC5827.  To avoid spurious
+	 * retransmissions due to small network reorderings, we implement
+	 * Mitigation A.3 in the RFC and delay the retransmission for a short
+	 * interval if appropriate.
+	 */
+	if (tp->do_early_retrans && !tp->retrans_out && tp->sacked_out &&
+	    (tp->packets_out =3D=3D (tp->sacked_out + 1) && tp->packets_out <=
 4) &&
+	    !tcp_may_send_now(sk))
+		return 1;
+
 	return 0;
 }
=20
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3cabafb..6f6a918 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -482,6 +482,7 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->sacked_out =3D 0;
 		newtp->fackets_out =3D 0;
 		newtp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
+		tcp_enable_early_retrans(newtp);
=20
 		/* So many TCP implementations out there (incorrectly) count the
 		 * initial SYN frame in their delayed-ACK and congestion control
--=20
1.7.7.3
