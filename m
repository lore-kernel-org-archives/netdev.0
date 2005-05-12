From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 13:13:49 -0700 (PDT)
Message-ID: <20050512.131349.32715242.davem@davemloft.net>
References: <20050511.223036.39664020.davem@davemloft.net>
	<E1DWAZg-0006aD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DWAZg-0006aD-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 20:05:48 +1000

> What we could do is get the TSO drivers to all implement NETIF_F_FRAGLIST.
> Once they do that, you can simply chain up the skb's and send it off to
> them.  The coalescing will need to be done in the drivers.  However, that's
> not too bad because coalescing only has to be done at the skb boundaries.
> 
> In fact, this is how we can simplify the unwinding stuff in your
> skb_append_pages function.  Because the coalescing only needs to occur
> between skb's, you only need to check the first frag to know whether it
> can be coalesced or not.  This means that the unwinding stuff can mostly
> go away.
> 
> We'll have to watch out for retransmissions of the frame with a non-null
> frag_list pointer.  They will need to be copied if their clone is still
> hanging around.

Yes, we can just add a frag_list pointer check to the skb_cloned()
tests we do when cons'ing up retransmit SKBs for tcp_transmit_skb().

But this still has the early free problem, I think.  If an ACK
comes in which releases an SKB on the chain, while the driver
is still working with that chain, we cannot free the SKB.  We
have to do it some time later.

One way to prevent that would be to do an skb_get() on every
SKB in the chain, but then we're back to the original problem
of all the extra atomic operations.

A secondary point is that I'd like to use a name other than
NETIF_F_FRAGLIST because people are super confused as to what this
device flag even means.  Some people confuse it with NETIF_F_SG,
others thing it takes a huge UDP frame and fragments it into MTU sized
IP frames and checksums the whole thing.  None of which are true.

Loopback is the only driver which supports this properly, by
simply doing nothing with the packet :-)

So back to the main point, we are in quite a conundrum.  The whole
point of TSO is to offload the segmentation overhead, but we're in
fact making the TCP output engine more expensive for the TSO path.

I've also considered a longer term idea where we store the write queue
in some minimal abstract format, instead of a list of SKBs.  Just a
data collection and some sequence numbers.  But that would be a huge
change with questionable gains.
