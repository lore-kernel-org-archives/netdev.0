From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 17/45] time/clocksource: Use get/put_online_cpus_atomic()
 to prevent CPU offline
Date: Wed, 26 Jun 2013 01:58:20 +0530
Message-ID: <20130625202820.16593.17778.stgit@srivatsabhat.in.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/time/clocksource.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/time/clocksource.c b/kernel/time/clocksource.c
index e713ef7..c4bbc25 100644
--- a/kernel/time/clocksource.c
+++ b/kernel/time/clocksource.c
@@ -30,6 +30,7 @@
 #include <linux/sched.h> /* for spin_unlock_irq() using preempt_count() m68k */
 #include <linux/tick.h>
 #include <linux/kthread.h>
+#include <linux/cpu.h>
 
 #include "tick-internal.h"
 
@@ -252,6 +253,7 @@ static void clocksource_watchdog(unsigned long data)
 	int64_t wd_nsec, cs_nsec;
 	int next_cpu, reset_pending;
 
+	get_online_cpus_atomic();
 	spin_lock(&watchdog_lock);
 	if (!watchdog_running)
 		goto out;
@@ -329,6 +331,7 @@ static void clocksource_watchdog(unsigned long data)
 	add_timer_on(&watchdog_timer, next_cpu);
 out:
 	spin_unlock(&watchdog_lock);
+	put_online_cpus_atomic();
 }
 
 static inline void clocksource_start_watchdog(void)
@@ -367,6 +370,7 @@ static void clocksource_enqueue_watchdog(struct clocksource *cs)
 {
 	unsigned long flags;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&watchdog_lock, flags);
 	if (cs->flags & CLOCK_SOURCE_MUST_VERIFY) {
 		/* cs is a clocksource to be watched. */
@@ -386,6 +390,7 @@ static void clocksource_enqueue_watchdog(struct clocksource *cs)
 	/* Check if the watchdog timer needs to be started. */
 	clocksource_start_watchdog();
 	spin_unlock_irqrestore(&watchdog_lock, flags);
+	put_online_cpus_atomic();
 }
 
 static void clocksource_dequeue_watchdog(struct clocksource *cs)
