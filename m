From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 17:44:54 +0200
Message-ID: <466D6DF6.9060300@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net> <1181575549.4077.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45774 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbXFKPrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 11:47:24 -0400
In-Reply-To: <1181575549.4077.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 17:12 +0200, Patrick McHardy wrote:
> 
>>Worst cast is (n - 2) * (m - 1) + 1 full sized packet transmission
>>times.
>>
>>You can do the math yourself, but we're talking about potentially
>>a lot of packets.
> 
> 
> I agree if you use the strategy of "a ring shutdown down" implies
> "dont wake up until the ring that caused the shutdown opens up"
> What i am saying below is to make a change to that strategy.


Glad we agree on something. Now all I have to do is convince you that
a change to this strategy is not a good idea :)

>>>If you throw the burden to the driver (as i am recommending in all my
>>>arguements so far), it should open up sooner based on priorities.
>>>I didnt wanna bring this earlier because it may take the discussion in
>>>the wrong direction. 
>>>So in your example if n-1 shuts down the driver, then it is upto to the
>>>driver to open it up if any higher prio packet makes it out.
>>
>>
>>How could it do that? n-1 is still completely full and you don't
>>know what the next packet is going to be. Are you proposing to
>>simply throw the packet away in the driver even though its within
>>the configured limits of the qdisc?
> 
> 
> No no Patrick - i am just saying the following:
> - let the driver shutdown whenever a ring is full. Remember which ring X
> shut it down.
> - when you get a tx interupt or prun tx descriptors, if a ring <= X has
> transmitted a packet (or threshold of packets), then wake up the driver
> (i.e open up). 


At this point the qdisc might send new packets. What do you do when a
packet for a full ring arrives?

I see three choices:

- drop it, even though its still within the qdiscs configured limits
- requeue it, which does not work because the qdisc is still active
  and might just hand you the same packet over and over again in a
  busy loop, until the ring has more room (which has the same worst
  case, just that we're sitting in a busy loop now).
- requeue and stop the queue: we're back to where we started since
  now higher priority packets will not get passed to the driver.
