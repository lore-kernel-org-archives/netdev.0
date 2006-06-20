From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for	ATM/ADSL	(userspace)
Date: Tue, 20 Jun 2006 18:51:13 +0200
Message-ID: <44982781.8030301@trash.net>
References: <1150278040.26181.37.camel@localhost.localdomain>	 <1150282625.3490.23.camel@localhost.localdomain>	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>	 <1150376591.5116.36.camel@jzny2>	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>	 <1150812370.5270.27.camel@jzny2>  <44980A07.4050106@trash.net> <1150817922.5270.125.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Russell Stuart <russell-tcatm@stuart.id.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:13255 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751411AbWFTQwD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 12:52:03 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150817922.5270.125.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-20-06 at 16:45 +0200, Patrick McHardy wrote:
> 
>>Actually in the PPPoE case Linux doesn't know about ethernet
>>headers either, since shaping is usually done on the PPP device.
>>But that doesn't really matter since the ethernet link is not
>>the bottleneck - although it does add some delay for packetization.
> 
> 
> good point. But one could argue that is within linux (local) as opposed
> to something downstream at the ISP i.e. i have knowledge of it and i
> could do clever things. The other is: I have to know that the ISP is
> using pigeons as the link layer downstream and compensate for it.
> 
> The issue is really is whether Linux should be interested in the
> throughput it is told about or the goodput (also known as effective
> throughput) the service provider offers. Two different issues by
> definition. 


In the case of PPPoE non-work-conserving qdiscs are already used
to manage a link that is non-local with knowledge of the its
bandwidth, contrary to a local link that would be best managed
in work-conserving mode. And I think for better accuracy it is
necessary to manage effective throughput, especially if you're
interested in guaranteed delays.

>>>Yes, Linux cant tell if your service provider is lying to you.
>>
>>I wouldn't call it lying as long as they don't say "1.5mbps IP
>>layer throughput". 
> 
> 
> It is a scam for sure.
> By definition of what throughput is - you are telling the truth; just
> not the whole truth. Most users think in terms of goodput and not
> throughput. 
> i.e you are not telling the whole truth by not saying "it is 1.5Mbps ATM
> throughput". Tpyically not an issue until somebody finds that by leaving
> out "ATM" you meant throughput and not goodput. 


I think that point can be used to argue in favour of that Linux should
be able to manage effective throughput :)

>>Ethernet doesn't provide 100mbit IP layer
>>throughput either, and with minimum sized IP packets its actually
>>well below that.
>
> 
> OTOH, nobody has ethernet MTUs of 64 bytes.


Sure, but I might now want my HFSC class with guaranteed delay of 140us
to be distrurbed by someone sending small packets, that need more time
on the wire than HFSC thinks.

> To be academic and pedantic: The schedulers should be focusing on
> throughput and not goodput.
> Look at it from another angle related to the nature of the link layer
> used:
> If i buy a 1.5 Mbps 802.11JHS (such a link layer technology doesnt
> exist, but assume for the sake of arguement it does) from a wireless
> service provider, ethernet headers etc - but in this case the link is so
> bad (because of the link layer technology) i have to retransmit so much
> that 0.5 Mbps is wasted on retransmits, the question becomes: 
> 1)Do i fix the scheduler to compensate for this link layer retransmit?
> or
> 2)Do i find some other creative way to tell the scheduler that
> without making any changes to it that my ftp (despite the retransmits)
> should only chew 100Kbps.?
> 
> I am saying that #2 is the choice to go with hence my assertion earlier,
> it should be fine to tell the scheduler all it has is 1Mbps and nobody
> gets hurt. #1 if i could do it with minimal intrusion and still get to
> use it when i have 802.11g. 
> 
> Not sure i made sense.

HFSC is actually capable of handling this quite well. If you use it
in work-conserving mode (and the card doesn't do (much) internal
queueing) it will get clocked by successful transmissions. Using
link-sharing classes you can define proportions for use of available
bandwidth, possibly with upper limits. No hacks required :)

Anyway, this again goes more in the direction of handling link speed
changes.

>>A non intrusive way is prefered of course, but I can't really see
>>one if you want more than just a special-case solution that only
>>covers qdiscs using rate-tables and even ignores inner qdiscs.
>>HFSC and SFQ for example both need to calculate the wire length
>>at runtime.
>>
> 
> Agreed. That would be equivalent to #1 above.
> 
> 
>>Handling all qdiscs would mean adding a pointer to a mapping table
>>to struct net_device and using something like "skb_wire_len(skb, dev)"
>>instead of skb->len in the queueing layer. 
> 
> 
> That does seem sensible and simpler. I would suspect then that you will
> do this one time with something like
> ip dev add compensate_header 100 bytes

Something like that, but its a bit more complicated.
For ATM we need some mapping:
[0-48]  -> 53
[49-96] -> 106
...

for Ethernet we need:
[0-60] -> 64
[60-n] -> n + 4

We could do something like this (feel free to imagine nicer names):

ATM:
table = {
	.step = 53,
	.map = {
		[0..48] = 53,
		[49..96] = 106,
		...
	}
};

Requiring a table of size 32 for typical MTUs.

Ethernet:

table = {
	.step = 60,
	.map = {
		[0..60] = 60,
		[...] = 0,
	},
	.fixed_overhead = 4,
};

static inline unsigned int
skb_wire_len(struct sk_buff *skb, struct net_device *dev)
{
	unsigned int idx, len;

	if (dev->lengthtable == NULL)
		return skb->len;
	idx = skb->len / dev->lengthtable->step;
	len = dev->lengthtable->map[idx];
	return dev->lengthtable->fixed_overhead + len ? len : skb->len;
}

Unforunately I can't think of a way to handle the ATM case without
a division .. or iteration.

>>That of course doesn't
>>mean that we can't still provide pre-adjusted ratetables for qdiscs
>>that use them.
>>
> 
> 
> But what would the point be then if you can compensate as you did above?

It doesn't need runtime divisions :)
