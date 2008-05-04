From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH -mm] __ratelimit rewrite
Date: Sun, 4 May 2008 15:07:38 +0800
Message-ID: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.237]:39957 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbYEDHJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 03:09:46 -0400
Received: by hu-out-0506.google.com with SMTP id 19so1941968hue.21
        for <netdev@vger.kernel.org>; Sun, 04 May 2008 00:09:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ratelimit user use same jiffies and burst params, so some messages
(callbacks) will be lost.

For example:
a call printk_ratelimit(5 * HZ, 1)
b call printk_ratelimit(5 * HZ, 1) before the 5*HZ timeout of a, then b will
will be supressed.

Here rewrite the __ratelimit function, and use a ratelimit_state as parameter.
Thanks for hints from andrew.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>

---
include/asm-generic/bug.h  |    4 +--
include/linux/kernel.h     |    9 +------
include/linux/net.h        |    3 --
include/linux/ratelimit.h  |   20 +++++++++++++++
include/linux/rcupreempt.h |    7 +++--
kernel/printk.c            |   17 ++-----------
kernel/sysctl.c            |    4 +--
lib/ratelimit.c            |   57 ++++++++++++++++++++++++---------------------
net/core/sysctl_net_core.c |    4 +--
net/core/utils.c           |    5 +--
10 files changed, 70 insertions(+), 60 deletions(-)

diff -uprN linux/include/asm-generic/bug.h linux.new/include/asm-generic/bug.h
--- linux/include/asm-generic/bug.h	2008-04-30 17:32:54.000000000 +0800
+++ linux.new/include/asm-generic/bug.h	2008-05-04 13:46:38.000000000 +0800
@@ -76,8 +76,8 @@ extern void warn_on_slowpath(const char 
 	unlikely(__ret_warn_once);				\
 })
 
-#define WARN_ON_SECS(condition, state, secs)			\
-		WARN_ON((condition) && __ratelimit(state))
+#define WARN_ON_RATELIMIT(condition, state)			\
+		WARN_ON((condition) && __ratelimit(state));
 
 #ifdef CONFIG_SMP
 # define WARN_ON_SMP(x)			WARN_ON(x)
diff -uprN linux/include/linux/kernel.h linux.new/include/linux/kernel.h
--- linux/include/linux/kernel.h	2008-04-30 17:33:59.000000000 +0800
+++ linux.new/include/linux/kernel.h	2008-04-30 17:33:52.000000000 +0800
@@ -14,6 +14,7 @@
 #include <linux/compiler.h>
 #include <linux/bitops.h>
 #include <linux/log2.h>
+#include <linux/ratelimit.h>
 #include <asm/byteorder.h>
 #include <asm/bug.h>
 
@@ -187,12 +188,8 @@ asmlinkage int printk(const char * fmt, 
 extern int log_buf_get_len(void);
 extern int log_buf_read(int idx);
 extern int log_buf_copy(char *dest, int idx, int len);
-
-extern int printk_ratelimit_jiffies;
-extern int printk_ratelimit_burst;
+extern struct ratelimit_state printk_ratelimit_state;
 extern int printk_ratelimit(void);
-extern int __ratelimit(int ratelimit_jiffies, int ratelimit_burst);
-extern int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst);
 extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
 				   unsigned int interval_msec);
 #else
@@ -206,8 +203,6 @@ static inline int log_buf_get_len(void) 
 static inline int log_buf_read(int idx) { return 0; }
 static inline int log_buf_copy(char *dest, int idx, int len) { return 0; }
 static inline int printk_ratelimit(void) { return 0; }
-static inline int __printk_ratelimit(int ratelimit_jiffies, \
-				     int ratelimit_burst) { return 0; }
 static inline bool printk_timed_ratelimit(unsigned long *caller_jiffies, \
 					  unsigned int interval_msec)	\
 		{ return false; }
diff -uprN linux/include/linux/net.h linux.new/include/linux/net.h
--- linux/include/linux/net.h	2008-04-30 17:35:36.000000000 +0800
+++ linux.new/include/linux/net.h	2008-04-30 17:35:45.000000000 +0800
@@ -338,8 +338,7 @@ static const struct proto_ops name##_ops
 
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
-extern int net_msg_cost;
-extern int net_msg_burst;
+extern struct ratelimit_state net_ratelimit_state;
 #endif
 
 #endif /* __KERNEL__ */
