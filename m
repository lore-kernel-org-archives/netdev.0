From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: switch rtt estimations to usec resolution
Date: Sun, 23 Feb 2014 10:50:58 -0800
Message-ID: <1393181458.2316.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393137487.2316.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LFD.2.11.1402230908210.1460@ja.home.ssi.bg>
	 <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Larry Brakmo <brakmo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46372 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbaBWSvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 13:51:00 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so5564068pad.41
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 10:51:00 -0800 (PST)
In-Reply-To: <1393178122.2316.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Upcoming congestion controls for TCP require usec resolution for RTT
estimations. Millisecond resolution is simply not enough these days.

FQ/pacing in DC environments also require this change for finer control
and removal of bimodal behavior due to the current hack in
tcp_update_pacing_rate() for 'small rtt'

TCP_CONG_RTT_STAMP no longer is needed.

As Julian Anastasov pointed out, we need to keep user compatibility :
tcp_metrics used to export RTT and RTTVAR in msec resolution,
so we added RTT_US and RTTVAR_US. An iproute2 patch is needed
to use the new attributes if provided by the kernel.

In this example ss command displays a srtt of 32 usecs

lpk51:~# ./ss -i dst lpk52
Netid  State      Recv-Q Send-Q   Local Address:Port       Peer
Address:Port   
tcp    ESTAB      0      1         10.246.11.51:42959
10.246.11.52:64614   
         cubic wscale:6,6 rto:201 rtt:0.032/0.001 ato:40 mss:1448
cwnd:10 send
3620.0Mbps pacing_rate 7240.0Mbps unacked:1 rcv_rtt:993 rcv_space:29559
 
Updated iproute2 ip command displays :

lpk51:~# ./ip tcp_metrics|grep 10.246.11.52
10.246.11.52 age 561.914sec cwnd 10 rtt 274us rttvar 213us source
10.246.11.51

Old binary displays :

