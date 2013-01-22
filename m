From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 25/45] x86: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Tue, 22 Jan 2013 13:09:40 +0530
Message-ID: <20130122073936.13822.32560.stgit@srivatsabhat.in.ibm.com>
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

Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Daniel J Blueman <daniel@numascale-asia.com>
Cc: Steffen Persvold <sp@numascale.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>
Cc: linux-edac@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/include/asm/ipi.h               |    5 +++++
 arch/x86/kernel/apic/apic_flat_64.c      |   10 ++++++++++
 arch/x86/kernel/apic/apic_numachip.c     |    5 +++++
 arch/x86/kernel/apic/es7000_32.c         |    5 +++++
 arch/x86/kernel/apic/io_apic.c           |    7 +++++--
 arch/x86/kernel/apic/ipi.c               |   10 ++++++++++
 arch/x86/kernel/apic/x2apic_cluster.c    |    4 ++++
 arch/x86/kernel/apic/x2apic_uv_x.c       |    4 ++++
 arch/x86/kernel/cpu/mcheck/therm_throt.c |    4 ++--
 arch/x86/mm/tlb.c                        |   14 +++++++-------
 10 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/ipi.h b/arch/x86/include/asm/ipi.h
index 615fa90..112249c 100644
--- a/arch/x86/include/asm/ipi.h
+++ b/arch/x86/include/asm/ipi.h
@@ -20,6 +20,7 @@
  * Subject to the GNU Public License, v.2
  */
 
+#include <linux/cpu.h>
 #include <asm/hw_irq.h>
 #include <asm/apic.h>
 #include <asm/smp.h>
@@ -131,18 +132,22 @@ extern int no_broadcast;
 
 static inline void __default_local_send_IPI_allbutself(int vector)
 {
+	get_online_cpus_atomic();
 	if (no_broadcast || vector == NMI_VECTOR)
 		apic->send_IPI_mask_allbutself(cpu_online_mask, vector);
 	else
 		__default_send_IPI_shortcut(APIC_DEST_ALLBUT, vector, apic->dest_logical);
+	put_online_cpus_atomic();
 }
 
 static inline void __default_local_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	if (no_broadcast || vector == NMI_VECTOR)
 		apic->send_IPI_mask(cpu_online_mask, vector);
 	else
 		__default_send_IPI_shortcut(APIC_DEST_ALLINC, vector, apic->dest_logical);
+	put_online_cpus_atomic();
 }
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/apic/apic_flat_64.c b/arch/x86/kernel/apic/apic_flat_64.c
index 00c77cf..8207ade 100644
--- a/arch/x86/kernel/apic/apic_flat_64.c
+++ b/arch/x86/kernel/apic/apic_flat_64.c
@@ -11,6 +11,7 @@
 #include <linux/errno.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/ctype.h>
@@ -92,6 +93,8 @@ static void flat_send_IPI_allbutself(int vector)
 #else
 	int hotplug = 0;
 #endif
+
+	get_online_cpus_atomic();
 	if (hotplug || vector == NMI_VECTOR) {
 		if (!cpumask_equal(cpu_online_mask, cpumask_of(cpu))) {
 			unsigned long mask = cpumask_bits(cpu_online_mask)[0];
@@ -105,16 +108,19 @@ static void flat_send_IPI_allbutself(int vector)
 		__default_send_IPI_shortcut(APIC_DEST_ALLBUT,
 					    vector, apic->dest_logical);
 	}
+	put_online_cpus_atomic();
 }
 
 static void flat_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	if (vector == NMI_VECTOR) {
 		flat_send_IPI_mask(cpu_online_mask, vector);
 	} else {
 		__default_send_IPI_shortcut(APIC_DEST_ALLINC,
 					    vector, apic->dest_logical);
 	}
+	put_online_cpus_atomic();
 }
 
 static unsigned int flat_get_apic_id(unsigned long x)
