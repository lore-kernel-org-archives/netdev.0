From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Wed, 06 Aug 2008 23:07:41 -0700 (PDT)
Message-ID: <20080806.230741.137564172.davem@davemloft.net>
References: <20080731132735.GA9085@gondor.apana.org.au>
	<20080803.011945.249059359.davem@davemloft.net>
	<20080803085553.GA1512@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751833AbYHGGHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:07:41 -0400
In-Reply-To: <20080803085553.GA1512@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 3 Aug 2008 16:55:53 +0800

> On Sun, Aug 03, 2008 at 01:19:45AM -0700, David Miller wrote:
> >
> > I would start hacking on this beast but I haven't yet come up with
> > a clean way to share a lot of code with the existing sw GSO engine.
> > That's the key to implementing this properly.
> 
> I think it's doable.  We could refactor the software GSO so that
> it spits out one fragment at a time and the output could either
> be written to some memory provided by the caller or fed through
> a callback.
> 
> BTW, loner term we should start thinking about breaking the 64K
> barrier.

So I had this idea.  My goal is to minimize the number of DMA
mappings the driver has to make.

We don't touch anything in the original TSO skb.  However we expand
the headroom (if necessary) and in the area in front of skb->data we
build the header areas for the sub-TSO frames, one by one.

We give the driver some iterator functions that walk through the
header areas and compute offset/length pairs into the
skb_shared_info() page list.

So basically the number of DMA mappings to make would be identical
to the number necessary for TSO capable hardware.  And at the
top level we can arrange it such that the headroom will be large
enough already in the cases that matter.

The only fly in the ointment is that the driver has to store these
DMA mapping cookies away somewhere, because what's going to happen
is the driver will directly DMA map the skb_shared_info() area pages
but then slice and adjust DMA addresses as it unpacks the TSO frame
into the TX ring.

This might be where we get pushed over the edge and have to add a
dma_addr_t to sk_buff and skb_frag_struct.  And that might not
be such a bad thing because it will allow other things that
we've always wanted to do.

Another nice aspect of this idea is that we can make the existing GSO
code just build this funny "TSO plus hidden headers" SKB, and then do
the by-hand unpacking into new SKB chunks that we will let smart
drivers do directly into their TX rings.

Herbert what do you think?
