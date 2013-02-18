From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 35/46] ia64: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Mon, 18 Feb 2013 18:13:17 +0530
Message-ID: <20130218124317.26245.67004.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/irq_ia64.c |   13 +++++++++++++
 arch/ia64/kernel/perfmon.c  |    6 ++++++
 arch/ia64/kernel/smp.c      |   23 ++++++++++++++++-------
 arch/ia64/mm/tlb.c          |    6 ++++--
 4 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 1034884..d0b4478 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -31,6 +31,7 @@
 #include <linux/ratelimit.h>
 #include <linux/acpi.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 
 #include <asm/delay.h>
 #include <asm/intrinsics.h>
@@ -190,9 +191,11 @@ static void clear_irq_vector(int irq)
 {
 	unsigned long flags;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	__clear_irq_vector(irq);
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 }
 
 int
@@ -204,6 +207,7 @@ ia64_native_assign_irq_vector (int irq)
 
 	vector = -ENOSPC;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	for_each_online_cpu(cpu) {
 		domain = vector_allocation_domain(cpu);
@@ -218,6 +222,7 @@ ia64_native_assign_irq_vector (int irq)
 	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return vector;
 }
 
@@ -302,9 +307,11 @@ int irq_prepare_move(int irq, int cpu)
 	unsigned long flags;
 	int ret;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	ret = __irq_prepare_move(irq, cpu);
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -320,11 +327,13 @@ void irq_complete_move(unsigned irq)
 	if (unlikely(cpu_isset(smp_processor_id(), cfg->old_domain)))
 		return;
 
+	get_online_cpus_atomic();
 	cpumask_and(&cleanup_mask, &cfg->old_domain, cpu_online_mask);
 	cfg->move_cleanup_count = cpus_weight(cleanup_mask);
 	for_each_cpu_mask(i, cleanup_mask)
 		platform_send_ipi(i, IA64_IRQ_MOVE_VECTOR, IA64_IPI_DM_INT, 0);
 	cfg->move_in_progress = 0;
+	put_online_cpus_atomic();
 }
 
 static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
@@ -409,6 +418,8 @@ int create_irq(void)
 	cpumask_t domain = CPU_MASK_NONE;
 
 	irq = vector = -ENOSPC;
+
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	for_each_online_cpu(cpu) {
 		domain = vector_allocation_domain(cpu);
@@ -424,6 +435,8 @@ int create_irq(void)
 	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
+
 	if (irq >= 0)
 		dynamic_irq_init(irq);
 	return irq;
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index ea39eba..6c6a029 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -34,6 +34,7 @@
 #include <linux/poll.h>
 #include <linux/vfs.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/pagemap.h>
 #include <linux/mount.h>
 #include <linux/bitops.h>
@@ -6485,6 +6486,7 @@ pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 	}
 
 	/* reserve our session */
+	get_online_cpus_atomic();
 	for_each_online_cpu(reserve_cpu) {
 		ret = pfm_reserve_session(NULL, 1, reserve_cpu);
 		if (ret) goto cleanup_reserve;
@@ -6500,6 +6502,7 @@ pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 	/* officially change to the alternate interrupt handler */
 	pfm_alt_intr_handler = hdl;
 
+	put_online_cpus_atomic();
 	spin_unlock(&pfm_alt_install_check);
 
 	return 0;
@@ -6512,6 +6515,7 @@ cleanup_reserve:
 		pfm_unreserve_session(NULL, 1, i);
 	}
 
+	put_online_cpus_atomic();
 	spin_unlock(&pfm_alt_install_check);
 
 	return ret;
@@ -6536,6 +6540,7 @@ pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 
 	pfm_alt_intr_handler = NULL;
 
+	get_online_cpus_atomic();
 	ret = on_each_cpu(pfm_alt_restore_pmu_state, NULL, 1);
 	if (ret) {
 		DPRINT(("on_each_cpu() failed: %d\n", ret));
@@ -6545,6 +6550,7 @@ pfm_remove_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 		pfm_unreserve_session(NULL, 1, i);
 	}
 
+	put_online_cpus_atomic();
 	spin_unlock(&pfm_alt_install_check);
 
 	return 0;
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 9fcd4e6..d9a4636 100644
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
@@ -154,12 +155,15 @@ send_IPI_single (int dest_cpu, int op)
 static inline void
 send_IPI_allbutself (int op)
 {
-	unsigned int i;
+	unsigned int i, cpu;
 
+	get_online_cpus_atomic();
+	cpu = smp_processor_id();
 	for_each_online_cpu(i) {
-		if (i != smp_processor_id())
+		if (i != cpu)
 			send_IPI_single(i, op);
 	}
+	put_online_cpus_atomic();
 }
 
 /*
@@ -170,9 +174,11 @@ send_IPI_mask(const struct cpumask *mask, int op)
 {
 	unsigned int cpu;
 
+	get_online_cpus_atomic();
 	for_each_cpu(cpu, mask) {
 			send_IPI_single(cpu, op);
 	}
+	put_online_cpus_atomic();
 }
 
 /*
@@ -183,9 +189,11 @@ send_IPI_all (int op)
 {
 	int i;
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(i) {
 		send_IPI_single(i, op);
 	}
+	put_online_cpus_atomic();
 }
 
 /*
@@ -259,7 +267,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 	cpumask_t cpumask = xcpumask;
 	int mycpu, cpu, flush_mycpu = 0;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	mycpu = smp_processor_id();
 
 	for_each_cpu_mask(cpu, cpumask)
@@ -280,7 +288,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 		while(counts[cpu] == (local_tlb_flush_counts[cpu].count & 0xffff))
 			udelay(FLUSH_DELAY);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void
@@ -293,12 +301,13 @@ void
 smp_flush_tlb_mm (struct mm_struct *mm)
 {
 	cpumask_var_t cpus;
-	preempt_disable();
+
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
@@ -313,7 +322,7 @@ smp_flush_tlb_mm (struct mm_struct *mm)
 	local_irq_disable();
 	local_finish_flush_tlb_mm(mm);
 	local_irq_enable();
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void arch_send_call_function_single_ipi(int cpu)
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index ed61297..8f03b58 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -20,6 +20,7 @@
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/mm.h>
 #include <linux/bootmem.h>
 #include <linux/slab.h>
@@ -87,11 +88,12 @@ wrap_mmu_context (struct mm_struct *mm)
 	 * can't call flush_tlb_all() here because of race condition
 	 * with O(1) scheduler [EF]
 	 */
-	cpu = get_cpu(); /* prevent preemption/migration */
+	get_online_cpus_atomic(); /* prevent preemption/migration */
+	cpu = smp_processor_id();
 	for_each_online_cpu(i)
 		if (i != cpu)
 			per_cpu(ia64_need_tlb_flush, i) = 1;
-	put_cpu();
+	put_online_cpus_atomic();
 	local_flush_tlb_all();
 }
 
