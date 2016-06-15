From: Daniel Metz <dmetz@mytum.de>
Subject: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO calculation
Date: Wed, 15 Jun 2016 20:00:03 +0200
Message-ID: <20160615180003.28970-1-dmetz@mytum.de>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Metz <Daniel.Metz@rohde-schwarz.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Daniel Metz <dmetz@mytum.de>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:39945 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230AbcFOSAZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 14:00:25 -0400
In-Reply-To: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Metz <Daniel.Metz@rohde-schwarz.com>

This patch adjusts Linux RTO calculation to be RFC6298 Standard
compliant. MinRTO is no longer added to the computed RTO, RTO damping
and overestimation are decreased.

In RFC 6298 Standard TCP Retransmission Timeout (RTO) calculation the
calculated RTO is rounded up to the Minimum RTO (MinRTO), if it is
less.  The Linux implementation as a discrepancy to the Standard
basically adds the defined MinRTO to the calculated RTO. When
comparing both approaches, the Linux calculation seems to perform
worse for sender limited TCP flows like Telnet, SSH or constant bit
rate encoded transmissions, especially for Round Trip Times (RTT) of
50ms to 800ms.

Compared to the Linux implementation the RFC 6298 proposed RTO
calculation performs better and more precise in adapting to current
network characteristics. Extensive measurements for bulk data did not
show a negative impact of the adjusted calculation.

Exemplary performance comparison for sender-limited-flows:

- Rate: 10Mbit/s
- Delay: 200ms, Delay Variation: 10ms
- Time between each scheduled segment: 1s
- Amount Data Segments: 300
- Mean of 11 runs

         Mean Response Waiting Time [milliseconds]

PER [%] |   0.5      1    1.5      2      3      5      7     10
--------+-------------------------------------------------------
old     | 206.4  208.6  218.0  218.6  227.2  249.3  274.7  308.2
new     | 203.9  206.0  207.0  209.9  217.3  225.6  238.7  259.1

Detailed analysis:
https://docs.google.com/document/d/1pKmPfnQb6fDK4qpiNVkN8cQyGE4wYDZukcu=
ZfR-BnnM/

Reasoning for historic design:
Sarolahti, P.; Kuznetsov, A. (2002). Congestion Control in Linux TCP.
Conference Paper. Proceedings of the FREENIX Track. 2002 USENIX Annual
https://www.cs.helsinki.fi/research/iwtcp/papers/linuxtcp.pdf

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Signed-off-by: Daniel Metz <dmetz@mytum.de>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---

 v3:
  - remove mdev_us

 v2:
  - Using the RFC 6298 compliant implementation, the tcp_sock struct va=
riable
    u32 mdev_max_us becomes obsolete and consequently is being removed.
  - Add reference to Kuznetsov paper


 include/linux/tcp.h      |  2 --
 net/ipv4/tcp.c           |  3 +-
 net/ipv4/tcp_input.c     | 72 ++++++++++------------------------------=
