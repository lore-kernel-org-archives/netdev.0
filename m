From: Mandeep Singh Baines <msb@google.com>
Subject: [PATCH] softlockup: detect bottom-half lockups
Date: Tue, 13 Jan 2009 23:04:47 -0800
Message-ID: <20090114070447.GA25222@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rientjes@google.com, mbligh@google.com, thockin@google.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: mingo@elte.hu, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:30639 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbZANHFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 02:05:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new kernel debug feature: CONFIG_DETECT_BHLOCKUP.

This feature is an extension of the softlockup detector.

When enabled, per-CPU watchdog tasklets are created, which try to run
periodically and update a timestamp. If they get delayed for more than
then the configured threshold a callback from the timer interrupt detects
this condition and prints out a warning message similar to what is
currently printing when a softlockup is detected.

The feature should be useful to real-time developers and developers
of network and other high-performance drivers.

Background:

Colleague noticed that a server was experiencing periodic packet drops:
a burst of packets every n minutes. After a lot of head scratching, it was
root caused to a daemon reading /proc/net/tcp. In this particular kernel,
the code disabled bottom-halves while iterating over all TCP buckets.

There was no softlockup because the burst wasn't long enough. With a
bottom-half only lockup detector it should be possible to set the threshold
very low (100s of ms) since the expected maximum delay for a temporary
bhlockup is much less than a softlockup.

The bug was fixed with this patch:

    commit      a7ab4b501f9b8a9dc4d5cee542db67b6ccd1088b
    Author: Herbert Xu <herbert@gondor.apana.org.au>
    Date:   Mon, 11 Jun 2007 00:33:08 +0000 (17:33 -0700)

    [TCPv4]: Improve BH latency in /proc/net/tcp

Signed-off-by: Mandeep Singh Baines <msb@google.com>
---
 include/linux/sched.h |    6 +++
 kernel/softlockup.c   |  119 ++++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sysctl.c       |   33 ++++++++++++++
 lib/Kconfig.debug     |   14 ++++++
 4 files changed, 171 insertions(+), 1 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 55e30d1..ad01824 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -314,6 +314,12 @@ static inline void touch_all_softlockup_watchdogs(void)
 {
 }
 #endif
+#ifdef CONFIG_DETECT_BHLOCKUP
+extern int bhlockup_thresh;
+extern int proc_dobhlockup_thresh(struct ctl_table *table, int write,
+				  struct file *filp, void __user *buffer,
+				  size_t *lenp, loff_t *ppos);
+#endif
 
 
 /* Attach to any functions which should be ignored in wchan output. */
diff --git a/kernel/softlockup.c b/kernel/softlockup.c
index dc0b3be..8348266 100644
--- a/kernel/softlockup.c
+++ b/kernel/softlockup.c
@@ -19,6 +19,15 @@
 
 #include <asm/irq_regs.h>
 
+#ifdef CONFIG_DETECT_BHLOCKUP
+#include <linux/interrupt.h>
+#include <linux/sysctl.h>
+
+static DEFINE_PER_CPU(unsigned long, bhtouch_timestamp);
+
+int __read_mostly bhlockup_thresh = 5000;
+#endif
+
 static DEFINE_SPINLOCK(print_lock);
 
 static DEFINE_PER_CPU(unsigned long, touch_timestamp);
@@ -75,6 +84,10 @@ static void __touch_softlockup_watchdog(void)
 void touch_softlockup_watchdog(void)
 {
 	__raw_get_cpu_var(touch_timestamp) = 0;
+#ifdef CONFIG_DETECT_BHLOCKUP
+	__raw_get_cpu_var(bhtouch_timestamp) = 0;
+#endif
+
 }
 EXPORT_SYMBOL(touch_softlockup_watchdog);
 
@@ -83,11 +96,111 @@ void touch_all_softlockup_watchdogs(void)
 	int cpu;
 
 	/* Cause each CPU to re-update its timestamp rather than complain */
-	for_each_online_cpu(cpu)
+	for_each_online_cpu(cpu) {
 		per_cpu(touch_timestamp, cpu) = 0;
+#ifdef CONFIG_DETECT_BHLOCKUP
+		per_cpu(bhtouch_timestamp, cpu) = 0;
+#endif
+	}
 }
 EXPORT_SYMBOL(touch_all_softlockup_watchdogs);
 
