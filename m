From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Wed, 5 Jul 2017 16:29:55 -0700
Message-ID: <20170705232955.GA15992@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com,
        dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org,
        arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This series therefore removes spin_unlock_wait() and changes
its users to instead use a lock/unlock pair.  The commits are as follows,
in three groups:

1-7.	Change uses of spin_unlock_wait() and raw_spin_unlock_wait()
	to instead use a spin_lock/spin_unlock pair.  These may be
	applied in any order, but must be applied before any later
	commits in this series.  The commit logs state why I believe
	that these commits won't noticeably degrade performance.

8.	Remove core-kernel definitions for spin_unlock_wait() and
	raw_spin_unlock_wait().

9.	Remove arch-specific definitions of arch_spin_unlock_wait().

Changes since v1:

o	Disable interrupts where needed, thus avoiding embarrassing
	interrupt-based self-deadlocks.

o	Substitute Manfred's patch for contrack_lock (#1 above).

o	Substitute Oleg's patch for task_work (#2 above).

o	Use more efficient barrier based on Arnd Bergmann feedback.

							Thanx, Paul

------------------------------------------------------------------------

 arch/alpha/include/asm/spinlock.h    |    5 -
 arch/arc/include/asm/spinlock.h      |    5 -
 arch/arm/include/asm/spinlock.h      |   16 ----
 arch/arm64/include/asm/spinlock.h    |   58 +----------------
 arch/blackfin/include/asm/spinlock.h |    5 -
 arch/hexagon/include/asm/spinlock.h  |    5 -
 arch/ia64/include/asm/spinlock.h     |   21 ------
 arch/m32r/include/asm/spinlock.h     |    5 -
 arch/metag/include/asm/spinlock.h    |    5 -
 arch/mips/include/asm/spinlock.h     |   16 ----
 arch/mn10300/include/asm/spinlock.h  |    5 -
 arch/parisc/include/asm/spinlock.h   |    7 --
 arch/powerpc/include/asm/spinlock.h  |   33 ---------
 arch/s390/include/asm/spinlock.h     |    7 --
 arch/sh/include/asm/spinlock-cas.h   |    5 -
 arch/sh/include/asm/spinlock-llsc.h  |    5 -
 arch/sparc/include/asm/spinlock_32.h |    5 -
 arch/sparc/include/asm/spinlock_64.h |    5 -
 arch/tile/include/asm/spinlock_32.h  |    2 
 arch/tile/include/asm/spinlock_64.h  |    2 
 arch/tile/lib/spinlock_32.c          |   23 ------
 arch/tile/lib/spinlock_64.c          |   22 ------
 arch/xtensa/include/asm/spinlock.h   |    5 -
 drivers/ata/libata-eh.c              |    8 --
 include/asm-generic/qspinlock.h      |   14 ----
 include/linux/spinlock.h             |   31 ---------
 include/linux/spinlock_up.h          |    6 -
 ipc/sem.c                            |    3 
 kernel/exit.c                        |    3 
 kernel/locking/qspinlock.c           |  117 -----------------------------------
 kernel/sched/completion.c            |    9 --
 kernel/sched/core.c                  |    5 -
 kernel/task_work.c                   |    8 --
 net/netfilter/nf_conntrack_core.c    |   44 +++++++------
 34 files changed, 43 insertions(+), 472 deletions(-)
