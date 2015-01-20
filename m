From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Mon, 19 Jan 2015 18:16:56 -0800
Message-ID: <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	 <54B590FB.5040805@dev.mellanox.co.il>
	 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
	 <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54BC286B.8000605@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:64126 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbATCQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 21:16:58 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so14960319iga.0
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 18:16:58 -0800 (PST)
In-Reply-To: <54BC286B.8000605@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-18 at 23:40 +0200, Eyal Perry wrote:

> So indeed, interrupt mitigation (tx-usecs 1 tx-frames 1) improves things up
> for the "refined TSO autosizing" kernel (from 18.4Gbps to 19.7Gbps). but
> in the
> other kernel, the BW is remains the same with and without the coalescing.

OK thanks for testing.

I believe the regression comes from inability for cc to cope with
stretch acks.

Nowadays on fast networks, each ACK packet acknowledges ~45 MSS, but
CUBIC (and others cc) got support for this only during slow start, with
commit 9f9843a751d0a2057f9f3d313886e7e5e6ebaac9
("tcp: properly handle stretch acks in slow start")

I guess it is time to also handle congestion avoidance phase.

With following patch (very close to what we use here at Google) I
reached 37Gbps instead of 20Gbps :

ethtool -C eth1 tx-usecs 4 tx-frames 4

DUMP_TCP_INFO=1 ./netperf -H remote -T2,2 -t TCP_STREAM -l 20
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to remote () port 0 AF_INET : cpu bind
rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=67 rttvar=6 snd_ssthresh=263 cwnd=265 reordering=3 total_retrans=4569 ca_state=0
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    20.00    37213.05   

I guess this is a world record, my previous one was 34Gbps.


 include/net/tcp.h    |    2 
 net/ipv4/tcp_cong.c  |    4 +
 net/ipv4/tcp_cubic.c |   91 +++++++++++++++++++----------------------
 3 files changed, 47 insertions(+), 50 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b8fdc6bab3f3..05815fbb490f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -843,7 +843,7 @@ void tcp_get_available_congestion_control(char *buf, size_t len);
 void tcp_get_allowed_congestion_control(char *buf, size_t len);
 int tcp_set_allowed_congestion_control(char *allowed);
 int tcp_set_congestion_control(struct sock *sk, const char *name);
-void tcp_slow_start(struct tcp_sock *tp, u32 acked);
+int tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
 
 u32 tcp_reno_ssthresh(struct sock *sk);
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 63c29dba68a8..f0fc696b9333 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -360,13 +360,15 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
  * ABC caps N to 2. Slow start exits when cwnd grows over ssthresh and
  * returns the leftover acks to adjust cwnd in congestion avoidance mode.
  */