lpk51:~# ip tcp_metrics|grep 10.246.11.52
10.246.11.52 age 561.914sec cwnd 10 rtt 250us rttvar 125us source
10.246.11.51

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Larry Brakmo <brakmo@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/linux/tcp.h              |    8 -
 include/net/tcp.h                |   10 +-
 include/uapi/linux/tcp_metrics.h |    7 +
 net/ipv4/tcp.c                   |    8 -
 net/ipv4/tcp_cubic.c             |    4 
 net/ipv4/tcp_hybla.c             |   12 +-
 net/ipv4/tcp_illinois.c          |    1 
 net/ipv4/tcp_input.c             |  120 ++++++++++++-----------------
 net/ipv4/tcp_ipv4.c              |    2 
 net/ipv4/tcp_lp.c                |    1 
 net/ipv4/tcp_metrics.c           |   72 +++++++++--------
 net/ipv4/tcp_minisocks.c         |    4 
 net/ipv4/tcp_output.c            |   14 +--
 net/ipv4/tcp_probe.c             |    2 
 net/ipv4/tcp_vegas.c             |    1 
 net/ipv4/tcp_veno.c              |    1 
 net/ipv4/tcp_yeah.c              |    1 
 17 files changed, 130 insertions(+), 138 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4ad0706d40eb..239946868142 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -201,10 +201,10 @@ struct tcp_sock {
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
-	u32	srtt;		/* smoothed round trip time << 3	*/
-	u32	mdev;		/* medium deviation			*/
-	u32	mdev_max;	/* maximal mdev for the last rtt period	*/
-	u32	rttvar;		/* smoothed mdev_max			*/
+	u32	srtt_us;	/* smoothed round trip time << 3 in usecs */
+	u32	mdev_us;	/* medium deviation			*/
+	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
+	u32	rttvar_us;	/* smoothed mdev_max			*/
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1f820537741a..93eab0b9da60 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -31,6 +31,7 @@
 #include <linux/crypto.h>
 #include <linux/cryptohash.h>
 #include <linux/kref.h>
+#include <linux/ktime.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -478,7 +479,6 @@ int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
-#include <linux/ktime.h>
 
 /* Syncookies use a monotonic timer which increments every 64 seconds.
  * This counter is used both as a hash input and partially encoded into
@@ -619,7 +619,7 @@ static inline void tcp_bound_rto(const struct sock *sk)
 
 static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 {
-	return (tp->srtt >> 3) + tp->rttvar;
+	return usecs_to_jiffies((tp->srtt_us >> 3) + tp->rttvar_us);
 }
 
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
@@ -656,6 +656,11 @@ static inline u32 tcp_rto_min(struct sock *sk)
 	return rto_min;
 }
 
+static inline u32 tcp_rto_min_us(struct sock *sk)
+{
+	return jiffies_to_usecs(tcp_rto_min(sk));
+}
+
 /* Compute the actual receive window we are currently advertising.
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
@@ -778,7 +783,6 @@ enum tcp_ca_event {
 #define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
 
 #define TCP_CONG_NON_RESTRICTED 0x1
-#define TCP_CONG_RTT_STAMP	0x2
 
 struct tcp_congestion_ops {
 	struct list_head	list;
diff --git a/include/uapi/linux/tcp_metrics.h b/include/uapi/linux/tcp_metrics.h
index 54a37b13f2c4..93533926035c 100644
--- a/include/uapi/linux/tcp_metrics.h
+++ b/include/uapi/linux/tcp_metrics.h
@@ -11,12 +11,15 @@
 #define TCP_METRICS_GENL_VERSION	0x1
 
 enum tcp_metric_index {
-	TCP_METRIC_RTT,
-	TCP_METRIC_RTTVAR,
+	TCP_METRIC_RTT,		/* in ms units */
+	TCP_METRIC_RTTVAR,	/* in ms units */
 	TCP_METRIC_SSTHRESH,
 	TCP_METRIC_CWND,
 	TCP_METRIC_REORDERING,
 
+	TCP_METRIC_RTT_US,	/* in usec units */
+	TCP_METRIC_RTTVAR_US,	/* in usec units */
+
 	/* Always last.  */
 	__TCP_METRIC_MAX,
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bed379c7abcd..7374905b3701 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -387,7 +387,7 @@ void tcp_init_sock(struct sock *sk)
 	INIT_LIST_HEAD(&tp->tsq_node);
 
 	icsk->icsk_rto = TCP_TIMEOUT_INIT;
-	tp->mdev = TCP_TIMEOUT_INIT;
+	tp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
@@ -2339,7 +2339,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 
 	sk->sk_shutdown = 0;
 	sock_reset_flag(sk, SOCK_DONE);
-	tp->srtt = 0;
+	tp->srtt_us = 0;
 	if ((tp->write_seq += tp->max_window + 2) == 0)
 		tp->write_seq = 1;
 	icsk->icsk_backoff = 0;
@@ -2783,8 +2783,8 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_pmtu = icsk->icsk_pmtu_cookie;
 	info->tcpi_rcv_ssthresh = tp->rcv_ssthresh;
-	info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
-	info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
+	info->tcpi_rtt = tp->srtt_us >> 3;
+	info->tcpi_rttvar = tp->mdev_us >> 2;
 	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
 	info->tcpi_snd_cwnd = tp->snd_cwnd;
 	info->tcpi_advmss = tp->advmss;
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 828e4c3ffbaf..8bf224516ba2 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -476,10 +476,6 @@ static int __init cubictcp_register(void)
 	/* divide by bic_scale and by constant Srtt (100ms) */
 	do_div(cube_factor, bic_scale * 10);
 
-	/* hystart needs ms clock resolution */
-	if (hystart && HZ < 1000)
-		cubictcp.flags |= TCP_CONG_RTT_STAMP;
-
 	return tcp_register_congestion_control(&cubictcp);
 }
 
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 2a1a9e2a4e51..4c1cb670d62a 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -21,7 +21,7 @@ struct hybla {
 	u32   rho2;	      /* Rho * Rho, integer part */
 	u32   rho_3ls;	      /* Rho parameter, <<3 */
 	u32   rho2_7ls;	      /* Rho^2, <<7	*/
-	u32   minrtt;	      /* Minimum smoothed round trip time value seen */
+	u32   minrtt_us;      /* Minimum smoothed round trip time value seen */
 };
 
 /* Hybla reference round trip time (default= 1/40 sec = 25 ms), in ms */
