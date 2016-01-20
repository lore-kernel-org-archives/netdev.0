From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH RT 1/2] net: provide a way to delegate processing a softirq
 to ksoftirqd
Date: Wed, 20 Jan 2016 17:32:39 +0100
Message-ID: <20160120163239.GA2741@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: linux-rt-users@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the NET_RX uses up all of his budget it moves the following NAPI
invocations into the `ksoftirqd`. On -RT it does not do so. Instead it
rises the NET_RX softirq in its current context again.

In order to get closer to mainline's behaviour this patch provides
__raise_softirq_irqoff_ksoft() which raises the softirq in the ksoftird.

Cc: stable-rt@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/interrupt.h |  8 ++++++++
 kernel/softirq.c          | 13 +++++++++++++
 net/core/dev.c            |  2 +-
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 79a9622b5a38..655cee096aed 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -465,6 +465,14 @@ extern void thread_do_softirq(void);
 extern void open_softirq(int nr, void (*action)(struct softirq_action *));
 extern void softirq_init(void);
 extern void __raise_softirq_irqoff(unsigned int nr);
+#ifdef CONFIG_PREEMPT_RT_FULL
+extern void __raise_softirq_irqoff_ksoft(unsigned int nr);
+#else
+static inline void __raise_softirq_irqoff_ksoft(unsigned int nr)
+{
+	__raise_softirq_irqoff(nr);
+}
+#endif
 
 extern void raise_softirq_irqoff(unsigned int nr);
 extern void raise_softirq(unsigned int nr);
diff --git a/kernel/softirq.c b/kernel/softirq.c
index f4c2e679a7d7..e83fffff38cf 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -641,6 +641,19 @@ void __raise_softirq_irqoff(unsigned int nr)
 }
 
 /*
+ * Same as __raise_softirq_irqoff() but will process them in ksoftirqd
+ */
+void __raise_softirq_irqoff_ksoft(unsigned int nr)
+{
+	if (WARN_ON_ONCE(!__this_cpu_read(ksoftirqd)))
+		return;
+	trace_softirq_raise(nr);
+	or_softirq_pending(1UL << nr);
+	__this_cpu_read(ksoftirqd)->softirqs_raised |= (1U << nr);
+	wakeup_softirqd();
+}
+
+/*
  * This function must run with irqs disabled!
  */
 void raise_softirq_irqoff(unsigned int nr)
diff --git a/net/core/dev.c b/net/core/dev.c
index f4475ccbc19b..13a55d0df151 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4955,7 +4955,7 @@ static void net_rx_action(struct softirq_action *h)
 	list_splice_tail(&repoll, &list);
 	list_splice(&list, &sd->poll_list);
 	if (!list_empty(&sd->poll_list))
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+		__raise_softirq_irqoff_ksoft(NET_RX_SOFTIRQ);
 
 	net_rps_action_and_irq_enable(sd);
 }
-- 
2.7.0.rc3
