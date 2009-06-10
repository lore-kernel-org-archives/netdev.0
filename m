From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2 3/2 v2] tc_core: Return double from
	tc_core_tick2time()
Date: Wed, 10 Jun 2009 07:46:34 +0000
Message-ID: <20090610074634.GB2673@ff.dom.local>
References: <20090609080536.GD5237@ff.dom.local> <4A2E6BA4.30002@trash.net> <20090609225317.GA3262@ami.dom.local> <4A2EEA84.3080803@trash.net>
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
Received: from mail-ew0-f210.google.com ([209.85.219.210]:46572 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867AbZFJHqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 03:46:40 -0400
Received: by ewy6 with SMTP id 6so719993ewy.37
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 00:46:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A2EEA84.3080803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 01:04:36AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Hmm... I'm not sure this floor() is needed here, but maybe I'll get it
>> tomorrow... 
>
> Its not. It was mainly a suggestion to make the symetry more explicit.
> I hope gcc understands :)

If so, then maybe let's reconsider previous example:

> Let's see how it's used (mainly) in tc_calc_xmittime() e.g. for
> Antonio's mostly 800byte and 555Mbit rate:
> 
> tc_core_time2tick(TIME_UNITS_PER_SEC * (double)size/rate)
> tc_core_time2tick(1000000 * (double) 800/69375000)
> tc_core_time2tick(11.53153)

Let's say it returns 116 (after x10 with ceil()). Then, going backwards:

tc_calc_xmitsize()
{
	return ((double) 69375000 * tc_core_tick2time(116)) / TIME_UNITS_PER_SEC;
}

would give us: 763 after /10 with floor(), and 804 without floor().
The latter looks nicer to me but I leave the choice to you or Stephen.

Thanks,
Jarek P.
--------------------------> take 2
Patrick McHardy wrote:
> It seems inconsistent to have the time2tick() function take a
> double, but return an unsigned from tick2time(). If we're going
> to change this, please keep them symetrical (you could even use
> floor() in tick2time() to make it more explicit).

This patch removes this inconsistency.

Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/tc/tc_core.c b/tc/tc_core.c
--- a/tc/tc_core.c	2009-06-10 07:18:30.000000000 +0000
+++ b/tc/tc_core.c	2009-06-10 07:20:38.000000000 +0000
@@ -41,9 +41,9 @@ unsigned tc_core_time2tick(double time)
 	return ceil(time * tick_in_usec);
 }
 
-unsigned tc_core_tick2time(unsigned tick)
+double tc_core_tick2time(unsigned tick)
 {
-	return tick/tick_in_usec;
+	return tick / tick_in_usec;
 }
 
 unsigned tc_core_time2ktime(unsigned time)
diff -Nurp a/tc/tc_core.h b/tc/tc_core.h
--- a/tc/tc_core.h	2009-06-10 07:17:34.000000000 +0000
+++ b/tc/tc_core.h	2009-06-10 07:19:41.000000000 +0000
@@ -15,7 +15,7 @@ enum link_layer {
 
 int  tc_core_time2big(double time);
 unsigned tc_core_time2tick(double time);
-unsigned tc_core_tick2time(unsigned tick);
+double tc_core_tick2time(unsigned tick);
 unsigned tc_core_time2ktime(unsigned time);
 unsigned tc_core_ktime2time(unsigned ktime);
 unsigned tc_calc_xmittime(unsigned rate, unsigned size);
