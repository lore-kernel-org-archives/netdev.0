From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: >10% performance degradation since 2.6.18
Date: Sun, 5 Jul 2009 07:09:26 -0600
Message-ID: <20090705130926.GS5480@parisc-linux.org>
References: <4A4F1EA0.3070501@garzik.org> <20090705040137.GA7747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, andi@firstfloor.org,
	arjan@infradead.org, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, douglas.w.styner@intel.com,
	chinang.ma@intel.com, terry.o.prickett@intel.com,
	matthew.r.wilcox@intel.com, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:60036 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbZGENJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 09:09:24 -0400
Content-Disposition: inline
In-Reply-To: <20090705040137.GA7747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 12:01:37PM +0800, Herbert Xu wrote:
> > If yes, how to best handle when the scheduler moves app to another CPU?
> > Should we reprogram the NIC hardware flow steering mechanism at that point?
> 
> Not really.  For now the best thing to do is to pin everything
> down and not move at all, because we can't afford to move.
> 
> The only way for moving to work is if we had the ability to get
> the sockets to follow the processes.  That means, we must have
> one RX queue per socket.

Maybe not one RX queue per socket -- sockets belonging to the same
thread could share the same RX queue.  I'm fairly ignorant of the way
networking works these days; is it possible to dynamically reassign a
socket between RX queues, so we'd only need one RX queue per CPU?

It seems the 82575 device has four queues per port, and it's a dual-port
card, so that's eight queues in the system.  We'd need hundreds of queues
to get one queue per client process.  The 82576 has sixteen queues per
port, but that's still not enough (funnily, the driver still limits you
to four per port).

For what it's worth, I believe the current setup pins the client tasks to
a package, but they are allowed to move between cores on that package.
My information may be out of date; hopefully Doug, Chinang or Terry can
clarify how the tasks are currently bound.

I know this test still uses SCHED_RR for the client tasks (using
SCHED_OTHER results in another couple of percentage points off the
overall performance).

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
