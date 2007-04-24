From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Wed, 25 Apr 2007 07:49:32 +0900 (JST)
Message-ID: <20070425.074932.51286377.yoshfuji@linux-ipv6.org>
References: <20070425.065539.104129657.yoshfuji@linux-ipv6.org>
	<20070424145754.1a37f666@dxpl.pdx.osdl.net>
	<1177452915.30986.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, dada1@cosmosbay.com,
	bunk@stusta.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: tglx@linutronix.de, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32931 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423202AbXDXWtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 18:49:35 -0400
In-Reply-To: <1177452915.30986.61.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1177452915.30986.61.camel@localhost.localdomain> (at Wed, 25 Apr 2007 00:15:15 +0200), Thomas Gleixner <tglx@linutronix.de> says:

> On Tue, 2007-04-24 at 14:57 -0700, Stephen Hemminger wrote:
> > On Wed, 25 Apr 2007 06:55:39 +0900 (JST)
> > YOSHIFUJI Hideaki / 吉藤英明  <yoshfuji@linux-ipv6.org> wrote:
> > 
> > > In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24 Apr 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundation.org> says:
> > > 
> > > > Yoshifuji-san had the right idea, but ktime_to_us needs to be defined
> > > > in a way that works on both 64 and 32bit platforms.
> > > 
> > > No, this does not cure.
> > > >  
> > > > +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> > > > +
> > > 
> > > NSEC_PER_USEC?
> > 
> > On 64 bit platforms, ktime stores nano-seconds in a 64 bit value, so
> > this is correct.
> 
> Err, nsec_value / NSEC_PER_SEC results in seconds AFAICS
> 
> nsec_value / NSEC_PER_USEC gives you microseconds
> 
> > > 
> > > > +static inline s64 ktime_to_us(const ktime_t kt)
> > > > +{
> > > > +	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_USEC;
> > > > +}
> > > > +
> > > 
> > > Please do NOT use division here, which was the source of the
> > > linkage error, and the reason why I posted a patch to use
> > > ktime_to_timeval().
> > 
> > On 32 bit platforms, ktime stores as two 32 bit values. Therefore the
> > division is only 32bit and therefore okay.
> 
> Nope.
> 
> #if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)
> ....
> 
> and on i386
> 
> config KTIME_SCALAR
>         bool
>         default y
> 
> so you take the 
> 
> ktime_to_timeval is probably the right way for it.

----
[TCP]: Fix linkage errors on i386.

To avoid raw division, use ktime_to_timeval() to get usec.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 248305b..81bb9c7 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -259,6 +259,12 @@ static inline s64 ktime_to_ns(const ktime_t kt)
 
 #endif
 
+static inline s64 ktime_to_us(const ktime_t kt)
+{
+	struct timeval tv = ktime_to_timeval(kt);
+	return (s64) tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
+}
+
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 8e31659..4adc47c 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -90,7 +90,7 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 
 	ca->acked = pkts_acked;
 
-	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
+	rtt = ktime_to_us(net_timedelta(last));
 
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index b4e062a..43294ad 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -266,7 +266,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
 
-	tcp_lp_rtt_sample(sk,  ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC);
+	tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
 
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 0f0ee7f..73e19cf 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -118,7 +118,7 @@ void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	u32 vrtt;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 0b50d06..9edb340 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -75,7 +75,7 @@ static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 	u32 vrtt;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	vrtt = ktime_to_us(net_timedelta(last)) + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
