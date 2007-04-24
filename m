From: Stephen Hemminger <shemminger@linux-founsation.org>
Subject: [PATCH 3/4] tcp: congestion control API update
Date: Mon, 23 Apr 2007 20:31:20 -0700
Message-ID: <20070424033317.129630701@linux-foundation.org>
References: <20070424033117.873984872@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:49113 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161568AbXDXDgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 23:36:18 -0400
Content-Disposition: inline; filename=tcp-cong-api-update.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do some simple changes to make congestion control API faster/cleaner.
* use ktime_t rather than timeval
* merge rtt sampling into existing ack callback
  this means one indirect call versus two per ack.
* use flags bits to store options/settings

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 include/linux/skbuff.h  |    5 +++++
 include/net/tcp.h       |    9 +++++----
 net/ipv4/tcp_bic.c      |    2 +-
 net/ipv4/tcp_cong.c     |   14 +++++++-------
 net/ipv4/tcp_cubic.c    |    2 +-
 net/ipv4/tcp_htcp.c     |    2 +-
 net/ipv4/tcp_illinois.c |   16 +++++++---------
 net/ipv4/tcp_input.c    |   25 ++++++++-----------------
 net/ipv4/tcp_lp.c       |    8 +++++---
 net/ipv4/tcp_output.c   |    2 +-
 net/ipv4/tcp_vegas.c    |   10 +++++++---
 net/ipv4/tcp_veno.c     |   10 +++++++---
 net/ipv4/tcp_westwood.c |    2 +-
 net/ipv4/tcp_yeah.c     |    6 ++++--
 net/ipv4/tcp_yeah.h     |    7 +++++--
 15 files changed, 65 insertions(+), 55 deletions(-)

--- net-2.6.22.orig/include/linux/skbuff.h
+++ net-2.6.22/include/linux/skbuff.h
@@ -1569,6 +1569,11 @@ static inline void __net_timestamp(struc
 	skb->tstamp = ktime_get_real();
 }
 
