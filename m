From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v4 1/5] irq: add tracepoint to softirq_raise
Date: Wed, 28 Jul 2010 15:29:05 +0900
Message-ID: <4C4FCE31.5090004@jp.fujitsu.com>
References: <4C4FCDA1.3000803@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:44130 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712Ab0G1G3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 02:29:18 -0400
In-Reply-To: <4C4FCDA1.3000803@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHANGE-LOG since v3:
  -change arguments of softirq tracepoint into original one.

From: Lai Jiangshan <laijs@cn.fujitsu.com>

Add a tracepoint for tracing when softirq action is raised.

It and the existed tracepoints complete softirq's tracepoints:
softirq_raise, softirq_entry and softirq_exit.

And when this tracepoint is used in combination with
the softirq_entry tracepoint we can determine
the softirq raise latency.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Acked-by: Frederic Weisbecker <fweisbec@gmail.com>

[ factorize softirq events with DECLARE_EVENT_CLASS ]
Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/linux/interrupt.h  |    8 +++++++-
 include/trace/events/irq.h |   26 ++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index c233113..5460db4 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -18,6 +18,7 @@
 #include <asm/atomic.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
+#include <trace/events/irq.h>
 
 /*
  * These correspond to the IORESOURCE_IRQ_* defines in
@@ -402,7 +403,12 @@ asmlinkage void do_softirq(void);
 asmlinkage void __do_softirq(void);
 extern void open_softirq(int nr, void (*action)(struct softirq_action *));
 extern void softirq_init(void);
-#define __raise_softirq_irqoff(nr) do { or_softirq_pending(1UL << (nr)); } while (0)
+static inline void __raise_softirq_irqoff(unsigned int nr)
+{
+	trace_softirq_raise((struct softirq_action *)&nr, NULL);
+	or_softirq_pending(1UL << nr);
+}
+
 extern void raise_softirq_irqoff(unsigned int nr);
 extern void raise_softirq(unsigned int nr);
 extern void wakeup_softirqd(void);
diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
index 0e4cfb6..3ddda02 100644
--- a/include/trace/events/irq.h
+++ b/include/trace/events/irq.h
@@ -5,7 +5,9 @@
 #define _TRACE_IRQ_H
 
 #include <linux/tracepoint.h>
-#include <linux/interrupt.h>
+
+struct irqaction;
+struct softirq_action;
 
 #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
 #define show_softirq_name(val)				\
@@ -93,7 +95,10 @@ DECLARE_EVENT_CLASS(softirq,
 	),
 
 	TP_fast_assign(
-		__entry->vec = (int)(h - vec);
+		if (vec)
+			__entry->vec = (int)(h - vec);
+		else
+			__entry->vec = *((int *)h);
 	),
 
 	TP_printk("vec=%d [action=%s]", __entry->vec,
@@ -136,6 +141,23 @@ DEFINE_EVENT(softirq, softirq_exit,
 	TP_ARGS(h, vec)
 );
 
+/**
+ * softirq_raise - called immediately when a softirq is raised
+ * @h: pointer to struct softirq_action
+ * @vec: pointer to first struct softirq_action in softirq_vec array
+ *
+ * The @h parameter contains a pointer to the softirq vector number which is
+ * raised. @vec is NULL and it means @h includes vector number not
+ * softirq_action. When used in combination with the softirq_entry tracepoint
+ * we can determine the softirq raise latency.
+ */
+DEFINE_EVENT(softirq, softirq_raise,
+
+	TP_PROTO(struct softirq_action *h, struct softirq_action *vec),
+
+	TP_ARGS(h, vec)
+);
+
 #endif /*  _TRACE_IRQ_H */
 
 /* This part must be outside protection */

