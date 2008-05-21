From: Stephen Hemminger <shemminger@vyatta.com>
Subject: route metrics in jiffies??
Date: Wed, 21 May 2008 11:43:54 -0700
Message-ID: <20080521114354.31c6807c@extreme>
References: <20080521163815.GA5028@sc.homeunix.net>
	<20080521101053.27db3495@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45714 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757224AbYEUSoC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 14:44:02 -0400
In-Reply-To: <20080521101053.27db3495@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008 10:10:53 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Wed, 21 May 2008 17:38:15 +0100
> Stephane Chazelas <Stephane_Chazelas@yahoo.fr> wrote:
>=20
> > Hi Stephen,
> >=20
> > there seems to be something wrong with the timer values as
> > processed by at least the "ss" and "ip" commands when
> > CONFIG_HIGH_RES_TIMERS is on.
> >=20
> > $ zgrep -e HZ=3D -e HIGH_RES /proc/config.gz
> > CONFIG_HIGH_RES_TIMERS=3Dy
> > CONFIG_HZ=3D250
> >=20
> > For instance, the "ip route rtt <time>" and=20
> > rto values returned by PROC_NET_TCP=3D/proc/net/tcp ss -i
> > look incorrect:
> >=20
> > $ PROC_NET_TCP=3D/proc/net/tcp ss -i
> > State       Recv-Q Send-Q  Local Address:Port      Peer Address:Por=
t
> > ESTAB       0      0           127.0.0.1:35466        127.0.0.1:101=
98    rto:5.5e-08
> > [...]
> >=20
> > $ ss -i
> > State       Recv-Q Send-Q  Local Address:Port      Peer Address:Por=
t
> > ESTAB       0      0           127.0.0.1:35466        127.0.0.1:101=
98
> >         bic wscale:7,7 rto:220 rtt:23.5/19 send 11.2Mbps rcv_space:=
32792
> >=20
> >=20
> > $ ip route show
> > 10.95.131.111 via 10.95.128.1 dev eth0  rtt 5ms
> >=20
> > $ netstat -rn
> > Kernel IP routing table
> > Destination     Gateway         Genmask         Flags   MSS Window =
 irtt Iface
> > 10.95.131.111   10.95.128.1     255.255.255.255 UGH       0 0     5=
000000 eth0
> >=20
> > I think this is because get_hz gets the HZ value from the fourth
> > field in /proc/net/psched. That's 1e9 in my case, because that's
> > meant to be the frequency of CLOCK_MONOTONIC and when
> > CONFIG_HIGH_RES_TIMERS is on, the CLOCK_MONOTONIC resolution is
> > 1ns. So get_hz returns 1,000,000,000 instead of 250 in my case.
> >=20
> > I don't know how to get the right value, clock_getres return 1ns
> > as well.
> >=20
> > That's with 2.6.24.2, iproute-20080108 from debian (but the GIT
> > head code looks the same).
> >=20
> > Best regards,
> > St=C3=A9phane
>=20
> Several places in iproute utils confuse psched and user hz values.
> I am looking into it.


There is an even bigger mess up.  The API for route metrics has several
values encoded in jiffies.  This is a problem because there is no good
way to find the internal kernel value of HZ. So all kernel/user ABI's
are supposed to use an absolute value (like milliseconds) or clock_t
which user USER_HZ.

The problem is that these values are now hardcoded into people's system=
s
so anyone using the 'ip route' options: rttvar, rtomin, or rtt are brok=
en.
They might be lucky now (but I doubt it).

I propose doing the right thing and fixing kernel and iproute to always
use milliseconds for these values. To maintain compatibility, the new m=
etric
values will be renumbered.  So old kernels don't misinterpret the new v=
alues.

---------------------
--- a/include/linux/rtnetlink.h	2008-05-21 11:26:47.000000000 -0700
+++ b/include/linux/rtnetlink.h	2008-05-21 11:28:48.000000000 -0700
@@ -343,10 +343,8 @@ enum
 #define RTAX_MTU RTAX_MTU
 	RTAX_WINDOW,
 #define RTAX_WINDOW RTAX_WINDOW
-	RTAX_RTT,
-#define RTAX_RTT RTAX_RTT
-	RTAX_RTTVAR,
-#define RTAX_RTTVAR RTAX_RTTVAR
+	RTAX_RTT_OLD,
+	RTAX_RTTVAR_OLD,
 	RTAX_SSTHRESH,
 #define RTAX_SSTHRESH RTAX_SSTHRESH
 	RTAX_CWND,
