From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 2/3] TCP: cubic - eliminate use of receive time stamp
Date: Thu, 19 Jul 2007 08:41:31 +0100
Message-ID: <20070719074906.634042117@linux-foundation.org>
References: <20070719074129.670215301@linux-foundation.org>
Cc: Sangtae Ha <sha2@ncsu.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932602AbXGSIYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:24:36 -0400
Cc: Luca De Cicco <ldecicco@gmail.com>
Cc: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Cc: netdev@vger.kernel.org
Content-Disposition: inline; filename=tcp-cubic-rtt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove use of received timestamp option value from RTT calculation in Cubic.
A hostile receiver may be returning a larger timestamp option than the original
value. This would cause the sender to believe the malevolent receiver had
a larger RTT and because Cubic tries to provide some RTT friendliness, the
sender would then favor the liar.

Instead, use the jiffie resolutionRTT value already computed and
passed back after ack.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_cubic.c	2007-07-19 08:21:42.000000000 +0100
+++ b/net/ipv4/tcp_cubic.c	2007-07-19 08:24:58.000000000 +0100
@@ -246,38 +246,12 @@ static inline void bictcp_update(struct 
 		ca->cnt = 1;
 }
 
-
-/* Keep track of minimum rtt */
-static inline void measure_delay(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	struct bictcp *ca = inet_csk_ca(sk);
-	u32 delay;
-
-	/* No time stamp */
-	if (!(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr) ||
-	     /* Discard delay samples right after fast recovery */
-	    (s32)(tcp_time_stamp - ca->epoch_start) < HZ)
-		return;
-
-	delay = (tcp_time_stamp - tp->rx_opt.rcv_tsecr)<<3;
-	if (delay == 0)
-		delay = 1;
-
-	/* first time call or link delay decreases */
-	if (ca->delay_min == 0 || ca->delay_min > delay)
-		ca->delay_min = delay;
-}
-
 static void bictcp_cong_avoid(struct sock *sk, u32 ack,
 			      u32 seq_rtt, u32 in_flight, int data_acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	if (data_acked)
-		measure_delay(sk);
-
 	if (!tcp_is_cwnd_limited(sk, in_flight))
 		return;
 
@@ -337,14 +311,30 @@ static void bictcp_state(struct sock *sk
 static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct bictcp *ca = inet_csk_ca(sk);
+	u32 delay;
 
 	if (cnt > 0 && icsk->icsk_ca_state == TCP_CA_Open) {
-		struct bictcp *ca = inet_csk_ca(sk);
 		cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
 		ca->delayed_ack += cnt;
 	}
-}
 
+	/* Some calls are for duplicates without timetamps */
+	if (rtt_us < 0)
+		return;
+
+	/* Discard delay samples right after fast recovery */
+	if ((s32)(tcp_time_stamp - ca->epoch_start) < HZ)
+		return;
+
+	delay = usecs_to_jiffies(rtt_us) << 3;
+	if (delay == 0)
+		delay = 1;
+
+	/* first time call or link delay decreases */
+	if (ca->delay_min == 0 || ca->delay_min > delay)
+		ca->delay_min = delay;
+}
 
 static struct tcp_congestion_ops cubictcp = {
 	.init		= bictcp_init,

-- 

