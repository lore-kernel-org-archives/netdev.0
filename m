From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Thu, 6 Jul 2017 18:05:55 +0200
Message-ID: <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'paulmck@linux.vnet.ibm.com'" <paulmck@linux.vnet.ibm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <
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

So that has the IRQ inversion issue found earlier in this patch-set. Not
actually doing the acquire though breaks other guarantees. See later.

> It might even be that this is the defined semantics of spin_unlock_wait().

As is, spin_unlock_wait() is somewhat ill defined. IIRC it grew from an
optimization by Oleg and subsequently got used elsewhere. And it being
the subtle bugger it is, there were bugs.

But part of the problem with that definition is fairness. For fair locks,
spin_lock()+spin_unlock() partakes in the fairness protocol. Many of the
things that would make spin_lock_sync() cheaper preclude it doing that.

(with the exception of ticket locks, those could actually do this).

But I think we can argue we don't in fact want that, all we really need
is to ensure the completion of the _current_ lock. But then you've
violated that equivalent thing.

As is, this is all a bit up in the air -- some of the ticket lock
variants are fair or minimal, the qspinlock on is prone to starvation
(although I think I can in fact fix that for qspinlock).

> Note that it can only be useful to do a spin_lock/unlock pair if it is
> impossible for another code path to try to acquire the lock.
> (Or, at least, the code can't care if the lock is acquired just after.)
> So if it can de determined that the lock isn't held (a READ_ONCE()
> might be enough) the lock itself need not be acquired (with the
> associated slow bus cycles).

Now look at the ARM64/PPC implementations that do explicit stores.

READ_ONCE() can only ever be sufficient on strongly ordered
architectures, but given many performance critical architectures are in
fact weakly ordered, you've opened up the exact can of worms we want to
get rid of the thing for.


So given:

(1)

  spin_lock()
  spin_unlock()

does not in fact provide memory ordering. Any prior/subsequent
load/stores can leak into the section and cross there.

What the thing does do however is serialize against other critical
sections in that:

(2)

  CPU0			CPU1

			spin_lock()
  spin_lock()
			X = 5
			spin_unlock()
  spin_unlock()
  r = X;

we must have r == 5 (due to address dependency on the lock; CPU1 does
the store to X, then a store-release to the lock. CPU0 then does a
load-acquire on the lock and that fully orders the subsequent load of X
to the prior store of X).


The other way around is more difficult though:

(3)

  CPU0			CPU1

  X=5
  spin_lock()
			spin_lock()
  spin_unlock()
			r = X;
			spin_unlock()

Where the above will in fact observe r == 5, this will be very difficult
to achieve with anything that will not let CPU1 wait. Which was the
entire premise of the original optimization by Oleg.

One of the later fixes we did to spin_unlock_wait() is to give it
ACQUIRE semantics to deal with (2) but even that got massively tricky,
see for example the ARM64 / PPC implementations.



In short, I doubt there is any real optimization possible if you want to
retain exact lock+unlock semantics.

Now on the one hand I feel like Oleg that it would be a shame to loose
the optimization, OTOH this thing is really really tricky to use,
and has lead to a number of bugs already.
