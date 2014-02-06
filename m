From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: remove 1ms offset in srtt computation
Date: Thu, 06 Feb 2014 15:57:10 -0800
Message-ID: <1391731030.10160.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Vytautas Valancius <valas@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36278 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbaBFX5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 18:57:13 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa1so2373606pad.41
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 15:57:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP pacing depends on an accurate srtt estimation.

Current srtt estimation is using jiffie resolution,
and has an artificial offset of at least 1 ms, which can produce
slowdowns when FQ/pacing is used, especially in DC world,
where typical rtt is below 1 ms.

We are planning a switch to usec resolution for linux-3.15,
but in the meantime, this patch removes the 1 ms offset.

All we need is to have tp->srtt minimal value of 1 to differentiate
the case of srtt being initialized or not, not 8.

The problematic behavior was observed on a 40Gbit testbed,
where 32 concurrent netperf were reaching 12Gbps of aggregate
speed, instead of line speed.

This patch also has the effect of reporting more accurate srtt and send
rates to iproute2 ss command as in :

$ ss -i dst cca2
Netid  State      Recv-Q Send-Q          Local Address:Port
Peer Address:Port   
tcp    ESTAB      0      0                10.244.129.1:56984
10.244.129.2:12865   
	 cubic wscale:6,6 rto:200 rtt:0.25/0.25 ato:40 mss:1448 cwnd:10 send
463.4Mbps rcv_rtt:1 rcv_space:29200
tcp    ESTAB      0      390960           10.244.129.1:60247
10.244.129.2:50204   
	 cubic wscale:6,6 rto:200 rtt:0.875/0.75 mss:1448 cwnd:73 ssthresh:51
send 966.4Mbps unacked:73 retrans:0/121 rcv_space:29200

Reported-by: Vytautas Valancius <valas@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c  |   18 ++++++++++--------
 net/ipv4/tcp_output.c |    2 +-
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 65cf90e063d5..227cba79fa6b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -671,6 +671,7 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	long m = mrtt; /* RTT */
+	u32 srtt = tp->srtt;
 
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
@@ -688,11 +689,9 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 	 * does not matter how to _calculate_ it. Seems, it was trap
 	 * that VJ failed to avoid. 8)
 	 */
-	if (m == 0)
-		m = 1;
-	if (tp->srtt != 0) {
-		m -= (tp->srtt >> 3);	/* m is now error in rtt est */
-		tp->srtt += m;		/* rtt = 7/8 rtt + 1/8 new */
+	if (srtt != 0) {
+		m -= (srtt >> 3);	/* m is now error in rtt est */
+		srtt += m;		/* rtt = 7/8 rtt + 1/8 new */
 		if (m < 0) {
 			m = -m;		/* m is now abs(error) */
 			m -= (tp->mdev >> 2);   /* similar update on mdev */
@@ -723,11 +722,12 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
 		}
 	} else {
 		/* no previous measure. */
-		tp->srtt = m << 3;	/* take the measured time to be rtt */
+		srtt = m << 3;		/* take the measured time to be rtt */
 		tp->mdev = m << 1;	/* make sure rto = 3*rtt */
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 		tp->rtt_seq = tp->snd_nxt;
 	}
+	tp->srtt = max(1U, srtt);
 }
 
 /* Set the sk_pacing_rate to allow proper sizing of TSO packets.
@@ -746,8 +746,10 @@ static void tcp_update_pacing_rate(struct sock *sk)
 
 	rate *= max(tp->snd_cwnd, tp->packets_out);
 
-	/* Correction for small srtt : minimum srtt being 8 (1 jiffy << 3),
-	 * be conservative and assume srtt = 1 (125 us instead of 1.25 ms)
+	/* Correction for small srtt and scheduling constraints.
+	 * For small rtt, consider noise is too high, and use
+	 * the minimal value (srtt = 1 -> 125 us for HZ=1000)
+	 *
 	 * We probably need usec resolution in the future.
 	 * Note: This also takes care of possible srtt=0 case,
 	 * when tcp_rtt_estimator() was not yet called.
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 03d26b85eab8..10435b3b9d0f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1977,7 +1977,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	/* Schedule a loss probe in 2*RTT for SACK capable connections
 	 * in Open state, that are either limited by cwnd or application.
 	 */
-	if (sysctl_tcp_early_retrans < 3 || !rtt || !tp->packets_out ||
+	if (sysctl_tcp_early_retrans < 3 || !tp->srtt || !tp->packets_out ||
 	    !tcp_is_sack(tp) || inet_csk(sk)->icsk_ca_state != TCP_CA_Open)
 		return false;
 
