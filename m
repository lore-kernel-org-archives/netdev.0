From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Sat, 1 Jul 2017 19:00:45 -0700
Message-ID: <20170702020045.GR2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <a6642feb-2f3a-980f-5ed6-2deb79563e6b@colorfullife.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, tj@kernel.org, arnd@arndb.de,
        linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a6642feb-2f3a-980f-5ed6-2deb79563e6b@colorfullife.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 01, 2017 at 09:44:12PM +0200, Manfred Spraul wrote:
> Hi Paul,
> 
> On 06/30/2017 02:01 AM, Paul E. McKenney wrote:
> >There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> >and it appears that all callers could do just as well with a lock/unlock
> >pair.  This commit therefore replaces the spin_unlock_wait() calls
> >in nf_conntrack_lock() and nf_conntrack_all_lock() with spin_lock()
> >followed immediately by spin_unlock().  These functions do not appear
> >to be invoked on any fastpaths.
> >
> >Signed-off-by: Paul E. McKenney<paulmck@linux.vnet.ibm.com>
> >Cc: Pablo Neira Ayuso<pablo@netfilter.org>
> >Cc: Jozsef Kadlecsik<kadlec@blackhole.kfki.hu>
> >Cc: Florian Westphal<fw@strlen.de>
> >Cc: "David S. Miller"<davem@davemloft.net>
> >Cc:<netfilter-devel@vger.kernel.org>
> >Cc:<coreteam@netfilter.org>
> >Cc:<netdev@vger.kernel.org>
> >Cc: Will Deacon<will.deacon@arm.com>
> >Cc: Peter Zijlstra<peterz@infradead.org>
> >Cc: Alan Stern<stern@rowland.harvard.edu>
> >Cc: Andrea Parri<parri.andrea@gmail.com>
> >Cc: Linus Torvalds<torvalds@linux-foundation.org>
> >---
> >  net/netfilter/nf_conntrack_core.c | 26 ++++++++------------------
> >  1 file changed, 8 insertions(+), 18 deletions(-)
> >
> >diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> >index e847dbaa0c6b..9f997859d160 100644
> >--- a/net/netfilter/nf_conntrack_core.c
> >+++ b/net/netfilter/nf_conntrack_core.c
> >@@ -99,15 +99,11 @@ void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
> >  	spin_lock(lock);
> >  	while (unlikely(nf_conntrack_locks_all)) {
> I think here an ACQUIRE is missing.
> >  		spin_unlock(lock);
> >-
> >-		/*
> >-		 * Order the 'nf_conntrack_locks_all' load vs. the
> >-		 * spin_unlock_wait() loads below, to ensure
> >-		 * that 'nf_conntrack_locks_all_lock' is indeed held:
> >-		 */
> >-		smp_rmb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
> >-		spin_unlock_wait(&nf_conntrack_locks_all_lock);
> >+		/* Wait for nf_conntrack_locks_all_lock holder to release ... */
> >+		spin_lock(&nf_conntrack_locks_all_lock);
> >+		spin_unlock(&nf_conntrack_locks_all_lock);
> >  		spin_lock(lock);
> >+		/* ... and retry. */
> >  	}
> >  }
> As far as I see, nf_conntrack_locks[] nests inside
> nf_conntrack_lock_all_lock.
> So
>    spin_lock(&nf_conntrack_locks_all_lock);
>    spin_lock(lock);
>    spin_unlock(&nf_conntrack_locks_all_lock);
> 
> can replace the retry logic.
> 
> Correct? Then what about the attached patch?

At first glance, it looks correct to me, thank you!  I have replaced my
patch with this one for testing and further review.

							Thanx, Paul

> --
>     Manfred
> 
> 

> >From 453e7a77f3756d939c754031b092cbdfbd149559 Mon Sep 17 00:00:00 2001
> From: Manfred Spraul <manfred@colorfullife.com>
> Date: Sun, 21 Aug 2016 07:17:55 +0200
> Subject: [PATCH] net/netfilter/nf_conntrack_core: Fix net_conntrack_lock()
> 
> As we want to remove spin_unlock_wait() and replace it with explicit
> spin_lock()/spin_unlock() calls, we can use this to simplify the
> locking.
> 
> In addition:
> - Reading nf_conntrack_locks_all needs ACQUIRE memory ordering.
> - The new code avoids the backwards loop.
> 
> Only slightly tested, I did not manage to trigger calls to
> nf_conntrack_all_lock().
> 
> Fixes: b16c29191dc8
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Cc: <stable@vger.kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: netfilter-devel@vger.kernel.org
> ---
>  net/netfilter/nf_conntrack_core.c | 44 +++++++++++++++++++++------------------
>  1 file changed, 24 insertions(+), 20 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index e847dba..1193565 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -96,19 +96,24 @@ static struct conntrack_gc_work conntrack_gc_work;
> 
>  void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
>  {
> +	/* 1) Acquire the lock */
>  	spin_lock(lock);
> -	while (unlikely(nf_conntrack_locks_all)) {
> -		spin_unlock(lock);
> 
> -		/*
> -		 * Order the 'nf_conntrack_locks_all' load vs. the
> -		 * spin_unlock_wait() loads below, to ensure
> -		 * that 'nf_conntrack_locks_all_lock' is indeed held:
> -		 */
> -		smp_rmb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
> -		spin_unlock_wait(&nf_conntrack_locks_all_lock);
> -		spin_lock(lock);
> -	}
> +	/* 2) read nf_conntrack_locks_all, with ACQUIRE semantics */
> +	if (likely(smp_load_acquire(&nf_conntrack_locks_all) == false))
> +		return;
> +
> +	/* fast path failed, unlock */
> +	spin_unlock(lock);
> +
> +	/* Slow path 1) get global lock */
> +	spin_lock(&nf_conntrack_locks_all_lock);
> +
> +	/* Slow path 2) get the lock we want */
> +	spin_lock(lock);
> +
> +	/* Slow path 3) release the global lock */
> +	spin_unlock(&nf_conntrack_locks_all_lock);
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_lock);
> 
> @@ -149,18 +154,17 @@ static void nf_conntrack_all_lock(void)
>  	int i;
> 
>  	spin_lock(&nf_conntrack_locks_all_lock);
> -	nf_conntrack_locks_all = true;
> 
> -	/*
> -	 * Order the above store of 'nf_conntrack_locks_all' against
> -	 * the spin_unlock_wait() loads below, such that if
> -	 * nf_conntrack_lock() observes 'nf_conntrack_locks_all'
> -	 * we must observe nf_conntrack_locks[] held:
> -	 */
> -	smp_mb(); /* spin_lock(&nf_conntrack_locks_all_lock) */
> +	nf_conntrack_locks_all = true;
> 
>  	for (i = 0; i < CONNTRACK_LOCKS; i++) {
> -		spin_unlock_wait(&nf_conntrack_locks[i]);
> +		spin_lock(&nf_conntrack_locks[i]);
> +
> +		/* This spin_unlock provides the "release" to ensure that
> +		 * nf_conntrack_locks_all==true is visible to everyone that
> +		 * acquired spin_lock(&nf_conntrack_locks[]).
> +		 */
> +		spin_unlock(&nf_conntrack_locks[i]);
>  	}
>  }
> 
> -- 
> 2.9.4
> 

