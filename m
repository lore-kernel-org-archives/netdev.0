From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/3] printk: implement support for extended console drivers
Date: Wed, 29 Apr 2015 10:45:04 -0400
Message-ID: <1430318704-32374-4-git-send-email-tj@kernel.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Kay Sievers <kay@vrfy.org>
To: pmladek@suse.cz, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34356 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423013AbbD2OpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 10:45:20 -0400
In-Reply-To: <1430318704-32374-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

printk log_buf keeps various metadata for each message including its
sequence number and timestamp.  The metadata is currently available
only through /dev/kmsg and stripped out before passed onto console
drivers.  We want this metadata to be available to console drivers too
so that console consumers can get full information including the
metadata and dictionary, which among other things can be used to
detect whether messages got lost in transit.

This patch implements support for extended console drivers.  Consoles
can indicate that they want extended messages by setting the new
CON_EXTENDED flag and they'll be fed messages formatted the same way
as /dev/kmsg.

 "<level>,<sequnum>,<timestamp>,<contflag>;<message text>\n"

If extended consoles exist, in-kernel fragment assembly is disabled.
This ensures that all messages emitted to consoles have full metadata
including sequence number.  The contflag carries enough information to
reassemble the fragments from the reader side trivially.  Note that
this only affects /dev/kmsg.  Regular console and /proc/kmsg outputs
are not affected by this change.

* Extended message formatting for console drivers is enabled iff there
  are registered extended consoles.

* Comment describing /dev/kmsg message format updated to add missing
  contflag field and help distinguishing variable from verbatim terms.

v2: Disable in-kernel cont buffer if extended consoles are present
    which simplifies things quite a bit.  Hinted by Petr.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Petr Mladek <pmladek@suse.cz>
---
 include/linux/console.h |  1 +
 kernel/printk/printk.c  | 65 +++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 58 insertions(+), 8 deletions(-)

diff --git a/include/linux/console.h b/include/linux/console.h
index 9f50fb4..bd19434 100644
--- a/include/linux/console.h
+++ b/include/linux/console.h
@@ -115,6 +115,7 @@ static inline int con_debug_leave(void)
 #define CON_BOOT	(8)
 #define CON_ANYTIME	(16) /* Safe to call when cpu is offline */
 #define CON_BRL		(32) /* Used for a braille device */