@@ -35,7 +35,9 @@ static inline void hybla_recalc_param (struct sock *sk)
 {
 	struct hybla *ca = inet_csk_ca(sk);
 
-	ca->rho_3ls = max_t(u32, tcp_sk(sk)->srtt / msecs_to_jiffies(rtt0), 8);
+	ca->rho_3ls = max_t(u32,
+			    tcp_sk(sk)->srtt_us / (rtt0 * USEC_PER_MSEC),
+			    8U);
 	ca->rho = ca->rho_3ls >> 3;
 	ca->rho2_7ls = (ca->rho_3ls * ca->rho_3ls) << 1;
 	ca->rho2 = ca->rho2_7ls >> 7;
@@ -59,7 +61,7 @@ static void hybla_init(struct sock *sk)
 	hybla_recalc_param(sk);
 
 	/* set minimum rtt as this is the 1st ever seen */
-	ca->minrtt = tp->srtt;
+	ca->minrtt_us = tp->srtt_us;
 	tp->snd_cwnd = ca->rho;
 }
 
@@ -94,9 +96,9 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked,
 	int is_slowstart = 0;
 
 	/*  Recalculate rho only if this srtt is the lowest */
-	if (tp->srtt < ca->minrtt){
+	if (tp->srtt_us < ca->minrtt_us){
 		hybla_recalc_param(sk);
-		ca->minrtt = tp->srtt;
+		ca->minrtt_us = tp->srtt_us;
 	}
 
 	if (!tcp_is_cwnd_limited(sk, in_flight))
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index be047c63ca10..863d105e3015 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -325,7 +325,6 @@ static void tcp_illinois_info(struct sock *sk, u32 ext,
 }
 
 static struct tcp_congestion_ops tcp_illinois __read_mostly = {
-	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
 	.cong_avoid	= tcp_illinois_cong_avoid,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 227cba79fa6b..8c77b8ee95b6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -667,11 +667,11 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
  * To save cycles in the RFC 1323 implementation it was better to break
  * it up into three procedures. -- erics
  */
-static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
+static void tcp_rtt_estimator(struct sock *sk, const u32 mrtt_us)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	long m = mrtt; /* RTT */
-	u32 srtt = tp->srtt;
+	long m = mrtt_us; /* RTT */
+	u32 srtt = tp->srtt_us;
 
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
@@ -694,7 +694,7 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 		srtt += m;		/* rtt = 7/8 rtt + 1/8 new */
 		if (m < 0) {
 			m = -m;		/* m is now abs(error) */
-			m -= (tp->mdev >> 2);   /* similar update on mdev */
+			m -= (tp->mdev_us >> 2);   /* similar update on mdev */
 			/* This is similar to one of Eifel findings.
 			 * Eifel blocks mdev updates when rtt decreases.
 			 * This solution is a bit different: we use finer gain
@@ -706,28 +706,28 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 			if (m > 0)
 				m >>= 3;
 		} else {
-			m -= (tp->mdev >> 2);   /* similar update on mdev */
+			m -= (tp->mdev_us >> 2);   /* similar update on mdev */
 		}
-		tp->mdev += m;	    	/* mdev = 3/4 mdev + 1/4 new */
-		if (tp->mdev > tp->mdev_max) {
-			tp->mdev_max = tp->mdev;
-			if (tp->mdev_max > tp->rttvar)
-				tp->rttvar = tp->mdev_max;
+		tp->mdev_us += m;	    	/* mdev = 3/4 mdev + 1/4 new */
+		if (tp->mdev_us > tp->mdev_max_us) {
+			tp->mdev_max_us = tp->mdev_us;
+			if (tp->mdev_max_us > tp->rttvar_us)
+				tp->rttvar_us = tp->mdev_max_us;
 		}
 		if (after(tp->snd_una, tp->rtt_seq)) {
-			if (tp->mdev_max < tp->rttvar)
-				tp->rttvar -= (tp->rttvar - tp->mdev_max) >> 2;
+			if (tp->mdev_max_us < tp->rttvar_us)
+				tp->rttvar_us -= (tp->rttvar_us - tp->mdev_max_us) >> 2;
 			tp->rtt_seq = tp->snd_nxt;
-			tp->mdev_max = tcp_rto_min(sk);
+			tp->mdev_max_us = tcp_rto_min_us(sk);
 		}
 	} else {
 		/* no previous measure. */
 		srtt = m << 3;		/* take the measured time to be rtt */
-		tp->mdev = m << 1;	/* make sure rto = 3*rtt */
-		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
+		tp->mdev_us = m << 1;	/* make sure rto = 3*rtt */
+		tp->mdev_max_us = tp->rttvar_us = max(tp->mdev_us, tcp_rto_min_us(sk));
 		tp->rtt_seq = tp->snd_nxt;
 	}
-	tp->srtt = max(1U, srtt);
+	tp->srtt_us = max(1U, srtt);
 }
 
 /* Set the sk_pacing_rate to allow proper sizing of TSO packets.
@@ -742,20 +742,12 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	u64 rate;
 
 	/* set sk_pacing_rate to 200 % of current rate (mss * cwnd / srtt) */
-	rate = (u64)tp->mss_cache * 2 * (HZ << 3);
+	rate = (u64)tp->mss_cache * 2 * (USEC_PER_SEC << 3);
 
 	rate *= max(tp->snd_cwnd, tp->packets_out);
 
-	/* Correction for small srtt and scheduling constraints.
-	 * For small rtt, consider noise is too high, and use
-	 * the minimal value (srtt = 1 -> 125 us for HZ=1000)
-	 *
-	 * We probably need usec resolution in the future.
-	 * Note: This also takes care of possible srtt=0 case,
-	 * when tcp_rtt_estimator() was not yet called.
-	 */
-	if (tp->srtt > 8 + 2)
-		do_div(rate, tp->srtt);
+	if (likely(tp->srtt_us))
+		do_div(rate, tp->srtt_us);
 
 	/* ACCESS_ONCE() is needed because sch_fq fetches sk_pacing_rate
 	 * without any lock. We want to make sure compiler wont store
@@ -2034,10 +2026,12 @@ static bool tcp_pause_early_retransmit(struct sock *sk, int flag)
 	 * available, or RTO is scheduled to fire first.
 	 */
 	if (sysctl_tcp_early_retrans < 2 || sysctl_tcp_early_retrans > 3 ||
-	    (flag & FLAG_ECE) || !tp->srtt)
+	    (flag & FLAG_ECE) || !tp->srtt_us)
 		return false;
 
