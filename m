From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 3 Jun 2009 07:40:49 +0000
Message-ID: <20090603074049.GA5254@ff.dom.local>
References: <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:45693 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214AbZFCHky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 03:40:54 -0400
Received: by bwz22 with SMTP id 22so8485257bwz.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 00:40:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A2620FD.8030708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 09:06:37AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Jarek Poplawski wrote, On 06/02/2009 11:37 PM:
>> ...
>>
>>> I described the reasoning here:
>>> http://permalink.gmane.org/gmane.linux.network/128189
>>
>> The link is stuck now, so here is a quote:
>
> Thanks.
>
>> Jarek Poplawski wrote, On 05/17/2009 10:15 PM:
>>
>>> Here is some additional explanation. It looks like these rates above
>>> 500Mbit hit the design limits of packet scheduling. Currently used
>>> internal resolution PSCHED_TICKS_PER_SEC is 1,000,000. 550Mbit rate
>>> with 800byte packets means 550M/8/800 = 85938 packets/s, so on average
>>> 1000000/85938 = 11.6 ticks per packet. Accounting only 11 ticks means
>>> we leave 0.6*85938 = 51563 ticks per second, letting for additional
>>> sending of 51563/11 = 4687 packets/s or 4687*800*8 = 30Mbit. Of course
>>> it could be worse (0.9 tick/packet lost) depending on packet sizes vs.
>>> rates, and the effect rises for higher rates.
>
> I see. Unfortunately changing the scaling factors is pushing the lower
> end towards overflowing. For example Denys Fedoryshchenko reported some
> breakage a few years ago when I changed the iproute-internal factors
> triggered by this command:
>
> .. tbf buffer 1024kb latency 500ms rate 128kbit peakrate 256kbit  
> minburst 16384
>
> The burst size calculated by TBF with the current parameters is
> 64000000. Increasing it by a factor of 16 as in your patch results
> in 1024000000. Which means we're getting dangerously close to
> overflowing, a buffer size increase or a rate decrease of slightly
> bigger than factor 4 will already overflow.
>
> Mid-term we really need to move to 64 bit values and ns resolution,
> otherwise this problem is just going to reappear as soon as someone
> tries 10gbit. Not sure what the best short term fix is, I feel a bit
> uneasy about changing the current factors given how close this brings
> us towards overflowing.

I completely agree it's on the verge of overflow, and actually would
overflow for some insanely low (for today's standards) rates. So I
treat it's as a temporary solution, until people start asking about
more than 1 or 2Gbit. And of course we will have to move to 64 bit
anyway. Or we can do it now...

Btw., I've some doubts about HFSC; it's really different than others
wrt. rate tables/time accounting, and these PSCHED_TICKS look only
like an unnecesary compatibility; it works OK with usecs and doesn't
need this change now, unless I miss something. So maybe we would
simply stop using common psched_get_time() for it, and only do a
conversion for qdisc_watchdog_schedule() etc.?

Thanks,
Jarek P.
