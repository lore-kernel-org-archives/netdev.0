From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 10:31:28 +0200
Message-ID: <20170707083128.wqk6msuuhtyykhpu@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Laight <David.Laight@ACULAB.COM>,
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
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Jul 06, 2017 at 09:20:24AM -0700, Paul E. McKenney wrote:
> > On Thu, Jul 06, 2017 at 06:05:55PM +0200, Peter Zijlstra wrote:
> > > On Thu, Jul 06, 2017 at 02:12:24PM +0000, David Laight wrote:
> > > > From: Paul E. McKenney
> > 
> > [ . . . ]
> > 
> > > Now on the one hand I feel like Oleg that it would be a shame to loose
> > > the optimization, OTOH this thing is really really tricky to use,
> > > and has lead to a number of bugs already.
> > 
> > I do agree, it is a bit sad to see these optimizations go.  So, should
> > this make mainline, I will be tagging the commits that spin_unlock_wait()
> > so that they can be easily reverted should someone come up with good
> > semantics and a compelling use case with compelling performance benefits.
> 
> Ha!, but what would constitute 'good semantics' ?
> 
> The current thing is something along the lines of:
> 
>   "Waits for the currently observed critical section
>    to complete with ACQUIRE ordering such that it will observe
>    whatever state was left by said critical section."
> 
> With the 'obvious' benefit of limited interference on those actually
> wanting to acquire the lock, and a shorter wait time on our side too,
> since we only need to wait for completion of the current section, and
> not for however many contender are before us.

There's another, probably just as significant advantage: queued_spin_unlock_wait() 
is 'read-only', while spin_lock()+spin_unlock() dirties the lock cache line. On 
any bigger system this should make a very measurable difference - if 
spin_unlock_wait() is ever used in a performance critical code path.

> Not sure I have an actual (micro) benchmark that shows a difference
> though.

It should be pretty obvious from pretty much any profile, the actual lock+unlock 
sequence that modifies the lock cache line is essentially a global cacheline 
bounce.

> Is this all good enough to retain the thing, I dunno. Like I said, I'm 
> conflicted on the whole thing. On the one hand its a nice optimization, on the 
> other hand I don't want to have to keep fixing these bugs.

So on one hand it's _obvious_ that spin_unlock_wait() is both faster on the local 
_and_ the remote CPUs for any sort of use case where performance matters - I don't 
even understand how that can be argued otherwise.

The real question, does any use-case (we care about) exist.

Here's a quick list of all the use cases:

 net/netfilter/nf_conntrack_core.c:

   - This is I believe the 'original', historic spin_unlock_wait() usecase that
     still exists in the kernel. spin_unlock_wait() is only used in a rare case, 
     when the netfilter hash is resized via nf_conntrack_hash_resize() - which is 
     a very heavy operation to begin with. It will no doubt get slower with the 
     proposed changes, but it probably does not matter. A networking person 
     Acked-by would be nice though.

 drivers/ata/libata-eh.c:

   - Locking of the ATA port in ata_scsi_cmd_error_handler(), presumably this can
     race with IRQs and ioctls() on other CPUs. Very likely not performance 
     sensitive in any fashion, on IO errors things stop for many seconds anyway.

 ipc/sem.c:

   - A rare race condition branch in the SysV IPC semaphore freeing code in 
     exit_sem() - where even the main code flow is not performance sensitive, 
     because typical database workloads get their semaphore arrays during startup 
     and don't ever do heavy runtime allocation/freeing of them.

 kernel/sched/completion.c:

   - completion_done(). This is actually a (comparatively) rarely used completion 
     API call - almost all the upstream usecases are in drivers, plus two in 
     filesystems - neither usecase seems in a performance critical hot path. 
     Completions typically involve scheduling and context switching, so in the 
     worst case the proposed change adds overhead to a scheduling slow path.

So I'd argue that unless there's some surprising performance aspect of a 
completion_done() user, the proposed changes should not cause any performance 
trouble.

In fact I'd argue that any future high performance spin_unlock_wait() user is 
probably better off open coding the unlock-wait poll loop (and possibly thinking 
hard about eliminating it altogether). If such patterns pop up in the kernel we 
can think about consolidating them into a single read-only primitive again.

I.e. I think the proposed changes are doing no harm, and the unavailability of a 
generic primitive does not hinder future optimizations either in any significant 
fashion.

Thanks,

	Ingo
