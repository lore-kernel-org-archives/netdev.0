From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH RFC 01/26] netfilter: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Mon, 3 Jul 2017 10:39:49 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1707031012180.2027-100000@iolanthe.rowland.org>
References: <a6642feb-2f3a-980f-5ed6-2deb79563e6b@colorfullife.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        <linux-kernel@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <oleg@redhat.com>,
        <akpm@linux-foundation.org>, <mingo@redhat.com>,
        <dave@stgolabs.net>, <tj@kernel.org>, <arnd@arndb.de>,
        <linux-arch@vger.kernel.org>, <will.deacon@arm.com>,
        <peterz@infradead.org>, <parri.andrea@gmail.com>,
        <torvalds@linux-foundation.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, <coreteam@netfilter.org>
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:42874 "HELO
        iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1754062AbdGCOjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 10:39:51 -0400
In-Reply-To: <a6642feb-2f3a-980f-5ed6-2deb79563e6b@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Jul 2017, Manfred Spraul wrote:

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

As far as I can tell, this read does not need to have ACQUIRE
semantics.

You need to guarantee that two things can never happen:

    (1) We read nf_conntrack_locks_all == false, and this routine's
	critical section for nf_conntrack_locks[i] runs after the
	(empty) critical section for that lock in 
	nf_conntrack_all_lock().

    (2) We read nf_conntrack_locks_all == true, and this routine's 
	critical section for nf_conntrack_locks_all_lock runs before 
	the critical section in nf_conntrack_all_lock().

In fact, neither one can happen even if smp_load_acquire() is replaced
with READ_ONCE().  The reason is simple enough, using this property of
spinlocks:

	If critical section CS1 runs before critical section CS2 (for 
	the same lock) then: (a) every write coming before CS1's
	spin_unlock() will be visible to any read coming after CS2's
	spin_lock(), and (b) no write coming after CS2's spin_lock()
	will be visible to any read coming before CS1's spin_unlock().

Thus for (1), assuming the critical sections run in the order mentioned
above, since nf_conntrack_all_lock() writes to nf_conntrack_locks_all
before releasing nf_conntrack_locks[i], and since nf_conntrack_lock()
acquires nf_conntrack_locks[i] before reading nf_conntrack_locks_all,
by (a) the read will always see the write.

Similarly for (2), since nf_conntrack_all_lock() acquires 
nf_conntrack_locks_all_lock before writing to nf_conntrack_locks_all, 
and since nf_conntrack_lock() reads nf_conntrack_locks_all before 
releasing nf_conntrack_locks_all_lock, by (b) the read cannot see the 
write.

Alan Stern

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
