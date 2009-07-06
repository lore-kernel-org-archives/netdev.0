From: Andi Kleen <andi@firstfloor.org>
Subject: Re: >10% performance degradation since 2.6.18
Date: Mon, 6 Jul 2009 10:38:27 +0200
Message-ID: <20090706083827.GA28145@one.firstfloor.org>
References: <4A4F1EA0.3070501@garzik.org> <20090705040137.GA7747@gondor.apana.org.au> <20090705130926.GS5480@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Garzik <jeff@garzik.org>, andi@firstfloor.org,
	arjan@infradead.org, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, douglas.w.styner@intel.com,
	chinang.ma@intel.com, terry.o.prickett@intel.com,
	matthew.r.wilcox@intel.com, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57145 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbZGFIi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 04:38:27 -0400
Content-Disposition: inline
In-Reply-To: <20090705130926.GS5480@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 07:09:26AM -0600, Matthew Wilcox wrote:
> On Sun, Jul 05, 2009 at 12:01:37PM +0800, Herbert Xu wrote:
> > > If yes, how to best handle when the scheduler moves app to another CPU?
> > > Should we reprogram the NIC hardware flow steering mechanism at that point?
> > 
> > Not really.  For now the best thing to do is to pin everything
> > down and not move at all, because we can't afford to move.
> > 
> > The only way for moving to work is if we had the ability to get
> > the sockets to follow the processes.  That means, we must have
> > one RX queue per socket.
> 
> Maybe not one RX queue per socket -- sockets belonging to the same
> thread could share the same RX queue.  I'm fairly ignorant of the way
> networking works these days; is it possible to dynamically reassign a
> socket between RX queues, so we'd only need one RX queue per CPU?

That is how it is supposed to work (ignoring some special setups 
with QoS) in theory.

a You have per CPU RX queues (or if the NIC has less than CPUs, then on a 
  subset of CPUs)
b The NIC uses a hash function on the stream (= socket) to map an 
  incoming packet to a specific RX queue.
c The interrupt handler is supposed to be bound on a specific CPU.
d The CPU then does wakeups and the scheduler biases the process/thread
  using the sockets towards the CPU that always does the wakeups.

Ideally then the process/thread doing the socket IO should be on 
the receiving CPU.  It doesn't always work out like this in practice, 
but it should.

(c) seems to be the part that is broken right now.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
