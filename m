From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/30] mm: slb: add knowledge of reserve pages
Date: Tue, 12 Aug 2008 19:35:50 +1000
Message-ID: <18593.22902.998611.967202@notabene.brown>
References: <20080724140042.408642539@chello.nl>
	<20080724141529.635920366@chello.nl>
	<18593.8466.965002.476705@notabene.brown>
	<1218525750.10800.156.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753514AbYHLJgO@vger.kernel.org>
In-Reply-To: message from Peter Zijlstra on Tuesday August 12
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday August 12, a.p.zijlstra@chello.nl wrote:
> On Tue, 2008-08-12 at 15:35 +1000, Neil Brown wrote:
> > On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > > contexts that are entitled to it. This is done to ensure reserve pages don't
> > > leak out and get consumed.
> > 
> > This looks good (we are still missing slob though, aren't we :-( )
> 
> I actually have that now, just needs some testing..

Cool!

> 
> > > @@ -1526,7 +1540,7 @@ load_freelist:
> > >  	object = c->page->freelist;
> > >  	if (unlikely(!object))
> > >  		goto another_slab;
> > > -	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> > > +	if (unlikely(PageSlubDebug(c->page) || c->reserve))
> > >  		goto debug;
> > 
> > This looks suspiciously like debugging code that you have left in.
> > Is it??
> 
> Its not, we need to force slub into the debug slow path when we have a
> reserve page, otherwise we cannot do the permission check on each
> allocation.

I see.... a little.  I'm trying to avoid understanding slub too
deeply, I don't want to use up valuable brain cell :-)
Would we be justified in changing the label from 'debug:' to
'slow_path:'  or something?  And if it is just c->reserve, should
we avoid the call to alloc_debug_processing?


Thanks,
NeilBrown

> 
> > > @@ -265,7 +267,8 @@ struct array_cache {
> > >  	unsigned int avail;
> > >  	unsigned int limit;
> > >  	unsigned int batchcount;
> > > -	unsigned int touched;
> > > +	unsigned int touched:1,
> > > +		     reserve:1;
> > 
> > This sort of thing always worries me.
> > It is a per-cpu data structure so you won't get SMP races corrupting
> > fields.  But you do get read-modify-write in place of simple updates.
> > I guess it's not a problem..  But it worries me :-)
> 
> Right,.. do people prefer I just add another int?
