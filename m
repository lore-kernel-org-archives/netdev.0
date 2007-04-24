From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 14:57:54 -0700
Message-ID: <20070424145754.1a37f666@dxpl.pdx.osdl.net>
References: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
	<20070424183827.adb60ae0.dada1@cosmosbay.com>
	<20070424100420.2860db68@dxpl.pdx.osdl.net>
	<20070425.065539.104129657.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, bunk@stusta.de, davem@davemloft.net,
	netdev@vger.kernel.org, tglx@linutronix.de, yoshfuji@linux-ipv6.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:53036 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161490AbXDXWCJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 18:02:09 -0400
In-Reply-To: <20070425.065539.104129657.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 06:55:39 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@lin=
ux-ipv6.org> wrote:

> In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24 Ap=
r 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundation.=
org> says:
>=20
> > Yoshifuji-san had the right idea, but ktime_to_us needs to be defin=
ed
> > in a way that works on both 64 and 32bit platforms.
>=20
> No, this does not cure.
> > =20
> > +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> > +
>=20
> NSEC_PER_USEC?

On 64 bit platforms, ktime stores nano-seconds in a 64 bit value, so
this is correct.

>=20
> > +static inline s64 ktime_to_us(const ktime_t kt)
> > +{
> > +	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_USE=
C;
> > +}
> > +
>=20
> Please do NOT use division here, which was the source of the
> linkage error, and the reason why I posted a patch to use
> ktime_to_timeval().

On 32 bit platforms, ktime stores as two 32 bit values. Therefore the
division is only 32bit and therefore okay.

Corrected patch.
---------------------------
=46rom 04d3583fbb763deeb9d33c90239a8d35e66e0c1e Mon Sep 17 00:00:00 200=
1
=46rom: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 24 Apr 2007 12:44:33 -0700
Subject: [PATCH] ktime_to_us: for TCP usage.

Argh, Monday sucks.  Sorry, need to build on 32bit every time...

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/ktime.h   |   13 +++++++++++++
 net/ipv4/tcp_illinois.c |    2 +-
 net/ipv4/tcp_lp.c       |    2 +-
 net/ipv4/tcp_vegas.c    |    2 +-
 net/ipv4/tcp_veno.c     |    2 +-
 5 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 248305b..3793490 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -121,6 +121,8 @@ static inline ktime_t timeval_to_ktime(struct timev=
al tv)
 /* Convert ktime_t to nanoseconds - NOP in the scalar storage format: =
*/
 #define ktime_to_ns(kt)			((kt).tv64)
=20
+#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
+
 #else
=20
 /*
@@ -257,6 +259,17 @@ static inline s64 ktime_to_ns(const ktime_t kt)
 	return (s64) kt.tv.sec * NSEC_PER_SEC + kt.tv.nsec;
 }
=20
+/**
+ * ktime_to_us - convert a ktime_t variable to scalar microseconds
+ * @kt:		the ktime_t variable to convert
+ *
+ * Returns the scalar nanoseconds representation of @kt
+ */
+static inline s64 ktime_to_us(const ktime_t kt)
+{
+	return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
+}
+
 #endif
=20
 /*
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 8e31659..4adc47c 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -90,7 +90,7 @@ static void tcp_illinois_acked(struct sock *sk, u32 p=
kts_acked, ktime_t last)
=20
 	ca->acked =3D pkts_acked;
=20
-	rtt =3D ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
+	rtt =3D ktime_to_us(net_timedelta(last));
=20
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index b4e062a..43294ad 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -266,7 +266,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 =
num_acked, ktime_t last)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct lp *lp =3D inet_csk_ca(sk);
=20
-	tcp_lp_rtt_sample(sk,  ktime_to_ns(net_timedelta(last)) / NSEC_PER_US=
EC);
+	tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
=20
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 0f0ee7f..73e19cf 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -118,7 +118,7 @@ void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt,=
 ktime_t last)
 	u32 vrtt;
=20
 	/* Never allow zero rtt or baseRTT */
-	vrtt =3D (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt =3D ktime_to_us(net_timedelta(last)) + 1;
=20
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 0b50d06..9edb340 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -75,7 +75,7 @@ static void tcp_veno_pkts_acked(struct sock *sk, u32 =
cnt, ktime_t last)
 	u32 vrtt;
=20
 	/* Never allow zero rtt or baseRTT */
-	vrtt =3D (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt =3D ktime_to_us(net_timedelta(last)) + 1;
=20
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)
--=20
1.5.0.6

