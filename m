From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: suspicious RCU usage warnings in 3.3.0
Date: Fri, 13 Apr 2012 06:35:13 -0700
Message-ID: <20120413133513.GB2457@linux.vnet.ibm.com>
References: <20120411171004.016ddd95@nehalam.linuxnetplumber.net>
 <20120411.201854.1070083308359208025.davem@davemloft.net>
 <20120412004507.GF2473@linux.vnet.ibm.com>
 <20120411.210843.716144028821174908.davem@davemloft.net>
 <20120412045428.GB2497@linux.vnet.ibm.com>
 <alpine.SOC.1.00.1204131444150.2736@math.ut.ee>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.SOC.1.00.1204131444150.2736@math.ut.ee>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 13, 2012 at 02:55:12PM +0300, mroos@linux.ee wrote:
> > sparc64: Eliminate obsolete __handle_softirq() function
> > 
> > The invocation of softirq is now handled by irq_exit(), so there is no
> > need for sparc64 to invoke it on the trap-return path.  In fact, doing so
> > is a bug because if the trap occurred in the idle loop, this invocation
> > can result in lockdep-RCU failures.  The problem is that RCU ignores idle
> > CPUs, and the sparc64 trap-return path to the softirq handlers fails to
> > tell RCU that the CPU must be considered non-idle while those handlers
> > are executing.  This means that RCU is ignoring any RCU read-side critical
> > sections in those handlers, which in turn means that RCU-protected data
> > can be yanked out from under those read-side critical sections.
> > 
> > The shiny new lockdep-RCU ability to detect RCU read-side critical sections
> > that RCU is ignoring located this problem.
> > 
> > The fix is straightforward: Make sparc64 stop manually invoking the
> > softirq handlers.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> It works for me on Sun Fire V100 - no more RCU warnings under ping 
> flood.
> 
> Tested-by: Meelis Roos <mroos@linux.ee>

OK, if this thing is going to actually work, I guess I need to update
the changelog to give credit where it is due, please see below.

My main concern about my patch is my removal of this line:

	bne,pn			%icc, __handle_softirq

It is quite possible that this should instead change to look as follows:

	bne,pn			%icc, __handle_preemption

This code is under #ifndef CONFIG_SMP, so Meelis's testing would not
reach it.

Anyway, patch with updated changelog below.

							Thanx, Paul

------------------------------------------------------------------------

sparc64: Eliminate obsolete __handle_softirq() function

The invocation of softirq is now handled by irq_exit(), so there is no
need for sparc64 to invoke it on the trap-return path.  In fact, doing so
is a bug because if the trap occurred in the idle loop, this invocation
can result in lockdep-RCU failures.  The problem is that RCU ignores idle
CPUs, and the sparc64 trap-return path to the softirq handlers fails to
tell RCU that the CPU must be considered non-idle while those handlers
are executing.  This means that RCU is ignoring any RCU read-side critical
sections in those handlers, which in turn means that RCU-protected data
can be yanked out from under those read-side critical sections.

The shiny new lockdep-RCU ability to detect RCU read-side critical sections
that RCU is ignoring located this problem.

The fix is straightforward: Make sparc64 stop manually invoking the
softirq handlers.

Reported-by: Meelis Roos <mroos@linux.ee>
Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Tested-by: Meelis Roos <mroos@linux.ee>

diff --git a/arch/sparc/kernel/rtrap_64.S b/arch/sparc/kernel/rtrap_64.S
index 77f1b95..9171fc2 100644
--- a/arch/sparc/kernel/rtrap_64.S
+++ b/arch/sparc/kernel/rtrap_64.S
@@ -20,11 +20,6 @@
 
 		.text
 		.align			32
-__handle_softirq:
-		call			do_softirq
-		 nop
-		ba,a,pt			%xcc, __handle_softirq_continue
-		 nop
 __handle_preemption:
 		call			schedule
 		 wrpr			%g0, RTRAP_PSTATE, %pstate
@@ -89,9 +84,7 @@ rtrap:
 		cmp			%l1, 0
 
 		/* mm/ultra.S:xcall_report_regs KNOWS about this load. */
-		bne,pn			%icc, __handle_softirq
 		 ldx			[%sp + PTREGS_OFF + PT_V9_TSTATE], %l1
-__handle_softirq_continue:
 rtrap_xcall:
 		sethi			%hi(0xf << 20), %l4
 		and			%l1, %l4, %l4
