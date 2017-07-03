From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Mon, 3 Jul 2017 14:15:14 +0100
Message-ID: <20170703131514.GE1573@arm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-8-git-send-email-paulmck@linux.vnet.ibm.com>
 <20170630091928.GC9726@arm.com>
 <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com>
 <20170630221840.GI2393@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170630221840.GI2393@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2017 at 03:18:40PM -0700, Paul E. McKenney wrote:
> On Fri, Jun 30, 2017 at 02:13:39PM +0100, Will Deacon wrote:
> > On Fri, Jun 30, 2017 at 05:38:15AM -0700, Paul E. McKenney wrote:
> > > I also need to check all uses of spin_is_locked().  There might no
> > > longer be any that rely on any particular ordering...
> > 
> > Right. I think we're looking for the "insane case" as per 38b850a73034
> > (which was apparently used by ipc/sem.c at the time, but no longer).
> > 
> > There's a usage in kernel/debug/debug_core.c, but it doesn't fill me with
> > joy.
> 
> That is indeed an interesting one...  But my first round will be what
> semantics the implementations seem to provide:
> 
> Acquire courtesy of TSO: s390, sparc, x86.
> Acquire: ia64 (in reality fully ordered).
> Control dependency: alpha, arc, arm, blackfin, hexagon, m32r, mn10300, tile,
> 	xtensa.
> Control dependency plus leading full barrier: arm64, powerpc.
> UP-only: c6x, cris, frv, h8300, m68k, microblaze nios2, openrisc, um, unicore32.
> 
> Special cases:
> 	metag: Acquire if !CONFIG_METAG_SMP_WRITE_REORDERING.
> 	       Otherwise control dependency?
> 	mips: Control dependency, acquire if CONFIG_CPU_CAVIUM_OCTEON.
> 	parisc: Acquire courtesy of TSO, but why barrier in smp_load_acquire?
> 	sh: Acquire if one of SH4A, SH5, or J2, otherwise acquire?  UP-only?
> 
> Are these correct, or am I missing something with any of them?

That looks about right but, at least on ARM, I think we have to consider
the semantics of spin_is_locked with respect to the other spin_* functions,
rather than in isolation.

For example, ARM only has a control dependency, but spin_lock has a trailing
smp_mb() and spin_unlock has both leading and trailing smp_mb().

Will
