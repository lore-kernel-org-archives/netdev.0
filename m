From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 12:39:01 +0200
Message-ID: <1217241541.6331.42.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217240224.6331.32.camel@twins>
	 <1217240994.7813.53.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Neil Brown <neilb@suse.de>, mpm@selenic.com,
	cl@linux-foundation.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:21092 "EHLO
	viefep17-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753083AbYG1KjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 06:39:09 -0400
Received: from edge04.upc.biz ([192.168.13.239]) by viefep17-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080728103906.TXXA24448.viefep17-int.chello.at@edge04.upc.biz>
          for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 12:39:06 +0200
In-Reply-To: <1217240994.7813.53.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 13:29 +0300, Pekka Enberg wrote:

> > > > +	}
> > > > +
> > > > +	obj = __kmalloc_node_track_caller(size, flags, node, ip);
> > > > +	WARN_ON(!obj);
> > > 
> > > Why don't we discharge from the reserve here if !obj?
> > 
> > Well, this allocation should never fail:
> >   - we reserved memory
> >   - we accounted/throttle its usage
> > 
> > Thus this allocation should always succeed.
> 
> But if it *does* fail, it doesn't help that we mess up the reservation
> counts, no?

I guess you're right there. Will fix. Thanks!

> > > > +{
> > > > +	size_t size = ksize(obj);
> > > > +
> > > > +	kfree(obj);
> > > 
> > > We're trying to get rid of kfree() so I'd __kfree_reserve() could to
> > > mm/sl?b.c. Matt, thoughts?
> > 
> > My issue with moving these helpers into mm/sl?b.c is that it would
> > require replicating all this code 3 times. Even though the functionality
> > is (or should) be invariant to the actual slab implementation.
> 
> Right, I guess we could just rename ksize() to something else then and
> keep it internal to mm/.

That would be nice - we can stuff it into mm/internal.h or somesuch.

Also, you might have noticed, I still need to do everything SLOB. The
last time I rewrote all this code I was still hoping Linux would 'soon'
have a single slab allocator, but evidently we're still going with 3 for
now.. :-/

So I guess I can no longer hide behind that and will have to bite the
bullet and write the SLOB bits..

> > > > +	/*
> > > > +	 * ksize gives the full allocated size vs the requested size we used to
> > > > +	 * charge; however since we round up to the nearest power of two, this
> > > > +	 * should all work nicely.
> > > > +	 */
> > > > +	mem_reserve_kmalloc_charge(res, -size);
> > > > +}

