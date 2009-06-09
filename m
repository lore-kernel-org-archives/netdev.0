From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2 1/2] tc_core: Use double in tc_core_time2tick()
Date: Tue, 9 Jun 2009 23:54:25 +0200
Message-ID: <20090609215425.GA2893@ami.dom.local>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:7393 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760470AbZFIVyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 17:54:53 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1140871fga.17
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2009 14:54:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A2E6BA4.30002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 04:03:16PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Change 'time' parameters of tc_core_time2tick() and tc_core_time2big()
>> from unsigned to double. It is especially needed to use in
>> tc_calc_rtable() for kernels with increased psched ticks resolution,
>> but even without this, it looks reasonable to avoid rounding here.
>
> I would prefer to keep using integers, which are a lot easier to
> analyze for rounding errors and overflows, besides having constant
> granularity.
>
>> -unsigned tc_core_time2tick(unsigned time)
>> +unsigned tc_core_time2tick(double time)
>>  {
>> -	return time*tick_in_usec;
>> +	return time * tick_in_usec + 0.5;
>
> ceil()?

OK.

>
>>  }
>
> It seems inconsistent to have the time2tick() function take a
> double, but return an unsigned from tick2time(). If we're going
> to change this, please keep them symetrical (you could even use
> floor() in tick2time() to make it more explicit).

Let's see how it's used (mainly) in tc_calc_xmittime() e.g. for
Antonio's mostly 800byte and 555Mbit rate:

tc_core_time2tick(TIME_UNITS_PER_SEC * (double)size/rate)
tc_core_time2tick(1000000 * (double) 800/69375000)
tc_core_time2tick(11.53153)
tc_core_time2tick(11)

and let's say it's multiplied by 10. 5 ticks really make a difference.
Does it make sense to round it here before full calculations?

tc_core_tick2time() is used differently; it usually gets integers, to
show them as time. But even if not so, we have division here. So, I'm
not sure it's really needed, but if you confirm I'll do it in a
separate patch.

Thanks,
Jarek P.
--------------------> take 2
Change 'time' parameters of tc_core_time2tick() and tc_core_time2big()
from unsigned to double. It is especially needed to use in
tc_calc_rtable() for kernels with increased psched ticks resolution,
but even without this, it looks reasonable to avoid rounding here.
Additionally rounding with ceil() is used (it's safer to stay below
configured rate than going beyond limits).

With feedback from: Patrick McHardy <kaber@trash.net>

Reported-by: Antonio Almeida <vexwek@gmail.com>
Tested-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 tc/tc_core.c |   10 +++++-----
 tc/tc_core.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..c9c76b4 100644
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
+	t = ceil(time * tick_in_usec);
 	return (t >> 32) != 0;
 }
 
 
-unsigned tc_core_time2tick(unsigned time)
+unsigned tc_core_time2tick(double time)
 {
-	return time*tick_in_usec;
+	return ceil(time * tick_in_usec);
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
