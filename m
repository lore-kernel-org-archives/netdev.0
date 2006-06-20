From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for
	ATM/ADSL	(userspace)
Date: Tue, 20 Jun 2006 11:38:42 -0400
Message-ID: <1150817922.5270.125.camel@jzny2>
References: <1150278040.26181.37.camel@localhost.localdomain>
	 <1150282625.3490.23.camel@localhost.localdomain>
	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>
	 <1150376591.5116.36.camel@jzny2>
	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>
	 <1150812370.5270.27.camel@jzny2>  <44980A07.4050106@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:65505 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751328AbWFTPiq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 11:38:46 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FsiJU-000395-OW
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 11:38:48 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44980A07.4050106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 16:45 +0200, Patrick McHardy wrote:
> jamal wrote:

[..]

> Actually in the PPPoE case Linux doesn't know about ethernet
> headers either, since shaping is usually done on the PPP device.
> But that doesn't really matter since the ethernet link is not
> the bottleneck - although it does add some delay for packetization.

good point. But one could argue that is within linux (local) as opposed
to something downstream at the ISP i.e. i have knowledge of it and i
could do clever things. The other is: I have to know that the ISP is
using pigeons as the link layer downstream and compensate for it.

The issue is really is whether Linux should be interested in the
throughput it is told about or the goodput (also known as effective
throughput) the service provider offers. Two different issues by
definition. 

> > Yes, Linux cant tell if your service provider is lying to you.
> 
> I wouldn't call it lying as long as they don't say "1.5mbps IP
> layer throughput". 

It is a scam for sure.
By definition of what throughput is - you are telling the truth; just
not the whole truth. Most users think in terms of goodput and not
throughput. 
i.e you are not telling the whole truth by not saying "it is 1.5Mbps ATM
throughput". Tpyically not an issue until somebody finds that by leaving
out "ATM" you meant throughput and not goodput. 

> Ethernet doesn't provide 100mbit IP layer
> throughput either, and with minimum sized IP packets its actually
> well below that.
> 

OTOH, nobody has ethernet MTUs of 64 bytes.

> >>The issue here is, that ATM does not have fixed overhead (due to alignment 
> >>and padding).  This means that a fixed reduction of the bandwidth is not 
> >>the solution.  We could reduce the bandwidth to the worst-case overhead, 
> >>which is 62%, I do not think that is a good solution...
> >>
> > 
> > I dont see it as wrong to be honest with you. Your mileage may vary.
> 
> Its wasteful, and it can be avoided.
> 

If it can be avoided by being generic and without being intrusive, then
by all means.

> > Dont have time to read your doc and dont get me wrong, there is a
> > "quark" practical problem: As practical as the hard disk manufacturer
> > who claims that they have 11G drive when it is 10G. It needs to be
> > resolved - but not in an intrusive way in my opinion.
> 
> Not sure what a "quark" problem is .. but I think you're focusing
> too much on the aspect of "somebody is lying, not our fault".

No no - that is not my intent; sorry if it comes out that way. 
I am saying there is a practical "problem". The problem being someone is
equating throughput to effective throughput (also know as goodput).

To be academic and pedantic: The schedulers should be focusing on
throughput and not goodput.
Look at it from another angle related to the nature of the link layer
used:
If i buy a 1.5 Mbps 802.11JHS (such a link layer technology doesnt
exist, but assume for the sake of arguement it does) from a wireless
service provider, ethernet headers etc - but in this case the link is so
bad (because of the link layer technology) i have to retransmit so much
that 0.5 Mbps is wasted on retransmits, the question becomes: 
1)Do i fix the scheduler to compensate for this link layer retransmit?
or
2)Do i find some other creative way to tell the scheduler that
without making any changes to it that my ftp (despite the retransmits)
should only chew 100Kbps.?

I am saying that #2 is the choice to go with hence my assertion earlier,
it should be fine to tell the scheduler all it has is 1Mbps and nobody
gets hurt. #1 if i could do it with minimal intrusion and still get to
use it when i have 802.11g. 

Not sure i made sense.

> This is a real problem for any medium that adds link-layer headers.
> ATM is not even very special, the only thing special about it is
> that it has multiple "steps". But maybe I'm misunderstanding you,
> it has happened before :)
> 

I am not sure if i am making more sense now ;->

> A non intrusive way is prefered of course, but I can't really see
> one if you want more than just a special-case solution that only
> covers qdiscs using rate-tables and even ignores inner qdiscs.
> HFSC and SFQ for example both need to calculate the wire length
> at runtime.
> 

Agreed. That would be equivalent to #1 above.

> Handling all qdiscs would mean adding a pointer to a mapping table
> to struct net_device and using something like "skb_wire_len(skb, dev)"
> instead of skb->len in the queueing layer. 

That does seem sensible and simpler. I would suspect then that you will
do this one time with something like
ip dev add compensate_header 100 bytes

> That of course doesn't
> mean that we can't still provide pre-adjusted ratetables for qdiscs
> that use them.
> 

But what would the point be then if you can compensate as you did above?

Anyways, I have to go and meet The Man and i feel like i have hijacked
netdev this morning. So ttl.

cheers,
jamal

