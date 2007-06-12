From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 22:29:44 -0400
Message-ID: <1181615384.4071.121.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>
	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>
	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>
	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>
	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net>
	 <1181597718.4071.12.camel@localhost>  <466DEF9D.9070509@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:30342 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbXFLC3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 22:29:49 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1480011nzf
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 19:29:48 -0700 (PDT)
In-Reply-To: <466DEF9D.9070509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry - i was distracted elsewhere and didnt respond to your
earlier email; this one seems a superset.

On Tue, 2007-12-06 at 02:58 +0200, Patrick McHardy wrote:
> jamal wrote:
> > On Mon, 2007-11-06 at 17:44 +0200, Patrick McHardy wrote:

[use case abbreviated..]
the use case is sensible.

> the qdisc has a chance to hand out either a packet
>   of the same priority or higher priority, but at the cost of
>   at worst (n - 1) * m unnecessary dequeues+requeues in case
>   there is only a packet of lowest priority and we need to
>   fully serve all higher priority HW queues before it can
>   actually be dequeued. 

yes, i see that. 
[It actually is related to the wake threshold you use in the 
driver. tg3 and e1000 for example will do it after 30 or so packets.
But i get your point - what you are trying to describe is a worst case
scenario].

>   The other possibility would be to
>   activate the queue again once all rings can take packets
>   again, but that wouldn't fix the problem, which you can
>   easily see if you go back to my example and assume we still
>   have a low priority packet within the qdisc when the lowest
>   priority ring fills up (and the queue is stopped), and after
>   we tried to wake it and stopped it again the higher priority
>   packet arrives.

In your use case, only low prio packets are available on the stack.
Above you mention arrival of high prio - assuming thats intentional and
not it being late over there ;->
If higher prio packets are arriving on the qdisc when you open up, then
given strict prio those packets get to go to the driver first until
there are no more left; followed of course by low prio which then
shutdown the path again...

> Considering your proposal in combination with RR, you can see
> the same problem of unnecessary dequeues+requeues. 

Well, we havent really extended the use case from prio to RR.
But this is a good start as any since all sorts of work conserving
schedulers will behave in a similar fashion ..

> Since there
> is no priority for waking the queue when a equal or higher
> priority ring got dequeued as in the prio case, I presume you
> would wake the queue whenever a packet was sent. 

I suppose that is a viable approach if the hardware is RR based.
Actually in the case of e1000 it is WRR not plain RR, but that is a
moot point which doesnt affect the discussion.

> For the RR
> qdisc dequeue after requeue should hand out the same packet,
> independantly of newly enqueued packets (which doesn't happen
> and is a bug in Peter's RR version), so in the worst case the
> HW has to make the entire round before a packet can get
> dequeued in case the corresponding HW queue is full. This is
> a bit better than prio, but still up to n - 1 unnecessary
> requeues+dequeues. I think it can happen more often than
> for prio though.

I think what would better to be use is DRR. I pointed the code i did
a long time ago to Peter. 
With DRR, a deficit is viable to be carried forward.

> Forgetting about things like multiple qdisc locks and just
> looking at queueing behaviour, the question seems to come
> down to whether the unnecessary dequeues/requeues are acceptable
> (which I don't think since they are easily avoidable).

As i see it, the worst case scenario would have a finite time.
A 100Mbps NIC should be able to dish out, depending on packet size,
148Kpps to 8.6Kpps; a GigE 10x that.
so i think the phase in general wont last that long given the assumption
is packets are coming in from the stack to the driver with about the
packet rate equivalent to wire rate (for the case of all work conserving
schedulers).
In the general case there should be no contention at all.

>  OTOH
> you could turn it around and argue that the patches won't do
> much harm since ripping them out again (modulo queue mapping)
> should result in the same behaviour with just more overhead.

I am not sure i understood - but note that i have asked for a middle
ground from the begining. 

Thanks again for the patience and taking the time to go over this.

cheers,
jamal

