From: "David S. Miller" <davem@davemloft.net>
Subject: Re: issue with new TCP TSO stuff
Date: Thu, 12 May 2005 16:24:26 -0700 (PDT)
Message-ID: <20050512.162426.75782784.davem@davemloft.net>
References: <20050512221046.GA22136@gondor.apana.org.au>
	<20050512.155230.132927874.davem@davemloft.net>
	<20050512231038.GA22440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050512231038.GA22440@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 09:10:38 +1000

> However, I think you're right that this does have some fundamental
> overheads compared to the existing TSO code which we can't remove.
> 
> More specifically, the existing TSO code really does avoid
> segmentation in that no MTU-sized skb's are allocated unless
> the congestion window requires that to be done.  The new code
> will always allocate MTU-sized skb's no matter what.
> 
> The ideal solution should bring the best of both worlds :) That is,
> no segmentation on output unless required by the congestion window,
> while at the same time avoiding the tcp_skb_pcount logic.

Right.

Ok, the two true downfalls of the current TSO code are:

1) It does not attempt to predict what the CWND will
   be at packet output time.  So smaller than ideal
   TSO frames are built.
2) Packet loss is not handled gracefully, in fact TSO
   is disabled when this happens :-)

So, I'm mentioning this because it may end up being better to try and
solve those two problems instead of going to my new stuff.

#2 could be handled by down-sizing TSO frames when packet loss occurs.
Ie. tcp_retransmit_skb() or whatever will segmentize a TSO packet
which is within the sequence it is trying to retransmit.  Implementing
this is non- trivial mostly due to the fact that it has to work handle
GFP_ATOMIC memory failures and also get all the pcount crap correct.

#1 is more tricky, and is the main reason I explored the "TSO
Reloaded" idea.  I wonder if we could just build enormous TSO frames
_always_.  We pass down these huge things to the output path, with a
struct sk_buff local offset and size.  That way, if the packet is too
large for the congestion window, we're fine, we just set the offset
and size appropriately.  I think the tcp_snd_test() simplifications
made by my TSO Reloaded patch would help a lot here.  The send test is
logically now split to it's two tests 1) whether to send anything at
all, and 2) once #1 passes, how many such packets.

This would be a sort of super-TSO that would do less segmenting work
than even a "perfect" TSO segmenter would.

I'm still not sure which approach is best, just throwing around some
ideas.
