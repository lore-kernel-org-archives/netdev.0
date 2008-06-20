From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] RTT metrics scaling
Date: Fri, 20 Jun 2008 16:22:34 -0700
Message-ID: <20080620162234.1c2103ee@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53558 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756684AbYFTXWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 19:22:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the metrics (RTT, RTTVAR and RTAX_RTO_MIN) are stored in kernel
units (jiffies) and this leaks out through the netlink API to user space
where the units for jiffies are unknown.

This patches changes the kernel to convert to/from milliseconds. This changes
the ABI, but milliseconds seemed like the most natural unit for these parameters.

This patch is for comment only, just to show how it would be implemented.
I will update it after testing more.

--- a/include/net/dst.h	2008-06-20 15:34:00.000000000 -0700
+++ b/include/net/dst.h	2008-06-20 15:50:20.000000000 -0700
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
--- a/net/ipv4/tcp_input.c	2008-06-20 15:41:40.000000000 -0700
+++ b/net/ipv4/tcp_input.c	2008-06-20 15:48:31.000000000 -0700
@@ -602,7 +602,7 @@ static u32 tcp_rto_min(struct sock *sk)
 	u32 rto_min = TCP_RTO_MIN;
 
 	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
-		rto_min = dst_metric(dst, RTAX_RTO_MIN);
+		rto_min = dst_metric_rtt(dst, RTAX_RTO_MIN);
 	return rto_min;
 }
 
@@ -740,18 +740,15 @@ void tcp_update_metrics(struct sock *sk)
 			return;
 		}
 
-		m = dst_metric(dst, RTAX_RTT) - tp->srtt;
+		m = dst_metric_rtt(dst, RTAX_RTT) - tp->srtt;
 
 		/* If newly calculated rtt larger than stored one,
 		 * store new one. Otherwise, use EWMA. Remember,
 		 * rtt overestimation is always better than underestimation.
 		 */
-		if (!(dst_metric_locked(dst, RTAX_RTT))) {
-			if (m <= 0)
-				dst->metrics[RTAX_RTT - 1] = tp->srtt;
-			else
-				dst->metrics[RTAX_RTT - 1] -= (m >> 3);
-		}
+		if (!(dst_metric_locked(dst, RTAX_RTT)))
+			set_dst_metric_rtt(dst, RTAX_RTT,
+					   m <= 0 ? tp->srtt : (m >>3));
 
 		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
 			if (m < 0)
@@ -762,11 +759,10 @@ void tcp_update_metrics(struct sock *sk)
 			if (m < tp->mdev)
 				m = tp->mdev;
 
-			if (m >= dst_metric(dst, RTAX_RTTVAR))
-				dst->metrics[RTAX_RTTVAR - 1] = m;
-			else
-				dst->metrics[RTAX_RTTVAR-1] -=
-					(dst_metric(dst, RTAX_RTTVAR) - m)>>2;
+			set_dst_metric(dst, RTAX_RTTVAR,
+				       (m >= dst_metric_rtt(dst, RTAX_RTTVAR))
+				       ? m
+				       : (dst_metric(dst, RTAX_RTTVAR) - m)>>2);
 		}
 
 		if (tp->snd_ssthresh >= 0xFFFF) {
@@ -897,7 +893,7 @@ static void tcp_init_metrics(struct sock
 	if (dst_metric(dst, RTAX_RTT) == 0)
 		goto reset;
 
-	if (!tp->srtt && dst_metric(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -914,12 +910,12 @@ static void tcp_init_metrics(struct sock
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
