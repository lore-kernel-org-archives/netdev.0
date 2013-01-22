From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 37/45] mn10300: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 22 Jan 2013 13:13:16 +0530
Message-ID: <20130122074312.13822.41323.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: linux-am33-list@redhat.com
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/mn10300/kernel/smp.c   |    2 ++
 arch/mn10300/mm/cache-smp.c |    5 +++++
 arch/mn10300/mm/tlb-smp.c   |   15 +++++++++------
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/arch/mn10300/kernel/smp.c b/arch/mn10300/kernel/smp.c
index 5d7e152..9dfa172 100644
--- a/arch/mn10300/kernel/smp.c
+++ b/arch/mn10300/kernel/smp.c
@@ -349,9 +349,11 @@ void send_IPI_allbutself(int irq)
 {
 	cpumask_t cpumask;
 
+	get_online_cpus_atomic();
 	cpumask_copy(&cpumask, cpu_online_mask);
 	cpumask_clear_cpu(smp_processor_id(), &cpumask);
 	send_IPI_mask(&cpumask, irq);
+	put_online_cpus_atomic();
 }
 
 void arch_send_call_function_ipi_mask(const struct cpumask *mask)
diff --git a/arch/mn10300/mm/cache-smp.c b/arch/mn10300/mm/cache-smp.c
index 2d23b9e..47ca1c9 100644
--- a/arch/mn10300/mm/cache-smp.c
+++ b/arch/mn10300/mm/cache-smp.c
@@ -13,6 +13,7 @@
 #include <linux/mman.h>
 #include <linux/threads.h>
 #include <linux/interrupt.h>
+#include <linux/cpu.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -94,6 +95,8 @@ void smp_cache_call(unsigned long opr_mask,
 	smp_cache_mask = opr_mask;
 	smp_cache_start = start;
 	smp_cache_end = end;
+
+	get_online_cpus_atomic();
 	cpumask_copy(&smp_cache_ipi_map, cpu_online_mask);
 	cpumask_clear_cpu(smp_processor_id(), &smp_cache_ipi_map);
 
@@ -102,4 +105,6 @@ void smp_cache_call(unsigned long opr_mask,
 	while (!cpumask_empty(&smp_cache_ipi_map))
 		/* nothing. lockup detection does not belong here */
 		mb();
+
+	put_online_cpus_atomic();
 }
diff --git a/arch/mn10300/mm/tlb-smp.c b/arch/mn10300/mm/tlb-smp.c
index 3e57faf..d47304d 100644
--- a/arch/mn10300/mm/tlb-smp.c
+++ b/arch/mn10300/mm/tlb-smp.c
@@ -23,6 +23,7 @@
 #include <linux/sched.h>
 #include <linux/profile.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <asm/tlbflush.h>
 #include <asm/bitops.h>
 #include <asm/processor.h>
@@ -105,6 +106,7 @@ static void flush_tlb_others(cpumask_t cpumask, struct mm_struct *mm,
 	BUG_ON(cpumask_empty(&cpumask));
 	BUG_ON(cpumask_test_cpu(smp_processor_id(), &cpumask));
 
+	get_online_cpus_atomic();
 	cpumask_and(&tmp, &cpumask, cpu_online_mask);
 	BUG_ON(!cpumask_equal(&cpumask, &tmp));
 
@@ -134,6 +136,7 @@ static void flush_tlb_others(cpumask_t cpumask, struct mm_struct *mm,
 	flush_mm = NULL;
 	flush_va = 0;
 	spin_unlock(&tlbstate_lock);
+	put_online_cpus_atomic();
 }
 
 /**
@@ -144,7 +147,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -152,7 +155,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -163,7 +166,7 @@ void flush_tlb_current_task(void)
 	struct mm_struct *mm = current->mm;
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -171,7 +174,7 @@ void flush_tlb_current_task(void)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -184,7 +187,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	struct mm_struct *mm = vma->vm_mm;
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -192,7 +195,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, va);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
