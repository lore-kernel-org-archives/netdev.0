From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: RTT metrics scaling
Date: Fri, 18 Jul 2008 20:34:31 -0700
Message-ID: <20080718203431.48e16ff0@extreme>
References: <20080620162234.1c2103ee@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59399 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704AbYGSDef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 23:34:35 -0400
In-Reply-To: <20080620162234.1c2103ee@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the metrics (RTT, RTTVAR and RTAX_RTO_MIN) are stored in kernel
units (jiffies) and this leaks out through the netlink API to user space
where the units for jiffies are unknown.

This patches changes the kernel to convert to/from milliseconds. This changes
the ABI, but milliseconds seemed like the most natural unit for these parameters.
Values available via syscall in /proc/net/rt_cache and netlink will be in milliseconds.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/dst.h    |   14 +++++++++++++-
 net/ipv4/tcp_input.c |   31 ++++++++++++++++++-------------
 2 files changed, 31 insertions(+), 14 deletions(-)

--- a/include/net/dst.h	2008-07-18 20:30:22.000000000 -0700
+++ b/include/net/dst.h	2008-07-18 20:30:40.000000000 -0700
@@ -128,6 +128,18 @@ static inline u32 dst_mtu(const struct d
 	return mtu;
 }
 
+/* RTT metrics are stored in milliseconds for user ABI, but used as jiffies */
+static inline unsigned long dst_metric_rtt(const struct dst_entry *dst, int metric)
+{
+	return msecs_to_jiffies(dst_metric(dst, metric));
+}
+
+static inline void set_dst_metric_rtt(struct dst_entry *dst, int metric,
+				      unsigned long rtt)
+{
+	dst->metrics[metric-1] = jiffies_to_msecs(rtt);
+}
+
 static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {

--- a/net/ipv4/tcp_input.c	2008-07-18 20:30:22.000000000 -0700
+++ b/net/ipv4/tcp_input.c	2008-07-18 20:30:27.000000000 -0700
@@ -602,7 +602,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	u32 rto_min = TCP_RTO_MIN;
 
 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min = dst_metric(dst, RTAX_RTO_MIN);
+		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
 	return rto_min;
 }
 
@@ -729,6 +729,7 @@ void tcp_update_metrics(struct sock *sk)
 	if (dst && (dst->flags & DST_HOST)) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 		int m;
+		unsigned long rtt;
 
 		if (icsk->icsk_backoff || !tp->srtt) {
 			/* This session failed to estimate rtt. Why?
@@ -740,7 +741,8 @@ void tcp_update_metrics(struct sock *sk)
 			return;
 		}
 
-		m = dst_metric(dst, RTAX_RTT) - tp->srtt;
+		rtt = dst_metric_rtt(dst, RTAX_RTT);
+		m = rtt - tp->srtt;
 
 		/* If newly calculated rtt larger than stored one,
 		 * store new one. Otherwise, use EWMA. Remember,
@@ -748,12 +750,13 @@ void tcp_update_metrics(struct sock *sk)
 		 */
 		if (!(dst_metric_locked(dst, RTAX_RTT))) {
 			if (m <= 0)
-				dst->metrics[RTAX_RTT - 1] = tp->srtt;
+				set_dst_metric_rtt(dst, RTAX_RTT, tp->srtt);
 			else
-				dst->metrics[RTAX_RTT - 1] -= (m >> 3);
+				set_dst_metric_rtt(dst, RTAX_RTT, rtt - (m >> 3));
 		}
 
 		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
+			unsigned long var;
 			if (m < 0)
 				m = -m;
 
@@ -762,11 +765,13 @@ void tcp_update_metrics(struct sock *sk)
 			if (m < tp->mdev)
 				m = tp->mdev;
 
-			if (m >= dst_metric(dst, RTAX_RTTVAR))
-				dst->metrics[RTAX_RTTVAR - 1] = m;
+			var = dst_metric_rtt(dst, RTAX_RTTVAR);
+			if (m >= var)
+				var = m;
 			else
-				dst->metrics[RTAX_RTTVAR-1] -=
-					(dst_metric(dst, RTAX_RTTVAR) - m)>>2;
+				var -= (var - m) >> 2;
+
+			set_dst_metric_rtt(dst, RTAX_RTTVAR, var);
 		}
 
 		if (tp->snd_ssthresh >= 0xFFFF) {
@@ -897,7 +902,7 @@ static void tcp_init_metrics(struct sock
 	if (dst_metric(dst, RTAX_RTT) == 0)
 		goto reset;
 
-	if (!tp->srtt && dst_metric(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -914,12 +919,12 @@ static void tcp_init_metrics(struct sock
 	 * to low value, and then abruptly stops to do it and starts to delay
 	 * ACKs, wait for troubles.
 	 */
-	if (dst_metric(dst, RTAX_RTT) > tp->srtt) {
-		tp->srtt = dst_metric(dst, RTAX_RTT);
+	if (dst_metric_rtt(dst, RTAX_RTT) > tp->srtt) {
+		tp->srtt = dst_metric_rtt(dst, RTAX_RTT);
 		tp->rtt_seq = tp->snd_nxt;
 	}
-	if (dst_metric(dst, RTAX_RTTVAR) > tp->mdev) {
-		tp->mdev = dst_metric(dst, RTAX_RTTVAR);
+	if (dst_metric_rtt(dst, RTAX_RTTVAR) > tp->mdev) {
+		tp->mdev = dst_metric_rtt(dst, RTAX_RTTVAR);
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);

