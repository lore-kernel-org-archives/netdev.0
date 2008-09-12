From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 11 Sep 2008 21:08:23 -0700 (PDT)
Message-ID: <20080911.210823.38984020.davem@davemloft.net>
References: <20080803085553.GA1512@gondor.apana.org.au>
	<20080806.230741.137564172.davem@davemloft.net>
	<20080807061535.GA7591@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbYILEI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 00:08:29 -0400
In-Reply-To: <20080807061535.GA7591@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 7 Aug 2008 14:15:35 +0800

> On Wed, Aug 06, 2008 at 11:07:41PM -0700, David Miller wrote:
> >
> > We don't touch anything in the original TSO skb.  However we expand
> > the headroom (if necessary) and in the area in front of skb->data we
> > build the header areas for the sub-TSO frames, one by one.
> 
> Or we could just allocate them beforehand, either way, it's one
> operation per superpacket so it's cheap.
 ...
> > Another nice aspect of this idea is that we can make the existing GSO
> > code just build this funny "TSO plus hidden headers" SKB, and then do
> > the by-hand unpacking into new SKB chunks that we will let smart
> > drivers do directly into their TX rings.
> > 
> > Herbert what do you think?
> 
> Yes this idea sounds perfect :)

So I started studying how to do this.  I'm still not exactly sure how I
want the driver usage to look like.  But I did draw an ascii diagram :)
We'll call them QGSO or "Quick GSO" frames.

		TSO frame
		---------

skb->data ->	link level header
		IP header
		TCP header
		all data (always paged)

		QGSO frame
		----------

		------------------\
		link level header  |
		IP header          |--- * ->gso_segs
		TCP header         |
		------------------/
skb->data ->	orig link level header
	  	orig IP Header
		orig TCP header
		all data (always paged)

So when the driver gets this QGSO thing, It uses skb_shinfo(skb)->gso_segs
to figure out how far back in front of skb->data to start reading header
sections.

It could use two pointers, one to the header array and one to the data.
And then it would advance each as it fills in the TX descriptors.

However, every time I try to codify the driver part, it's super clumsy. :)

But, anyways, one thing we can let the driver do is, assuming "header_size"
is the computed size of each entry in the header array:

	__skb_push(skb, header_size * skb_shinfo(skb)->gso_segs);
	skb_dma_map(priv->dev, skb, DMA_TO_DEVICE);

which makes things a little simpler.

The driver starts it's header DMA address at skb_shinfo(skb)->dma_maps[0],
and this is linear so can just advance using simple increments.

The data DMA address starts at ->dma_maps[1] and the length is obtained
from the skb_frag_t.  Once the length is exhausted, we pick up the
next ->dma_maps[] array entry, and fetch the next skb_frag_t's length.

This process continues as the descriptors are filled in.

Then later skb_dma_unmap() is called.

I suspect that this __skb_push() thing is legal, because we have a unique
reference to a clone or similar.

I don't know, a lot of details to work out, which is why I'm writing this
8-)
