From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Sat, 8 Jul 2017 12:21:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1707081157020.17878-100000@netrider.rowland.org>
References: <20170708123018.qiwmyf3x43i4pgsg@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Manfred Spraul <manfred@colorfullife.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:51319 "HELO
        netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1752836AbdGHQVz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 12:21:55 -0400
In-Reply-To: <20170708123018.qiwmyf3x43i4pgsg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pardon me for barging in, but I found this whole interchange extremely 
confusing...

On Sat, 8 Jul 2017, Ingo Molnar wrote:

> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Sat, Jul 08, 2017 at 10:35:43AM +0200, Ingo Molnar wrote:
> > > 
> > > * Manfred Spraul <manfred@colorfullife.com> wrote:
> > > 
> > > > Hi Ingo,
> > > > 
> > > > On 07/07/2017 10:31 AM, Ingo Molnar wrote:
> > > > > 
> > > > > There's another, probably just as significant advantage: queued_spin_unlock_wait()
> > > > > is 'read-only', while spin_lock()+spin_unlock() dirties the lock cache line. On
> > > > > any bigger system this should make a very measurable difference - if
> > > > > spin_unlock_wait() is ever used in a performance critical code path.
> > > > At least for ipc/sem:
> > > > Dirtying the cacheline (in the slow path) allows to remove a smp_mb() in the
> > > > hot path.
> > > > So for sem_lock(), I either need a primitive that dirties the cacheline or
> > > > sem_lock() must continue to use spin_lock()/spin_unlock().

This statement doesn't seem to make sense.  Did Manfred mean to write 
"smp_mb()" instead of "spin_lock()/spin_unlock()"?

> > > Technically you could use spin_trylock()+spin_unlock() and avoid the lock acquire 
> > > spinning on spin_unlock() and get very close to the slow path performance of a 
> > > pure cacheline-dirtying behavior.

This is even more confusing.  Did Ingo mean to suggest using 
"spin_trylock()+spin_unlock()" in place of "spin_lock()+spin_unlock()" 
could provide the desired ordering guarantee without delaying other 
CPUs that may try to acquire the lock?  That seems highly questionable.

> > > But adding something like spin_barrier(), which purely dirties the lock cacheline, 
> > > would be even faster, right?
> > 
> > Interestingly enough, the arm64 and powerpc implementations of
> > spin_unlock_wait() were very close to what it sounds like you are
> > describing.
> 
> So could we perhaps solve all our problems by defining the generic version thusly:
> 
> void spin_unlock_wait(spinlock_t *lock)
> {
> 	if (spin_trylock(lock))
> 		spin_unlock(lock);
> }

How could this possibly be a generic version of spin_unlock_wait()?  
It does nothing at all (with no ordering properties) if some other CPU
currently holds the lock, whereas the real spin_unlock_wait() would
wait until the other CPU released the lock (or possibly longer).

And if no other CPU currently holds the lock, this has exactly the same
performance properties as spin_lock()+spin_unlock(), so what's the
advantage?

Alan Stern

> ... and perhaps rename it to spin_barrier() [or whatever proper name there would 
> be]?
> 
> Architectures can still optimize it, to remove the small window where the lock is 
> held locally - as long as the ordering is at least as strong as the generic 
> version.
> 
> This would have various advantages:
> 
>  - semantics are well-defined
> 
>  - the generic implementation is already pretty well optimized (no spinning)
> 
>  - it would make it usable for the IPC performance optimization
> 
>  - architectures could still optimize it to eliminate the window where the lock is
>    held locally - if there's such instructions available.
> 
> Was this proposed before, or am I missing something?
> 
> Thanks,
> 
> 	Ingo
