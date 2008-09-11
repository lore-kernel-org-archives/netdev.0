From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Thu, 11 Sep 2008 15:00:06 -0700 (PDT)
Message-ID: <20080911.150006.53056393.davem@davemloft.net>
References: <20080908.172513.162820960.davem@davemloft.net>
	<20080909143312.GA29952@gondor.apana.org.au>
	<20080911212459.GL6693@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752384AbYIKWAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 18:00:12 -0400
In-Reply-To: <20080911212459.GL6693@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 11 Sep 2008 14:24:59 -0700

> On Wed, Sep 10, 2008 at 12:33:12AM +1000, Herbert Xu wrote:
> > On Mon, Sep 08, 2008 at 05:25:13PM -0700, David Miller wrote:
> > > 
> > > The only comment I would make is that maybe it's a bit excessive
> > > to trigger the GC worker every time we walk the states.
> > 
> > Good point!
> > 
> > I've avoided the memory barrier by simply extending the mutexed
> > section in the GC to cover the list splicing.  Here's the updated
> > patch:
> > 
> > ipsec: Use RCU-like construct for saved state within a walk
> > 
> > Now that we save states within a walk we need synchronisation
> > so that the list the saved state is on doesn't disappear from
> > under us.
> > 
> > As it stands this is done by keeping the state on the list which
> > is bad because it gets in the way of the management of the state
> > life-cycle.
> > 
> > An alternative is to make our own pseudo-RCU system where we use
> > counters to indicate which state can't be freed immediately as
> > it may be referenced by an ongoing walk when that resumes.
> 
> There is only one reader at a time, right?  Otherwise, I don't see how
> the increments and reads of xfrm_state_walk_completed line up.

The RTNL semaphore is held across the modifications of the counters.
