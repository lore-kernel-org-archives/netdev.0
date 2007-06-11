From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 16:49:41 +0200
Message-ID: <466D6105.9050305@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net> <1181572815.4077.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44494 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbXFKOwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 10:52:11 -0400
In-Reply-To: <1181572815.4077.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 16:03 +0200, Patrick McHardy wrote:
> 
>>Read again what I wrote about the n > 2 case. Low priority queues might
>>starve high priority queues when using a single queue state for a
>>maximum of the time it takes to service n - 2 queues with max_qlen - 1
>>packets queued plus the time for a single packet. Thats assuming the
>>worst case of n - 2 queues with max_qlen - 1 packets and the lowest
>>priority queue full, so the queue is stopped until we can send at
>>least one lowest priority packet, which requires to fully service
>>all higher priority queues previously.
> 
> 
> I didnt quiet follow the above - I will try retrieving reading your
> other email to see if i can make sense of it. 


Let me explain with some ASCII art :)

We have n empty HW queues with a maximum length of m packets per queue:

[0] empty
[1] empty
[2] empty
..
[n-1] empty

Now we receive m - 1 packets for each all priorities >= 1 and < n - 1,
so we have:

[0] empty
[1] m - 1 packets
[2] m - 1 packets
..
[n-2] m - 1 packets
[n] empty

Since no queue is completely full, the queue is still active.
Now we receive m packets of priorty n:

[0] empty
[1] m - 1 packets
[2] m - 1 packets
..
[n-2] m - 1 packets
[n-1] m packets

At this point the queue needs to be stopped since the highest
priority queue is entirely full. To start it again at least
one packet of queue n - 1 needs to be sent, which (assuming
strict priority) requires that queues 1 to n - 2 are serviced
first. So any prio 0 packets arriving during this period will
sit in the qdisc and will not reach the device for a possibly
quite long time. With multiple queue states we'd know that
queue 0 can still take packets.

>>Your basic assumption seems to be that the qdisc is still in charge
>>of when packets get sent. This isn't the case if there is another
>>scheduler after the qdisc and there is contention in the second
>>queue.
> 
> 
> My basic assumption is if you use the same scheduler in both the
> hardware and qdisc, configured the same same number of queues and
> mapped the same priorities then you dont need to make any changes
> to the qdisc code. If i have a series of routers through which a packet
> traveses to its destination with the same qos parameters i also achieve
> the same results.


Did my example above convince you that this is not the case?

