From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply rcu_access_pointer() to avoid sparse false positive
Date: Sat, 12 Oct 2013 18:43:45 +0200
Message-ID: <20131012164345.GB20321@order.stressinduktion.org>
References: <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com> <20131009225617.GH11709@jtriplet-mobl1> <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com> <20131009234040.GB14055@jtriplet-mobl1> <1381363960.4971.55.camel@edumazet-glaptop.roam.corp.google.com> <20131010002833.GJ5790@linux.vnet.ibm.com> <20131010020422.GB24368@order.stressinduktion.org> <20131010190532.GQ5790@linux.vnet.ibm.com> <20131012022508.GA20321@order.stressinduktion.org> <20131012075336.GA5790@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>,
	linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58080 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3JLQnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 12:43:47 -0400
Content-Disposition: inline
In-Reply-To: <20131012075336.GA5790@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 12, 2013 at 12:53:36AM -0700, Paul E. McKenney wrote:
> On Sat, Oct 12, 2013 at 04:25:08AM +0200, Hannes Frederic Sowa wrote:
> > I saw your patch regarding making rcu_assign_pointer volatile and wonder if we
> > can still make it a bit more safe to use if we force the evaluation of the
> > to-be-assigned pointer before the write barrier. This is what I have in mind:
> > 
> > diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> > index f1f1bc3..79eccc3 100644
> > --- a/include/linux/rcupdate.h
> > +++ b/include/linux/rcupdate.h
> > @@ -550,8 +550,9 @@ static inline void rcu_preempt_sleep_check(void)
> >  	})
> >  #define __rcu_assign_pointer(p, v, space) \
> >  	do { \
> > +		typeof(v) ___v = (v); \
> >  		smp_wmb(); \
> > -		(p) = (typeof(*v) __force space *)(v); \
> > +		(p) = (typeof(*___v) __force space *)(___v); \
> >  	} while (0)
> > 
> > 
> > I don't think ___v must be volatile for this case because the memory barrier
> > will force the evaluation of v first.
> > 
> > This would guard against cases where rcu_assign_pointer is used like:
> > 
> > rcu_assign_pointer(ptr, compute_ptr_with_side_effects());
> 
> I am sorry, but I am not seeing how this would be particularly useful.

Oh, I do not think it is useful. It should help enforcing the right memory
orderings if someone uses rcu_assign_pointer in such a nasty way.

It was meant by me as a "defensive rearragement" to guard rcu_assign_pointer
to accidentaly slip memory mutations across the barrier without hurting
compiler optimizations too bad (or at all).

> The point of rcu_assign_pointer() is to order the initialization of
> a data structure against publishing a pointer to that data structure.
> An example may be found in cgroup_create():
> 
> 	name = cgroup_alloc_name(dentry);
> 	if (!name)
> 		goto err_free_cgrp;
> 	rcu_assign_pointer(cgrp->name, name);
> 
> Here, cgroup_alloc_name() allocates memory for the name and fills in
> the name:
> 
> static struct cgroup_name *cgroup_alloc_name(struct dentry *dentry)
> {
> 	struct cgroup_name *name;
> 
> 	name = kmalloc(sizeof(*name) + dentry->d_name.len + 1, GFP_KERNEL);
> 	if (!name)
> 		return NULL;
> 	strcpy(name->name, dentry->d_name.name);
> 	return name;
> }
> 
> So the point of the smp_wmb() in __rcu_assign_pointer() is to order the
> strcpy() in cgroup_alloc_name() to happen before the assignment of the
> name pointer to cgrp->name.
> 
> To make this example fit your pattern, we could change the code in
> cgroup_create() to look as follows (and to be buggy):
> 
> 	/* BAD CODE!  Do not do this! */
> 	rcu_assign_pointer(cgrp->name, cgroup_alloc_name(dentry));
> 	if (!cgrp->name)
> 		goto err_free_cgrp;
> 
> The reason that this is bad practice is that it is hiding the fact that
> the allocation and initialization in cgroup_alloc_name() needs to be
> ordered before the assignment to cgrp->name.
> 
> Make sense?

Absolutely! But e.g. the pointer could be preallocated and no length
checks are needed so there is no need for an error path, I guess someone
could think it is safe to put the get_ptr_with_side_effects (and if the
side effect is only a bit flip in the strucutre pointed to by the value)
in the v argument of rcu_assign_pointer.

I also tought about adding a (*(&(v))) statement to enfore that only
lvalues where allowed as the value in rcu_assign_pointer, but that would
already cause compilation errors (e.g. rcu_assign_pointer(ptr, ptr|MARK)).

The nice thing with ACCESS_ONCE(p) is, that there is now no way to put
a non-lvalue expression into the first argument of rcu_assign_pointer. :)

Regarding the volatile access, I hope that the C11 memory model
and enhancements to the compiler will some day provide a better
way to express the semantics of what is tried to express here
(__atomic_store_n/__atomic_load_n with the accompanied memory model,
which could be even weaker to what a volatile access would enfore
now and could guarantee atomic stores/loads).

Greeting,

  Hannes
