From: David Miller <davem@davemloft.net>
Subject: Re: Using GPU to do packet forwarding
Date: Tue, 24 Aug 2010 15:31:50 -0700 (PDT)
Message-ID: <20100824.153150.229738721.davem@davemloft.net>
References: <20100824151507.5c13bd69@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755229Ab0HXWbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 18:31:32 -0400
In-Reply-To: <20100824151507.5c13bd69@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 24 Aug 2010 15:15:07 -0700

> Interesting paper:
>   http://www.ndsl.kaist.edu/~kyoungsoo/papers/packetshader.pdf
> One section of general consideration is the expense of the current
> skb scheme. At 10G, they measure 60% of the CPU is used doing skb
> alloc/free; see paper for the alternative of using a huge
> packet buffer.  Also, they managed to shrink skb to 8 bytes!

It just means SLAB or SLUB are broken if the number is that high.
Also, their old kernel has none of the TX multiqueue work we've
done.

It should simply be a lockless list unlink, and how that can consume
%60 of cpu compared to the routing table lookup is beyond me.

But I suppose you can easily choose an environment and configuration
to make the numbers of one's techniques look better.

Next, they use a binary search ipv6 lookup which is going to touch
more data than a multi-way trie scheme would, it also avoids the
routing cache since ipv6 lacks one.  They even admit that they've
purposely rigged the test such that the working set doesn't fit in the
cpu cache.

It's an interesting paper, but we're going to have 64-cpu and 128-cpu
x86 machines commonly quite soon, so the arity of parallelism these
guys are getting in return (at a cost of generality) will decrease
steadily over time.