@@ -255,12 +261,16 @@ static void physflat_send_IPI_mask_allbutself(const struct cpumask *cpumask,
 
 static void physflat_send_IPI_allbutself(int vector)
 {
+	get_online_cpus_atomic();
 	default_send_IPI_mask_allbutself_phys(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static void physflat_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	physflat_send_IPI_mask(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static int physflat_probe(void)
diff --git a/arch/x86/kernel/apic/apic_numachip.c b/arch/x86/kernel/apic/apic_numachip.c
index 9c2aa89..7d19c1d 100644
--- a/arch/x86/kernel/apic/apic_numachip.c
+++ b/arch/x86/kernel/apic/apic_numachip.c
@@ -14,6 +14,7 @@
 #include <linux/errno.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -131,15 +132,19 @@ static void numachip_send_IPI_allbutself(int vector)
 	unsigned int this_cpu = smp_processor_id();
 	unsigned int cpu;
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (cpu != this_cpu)
 			numachip_send_IPI_one(cpu, vector);
 	}
+	put_online_cpus_atomic();
 }
 
 static void numachip_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	numachip_send_IPI_mask(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static void numachip_send_IPI_self(int vector)
diff --git a/arch/x86/kernel/apic/es7000_32.c b/arch/x86/kernel/apic/es7000_32.c
index 0874799..ddf2995 100644
--- a/arch/x86/kernel/apic/es7000_32.c
+++ b/arch/x86/kernel/apic/es7000_32.c
@@ -45,6 +45,7 @@
 #include <linux/gfp.h>
 #include <linux/nmi.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/io.h>
 
 #include <asm/apicdef.h>
@@ -412,12 +413,16 @@ static void es7000_send_IPI_mask(const struct cpumask *mask, int vector)
 
 static void es7000_send_IPI_allbutself(int vector)
 {
+	get_online_cpus_atomic();
 	default_send_IPI_mask_allbutself_phys(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static void es7000_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	es7000_send_IPI_mask(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static int es7000_apic_id_registered(void)
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index b739d39..ca1c2a5 100644
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
@@ -1788,13 +1789,13 @@ __apicdebuginit(void) print_local_APICs(int maxcpu)
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
@@ -2209,6 +2210,7 @@ void send_cleanup_vector(struct irq_cfg *cfg)
 {
 	cpumask_var_t cleanup_mask;
 
+	get_online_cpus_atomic();
 	if (unlikely(!alloc_cpumask_var(&cleanup_mask, GFP_ATOMIC))) {
 		unsigned int i;
 		for_each_cpu_and(i, cfg->old_domain, cpu_online_mask)
@@ -2219,6 +2221,7 @@ void send_cleanup_vector(struct irq_cfg *cfg)
 		free_cpumask_var(cleanup_mask);
 	}
 	cfg->move_in_progress = 0;
+	put_online_cpus_atomic();
 }
 
 asmlinkage void smp_irq_move_cleanup_interrupt(void)
diff --git a/arch/x86/kernel/apic/ipi.c b/arch/x86/kernel/apic/ipi.c
index cce91bf..c65aa77 100644
--- a/arch/x86/kernel/apic/ipi.c
+++ b/arch/x86/kernel/apic/ipi.c
@@ -29,12 +29,14 @@ void default_send_IPI_mask_sequence_phys(const struct cpumask *mask, int vector)
 	 * to an arbitrary mask, so I do a unicast to each CPU instead.
 	 * - mbligh
 	 */
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	for_each_cpu(query_cpu, mask) {
 		__default_send_IPI_dest_field(per_cpu(x86_cpu_to_apicid,
 				query_cpu), vector, APIC_DEST_PHYSICAL);
 	}
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 }
 
 void default_send_IPI_mask_allbutself_phys(const struct cpumask *mask,
@@ -46,6 +48,7 @@ void default_send_IPI_mask_allbutself_phys(const struct cpumask *mask,
 
 	/* See Hack comment above */
 
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	for_each_cpu(query_cpu, mask) {
 		if (query_cpu == this_cpu)
@@ -54,6 +57,7 @@ void default_send_IPI_mask_allbutself_phys(const struct cpumask *mask,
 				 query_cpu), vector, APIC_DEST_PHYSICAL);
 	}
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 }
 
 #ifdef CONFIG_X86_32
@@ -70,12 +74,14 @@ void default_send_IPI_mask_sequence_logical(const struct cpumask *mask,
 	 * should be modified to do 1 message per cluster ID - mbligh
 	 */
 
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	for_each_cpu(query_cpu, mask)
 		__default_send_IPI_dest_field(
 			early_per_cpu(x86_cpu_to_logical_apicid, query_cpu),
 			vector, apic->dest_logical);
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 }
 
 void default_send_IPI_mask_allbutself_logical(const struct cpumask *mask,
@@ -87,6 +93,7 @@ void default_send_IPI_mask_allbutself_logical(const struct cpumask *mask,
 
 	/* See Hack comment above */
 
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	for_each_cpu(query_cpu, mask) {
 		if (query_cpu == this_cpu)
@@ -96,6 +103,7 @@ void default_send_IPI_mask_allbutself_logical(const struct cpumask *mask,
 			vector, apic->dest_logical);
 		}
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 }
 
 /*
@@ -109,10 +117,12 @@ void default_send_IPI_mask_logical(const struct cpumask *cpumask, int vector)
 	if (WARN_ONCE(!mask, "empty IPI mask"))
 		return;
 
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	WARN_ON(mask & ~cpumask_bits(cpu_online_mask)[0]);
 	__default_send_IPI_dest_field(mask, vector, apic->dest_logical);
 	local_irq_restore(flags);
+	put_online_cpus_atomic();
 }
 
 void default_send_IPI_allbutself(int vector)
diff --git a/arch/x86/kernel/apic/x2apic_cluster.c b/arch/x86/kernel/apic/x2apic_cluster.c
index c88baa4..cb08e6b 100644
--- a/arch/x86/kernel/apic/x2apic_cluster.c
+++ b/arch/x86/kernel/apic/x2apic_cluster.c
@@ -88,12 +88,16 @@ x2apic_send_IPI_mask_allbutself(const struct cpumask *mask, int vector)
 
 static void x2apic_send_IPI_allbutself(int vector)
 {
+	get_online_cpus_atomic();
 	__x2apic_send_IPI_mask(cpu_online_mask, vector, APIC_DEST_ALLBUT);
+	put_online_cpus_atomic();
 }
 
 static void x2apic_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	__x2apic_send_IPI_mask(cpu_online_mask, vector, APIC_DEST_ALLINC);
+	put_online_cpus_atomic();
 }
 
 static int
diff --git a/arch/x86/kernel/apic/x2apic_uv_x.c b/arch/x86/kernel/apic/x2apic_uv_x.c
index 8cfade9..cc469a3 100644
--- a/arch/x86/kernel/apic/x2apic_uv_x.c
+++ b/arch/x86/kernel/apic/x2apic_uv_x.c
@@ -244,15 +244,19 @@ static void uv_send_IPI_allbutself(int vector)
 	unsigned int this_cpu = smp_processor_id();
 	unsigned int cpu;
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (cpu != this_cpu)
 			uv_send_IPI_one(cpu, vector);
 	}
+	put_online_cpus_atomic();
 }
 
 static void uv_send_IPI_all(int vector)
 {
+	get_online_cpus_atomic();
 	uv_send_IPI_mask(cpu_online_mask, vector);
+	put_online_cpus_atomic();
 }
 
 static int uv_apic_id_valid(int apicid)
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
index 13a6b29..2c3ec76 100644
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
