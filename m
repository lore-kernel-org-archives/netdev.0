From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Sun, 20 Feb 2005 14:43:59 -0800
Message-ID: <200502202244.j1KMinDD013572@guinness.s2io.com>
References: <m17jl2ncmu.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, "'Alex Aizman'" <alex@neterion.com>
To: "'Andi Kleen'" <ak@muc.de>, "'rick jones'" <rick.jones2@hp.com>
In-Reply-To: <m17jl2ncmu.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi,
This is an interesting idea, we'll play around...

BTW - does anybody know if it's possible to indicate multiple receive
packets?

In other OS drivers we have an option to indicate a "packet train" that got
received during an interrupt, but I'm not sure if/how it's doable in Linux.

We are adding Linux driver support for message-signaled interrupts and
header separation (just recently figured out how to indicate chained skb for
a packet that has IP and TCP headers separated by the ASIC);
If a packet train indication works then the driver could prefetch the
descriptor ring segment and also a rx buffer segment that holds headers
stored back-to-back, before indicating the train. 

Leonid

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Andi Kleen
> Sent: Sunday, February 20, 2005 1:30 PM
> To: rick jones
> Cc: netdev@oss.sgi.com
> Subject: Re: Intel and TOE in the news
> 
> rick jones <rick.jones2@hp.com> writes:
> 
> >> <speculating freely>
> >>
> >> It would be nice if the NIC could asynchronously trigger 
> prefetches 
> >> in the CPU. Currently a lot of the packet processing cost goes to 
> >> waiting for read cache misses.
> >>
> >> E.g.
> >>
> >> - NIC receives packet.
> >> - Tells target CPU to prefetch RX descriptor and headers.
> >> - CPU later looks at them and doesn't have to wait a for a 
> cache miss.
> >>
> >> Drawback is that you would need to tell the NIC in advance 
> on which 
> >> CPU you want to process the packet, but with Linux IRQ affinity 
> >> that's easy to figure out.
> >
> > With all the interrupt avoidance that is going-on these days, would 
> > prefetching in the driver be sufficient?  Presumably the driver is 
> > going to be processing multiple packets at a time on an 
> interrupt/etc 
> > so having it issue prefetches in SW would seem to help with all but 
> > the very first packet.
> 
> Yes, we came up with this idea some years ago too ;-). It was 
> even tried in some simple variants, but didn't work very well:
> 
> - The time between finding out you have a packet and it being 
> processed is often too short to make it worthwhile. That gets 
> worse with NAPI under high load.
> - You have to fetch the RX descriptor anyways to find out 
> where the packet memory is to prefetch the header, and that 
> is a cache miss too.
> (presumably you could keep a second sw only cache hot table 
> that allows to figure this out faster, that hasn't been tried so far)
> - It really requires a NIC that tells you in the RX 
> descriptor if a packet is IP (some do, but other popular ones don't). 
> Otherwise the network driver has to eat an early cache miss 
> anyways to read the 802.x protocol ID for passing the packet 
> up the network stack.
> (one possible fix for that would be to shift the protocol 
> parsing to later to avoid this, but that would be an 
> incompatible change in the driver interface) 
> 
> I guess with more intrusive changes Linux could do this better.
> e.g. if you have the cache hot secondary table and a really 
> cheap way to find out from the NIC on a interrupt how many 
> packets it accepted you could aggressive prefetching and do 
> the protocol lookup later with a callback to the driver. But 
> this has a problems too:
> 
> - Even on modern CPUs you cannot do too many prefetches in 
> parallel because you're overwhelming the load store units. At 
> some points new prefetches just get ignored. On older CPUs 
> this problem is even worse.
> 
> Jamal and Robert did some experiments with routing on this 
> and they ran also into this.
> 
> If the NIC initiated the transfers the bandwidth of the CPU 
> would be much more evenly used because the transfers are 
> spaced out in time as the packets arrive. Software prefetch 
> will be always bursty.
> 
> However I agree that probably some smaller software only 
> improvements could be still done in this area on Linux.
> 
> -Andi
> 
> 
