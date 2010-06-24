From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v2 1/5] irq: add tracepoint to softirq_raise
Date: Thu, 24 Jun 2010 17:16:27 +0900
Message-ID: <4C23145B.30805@jp.fujitsu.com>
References: <4C2312A8.9060903@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, scott.a.mcmillan@intel.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:53118 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab0FXIQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 04:16:28 -0400
In-Reply-To: <4C2312A8.9060903@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a tracepoint to raising of softirq.
This is useful if you want to detect which hard interrupt raise softirq
and lets you know a time between raising softirq and performing softirq.
Combinating with other tracepoint, it lets us know a process of packets
(See patch 0/5).

          <idle>-0     [001] 241229.957184: softirq_raise: vec=3 [action=NET_RX]
          <idle>-0     [000] 241229.993399: softirq_raise: vec=1 [action=TIMER]
          <idle>-0     [000] 241229.993400: softirq_raise: vec=9 [action=RCU]

This is a same patch Lai Jiangshan submitted.
http://marc.info/?l=linux-kernel&m=126026122728732&w=2

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/linux/interrupt.h  |    8 +++++++-
 include/trace/events/irq.h |   34 +++++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index c233113..1cb5726 100644
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
+	trace_softirq_raise(nr);
+	or_softirq_pending(1UL << nr);
+}
+
 extern void raise_softirq_irqoff(unsigned int nr);
 extern void raise_softirq(unsigned int nr);
 extern void wakeup_softirqd(void);
diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
index 0e4cfb6..7cb7435 100644
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
@@ -82,6 +84,32 @@ TRACE_EVENT(irq_handler_exit,
 		  __entry->irq, __entry->ret ? "handled" : "unhandled")
 );
 
+/**
+ * softirq_raise - called immediately when a softirq is raised
+ * @nr: softirq vector number
+ *
+ * Tracepoint for tracing when softirq action is raised.
+ * Also, when used in combination with the softirq_entry tracepoint
+ * we can determine the softirq raise latency.
+ */
+TRACE_EVENT(softirq_raise,
+
+	TP_PROTO(unsigned int nr),
+
+	TP_ARGS(nr),
+
+	TP_STRUCT__entry(
+		__field(	unsigned int,	vec	)
+	),
+
+	TP_fast_assign(
+		__entry->vec	= nr;
+	),
+
+	TP_printk("vec=%d [action=%s]", __entry->vec,
+		show_softirq_name(__entry->vec))
+);
+
 DECLARE_EVENT_CLASS(softirq,
 
 	TP_PROTO(struct softirq_action *h, struct softirq_action *vec),
@@ -89,11 +117,11 @@ DECLARE_EVENT_CLASS(softirq,
 	TP_ARGS(h, vec),
 
 	TP_STRUCT__entry(
-		__field(	int,	vec			)
+		__field(	unsigned int,	vec	)
 	),
 
 	TP_fast_assign(
-		__entry->vec = (int)(h - vec);
+		__entry->vec = (unsigned int)(h - vec);
 	),
 
 	TP_printk("vec=%d [action=%s]", __entry->vec,


