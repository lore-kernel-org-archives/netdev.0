From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 18/45] irq: Use get/put_online_cpus_atomic() to prevent CPU
 offline
Date: Tue, 22 Jan 2013 13:08:00 +0530
Message-ID: <20130122073757.13822.33489.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:59825 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3AVHkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 02:40:05 -0500
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 17:34:45 +1000
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/irq/manage.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index e49a288..b4240b9 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/cpu.h>
 #include <linux/task_work.h>
 
 #include "internals.h"
@@ -202,7 +203,9 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *mask)
 		return -EINVAL;
 
 	raw_spin_lock_irqsave(&desc->lock, flags);
+	get_online_cpus_atomic();
 	ret =  __irq_set_affinity_locked(irq_desc_get_irq_data(desc), mask);
+	put_online_cpus_atomic();
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 	return ret;
 }
@@ -343,7 +346,9 @@ int irq_select_affinity_usr(unsigned int irq, struct cpumask *mask)
 	int ret;
 
 	raw_spin_lock_irqsave(&desc->lock, flags);
+	get_online_cpus_atomic();
 	ret = setup_affinity(irq, desc, mask);
+	put_online_cpus_atomic();
 	raw_spin_unlock_irqrestore(&desc->lock, flags);
 	return ret;
 }
@@ -1126,7 +1131,9 @@ __setup_irq(unsigned int irq, struct irq_desc *desc, struct irqaction *new)
 		}
 
 		/* Set default affinity mask once everything is setup */
+		get_online_cpus_atomic();
 		setup_affinity(irq, desc, mask);
+		put_online_cpus_atomic();
 
 	} else if (new->flags & IRQF_TRIGGER_MASK) {
 		unsigned int nmsk = new->flags & IRQF_TRIGGER_MASK;
