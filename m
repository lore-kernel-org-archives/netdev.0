From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 02:58:05 +0200
Message-ID: <466DEF9D.9070509@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net> <1181597718.4071.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55738 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbXFLBAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 21:00:45 -0400
In-Reply-To: <1181597718.4071.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 17:44 +0200, Patrick McHardy wrote:
> 
>>At this point the qdisc might send new packets. What do you do when a
>>packet for a full ring arrives?
>>
> 
> 
> Hrm... ok, is this a trick question or i am missing the obvious?;->
> What is wrong with what any driver would do today - which is:
> netif_stop and return BUSY; core requeues the packet?
> 
> 
>>I see three choices:
>>
>>- drop it, even though its still within the qdiscs configured limits
>>- requeue it, which does not work because the qdisc is still active
>>  and might just hand you the same packet over and over again in a
>>  busy loop, until the ring has more room (which has the same worst
>>  case, just that we're sitting in a busy loop now).
>>- requeue and stop the queue: we're back to where we started since
>>  now higher priority packets will not get passed to the driver.
> 
> 
> Refer to choice #4 above. 


Replying again so we can hopefully move forward soon. Your choice #4
is exactly what I proposed as choice number 3.

Let me repeat my example why it doesn't work (well) without multiple
queue states (with typos etc fixed) and describe the possibilities.
If you still disagree I hope you can just change my example to show
how it gets fixed. As a thank you I will actually understand that
your solution works as well :)

We have n empty HW queues served in ascending priority order
with a maximum length of m packets per queue:

[0] empty
[1] empty
[2] empty
..
[n-1] empty

Now we receive m - 1 packets for all priorities >= 1 and < n - 1,
so we have:

[0] empty
[1] m - 1 packets
[2] m - 1 packets
..
[n-2] m - 1 packets
[n-1] empty

Since no HW queue is completely full, the queue is still active.
Now we receive m packets of priority n - 1:

[0] empty
[1] m - 1 packets
[2] m - 1 packets
..
[n-2] m - 1 packets
[n-1] m packets

At this point the queue needs to be stopped since the highest
priority queue is entirely full. To start it again at least
one packet of queue n - 1 needs to be sent, which requires
that queues 1 to n - 2 are serviced first. So any prio 0 packet
arriving during this period will sit in the qdisc and will not
reach the device for up to the time for (n - 2) * (m - 1) + 1
full sized packet transmissions. With multiple queue states
we'd know that queue 0 can still take packets.

You agreed that this is a problem and instead of keeping the
queue stopped until all rings can take at least one packet
again you proposed:

> - let the driver shutdown whenever a ring is full. Remember which
>   ring X shut it down.
> - when you get a tx interupt or prun tx descriptors, if a
>   ring <= X has transmitted a packet (or threshold of packets),
>   then wake up the driver (i.e open up).

At this point the queue is active, but at least one ring is already
full and the qdisc can still pass packets for it to the driver.
When this happens we can:

- drop it. This makes qdisc configured limit meaningless since
  the qdisc can't anticipate when the packet will make it through
  or get dropped.

- requeue it: this might result in a busy loop if the qdisc
  decides to hand out the packet again. The loop will be
  terminated once the ring has more room available an can
  eat the packet, which has the same worst case behaviour
  I described above.

- requeue (return BUSY) and stop the queue: thats what you
  proposed as option #4. The question is when to wake the
  queue again. Your suggestion was to wake it when some
  other queue with equal or higher priority got dequeued.
  Correcting my previous statement, you are correct that
  this will fix the starvation of higher priority queues
  because the qdisc has a chance to hand out either a packet
  of the same priority or higher priority, but at the cost of
  at worst (n - 1) * m unnecessary dequeues+requeues in case
  there is only a packet of lowest priority and we need to
  fully serve all higher priority HW queues before it can
  actually be dequeued. The other possibility would be to
  activate the queue again once all rings can take packets
  again, but that wouldn't fix the problem, which you can
  easily see if you go back to my example and assume we still
  have a low priority packet within the qdisc when the lowest
  priority ring fills up (and the queue is stopped), and after
  we tried to wake it and stopped it again the higher priority
  packet arrives.

Considering your proposal in combination with RR, you can see
the same problem of unnecessary dequeues+requeues. Since there
is no priority for waking the queue when a equal or higher
priority ring got dequeued as in the prio case, I presume you
would wake the queue whenever a packet was sent. For the RR
qdisc dequeue after requeue should hand out the same packet,
independantly of newly enqueued packets (which doesn't happen
and is a bug in Peter's RR version), so in the worst case the
HW has to make the entire round before a packet can get
dequeued in case the corresponding HW queue is full. This is
a bit better than prio, but still up to n - 1 unnecessary
requeues+dequeues. I think it can happen more often than
for prio though.

> The patches are trivial - really; as soon as Peter posts the e1000
> change for his version i should be able to cutnpaste and produce one
> that will work with what i am saying.


Forgetting about things like multiple qdisc locks and just
looking at queueing behaviour, the question seems to come
down to whether the unnecessary dequeues/requeues are acceptable
(which I don't think since they are easily avoidable). OTOH
you could turn it around and argue that the patches won't do
much harm since ripping them out again (modulo queue mapping)
should result in the same behaviour with just more overhead.