+#ifdef CONFIG_DETECT_BHLOCKUP
+int proc_dobhlockup_thresh(struct ctl_table *table, int write,
+			   struct file *filp, void __user *buffer,
+			   size_t *lenp, loff_t *ppos)
+{
+	touch_all_softlockup_watchdogs();
+	return proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+}
+
+static unsigned long get_timestamp_ms(int this_cpu)
+{
+	return cpu_clock(this_cpu) >> 20LL;  /* 2^20 ~= 10^6 */
+}
+
+static void __touch_bhlockup_watchdog(void)
+{
+	int this_cpu = raw_smp_processor_id();
+
+	__raw_get_cpu_var(bhtouch_timestamp) = get_timestamp_ms(this_cpu);
+}
+
+/*
+ * The watchdog tasklet - touches the timestamp.
+ */
+static void bhwatchdog(unsigned long dummy)
+{
+	__touch_bhlockup_watchdog();
+}
+DEFINE_PER_CPU(struct tasklet_struct, bhlockup_tasklet) = { NULL, 0, ATOMIC_INIT(0), bhwatchdog, 0UL };
+
+/*
+ * This callback runs from the timer interrupt, and checks
+ * whether the watchdog thread has hung or not:
+ */
+void bhlockup_tick(void)
+{
+	int this_cpu = smp_processor_id();
+	unsigned long touch_timestamp = per_cpu(bhtouch_timestamp, this_cpu);
+	unsigned long print_timestamp;
+	struct pt_regs *regs = get_irq_regs();
+	unsigned long now;
+
+	/* Is detection switched off? */
+	if (bhlockup_thresh <= 0) {
+		/* Be sure we don't false trigger if switched back on */
+		if (touch_timestamp)
+			per_cpu(bhtouch_timestamp, this_cpu) = 0;
+		return;
+	}
+
+	if (touch_timestamp == 0) {
+		__touch_bhlockup_watchdog();
+		return;
+	}
+
+	print_timestamp = per_cpu(print_timestamp, this_cpu);
+
+	/* report at most once a second */
+	if (print_timestamp == (touch_timestamp >> 10) || did_panic)
+		return;
+
+	/* do not print during early bootup: */
+	if (unlikely(system_state != SYSTEM_RUNNING)) {
+		__touch_bhlockup_watchdog();
+		return;
+	}
+
+	now = get_timestamp_ms(this_cpu);
+
+	/*
+	 * Wake up the high-prio watchdog task twice per
+	 * threshold timespan.
+	 */
+	if (now > touch_timestamp + bhlockup_thresh/2)
+		tasklet_schedule(&per_cpu(bhlockup_tasklet, this_cpu));
+
+	/* Warn about unreasonable delays: */
+	if (now <= (touch_timestamp + bhlockup_thresh))
+		return;
+
+	per_cpu(print_timestamp, this_cpu) = touch_timestamp >> 10;
+
+	spin_lock(&print_lock);
+	printk(KERN_ERR "BUG: bh lockup - CPU#%d stuck for %lums! [%s:%d]\n",
+			this_cpu, now - touch_timestamp,
+			current->comm, task_pid_nr(current));
+	print_modules();
+	print_irqtrace_events(current);
+	if (regs)
+		show_regs(regs);
+	else
+		dump_stack();
+	spin_unlock(&print_lock);
+}
+#endif
+
 /*
  * This callback runs from the timer interrupt, and checks
  * whether the watchdog thread has hung or not:
@@ -100,6 +213,10 @@ void softlockup_tick(void)
 	struct pt_regs *regs = get_irq_regs();
 	unsigned long now;
 
+#ifdef CONFIG_DETECT_BHLOCKUP
+	bhlockup_tick();
+#endif
+
 	/* Is detection switched off? */
 	if (!per_cpu(watchdog_task, this_cpu) || softlockup_thresh <= 0) {
 		/* Be sure we don't false trigger if switched back on */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3d56fe7..94d234d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -799,6 +799,19 @@ static struct ctl_table kern_table[] = {
 		.strategy	= &sysctl_intvec,
 	},
 #endif
+#ifdef CONFIG_DETECT_SOFTLOCKUP
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "bhlockup_thresh_ms",
+		.data		= &bhlockup_thresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dobhlockup_thresh,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &neg_one,
+		.extra2		= &sixty,
+	},
+#endif
 #ifdef CONFIG_COMPAT
 	{
 		.ctl_name	= KERN_COMPAT_LOG,
@@ -2010,6 +2023,26 @@ void sysctl_head_put(struct ctl_table_header *head)
  * /proc/sys support
  */
 
+int proc_dobhlockupnow(ctl_table *table, int write, struct file *filp,
+		      void *buffer, size_t *lenp, loff_t *ppos)
+{
+	if (write) {
+		char magic[20];
+		/* just crash in kernel mode. */
+		if(copy_from_user(magic, buffer, min(*lenp, sizeof(magic))))
+			return -EFAULT;
+		magic[min(*lenp, sizeof(magic))-1] = 0;
+		if (!strcmp(magic, "elgooG")) {
+			local_bh_disable();
+			mdelay(20000);
+			local_bh_enable();
+		}
+		return 0;
+	}
+	*lenp = 0;
+	return 0;
+}
+
 #ifdef CONFIG_PROC_SYSCTL
 
 static int _proc_do_string(void* data, int maxlen, int write,
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index b0f239e..a7c8b2c 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -186,6 +186,20 @@ config BOOTPARAM_SOFTLOCKUP_PANIC_VALUE
 	default 0 if !BOOTPARAM_SOFTLOCKUP_PANIC
 	default 1 if BOOTPARAM_SOFTLOCKUP_PANIC
 
+config DETECT_BHLOCKUP
+	bool "Detect Bottom-half Lockups"
+	depends on DETECT_SOFTLOCKUP
+	default y
+	help
+	  Say Y here to enable the kernel to detect "bottom-half lockups",
+	  which are bugs that cause the kernel to delay soft interrupt
+	  processing for more than 5 seconds.
+
+	  When a bottom-half lockup is detected, the kernel will print the
+	  current stack trace (which you should report), but the
+	  system will stay locked up. This feature has negligible
+	  overhead.
+
 config SCHED_DEBUG
 	bool "Collect scheduler debugging info"
 	depends on DEBUG_KERNEL && PROC_FS
-- 
1.5.4.5

