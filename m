From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 -next 0/5] don't exceed original maximum fragment
 size when refragmenting
Date: Mon, 04 May 2015 19:29:25 -0400 (EDT)
Message-ID: <20150504.192925.1995874259134884815.davem@davemloft.net>
References: <1430772888-5682-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	jesse@nicira.com, herbert@gondor.apana.org.au
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbEDX31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:29:27 -0400
In-Reply-To: <1430772888-5682-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  4 May 2015 22:54:43 +0200

> #2 keep fragments attached to reassembled
> 
> The idea is to attach the original skbs to the reassembled one, so the
> networking stack can choose which ones to use depending on the use
> case. Forwarding would operate on the original ones while code dealing
> with PACKET_HOST frames would use the reassembled one.
> 
> 	- We have the overhead to carry more skbs around, which we
>           currently don't do.

I disagree.  It is much more cheaper to save around a chain of smaller
than PAGE_SIZE SKB fragments, than have to allocate multi-order linear
SKB to hold the whole thing.

Furthermore, the allocation of the incoming SKB fragments has by
definition _ALREADY_ suceeded.  Therefore it is more likely to result
in successful passing of the frames through the host.

And I do not think you need to sets of packets.  We have SKB
interfaces that can pull headers out of the SKB even if it crosses
a frag boundary, yet returns a pointer directly to the object inside
of skb->data if it is fully contained inside of the linear area which
is the common case.

All of this infrastructure is there and optimized for handling
spaghetti fragged SKBs if that's what we end up receiving, use it.

All of these overlapping frag etc. issues are just details, and I am
still not convinced these cannot be handled properly.  Please try
harder.

> 	- This information cannot be stored in any of the currently
>           available fields in the skb or shared_info. That said, a new
>           pointer would be necessary in every skb, independently if it
>           is fragmented or not. This change does impact fast path and
>           skb size.

You could use the existing frag_list, or make a new member (but not
in sk_buff, but rather in the shinfo).

Just imposing a size limit does not preserve the geometry.

I consider this a show stopper, and I believe people like Herbert
Xu will agree with me.