--------
 net/ipv4/tcp_metrics.c   |  5 ++--
 net/ipv4/tcp_minisocks.c |  1 -
 5 files changed, 18 insertions(+), 65 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7be9b12..3128eb1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -230,8 +230,6 @@ struct tcp_sock {
=20
 /* RTT measurement */
 	u32	srtt_us;	/* smoothed round trip time << 3 in usecs */
-	u32	mdev_us;	/* medium deviation			*/
-	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
 	u32	rttvar_us;	/* smoothed mdev_max			*/
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
 	struct rtt_meas {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed14..4a7597c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -386,7 +386,6 @@ void tcp_init_sock(struct sock *sk)
 	INIT_LIST_HEAD(&tp->tsq_node);
=20
 	icsk->icsk_rto =3D TCP_TIMEOUT_INIT;
-	tp->mdev_us =3D jiffies_to_usecs(TCP_TIMEOUT_INIT);
 	tp->rtt_min[0].rtt =3D ~0U;
=20
 	/* So many TCP implementations out there (incorrectly) count the
@@ -2703,7 +2702,7 @@ void tcp_get_info(struct sock *sk, struct tcp_inf=
o *info)
 	info->tcpi_pmtu =3D icsk->icsk_pmtu_cookie;
 	info->tcpi_rcv_ssthresh =3D tp->rcv_ssthresh;
 	info->tcpi_rtt =3D tp->srtt_us >> 3;
-	info->tcpi_rttvar =3D tp->mdev_us >> 2;
+	info->tcpi_rttvar =3D tp->rttvar_us >> 2;
 	info->tcpi_snd_ssthresh =3D tp->snd_ssthresh;
 	info->tcpi_snd_cwnd =3D tp->snd_cwnd;
 	info->tcpi_advmss =3D tp->advmss;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94d4aff..279f5f7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -680,8 +680,7 @@ static void tcp_event_data_recv(struct sock *sk, st=
ruct sk_buff *skb)
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
- * Proceedings SIGCOMM 87]. The algorithm is from the SIGCOMM 88
- * piece by Van Jacobson.
+ * Proceedings SIGCOMM 87].
  * NOTE: the next three routines used to be one big routine.
  * To save cycles in the RFC 1323 implementation it was better to brea=
k
  * it up into three procedures. -- erics
@@ -692,59 +691,19 @@ static void tcp_rtt_estimator(struct sock *sk, lo=
ng mrtt_us)
 	long m =3D mrtt_us; /* RTT */
 	u32 srtt =3D tp->srtt_us;
=20
-	/*	The following amusing code comes from Jacobson's
-	 *	article in SIGCOMM '88.  Note that rtt and mdev
-	 *	are scaled versions of rtt and mean deviation.
-	 *	This is designed to be as fast as possible
-	 *	m stands for "measurement".
-	 *
-	 *	On a 1990 paper the rto value is changed to:
-	 *	RTO =3D rtt + 4 * mdev
-	 *
-	 * Funny. This algorithm seems to be very broken.
-	 * These formulae increase RTO, when it should be decreased, increase
-	 * too slowly, when it should be increased quickly, decrease too quic=
kly
-	 * etc. I guess in BSD RTO takes ONE value, so that it is absolutely
-	 * does not matter how to _calculate_ it. Seems, it was trap
-	 * that VJ failed to avoid. 8)
-	 */
 	if (srtt !=3D 0) {
-		m -=3D (srtt >> 3);	/* m is now error in rtt est */
-		srtt +=3D m;		/* rtt =3D 7/8 rtt + 1/8 new */
-		if (m < 0) {
-			m =3D -m;		/* m is now abs(error) */
-			m -=3D (tp->mdev_us >> 2);   /* similar update on mdev */
-			/* This is similar to one of Eifel findings.
-			 * Eifel blocks mdev updates when rtt decreases.
-			 * This solution is a bit different: we use finer gain
-			 * for mdev in this case (alpha*beta).
-			 * Like Eifel it also prevents growth of rto,
-			 * but also it limits too fast rto decreases,
-			 * happening in pure Eifel.
-			 */
-			if (m > 0)
-				m >>=3D 3;
-		} else {
-			m -=3D (tp->mdev_us >> 2);   /* similar update on mdev */
-		}
-		tp->mdev_us +=3D m;		/* mdev =3D 3/4 mdev + 1/4 new */
-		if (tp->mdev_us > tp->mdev_max_us) {
-			tp->mdev_max_us =3D tp->mdev_us;
-			if (tp->mdev_max_us > tp->rttvar_us)
-				tp->rttvar_us =3D tp->mdev_max_us;
-		}
-		if (after(tp->snd_una, tp->rtt_seq)) {
-			if (tp->mdev_max_us < tp->rttvar_us)
-				tp->rttvar_us -=3D (tp->rttvar_us - tp->mdev_max_us) >> 2;
+		m -=3D (srtt >> 3);	 /* m' =3D m - srtt / 8 =3D (R' - SRTT) */
+		srtt +=3D m;	/* srtt =3D srtt + m=E2=80=99 =3D srtt + m - srtt / 8 *=
/
+		if (m < 0)
+			m =3D -m;
+		m -=3D (tp->rttvar_us >> 2); /* m'' =3D |m'| - rttvar / 4 */
+		tp->rttvar_us +=3D m;
+		if (after(tp->snd_una, tp->rtt_seq))
 			tp->rtt_seq =3D tp->snd_nxt;
-			tp->mdev_max_us =3D tcp_rto_min_us(sk);
-		}
 	} else {
 		/* no previous measure. */
-		srtt =3D m << 3;		/* take the measured time to be rtt */
-		tp->mdev_us =3D m << 1;	/* make sure rto =3D 3*rtt */
-		tp->rttvar_us =3D max(tp->mdev_us, tcp_rto_min_us(sk));
-		tp->mdev_max_us =3D tp->rttvar_us;
+		srtt =3D m << 3;
+		tp->rttvar_us =3D m << 1;
 		tp->rtt_seq =3D tp->snd_nxt;
 	}
 	tp->srtt_us =3D max(1U, srtt);
@@ -798,6 +757,7 @@ static void tcp_update_pacing_rate(struct sock *sk)
  */
 static void tcp_set_rto(struct sock *sk)
 {
+	const u32 min_rto =3D tcp_rto_min_us(sk);
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Old crap is replaced with new one. 8)
 	 *
@@ -809,17 +769,15 @@ static void tcp_set_rto(struct sock *sk)
 	 *    is invisible. Actually, Linux-2.4 also generates erratic
 	 *    ACKs in some circumstances.
 	 */
-	inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp);
-
+	if (((tp->srtt_us >> 3) + tp->rttvar_us) < min_rto)
+		inet_csk(sk)->icsk_rto =3D usecs_to_jiffies(min_rto);
+	else
+		inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp);
 	/* 2. Fixups made earlier cannot be right.
 	 *    If we do not estimate RTO correctly without them,
 	 *    all the algo is pure shit and should be replaced
 	 *    with correct one. It is exactly, which we pretend to do.
 	 */
