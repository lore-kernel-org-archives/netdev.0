From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 37/46] MIPS: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Mon, 18 Feb 2013 18:13:28 +0530
Message-ID: <20130218124328.26245.69487.stgit@srivatsabhat.in.ibm.com>
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
depend on preempt_disable() or local_irq_disable() to prevent CPUs fom
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: David Daney <david.daney@cavium.com>
Cc: linux-mips@linux-mips.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/mips/kernel/cevt-smtc.c |    8 ++++++++
 arch/mips/kernel/smp.c       |   16 ++++++++--------
 arch/mips/kernel/smtc.c      |    3 +++
 arch/mips/mm/c-octeon.c      |    4 ++--
 4 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/arch/mips/kernel/cevt-smtc.c b/arch/mips/kernel/cevt-smtc.c
index 2e72d30..6fb311b 100644
--- a/arch/mips/kernel/cevt-smtc.c
+++ b/arch/mips/kernel/cevt-smtc.c
@@ -11,6 +11,7 @@
 #include <linux/interrupt.h>
 #include <linux/percpu.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/irq.h>
 
 #include <asm/smtc_ipi.h>
@@ -84,6 +85,8 @@ static int mips_next_event(unsigned long delta,
 	unsigned long nextcomp = 0L;
 	int vpe = current_cpu_data.vpe_id;
 	int cpu = smp_processor_id();
+
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	mtflags = dmt();
 
@@ -164,6 +167,7 @@ static int mips_next_event(unsigned long delta,
 	}
 	emt(mtflags);
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 	return 0;
 }
 
@@ -180,6 +184,7 @@ void smtc_distribute_timer(int vpe)
 
 repeat:
 	nextstamp = 0L;
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 	    /*
 	     * Find virtual CPUs within the current VPE who have
@@ -221,6 +226,9 @@ repeat:
 
 	    }
 	}
+
+	put_online_cpus_atomic()
+
 	/* Reprogram for interrupt at next soonest timestamp for VPE */
 	if (ISVALID(nextstamp)) {
 		write_c0_compare(nextstamp);
diff --git a/arch/mips/kernel/smp.c b/arch/mips/kernel/smp.c
index 66bf4e2..3828afa 100644
--- a/arch/mips/kernel/smp.c
+++ b/arch/mips/kernel/smp.c
@@ -248,12 +248,12 @@ static inline void smp_on_other_tlbs(void (*func) (void *info), void *info)
 
 static inline void smp_on_each_tlb(void (*func) (void *info), void *info)
 {
-	preempt_disable();
+	get_online_cpus_atomic();
 
 	smp_on_other_tlbs(func, info);
 	func(info);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /*
@@ -271,7 +271,7 @@ static inline void smp_on_each_tlb(void (*func) (void *info), void *info)
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
-	preempt_disable();
+	get_online_cpus_atomic();
 
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		smp_on_other_tlbs(flush_tlb_mm_ipi, mm);
@@ -285,7 +285,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	}
 	local_flush_tlb_mm(mm);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 struct flush_tlb_data {
@@ -305,7 +305,7 @@ void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned l
 {
 	struct mm_struct *mm = vma->vm_mm;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	if ((atomic_read(&mm->mm_users) != 1) || (current->mm != mm)) {
 		struct flush_tlb_data fd = {
 			.vma = vma,
@@ -323,7 +323,7 @@ void flush_tlb_range(struct vm_area_struct *vma, unsigned long start, unsigned l
 		}
 	}
 	local_flush_tlb_range(vma, start, end);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 static void flush_tlb_kernel_range_ipi(void *info)
@@ -352,7 +352,7 @@ static void flush_tlb_page_ipi(void *info)
 
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long page)
 {
-	preempt_disable();
+	get_online_cpus_atomic();
 	if ((atomic_read(&vma->vm_mm->mm_users) != 1) || (current->mm != vma->vm_mm)) {
 		struct flush_tlb_data fd = {
 			.vma = vma,
@@ -369,7 +369,7 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long page)
 		}
 	}
 	local_flush_tlb_page(vma, page);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 static void flush_tlb_one_ipi(void *info)
diff --git a/arch/mips/kernel/smtc.c b/arch/mips/kernel/smtc.c
index 1d47843..caf081e 100644
--- a/arch/mips/kernel/smtc.c
+++ b/arch/mips/kernel/smtc.c
@@ -22,6 +22,7 @@
 #include <linux/sched.h>
 #include <linux/smp.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/interrupt.h>
 #include <linux/kernel_stat.h>
 #include <linux/module.h>
@@ -1143,6 +1144,7 @@ static irqreturn_t ipi_interrupt(int irq, void *dev_idm)
 	 * for the current TC, so we ought not to have to do it explicitly here.
 	 */
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (cpu_data[cpu].vpe_id != my_vpe)
 			continue;
@@ -1179,6 +1181,7 @@ static irqreturn_t ipi_interrupt(int irq, void *dev_idm)
 			}
 		}
 	}
+	put_online_cpus_atomic();
 
 	return IRQ_HANDLED;
 }
diff --git a/arch/mips/mm/c-octeon.c b/arch/mips/mm/c-octeon.c
index 6ec04da..cd2c1ce 100644
--- a/arch/mips/mm/c-octeon.c
+++ b/arch/mips/mm/c-octeon.c
@@ -73,7 +73,7 @@ static void octeon_flush_icache_all_cores(struct vm_area_struct *vma)
 	mb();
 	octeon_local_flush_icache();
 #ifdef CONFIG_SMP
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpu = smp_processor_id();
 
 	/*
@@ -88,7 +88,7 @@ static void octeon_flush_icache_all_cores(struct vm_area_struct *vma)
 	for_each_cpu(cpu, &mask)
 		octeon_send_ipi_single(cpu, SMP_ICACHE_FLUSH);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 #endif
 }
 
