From: "Alex Aizman" <alex@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Sun, 20 Feb 2005 17:57:56 -0800
Message-ID: <200502210158.j1L1wcDD004318@guinness.s2io.com>
References: <20050220230713.GA62354@muc.de>
Reply-To: <alex@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>
To: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>
In-Reply-To: <20050220230713.GA62354@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> You can always call netif_rx() multiple times from the 
> interrupt. 

That's what we do, simply because interrupts are coalesced. 

> The function doesn't do the full packet 
> processing,  but just stuffs the packet into a CPU queue that 
> is processed at a lower priority interrupt (softirq). 

There's the netif_rx's own per-packet overhead (including the call itself)
that arguably could be optimized..

> Most interesting would be to use per CPU TX completion 
> interrupts using MSI-X and avoid bouncing packets around between CPUs.

Our experimental Linux driver already supports MSI and MSI-X (the latter not
tested). Once/if multi-MSI support in Linux becomes available it'd be
practically possible to scale TCP connections with a number of CPUs.
Alternative: wait until Xframe II adapter w/MSI-X.. 


Alex

> -----Original Message-----
> From: Andi Kleen [mailto:ak@muc.de] 
> Sent: Sunday, February 20, 2005 3:07 PM
> To: Leonid Grossman
> Cc: 'rick jones'; netdev@oss.sgi.com; 'Alex Aizman'
> Subject: Re: Intel and TOE in the news
> 
> On Sun, Feb 20, 2005 at 02:43:59PM -0800, Leonid Grossman wrote:
> > This is an interesting idea, we'll play around...
> 
> What exactly? The software only shadow table?
> 
> > 
> > BTW - does anybody know if it's possible to indicate 
> multiple receive 
> > packets?
> > 
> > In other OS drivers we have an option to indicate a "packet train" 
> > that got received during an interrupt, but I'm not sure 
> if/how it's doable in Linux.
> 
> You can always call netif_rx() multiple times from the 
> interrupt. The function doesn't do the full packet 
> processing,  but just stuffs the packet into a CPU queue that 
> is processed at a lower priority interrupt (softirq). 
> Doesn't work for NAPI unfortunately though; netif_receive_skb 
> always does the protocol stack.
> 
> > We are adding Linux driver support for message-signaled 
> interrupts and 
> > header separation (just recently figured out how to 
> indicate chained 
> > skb for
> 
> I had an experimental patch to enable MSI (without -X) for 
> your cards, but didn't push it out because i wasn't too happy with it.
> 
> Most interesting would be to use per CPU TX completion 
> interrupts using MSI-X and avoid bouncing packets around between CPUs.
> 
> > a packet that has IP and TCP headers separated by the ASIC); If a 
> > packet train indication works then the driver could prefetch the 
> > descriptor ring segment and also a rx buffer segment that holds 
> > headers stored back-to-back, before indicating the train.
> 
> Me and Jamal tried that some time ago, but it did not help too much.
> Probably because the protocol process overhead was not big enough.
> However that was with NAPI, might be perhaps worth trying without it. 
> 
> Problem is that need to fill in skb->protocol/pkt_type before 
> you can pass the packet up; you can perhaps derive it from 
> the RX descriptor (card has a bit that says "this is IP" and 
> "its unicast for my MAC"). 
> But the RX descriptor access is already a cache miss that 
> stalls you.  
> 
> To make the prefetching work well for this would probably 
> require a callback to the driver so that you can do this 
> later after your prefetch succeeded.
> 
> -Andi
> 
> 
