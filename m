From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Wed, 09 Apr 2008 18:00:38 +0200
Message-ID: <47FCE826.2030106@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>	<873apwrc4t.fsf@basil.nowhere.org> <47FB60EF.1080004@trash.net>	<7iy77o9wzb.fsf@lanthane.pps.jussieu.fr> <47FB9315.5030109@trash.net> <7ifxtvghaz.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51789 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbYDIQAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 12:00:42 -0400
In-Reply-To: <7ifxtvghaz.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
>>>> I'd suggest to use the flow classifier for this. For simplicity
>>>> you could attach a default classifier that uses the same keys as
>>>> this one.
> 
>>> I'm not sure I know what you're speaking about.  Could you please
>>> point me at code somewhere?
> 
>> Check out a recent tree (either Linus' current tree or ideally
>> the net-2.6.26.git tree from
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26.git
>>
>> and look at net/sched/cls_flow.c and the recent changes to
>> net/sched/sch_sfq.c for external classifiers.
> 
> Thanks for the pointer.  Unfortunately, it will need some changes to
> work with sfb -- since we do double-buffering, we need some overlap
> between the old and new classifiers when we choose to reclassify.  I'm
> not quite sure how to do that.

You mean for perturbation? Yes, thats something not currently
supported. I'd suggest to ignore this for now, I intend
to add support, just need to figure out a way to reliably
kill the timer on cleanup (can't use del_timer_sync since
we're holding a lock). Shouldn't be that hard ...

> Other than that, it will require some changes to sfb (which currently
> assumes we can get an arbitrary amount of hash data for a single
> packet, while the classifiers only give 32 bits), but these changes
> are a good thing -- 32 bits should be enough.

Actually its only (max) 16 bits, the qdisc handle is always
encoded in the upper 16 bits. If you need more you could
combine it with other data. I recall seeing a paper about bloom
filters that analyzed the effectiveness of this compared to
perfect hashing, they concluded that the increase in false
positives is negligible.

I'll see if I can find it again in case you're interested.

> Would you have an example of how this stuff is configured from
> user-space?

I'm using this for per-dst hashing to 1024 classes
(1400:1 - 1400:1025).

tc filter add dev eth0 protocol ip pref 1 parent 1400: handle 1 \
         flow hash keys dst divisor 1024 

