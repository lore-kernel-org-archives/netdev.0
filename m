From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 2/5] genirq: add flags for controlling the default threaded irq behavior
Date: Wed, 15 Jun 2016 15:42:03 +0200
Message-ID: <27519147c77d201c5d380a7a34803d3a7bbc0e18.1465996447.git.pabeni@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A threadable irq can benefit from irq_set_affinity when running
in non threaded mode and prefer running unbounded to cpu when in
threaded mode. Setting the IRQF_TH_NO_AFFINITY flag on irq
registration allow the irq to achieve both behaviors.

A long running threaded irq can starve the system if scheduled under
SCHED_FIFO. Setting the IRQF_TH_SCHED_NORMAL flag on irq will cause
the irq thread to run by default under the SCHED_NORMAL scheduler.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/interrupt.h |  6 ++++++
 kernel/irq/manage.c       | 17 +++++++++++------
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 85d3738..33c3033 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -61,6 +61,10 @@
  *                interrupt handler after suspending interrupts. For system
  *                wakeup devices users need to implement wakeup detection in
  *                their interrupt handlers.
+ * IRQF_TH_SCHED_NORMAL - If the IRQ is threaded, it will use SCHED_NORMAL,
+ *                instead the default SCHED_FIFO scheduler
+ * IRQF_TH_NO_AFFINITY - If the IRQ is threaded, the affinity hint will not be
+ *                enforced in the IRQ thread
  */
 #define IRQF_SHARED		0x00000080
 #define IRQF_PROBE_SHARED	0x00000100
@@ -74,6 +78,8 @@
 #define IRQF_NO_THREAD		0x00010000
 #define IRQF_EARLY_RESUME	0x00020000
 #define IRQF_COND_SUSPEND	0x00040000
+#define IRQF_TH_SCHED_NORMAL	0x00080000
+#define IRQF_TH_NO_AFFINITY	0x00100000
 
 #define IRQF_TIMER		(__IRQF_TIMER | IRQF_NO_SUSPEND | IRQF_NO_THREAD)
 
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index cce4efd..d695e12 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1055,9 +1055,7 @@ static struct task_struct *
 create_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 {
 	struct task_struct *t;
-	struct sched_param param = {
-		.sched_priority = MAX_USER_RT_PRIO/2,
-	};
+	struct sched_param param;
 
 	if (!secondary) {
 		t = kthread_create(irq_thread, new, "irq/%d-%s", irq,
@@ -1071,7 +1069,12 @@ create_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 	if (IS_ERR(t))
 		return t;
 
-	sched_setscheduler_nocheck(t, SCHED_FIFO, &param);
+	if (new->flags & IRQF_TH_SCHED_NORMAL) {
+		sched_setscheduler_nocheck(t, SCHED_NORMAL, &param);
+	} else {
+		param.sched_priority = MAX_USER_RT_PRIO/2;
+		sched_setscheduler_nocheck(t, SCHED_FIFO, &param);
+	}
 
 	/*
 	 * We keep the reference to the task struct even if
@@ -1100,7 +1103,8 @@ setup_irq_thread(struct irqaction *new, unsigned int irq, bool secondary)
 	 * correct as we want the thread to move to the cpu(s)
 	 * on which the requesting code placed the interrupt.
 	 */
-	set_bit(IRQTF_AFFINITY, &new->thread_flags);
+	if (!(new->flags & IRQF_TH_NO_AFFINITY))
+		set_bit(IRQTF_AFFINITY, &new->thread_flags);
 	return 0;
 }
 
@@ -1549,7 +1553,8 @@ void __irq_reconfigure_action(struct irq_desc *desc, struct irqaction *action,
 
 	action->thread = t;
 	set_bit(IRQTF_FORCED_THREAD, &action->thread_flags);
-	set_bit(IRQTF_AFFINITY, &action->thread_flags);
+	if (!(action->flags & IRQF_TH_NO_AFFINITY))
+		set_bit(IRQTF_AFFINITY, &action->thread_flags);
 
 	if (!(desc->irq_data.chip->flags & IRQCHIP_ONESHOT_SAFE)) {
 		/*
-- 
1.8.3.1
