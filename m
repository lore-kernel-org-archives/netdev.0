From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 41/45] powerpc: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Fri, 28 Jun 2013 01:30:11 +0530
Message-ID: <20130627200010.29830.98711.stgit@srivatsabhat.in.ibm.com>
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
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Gleb Natapov <gleb@redhat.com>, Alexander Graf <agraf@suse.de>,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Kumar Gala <galak@kernel.crashing.org>,
	Zhao Chenhui <chenhui.zhao@freescale.com>,
	linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org,
	kvm-ppc@vger.kernel.org, oprofile-list@lists.sf.net,
	cbe-oss-dev@lists.ozlabs.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Gleb Natapov <gleb@redhat.com>
Cc: Alexander Graf <agraf@suse.de>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: Zhao Chenhui <chenhui.zhao@freescale.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: kvm@vger.kernel.org
Cc: kvm-ppc@vger.kernel.org
Cc: oprofile-list@lists.sf.net
Cc: cbe-oss-dev@lists.ozlabs.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/irq.c                  |    7 ++++++-
 arch/powerpc/kernel/machine_kexec_64.c     |    4 ++--
 arch/powerpc/kernel/smp.c                  |    2 ++
 arch/powerpc/kvm/book3s_hv.c               |    5 +++--
 arch/powerpc/mm/mmu_context_nohash.c       |    3 +++
 arch/powerpc/oprofile/cell/spu_profiler.c  |    3 +++
 arch/powerpc/oprofile/cell/spu_task_sync.c |    4 ++++
 arch/powerpc/oprofile/op_model_cell.c      |    6 ++++++
 8 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index ca39bac..41e9961 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -45,6 +45,7 @@
 #include <linux/irq.h>
 #include <linux/seq_file.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/profile.h>
 #include <linux/bitops.h>
 #include <linux/list.h>
@@ -410,7 +411,10 @@ void migrate_irqs(void)
 	unsigned int irq;
 	static int warned;
 	cpumask_var_t mask;
-	const struct cpumask *map = cpu_online_mask;
+	const struct cpumask *map;
+
+	get_online_cpus_atomic();
+	map = cpu_online_mask;
 
 	alloc_cpumask_var(&mask, GFP_ATOMIC);
 
@@ -436,6 +440,7 @@ void migrate_irqs(void)
 	}
 
 	free_cpumask_var(mask);
+	put_online_cpus_atomic();
 
 	local_irq_enable();
 	mdelay(1);
diff --git a/arch/powerpc/kernel/machine_kexec_64.c b/arch/powerpc/kernel/machine_kexec_64.c
index 611acdf..38f6d75 100644
--- a/arch/powerpc/kernel/machine_kexec_64.c
+++ b/arch/powerpc/kernel/machine_kexec_64.c
@@ -187,7 +187,7 @@ static void kexec_prepare_cpus_wait(int wait_state)
 	int my_cpu, i, notified=-1;
 
 	hw_breakpoint_disable();
-	my_cpu = get_cpu();
+	my_cpu = get_online_cpus_atomic();
 	/* Make sure each CPU has at least made it to the state we need.
 	 *
 	 * FIXME: There is a (slim) chance of a problem if not all of the CPUs
@@ -266,7 +266,7 @@ static void kexec_prepare_cpus(void)
 	 */
 	kexec_prepare_cpus_wait(KEXEC_STATE_REAL_MODE);
 
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 #else /* ! SMP */
diff --git a/arch/powerpc/kernel/smp.c b/arch/powerpc/kernel/smp.c
index ee7ac5e..2123bec 100644
--- a/arch/powerpc/kernel/smp.c
+++ b/arch/powerpc/kernel/smp.c
@@ -277,9 +277,11 @@ void smp_send_debugger_break(void)
 	if (unlikely(!smp_ops))
 		return;
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu)
 		if (cpu != me)
 			do_message_pass(cpu, PPC_MSG_DEBUGGER_BREAK);
+	put_online_cpus_atomic();
 }
 #endif
 
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 2efa9dd..9d8a973 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -28,6 +28,7 @@
 #include <linux/fs.h>
 #include <linux/anon_inodes.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/spinlock.h>
 #include <linux/page-flags.h>
 #include <linux/srcu.h>
@@ -78,7 +79,7 @@ void kvmppc_fast_vcpu_kick(struct kvm_vcpu *vcpu)
 		++vcpu->stat.halt_wakeup;
 	}
 