+#define CON_EXTENDED	(64) /* Use the extended output format a la /dev/kmsg */
 
 struct console {
 	char	name[16];
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 51ce4f1..9cc2664 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -85,6 +85,18 @@ static struct lockdep_map console_lock_dep_map = {
 #endif
 
 /*
+ * Number of registered extended console drivers.
+ *
+ * If extended consoles are present, in-kernel cont reassembly is disabled
+ * and each fragment is stored as a separate log entry with proper
+ * continuation flag so that every emitted message has full metadata.  This
+ * doesn't change the result for regular consoles or /proc/kmsg.  For
+ * /dev/kmsg, as long as the reader concatenates messages according to
+ * consecutive continuation flags, the end result should be the same too.
+ */
+static int nr_ext_console_drivers;
+
+/*
  * Helper macros to handle lockdep when locking/unlocking console_sem. We use
  * macros instead of functions so that _RET_IP_ contains useful information.
  */
@@ -195,7 +207,7 @@ static int console_may_schedule;
  * need to be changed in the future, when the requirements change.
  *
  * /dev/kmsg exports the structured data in the following line format:
- *   "level,sequnum,timestamp;<message text>\n"
+ *   "<level>,<sequnum>,<timestamp>,<contflag>;<message text>\n"
  *
  * The optional key/value pairs are attached as continuation lines starting
  * with a space character and terminated by a newline. All possible
@@ -1417,7 +1429,9 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
  * log_buf[start] to log_buf[end - 1].
  * The console_lock must be held.
  */
-static void call_console_drivers(int level, const char *text, size_t len)
+static void call_console_drivers(int level,
+				 const char *ext_text, size_t ext_len,
+				 const char *text, size_t len)
 {
 	struct console *con;
 
@@ -1438,7 +1452,10 @@ static void call_console_drivers(int level, const char *text, size_t len)
 		if (!cpu_online(smp_processor_id()) &&
 		    !(con->flags & CON_ANYTIME))
 			continue;
-		con->write(con, text, len);
+		if (con->flags & CON_EXTENDED)
+			con->write(con, ext_text, ext_len);
+		else
+			con->write(con, text, len);
 	}
 }
 
@@ -1581,8 +1598,12 @@ static bool cont_add(int facility, int level, const char *text, size_t len)
 	if (cont.len && cont.flushed)
 		return false;
 
-	if (cont.len + len > sizeof(cont.buf)) {
-		/* the line gets too long, split it up in separate records */
+	/*
+	 * If ext consoles are present, flush and skip in-kernel
+	 * continuation.  See nr_ext_console_drivers definition.  Also, if
+	 * the line gets too long, split it up in separate records.
+	 */
+	if (nr_ext_console_drivers || cont.len + len > sizeof(cont.buf)) {
 		cont_flush(LOG_CONT);
 		return false;
 	}
@@ -1917,9 +1938,19 @@ static struct cont {
 	u8 level;
 	bool flushed:1;
 } cont;
+static char *log_text(const struct printk_log *msg) { return NULL; }
+static char *log_dict(const struct printk_log *msg) { return NULL; }
 static struct printk_log *log_from_idx(u32 idx) { return NULL; }
 static u32 log_next(u32 idx) { return 0; }
-static void call_console_drivers(int level, const char *text, size_t len) {}
+static ssize_t msg_print_ext_header(char *buf, size_t size,
+				    struct printk_log *msg, u64 seq,
+				    enum log_flags prev_flags) { return 0; }
+static ssize_t msg_print_ext_body(char *buf, size_t size,
+				  char *dict, size_t dict_len,
+				  char *text, size_t text_len) { return 0; }
+static void call_console_drivers(int level,
+				 const char *ext_text, size_t ext_len,
+				 const char *text, size_t len) {}
 static size_t msg_print_text(const struct printk_log *msg, enum log_flags prev,
 			     bool syslog, char *buf, size_t size) { return 0; }
 static size_t cont_print_text(char *text, size_t size) { return 0; }
@@ -2172,7 +2203,7 @@ static void console_cont_flush(char *text, size_t size)
 	len = cont_print_text(text, size);
 	raw_spin_unlock(&logbuf_lock);
 	stop_critical_timings();
-	call_console_drivers(cont.level, text, len);
+	call_console_drivers(cont.level, NULL, 0, text, len);
 	start_critical_timings();
 	local_irq_restore(flags);
 	return;
@@ -2196,6 +2227,7 @@ out:
  */
 void console_unlock(void)
 {
+	static char ext_text[CONSOLE_EXT_LOG_MAX];
 	static char text[LOG_LINE_MAX + PREFIX_MAX];
 	static u64 seen_seq;
 	unsigned long flags;
@@ -2214,6 +2246,7 @@ void console_unlock(void)
 again:
 	for (;;) {
 		struct printk_log *msg;
+		size_t ext_len = 0;
 		size_t len;
 		int level;
 
@@ -2259,13 +2292,22 @@ skip:
 		level = msg->level;
 		len += msg_print_text(msg, console_prev, false,
 				      text + len, sizeof(text) - len);
+		if (nr_ext_console_drivers) {
+			ext_len = msg_print_ext_header(ext_text,
+						sizeof(ext_text),
+						msg, console_seq, console_prev);
+			ext_len += msg_print_ext_body(ext_text + ext_len,
+						sizeof(ext_text) - ext_len,
+						log_dict(msg), msg->dict_len,
+						log_text(msg), msg->text_len);
+		}
 		console_idx = log_next(console_idx);
 		console_seq++;
 		console_prev = msg->flags;
 		raw_spin_unlock(&logbuf_lock);
 
 		stop_critical_timings();	/* don't trace print latency */
-		call_console_drivers(level, text, len);
+		call_console_drivers(level, ext_text, ext_len, text, len);
 		start_critical_timings();
 		local_irq_restore(flags);
 	}
@@ -2521,6 +2563,10 @@ void register_console(struct console *newcon)
 		newcon->next = console_drivers->next;
 		console_drivers->next = newcon;
 	}
+
+	if (newcon->flags & CON_EXTENDED)
+		nr_ext_console_drivers++;
+
 	if (newcon->flags & CON_PRINTBUFFER) {
 		/*
 		 * console_unlock(); will print out the buffered messages
@@ -2593,6 +2639,9 @@ int unregister_console(struct console *console)
 		}
 	}
 
+	if (!res && (console->flags & CON_EXTENDED))
+		nr_ext_console_drivers--;
+
 	/*
 	 * If this isn't the last console and it has CON_CONSDEV set, we
 	 * need to set it on the next preferred console.
-- 
2.1.0
