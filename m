From: Hugh Dickins <hugh@veritas.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 19:44:58 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
 <20070515104453.f901e91f.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Badari Pulavarty <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-1.symantec.com ([216.10.194.28]:35112 "EHLO
	extu-mxob-1.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129AbXEOVWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 17:22:03 -0400
In-Reply-To: <Pine.LNX.4.64.0705151109021.31972@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 May 2007, Christoph Lameter wrote:
> On Tue, 15 May 2007, Andrew Morton wrote:
> 
> > I _think_ we can just do
> > 
> > --- a/fs/compat.c~a
> > +++ a/fs/compat.c
> > @@ -1566,9 +1566,13 @@ int compat_core_sys_select(int n, compat
> >  	 */
> >  	ret = -ENOMEM;
> >  	size = FDS_BYTES(n);
> > -	bits = kmalloc(6 * size, GFP_KERNEL);
> > -	if (!bits)
> > -		goto out_nofds;
> > +	if (likely(size)) {
> > +		bits = kmalloc(6 * size, GFP_KERNEL);
> > +		if (!bits)
> > +			goto out_nofds;
> > +	} else {
> > +		bits = NULL;
> > +	}

It's interesting that compat_core_sys_select() shows this kmalloc(0)
failure but core_sys_select() does not.  That's because core_sys_select()
avoids kmalloc by using a buffer on the stack for small allocations (and
0 sure is small).  Shouldn't compat_core_sys_select() do just the same?
Or is SLUB going to be so efficient that doing so is a waste of time?

> >  	fds.in      = (unsigned long *)  bits;
> >  	fds.out     = (unsigned long *) (bits +   size);
> >  	fds.ex      = (unsigned long *) (bits + 2*size);
> > _
> > 
> > I mean, if that oopses then I'd be very interested in finding out why.
> > 
> > But I'm starting to suspect that it would be better to permit kmalloc(0) in
> > slub.  It depends on how many more of these things need fixing.
> > 
> > otoh, a kmalloc(0) could be a sign of some buggy/inefficient/weird code, so
> > there's some value in forcing us to go look at all the callsites.
>  
> Hmmm... We could have kmalloc(0) return a pointer to the zero page? That 
> would catch any writers?

I don't think using the zero page that way would be at all safe:
there's probably configurations/architectures in which it is write
protected, but I don't believe that's a given at all.

But the principle is good: ERR_PTR(-MAX_ERRNO) should work,
that area up the top should always give a fault.
Hmm, but perhaps there are architectures on which it does not?

Hugh
