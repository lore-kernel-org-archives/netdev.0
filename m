From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 19:26:30 +1100
Message-ID: <20090114082630.GB16692@gondor.apana.org.au>
References: <20090113.163705.130074998.davem@davemloft.net> <20090114035124.GA8409@gondor.apana.org.au> <20090113.232710.55011568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59997 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752805AbZANI1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 03:27:12 -0500
Content-Disposition: inline
In-Reply-To: <20090113.232710.55011568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 11:27:10PM -0800, David Miller wrote:
> 
> So while trying to figure out a sane way to fix this, I found
> another bug:
> 
> 	/*
> 	 * map the linear part
> 	 */
> 	if (__splice_segment(virt_to_page(skb->data),
> 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
> 			     skb_headlen(skb),
> 			     offset, len, skb, spd))
> 		return 1;
> 
> This will explode if the SLAB cache for skb->head is using compound
> (ie. order > 0) pages.
> 
> For example, if this is an order-1 page being used for the skb->head
> data (which would be true on most systems for jumbo MTU frames being
> received into a linear SKB), the offset will be wrong and depending
> upon skb_headlen() we could reference past the end of that
> non-compound page we will end up grabbing a reference to.

I'm actually not worried so much about these packets since these
drivers should be converted to skb frags as otherwise they'll
probably stop working after a while due to memory fragmentation.

But yeah for correctness we definitely should address this in
skb_splice_bits.

I still think Jarek's approach (the copying one) is probably the
easiest for now until we can find a better way.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
