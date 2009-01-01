From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] cpualloc: improvements to per-cpu allocation
Date: Thu, 1 Jan 2009 10:56:23 +1030
Message-ID: <200901011056.23443.rusty@rustcorp.com.au>
References: <200812310938.09912.rusty@rustcorp.com.au> <Pine.LNX.4.64.0812311717050.22685@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	catalin.marinas@arm.com,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33566 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbZAAA00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 19:26:26 -0500
In-Reply-To: <Pine.LNX.4.64.0812311717050.22685@quilx.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 January 2009 09:57:49 Christoph Lameter wrote:
> On Wed, 31 Dec 2008, Rusty Russell wrote:
> 
> > afterwards, with many more to come (eg. local_t is now more useful, if we sort
> > the semantics of what it should look like).
> 
> Well I dont like local_t as you may have noticed. It limits us to an int.
> I think its better to start out with the idea of the cmpxchg that applies
> to any scalar. Focus on the operations instead of the use of types.

Yes, doing an audit of actual and potential local_t-like users is on my
todo list (after the merge frenzy).  I like your variable types, but it
make a trival implementation difficult/impossible, which is optimal for
sparc64 and similar to what SNMP counters currently use.  We might not
be able to please everyone though.

> Ok so a special allocator for big percpu that avoids the need to
> dynamically resize percpu sections. But this still leaves the problem that
> too many small allocations may overflow the percpu area.

Yes, and this is a hack.  Eventually we want to grow the percpu area, but
that may not be done for 2.6.30.  Most allocations are tiny, so we'd need
thousands to overflow.  Those are the kind of people who do vmalloc= on
the command line, so percpu= shouldn't kill them.

> >     Christoph did the hard work of figuring out what the number should be
> >     (based on converting the slub allocator).  allyesconfig on x86-32 uses
> >     7k before mounting root, so 10k seems reasonable.
> 
> This is only the requirement if the page allocator and slab allocator is
> converted to use the percpu area. Additional users may require more space.

Yes, and hence I double-checked it with allyesconfig.  We'll need to be
vigilant as we add more usages.

> > commit a56f30e8a075e8ce15b4dff8e3fe0edb9baff7ea
> > Author: Rusty Russell <rusty@rustcorp.com.au>
> > Date:   Wed Dec 31 09:21:53 2008 +1030
> >
> >     alloc_percpu: remove per_cpu__ prefix.
> >
> >     Now that the return from alloc_percpu is compatible with the address
> >     of per-cpu vars, it makes sense to hand around the address of per-cpu
> >     variables.  To make this sane, we remove the per_cpu__ prefix we used
> >     created to stop people accidentally using these vars directly.
> 
> Doesnt that move limit how the percpu area can be handled by the arch? If
> it becomes a requirement that a percpu address is like any other global
> variable then the zero based approach no longer works and with that we may
> create x86_64 issues for pda conversion.

I don't think it's a problem.  You still can't use them directly (this
wording was not meant to imply that), but you can now hand their addresses
to per_cpu_ptr() etc.  So zero-based x86-64 should Just Work.

Cheers,
Rusty.
