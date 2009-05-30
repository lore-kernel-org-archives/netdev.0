From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Sat, 30 May 2009 22:07:56 +0200
Message-ID: <20090530200756.GF3166@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com> <20090521085116.GC2892@ami.dom.local> <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com> <20090523073201.GA2766@ami.dom.local> <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:62389 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbZE3UIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 16:08:21 -0400
Received: by bwz22 with SMTP id 22so6751290bwz.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 13:08:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 06:02:39PM +0100, Antonio Almeida wrote:
> On Thu, May 28, 2009 at 10:12 PM, Jarek Poplawski wrote:
...
> > -#define PSCHED_US2NS(x)                        ((s64)(x) << 10)
> > -#define PSCHED_NS2US(x)                        ((x) >> 10)
> > +#define PSCHED_US2NS(x)                        ((s64)(x) << 6)
> > +#define PSCHED_NS2US(x)                        ((x) >> 6)
> >
> >  #define PSCHED_TICKS_PER_SEC           PSCHED_NS2US(NSEC_PER_SEC)
> >  #define PSCHED_PASTPERFECT             0
> 
> It's better! This patch gives more accuracy to HTB. Here some values:
> Note that these are boundary values, so, e.g., any HTB configuration
> between 377000Kbit and 400000Kbit would fall in the same step - close
> to 397977Kbit.
> This test was made over the same conditions: generating 950Mbit/s of
> unidirectional tcp traffic of 800 bytes packets long.

Here is a tc patch, which should minimize these boundaries, so please,
repeat this test with previous patches/conditions plus this one.

Thanks,
Jarek P.
---

 tc/tc_core.c |   10 +++++-----
 tc/tc_core.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..6d74287 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -27,18 +27,18 @@
 static double tick_in_usec = 1;
 static double clock_factor = 1;
 
-int tc_core_time2big(unsigned time)
+int tc_core_time2big(double time)
 {
-	__u64 t = time;
+	__u64 t;
 
-	t *= tick_in_usec;
+	t = time * tick_in_usec + 0.5;
 	return (t >> 32) != 0;
 }
 
 
-unsigned tc_core_time2tick(unsigned time)
+unsigned tc_core_time2tick(double time)
 {
-	return time*tick_in_usec;
+	return time * tick_in_usec + 0.5;
 }
 
 unsigned tc_core_tick2time(unsigned tick)
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 5a693ba..0ac65aa 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -13,8 +13,8 @@ enum link_layer {
 };
 
 
-int  tc_core_time2big(unsigned time);
-unsigned tc_core_time2tick(unsigned time);
+int  tc_core_time2big(double time);
+unsigned tc_core_time2tick(double time);
 unsigned tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
