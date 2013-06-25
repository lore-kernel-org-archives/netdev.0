From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 36/45] ia64: smp,
 tlb: Use get/put_online_cpus_atomic() to prevent CPU offline
Date: Wed, 26 Jun 2013 02:02:25 +0530
Message-ID: <20130625203224.16593.17120.stgit@srivatsabhat.in.ibm.com>
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
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/smp.c |   12 ++++++------
 arch/ia64/mm/tlb.c     |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 9fcd4e6..25991ba 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -24,6 +24,7 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/kernel_stat.h>
 #include <linux/mm.h>
 #include <linux/cache.h>
@@ -259,8 +260,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 	cpumask_t cpumask = xcpumask;
 	int mycpu, cpu, flush_mycpu = 0;
 
-	preempt_disable();
-	mycpu = smp_processor_id();
+	mycpu = get_online_cpus_atomic();
 
 	for_each_cpu_mask(cpu, cpumask)
 		counts[cpu] = local_tlb_flush_counts[cpu].count & 0xffff;
@@ -280,7 +280,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 		while(counts[cpu] == (local_tlb_flush_counts[cpu].count & 0xffff))
 			udelay(FLUSH_DELAY);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void
@@ -293,12 +293,12 @@ void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
 	cpumask_var_t cpus;
-	preempt_disable();
+	get_online_cpus_atomic();
 	/* this happens for the common case of a single-threaded fork():  */
 	if (likely(mm == current->active_mm && atomic_read(&mm->mm_users) == 1))
 	{
 		local_finish_flush_tlb_mm(mm);
-		preempt_enable();
+		put_online_cpus_atomic();
 		return;
 	}
 	if (!alloc_cpumask_var(&cpus, GFP_ATOMIC)) {
@@ -313,7 +313,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 	local_irq_disable();
 	local_finish_flush_tlb_mm(mm);
 	local_irq_enable();
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void arch_send_call_function_single_ipi(int cpu)
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index ed61297..8c55ef5 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -87,11 +87,11 @@ wrap_mmu_context (struct mm_struct *mm)
 	 * can't call flush_tlb_all() here because of race condition
 	 * with O(1) scheduler [EF]
 	 */
-	cpu = get_cpu(); /* prevent preemption/migration */
+	cpu = get_online_cpus_atomic(); /* prevent preemption/migration */
 	for_each_online_cpu(i)
 		if (i != cpu)
 			per_cpu(ia64_need_tlb_flush, i) = 1;
-	put_cpu();
+	put_online_cpus_atomic();
 	local_flush_tlb_all();
 }
 
