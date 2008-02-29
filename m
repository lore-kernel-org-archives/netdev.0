From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
Date: Fri, 29 Feb 2008 13:18:53 +0100
Message-ID: <1204287533.6243.105.camel@lappy>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
	 <1204285912.6243.93.camel@lappy>
	 <84144f020802290358t2774f7bwd87efe79e7bd4235@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Christoph Lameter <clameter@sgi.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33284 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbYB2MTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 07:19:55 -0500
In-Reply-To: <84144f020802290358t2774f7bwd87efe79e7bd4235@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-02-29 at 13:58 +0200, Pekka Enberg wrote:
> Hi Peter,
> 
> On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >  I made page->reserve into PG_emergency and made that bit stick for the
> >  lifetime of that page allocation. I then made kmem_is_emergency() look
> >  up the head page backing that allocation's slab and return
> >  PageEmergency().
> 
> [snip]
> 
> On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >  This is a stricter model than I had before, and has one ramification I'm
> >  not entirely sure I like.
> >
> >  It means the page remains a reserve page throughout its lifetime, which
> >  means the slab remains a reserve slab throughout its lifetime. Therefore
> >  it may never be used for !reserve allocations. Which in turn generates
> >  complexities for the partial list.
> 
> Hmm, so why don't we then clear the PG_emergency flag then 

Clearing PG_emergency would mean kmem_is_emergency() would return false
in kfree_reserve() and fail to un-charge the object.

Previously objects would track their account status themselves (when
needed) and freeing PG_emergency wouldn't be a problem.

> and allocate a new fresh page to the reserves?

Not sure I understand this properly. We would only do this once the page
watermarks are high enough, so the reserves are full again.

> On Fri, Feb 29, 2008 at 1:51 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >  Does this sound like something I should pursuit? I feel it might
> >  complicate the slab allocators too much..
> 
> I can't answer that question until I see the code ;-). But overall, I
> think it's better to put that code in SLUB rather than trying to work
> around it elsewhere. The fact is, as soon as you have some sort of
> reservation for _objects_, you need help from the SLUB allocator.

Well, I agree with that consolidating it makes sense. And like I said,
it gives pretty code. However, it also puts the burden of this feature
on everyone and might affect performance - still its only the slow path,
but still.


