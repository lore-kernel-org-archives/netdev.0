From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 17:12:59 +0200
Message-ID: <466D667B.6050108@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net> <1181574306.4077.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45018 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbXFKPPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 11:15:30 -0400
In-Reply-To: <1181574306.4077.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 16:49 +0200, Patrick McHardy wrote:
> 
>>We have n empty HW queues with a maximum length of m packets per queue:
>>
>>[0] empty
>>[1] empty
>>[2] empty
>>..
>>[n-1] empty
>
> 
> Asumming 0 i take it is higher prio than n-1.


Yes.

>>Now we receive m - 1 packets for each all priorities >= 1 and < n - 1,
>>so we have:
>>
>>[0] empty
>>[1] m - 1 packets
>>[2] m - 1 packets
>>..
>>[n-2] m - 1 packets
>>[n] empty
>>
>>Since no queue is completely full, the queue is still active.
>>Now we receive m packets of priorty n:
> 
> 
> n-1 (i think?)


Right.

>>[0] empty
>>[1] m - 1 packets
>>[2] m - 1 packets
>>..
>>[n-2] m - 1 packets
>>[n-1] m packets
>>
>>At this point the queue needs to be stopped since the highest
>>priority queue is entirely full. 
> 
> 
> ok, so 0 is lower prio than n-1 


Higher priority. But we don't know what the priority of the
next packet is going to be, so we have to stop the entire
qdisc anyway.

>>To start it again at least one packet of queue n - 1 needs to be sent, 
> 
> 
> following so far ...
> 
> 
>>which (assuming
>>strict priority) requires that queues 1 to n - 2 are serviced
>>first. 
> 
> 
> Ok, so let me revert that; 0 is higher prio than n-1.


Yes.

>>So any prio 0 packets arriving during this period will
>>sit in the qdisc and will not reach the device for a possibly
>>quite long time. 
> 
> 
> "possibly long time" is where we diverge ;->

Worst cast is (n - 2) * (m - 1) + 1 full sized packet transmission
times.

You can do the math yourself, but we're talking about potentially
a lot of packets.

> If you throw the burden to the driver (as i am recommending in all my
> arguements so far), it should open up sooner based on priorities.
> I didnt wanna bring this earlier because it may take the discussion in
> the wrong direction. 
> So in your example if n-1 shuts down the driver, then it is upto to the
> driver to open it up if any higher prio packet makes it out.


How could it do that? n-1 is still completely full and you don't
know what the next packet is going to be. Are you proposing to
simply throw the packet away in the driver even though its within
the configured limits of the qdisc?
