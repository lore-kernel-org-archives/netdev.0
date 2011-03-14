From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/7] tcp_cubic: fix clock dependency
Date: Mon, 14 Mar 2011 10:52:15 -0700
Message-ID: <20110314175439.564307922@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58246 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757052Ab1CNSCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:03 -0400
Content-Disposition: inline; filename=tcp-cubic-minrtt.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hystart code was written with assumption that HZ=1000.
Replace the use of jiffies with bictcp_clock as a millisecond
real time clock. 

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>

--- a/net/ipv4/tcp_cubic.c	2011-03-14 08:19:18.000000000 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-03-14 08:22:42.486690594 -0700
@@ -88,7 +88,7 @@ struct bictcp {
 	u32	last_time;	/* time when updated last_cwnd */
 	u32	bic_origin_point;/* origin point of bic function */
 	u32	bic_K;		/* time to origin point from the beginning of the current epoch */
-	u32	delay_min;	/* min delay */
+	u32	delay_min;	/* min delay (msec << 3) */
 	u32	epoch_start;	/* beginning of an epoch */
 	u32	ack_cnt;	/* number of acks */
 	u32	tcp_cwnd;	/* estimated tcp cwnd */
@@ -98,7 +98,7 @@ struct bictcp {
 	u8	found;		/* the exit point is found? */
 	u32	round_start;	/* beginning of each round */
 	u32	end_seq;	/* end_seq of the round */
-	u32	last_jiffies;	/* last time when the ACK spacing is close */
+	u32	last_ack;	/* last time when the ACK spacing is close */
 	u32	curr_rtt;	/* the minimum rtt of current round */
 };
 
@@ -119,12 +119,21 @@ static inline void bictcp_reset(struct b
 	ca->found = 0;
 }
 
+static inline u32 bictcp_clock(void)
+{
+#if HZ < 1000
+	return ktime_to_ms(ktime_get_real());
+#else
+	return jiffies_to_msecs(jiffies);
+#endif
+}
+
 static inline void bictcp_hystart_reset(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	ca->round_start = ca->last_jiffies = jiffies;
+	ca->round_start = ca->last_ack = bictcp_clock();
 	ca->end_seq = tp->snd_nxt;
 	ca->curr_rtt = 0;
 	ca->sample_cnt = 0;
@@ -239,8 +248,8 @@ static inline void bictcp_update(struct
 	 */
 
 	/* change the unit from HZ to bictcp_HZ */
-	t = ((tcp_time_stamp + (ca->delay_min>>3) - ca->epoch_start)
-	     << BICTCP_HZ) / HZ;
+	t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3)
+	      - ca->epoch_start) << BICTCP_HZ) / HZ;
 
 	if (t < ca->bic_K)		/* t - K */
 		offs = ca->bic_K - t;
@@ -342,14 +351,12 @@ static void hystart_update(struct sock *
 	struct bictcp *ca = inet_csk_ca(sk);
 
 	if (!(ca->found & hystart_detect)) {
-		u32 curr_jiffies = jiffies;
+		u32 now = bictcp_clock();
 
 		/* first detection parameter - ack-train detection */
-		if ((s32)(curr_jiffies - ca->last_jiffies) <=
-		    msecs_to_jiffies(hystart_ack_delta)) {
-			ca->last_jiffies = curr_jiffies;
-			if ((s32) (curr_jiffies - ca->round_start) >
-			    ca->delay_min >> 4)
+		if ((s32)(now - ca->last_ack) <= hystart_ack_delta) {
+			ca->last_ack = now;
+			if ((s32)(now - ca->round_start) > ca->delay_min >> 4)
 				ca->found |= HYSTART_ACK_TRAIN;
 		}
 
@@ -396,7 +403,7 @@ static void bictcp_acked(struct sock *sk
 	if ((s32)(tcp_time_stamp - ca->epoch_start) < HZ)
 		return;
 
-	delay = usecs_to_jiffies(rtt_us) << 3;
+	delay = (rtt_us << 3) / USEC_PER_MSEC;
 	if (delay == 0)
 		delay = 1;
 


