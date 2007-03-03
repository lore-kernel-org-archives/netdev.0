From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 4/4]: Kill fastpath_{skb,cnt}_hint.
Date: Sat, 3 Mar 2007 10:12:04 +0200
Message-ID: <20070303081204.GF25760@galon.ev-en.org>
References: <20070228.114949.18302561.davem@davemloft.net> <20070301181340.GD25760@galon.ev-en.org> <20070302.222250.41632359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:39455
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbXCCIMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 03:12:08 -0500
Content-Disposition: inline
In-Reply-To: <20070302.222250.41632359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070303 08:22]:
> BTW, I think I figured out a way to get rid of
> lost_{skb,cnt}_hint.  The fact of the matter in this case is that
> the setting of the tag bits always propagates from front of the queue
> onward.  We don't get holes mid-way.
> 
> So what we can do is search the RB-tree for high_seq and walk
> backwards.  Once we hit something with TCPCB_TAGBITS set, we
> stop processing as there are no earlier SKBs which we'd need
> to do anything with.
> 
> Do you see any problems with that idea?

I think this will be a fairly long walk initially.

You can try an augmented walk. If you are on a node which is tagged
anything on the right side will be tagged as well since it is smaller,
so you need to go left. This way you can find the first non-tagged item
in O(log n).

A bug in this logic is that sequence numbers can and do wrap around.

If you are willing to change the logic of the tree you can remove any
sacked element from it. Many of the operations are really only
interested in the non-sacked skbs. This will be similar to my patches
with the non-sacked list but I still needed the hints since the number
of lost packets could still be large and some operations (retransmit
f.ex.) need to get to the end of the list.


> scoreboard_skb_hint is a little bit trickier, but it is a similar
> case to the tcp_lost_skb_hint case.  Except here the termination
> condition is a relative timeout instead of a sequence number and
> packet count test.
> 
> Perhaps for that we can remember some state from the
> tcp_mark_head_lost() we do first.  In fact, we can start
> the queue walk from the latest packet which tcp_mark_head_lost()
> marked with a tag bit.
> 
> Basically these two algorithms are saying:
> 
> 1) Mark up to smallest of 'lost' or tp->high_seq.
> 2) Mark packets after those processed in #1 which have
>    timed out.
> 
> Right?

Yes. This makes sense, the two algorithms start from the same place. I'd
even consider merging them into a single walk, unless we know that
usually on happens without the other.

There is another case like that for tcp_xmit_retrans where the forward
transmission should only start at the position that the retransmit
finished. I had that in my old patches and it improved performance at
the time.

Baruch
