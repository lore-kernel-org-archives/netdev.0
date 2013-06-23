From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 35/45] ia64: irq,
 perfmon: Use get/put_online_cpus_atomic() to prevent CPU offline
Date: Sun, 23 Jun 2013 19:15:59 +0530
Message-ID: <20130623134555.19094.5855.stgit@srivatsabhat.in.ibm.com>
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
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-ia64@vger.kernel.org
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

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/ia64/kernel/irq_ia64.c |   15 +++++++++++++++
 arch/ia64/kernel/perfmon.c  |    8 +++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 1034884..f58b162 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -25,6 +25,7 @@
 #include <linux/ptrace.h>
 #include <linux/signal.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/threads.h>
 #include <linux/bitops.h>
 #include <linux/irq.h>
@@ -160,9 +161,11 @@ int bind_irq_vector(int irq, int vector, cpumask_t domain)
 	unsigned long flags;
 	int ret;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	ret = __bind_irq_vector(irq, vector, domain);
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -190,9 +193,11 @@ static void clear_irq_vector(int irq)
 {
 	unsigned long flags;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	__clear_irq_vector(irq);
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 }
 
 int
@@ -204,6 +209,7 @@ ia64_native_assign_irq_vector (int irq)
 
 	vector = -ENOSPC;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	for_each_online_cpu(cpu) {
 		domain = vector_allocation_domain(cpu);
@@ -218,6 +224,7 @@ ia64_native_assign_irq_vector (int irq)
 	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return vector;
 }
 
@@ -302,9 +309,11 @@ int irq_prepare_move(int irq, int cpu)
 	unsigned long flags;
 	int ret;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	ret = __irq_prepare_move(irq, cpu);
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -320,11 +329,13 @@ void irq_complete_move(unsigned irq)
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
@@ -393,10 +404,12 @@ void destroy_and_reserve_irq(unsigned int irq)
 
 	dynamic_irq_cleanup(irq);
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	__clear_irq_vector(irq);
 	irq_status[irq] = IRQ_RSVD;
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 }
 
 /*
@@ -409,6 +422,7 @@ int create_irq(void)
 	cpumask_t domain = CPU_MASK_NONE;
 
 	irq = vector = -ENOSPC;
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&vector_lock, flags);
 	for_each_online_cpu(cpu) {
 		domain = vector_allocation_domain(cpu);
@@ -424,6 +438,7 @@ int create_irq(void)
 	BUG_ON(__bind_irq_vector(irq, vector, domain));
  out:
 	spin_unlock_irqrestore(&vector_lock, flags);
+	put_online_cpus_atomic();
 	if (irq >= 0)
 		dynamic_irq_init(irq);
 	return irq;
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 9ea25fc..16c8303 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -6476,9 +6476,12 @@ pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 	/* do the easy test first */
 	if (pfm_alt_intr_handler) return -EBUSY;
 
+	get_online_cpus_atomic();
+
 	/* one at a time in the install or remove, just fail the others */
 	if (!spin_trylock(&pfm_alt_install_check)) {
-		return -EBUSY;
+		ret = -EBUSY;
+		goto out;
 	}
 
 	/* reserve our session */
@@ -6498,6 +6501,7 @@ pfm_install_alt_pmu_interrupt(pfm_intr_handler_desc_t *hdl)
 	pfm_alt_intr_handler = hdl;
 
 	spin_unlock(&pfm_alt_install_check);
+	put_online_cpus_atomic();
 
 	return 0;
 
@@ -6510,6 +6514,8 @@ cleanup_reserve:
 	}
 
 	spin_unlock(&pfm_alt_install_check);
+out:
+	put_online_cpus_atomic();
 
 	return ret;
 }
