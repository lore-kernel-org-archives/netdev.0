From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 21:48:29 -0700 (PDT)
Message-ID: <20080909.214829.193700357.davem@davemloft.net>
References: <20080909.210654.159776216.davem@davemloft.net>
	<20080910042247.GA2544@gondor.apana.org.au>
	<20080909.212426.193696271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750767AbYIJEsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:48:36 -0400
In-Reply-To: <20080909.212426.193696271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 09 Sep 2008 21:24:26 -0700 (PDT)

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 10 Sep 2008 14:22:47 +1000
> 
> > On Tue, Sep 09, 2008 at 09:06:54PM -0700, David Miller wrote:
> > > @@ -120,7 +120,6 @@ extern struct mutex xfrm_cfg_mutex;
> > >  /* Full description of state of transformer. */
> > >  struct xfrm_state
> > >  {
> > > -	struct list_head	all;
> > >  	union {
> > >  		struct list_head	gclist;
> > >  		struct hlist_node	bydst;
> > 
> > This union now needs to move across to bysrc or byspi since bydst
> > needs to be preserved for walking even after a node is added to
> > the GC.
> 
> That would explain the crash I just got :)

No, it doesn't explain the crash/hang.  And it happens even without my
patch.

I get a hang in del_timer_sync() and it's from a workqueue so I suspect
your patch :-)

I can't see what does the list delete from the GC leftover list?  Entries
seem to stay on there forever.  We even kfree() the object.

The list iteration is:

	list_for_each_entry_safe(x, tmp, &xfrm_state_gc_leftovers, gclist) {
		if ((long)(x->lastused - completed) > 0)
			break;
		xfrm_state_gc_destroy(x);
	}

And xfrm_state_gc_destroy() doesn't do a list_del(&x->gclist) or similar.