@@ -361,8 +359,14 @@ enum
 #define RTAX_INITCWND RTAX_INITCWND
 	RTAX_FEATURES,
 #define RTAX_FEATURES RTAX_FEATURES
+	RTAX_RTO_MIN_OLD,
+
 	RTAX_RTO_MIN,
 #define RTAX_RTO_MIN RTAX_RTO_MIN
+	RTAX_RTT,
+#define RTAX_RTT RTAX_RTT
+	RTAX_RTTVAR,
+#define RTAX_RTTVAR RTAX_RTTVAR
 	__RTAX_MAX
 };
=20
--- a/net/ipv4/tcp_input.c	2008-05-21 11:31:23.000000000 -0700
+++ b/net/ipv4/tcp_input.c	2008-05-21 11:40:29.000000000 -0700
@@ -730,7 +730,7 @@ void tcp_update_metrics(struct sock *sk)
=20
 	if (dst && (dst->flags & DST_HOST)) {
 		const struct inet_connection_sock *icsk =3D inet_csk(sk);
-		int m;
+		long m;
=20
 		if (icsk->icsk_backoff || !tp->srtt) {
 			/* This session failed to estimate rtt. Why?
@@ -742,7 +742,7 @@ void tcp_update_metrics(struct sock *sk)
 			return;
 		}
=20
-		m =3D dst_metric(dst, RTAX_RTT) - tp->srtt;
+		m =3D msecs_to_jiffies(dst_metric(dst, RTAX_RTT)) - tp->srtt;
=20
 		/* If newly calculated rtt larger than stored one,
 		 * store new one. Otherwise, use EWMA. Remember,
@@ -750,9 +750,9 @@ void tcp_update_metrics(struct sock *sk)
 		 */
 		if (!(dst_metric_locked(dst, RTAX_RTT))) {
 			if (m <=3D 0)
-				dst->metrics[RTAX_RTT - 1] =3D tp->srtt;
+				dst->metrics[RTAX_RTT - 1] =3D jiffies_to_msecs(tp->srtt);
 			else
-				dst->metrics[RTAX_RTT - 1] -=3D (m >> 3);
+				dst->metrics[RTAX_RTT - 1] -=3D jiffies_to_msecs(m >> 3);
 		}
=20
 		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
@@ -765,10 +765,11 @@ void tcp_update_metrics(struct sock *sk)
 				m =3D tp->mdev;
=20
 			if (m >=3D dst_metric(dst, RTAX_RTTVAR))
-				dst->metrics[RTAX_RTTVAR - 1] =3D m;
+				dst->metrics[RTAX_RTTVAR - 1] =3D jiffies_to_msecs(m);
 			else
 				dst->metrics[RTAX_RTTVAR-1] -=3D
-					(dst_metric(dst, RTAX_RTTVAR) - m)>>2;
+					jiffies_to_msecs((dst_metric(dst, RTAX_RTTVAR)
+							  - m) >> 2);
 		}
=20
 		if (tp->snd_ssthresh >=3D 0xFFFF) {
@@ -899,7 +900,7 @@ static void tcp_init_metrics(struct sock
 	if (dst_metric(dst, RTAX_RTT) =3D=3D 0)
 		goto reset;
=20
-	if (!tp->srtt && dst_metric(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (!tp->srtt && dst_metric(dst, RTAX_RTT) < jiffies_to_msecs(TCP_TIM=
EOUT_INIT << 3))
 		goto reset;
=20
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,12 +917,12 @@ static void tcp_init_metrics(struct sock
 	 * to low value, and then abruptly stops to do it and starts to delay
 	 * ACKs, wait for troubles.
 	 */
-	if (dst_metric(dst, RTAX_RTT) > tp->srtt) {
-		tp->srtt =3D dst_metric(dst, RTAX_RTT);
+	if (dst_metric(dst, RTAX_RTT) > jiffies_to_msecs(tp->srtt)) {
+		tp->srtt =3D msecs_to_jiffies(dst_metric(dst, RTAX_RTT));
 		tp->rtt_seq =3D tp->snd_nxt;
 	}
-	if (dst_metric(dst, RTAX_RTTVAR) > tp->mdev) {
-		tp->mdev =3D dst_metric(dst, RTAX_RTTVAR);
+	if (dst_metric(dst, RTAX_RTTVAR) > jiffies_to_msecs(tp->mdev)) {
+		tp->mdev =3D msecs_to_jiffies(dst_metric(dst, RTAX_RTTVAR));
 		tp->mdev_max =3D tp->rttvar =3D max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);



