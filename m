From: Steven Hawkes <fsh016@ftw.mot.com>
Subject: printk_ratelimit and net_ratelimit conflict and tunable behavior
Date: Mon, 25 Feb 2008 14:36:40 -0600
Message-ID: <200802252036.m1PKaeMY012587@ftw.mot.com>
To: davem@davemloft.net, joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail119.messagelabs.com ([216.82.241.179]:37154 "HELO
	mail119.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757541AbYBYUgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 15:36:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hawkes <steve.hawkes@motorola.com>

The printk_ratelimit() and net_ratelimit() functions each have their own
tunable parameters to control their respective rate limiting feature, but
they share common state variables, preventing independent tuning of the
parameters from working correctly. Also, changes to rate limiting tunable
parameters do not always take effect properly since state is not recomputed
when changes occur. For example, if ratelimit_burst is increased while rate
limiting is occurring, the change won't take full effect until at least
enough time between messages occurs so that the toks value reaches
ratelimit_burst * ratelimit_jiffies. This can result in messages being
suppressed when they should be allowed.

Implement independent state for printk_ratelimit() and net_ratelimit(), and
update state when tunables are changed.

Signed-off-by: Steve Hawkes <steve.hawkes@motorola.com>
---
diff -uprN linux-2.6.24/include/linux/kernel.h linux-2.6.24-printk_ratelimit/include/linux/kernel.h
--- linux-2.6.24/include/linux/kernel.h	2008-01-24 16:58:37.000000000 -0600
+++ linux-2.6.24-printk_ratelimit/include/linux/kernel.h	2008-02-21 11:20:41.751197312 -0600
@@ -196,8 +196,19 @@ static inline int log_buf_copy(char *des
 
 unsigned long int_sqrt(unsigned long);
 
+struct printk_ratelimit_state
+{
+	unsigned long toks;
+	unsigned long last_jiffies;
+	int missed;
+	int limit_jiffies;
+	int limit_burst;
+	char const *facility;
+};
+
 extern int printk_ratelimit(void);
-extern int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst);
+extern int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst,
+				struct printk_ratelimit_state *state);
 extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
 				unsigned int interval_msec);
 
diff -uprN linux-2.6.24/kernel/printk.c linux-2.6.24-printk_ratelimit/kernel/printk.c
--- linux-2.6.24/kernel/printk.c	2008-01-24 16:58:37.000000000 -0600
+++ linux-2.6.24-printk_ratelimit/kernel/printk.c	2008-02-21 11:22:27.442319625 -0600
@@ -1238,35 +1238,41 @@ void tty_write_message(struct tty_struct
 /*
  * printk rate limiting, lifted from the networking subsystem.
  *
- * This enforces a rate limit: not more than one kernel message
- * every printk_ratelimit_jiffies to make a denial-of-service
- * attack impossible.
+ * This enforces a rate limit to mitigate denial-of-service attacks:
+ * not more than ratelimit_burst messages every ratelimit_jiffies.
  */
-int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst)
+int __printk_ratelimit(int ratelimit_jiffies,
+			int ratelimit_burst,
+			struct printk_ratelimit_state *state)
 {
 	static DEFINE_SPINLOCK(ratelimit_lock);
-	static unsigned long toks = 10 * 5 * HZ;
-	static unsigned long last_msg;
-	static int missed;
 	unsigned long flags;
 	unsigned long now = jiffies;
 
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
+	state->toks += now - state->last_jiffies;
+	/* Reset limiting if tunables changed */
+	if ((state->limit_jiffies != ratelimit_jiffies) ||
+	    (state->limit_burst != ratelimit_burst)) {
+		state->toks = ratelimit_burst * ratelimit_jiffies;
+		state->limit_jiffies = ratelimit_jiffies;
+		state->limit_burst = ratelimit_burst;
+	}
+	state->last_jiffies = now;
+	if (state->toks > (ratelimit_burst * ratelimit_jiffies))
+		state->toks = ratelimit_burst * ratelimit_jiffies;
+	if (state->toks >= ratelimit_jiffies) {
+		int lost = state->missed;
+		state->missed = 0;
+		state->toks -= ratelimit_jiffies;
 		spin_unlock_irqrestore(&ratelimit_lock, flags);
-		if (lost)
-			printk(KERN_WARNING "printk: %d messages suppressed.\n", lost);
+		if (lost) {
+			pr_warning("%s ratelimit suppressed message count: %d\n",
+				state->facility, lost);
+		}
 		return 1;
 	}
-	missed++;
+	state->missed++;
 	spin_unlock_irqrestore(&ratelimit_lock, flags);
 	return 0;
 }
@@ -1280,8 +1286,17 @@ int printk_ratelimit_burst = 10;
 
 int printk_ratelimit(void)
 {
+	static struct printk_ratelimit_state limit_state = {
+		.toks          = 10 * 5 * HZ,
+		.last_jiffies  = 0,
+		.missed        = 0,
+		.limit_jiffies = 5 * HZ,
+		.limit_burst   = 10,
+		.facility      = "printk"
+	};
+
 	return __printk_ratelimit(printk_ratelimit_jiffies,
-				printk_ratelimit_burst);
+				printk_ratelimit_burst, &limit_state);
 }
 EXPORT_SYMBOL(printk_ratelimit);
 
diff -uprN linux-2.6.24/net/core/utils.c linux-2.6.24-printk_ratelimit/net/core/utils.c
--- linux-2.6.24/net/core/utils.c	2008-01-24 16:58:37.000000000 -0600
+++ linux-2.6.24-printk_ratelimit/net/core/utils.c	2008-02-21 11:03:44.644337698 -0600
@@ -41,7 +41,16 @@ EXPORT_SYMBOL(net_msg_warn);
  */
 int net_ratelimit(void)
 {
-	return __printk_ratelimit(net_msg_cost, net_msg_burst);
+	static struct printk_ratelimit_state limit_state = {
+		.toks          = 10 * 5 * HZ,
+		.last_jiffies  = 0,
+		.missed        = 0,
+		.limit_jiffies = 5 * HZ,
+		.limit_burst   = 10,
+		.facility      = "net"
+	};
+
+	return __printk_ratelimit(net_msg_cost, net_msg_burst, &limit_state);
 }
 EXPORT_SYMBOL(net_ratelimit);
 
