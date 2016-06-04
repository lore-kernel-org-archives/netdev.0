From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Sat, 4 Jun 2016 07:11:31 -0400
Message-ID: <20160604071131.08d449db@grimm.local.home>
References: <20160526195641.6c26e979@gandalf.local.home>
	<20160602161235.GA12971@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: alison@peloton-tech.com, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20160602161235.GA12971@linutronix.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Jun 2016 18:12:35 +0200
Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> * Steven Rostedt | 2016-05-26 19:56:41 [-0400]:
> 
> >[ Alison, can you try this patch ]
> 
> Alison, did you try it?
> 
> Sebastian

This patch may help too...

-- Steve

>From 729e35706b8352d83692764adbeca429bb26ba7f Mon Sep 17 00:00:00 2001
From: Steven Rostedt <srostedt@redhat.com>
Date: Tue, 5 Jan 2016 14:53:09 -0500
Subject: [PATCH] softirq: Perform softirqs in local_bh_enable() for a limited
 amount of time

To prevent starvation of tasks like ksoftirqd, if the task that is
processing its softirqs takes more than 2 jiffies to do so, and the
softirqs are constantly being re-added, then defer the processing to
ksoftirqd.

Signed-off-by: Steven Rostedt <rosted@goodmis.org>
Signed-off-by: Luis Claudio R. Goncalves <lgoncalv@redhat.com>
---
 kernel/softirq.c |   53 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 34 insertions(+), 19 deletions(-)

Index: linux-rt.git/kernel/softirq.c
===================================================================
--- linux-rt.git.orig/kernel/softirq.c	2016-06-04 07:01:54.584296827 -0400
+++ linux-rt.git/kernel/softirq.c	2016-06-04 07:06:35.449913451 -0400
@@ -206,6 +206,22 @@ static void handle_softirq(unsigned int
 	}
 }
 
+/*
+ * We restart softirq processing for at most MAX_SOFTIRQ_RESTART times,
+ * but break the loop if need_resched() is set or after 2 ms.
+ * The MAX_SOFTIRQ_TIME provides a nice upper bound in most cases, but in
+ * certain cases, such as stop_machine(), jiffies may cease to
+ * increment and so we need the MAX_SOFTIRQ_RESTART limit as
+ * well to make sure we eventually return from this method.
+ *
+ * These limits have been established via experimentation.
+ * The two things to balance is latency against fairness -
+ * we want to handle softirqs as soon as possible, but they
+ * should not be able to lock up the box.
+ */
+#define MAX_SOFTIRQ_TIME  msecs_to_jiffies(2)
+#define MAX_SOFTIRQ_RESTART 10
+
 #ifndef CONFIG_PREEMPT_RT_FULL
 static inline int ksoftirqd_softirq_pending(void)
 {
@@ -349,22 +365,6 @@ void __local_bh_enable_ip(unsigned long
 }
 EXPORT_SYMBOL(__local_bh_enable_ip);
 
-/*
- * We restart softirq processing for at most MAX_SOFTIRQ_RESTART times,
- * but break the loop if need_resched() is set or after 2 ms.
- * The MAX_SOFTIRQ_TIME provides a nice upper bound in most cases, but in
- * certain cases, such as stop_machine(), jiffies may cease to
- * increment and so we need the MAX_SOFTIRQ_RESTART limit as
- * well to make sure we eventually return from this method.
- *
- * These limits have been established via experimentation.
- * The two things to balance is latency against fairness -
- * we want to handle softirqs as soon as possible, but they
- * should not be able to lock up the box.
- */
-#define MAX_SOFTIRQ_TIME  msecs_to_jiffies(2)
-#define MAX_SOFTIRQ_RESTART 10
-
 #ifdef CONFIG_TRACE_IRQFLAGS
 /*
  * When we run softirqs from irq_exit() and thus on the hardirq stack we need
@@ -537,11 +537,17 @@ static void do_single_softirq(int which)
  */
 static void do_current_softirqs(void)
 {
-	while (current->softirqs_raised) {
-		int i = __ffs(current->softirqs_raised);
+	unsigned long end = jiffies + MAX_SOFTIRQ_TIME;
+	unsigned int softirqs_raised = current->softirqs_raised;
+
+restart:
+	current->softirqs_raised &= ~softirqs_raised;
+
+	while (softirqs_raised) {
+		int i = __ffs(softirqs_raised);
 		unsigned int pending, mask = (1U << i);
 
-		current->softirqs_raised &= ~mask;
+		softirqs_raised &= ~mask;
 		local_irq_enable();
 
 		/*
@@ -568,6 +574,15 @@ static void do_current_softirqs(void)
 		unlock_softirq(i);
 		local_irq_disable();
 	}
+
+	softirqs_raised = current->softirqs_raised;
+	if (softirqs_raised) {
+		if (time_before(jiffies, end))
+			goto restart;
+
+		__this_cpu_read(ksoftirqd)->softirqs_raised |= softirqs_raised;
+		wakeup_softirqd();
+	}
 }
 
 void __local_bh_disable(void)
