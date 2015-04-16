From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/16] printk: move LOG_NOCONS skipping into call_console_drivers()
Date: Thu, 16 Apr 2015 19:03:40 -0400
Message-ID: <1429225433-11946-4-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Kay Sievers <kay@vrfy.org>,
	Petr Mladek <pmladek@suse.cz>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a line is printed by multiple printk invocations, each chunk is
directly sent out to console drivers so that they don't get lost.
When the line is completed and stored in the log buffer, the line is
suppressed from going out to consoles as that'd lead to duplicate
outputs.  This is tracked with LOG_NOCONS flag.

The suppression is currently implemented in console_unlock() which
skips invoking call_console_drivers() for LOG_NOCONS messages.  This
patch moves the filtering into call_console_drivers() in preparation
of the planned extended console drivers which will deal with the
duplicate messages themselves.

While this makes call_console_drivers() iterate over LOG_NOCONS
messages, this is extremely unlikely to matter especially given that
continuation lines aren't that common and also simplifies
console_unlock() a bit.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Petr Mladek <pmladek@suse.cz>
---
 kernel/printk/printk.c | 46 ++++++++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 22 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 5ea6709..0175c46 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1417,7 +1417,8 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
  * log_buf[start] to log_buf[end - 1].
  * The console_lock must be held.
  */
-static void call_console_drivers(int level, const char *text, size_t len)
+static void call_console_drivers(int level, bool nocons,
+				 const char *text, size_t len)
 {
 	struct console *con;
 
@@ -1438,6 +1439,13 @@ static void call_console_drivers(int level, const char *text, size_t len)
 		if (!cpu_online(smp_processor_id()) &&
 		    !(con->flags & CON_ANYTIME))
 			continue;
+		/*
+		 * Skip record we have buffered and already printed
+		 * directly to the console when we received it.
+		 */
+		if (nocons)
+			continue;
+
 		con->write(con, text, len);
 	}
 }
@@ -1919,7 +1927,8 @@ static struct cont {
 } cont;
 static struct printk_log *log_from_idx(u32 idx) { return NULL; }
 static u32 log_next(u32 idx) { return 0; }
-static void call_console_drivers(int level, const char *text, size_t len) {}
+static void call_console_drivers(int level, bool nocons,
+				 const char *text, size_t len) {}
 static size_t msg_print_text(const struct printk_log *msg, enum log_flags prev,
 			     bool syslog, char *buf, size_t size) { return 0; }
 static size_t cont_print_text(char *text, size_t size) { return 0; }
@@ -2190,7 +2199,7 @@ static void console_cont_flush(char *text, size_t size)
 	len = cont_print_text(text, size);
 	raw_spin_unlock(&logbuf_lock);
 	stop_critical_timings();
-	call_console_drivers(cont.level, text, len);
+	call_console_drivers(cont.level, false, text, len);
 	start_critical_timings();
 	local_irq_restore(flags);
 	return;
@@ -2234,6 +2243,7 @@ again:
 		struct printk_log *msg;
 		size_t len;
 		int level;
+		bool nocons;
 
 		raw_spin_lock_irqsave(&logbuf_lock, flags);
 		if (seen_seq != log_next_seq) {
@@ -2252,38 +2262,30 @@ again:
 		} else {
 			len = 0;
 		}
-skip:
+
 		if (console_seq == log_next_seq)
 			break;
 
 		msg = log_from_idx(console_idx);
-		if (msg->flags & LOG_NOCONS) {
-			/*
-			 * Skip record we have buffered and already printed
-			 * directly to the console when we received it.
-			 */
-			console_idx = log_next(console_idx);
-			console_seq++;
-			/*
-			 * We will get here again when we register a new
-			 * CON_PRINTBUFFER console. Clear the flag so we
-			 * will properly dump everything later.
-			 */
-			msg->flags &= ~LOG_NOCONS;
-			console_prev = msg->flags;
-			goto skip;
-		}
-
 		level = msg->level;
+		nocons = msg->flags & LOG_NOCONS;
 		len += msg_print_text(msg, console_prev, false,
 				      text + len, sizeof(text) - len);
 		console_idx = log_next(console_idx);
 		console_seq++;
 		console_prev = msg->flags;
+
+		/*
+		 * The log will be processed again when we register a new
+		 * CON_PRINTBUFFER console. Clear the flag so we will
+		 * properly dump everything later.
+		 */
+		msg->flags &= ~LOG_NOCONS;
+
 		raw_spin_unlock(&logbuf_lock);
 
 		stop_critical_timings();	/* don't trace print latency */
-		call_console_drivers(level, text, len);
+		call_console_drivers(level, nocons, text, len);
 		start_critical_timings();
 		local_irq_restore(flags);
 	}
-- 
2.1.0
