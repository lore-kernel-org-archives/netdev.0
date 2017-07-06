From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 08:21:10 -0700
Message-ID: <20170706152110.GZ2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 02:12:24PM +0000, David Laight wrote:
> From: Paul E. McKenney
> > Sent: 06 July 2017 00:30
> > There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> > and it appears that all callers could do just as well with a lock/unlock
> > pair.  This series therefore removes spin_unlock_wait() and changes
> > its users to instead use a lock/unlock pair.  The commits are as follows,
> > in three groups:
> > 
> > 1-7.	Change uses of spin_unlock_wait() and raw_spin_unlock_wait()
> > 	to instead use a spin_lock/spin_unlock pair.  These may be
> > 	applied in any order, but must be applied before any later
> > 	commits in this series.  The commit logs state why I believe
> > 	that these commits won't noticeably degrade performance.
> 
> I can't help feeling that it might be better to have a spin_lock_sync()
> call that is equivalent to a spin_lock/spin_unlock pair.
> The default implementation being an inline function that does exactly that.
> This would let an architecture implement a more efficient version.
> 
> It might even be that this is the defined semantics of spin_unlock_wait().

That was in fact my first proposal, see the comment header in current
mainline for spin_unlock_wait() in include/linux/spinlock.h.  But Linus
quite rightly pointed out that if spin_unlock_wait() was to be defined in
this way, we should get rid of spin_unlock_wait() entirely, especially
given that there are not very many calls to spin_unlock_wait() and
also given that none of them are particularly performance critical.
Hence the current patch set, which does just that.

> Note that it can only be useful to do a spin_lock/unlock pair if it is
> impossible for another code path to try to acquire the lock.
> (Or, at least, the code can't care if the lock is acquired just after.)

Indeed!  As Oleg Nesterov pointed out, a spin_lock()/spin_unlock() pair
is sort of like synchronize_rcu() for a given lock, where that lock's
critical sections play the role of RCU read-side critical sections.
So anything before the pair is visible to later critical sections, and
anything in prior critical sections is visible to anything after the pair.
But again, as Linus pointed out, if we are going to have these semantics,
just do spin_lock() immediately followed by spin_unlock().

> So if it can de determined that the lock isn't held (a READ_ONCE()
> might be enough) the lock itself need not be acquired (with the
> associated slow bus cycles).

If you want the full semantics of a spin_lock()/spin_unlock() pair,
you need a full memory barrier before the READ_ONCE(), even on x86.
Without that memory barrier, you don't get the effect of the release
implicit in spin_unlock().

For weaker architectures, such as PowerPC and ARM, a READ_ONCE()
does -not- suffice, not at all, even with smp_mb() before and after.
I encourage you to take a look at arch_spin_unlock_wait() in arm64
and powerpc if youi are interested.  There were also some lengthy LKML
threads discussing this about 18 months ago that could be illuminating.

And yes, there are architecture-specific optimizations for an
empty spin_lock()/spin_unlock() critical section, and the current
arch_spin_unlock_wait() implementations show some of these optimizations.
But I expect that performance benefits would need to be demonstrated at
the system level.

							Thanx, Paul