-	me = get_cpu();
+	me = get_online_cpus_atomic();
 
 	/* CPU points to the first thread of the core */
 	if (cpu != me && cpu >= 0 && cpu < nr_cpu_ids) {
@@ -88,7 +89,7 @@ void kvmppc_fast_vcpu_kick(struct kvm_vcpu *vcpu)
 		else if (cpu_online(cpu))
 			smp_send_reschedule(cpu);
 	}
-	put_cpu();
+	put_online_cpus_atomic();
 }
 
 /*
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index e779642..c7bdcb4 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -194,6 +194,8 @@ void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next)
 	unsigned int i, id, cpu = smp_processor_id();
 	unsigned long *map;
 
+	get_online_cpus_atomic();
+
 	/* No lockless fast path .. yet */
 	raw_spin_lock(&context_lock);
 
@@ -280,6 +282,7 @@ void switch_mmu_context(struct mm_struct *prev, struct mm_struct *next)
 	pr_hardcont(" -> %d\n", id);
 	set_context(id, next->pgd);
 	raw_spin_unlock(&context_lock);
+	put_online_cpus_atomic();
 }
 
 /*
diff --git a/arch/powerpc/oprofile/cell/spu_profiler.c b/arch/powerpc/oprofile/cell/spu_profiler.c
index b129d00..ab6e6c1 100644
--- a/arch/powerpc/oprofile/cell/spu_profiler.c
+++ b/arch/powerpc/oprofile/cell/spu_profiler.c
@@ -14,6 +14,7 @@
 
 #include <linux/hrtimer.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/slab.h>
 #include <asm/cell-pmu.h>
 #include <asm/time.h>
@@ -142,6 +143,7 @@ static enum hrtimer_restart profile_spus(struct hrtimer *timer)
 	if (!spu_prof_running)
 		goto stop;
 
+	get_online_cpus_atomic();
 	for_each_online_cpu(cpu) {
 		if (cbe_get_hw_thread_id(cpu))
 			continue;
@@ -177,6 +179,7 @@ static enum hrtimer_restart profile_spus(struct hrtimer *timer)
 				       oprof_spu_smpl_arry_lck_flags);
 
 	}
+	put_online_cpus_atomic();
 	smp_wmb();	/* insure spu event buffer updates are written */
 			/* don't want events intermingled... */
 
diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 28f1af2..8464ef6 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -28,6 +28,7 @@
 #include <linux/oprofile.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/cpu.h>
 #include "pr_util.h"
 
 #define RELEASE_ALL 9999
@@ -448,11 +449,14 @@ static int number_of_online_nodes(void)
 {
         u32 cpu; u32 tmp;
         int nodes = 0;
+
+	get_online_cpus_atomic();
         for_each_online_cpu(cpu) {
                 tmp = cbe_cpu_to_node(cpu) + 1;
                 if (tmp > nodes)
                         nodes++;
         }
+	put_online_cpus_atomic();
         return nodes;
 }
 
diff --git a/arch/powerpc/oprofile/op_model_cell.c b/arch/powerpc/oprofile/op_model_cell.c
index b9589c1..c9bb028 100644
--- a/arch/powerpc/oprofile/op_model_cell.c
+++ b/arch/powerpc/oprofile/op_model_cell.c
@@ -22,6 +22,7 @@
 #include <linux/oprofile.h>
 #include <linux/percpu.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 #include <linux/spinlock.h>
 #include <linux/timer.h>
 #include <asm/cell-pmu.h>
@@ -463,6 +464,7 @@ static void cell_virtual_cntr(unsigned long data)
 	 * not both playing with the counters on the same node.
 	 */
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&cntr_lock, flags);
 
 	prev_hdw_thread = hdw_thread;
@@ -550,6 +552,7 @@ static void cell_virtual_cntr(unsigned long data)
 	}
 
 	spin_unlock_irqrestore(&cntr_lock, flags);
+	put_online_cpus_atomic();
 
 	mod_timer(&timer_virt_cntr, jiffies + HZ / 10);
 }
@@ -608,6 +611,8 @@ static void spu_evnt_swap(unsigned long data)
 	/* Make sure spu event interrupt handler and spu event swap
 	 * don't access the counters simultaneously.
 	 */
+
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&cntr_lock, flags);
 
 	cur_spu_evnt_phys_spu_indx = spu_evnt_phys_spu_indx;
@@ -673,6 +678,7 @@ static void spu_evnt_swap(unsigned long data)
 	}
 
 	spin_unlock_irqrestore(&cntr_lock, flags);
+	put_online_cpus_atomic();
 
 	/* swap approximately every 0.1 seconds */
 	mod_timer(&timer_spu_event_swap, jiffies + HZ / 25);
