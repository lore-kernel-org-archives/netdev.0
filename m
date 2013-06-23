From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 39/45] mn10300: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Sun, 23 Jun 2013 19:16:45 +0530
Message-ID: <20130623134641.19094.47358.stgit@srivatsabhat.in.ibm.com>
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
	David Howells <dhowells@redhat.com>,
	Koichi Yasutake <yasutake.koichi@jp.panasonic.com>,
	linux-am33-list@redhat.com
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: David Howells <dhowells@redhat.com>
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com>
Cc: linux-am33-list@redhat.com
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/mn10300/mm/cache-smp.c |    3 +++
 arch/mn10300/mm/tlb-smp.c   |   17 +++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/arch/mn10300/mm/cache-smp.c b/arch/mn10300/mm/cache-smp.c
index 2d23b9e..406357d 100644
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
@@ -91,6 +92,7 @@ void smp_cache_interrupt(void)
 void smp_cache_call(unsigned long opr_mask,
 		    unsigned long start, unsigned long end)
 {
+	get_online_cpus_atomic();
 	smp_cache_mask = opr_mask;
 	smp_cache_start = start;
 	smp_cache_end = end;
@@ -102,4 +104,5 @@ void smp_cache_call(unsigned long opr_mask,
 	while (!cpumask_empty(&smp_cache_ipi_map))
 		/* nothing. lockup detection does not belong here */
 		mb();
+	put_online_cpus_atomic();
 }
diff --git a/arch/mn10300/mm/tlb-smp.c b/arch/mn10300/mm/tlb-smp.c
index 3e57faf..8856fd3 100644
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
@@ -61,7 +62,7 @@ void smp_flush_tlb(void *unused)
 {
 	unsigned long cpu_id;
 
-	cpu_id = get_cpu();
+	cpu_id = get_online_cpus_atomic();
 
 	if (!cpumask_test_cpu(cpu_id, &flush_cpumask))
 		/* This was a BUG() but until someone can quote me the line
@@ -82,7 +83,7 @@ void smp_flush_tlb(void *unused)
 	cpumask_clear_cpu(cpu_id, &flush_cpumask);
 	smp_mb__after_clear_bit();
 out:
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -144,7 +145,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 {
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -152,7 +153,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -163,7 +164,7 @@ void flush_tlb_current_task(void)
 	struct mm_struct *mm = current->mm;
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -171,7 +172,7 @@ void flush_tlb_current_task(void)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, FLUSH_ALL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
@@ -184,7 +185,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	struct mm_struct *mm = vma->vm_mm;
 	cpumask_t cpu_mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -192,7 +193,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, va);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /**
