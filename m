From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for ATM/ADSL	(userspace)
Date: Tue, 20 Jun 2006 16:45:27 +0200
Message-ID: <44980A07.4050106@trash.net>
References: <1150278040.26181.37.camel@localhost.localdomain>	 <1150282625.3490.23.camel@localhost.localdomain>	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>	 <1150376591.5116.36.camel@jzny2>	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk> <1150812370.5270.27.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42684 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751166AbWFTOpa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:45:30 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150812370.5270.27.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Heres the standard setup as i understand it(at least in north america, I
> know Europeans love their ATM with a little gravy on top):
> 
>                                                                        
> |Linux| --ethernet-- |Modem| --DSL-- |DSLAM| --ATM-- |BRAS| 
> 
>     
> What this means is that Linux computes based on ethernet
> headers. Somewhere downstream ATM (refer to above) comes in and that
> causes mismatch in what Linux expects to be the bandwidth and what
> your service provider who doesnt account for the ATM overhead when
> they sell you "1.5Mbps".

Actually in the PPPoE case Linux doesn't know about ethernet
headers either, since shaping is usually done on the PPP device.
But that doesn't really matter since the ethernet link is not
the bottleneck - although it does add some delay for packetization.

> Yes, Linux cant tell if your service provider is lying to you.

I wouldn't call it lying as long as they don't say "1.5mbps IP
layer throughput". Ethernet doesn't provide 100mbit IP layer
throughput either, and with minimum sized IP packets its actually
well below that.

>>The patch is the solution to the classical problem people 
>>have when tryng to configure traffic control on an ADSL link?
>>
>>Q: The packet scheduling does not work all the time?
>>A: Try to decrease to bandwidth.
>>
>>
>>The issue here is, that ATM does not have fixed overhead (due to alignment 
>>and padding).  This means that a fixed reduction of the bandwidth is not 
>>the solution.  We could reduce the bandwidth to the worst-case overhead, 
>>which is 62%, I do not think that is a good solution...
>>
> 
> I dont see it as wrong to be honest with you. Your mileage may vary.

Its wasteful, and it can be avoided.

> Dont have time to read your doc and dont get me wrong, there is a
> "quark" practical problem: As practical as the hard disk manufacturer
> who claims that they have 11G drive when it is 10G. It needs to be
> resolved - but not in an intrusive way in my opinion.

Not sure what a "quark" problem is .. but I think you're focusing
too much on the aspect of "somebody is lying, not our fault".
This is a real problem for any medium that adds link-layer headers.
ATM is not even very special, the only thing special about it is
that it has multiple "steps". But maybe I'm misunderstanding you,
it has happened before :)

A non intrusive way is prefered of course, but I can't really see
one if you want more than just a special-case solution that only
covers qdiscs using rate-tables and even ignores inner qdiscs.
HFSC and SFQ for example both need to calculate the wire length
at runtime.

Handling all qdiscs would mean adding a pointer to a mapping table
to struct net_device and using something like "skb_wire_len(skb, dev)"
instead of skb->len in the queueing layer. That of course doesn't
mean that we can't still provide pre-adjusted ratetables for qdiscs
that use them.

