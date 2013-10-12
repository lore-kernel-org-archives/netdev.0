From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Sat, 12 Oct 2013 00:53:36 -0700
Message-ID: <20131012075336.GA5790@linux.vnet.ibm.com>
References: <20131009223652.GC5790@linux.vnet.ibm.com>
 <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009225617.GH11709@jtriplet-mobl1>
 <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009234040.GB14055@jtriplet-mobl1>
 <1381363960.4971.55.camel@edumazet-glaptop.roam.corp.google.com>
 <20131010002833.GJ5790@linux.vnet.ibm.com>
 <20131010020422.GB24368@order.stressinduktion.org>
 <20131010190532.GQ5790@linux.vnet.ibm.com>
 <20131012022508.GA20321@order.stressinduktion.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131012022508.GA20321@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 12, 2013 at 04:25:08AM +0200, Hannes Frederic Sowa wrote:
> On Thu, Oct 10, 2013 at 12:05:32PM -0700, Paul E. McKenney wrote:
> > On Thu, Oct 10, 2013 at 04:04:22AM +0200, Hannes Frederic Sowa wrote:
> > > On Wed, Oct 09, 2013 at 05:28:33PM -0700, Paul E. McKenney wrote:
> > > > On Wed, Oct 09, 2013 at 05:12:40PM -0700, Eric Dumazet wrote:
> > > > > On Wed, 2013-10-09 at 16:40 -0700, Josh Triplett wrote:
> > > > > 
> > > > > > that.  Constructs like list_del_rcu are much clearer, and not
> > > > > > open-coded.  Open-coding synchronization code is almost always a Bad
> > > > > > Idea.
> > > > > 
> > > > > OK, so you think there is synchronization code.
> > > > > 
> > > > > I will shut up then, no need to waste time.
> > > > 
> > > > As you said earlier, we should at least get rid of the memory barrier
> > > > as long as we are changing the code.
> > > 
> > > Interesting thread!
> > > 
> > > Sorry to chime in and asking a question:
> > > 
> > > Why do we need an ACCESS_ONCE here if rcu_assign_pointer can do without one?
> > > In other words I wonder why rcu_assign_pointer is not a static inline function
> > > to use the sequence point in argument evaluation (if I remember correctly this
> > > also holds for inline functions) to not allow something like this:
> > > 
> > > E.g. we want to publish which lock to take first to prevent an ABBA problem
> > > (extreme example):
> > > 
> > > rcu_assign_pointer(lockptr, min(lptr1, lptr2));
> > > 
> > > Couldn't a compiler spill the lockptr memory location as a temporary buffer
> > > if the compiler is under register pressure? (yes, this seems unlikely if we
> > > flushed out most registers to memory because of the barrier, but still... ;) )
> > > 
> > > This seems to be also the case if we publish a multi-dereferencing pointers
> > > e.g. ptr->ptr->ptr.
> > 
> > IIRC, sequence points only confine volatile accesses.  For non-volatile
> > accesses, the so-called "as-if rule" allows compiler writers to do some
> > surprisingly global reordering.
> > 
> > The reason that rcu_assign_pointer() isn't an inline function is because
> > it needs to be type-generic, in other words, it needs to be OK to use
> > it on any type of pointers as long as the C types of the two pointers
> > match (the sparse types can vary a bit).
> > 
> > One of the reasons for wanting a volatile cast in rcu_assign_pointer() is
> > to prevent compiler mischief such as you described in your last two
> > paragraphs.  That said, it would take a very brave compiler to pull
> > a pointer-referenced memory location into a register and keep it there.
> > Unfortunately, increasing compiler bravery seems to be a solid long-term
> > trend.
> 
> I saw your patch regarding making rcu_assign_pointer volatile and wonder if we
> can still make it a bit more safe to use if we force the evaluation of the
> to-be-assigned pointer before the write barrier. This is what I have in mind:
> 
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index f1f1bc3..79eccc3 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -550,8 +550,9 @@ static inline void rcu_preempt_sleep_check(void)
>  	})
>  #define __rcu_assign_pointer(p, v, space) \
>  	do { \
> +		typeof(v) ___v = (v); \
>  		smp_wmb(); \
> -		(p) = (typeof(*v) __force space *)(v); \
> +		(p) = (typeof(*___v) __force space *)(___v); \
>  	} while (0)
> 
> 
> I don't think ___v must be volatile for this case because the memory barrier
> will force the evaluation of v first.
> 
> This would guard against cases where rcu_assign_pointer is used like:
> 
> rcu_assign_pointer(ptr, compute_ptr_with_side_effects());

I am sorry, but I am not seeing how this would be particularly useful.

The point of rcu_assign_pointer() is to order the initialization of
a data structure against publishing a pointer to that data structure.
An example may be found in cgroup_create():

	name = cgroup_alloc_name(dentry);
	if (!name)
		goto err_free_cgrp;
	rcu_assign_pointer(cgrp->name, name);

Here, cgroup_alloc_name() allocates memory for the name and fills in
the name:

static struct cgroup_name *cgroup_alloc_name(struct dentry *dentry)
{
	struct cgroup_name *name;

	name = kmalloc(sizeof(*name) + dentry->d_name.len + 1, GFP_KERNEL);
	if (!name)
		return NULL;
	strcpy(name->name, dentry->d_name.name);
	return name;
}

So the point of the smp_wmb() in __rcu_assign_pointer() is to order the
strcpy() in cgroup_alloc_name() to happen before the assignment of the
name pointer to cgrp->name.

To make this example fit your pattern, we could change the code in
cgroup_create() to look as follows (and to be buggy):

	/* BAD CODE!  Do not do this! */
	rcu_assign_pointer(cgrp->name, cgroup_alloc_name(dentry));
	if (!cgrp->name)
		goto err_free_cgrp;

The reason that this is bad practice is that it is hiding the fact that
the allocation and initialization in cgroup_alloc_name() needs to be
ordered before the assignment to cgrp->name.

Make sense?

							Thanx, Paul
