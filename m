From: David Miller <davem@davemloft.net>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Sun, 03 Aug 2008 01:19:45 -0700 (PDT)
Message-ID: <20080803.011945.249059359.davem@davemloft.net>
References: <20080731.053516.185810642.davem@davemloft.net>
	<20080731131929.GO10471@solarflare.com>
	<20080731132735.GA9085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org, akarkare@marvell.com, nico@cam.org,
	dale@farnsworth.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbYHCITp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 04:19:45 -0400
In-Reply-To: <20080731132735.GA9085@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 31 Jul 2008 21:27:35 +0800

> On Thu, Jul 31, 2008 at 02:19:30PM +0100, Ben Hutchings wrote:
> >
> > You might want to think about providing a way for soft-GSO to generate
> > more lightweight structures than skbs.  The overhead for skb allocation
> > becomes quite significant beyond 1 Gbit/s, which is why we added the soft-
> > TSO implementation in sfc using per-interface pools of header buffers.  I
> > would guess niu would benefit from this sort of approach, though it looks
> > like all the other 10G NICs do TSO in hardware/firmware.
> 
> We could always provide a library that makes it easier for the
> drivers to do TSO in software without allocating skb's.

I took a brief look into this, and yes NIU would benefit a lot from
what the sfc driver is doing and using sw GSO in general.

I think that, in order to work out, the driver has to provide a pool
of DMA buffers to use in some generic fashion.

It seems likely that it's best to give the driver the largest amount
of flexibility wrt. the DMA bits.  There are two reasonable ways for
them to implement a header buffer pool:

1) A big coherent DMA block that gets chopped up into fixed size pieces.

2) A free list of kmalloc() buffers that get DMA mapped dynamically
   (because such dynamic DMA mappings transfer faster than coherent ones
   on some systems).

But anyways, we don't want to be in the business of enforcing one way
or the other in whatever interface we come up with.

So likely what we'll do is have the driver say it can do hw TSO and
then at ->hard_start_xmit() time it calls into the sw GSO engine,
passing header buffers in along the way.

I would start hacking on this beast but I haven't yet come up with
a clean way to share a lot of code with the existing sw GSO engine.
That's the key to implementing this properly.
