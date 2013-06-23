From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 13/45] timer: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Sun, 23 Jun 2013 19:10:56 +0530
Message-ID: <20130623134053.19094.23654.stgit@srivatsabhat.in.ibm.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/timer.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/timer.c b/kernel/timer.c
index 15ffdb3..5db594c 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -729,6 +729,7 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
 	timer_stats_timer_set_start_info(timer);
 	BUG_ON(!timer->function);
 
+	get_online_cpus_atomic();
 	base = lock_timer_base(timer, &flags);
 
 	ret = detach_if_pending(timer, base, false);
@@ -768,6 +769,7 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
 
 out_unlock:
 	spin_unlock_irqrestore(&base->lock, flags);
+	put_online_cpus_atomic();
 
 	return ret;
 }
@@ -926,6 +928,7 @@ void add_timer_on(struct timer_list *timer, int cpu)
 
 	timer_stats_timer_set_start_info(timer);
 	BUG_ON(timer_pending(timer) || !timer->function);
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&base->lock, flags);
 	timer_set_base(timer, base);
 	debug_activate(timer, timer->expires);
@@ -940,6 +943,7 @@ void add_timer_on(struct timer_list *timer, int cpu)
 	 */
 	wake_up_nohz_cpu(cpu);
 	spin_unlock_irqrestore(&base->lock, flags);
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL_GPL(add_timer_on);
 
