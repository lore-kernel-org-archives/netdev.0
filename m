From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 29/45] x86/xen: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 22 Jan 2013 13:10:51 +0530
Message-ID: <20130122074046.13822.61950.stgit@srivatsabhat.in.ibm.com>
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

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: xen-devel@lists.xensource.com
Cc: virtualization@lists.linux-foundation.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/xen/mmu.c |   11 +++++++++--
 arch/x86/xen/smp.c |    9 +++++++++
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 01de35c..6a95a15 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -39,6 +39,7 @@
  * Jeremy Fitzhardinge <jeremy@xensource.com>, XenSource Inc, 2007
  */
 #include <linux/sched.h>
+#include <linux/cpu.h>
 #include <linux/highmem.h>
 #include <linux/debugfs.h>
 #include <linux/bug.h>
@@ -1163,9 +1164,13 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
  */
 static void xen_exit_mmap(struct mm_struct *mm)
 {
-	get_cpu();		/* make sure we don't move around */
+	/*
+	 * Make sure we don't move around, and prevent CPUs from going
+	 * offline.
+	 */
+	get_online_cpus_atomic();
 	xen_drop_mm_ref(mm);
-	put_cpu();
+	put_online_cpus_atomic();
 
 	spin_lock(&mm->page_table_lock);
 
@@ -1371,6 +1376,7 @@ static void xen_flush_tlb_others(const struct cpumask *cpus,
 	args->op.arg2.vcpumask = to_cpumask(args->mask);
 
 	/* Remove us, and any offline CPUS. */
+	get_online_cpus_atomic();
 	cpumask_and(to_cpumask(args->mask), cpus, cpu_online_mask);
 	cpumask_clear_cpu(smp_processor_id(), to_cpumask(args->mask));
 
@@ -1383,6 +1389,7 @@ static void xen_flush_tlb_others(const struct cpumask *cpus,
 	MULTI_mmuext_op(mcs.mc, &args->op, 1, NULL, DOMID_SELF);
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
+	put_online_cpus_atomic();
 }
 
 static unsigned long xen_read_cr3(void)
diff --git a/arch/x86/xen/smp.c b/arch/x86/xen/smp.c
index 4f7d259..7d753ae 100644
--- a/arch/x86/xen/smp.c
+++ b/arch/x86/xen/smp.c
@@ -16,6 +16,7 @@
 #include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/irq_work.h>
 
 #include <asm/paravirt.h>
@@ -487,8 +488,10 @@ static void __xen_send_IPI_mask(const struct cpumask *mask,
 {
 	unsigned cpu;
 
+	get_online_cpus_atomic();
 	for_each_cpu_and(cpu, mask, cpu_online_mask)
 		xen_send_IPI_one(cpu, vector);
+	put_online_cpus_atomic();
 }
 
 static void xen_smp_send_call_function_ipi(const struct cpumask *mask)
@@ -551,8 +554,10 @@ void xen_send_IPI_all(int vector)
 {
 	int xen_vector = xen_map_vector(vector);
 
+	get_online_cpus_atomic();
 	if (xen_vector >= 0)
 		__xen_send_IPI_mask(cpu_online_mask, xen_vector);
+	put_online_cpus_atomic();
 }
 
 void xen_send_IPI_self(int vector)
@@ -572,20 +577,24 @@ void xen_send_IPI_mask_allbutself(const struct cpumask *mask,
 	if (!(num_online_cpus() > 1))
 		return;
 
+	get_online_cpus_atomic();
 	for_each_cpu_and(cpu, mask, cpu_online_mask) {
 		if (this_cpu == cpu)
 			continue;
 
 		xen_smp_send_call_function_single_ipi(cpu);
 	}
+	put_online_cpus_atomic();
 }
 
 void xen_send_IPI_allbutself(int vector)
 {
 	int xen_vector = xen_map_vector(vector);
 
+	get_online_cpus_atomic();
 	if (xen_vector >= 0)
 		xen_send_IPI_mask_allbutself(cpu_online_mask, xen_vector);
+	put_online_cpus_atomic();
 }
 
 static irqreturn_t xen_call_function_interrupt(int irq, void *dev_id)
