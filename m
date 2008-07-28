From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 12/30] mm: memory reserve management
Date: Mon, 28 Jul 2008 19:13:43 +0200
Message-ID: <1217265223.18049.22.camel@twins>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <1217239564.7813.36.camel@penberg-laptop>  <1217263769.15724.32.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Neil Brown <neilb@suse.de>, cl@linux-foundation.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:62097 "EHLO
	viefep15-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752972AbYG1RNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 13:13:52 -0400
Received: from edge01.upc.biz ([192.168.13.236]) by viefep15-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080728171350.KEZN14014.viefep15-int.chello.at@edge01.upc.biz>
          for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 19:13:50 +0200
In-Reply-To: <1217263769.15724.32.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 11:49 -0500, Matt Mackall wrote:
> On Mon, 2008-07-28 at 13:06 +0300, Pekka Enberg wrote:
> > We're trying to get rid of kfree() so I'd __kfree_reserve() could to
> > mm/sl?b.c. Matt, thoughts?
> 
> I think you mean ksize there. My big issue is that we need to make it
> clear that ksize pairs -only- with kmalloc and that
> ksize(kmem_cache_alloc(...)) is a categorical error. Preferably, we do
> this by giving it a distinct name, like kmalloc_size(). We can stick an
> underbar in front of it to suggest you ought not be using it too.

Right, both make sense, so _kmalloc_size() has my vote.

> > > +	/*
> > > +	 * ksize gives the full allocated size vs the requested size we
> > used to
> > > +	 * charge; however since we round up to the nearest power of two,
> > this
> > > +	 * should all work nicely.
> > > +	 */
> 
> SLOB doesn't do this, of course. But does that matter? I think you want
> to charge the actual allocation size to the reserve in all cases, no?
> That probably means calling ksize() on both alloc and free.

Like said, I still need to do all the SLOB reservation stuff. That
includes coming up with upper bound fragmentation loss.

For SL[UA]B I use roundup_power_of_two for kmalloc sizes. Thus with the
above ksize(), if we did p=kmalloc(x), then we'd account
roundup_power_of_two(x), and that should be equal to
roundup_power_of_two(ksize(p)), as ksize will always be smaller or equal
to the roundup.

I'm guessing the power of two upper bound is good for SLOB too -
although I haven't tried proving it wrong or tighetening it.

Only the kmem_cache_* reservation stuff would need some extra attention
with SLOB.

