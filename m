From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 15:46:54 -0700 (PDT)
Message-ID: <20050512.154654.43008397.davem@davemloft.net>
References: <E1DWAZg-0006aD-00@gondolin.me.apana.org.au>
	<20050512.131349.32715242.davem@davemloft.net>
	<20050512214744.GA21958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050512214744.GA21958@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 07:47:44 +1000

> On Thu, May 12, 2005 at 01:13:49PM -0700, David S. Miller wrote:
> > One way to prevent that would be to do an skb_get() on every
> > SKB in the chain, but then we're back to the original problem
> > of all the extra atomic operations.
> 
> You're being frugal Dave :) I was happy with one skb_clone per
> skb and you're having problems with skb_get? :)
> 
> Seriously, we already do one skb_clone for every packet sent
> so we won't be incurring any extra overhead with this.

It's "relative to existing TSO" that this cost is.  For the existing
TSO handling we do one atomic ref for the entire TSO frame.  Now we're
going to do it for the N frames that a TSO packet is composed of.

So what this ends up meaning is that the new TSO code's only gain
(relative to non-TSO) will basically be that we:

1) Incur only one trip down the device XMIT path for N frames.
2) Only send one set of headers of the bus to the device.

Whereas the existing TSO support has a third benefit which is:

3) TSO frames are segmented as singular SKBs

This reduction in SKB allocations and subsequent handling is
non-trivial.

It has ramifications beyond the transmit path.  When the ACKs
come back in, we do less kfree_skb() calls, for example.  But
then again, we had all of that ugly TSO partial-ACK trimming
stuff.

I'm going to do some profiling to make sure it really matters.