-	delay = max_t(unsigned long, (tp->srtt >> 5), msecs_to_jiffies(2));
+	delay = max(usecs_to_jiffies(tp->srtt_us >> 5),
+		    msecs_to_jiffies(2));
+
 	if (!time_after(inet_csk(sk)->icsk_timeout, (jiffies + delay)))
 		return false;
 
@@ -2884,7 +2878,7 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 }
 
 static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
-				      s32 seq_rtt, s32 sack_rtt)
+				      s32 seq_rtt_us, s32 sack_rtt)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2894,10 +2888,10 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 	 * is acked (RFC6298).
 	 */
 	if (flag & FLAG_RETRANS_DATA_ACKED)
-		seq_rtt = -1;
+		seq_rtt_us = -1;
 
-	if (seq_rtt < 0)
-		seq_rtt = sack_rtt;
+	if (seq_rtt_us < 0)
+		seq_rtt_us = jiffies_to_usecs(sack_rtt);
 
 	/* RTTM Rule: A TSecr value received in a segment is used to
 	 * update the averaged RTT measurement only if the segment
@@ -2905,14 +2899,14 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 	 * left edge of the send window.
 	 * See draft-ietf-tcplw-high-performance-00, section 3.3.
 	 */
-	if (seq_rtt < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
+	if (seq_rtt_us < 0 && tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 	    flag & FLAG_ACKED)
-		seq_rtt = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
+		seq_rtt_us = jiffies_to_usecs(tcp_time_stamp - tp->rx_opt.rcv_tsecr);
 
-	if (seq_rtt < 0)
+	if (seq_rtt_us < 0)
 		return false;
 
-	tcp_rtt_estimator(sk, seq_rtt);
+	tcp_rtt_estimator(sk, seq_rtt_us);
 	tcp_set_rto(sk);
 
 	/* RFC6298: only reset backoff on valid RTT measurement. */
@@ -2924,16 +2918,16 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 static void tcp_synack_rtt_meas(struct sock *sk, const u32 synack_stamp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	s32 seq_rtt = -1;
+	s32 seq_rtt_us = -1;
 
 	if (synack_stamp && !tp->total_retrans)
-		seq_rtt = tcp_time_stamp - synack_stamp;
+		seq_rtt_us = jiffies_to_usecs(tcp_time_stamp - synack_stamp);
 
 	/* If the ACK acks both the SYNACK and the (Fast Open'd) data packets
 	 * sent in SYN_RECV, SYNACK RTT is the smooth RTT computed in tcp_ack()
 	 */
-	if (!tp->srtt)
-		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt, -1);
+	if (!tp->srtt_us)
+		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt_us, -1);
 }
 
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight)
@@ -3033,9 +3027,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	u32 pkts_acked = 0;
 	u32 reord = tp->packets_out;
 	u32 prior_sacked = tp->sacked_out;
