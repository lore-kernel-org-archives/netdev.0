From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] add rcu_assign_index() if ever needed
Date: Thu, 14 Feb 2008 10:48:42 -0800
Message-ID: <20080214184842.GD8910@linux.vnet.ibm.com>
References: <20080213220024.GA30729@linux.vnet.ibm.com> <20080213220515.GA10642@linux.vnet.ibm.com> <20080214092427.960d1f67.randy.dunlap@oracle.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org, dipankar@in.ibm.com,
	ego@in.ibm.com, herbert@gondor.apana.org.au,
	akpm@linux-foundation.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39186 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796AbYBNStL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 13:49:11 -0500
Content-Disposition: inline
In-Reply-To: <20080214092427.960d1f67.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2008 at 09:24:27AM -0800, Randy Dunlap wrote:
> On Wed, 13 Feb 2008 14:05:15 -0800 Paul E. McKenney wrote:
> 
> > Hello again!
> > 
> > This is a speculative patch that as far as I can tell is not yet required.
> > If anyone applies RCU to a data structure allocated out of an array, using
> > array indexes in place of pointers to link the array elements together,
> > then the rcu_assign_index() function in this patch will be needed to
> > assign a given element's array index to the RCU-traversed index.  The
> > implementation is exactly that of the old rcu_assign_pointer(), so is
> > extremely well tested.
> > 
> > The existing rcu_assign_pointer() will emit a compiler warning in cases
> > where rcu_assign_index() is required.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> > 
> >  rcupdate.h |   18 ++++++++++++++++++
> >  1 file changed, 18 insertions(+)
> > 
> > diff -urpNa -X dontdiff linux-2.6.24-rap/include/linux/rcupdate.h linux-2.6.24-rai/include/linux/rcupdate.h
> > --- linux-2.6.24-rap/include/linux/rcupdate.h	2008-02-13 13:36:47.000000000 -0800
> > +++ linux-2.6.24-rai/include/linux/rcupdate.h	2008-02-13 10:55:40.000000000 -0800
> > @@ -286,6 +286,24 @@ extern struct lockdep_map rcu_lock_map;
> >  	})
> >  
> >  /**
> > + * rcu_assign_index - assign (publicize) a index of a newly
> > + * initialized array elementg that will be dereferenced by RCU
> > + * read-side critical sections.  Returns the value assigned.
> > + *
> > + * Inserts memory barriers on architectures that require them
> > + * (pretty much all of them other than x86), and also prevents
> > + * the compiler from reordering the code that initializes the
> > + * structure after the index assignment.  More importantly, this
> > + * call documents which indexes will be dereferenced by RCU read-side
> > + * code.
> > + */
> 
> s/a index/index/
> 
> Along with Gautham's typo fix, you could also make this be passable
> kernel-doc notation.  :)

Guess I should do the same for rcu_assign_pointer() and probably several
others as well...  Good catch!!!

							Thanx, Paul

> See Documentation/kernel-doc-nano-HOWTO.txt for details.
> 
> Summary:
> The function (or macro) name and short description must be on one line.
> This is followed by the parameters, then a "blank" (actually " *") line,
> then any (longer) description, notes, etc.  So basically:
> 
> /**
>  * rcu_assign_index - assign (publicize) index of a newly initialized array element
>  * @p: description of @p
>  * @v: description of @v
>  *
>  * This function assigns (publicizes) the index of a newly
>  * initialized array element that will be dereferenced by RCU
>  * read-side critical sections.  Returns the value assigned.
>  *
>  * Inserts memory barriers on architectures that require them
>  * (pretty much all of them other than x86), and also prevents
>  * the compiler from reordering the code that initializes the
>  * structure after the index assignment.  More importantly, this
>  * call documents which indexes will be dereferenced by RCU read-side
>  * code.
>  */
> 
> 
> > +
> > +#define rcu_assign_index(p, v)	({ \
> > +					smp_wmb(); \
> > +					(p) = (v); \
> > +				})
> > +
> > +/**
> >   * synchronize_sched - block until all CPUs have exited any non-preemptive
> >   * kernel code sequences.
> >   *
> 
> ---
> ~Randy
