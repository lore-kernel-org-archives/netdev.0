From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Fri, 13 Feb 2009 14:42:39 +1100
Message-ID: <1234496559.26036.17.camel@pasglop>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	 <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
	 <20090208.234502.197065045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: risto.suominen@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46672 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961AbZBMDmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 22:42:47 -0500
In-Reply-To: <20090208.234502.197065045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I really don't see why this patch could possibly be necessary.
> 
> On systems that lack cache coherence:
> 
> 1) {pci,dma}_alloc_{consistent,coherent}() give kernel mappings of
>    the buffer with the cache disabled.  Therefore the device and
>    and cpu see the correct data.
> 
> 2) {pci,dma}_{map,unmap}_{single,sg}() do the appropriate cache
>    flushing.
> 
>    Explicit syncing between cpu and device can be performed
>    using {pci,dma}_sync_{single,sg}() as needed.
> 
> Therefore, this patch is superfluous.

Allright so in that case, I'm not entirely sure... There is some history
behind that (and btw, de4x5 and tulip probably need the same
"workaround"), see below.

First what I believe the problem to be is some kind of coherency bug in
a bridge in some of these old systems. I'm not 100% sure of the details
but it does have to do with partial cache line access iirc. By moving
the descriptors into separate cache lines, we avoid the bug.

It would be possible, I suppose, to work around it by treating those
machines as non-coherent but with two significant drawbacks:

 - One is simple and you may want to ignore it :-) Basically, those are
already pretty slow machines, and thus we would slow them down even more
by doing manual cache flush/invalidates all over the place (as a matter
of fact, I'm not even sure those CPUs support dcbi instructions for
cache inval, I need to dbl check).

 - The other is more subtle but also harder to avoid: It would be fairly
hard to add support for non-coherent mappings on these because of the
way the whole MMU stuff works for those 32-bit hash based powerpc's.
Basically, we cannot have something mapped both cached and non-cached
(in different virtual addresses), and the use of the BAT mappings in the
processor means that most of the linear mapping -will- be mapped cached
in chunks of 256MB. The code pretty much relies on that, it's not just
an optimisation that can be turned off.

So I'm of mixed opinion here... It looks like since only those 2 or 3
drivers are affected (ie, they are the only thing ever found behind
those weirdo bridges) and since those chips happen to support this
padding between descriptor, it looks like a good compromise to just add
this feature to the drivers. In fact, de4x5.c at least used to have it,
I don't know if it's still the case.

Now, there are other cache coherency related bugs I think on those old
machines, or at least what look like it -could- be cache coherency
related bugs, or maybe just bugs in the DBDMA engine. Mesh for example
gets unhappy if we give it a buffer that is not aligned on a cache line
boundary and corrupts the beginning of that cache line. But I don't
think that treating the platform as non-coherent will fix that, ie, it
seems to happens regardless of the line actually being in the cache or
not.  This is typically triggered by the SCSI ID at boot when using SLAB
debug which de-aligns kmalloc, or at least that's how I observed it a
while ago.

Cheers,
Ben.


