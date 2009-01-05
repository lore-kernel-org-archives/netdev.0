From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Mon, 5 Jan 2009 14:21:41 +0100
Message-ID: <20090105132141.GO496@one.firstfloor.org>
References: <20090104151819.GA6590@basil.nowhere.org> <1231085150.3296.3.camel@johannes> <20090104162826.GT496@one.firstfloor.org> <1231087288.3296.15.camel@johannes> <20090104174339.GX496@one.firstfloor.org> <1231090388.3296.17.camel@johannes> <20090104184136.GY496@one.firstfloor.org> <1231144574.3286.15.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com,
	davem <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44435 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbZAENHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:07:51 -0500
Content-Disposition: inline
In-Reply-To: <1231144574.3286.15.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 09:36:14AM +0100, Johannes Berg wrote:
> On Sun, 2009-01-04 at 19:41 +0100, Andi Kleen wrote:
> 
> > I think most adjustments are too small to be noticed. Typically
> > they are just for a few bytes in the header. truesize
> > is already larger, so it can tolerate some slag.
> 
> This statement is incompatible with your patch when you think about the
> exact definition of truesize and the (unconditional!) adjustments your
> patch makes.

__alloc_skb does 

        size = SKB_DATA_ALIGN(size);
        skb->truesize = size + sizeof(struct sk_buff);

[ BTW it would be probably better if alloc_skb() just asked
slab what the truesize is for kmalloc instead of guessing wrong like this.
But that's a different topic]

and SKB_DATA_ALIGN is 

#define SKB_DATA_ALIGN(X)       (((X) + (SMP_CACHE_BYTES - 1)) & \
                                 ~(SMP_CACHE_BYTES - 1))

and on my configuration SMP_CACHE_BYTES is 64

skb_truesize_check does 

 int len = sizeof(struct sk_buff) + skb->len;

        if (unlikely((int)skb->truesize < len))
                skb_truesize_bug(skb);

This means if the change is less than the 64byte cache alignment 
(or more commonly 128 bytes on GENERIC_CPU distro kernels)
it won't be reported. To my knowledge header adjustments are usually
smaller and that is what pskb_expand_head() is usually used for.


> > I also only see it occasionally (maybe 5-10 times/day) when
> > the wireless stack appends a lot of data.
> 
> Except the data it appends should generally be of the same or very
> similar size under unchanging conditions, so that doesn't make a lot of
> sense either.

I don't know too much about the packet dynamics of the wireless stack,
but I can only report what my machine printed out.  

Here are some excerpts:

 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=769, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1404, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=769, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=920, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=462, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1452, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1452, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1452, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1452, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1452, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=468, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=820, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=820, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=468, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=533, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=468, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=542, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (600) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1349, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216
 SKB BUG: Invalid truesize (920) len=1440, sizeof(sk_buff)=216

> I disagree, obviously. I knew there was some truesize corruption, and I
> think you for tracing down where it occurs. I'll investigate a proper
> fix when I get around to that, meanwhile I don't think the problem is
> awfully urgent since we've had this going on for quite a while and, if
> any, it probably only affects/corrupts the raw monitor sockets.

I didn't use any monitoring with this. No tcpdump, no wireless
sniffer tools or anything. It happened all the time during
normal operation.

-Andi

-- 
ak@linux.intel.com
