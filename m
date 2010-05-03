From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet input_pkt_queue
Date: Mon, 03 May 2010 10:45:07 -0400
Message-ID: <4BDEE173.4070800@athenacr.com>
References: <1272783366.2173.13.camel@edumazet-laptop>	<20100502092020.GA9655@gargoyle.fritz.box>	<1272797690.2173.26.camel@edumazet-laptop>	<20100502071324.1a95fdad@infradead.org>	<1272810448.2173.31.camel@edumazet-laptop>	<20100502105418.7abf83a7@infradead.org>	<1272828143.2173.150.camel@edumazet-laptop>	<20100502205044.450beda2@infradead.org>	<1272863834.2173.173.camel@edumazet-laptop>	<20100503032227.268613ac@infradead.org>	<20100503103426.GA25809@one.firstfloor.org> <20100503070925.572bbee6@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:57297 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932429Ab0ECOpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 10:45:10 -0400
In-Reply-To: <20100503070925.572bbee6@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> On Mon, 3 May 2010 12:34:26 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
> 
>>>> Maybe its low cost, (apparently, it is, since I can reach ~900.000
>>>> ipis on my 16 cores machine) but multiply this by 16 or 32 or 64
>>>> cpus, and clockevents_notify() cost appears to be a killer, all
>>>> cpus compete on a single lock.
>>>>
>>>> Maybe this notifier could use RCU ?
>>> could this be an artifact of the local apic stopping in deeper C
>>> states? (which is finally fixed in the Westmere generation)
>> Yes it is I think.
>>
>> But I suspect Eric wants a solution for Nehalem.
> 
> sure ;-)
> 
> 
> so the hard problem is that on going idle, the local timers need to be
> funneled to the external HPET. Afaik right now we use one channel of
> the hpet, with the result that we have one global lock for this.

Does the HPET only need to be programmed when going idle?
That could mean that this isn't a big performance issue.
cares if you spin for a while when you're about to sleep for
at least 60usec?

> HPETs have more than one channel (2 or 3 historically, newer chipsets
> iirc have a few more), so in principle we can split this lock at least
> a little bit... if we can get to one hpet channel per level 3 cache
> domain we'd already make huge progress in terms of cost of the
> contention....

Another possible approach: if a core needs the HPET and finds it
locked, it could queue up its request to a backlog which the
locking core will service.
