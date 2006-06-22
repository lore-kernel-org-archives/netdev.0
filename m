From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling
	for	ATM/ADSL	(userspace)
Date: Thu, 22 Jun 2006 15:02:11 -0400
Message-ID: <1151002931.5392.69.camel@jzny2>
References: <1150278040.26181.37.camel@localhost.localdomain>
	 <1150282625.3490.23.camel@localhost.localdomain>
	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>
	 <1150376591.5116.36.camel@jzny2>
	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>
	 <1150812370.5270.27.camel@jzny2>  <44980A07.4050106@trash.net>
	 <1150817922.5270.125.camel@jzny2>  <44982781.8030301@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:59057 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1161205AbWFVTCR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 15:02:17 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FtURZ-0007m3-IB
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 15:02:21 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44982781.8030301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 18:51 +0200, Patrick McHardy wrote:
> jamal wrote:

> > The issue is really is whether Linux should be interested in the
> > throughput it is told about or the goodput (also known as effective
> > throughput) the service provider offers. Two different issues by
> > definition. 

> In the case of PPPoE non-work-conserving qdiscs are already used
> to manage a link that is non-local with knowledge of the its
> bandwidth, 

I think that is a different issue though- you are managing a
point-to-point link then you will be working under the assumption of 
throughput not goodput. 

If you had knowledge of the goodput you should use that for a working
assumption; i think in practise that approach is valuable.
My arguement is against trying to make complex changes to compensate
the scheduler for such changes. Therefore i am not feeling sorry
for the poor guy who has to go and tell their PPP device "bandwith is 
only 1Mbps" when their ISP is claiming it is 2Mbps i.e
 
The ADSL case i have seen thus far is you trying manage something
because a BRAS 3-4 hops down the path uses ATM. To use my earlier
example the arguement is no different than saying 3-4 hops downlink
there is a wireless link which is 20% lossy. Armed with knowledge
like that you can tell something to the scheduler to resolve thing.
The daemon in user space for example could be sending bandwidth
measuring probes and telling the kernel of the new goodput.

> contrary to a local link that would be best managed
> in work-conserving mode. And I think for better accuracy it is
> necessary to manage effective throughput, especially if you're
> interested in guaranteed delays.
> 

Indeed - but "fixing" the scheduler to achieve such management is not
the first choice (would be fine if it is generic and non-intrusive)

> >>>Yes, Linux cant tell if your service provider is lying to you.
> >>
> >>I wouldn't call it lying as long as they don't say "1.5mbps IP
> >>layer throughput". 
> > 
> > 
> > It is a scam for sure.
> > By definition of what throughput is - you are telling the truth; just
> > not the whole truth. Most users think in terms of goodput and not
> > throughput. 
> > i.e you are not telling the whole truth by not saying "it is 1.5Mbps ATM
> > throughput". Tpyically not an issue until somebody finds that by leaving
> > out "ATM" you meant throughput and not goodput. 
> 
> 
> I think that point can be used to argue in favour of that Linux should
> be able to manage effective throughput :)
> 

I think you have convinced me this is valuable I even suggest probes
above to discover goodput;-). I hope i have convinced you how rude it
would be to make extensive changes to compensate for goodput;->

> > I am saying that #2 is the choice to go with hence my assertion earlier,
> > it should be fine to tell the scheduler all it has is 1Mbps and nobody
> > gets hurt. #1 if i could do it with minimal intrusion and still get to
> > use it when i have 802.11g. 
> > 
> > Not sure i made sense.
> 
> HFSC is actually capable of handling this quite well. If you use it
> in work-conserving mode (and the card doesn't do (much) internal
> queueing) it will get clocked by successful transmissions. Using
> link-sharing classes you can define proportions for use of available
> bandwidth, possibly with upper limits. No hacks required :)
> 

HFSC sounds very interesting - I should go and study it a little more.
My understanding is though that it is a bit of a CPU pig, true?

> Anyway, this again goes more in the direction of handling link speed
> changes.
> 

The more we discuss this, the more i think they are the same thing ;->


> > ip dev add compensate_header 100 bytes
> 
> Something like that, but its a bit more complicated.
> For ATM we need some mapping:
> [0-48]  -> 53
> [49-96] -> 106
> ...
> 
> for Ethernet we need:
> [0-60] -> 64
> [60-n] -> n + 4
> 

an upper bound check against MTU would be reasonable. 

> We could do something like this (feel free to imagine nicer names):
> 

The name should reflect that the table exists to "compensate for
goodput".

> ATM:
> table = {
> 	.step = 53,
> 	.map = {
> 		[0..48] = 53,
> 		[49..96] = 106,
> 		...
> 	}
> };
> 
> Requiring a table of size 32 for typical MTUs.
> 
> Ethernet:
> 
> table = {
> 	.step = 60,
> 	.map = {
> 		[0..60] = 60,
> 		[...] = 0,
> 	},
> 	.fixed_overhead = 4,
> };
> 
> static inline unsigned int
> skb_wire_len(struct sk_buff *skb, struct net_device *dev)
> {
> 	unsigned int idx, len;
> 
> 	if (dev->lengthtable == NULL)
> 		return skb->len;
> 	idx = skb->len / dev->lengthtable->step;
> 	len = dev->lengthtable->map[idx];
> 	return dev->lengthtable->fixed_overhead + len ? len : skb->len;
> }
> 
> Unforunately I can't think of a way to handle the ATM case without
> a division .. or iteration.
> 

I am not thinking straight right now but it does not sound like a big
change to me i.e within reason. Note, it may be valuable to think of
this as related to the speed changing daemon as i stated earlier.
Only in this case it is "static" discovery of link layer
goodput/throughput vs some other way to dynamically discover things. 

cheers,
jamal

