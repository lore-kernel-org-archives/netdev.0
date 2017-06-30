From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Fri, 30 Jun 2017 15:18:40 -0700
Message-ID: <20170630221840.GI2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com>
 <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57840 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752810AbdF3WSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 18:18:47 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5UMEBJ1002495
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 18:18:46 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2bdtwagyff-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 18:18:46 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Fri, 30 Jun 2017 18:18:45 -0400
Content-Disposition: inline
In-Reply-To: <20170630131339.GA14118@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 30, 2017 at 02:13:39PM +0100, Will Deacon wrote:
> On Fri, Jun 30, 2017 at 05:38:15AM -0700, Paul E. McKenney wrote:
> > On Fri, Jun 30, 2017 at 10:19:29AM +0100, Will Deacon wrote:
> > > On Thu, Jun 29, 2017 at 05:01:16PM -0700, Paul E. McKenney wrote:
> > > > There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> > > > and it appears that all callers could do just as well with a lock/unlock
> > > > pair.  This commit therefore removes spin_unlock_wait() and related
> > > > definitions from core code.
> > > > 
> > > > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > > Cc: Ingo Molnar <mingo@redhat.com>
> > > > Cc: Will Deacon <will.deacon@arm.com>
> > > > Cc: Peter Zijlstra <peterz@infradead.org>
> > > > Cc: Alan Stern <stern@rowland.harvard.edu>
> > > > Cc: Andrea Parri <parri.andrea@gmail.com>
> > > > Cc: Linus Torvalds <torvalds@linux-foundation.org>
> > > > ---
> > > >  include/asm-generic/qspinlock.h |  14 -----
> > > >  include/linux/spinlock.h        |  31 -----------
> > > >  include/linux/spinlock_up.h     |   6 ---
> > > >  kernel/locking/qspinlock.c      | 117 ----------------------------------------
> > > >  4 files changed, 168 deletions(-)
> > > 
> > > [...]
> > > 
> > > > diff --git a/kernel/locking/qspinlock.c b/kernel/locking/qspinlock.c
> > > > index b2caec7315af..64a9051e4c2c 100644
> > > > --- a/kernel/locking/qspinlock.c
> > > > +++ b/kernel/locking/qspinlock.c
> > > > @@ -267,123 +267,6 @@ static __always_inline u32  __pv_wait_head_or_lock(struct qspinlock *lock,
> > > >  #define queued_spin_lock_slowpath	native_queued_spin_lock_slowpath
> > > >  #endif
> > > >  
> > > > -/*
> > > > - * Various notes on spin_is_locked() and spin_unlock_wait(), which are
> > > > - * 'interesting' functions:
> > > > - *
> > > > - * PROBLEM: some architectures have an interesting issue with atomic ACQUIRE
> > > > - * operations in that the ACQUIRE applies to the LOAD _not_ the STORE (ARM64,
> > > > - * PPC). Also qspinlock has a similar issue per construction, the setting of
> > > > - * the locked byte can be unordered acquiring the lock proper.
> > > > - *
> > > > - * This gets to be 'interesting' in the following cases, where the /should/s
> > > > - * end up false because of this issue.
> > > > - *
> > > > - *
> > > > - * CASE 1:
> > > > - *
> > > > - * So the spin_is_locked() correctness issue comes from something like:
> > > > - *
> > > > - *   CPU0				CPU1
> > > > - *
> > > > - *   global_lock();			local_lock(i)
> > > > - *     spin_lock(&G)			  spin_lock(&L[i])
> > > > - *     for (i)				  if (!spin_is_locked(&G)) {
> > > > - *       spin_unlock_wait(&L[i]);	    smp_acquire__after_ctrl_dep();
> > > > - *					    return;
> > > > - *					  }
> > > > - *					  // deal with fail
> > > > - *
> > > > - * Where it is important CPU1 sees G locked or CPU0 sees L[i] locked such
> > > > - * that there is exclusion between the two critical sections.
> > > > - *
> > > > - * The load from spin_is_locked(&G) /should/ be constrained by the ACQUIRE from
> > > > - * spin_lock(&L[i]), and similarly the load(s) from spin_unlock_wait(&L[i])
> > > > - * /should/ be constrained by the ACQUIRE from spin_lock(&G).
> > > > - *
> > > > - * Similarly, later stuff is constrained by the ACQUIRE from CTRL+RMB.
> > > 
> > > Might be worth keeping this comment about spin_is_locked, since we're not
> > > removing that guy just yet!
> > 
> > Ah, all the examples had spin_unlock_wait() in them.  So what I need to
> > do is to create a spin_unlock_wait()-free example to illustrate the
> > text starting with "The load from spin_is_locked(", correct?
> 
> Yeah, I think so.
> 
> > I also need to check all uses of spin_is_locked().  There might no
> > longer be any that rely on any particular ordering...
> 
> Right. I think we're looking for the "insane case" as per 38b850a73034
> (which was apparently used by ipc/sem.c at the time, but no longer).
> 
> There's a usage in kernel/debug/debug_core.c, but it doesn't fill me with
> joy.

That is indeed an interesting one...  But my first round will be what
semantics the implementations seem to provide:

Acquire courtesy of TSO: s390, sparc, x86.
Acquire: ia64 (in reality fully ordered).
Control dependency: alpha, arc, arm, blackfin, hexagon, m32r, mn10300, tile,
	xtensa.
Control dependency plus leading full barrier: arm64, powerpc.
UP-only: c6x, cris, frv, h8300, m68k, microblaze nios2, openrisc, um, unicore32.

Special cases:
	metag: Acquire if !CONFIG_METAG_SMP_WRITE_REORDERING.
	       Otherwise control dependency?
	mips: Control dependency, acquire if CONFIG_CPU_CAVIUM_OCTEON.
	parisc: Acquire courtesy of TSO, but why barrier in smp_load_acquire?
	sh: Acquire if one of SH4A, SH5, or J2, otherwise acquire?  UP-only?

Are these correct, or am I missing something with any of them?

							Thanx, Paul
