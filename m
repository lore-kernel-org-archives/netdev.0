From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 32/45] cris/smp: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Tue, 22 Jan 2013 13:11:51 +0530
Message-ID: <20130122074146.13822.86691.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: Mikael Starvik <starvik@axis.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: linux-cris-kernel@axis.com
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/cris/arch-v32/kernel/smp.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/cris/arch-v32/kernel/smp.c b/arch/cris/arch-v32/kernel/smp.c
index 04a16ed..644b358 100644
--- a/arch/cris/arch-v32/kernel/smp.c
+++ b/arch/cris/arch-v32/kernel/smp.c
@@ -15,6 +15,7 @@
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/cpumask.h>
+#include <linux/cpu.h>
 #include <linux/interrupt.h>
 #include <linux/module.h>
 
@@ -208,9 +209,12 @@ int __cpuinit __cpu_up(unsigned int cpu, struct task_struct *tidle)
 void smp_send_reschedule(int cpu)
 {
 	cpumask_t cpu_mask;
+
+	get_online_cpus_atomic();
 	cpumask_clear(&cpu_mask);
 	cpumask_set_cpu(cpu, &cpu_mask);
 	send_ipi(IPI_SCHEDULE, 0, cpu_mask);
+	put_online_cpus_atomic();
 }
 
 /* TLB flushing
@@ -224,6 +228,7 @@ void flush_tlb_common(struct mm_struct* mm, struct vm_area_struct* vma, unsigned
 	unsigned long flags;
 	cpumask_t cpu_mask;
 
+	get_online_cpus_atomic();
 	spin_lock_irqsave(&tlbstate_lock, flags);
 	cpu_mask = (mm == FLUSH_ALL ? cpu_all_mask : *mm_cpumask(mm));
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
@@ -232,6 +237,7 @@ void flush_tlb_common(struct mm_struct* mm, struct vm_area_struct* vma, unsigned
 	flush_addr = addr;
 	send_ipi(IPI_FLUSH_TLB, 1, cpu_mask);
 	spin_unlock_irqrestore(&tlbstate_lock, flags);
+	put_online_cpus_atomic();
 }
 
 void flush_tlb_all(void)
@@ -312,6 +318,7 @@ int smp_call_function(void (*func)(void *info), void *info, int wait)
 	struct call_data_struct data;
 	int ret;
 
+	get_online_cpus_atomic();
 	cpumask_setall(&cpu_mask);
 	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
 
@@ -325,6 +332,7 @@ int smp_call_function(void (*func)(void *info), void *info, int wait)
 	call_data = &data;
 	ret = send_ipi(IPI_CALL, wait, cpu_mask);
 	spin_unlock(&call_lock);
+	put_online_cpus_atomic();
 
 	return ret;
 }