diff -uprN linux/include/linux/ratelimit.h linux.new/include/linux/ratelimit.h
--- linux/include/linux/ratelimit.h	1970-01-01 07:00:00.000000000 +0700
+++ linux.new/include/linux/ratelimit.h	2008-05-04 14:33:50.000000000 +0800
@@ -0,0 +1,20 @@
+#ifndef _LINUX_RATELIMIT_H
+#define _LINUX_RATELIMIT_H
+
+struct ratelimit_state {
+	int interval;
+	int burst;
+	int printed;
+	int missed;
+	unsigned long begin;
+};
+
+#define DEFINE_RATELIMIT_STATE(name, interval, burst)		\
+		struct ratelimit_state name = {interval, burst,}
+extern int __ratelimit(struct ratelimit_state *rs);
+static inline int ratelimit(void)
+{
+	static struct ratelimit_state rs;
+	return __ratelimit(&rs);
+}
+#endif
diff -uprN linux/include/linux/rcupreempt.h linux.new/include/linux/rcupreempt.h
--- linux/include/linux/rcupreempt.h	2008-04-30 17:35:00.000000000 +0800
+++ linux.new/include/linux/rcupreempt.h	2008-05-04 13:48:35.000000000 +0800
@@ -115,16 +115,19 @@ DECLARE_PER_CPU(struct rcu_dyntick_sched
 
 static inline void rcu_enter_nohz(void)
 {
+	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
 	smp_mb(); /* CPUs seeing ++ must see prior RCU read-side crit sects */
 	__get_cpu_var(rcu_dyntick_sched).dynticks++;
-	WARN_ON_SECS(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1, 10);
+	WARN_ON_RATELIMIT(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1, &rs);
 }
 
 static inline void rcu_exit_nohz(void)
 {
+	static DEFINE_RATELIMIT_STATE(rs, 10 * HZ, 1);
 	__get_cpu_var(rcu_dyntick_sched).dynticks++;
 	smp_mb(); /* CPUs seeing ++ must see later RCU read-side crit sects */
-	WARN_ON_SECS(!(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1), 10);
+	WARN_ON_RATELIMIT(!(__get_cpu_var(rcu_dyntick_sched).dynticks & 0x1),
+			&rs);
 }
 
 #else /* CONFIG_NO_HZ */
diff -uprN linux/kernel/printk.c linux.new/kernel/printk.c
--- linux/kernel/printk.c	2008-04-30 17:36:20.000000000 +0800
+++ linux.new/kernel/printk.c	2008-05-04 14:01:35.000000000 +0800
@@ -1323,6 +1323,8 @@ void tty_write_message(struct tty_struct
 }
 
 #if defined CONFIG_PRINTK
+
+DEFINE_RATELIMIT_STATE(printk_ratelimit_state, 5 * HZ, 10);
 /*
  * printk rate limiting, lifted from the networking subsystem.
  *
@@ -1330,22 +1332,9 @@ void tty_write_message(struct tty_struct
  * every printk_ratelimit_jiffies to make a denial-of-service
  * attack impossible.
  */
-int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst)
-{
-	return __ratelimit(ratelimit_jiffies, ratelimit_burst);
-}
-EXPORT_SYMBOL(__printk_ratelimit);
-
-/* minimum time in jiffies between messages */
-int printk_ratelimit_jiffies = 5 * HZ;
-
-/* number of messages we send before ratelimiting */
-int printk_ratelimit_burst = 10;
-
 int printk_ratelimit(void)
 {
-	return __printk_ratelimit(printk_ratelimit_jiffies,
-				printk_ratelimit_burst);
+	return __ratelimit(&printk_ratelimit_state);
 }
 EXPORT_SYMBOL(printk_ratelimit);
 
