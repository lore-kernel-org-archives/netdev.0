From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 03:42:24 -0400 (EDT)
Message-ID: <20111014.034224.1197576516015404466.davem@davemloft.net>
References: <1318576791.2533.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693Ab1JNHma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:42:30 -0400
In-Reply-To: <1318576791.2533.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Oct 2011 09:19:51 +0200

> Many drivers allocates big skb to store a single TCP frame.
> (WIFI drivers, or NIC using PAGE_SIZE fragments)
> 
> Its now common to get skb->truesize bigger than 4096 to store a ~1500
> bytes TCP frame.
> 
> TCP sessions with large RTT and packet losses can fill their Out Of
> Order queue with such oversized skbs, and hit their sk_rcvbuf limit,
> starting a pruning of complete OFO queue, without giving chance to
> receive the missing packet(s) and moving skbs from OFO to receive queue.
> 
> This patch adds skb_reduce_truesize() helper, and uses it for all skbs
> queued into OFO queue.
> 
> Spending some time to perform a copy is worth the pain, since it permits
> SACK processing to have a chance to complete over the RTT barrier.
> 
> This greatly improves user experience, without added cost on fast path.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

No objection from me, although I wish wireless drivers were able to
size their SKBs more appropriately.  I wonder how many problems that
look like "OMG we gotz da Buffer Bloat, arrr!" are actually due to
this truesize issue.

I think such large truesize SKBs will cause problems even in non loss
situations, in that the receive buffer will hit it's limits more
quickly.  I not sure that the receive buffer autotuning is built to
handle this sort of scenerio as a common occurance.

You might want to check if this is the actual root cause of your
problems.  If the receive buffer autotuning doesn't expand the receive
buffer enough to hold two windows worth of these large truesize SKBs,
that's the real reason why we end up pruning.

We have to decide if these kinds of SKBs are acceptable as a normal
situation for MSS sized frames.  And if they are then it's probably
a good idea to adjust the receive buffer autotuning code too.

Although I realize it might be difficult, getting rid of these weird
SKBs in the first place would be ideal.

It would also be a good idea to put the truesize inaccuracies into
perspective when selecting how to fix this.  It's trying to prevent
1 byte packets not accounting for the 256 byte SKB and metadata.
That kind of case with such a high ratio of wastage is important.

On the other hand, using 2048 bytes for a 1500 byte packet and claiming
the truesize is 1500 + sizeof(metadata)... that might be an acceptable
lie to tell :-)  This is especially true if it allows an easy solution
to this wireless problem.

Just some thoughts...  and I wonder if the wireless thing is due to
some hardware limitation or similar.