-	s32 seq_rtt = -1;
-	s32 ca_seq_rtt = -1;
+	s32 seq_rtt_us = -1;
+	s32 ca_seq_rtt_us = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
+	ktime_t first_ackt = net_invalid_timestamp();
 	bool rtt_update;
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
@@ -3063,11 +3058,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 				tp->retrans_out -= acked_pcount;
 			flag |= FLAG_RETRANS_DATA_ACKED;
 		} else {
-			ca_seq_rtt = now - scb->when;
 			last_ackt = skb->tstamp;
-			if (seq_rtt < 0) {
-				seq_rtt = ca_seq_rtt;
-			}
+			if (!first_ackt.tv64)
+				first_ackt = last_ackt;
+
 			if (!(sacked & TCPCB_SACKED_ACKED))
 				reord = min(pkts_acked, reord);
 			if (!after(scb->end_seq, tp->high_seq))
@@ -3113,7 +3107,14 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
-	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt);
+	if (first_ackt.tv64) {
+		ktime_t curt = ktime_get_real();
+
+		seq_rtt_us = ktime_us_delta(curt, first_ackt);
+		ca_seq_rtt_us = ktime_us_delta(curt, last_ackt);
+	}
+
+	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt);
 
 	if (flag & FLAG_ACKED) {
 		const struct tcp_congestion_ops *ca_ops
@@ -3141,23 +3142,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 		tp->fackets_out -= min(pkts_acked, tp->fackets_out);
 
-		if (ca_ops->pkts_acked) {
-			s32 rtt_us = -1;
-
-			/* Is the ACK triggering packet unambiguous? */
-			if (!(flag & FLAG_RETRANS_DATA_ACKED)) {
-				/* High resolution needed and available? */
-				if (ca_ops->flags & TCP_CONG_RTT_STAMP &&
-				    !ktime_equal(last_ackt,
-						 net_invalid_timestamp()))
-					rtt_us = ktime_us_delta(ktime_get_real(),
-								last_ackt);
-				else if (ca_seq_rtt >= 0)
-					rtt_us = jiffies_to_usecs(ca_seq_rtt);
-			}
+		if (ca_ops->pkts_acked)
+			ca_ops->pkts_acked(sk, pkts_acked, ca_seq_rtt_us);
 
-			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
-		}
 	} else if (skb && rtt_update && sack_rtt >= 0 &&
 		   sack_rtt > (s32)(now - TCP_SKB_CB(skb)->when)) {
 		/* Do not re-arm RTO if the sack RTT is measured from data sent
@@ -3369,7 +3356,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 	bool is_dupack = false;
-	u32 prior_in_flight, prior_cwnd = tp->snd_cwnd, prior_rtt = tp->srtt;
+	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets = tp->packets_out;
 	const int prior_unsacked = tp->packets_out - tp->sacked_out;
@@ -3474,8 +3461,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
 		tcp_schedule_loss_probe(sk);
-	if (tp->srtt != prior_rtt || tp->snd_cwnd != prior_cwnd)
-		tcp_update_pacing_rate(sk);
+	tcp_update_pacing_rate(sk);
 	return 1;
 
 no_queue:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3cf976510497..17c0fb172fba 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -435,7 +435,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 			break;
 
 		icsk->icsk_backoff--;
-		inet_csk(sk)->icsk_rto = (tp->srtt ? __tcp_set_rto(tp) :
+		inet_csk(sk)->icsk_rto = (tp->srtt_us ? __tcp_set_rto(tp) :
 			TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
 		tcp_bound_rto(sk);
 
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 503798f2fcd6..c9aecae31327 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -315,7 +315,6 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
 }
 
 static struct tcp_congestion_ops tcp_lp __read_mostly = {
-	.flags = TCP_CONG_RTT_STAMP,
 	.init = tcp_lp_init,
 	.ssthresh = tcp_reno_ssthresh,
 	.cong_avoid = tcp_lp_cong_avoid,
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index d547075d8300..1fc8d2465c48 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -33,6 +33,11 @@ struct tcp_fastopen_metrics {
 	struct	tcp_fastopen_cookie	cookie;
 };
 
+/* TCP_METRIC_MAX includes 2 extra fields for userspace compatibility
+ * Kernel only stores RTT and RTTVAR in usec resolution
+ */
+#define TCP_METRIC_MAX_KERNEL (TCP_METRIC_MAX - 2)
+
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
 	struct inetpeer_addr		tcpm_saddr;
@@ -41,7 +46,7 @@ struct tcp_metrics_block {
 	u32				tcpm_ts;
 	u32				tcpm_ts_stamp;
 	u32				tcpm_lock;
-	u32				tcpm_vals[TCP_METRIC_MAX + 1];
+	u32				tcpm_vals[TCP_METRIC_MAX_KERNEL + 1];
 	struct tcp_fastopen_metrics	tcpm_fastopen;
 
 	struct rcu_head			rcu_head;
@@ -59,12 +64,6 @@ static u32 tcp_metric_get(struct tcp_metrics_block *tm,
 	return tm->tcpm_vals[idx];
 }
 
-static u32 tcp_metric_get_jiffies(struct tcp_metrics_block *tm,
-				  enum tcp_metric_index idx)
-{
-	return msecs_to_jiffies(tm->tcpm_vals[idx]);
-}
-
 static void tcp_metric_set(struct tcp_metrics_block *tm,
 			   enum tcp_metric_index idx,
 			   u32 val)
@@ -72,13 +71,6 @@ static void tcp_metric_set(struct tcp_metrics_block *tm,
 	tm->tcpm_vals[idx] = val;
 }
 
-static void tcp_metric_set_msecs(struct tcp_metrics_block *tm,
-				 enum tcp_metric_index idx,
-				 u32 val)
-{
-	tm->tcpm_vals[idx] = jiffies_to_msecs(val);
-}
-
 static bool addr_same(const struct inetpeer_addr *a,
 		      const struct inetpeer_addr *b)
 {
@@ -384,7 +376,7 @@ void tcp_update_metrics(struct sock *sk)
 		dst_confirm(dst);
 
 	rcu_read_lock();
-	if (icsk->icsk_backoff || !tp->srtt) {
+	if (icsk->icsk_backoff || !tp->srtt_us) {
 		/* This session failed to estimate rtt. Why?
 		 * Probably, no packets returned in time.  Reset our
 		 * results.
@@ -399,8 +391,8 @@ void tcp_update_metrics(struct sock *sk)
 	if (!tm)
 		goto out_unlock;
 
-	rtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
-	m = rtt - tp->srtt;
+	rtt = tcp_metric_get(tm, TCP_METRIC_RTT);
+	m = rtt - tp->srtt_us;
 
 	/* If newly calculated rtt larger than stored one, store new
 	 * one. Otherwise, use EWMA. Remember, rtt overestimation is
@@ -408,10 +400,10 @@ void tcp_update_metrics(struct sock *sk)
 	 */
 	if (!tcp_metric_locked(tm, TCP_METRIC_RTT)) {
 		if (m <= 0)
-			rtt = tp->srtt;
+			rtt = tp->srtt_us;
 		else
 			rtt -= (m >> 3);
-		tcp_metric_set_msecs(tm, TCP_METRIC_RTT, rtt);
+		tcp_metric_set(tm, TCP_METRIC_RTT, rtt);
 	}
 
 	if (!tcp_metric_locked(tm, TCP_METRIC_RTTVAR)) {
@@ -422,16 +414,16 @@ void tcp_update_metrics(struct sock *sk)
 
 		/* Scale deviation to rttvar fixed point */
 		m >>= 1;
-		if (m < tp->mdev)
-			m = tp->mdev;
+		if (m < tp->mdev_us)
+			m = tp->mdev_us;
 
-		var = tcp_metric_get_jiffies(tm, TCP_METRIC_RTTVAR);
+		var = tcp_metric_get(tm, TCP_METRIC_RTTVAR);
 		if (m >= var)
 			var = m;
 		else
 			var -= (var - m) >> 2;
 
-		tcp_metric_set_msecs(tm, TCP_METRIC_RTTVAR, var);
+		tcp_metric_set(tm, TCP_METRIC_RTTVAR, var);
 	}
 
 	if (tcp_in_initial_slowstart(tp)) {
@@ -528,7 +520,7 @@ void tcp_init_metrics(struct sock *sk)
 		tp->reordering = val;
 	}
 
-	crtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
+	crtt = tcp_metric_get(tm, TCP_METRIC_RTT);
 	rcu_read_unlock();
 reset:
 	/* The initial RTT measurement from the SYN/SYN-ACK is not ideal
@@ -551,18 +543,20 @@ reset:
 	 * to low value, and then abruptly stops to do it and starts to delay
 	 * ACKs, wait for troubles.
 	 */
-	if (crtt > tp->srtt) {
+	if (crtt > tp->srtt_us) {
 		/* Set RTO like tcp_rtt_estimator(), but from cached RTT. */
 		crtt >>= 3;
-		inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));
-	} else if (tp->srtt == 0) {
+		inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min_us(sk));
+	} else if (tp->srtt_us == 0) {
 		/* RFC6298: 5.7 We've failed to get a valid RTT sample from
 		 * 3WHS. This is most likely due to retransmission,
 		 * including spurious one. Reset the RTO back to 3secs
 		 * from the more aggressive 1sec to avoid more spurious
 		 * retransmission.
 		 */
-		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_FALLBACK;
+		tp->rttvar_us = jiffies_to_usecs(TCP_TIMEOUT_FALLBACK);
+		tp->mdev_us = tp->mdev_max_us = tp->rttvar_us;
+
 		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_FALLBACK;
 	}
 	/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has been
@@ -809,10 +803,26 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 		nest = nla_nest_start(msg, TCP_METRICS_ATTR_VALS);
 		if (!nest)
 			goto nla_put_failure;
-		for (i = 0; i < TCP_METRIC_MAX + 1; i++) {
-			if (!tm->tcpm_vals[i])
+		for (i = 0; i < TCP_METRIC_MAX_KERNEL + 1; i++) {
+			u32 val = tm->tcpm_vals[i];
+
+			if (!val)
 				continue;
-			if (nla_put_u32(msg, i + 1, tm->tcpm_vals[i]) < 0)
+			if (i == TCP_METRIC_RTT) {
+				if (nla_put_u32(msg, TCP_METRIC_RTT_US + 1,
+						val) < 0)
+					goto nla_put_failure;
+				n++;
+				val = max(val / 1000, 1U);
+			}
+			if (i == TCP_METRIC_RTTVAR) {
+				if (nla_put_u32(msg, TCP_METRIC_RTTVAR_US + 1,
+						val) < 0)
+					goto nla_put_failure;
+				n++;
+				val = max(val / 1000, 1U);
+			}
+			if (nla_put_u32(msg, i + 1, val) < 0)
 				goto nla_put_failure;
 			n++;
 		}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 7a436c517e44..ca788ada5bd3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -398,8 +398,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 
 		tcp_init_wl(newtp, treq->rcv_isn);
 
-		newtp->srtt = 0;
-		newtp->mdev = TCP_TIMEOUT_INIT;
+		newtp->srtt_us = 0;
+		newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
 
 		newtp->packets_out = 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 21e8a9f33287..6d115fc111e0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -856,11 +856,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (clone_it) {
 		const struct sk_buff *fclone = skb + 1;
 
-		/* If congestion control is doing timestamping, we must
-		 * take such a timestamp before we potentially clone/copy.
-		 */
-		if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
-			__net_timestamp(skb);
+		__net_timestamp(skb);
 
 		if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
 			     fclone->fclone == SKB_FCLONE_CLONE))
@@ -1964,7 +1960,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 timeout, tlp_time_stamp, rto_time_stamp;
-	u32 rtt = tp->srtt >> 3;
+	u32 rtt = usecs_to_jiffies(tp->srtt_us >> 3);
 
 	if (WARN_ON(icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS))
 		return false;
@@ -1986,7 +1982,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	/* Schedule a loss probe in 2*RTT for SACK capable connections
 	 * in Open state, that are either limited by cwnd or application.
 	 */
-	if (sysctl_tcp_early_retrans < 3 || !tp->srtt || !tp->packets_out ||
+	if (sysctl_tcp_early_retrans < 3 || !tp->srtt_us || !tp->packets_out ||
 	    !tcp_is_sack(tp) || inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
 		return false;
 
@@ -3040,8 +3036,8 @@ void tcp_send_delayed_ack(struct sock *sk)
 		 * Do not use inet_csk(sk)->icsk_rto here, use results of rtt measurements
 		 * directly.
 		 */
-		if (tp->srtt) {
-			int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
+		if (tp->srtt_us) {
+			int rtt = max(usecs_to_jiffies(tp->srtt_us >> 3), TCP_DELACK_MIN);
 
 			if (rtt < max_ato)
 				max_ato = rtt;
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 1f2d37613c9e..3b66610d4156 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -154,7 +154,7 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			p->snd_wnd = tp->snd_wnd;
 			p->rcv_wnd = tp->rcv_wnd;
 			p->ssthresh = tcp_current_ssthresh(sk);
-			p->srtt = tp->srtt >> 3;
+			p->srtt = tp->srtt_us >> 3;
 
 			tcp_probe.head = (tcp_probe.head + 1) & (bufsize - 1);
 		}
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index a022c17c9cf1..48539fff6357 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -306,7 +306,6 @@ void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 
 static struct tcp_congestion_ops tcp_vegas __read_mostly = {
-	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_vegas_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_vegas_cong_avoid,
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 326475a94865..1b8e28fcd7e1 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -203,7 +203,6 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 }
 
 static struct tcp_congestion_ops tcp_veno __read_mostly = {
-	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
 	.cong_avoid	= tcp_veno_cong_avoid,
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 8eab02030ed0..5ede0e727945 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -227,7 +227,6 @@ static u32 tcp_yeah_ssthresh(struct sock *sk) {
 }
 
 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
-	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
 	.cong_avoid	= tcp_yeah_cong_avoid,