diff -uprN linux/kernel/sysctl.c linux.new/kernel/sysctl.c
--- linux/kernel/sysctl.c	2008-04-30 17:36:39.000000000 +0800
+++ linux.new/kernel/sysctl.c	2008-04-30 17:36:46.000000000 +0800
@@ -623,7 +623,7 @@ static struct ctl_table kern_table[] = {
 	{
 		.ctl_name	= KERN_PRINTK_RATELIMIT,
 		.procname	= "printk_ratelimit",
-		.data		= &printk_ratelimit_jiffies,
+		.data		= &printk_ratelimit_state.interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
@@ -632,7 +632,7 @@ static struct ctl_table kern_table[] = {
 	{
 		.ctl_name	= KERN_PRINTK_RATELIMIT_BURST,
 		.procname	= "printk_ratelimit_burst",
-		.data		= &printk_ratelimit_burst,
+		.data		= &printk_ratelimit_state.burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
diff -uprN linux/lib/ratelimit.c linux.new/lib/ratelimit.c
--- linux/lib/ratelimit.c	2008-04-30 17:37:31.000000000 +0800
+++ linux.new/lib/ratelimit.c	2008-05-04 14:46:20.000000000 +0800
@@ -3,6 +3,9 @@
  *
  * Isolated from kernel/printk.c by Dave Young <hidave.darkstar@gmail.com>
  *
+ * 2008-05-01 rewrite the function and use a ratelimit_state data struct as
+ * parameter. Now every user can use their own standalone ratelimit_state.
+ *
  * This file is released under the GPLv2.
  *
  */
@@ -11,41 +14,43 @@
 #include <linux/jiffies.h>
 #include <linux/module.h>
 
+static DEFINE_SPINLOCK(ratelimit_lock);
+static unsigned long flags;
+
 /*
  * __ratelimit - rate limiting
- * @ratelimit_jiffies: minimum time in jiffies between two callbacks
- * @ratelimit_burst: number of callbacks we do before ratelimiting
+ * @rs: ratelimit_state data
  *
- * This enforces a rate limit: not more than @ratelimit_burst callbacks
- * in every ratelimit_jiffies
+ * This enforces a rate limit: not more than @rs->ratelimit_burst callbacks
+ * in every @rs->ratelimit_jiffies
  */
-int __ratelimit(int ratelimit_jiffies, int ratelimit_burst)
+int __ratelimit(struct ratelimit_state *rs)
 {
-	static DEFINE_SPINLOCK(ratelimit_lock);
-	static unsigned toks = 10 * 5 * HZ;
-	static unsigned long last_msg;
-	static int missed;
-	unsigned long flags;
-	unsigned long now = jiffies;
+	if (!rs->interval)
+		return 1;
 
 	spin_lock_irqsave(&ratelimit_lock, flags);
-	toks += now - last_msg;
-	last_msg = now;
-	if (toks > (ratelimit_burst * ratelimit_jiffies))
-		toks = ratelimit_burst * ratelimit_jiffies;
-	if (toks >= ratelimit_jiffies) {
-		int lost = missed;
-
-		missed = 0;
-		toks -= ratelimit_jiffies;
-		spin_unlock_irqrestore(&ratelimit_lock, flags);
-		if (lost)
-			printk(KERN_WARNING "%s: %d messages suppressed\n",
-				__func__, lost);
-		return 1;
+	if (!rs->begin)
+		rs->begin = jiffies;
+
+	if (time_is_before_jiffies(rs->begin + rs->interval)) {
+		if (rs->missed)
+			printk(KERN_WARNING "%s: %d callbacks suppressed\n",
+				__func__, rs->missed);
+		rs->begin = 0;
+		rs->printed = 0;
+		rs->missed = 0;
 	}
-	missed++;
+	if (rs->burst && rs->burst > rs->printed)
+		goto print;
+
+	rs->missed++;
 	spin_unlock_irqrestore(&ratelimit_lock, flags);
 	return 0;
+
+print:
+	rs->printed++;
+	spin_unlock_irqrestore(&ratelimit_lock, flags);
+	return 1;
 }
 EXPORT_SYMBOL(__ratelimit);
diff -uprN linux/net/core/sysctl_net_core.c linux.new/net/core/sysctl_net_core.c
--- linux/net/core/sysctl_net_core.c	2008-04-30 17:38:59.000000000 +0800
+++ linux.new/net/core/sysctl_net_core.c	2008-04-30 17:38:46.000000000 +0800
@@ -67,7 +67,7 @@ static struct ctl_table net_core_table[]
 	{
 		.ctl_name	= NET_CORE_MSG_COST,
 		.procname	= "message_cost",
-		.data		= &net_msg_cost,
+		.data		= &net_ratelimit_state.interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
@@ -76,7 +76,7 @@ static struct ctl_table net_core_table[]
 	{
 		.ctl_name	= NET_CORE_MSG_BURST,
 		.procname	= "message_burst",
-		.data		= &net_msg_burst,
+		.data		= &net_ratelimit_state.burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
diff -uprN linux/net/core/utils.c linux.new/net/core/utils.c
--- linux/net/core/utils.c	2008-04-30 17:38:29.000000000 +0800
+++ linux.new/net/core/utils.c	2008-05-04 14:02:09.000000000 +0800
@@ -31,17 +31,16 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-int net_msg_cost __read_mostly = 5*HZ;
-int net_msg_burst __read_mostly = 10;
 int net_msg_warn __read_mostly = 1;
 EXPORT_SYMBOL(net_msg_warn);
 
+DEFINE_RATELIMIT_STATE(net_ratelimit_state, 5 * HZ, 10);
 /*
  * All net warning printk()s should be guarded by this function.
  */
 int net_ratelimit(void)
 {
-	return __printk_ratelimit(net_msg_cost, net_msg_burst);
+	return __ratelimit(&net_ratelimit_state);
 }
 EXPORT_SYMBOL(net_ratelimit);
 