+static inline ktime_t net_timedelta(ktime_t t)
+{
+	return ktime_sub(ktime_get_real(), t);
+}
+
 
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
--- net-2.6.22.orig/include/net/tcp.h
+++ net-2.6.22/include/net/tcp.h
@@ -629,9 +629,12 @@ enum tcp_ca_event {
 #define TCP_CA_MAX	128
 #define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
 
+#define TCP_CONG_NON_RESTRICTED 0x1
+#define TCP_CONG_RTT_STAMP	0x2
+
 struct tcp_congestion_ops {
 	struct list_head	list;
-	int	non_restricted;
+	unsigned long flags;
 
 	/* initialize private data (optional) */
 	void (*init)(struct sock *sk);
@@ -645,8 +648,6 @@ struct tcp_congestion_ops {
 	/* do new cwnd calculation (required) */
 	void (*cong_avoid)(struct sock *sk, u32 ack,
 			   u32 rtt, u32 in_flight, int good_ack);
-	/* round trip time sample per acked packet (optional) */
-	void (*rtt_sample)(struct sock *sk, u32 usrtt);
 	/* call before changing ca_state (optional) */
 	void (*set_state)(struct sock *sk, u8 new_state);
 	/* call when cwnd event occurs (optional) */
@@ -654,7 +655,7 @@ struct tcp_congestion_ops {
 	/* new value of cwnd after loss (optional) */
 	u32  (*undo_cwnd)(struct sock *sk);
 	/* hook for packet ack accounting (optional) */
-	void (*pkts_acked)(struct sock *sk, u32 num_acked);
+	void (*pkts_acked)(struct sock *sk, u32 num_acked, ktime_t last);
 	/* get info for inet_diag (optional) */
 	void (*get_info)(struct sock *sk, u32 ext, struct sk_buff *skb);
 
--- net-2.6.22.orig/net/ipv4/tcp_bic.c
+++ net-2.6.22/net/ipv4/tcp_bic.c
@@ -206,7 +206,7 @@ static void bictcp_state(struct sock *sk
 /* Track delayed acknowledgment ratio using sliding window
  * ratio = (15*ratio + sample) / 16
  */
-static void bictcp_acked(struct sock *sk, u32 cnt)
+static void bictcp_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
--- net-2.6.22.orig/net/ipv4/tcp_cong.c
+++ net-2.6.22/net/ipv4/tcp_cong.c
@@ -126,7 +126,7 @@ int tcp_set_default_congestion_control(c
 #endif
 
 	if (ca) {
-		ca->non_restricted = 1;	/* default is always allowed */
+		ca->flags |= TCP_CONG_NON_RESTRICTED;	/* default is always allowed */
 		list_move(&ca->list, &tcp_cong_list);
 		ret = 0;
 	}
@@ -181,7 +181,7 @@ void tcp_get_allowed_congestion_control(
 	*buf = '\0';
 	rcu_read_lock();
 	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
-		if (!ca->non_restricted)
+		if (!(ca->flags & TCP_CONG_NON_RESTRICTED))
 			continue;
 		offs += snprintf(buf + offs, maxlen - offs,
 				 "%s%s",
@@ -212,16 +212,16 @@ int tcp_set_allowed_congestion_control(c
 		}
 	}
 
-	/* pass 2 clear */
+	/* pass 2 clear old values */
 	list_for_each_entry_rcu(ca, &tcp_cong_list, list)
-		ca->non_restricted = 0;
+		ca->flags &= ~TCP_CONG_NON_RESTRICTED;
 
 	/* pass 3 mark as allowed */
 	while ((name = strsep(&val, " ")) && *name) {
 		ca = tcp_ca_find(name);
 		WARN_ON(!ca);
 		if (ca)
-			ca->non_restricted = 1;
+			ca->flags |= TCP_CONG_NON_RESTRICTED;
 	}
 out:
 	spin_unlock(&tcp_cong_list_lock);
@@ -256,7 +256,7 @@ int tcp_set_congestion_control(struct so
 	if (!ca)
 		err = -ENOENT;
 
-	else if (!(ca->non_restricted || capable(CAP_NET_ADMIN)))
+	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) || capable(CAP_NET_ADMIN)))
 		err = -EPERM;
 
 	else if (!try_module_get(ca->owner))
@@ -371,8 +371,8 @@ u32 tcp_reno_min_cwnd(const struct sock 
 EXPORT_SYMBOL_GPL(tcp_reno_min_cwnd);
 
 struct tcp_congestion_ops tcp_reno = {
+	.flags		= TCP_CONG_NON_RESTRICTED,
 	.name		= "reno",
-	.non_restricted = 1,
 	.owner		= THIS_MODULE,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
--- net-2.6.22.orig/net/ipv4/tcp_cubic.c
+++ net-2.6.22/net/ipv4/tcp_cubic.c
@@ -334,7 +334,7 @@ static void bictcp_state(struct sock *sk
 /* Track delayed acknowledgment ratio using sliding window
  * ratio = (15*ratio + sample) / 16
  */
-static void bictcp_acked(struct sock *sk, u32 cnt)
+static void bictcp_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
--- net-2.6.22.orig/net/ipv4/tcp_htcp.c
+++ net-2.6.22/net/ipv4/tcp_htcp.c
@@ -98,7 +98,7 @@ static inline void measure_rtt(struct so
 	}
 }
 
-static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked)
+static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, ktime_t last)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
--- net-2.6.22.orig/net/ipv4/tcp_illinois.c
+++ net-2.6.22/net/ipv4/tcp_illinois.c
@@ -83,9 +83,14 @@ static void tcp_illinois_init(struct soc
 }
 
 /* Measure RTT for each ack. */
-static void tcp_illinois_rtt_sample(struct sock *sk, u32 rtt)
+static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 {
 	struct illinois *ca = inet_csk_ca(sk);
+	u32 rtt;
+
+	ca->acked = pkts_acked;
+
+	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
 
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
@@ -103,13 +108,6 @@ static void tcp_illinois_rtt_sample(stru
 	ca->sum_rtt += rtt;
 }
 
-/* Capture count of packets covered by ack, to adjust for delayed acks */
-static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked)
-{
-	struct illinois *ca = inet_csk_ca(sk);
-	ca->acked = pkts_acked;
-}
-
 /* Maximum queuing delay */
 static inline u32 max_delay(const struct illinois *ca)
 {
@@ -325,12 +323,12 @@ static void tcp_illinois_info(struct soc
 }
 
 static struct tcp_congestion_ops tcp_illinois = {
+	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
 	.min_cwnd	= tcp_reno_min_cwnd,
 	.cong_avoid	= tcp_illinois_cong_avoid,
 	.set_state	= tcp_illinois_state,
-	.rtt_sample	= tcp_illinois_rtt_sample,
 	.get_info	= tcp_illinois_info,
 	.pkts_acked	= tcp_illinois_acked,
 
--- net-2.6.22.orig/net/ipv4/tcp_input.c
+++ net-2.6.22/net/ipv4/tcp_input.c
@@ -2402,14 +2402,6 @@ static int tcp_tso_acked(struct sock *sk
 	return acked;
 }
 
-static u32 tcp_usrtt(struct timeval *tv)
-{
-	struct timeval now;
-
-	do_gettimeofday(&now);
-	return (now.tv_sec - tv->tv_sec) * 1000000 + (now.tv_usec - tv->tv_usec);
-}
-
 /* Remove acknowledged frames from the retransmission queue. */
 static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
@@ -2420,9 +2412,7 @@ static int tcp_clean_rtx_queue(struct so
 	int acked = 0;
 	__s32 seq_rtt = -1;
 	u32 pkts_acked = 0;
-	void (*rtt_sample)(struct sock *sk, u32 usrtt)
-		= icsk->icsk_ca_ops->rtt_sample;
-	struct timeval tv = { .tv_sec = 0, .tv_usec = 0 };
+	ktime_t last_ackt = ktime_set(0,0);
 
 	while ((skb = tcp_write_queue_head(sk)) &&
 	       skb != tcp_send_head(sk)) {
@@ -2471,7 +2461,7 @@ static int tcp_clean_rtx_queue(struct so
 				seq_rtt = -1;
 			} else if (seq_rtt < 0) {
 				seq_rtt = now - scb->when;
-				skb_get_timestamp(skb, &tv);
+				last_ackt = skb->tstamp;
 			}
 			if (sacked & TCPCB_SACKED_ACKED)
 				tp->sacked_out -= tcp_skb_pcount(skb);
@@ -2484,7 +2474,7 @@ static int tcp_clean_rtx_queue(struct so
 			}
 		} else if (seq_rtt < 0) {
 			seq_rtt = now - scb->when;
-			skb_get_timestamp(skb, &tv);
+			last_ackt = skb->tstamp;
 		}
 		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tcp_packets_out_dec(tp, skb);
@@ -2494,13 +2484,14 @@ static int tcp_clean_rtx_queue(struct so
 	}
 
 	if (acked&FLAG_ACKED) {
+		const struct tcp_congestion_ops *ca_ops
+			= inet_csk(sk)->icsk_ca_ops;
+
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk);
-		if (rtt_sample && !(acked & FLAG_RETRANS_DATA_ACKED))
-			(*rtt_sample)(sk, tcp_usrtt(&tv));
 
-		if (icsk->icsk_ca_ops->pkts_acked)
-			icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked);
+		if (ca_ops->pkts_acked)
+			ca_ops->pkts_acked(sk, pkts_acked, last_ackt);
 	}
 
 #if FASTRETRANS_DEBUG > 0
--- net-2.6.22.orig/net/ipv4/tcp_lp.c
+++ net-2.6.22/net/ipv4/tcp_lp.c
@@ -218,7 +218,7 @@ static u32 tcp_lp_owd_calculator(struct 
  *   3. calc smoothed OWD (SOWD).
  * Most ideas come from the original TCP-LP implementation.
  */
-static void tcp_lp_rtt_sample(struct sock *sk, u32 usrtt)
+static void tcp_lp_rtt_sample(struct sock *sk, u32 rtt)
 {
 	struct lp *lp = inet_csk_ca(sk);
 	s64 mowd = tcp_lp_owd_calculator(sk);
@@ -261,11 +261,13 @@ static void tcp_lp_rtt_sample(struct soc
  * newReno in increase case.
  * We work it out by following the idea from TCP-LP's paper directly
  */
-static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked)
+static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
 
+	tcp_lp_rtt_sample(sk,  ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC);
+
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
 		lp->inference = 3 * (tcp_time_stamp - tp->rx_opt.rcv_tsecr);
@@ -312,11 +314,11 @@ static void tcp_lp_pkts_acked(struct soc
 }
 
 static struct tcp_congestion_ops tcp_lp = {
+	.flags = TCP_CONG_RTT_STAMP,
 	.init = tcp_lp_init,
 	.ssthresh = tcp_reno_ssthresh,
 	.cong_avoid = tcp_lp_cong_avoid,
 	.min_cwnd = tcp_reno_min_cwnd,
-	.rtt_sample = tcp_lp_rtt_sample,
 	.pkts_acked = tcp_lp_pkts_acked,
 
 	.owner = THIS_MODULE,
--- net-2.6.22.orig/net/ipv4/tcp_output.c
+++ net-2.6.22/net/ipv4/tcp_output.c
@@ -409,7 +409,7 @@ static int tcp_transmit_skb(struct sock 
 	/* If congestion control is doing timestamping, we must
 	 * take such a timestamp before we potentially clone/copy.
 	 */
-	if (icsk->icsk_ca_ops->rtt_sample)
+	if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
 		__net_timestamp(skb);
 
 	if (likely(clone_it)) {
--- net-2.6.22.orig/net/ipv4/tcp_vegas.c
+++ net-2.6.22/net/ipv4/tcp_vegas.c
@@ -120,10 +120,13 @@ static void tcp_vegas_init(struct sock *
  *   o min-filter RTT samples from a much longer window (forever for now)
  *     to find the propagation delay (baseRTT)
  */
-static void tcp_vegas_rtt_calc(struct sock *sk, u32 usrtt)
+static void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
-	u32 vrtt = usrtt + 1; /* Never allow zero rtt or baseRTT */
+	u32 vrtt;
+
+	/* Never allow zero rtt or baseRTT */
+	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
@@ -353,11 +356,12 @@ static void tcp_vegas_get_info(struct so
 }
 
 static struct tcp_congestion_ops tcp_vegas = {
+	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_vegas_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_vegas_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
-	.rtt_sample	= tcp_vegas_rtt_calc,
+	.pkts_acked	= tcp_vegas_pkts_acked,
 	.set_state	= tcp_vegas_state,
 	.cwnd_event	= tcp_vegas_cwnd_event,
 	.get_info	= tcp_vegas_get_info,
--- net-2.6.22.orig/net/ipv4/tcp_veno.c
+++ net-2.6.22/net/ipv4/tcp_veno.c
@@ -69,10 +69,13 @@ static void tcp_veno_init(struct sock *s
 }
 
 /* Do rtt sampling needed for Veno. */
-static void tcp_veno_rtt_calc(struct sock *sk, u32 usrtt)
+static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct veno *veno = inet_csk_ca(sk);
-	u32 vrtt = usrtt + 1;	/* Never allow zero rtt or basertt */
+	u32 vrtt;
+
+	/* Never allow zero rtt or baseRTT */
+	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)
@@ -199,10 +202,11 @@ static u32 tcp_veno_ssthresh(struct sock
 }
 
 static struct tcp_congestion_ops tcp_veno = {
+	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
 	.cong_avoid	= tcp_veno_cong_avoid,
-	.rtt_sample	= tcp_veno_rtt_calc,
+	.pkts_acked	= tcp_veno_pkts_acked,
 	.set_state	= tcp_veno_state,
 	.cwnd_event	= tcp_veno_cwnd_event,
 
--- net-2.6.22.orig/net/ipv4/tcp_westwood.c
+++ net-2.6.22/net/ipv4/tcp_westwood.c
@@ -100,7 +100,7 @@ static void westwood_filter(struct westw
  * Called after processing group of packets.
  * but all westwood needs is the last sample of srtt.
  */
-static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt)
+static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct westwood *w = inet_csk_ca(sk);
 	if (cnt > 0)
--- net-2.6.22.orig/net/ipv4/tcp_yeah.c
+++ net-2.6.22/net/ipv4/tcp_yeah.c
@@ -64,13 +64,15 @@ static void tcp_yeah_init(struct sock *s
 }
 
 
-static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked)
+static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
 
 	if (icsk->icsk_ca_state == TCP_CA_Open)
 		yeah->pkts_acked = pkts_acked;
+
+	tcp_vegas_pkts_acked(sk, pkts_acked, last);
 }
 
 static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
@@ -237,11 +239,11 @@ static u32 tcp_yeah_ssthresh(struct sock
 }
 
 static struct tcp_congestion_ops tcp_yeah = {
+	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
 	.cong_avoid	= tcp_yeah_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
-	.rtt_sample	= tcp_vegas_rtt_calc,
 	.set_state	= tcp_vegas_state,
 	.cwnd_event	= tcp_vegas_cwnd_event,
 	.get_info	= tcp_vegas_get_info,
--- net-2.6.22.orig/net/ipv4/tcp_yeah.h
+++ net-2.6.22/net/ipv4/tcp_yeah.h
@@ -81,10 +81,13 @@ static void tcp_vegas_state(struct sock 
  *   o min-filter RTT samples from a much longer window (forever for now)
  *     to find the propagation delay (baseRTT)
  */
-static void tcp_vegas_rtt_calc(struct sock *sk, u32 usrtt)
+static void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
-	u32 vrtt = usrtt + 1; /* Never allow zero rtt or baseRTT */
+	u32 vrtt;
+
+	/* Never allow zero rtt or baseRTT */
+	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)

-- 

