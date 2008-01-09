From: linux@horizon.com
Subject: Re: SACK scoreboard
Date: 9 Jan 2008 01:04:09 -0500
Message-ID: <20080109060409.18161.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:13448 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750940AbYAIGEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:04:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just some idle brainstorming on the subject...

It seems the only way to handle network pipes sigificantly larger (delay *
bandwidth product) than the processor cache is to make freeing retransmit
data o(n).

Now, there are some ways to reduce the constant factor.  The one that
comes to mind first is to not queue sk_buffs.  Throw away the struct
sk_buff after transmission and just queue skb_frag_structs, pages, or
maybe even higher-order pages of data.  Then freeing the data when it's
acked has a much smaller constant factor, particularly d-cache footprint,
and no slab operations.

The downside is more work to recreate the skb if you do have to
retransmit, but optimizing for retransmits is silly.

Some implementations could leave large chunks of memory locked until
all of the sk_buff->skb_shared_info->skb_frag_structs referencing them
have gone away, but you can look at the transmit window when deciding
how big a chunk size to use.


Then, to actually get below O(n), you want to keep the queued data in
a data structure known to the memory manager.  Basically, splice the
retransmit queue onto the free list.

It may require some kludgery in the memory manager.  In particular, doing
that in O(1) time obviously means that you can't coalesce adjacent free
regions to build higher-order pages.  So you'd have to have a threshold
for uncoalesced pages and a way to force coalescing under memory pressure.

You're just deferring work until the page is allocated, but the point
is that then it's okay to bring it into cache when it's about to be
used again.  It's the redundant round trip just because an ack arrived
that's annoying.

I've done thins sort of thing with specialized fixed-block-size allocators
before (an alpha-beta minimax search tree allocates nodes one at a
time, but frees whole subtrees at once), but might it be feasible for
kernel use?
