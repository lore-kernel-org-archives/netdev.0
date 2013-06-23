From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 26/45] x86: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Sun, 23 Jun 2013 19:13:43 +0530
Message-ID: <20130623134340.19094.55514.stgit@srivatsabhat.in.ibm.com>
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
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Tony Luck <tony.luck@intel.com>,
	Borislav Petkov <bp@alien8.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	Joerg Roedel <joro@8bytes.org>,
	Jan Beulich <jbeulich@suse.com>,
	Joonsoo Kim <js1304@gmail.com>, linux-edac@vger.kernel.org
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
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Jan Beulich <jbeulich@suse.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: linux-edac@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/kernel/apic/io_apic.c           |   21 ++++++++++++++++++---
 arch/x86/kernel/cpu/mcheck/therm_throt.c |    4 ++--
 arch/x86/mm/tlb.c                        |   14 +++++++-------
 3 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 9ed796c..4c71c1e 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -25,6 +25,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 #include <linux/pci.h>
 #include <linux/mc146818rtc.h>
 #include <linux/compiler.h>
@@ -1169,9 +1170,11 @@ int assign_irq_vector(int irq, struct irq_cfg *cfg, const struct cpumask *mask)
 	int err;
 	unsigned long flags;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&vector_lock, flags);
 	err = __assign_irq_vector(irq, cfg, mask);
 	raw_spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return err;
 }
 
@@ -1757,13 +1760,13 @@ __apicdebuginit(void) print_local_APICs(int maxcpu)
 	if (!maxcpu)
 		return;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (cpu >= maxcpu)
 			break;
 		smp_call_function_single(cpu, print_local_APIC, NULL, 1);
 	}
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 __apicdebuginit(void) print_PIC(void)
@@ -2153,10 +2156,12 @@ static int ioapic_retrigger_irq(struct irq_data *data)
 	unsigned long flags;
 	int cpu;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&vector_lock, flags);
 	cpu = cpumask_first_and(cfg->domain, cpu_online_mask);
 	apic->send_IPI_mask(cpumask_of(cpu), cfg->vector);
 	raw_spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 
 	return 1;
 }
@@ -2175,6 +2180,7 @@ void send_cleanup_vector(struct irq_cfg *cfg)
 {
 	cpumask_var_t cleanup_mask;
 
+	get_online_cpus_atomic();
 	if (unlikely(!alloc_cpumask_var(&cleanup_mask, GFP_ATOMIC))) {
 		unsigned int i;
 		for_each_cpu_and(i, cfg->old_domain, cpu_online_mask)
@@ -2185,6 +2191,7 @@ void send_cleanup_vector(struct irq_cfg *cfg)
 		free_cpumask_var(cleanup_mask);
 	}
 	cfg->move_in_progress = 0;
+	put_online_cpus_atomic();
 }
 
 asmlinkage void smp_irq_move_cleanup_interrupt(void)
@@ -2939,11 +2946,13 @@ unsigned int __create_irqs(unsigned int from, unsigned int count, int node)
 			goto out_irqs;
 	}
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&vector_lock, flags);
 	for (i = 0; i < count; i++)
 		if (__assign_irq_vector(irq + i, cfg[i], apic->target_cpus()))
 			goto out_vecs;
 	raw_spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 
 	for (i = 0; i < count; i++) {
 		irq_set_chip_data(irq + i, cfg[i]);
@@ -2957,6 +2966,7 @@ out_vecs:
 	for (i--; i >= 0; i--)
 		__clear_irq_vector(irq + i, cfg[i]);
 	raw_spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 out_irqs:
 	for (i = 0; i < count; i++)
 		free_irq_at(irq + i, cfg[i]);
@@ -2994,9 +3004,11 @@ void destroy_irq(unsigned int irq)
 
 	free_remapped_irq(irq);
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&vector_lock, flags);
 	__clear_irq_vector(irq, cfg);
 	raw_spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	free_irq_at(irq, cfg);
 }
 
@@ -3365,8 +3377,11 @@ io_apic_setup_irq_pin(unsigned int irq, int node, struct io_apic_irq_attr *attr)
 	if (!cfg)
 		return -EINVAL;
 	ret = __add_pin_to_irq_node(cfg, node, attr->ioapic, attr->ioapic_pin);
-	if (!ret)
+	if (!ret) {
+		get_online_cpus_atomic();
 		setup_ioapic_irq(irq, cfg, attr);
+		put_online_cpus_atomic();
+	}
 	return ret;
 }
 
diff --git a/arch/x86/kernel/cpu/mcheck/therm_throt.c b/arch/x86/kernel/cpu/mcheck/therm_throt.c
index 47a1870..d128ba4 100644
--- a/arch/x86/kernel/cpu/mcheck/therm_throt.c
+++ b/arch/x86/kernel/cpu/mcheck/therm_throt.c
@@ -82,13 +82,13 @@ static ssize_t therm_throt_device_show_##event##_##name(		\
 	unsigned int cpu = dev->id;					\
 	ssize_t ret;							\
 									\
-	preempt_disable();	/* CPU hotplug */			\
+	get_online_cpus_atomic();	/* CPU hotplug */		\
 	if (cpu_online(cpu)) {						\
 		ret = sprintf(buf, "%lu\n",				\
 			      per_cpu(thermal_state, cpu).event.name);	\
 	} else								\
 		ret = 0;						\
-	preempt_enable();						\
+	put_online_cpus_atomic();					\
 									\
 	return ret;							\
 }
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 282375f..8126374 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -147,12 +147,12 @@ void flush_tlb_current_task(void)
 {
 	struct mm_struct *mm = current->mm;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 
 	local_flush_tlb();
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /*
@@ -187,7 +187,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 	unsigned long addr;
 	unsigned act_entries, tlb_entries = 0;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	if (current->active_mm != mm)
 		goto flush_all;
 
@@ -225,21 +225,21 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		if (cpumask_any_but(mm_cpumask(mm),
 				smp_processor_id()) < nr_cpu_ids)
 			flush_tlb_others(mm_cpumask(mm), mm, start, end);
-		preempt_enable();
+		put_online_cpus_atomic();
 		return;
 	}
 
 flush_all:
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 
 	if (current->active_mm == mm) {
 		if (current->mm)
@@ -251,7 +251,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long start)
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, start, 0UL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 static void do_flush_tlb_all(void *info)
