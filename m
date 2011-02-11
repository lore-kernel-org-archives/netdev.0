From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] niu: Fix races between up/down and get_stats.
Date: Fri, 11 Feb 2011 15:29:52 -0200
Message-ID: <20110211172952.GA3112@redhat.com>
References: <20110203.162529.260086668.davem@davemloft.net>
 <20110204162646.GC3710@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756209Ab1BKS1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 13:27:06 -0500
Content-Disposition: inline
In-Reply-To: <20110204162646.GC3710@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 04, 2011 at 02:26:46PM -0200, Flavio Leitner wrote:
> On Thu, Feb 03, 2011 at 04:25:29PM -0800, David Miller wrote:
> > 
> > As reported by Flavio Leitner, there is no synchronization to protect
> > NIU's get_stats method from seeing a NULL pointer in either
> > np->rx_rings or np->tx_rings.  In fact, as far as ->ndo_get_stats
> > is concerned, these values are set completely asynchronously.
> > 
> > Flavio attempted to fix this using a RW semaphore, which in fact
> > works most of the time.  However, dev_get_stats() can be invoked
> > from non-sleepable contexts in some cases, so this fix doesn't
> > work in all cases.
> > 
> > So instead, control the visibility of the np->{rx,tx}_ring pointers
> > when the device is being brough up, and use properties of the device
> > down sequence to our advantage.
> > 
> > In niu_get_stats(), return immediately if netif_running() is false.
> > The device shutdown sequence first marks the device as not running (by
> > clearing the __LINK_STATE_START bit), then it performans a
> > synchronize_rcu() (in dev_deactive_many()), and then finally it
> > invokes the driver ->ndo_stop() method.
> > 
> > This guarentees that all invocations of niu_get_stats() either see
> > netif_running() as false, or they see the channel pointers before
> > ->ndo_stop() clears them out.
> > 
> > If netif_running() is true, protect against startup races by loading
> > the np->{rx,tx}_rings pointer into a local variable, and punting if
> > it is NULL.  Use ACCESS_ONCE to prevent the compiler from reloading
> > the pointer on us.
> > 
> > Also, during open, control the order in which the pointers and the
> > ring counts become visible globally using SMP write memory barriers.
> > We make sure the np->num_{rx,tx}_rings value is stable and visible
> > before np->{rx,tx}_rings is.
> > 
> > Such visibility control is not necessary on the niu_free_channels()
> > side because of the RCU sequencing that happens during device down as
> > described above.  We are always guarenteed that all niu_get_stats
> > calls are finished, or will see netif_running() false, by the time
> > ->ndo_stop is invoked.
> > 
> > Reported-by: Flavio Leitner <fleitner@redhat.com>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> nice patch, clever
> I got positive feedback on my patch. I'll ask for this patch as well.

Got a feedback that your patch works out too.
thanks,
-- 
Flavio
