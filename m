From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 00:07:13 +0100
Message-ID: <20050220230713.GA62354@muc.de>
References: <m17jl2ncmu.fsf@muc.de> <200502202244.j1KMinDD013572@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
Date: Mon, 21 Feb 2005 00:07:13 +0100
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200502202244.j1KMinDD013572@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 20, 2005 at 02:43:59PM -0800, Leonid Grossman wrote:
> This is an interesting idea, we'll play around...

What exactly? The software only shadow table?

> 
> BTW - does anybody know if it's possible to indicate multiple receive
> packets?
> 
> In other OS drivers we have an option to indicate a "packet train" that got
> received during an interrupt, but I'm not sure if/how it's doable in Linux.

You can always call netif_rx() multiple times from the interrupt. The
function doesn't do the full packet processing,  but just stuffs the packet 
into a CPU queue that is processed at a lower priority interrupt (softirq). 
Doesn't work for NAPI unfortunately though; netif_receive_skb always
does the protocol stack.

> We are adding Linux driver support for message-signaled interrupts and
> header separation (just recently figured out how to indicate chained skb for

I had an experimental patch to enable MSI (without -X) for your cards,
but didn't push it out because i wasn't too happy with it.

Most interesting would be to use per CPU TX completion interrupts using
MSI-X and avoid bouncing packets around between CPUs.

> a packet that has IP and TCP headers separated by the ASIC);
> If a packet train indication works then the driver could prefetch the
> descriptor ring segment and also a rx buffer segment that holds headers
> stored back-to-back, before indicating the train. 

Me and Jamal tried that some time ago, but it did not help too much.
Probably because the protocol process overhead was not big enough.
However that was with NAPI, might be perhaps worth trying without
it. 

Problem is that need to fill in skb->protocol/pkt_type before you can pass
the packet up; you can perhaps derive it from the RX descriptor (card has a 
bit that says "this is IP" and "its unicast for my MAC"). 
But the RX descriptor access is already a cache miss that stalls you.  

To make the prefetching work well for this would probably require a callback
to the driver so that you can do this later after your prefetch succeeded.

-Andi
