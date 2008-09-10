From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 21:24:26 -0700 (PDT)
Message-ID: <20080909.212426.193696271.davem@davemloft.net>
References: <20080910040107.GA29695@gondor.apana.org.au>
	<20080909.210654.159776216.davem@davemloft.net>
	<20080910042247.GA2544@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751148AbYIJEYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:24:33 -0400
In-Reply-To: <20080910042247.GA2544@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Sep 2008 14:22:47 +1000

> On Tue, Sep 09, 2008 at 09:06:54PM -0700, David Miller wrote:
> > @@ -120,7 +120,6 @@ extern struct mutex xfrm_cfg_mutex;
> >  /* Full description of state of transformer. */
> >  struct xfrm_state
> >  {
> > -	struct list_head	all;
> >  	union {
> >  		struct list_head	gclist;
> >  		struct hlist_node	bydst;
> 
> This union now needs to move across to bysrc or byspi since bydst
> needs to be preserved for walking even after a node is added to
> the GC.

That would explain the crash I just got :)

> > @@ -566,7 +564,6 @@ int __xfrm_state_delete(struct xfrm_state *x)
> >  		x->km.state = XFRM_STATE_DEAD;
> >  		spin_lock(&xfrm_state_lock);
> >  		x->lastused = xfrm_state_walk_ongoing;
> > -		list_del_rcu(&x->all);
> >  		hlist_del(&x->bydst);
> 
> We need hlist_del_rcu on bydst for the same reason.

Ok, gotcha.

> This is a bug in the original patch.  When we get an error on
> the very last node we'll lose that node instead of dumping it
> later.  I wonder if we could just get rid of last altogether...

I'll take a look at this too after I resolve and test the above
issues.

Thanks.
