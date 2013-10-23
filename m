From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 3/3] netfilter: x_tables: fix ordering of jumpstack
 allocation and table update
Date: Wed, 23 Oct 2013 17:37:07 +0100
Message-ID: <20131023163706.GA5117@mudshark.cambridge.arm.com>
References: <1382519724-3953-1-git-send-email-pablo@netfilter.org>
 <1382519724-3953-4-git-send-email-pablo@netfilter.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B73A2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:64052 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622Ab3JWQhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:37:19 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Oct 23, 2013 at 10:45:04AM +0100, David Laight wrote:
> > Subject: [PATCH 3/3] netfilter: x_tables: fix ordering of jumpstack allocation and table update
> ...
> > Meanwhile, CPU0 is handling the network receive path and ends up in
> > ipt_do_table, resulting in:
> > 
> > 	private = table->private;
> > 
> > 	[...]
> > 
> > 	jumpstack  = (struct ipt_entry **)private->jumpstack[cpu];
> > 
> > On weakly ordered memory architectures, the writes to table->private
> > and newinfo->jumpstack from CPU1 can be observed out of order by CPU0.
> > Furthermore, on architectures which don't respect ordering of address
> > dependencies (i.e. Alpha), the reads from CPU0 can also be re-ordered.
> 
> Which reads might be out of order?
> AFAICT they are strongly sequenced because they second depends on the
> value read by the first.
> So I don't see why the read barrier is needed.

That is why this is a dependent read barrier. Some architectures (e.g.
Alpha) *do* allow dependent reads to be observed out of order, so you can
effectively load the data pointed to by a pointer before you load the
pointer itself!

Take a look at Paul's paper about memory ordering if you're curious:

  http://www.rdrop.com/users/paulmck/scalability/paper/whymb.2009.04.05a.pdf

> > -	table->private = newinfo;
> >  	newinfo->initial_entries = private->initial_entries;
> > +	/*
> > +	 * Ensure contents of newinfo are visible before assigning to
> > +	 * private.
> > +	 */
> > +	smp_wmb();
> > +	table->private = newinfo;
> 
> Those writes were in the wrong order on all systems.
> Also gcc needs to be told not to reorder the writes even on non-smp
> systems (if the code might be pre-empted).
> So an asm volatile (:::"memory") is needed there even if no specific
> synchronisation instruction is needed.

The smp_* barriers expand to barrier() when !CONFIG_SMP, which gives you the
memory clobber you want.

What I'm *not* 100% sure about is the table freeing path. There is a mutex
there for removing the table from a list, but I'm not sure how we ensure
that there are no parallel readers at that point.

Will
