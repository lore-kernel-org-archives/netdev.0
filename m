From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 19/45] irq: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Sun, 23 Jun 2013 19:12:30 +0530
Message-ID: <20130623134226.19094.55366.stgit@srivatsabhat.in.ibm.com>
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
	Thomas Gleixner <tglx@linutronix.de>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:51862 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab3FWNpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 09:45:50 -0400
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sun, 23 Jun 2013 19:11:12 +0530
In-Reply-To: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once stop_machine() is gone from the CPU offline path, we won't be able
to depend on disabling preemption to prevent CPUs from going offline
from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
offline, while invoking from atomic context.

Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/irq/manage.c |    7 +++++++
 kernel/irq/proc.c   |    3 +++
 2 files changed, 10 insertions(+)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index e16caa8..4d89f19 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/sched/rt.h>
 #include <linux/task_work.h>
+#include <linux/cpu.h>
 
 #include "internals.h"
 
@@ -202,9 +203,11 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *mask)
 	if (!desc)
 		return -EINVAL;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	ret =  __irq_set_affinity_locked(irq_desc_get_irq_data(desc), mask);
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -343,9 +346,11 @@ int irq_select_affinity_usr(unsigned int irq, struct cpumask *mask)
 	unsigned long flags;
 	int ret;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	ret = setup_affinity(irq, desc, mask);
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
+	put_online_cpus_atomic();
 	return ret;
 }
 
@@ -1128,7 +1133,9 @@ __setup_irq(unsigned int irq, struct irq_desc *desc, struct irqaction *new)
 		}
 
 		/* Set default affinity mask once everything is setup */
+		get_online_cpus_atomic();
 		setup_affinity(irq, desc, mask);
+		put_online_cpus_atomic();
 
 	} else if (new->flags & IRQF_TRIGGER_MASK) {
 		unsigned int nmsk = new->flags & IRQF_TRIGGER_MASK;
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 19ed5c4..47f9a74 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/irq.h>
+#include <linux/cpu.h>
 #include <linux/gfp.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -441,6 +442,7 @@ int show_interrupts(struct seq_file *p, void *v)
 	if (!desc)
 		return 0;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&desc->lock, flags);
 	for_each_online_cpu(j)
 		any_count |= kstat_irqs_cpu(i, j);
@@ -477,6 +479,7 @@ int show_interrupts(struct seq_file *p, void *v)
 	seq_putc(p, '\n');
 out:
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
+	put_online_cpus_atomic();
 	return 0;
 }
 #endif