-void tcp_slow_start(struct tcp_sock *tp, u32 acked)
+int tcp_slow_start(struct tcp_sock *tp, u32 acked)
 {
 	u32 cwnd = tp->snd_cwnd + acked;
 
 	if (cwnd > tp->snd_ssthresh)
 		cwnd = tp->snd_ssthresh + 1;
+	acked -= cwnd - tp->snd_cwnd;
 	tp->snd_cwnd = min(cwnd, tp->snd_cwnd_clamp);
+	return acked;
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 6b6002416a73..c0e048929b74 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -81,7 +81,6 @@ MODULE_PARM_DESC(hystart_ack_delta, "spacing between ack's indicating train (mse
 
 /* BIC TCP Parameters */
 struct bictcp {
-	u32	cnt;		/* increase cwnd by 1 after ACKs */
 	u32	last_max_cwnd;	/* last maximum snd_cwnd */
 	u32	loss_cwnd;	/* congestion window at last loss */
 	u32	last_cwnd;	/* the last snd_cwnd */
@@ -93,20 +92,18 @@ struct bictcp {
 	u32	epoch_start;	/* beginning of an epoch */
 	u32	ack_cnt;	/* number of acks */
 	u32	tcp_cwnd;	/* estimated tcp cwnd */
-#define ACK_RATIO_SHIFT	4
-#define ACK_RATIO_LIMIT (32u << ACK_RATIO_SHIFT)
-	u16	delayed_ack;	/* estimate the ratio of Packets/ACKs << 4 */
 	u8	sample_cnt;	/* number of samples to decide curr_rtt */
 	u8	found;		/* the exit point is found? */
 	u32	round_start;	/* beginning of each round */
 	u32	end_seq;	/* end_seq of the round */
 	u32	last_ack;	/* last time when the ACK spacing is close */
 	u32	curr_rtt;	/* the minimum rtt of current round */
+	u32	last_bic_target;/* last target cwnd computed by cubic
+				 * (not tcp_friendliness mode) */
 };
 
 static inline void bictcp_reset(struct bictcp *ca)
 {
-	ca->cnt = 0;
 	ca->last_max_cwnd = 0;
 	ca->last_cwnd = 0;
 	ca->last_time = 0;
@@ -114,7 +111,6 @@ static inline void bictcp_reset(struct bictcp *ca)
 	ca->bic_K = 0;
 	ca->delay_min = 0;
 	ca->epoch_start = 0;
-	ca->delayed_ack = 2 << ACK_RATIO_SHIFT;
 	ca->ack_cnt = 0;
 	ca->tcp_cwnd = 0;
 	ca->found = 0;
@@ -205,12 +201,14 @@ static u32 cubic_root(u64 a)
 /*
  * Compute congestion window to use.
  */
-static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
+static inline void bictcp_update(struct bictcp *ca, u32 pkts_acked, u32 cwnd)
 {
-	u32 delta, bic_target, max_cnt;
+	u32 delta, bic_target;
 	u64 offs, t;
 
-	ca->ack_cnt++;	/* count the number of ACKs */
+	ca->ack_cnt += pkts_acked;	/* count the number of packets that
+					 * have been ACKed
+					 */
 
 	if (ca->last_cwnd == cwnd &&
 	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
@@ -221,7 +219,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 
 	if (ca->epoch_start == 0) {
 		ca->epoch_start = tcp_time_stamp;	/* record beginning */
-		ca->ack_cnt = 1;			/* start counting */
+		ca->ack_cnt = pkts_acked;		/* start counting */
 		ca->tcp_cwnd = cwnd;			/* syn with cubic */
 
 		if (ca->last_max_cwnd <= cwnd) {
@@ -269,19 +267,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	else                                          /* above origin*/
 		bic_target = ca->bic_origin_point + delta;
 
-	/* cubic function - calc bictcp_cnt*/
-	if (bic_target > cwnd) {
-		ca->cnt = cwnd / (bic_target - cwnd);
-	} else {
-		ca->cnt = 100 * cwnd;              /* very small increment*/
-	}
-
-	/*
-	 * The initial growth of cubic function may be too conservative
-	 * when the available bandwidth is still unknown.
-	 */
-	if (ca->last_max_cwnd == 0 && ca->cnt > 20)
-		ca->cnt = 20;	/* increase cwnd 5% per RTT */
+	ca->last_bic_target = bic_target;
 
 	/* TCP Friendly */
 	if (tcp_friendliness) {
@@ -292,18 +278,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 			ca->ack_cnt -= delta;
 			ca->tcp_cwnd++;
 		}
-
-		if (ca->tcp_cwnd > cwnd) {	/* if bic is slower than tcp */
-			delta = ca->tcp_cwnd - cwnd;
-			max_cnt = cwnd / delta;
-			if (ca->cnt > max_cnt)
-				ca->cnt = max_cnt;
-		}
 	}
-
-	ca->cnt = (ca->cnt << ACK_RATIO_SHIFT) / ca->delayed_ack;
-	if (ca->cnt == 0)			/* cannot be zero */
-		ca->cnt = 1;
 }
 
 static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
@@ -314,13 +289,43 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	if (!tcp_is_cwnd_limited(sk))
 		return;
 
+	/* cwnd may first advance in slow start then move on to congestion
+	 * control mode on a stretch ACK.
+	 */
 	if (tp->snd_cwnd <= tp->snd_ssthresh) {
 		if (hystart && after(ack, ca->end_seq))
 			bictcp_hystart_reset(sk);
-		tcp_slow_start(tp, acked);
-	} else {
-		bictcp_update(ca, tp->snd_cwnd);
-		tcp_cong_avoid_ai(tp, ca->cnt);
+		acked = tcp_slow_start(tp, acked);
+	}
+
+	if (acked && tp->snd_cwnd > tp->snd_ssthresh) {
+		u32 target, cnt;
+
+		bictcp_update(ca, acked, tp->snd_cwnd);
+		/* Compute target cwnd based on bic_target and tcp_cwnd
+		 * (whichever is faster)
+		 */
+		target = (ca->last_bic_target >= ca->tcp_cwnd) ?
+				ca->last_bic_target : ca->tcp_cwnd;
+		while (acked > 0) {
+			if (target > tp->snd_cwnd)
+				cnt = tp->snd_cwnd / (target - tp->snd_cwnd);
+			else
+				cnt = 100 * tp->snd_cwnd;
+
+			/* The initial growth of cubic function may be
+			 * too conservative when the available
+			 * bandwidth is still unknown.
+			 */
+			if (ca->last_max_cwnd == 0 && cnt > 20)
+				cnt = 20;   /* increase cwnd 5% per RTT */
+
+			if (cnt == 0)		/* cannot be zero */
+				cnt = 1;
+
+			tcp_cong_avoid_ai(tp, cnt);
+			acked--;
+		}
 	}
 }
 
@@ -411,20 +416,10 @@ static void hystart_update(struct sock *sk, u32 delay)
  */
 static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 {
-	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 	u32 delay;
 
-	if (icsk->icsk_ca_state == TCP_CA_Open) {
-		u32 ratio = ca->delayed_ack;
-
-		ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
-		ratio += cnt;
-
-		ca->delayed_ack = clamp(ratio, 1U, ACK_RATIO_LIMIT);
-	}
-
 	/* Some calls are for duplicates without timetamps */
 	if (rtt_us < 0)
 		return;
