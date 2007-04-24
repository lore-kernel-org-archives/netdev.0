From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Wed, 25 Apr 2007 01:10:28 +0900 (JST)
Message-ID: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
	<20070424155324.GL3468@stusta.de>
	<20070425.005845.113682267.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@osdl.org, netdev@vger.kernel.org,
	tglx@linutronix.de, yoshfuji@linux-ipv6.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32881 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161805AbXDXQKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 12:10:32 -0400
In-Reply-To: <20070425.005845.113682267.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070425.005845.113682267.yoshfuji@linux-ipv6.org> (at Wed, 25 Apr 2007 00:58:45 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20070424155324.GL3468@stusta.de> (at Tue, 24 Apr 2007 17:53:24 +0200), Adrian Bunk <bunk@stusta.de> says:
> 
> > On Wed, Apr 25, 2007 at 12:17:43AM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > > Recent ktime_t changes had introduced linkage errors.
> > > 
> > > | WARNING: "__divdi3" [net/ipv4/tcp_veno.ko] undefined!
> > > | WARNING: "__divdi3" [net/ipv4/tcp_vegas.ko] undefined!
> > > | WARNING: "__divdi3" [net/ipv4/tcp_lp.ko] undefined!
> > > | WARNING: "__divdi3" [net/ipv4/tcp_illinois.ko] undefined!
> > > 
> > > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > > 
> > > ---
> > > diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
> > > index 8e31659..0cec615 100644
> > > --- a/net/ipv4/tcp_illinois.c
> > > +++ b/net/ipv4/tcp_illinois.c
> > > @@ -87,10 +87,12 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
> > >  {
> > >  	struct illinois *ca = inet_csk_ca(sk);
> > >  	u32 rtt;
> > > +	struct timeval tv;
> > >  
> > >  	ca->acked = pkts_acked;
> > >  
> > > -	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
> > > +	tv = ktime_to_timeval(net_timedelta(last));
> > > +	rtt = tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
> > >  
> > >  	/* ignore bogus values, this prevents wraparound in alpha math */
> > >  	if (rtt > RTT_MAX)
> > >...
> > 
> > Couldn't this be better solved by adding something like the following 
> > to include/linux/ktime.h ?
> > 
> > static inline s64 ktime_to_us(const ktime_t kt)
> > {
> >    return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
> > }
> > 
> 
> That will introduce same error, won't it?

How about this?

Singed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index 248305b..601a74e 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -259,6 +259,12 @@ static inline s64 ktime_to_ns(const ktime_t kt)
 
 #endif
 
+static inline s64 ktime_to_us(const ktime_t kt)
+{
+	struct timeval tv = ktime_to_timeval(kt);
+	return tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
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
