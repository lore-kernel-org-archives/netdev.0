From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu: fix skb truesize underestimation
Date: Fri, 14 Oct 2011 00:34:27 -0400 (EDT)
Message-ID: <20111014.003427.1515514811425011051.davem@davemloft.net>
References: <1318545567.2533.46.camel@edumazet-laptop>
	<20111013.222659.12182837968152363.davem@davemloft.net>
	<1318563231.2533.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab1JNEer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 00:34:47 -0400
In-Reply-To: <1318563231.2533.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Oct 2011 05:33:51 +0200

> But then I see you also do in niu_rbr_add_page(), rigth after the
> alloc_page(), the thing I was thinking to add : (perform all needed
> get_page() in a single shot)
> 
> atomic_add(rp->rbr_blocks_per_page - 1,
> 	&compound_head(page)->_count);
> 
> So I am a bit lost here. Arent you doing too many page->_count
> increases ?

It would be pretty amazing for a leak of this magnitude to exist for
so long. :-)

A page can be split into multiple blocks, each block is some power
of two in size.

The chip splits up "blocks" into smaller (also power of two)
fragments, and these fragments are what we en-tail to the SKBs.

So at the top level we give the chip blocks.  We try to make this
equal to PAGE_SIZE.  But if PAGE_SIZE is really large we limit the
block size to 1 << 15.  Note that it is only when we enforce this
block size limit that the compount_page(page)->_count atomic increment
will occur.  As long as PAGE_SIZE <= 1 << 15, rbr_blocks_per_page
will be 1.

When the chip takes a block and starts using it, it decides which
fragment size to use for that block.  Once a fragment size has been
choosen for a block, it will not change.

The fragment sizes the chip can use is stored in rp->rbr_sizes[].  We
always configure the chip to use 256 byte and 1024 byte blocks, then
depending upon the MTU and the PAGE_SIZE we'll optionally enable other
sizes such as 2048, 4096, and 8192.

When we get an RX packet the descriptor tells us the DMA address
and the fragment size in use for the block that the memory at
DMA address belongs to.

So the two seperate page reference count grabs you see are handling
references for memory being chopped up at two different levels.

I can't see how we could optimize the intra-block refcounts any
further.  Part of the problem is that we don't know apriori what
fragment size the chip will use for a given block.
