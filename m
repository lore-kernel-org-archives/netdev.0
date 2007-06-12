From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 15:21:54 +0200
Message-ID: <466E9DF2.9010505@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net>	 <1181597718.4071.12.camel@localhost>  <466DEF9D.9070509@trash.net> <1181615384.4071.121.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36043 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbXFLNYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 09:24:46 -0400
In-Reply-To: <1181615384.4071.121.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
>>the qdisc has a chance to hand out either a packet
>>  of the same priority or higher priority, but at the cost of
>>  at worst (n - 1) * m unnecessary dequeues+requeues in case
>>  there is only a packet of lowest priority and we need to
>>  fully serve all higher priority HW queues before it can
>>  actually be dequeued. 
> 
> 
> yes, i see that. 
> [It actually is related to the wake threshold you use in the 
> driver. tg3 and e1000 for example will do it after 30 or so packets.
> But i get your point - what you are trying to describe is a worst case
> scenario].


Yes. Using a higher threshold reduces the overhead, but leads to
lower priority packets getting out even if higher priority packets
are present in the qdisc. Note that if we use the threshold with
multiple queue states (threshold per ring) this doesn't happen.

>>  The other possibility would be to
>>  activate the queue again once all rings can take packets
>>  again, but that wouldn't fix the problem, which you can
>>  easily see if you go back to my example and assume we still
>>  have a low priority packet within the qdisc when the lowest
>>  priority ring fills up (and the queue is stopped), and after
>>  we tried to wake it and stopped it again the higher priority
>>  packet arrives.
> 
> 
> In your use case, only low prio packets are available on the stack.
> Above you mention arrival of high prio - assuming thats intentional and
> not it being late over there ;->
> If higher prio packets are arriving on the qdisc when you open up, then
> given strict prio those packets get to go to the driver first until
> there are no more left; followed of course by low prio which then
> shutdown the path again...


Whats happening is: Lowest priority ring fills up, queue is stopped.
We have more packets for it in the qdisc. A higher priority packet
is transmitted, the queue is woken up again, the lowest priority packet
goes to the driver and hits the full ring, packet is requeued and
queue shut down until ring frees up again. Now a high priority packet
arrives. It won't get to the driver anymore. But its not very important
since having two different wakeup-strategies would be a bit strange
anyway, so lets just rule out this possibility.

>>Considering your proposal in combination with RR, you can see
>>the same problem of unnecessary dequeues+requeues. 
> 
> 
> Well, we havent really extended the use case from prio to RR.
> But this is a good start as any since all sorts of work conserving
> schedulers will behave in a similar fashion ..
> 
> 
>>Since there
>>is no priority for waking the queue when a equal or higher
>>priority ring got dequeued as in the prio case, I presume you
>>would wake the queue whenever a packet was sent. 
> 
> 
> I suppose that is a viable approach if the hardware is RR based.
> Actually in the case of e1000 it is WRR not plain RR, but that is a
> moot point which doesnt affect the discussion.
> 
> 
>>For the RR
>>qdisc dequeue after requeue should hand out the same packet,
>>independantly of newly enqueued packets (which doesn't happen
>>and is a bug in Peter's RR version), so in the worst case the
>>HW has to make the entire round before a packet can get
>>dequeued in case the corresponding HW queue is full. This is
>>a bit better than prio, but still up to n - 1 unnecessary
>>requeues+dequeues. I think it can happen more often than
>>for prio though.
> 
> 
> I think what would better to be use is DRR. I pointed the code i did
> a long time ago to Peter. 
> With DRR, a deficit is viable to be carried forward.


If both driver and HW do it, its probably OK for short term, but it
shouldn't grow too large since short-term fairness is also important.
But the unnecessary dequeues+requeues can still happen.

>>Forgetting about things like multiple qdisc locks and just
>>looking at queueing behaviour, the question seems to come
>>down to whether the unnecessary dequeues/requeues are acceptable
>>(which I don't think since they are easily avoidable).
> 
> 
> As i see it, the worst case scenario would have a finite time.
> A 100Mbps NIC should be able to dish out, depending on packet size,
> 148Kpps to 8.6Kpps; a GigE 10x that.
> so i think the phase in general wont last that long given the assumption
> is packets are coming in from the stack to the driver with about the
> packet rate equivalent to wire rate (for the case of all work conserving
> schedulers).
> In the general case there should be no contention at all.


It does have finite time, but its still undesirable. The average case
would probably have been more interesting, but its also harder :)
I also expect to see lots of requeues under "normal" load that doesn't
ressemble the worst-case, but only tests can confirm that.

>> OTOH
>>you could turn it around and argue that the patches won't do
>>much harm since ripping them out again (modulo queue mapping)
>>should result in the same behaviour with just more overhead.
> 
> 
> I am not sure i understood - but note that i have asked for a middle
> ground from the begining. 


I just mean that we could rip the patches out at any point again
without user visible impact aside from more overhead. So even
if they turn out to be a mistake its easily correctable.

I've also looked into moving all multiqueue specific handling to
the top-level qdisc out of sch_generic, unfortunately that leads
to races unless all subqueue state operations takes dev->qdisc_lock.
Besides the overhead I think it would lead to ABBA deadlocks.

So how do we move forward?

