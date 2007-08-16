From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] lockdep: annotate rcu_read_{,un}lock()
Date: Thu, 16 Aug 2007 09:01:45 -0700
Message-ID: <20070816160145.GA16957@linux.vnet.ibm.com>
References: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com> <E1ILEJr-0005Fl-00@gondolin.me.apana.org.au> <20070815.144628.104052147.davem@davemloft.net> <1187274307.6114.92.camel@twins>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, herbert@gondor.apana.org.au,
	123.oleg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Daniel Walker <dwalker@mvista.com>, josht@linux.vnet.ibm.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:33944 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765588AbXHPQBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 12:01:49 -0400
Content-Disposition: inline
In-Reply-To: <1187274307.6114.92.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 04:25:07PM +0200, Peter Zijlstra wrote:
> 
> There seem to be some unbalanced rcu_read_{,un}lock() issues of late,
> how about doing something like this:

This will break when rcu_read_lock() and rcu_read_unlock() are invoked
from NMI/SMI handlers -- the raw_local_irq_save() in lock_acquire() will
not mask NMIs or SMIs.

One approach would be to check for being in an NMI/SMI handler, and
to avoid calling lock_acquire() and lock_release() in those cases.
Another approach would be to use sparse, which has checks for
rcu_read_lock()/rcu_read_unlock() nesting.

							Thanx, Paul

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/lockdep.h  |    7 +++++++
>  include/linux/rcupdate.h |   12 ++++++++++++
>  kernel/rcupdate.c        |    8 ++++++++
>  3 files changed, 27 insertions(+)
> 
> Index: linux-2.6/include/linux/lockdep.h
> ===================================================================
> --- linux-2.6.orig/include/linux/lockdep.h
> +++ linux-2.6/include/linux/lockdep.h
> @@ -252,6 +252,13 @@ extern void lockdep_init_map(struct lock
>  			     struct lock_class_key *key, int subclass);
> 
>  /*
> + * To initialize a lockdep_map statically use this macro.
> + * Note that _name must not be NULL.
> + */
> +#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
> +	{ .name = (_name), .key = (void *)(_key), }
> +
> +/*
>   * Reinitialize a lock key - for cases where there is special locking or
>   * special initialization of locks so that the validator gets the scope
>   * of dependencies wrong: they are either too broad (they need a class-split)
> Index: linux-2.6/include/linux/rcupdate.h
> ===================================================================
> --- linux-2.6.orig/include/linux/rcupdate.h
> +++ linux-2.6/include/linux/rcupdate.h
> @@ -41,6 +41,7 @@
>  #include <linux/percpu.h>
>  #include <linux/cpumask.h>
>  #include <linux/seqlock.h>
> +#include <linux/lockdep.h>
> 
>  /**
>   * struct rcu_head - callback structure for use with RCU
> @@ -133,6 +134,15 @@ static inline void rcu_bh_qsctr_inc(int 
>  extern int rcu_pending(int cpu);
>  extern int rcu_needs_cpu(int cpu);
> 
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +extern struct lockdep_map rcu_lock_map;
> +# define rcu_read_acquire()	lock_acquire(&rcu_lock_map, 0, 0, 2, 1, _THIS_IP_)
> +# define rcu_read_release()	lock_release(&rcu_lock_map, 1, _THIS_IP_)
> +#else
> +# define rcu_read_acquire()	do { } while (0)
> +# define rcu_read_release()	do { } while (0)
> +#endif
> +
>  /**
>   * rcu_read_lock - mark the beginning of an RCU read-side critical section.
>   *
> @@ -166,6 +176,7 @@ extern int rcu_needs_cpu(int cpu);
>  	do { \
>  		preempt_disable(); \
>  		__acquire(RCU); \
> +		rcu_read_acquire(); \
>  	} while(0)
> 
>  /**
> @@ -175,6 +186,7 @@ extern int rcu_needs_cpu(int cpu);
>   */
>  #define rcu_read_unlock() \
>  	do { \
> +		rcu_read_release(); \
>  		__release(RCU); \
>  		preempt_enable(); \
>  	} while(0)
> Index: linux-2.6/kernel/rcupdate.c
> ===================================================================
> --- linux-2.6.orig/kernel/rcupdate.c
> +++ linux-2.6/kernel/rcupdate.c
> @@ -49,6 +49,14 @@
>  #include <linux/cpu.h>
>  #include <linux/mutex.h>
> 
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +static struct lock_class_key rcu_lock_key;
> +struct lockdep_map rcu_lock_map =
> +	STATIC_LOCKDEP_MAP_INIT("rcu_read_lock", &rcu_lock_key);
> +
> +EXPORT_SYMBOL_GPL(rcu_lock_map);
> +#endif
> +
>  /* Definition for rcupdate control block. */
>  static struct rcu_ctrlblk rcu_ctrlblk = {
>  	.cur = -300,
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