-
-	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
-	 * guarantees that rto is higher.
-	 */
 	tcp_bound_rto(sk);
 }
=20
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b617826..9ec9d99 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -420,8 +420,8 @@ void tcp_update_metrics(struct sock *sk)
=20
 		/* Scale deviation to rttvar fixed point */
 		m >>=3D 1;
-		if (m < tp->mdev_us)
-			m =3D tp->mdev_us;
+		if (m < tp->rttvar_us)
+			m =3D tp->rttvar_us;
=20
 		var =3D tcp_metric_get(tm, TCP_METRIC_RTTVAR);
 		if (m >=3D var)
@@ -561,7 +561,6 @@ reset:
 		 * retransmission.
 		 */
 		tp->rttvar_us =3D jiffies_to_usecs(TCP_TIMEOUT_FALLBACK);
-		tp->mdev_us =3D tp->mdev_max_us =3D tp->rttvar_us;
=20
 		inet_csk(sk)->icsk_rto =3D TCP_TIMEOUT_FALLBACK;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4b95ec4..e72c2f5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -463,7 +463,6 @@ struct sock *tcp_create_openreq_child(const struct =
sock *sk,
 		tcp_init_wl(newtp, treq->rcv_isn);
=20
 		newtp->srtt_us =3D 0;
-		newtp->mdev_us =3D jiffies_to_usecs(TCP_TIMEOUT_INIT);
 		newtp->rtt_min[0].rtt =3D ~0U;
 		newicsk->icsk_rto =3D TCP_TIMEOUT_INIT;
=20
--=20
2.8.3
