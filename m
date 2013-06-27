From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 37/45] m32r: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Fri, 28 Jun 2013 01:29:21 +0530
Message-ID: <20130627195920.29830.11441.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hirokazu Takata <takata@linux-m32r.org>,
	linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Hirokazu Takata <takata@linux-m32r.org>
Cc: linux-m32r@ml.linux-m32r.org
Cc: linux-m32r-ja@ml.linux-m32r.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/m32r/kernel/smp.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/m32r/kernel/smp.c b/arch/m32r/kernel/smp.c
index ce7aea3..ffafdba 100644
--- a/arch/m32r/kernel/smp.c
+++ b/arch/m32r/kernel/smp.c
@@ -151,7 +151,7 @@ void smp_flush_cache_all(void)
 	cpumask_t cpumask;
 	unsigned long *mask;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpumask_copy(&cpumask, cpu_online_mask);
 	cpumask_clear_cpu(smp_processor_id(), &cpumask);
 	spin_lock(&flushcache_lock);
@@ -162,7 +162,7 @@ void smp_flush_cache_all(void)
 	while (flushcache_cpumask)
 		mb();
 	spin_unlock(&flushcache_lock);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 void smp_flush_cache_all_interrupt(void)
@@ -197,12 +197,12 @@ void smp_flush_tlb_all(void)
 {
 	unsigned long flags;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	local_irq_save(flags);
 	__flush_tlb_all();
 	local_irq_restore(flags);
 	smp_call_function(flush_tlb_all_ipi, NULL, 1);
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /*==========================================================================*
@@ -250,7 +250,7 @@ void smp_flush_tlb_mm(struct mm_struct *mm)
 	unsigned long *mmc;
 	unsigned long flags;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpu_id = smp_processor_id();
 	mmc = &mm->context[cpu_id];
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
@@ -268,7 +268,7 @@ void smp_flush_tlb_mm(struct mm_struct *mm)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, NULL, FLUSH_ALL);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /*==========================================================================*
@@ -320,7 +320,7 @@ void smp_flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	unsigned long *mmc;
 	unsigned long flags;
 
-	preempt_disable();
+	get_online_cpus_atomic();
 	cpu_id = smp_processor_id();
 	mmc = &mm->context[cpu_id];
 	cpumask_copy(&cpu_mask, mm_cpumask(mm));
@@ -341,7 +341,7 @@ void smp_flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 	if (!cpumask_empty(&cpu_mask))
 		flush_tlb_others(cpu_mask, mm, vma, va);
 
-	preempt_enable();
+	put_online_cpus_atomic();
 }
 
 /*==========================================================================*
