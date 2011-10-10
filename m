From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 11:01:24 +0200
Message-ID: <1318237284.29415.422.camel@pasglop>
References: <1318145118.29415.371.camel@pasglop>
	 <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
	 <20111010084726.GM2681@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34414 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab1JJJBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 05:01:48 -0400
In-Reply-To: <20111010084726.GM2681@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-10 at 10:47 +0200, Eli Cohen wrote:
> On Mon, Oct 10, 2011 at 09:40:17AM +0100, David Laight wrote:
> > 
> > Actually memory barriers shouldn't really be added to
> > any of these 'accessor' functions.
> > (Or, at least, ones without barriers should be provided.)
> > 
> > The driver may want to to a series of writes, then a
> > single barrier, before a final write of a command (etc).
> > 
> > in_le32() from io.h is specially horrid!
> > 
> > 	David
> > 
> The driver would like to control if and when we want to put a memory
> barrier. We really don't want it to be done under the hood. In this
> respect we prefer raw functions which are still available to all
> platforms.

 ... but not necessarily the corresponding barriers.

That's why on powerpc we had to make all rmb,wmb and mb the same, aka a
full sync, because our weaker barriers don't order cachable vs.
non-cachable.

In any case, the raw functions are a bit nasty to use because they both
don't have barriers -and- don't handle endianness. So you have to be
extra careful.

In 90% of the cases, the barriers are what you want anyway. For example
in the else case of the driver, the doorbell MMIO typically wants it, so
using writel() is fine (or iowrite32be) and will have the necessary
barriers.

The case where things get a bit more nasty is when you try to use MMIO
for low latency small-data type transfers instead of DMA, in which case
you do want the ability for the chipset to write-combine and control the
barriers more precisely.

However, this is hard and Linux doesn't provide very good accessors to
do so, thus you need to be extra careful (see my example about wmb()

In the case of the iomap "copy" operations, my problem is that they
don't properly advertise their lack of ordering since normal iomap does
have full ordering.

I believe they should provide ordering with a barrier before & a barrier
after, eventually with _relaxed variants or _raw variants for those who
"know what they are doing".

Maybe it's time for us to revive those discussions about providing a
good set of relaxed MMIO accessors with explicit barriers :-)

Cheers,
Ben.
 
