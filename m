From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 23:27:10 -0800 (PST)
Message-ID: <20090113.232710.55011568.davem@davemloft.net>
References: <20090113.163705.130074998.davem@davemloft.net>
	<20090114035124.GA8409@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754412AbZANH1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 02:27:10 -0500
In-Reply-To: <20090114035124.GA8409@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Jan 2009 14:51:24 +1100

> Unfortunately this won't work, not even for network destinations.
> 
> The reason is that this gets called as soon as the destination's
> splice hook returns, for networking that means when sendpage returns.
> 
> So by that time we'll still be left with just a page reference
> on a page where the slab memory may already have been freed.
> 
> To make this work we need to get the destination's splice hooks
> to acquire this reference.

So while trying to figure out a sane way to fix this, I found
another bug:

	/*
	 * map the linear part
	 */
	if (__splice_segment(virt_to_page(skb->data),
			     (unsigned long) skb->data & (PAGE_SIZE - 1),
			     skb_headlen(skb),
			     offset, len, skb, spd))
		return 1;

This will explode if the SLAB cache for skb->head is using compound
(ie. order > 0) pages.

For example, if this is an order-1 page being used for the skb->head
data (which would be true on most systems for jumbo MTU frames being
received into a linear SKB), the offset will be wrong and depending
upon skb_headlen() we could reference past the end of that
non-compound page we will end up grabbing a reference to.

And then we'll end up with a compound page in an skb_shinfo() frag
array, which is illegal.

Well, at least, I can list several drivers that will barf when
trying to TX that (Acenic, atlx1, cassini, jme, sungem), since
they use pci_map_page(... virt_to_page(skb->data)) or similar.

The core KMAP'ing support for SKBs will also not be able to grok
such a beastly SKB.

