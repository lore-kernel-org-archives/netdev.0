From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 05/30] mm: slb: add knowledge of reserve pages
Date: Tue, 12 Aug 2008 12:23:27 +0200
Message-ID: <1218536607.10800.181.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141529.635920366@chello.nl>
	 <18593.8466.965002.476705@notabene.brown>
	 <1218525750.10800.156.camel@twins>
	 <18593.22902.998611.967202@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:5897 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbYHLKXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 06:23:32 -0400
Received: from edge04.upc.biz ([192.168.13.239]) by viefep18-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080812102329.MRLC10672.viefep18-int.chello.at@edge04.upc.biz>
          for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 12:23:29 +0200
In-Reply-To: <18593.22902.998611.967202@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-08-12 at 19:35 +1000, Neil Brown wrote:
> On Tuesday August 12, a.p.zijlstra@chello.nl wrote:
> > On Tue, 2008-08-12 at 15:35 +1000, Neil Brown wrote:
> > > On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > > > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > > > contexts that are entitled to it. This is done to ensure reserve pages don't
> > > > leak out and get consumed.
> > > 
> > > This looks good (we are still missing slob though, aren't we :-( )
> > 
> > I actually have that now, just needs some testing..
> 
> Cool!
> 
> > 
> > > > @@ -1526,7 +1540,7 @@ load_freelist:
> > > >  	object = c->page->freelist;
> > > >  	if (unlikely(!object))
> > > >  		goto another_slab;
> > > > -	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> > > > +	if (unlikely(PageSlubDebug(c->page) || c->reserve))
> > > >  		goto debug;
> > > 
> > > This looks suspiciously like debugging code that you have left in.
> > > Is it??
> > 
> > Its not, we need to force slub into the debug slow path when we have a
> > reserve page, otherwise we cannot do the permission check on each
> > allocation.
> 
> I see.... a little.  I'm trying to avoid understanding slub too
> deeply, I don't want to use up valuable brain cell :-)

:-)

> Would we be justified in changing the label from 'debug:' to
> 'slow_path:'  or something?  

Could do I guess.

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1543,7 +1543,7 @@ load_freelist:
 	if (unlikely(!object))
 		goto another_slab;
 	if (unlikely(PageSlubDebug(c->page) || c->reserve))
-		goto debug;
+		goto slow_path;
 
 	c->freelist = object[c->offset];
 	c->page->inuse = c->page->objects;
@@ -1586,11 +1586,21 @@ grow_slab:
 		goto load_freelist;
 	}
 	return NULL;
-debug:
+
+slow_path:
 	if (PageSlubDebug(c->page) &&
 			!alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
+	/*
+	 * Avoid the slub fast path in slab_alloc by not setting
+	 * c->freelist and the fast path in slab_fere by making 
+	 * node_match() fail by setting c->node to -1.
+	 *
+	 * We use this for for debug checks and reserve handling,
+	 * which needs to do permission checks on each allocation.
+	 */
+
 	c->page->inuse++;
 	c->page->freelist = object[c->offset];
 	c->node = -1;


> And if it is just c->reserve, should
> we avoid the call to alloc_debug_processing?

We already do:

	if (PageSlubDebug(c->page) &&
			!alloc_debug_processing(s, c->page, object, addr))
		goto another_slab;

since in that case PageSlubDebug() will be false.

