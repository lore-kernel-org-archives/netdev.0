From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Sun, 20 Feb 2005 19:31:55 -0800
Message-ID: <200502210332.j1L3WkDD014744@guinness.s2io.com>
References: <20050220230713.GA62354@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>,
        "'Alex Aizman'" <alex@neterion.com>
To: "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>
In-Reply-To: <20050220230713.GA62354@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Andi Kleen
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

Yes, this is what we currently do; I was rather thinking about the option to
indicate multiple packets in a single call (say as a linked list). 
Alternative (rather, complimentary) approach is to collapse consecutive
packets from the same session in a single large frame; we are going to try
this as well since the ASIC has hw assists for that.

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

We have single MSI working now. Jeff - thanks for the pointer to multiple
MSI usage in IB, we will have a look (to catch up with the times :-). 
I guess MSIs are not that interesting in themselves - it's more what the
driver can do with them to optimize tx/rx processing... 

> Most interesting would be to use per CPU TX completion 
> interrupts using MSI-X and avoid bouncing packets around between CPUs.

Do you mean indicating rx packets to the same cpu that tx (for the same
session) came from, or something else?

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

Instead of requiring a callback, a driver can prefetch descriptors and
headers for the packets that are going to be processed on the next interrupt
- by then, prefetch will likely succeed.

Leonid  

> 
> -Andi
> 
> 
> 
