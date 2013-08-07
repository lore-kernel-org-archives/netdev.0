From: Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH v3 10/11] syslog_ns: implement ns_console_unlock for specific syslog_ns
Date: Wed, 7 Aug 2013 15:37:14 +0800
Message-ID: <1375861035-24320-11-git-send-email-rui.xiang@huawei.com>
References: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<serge.hallyn@ubuntu.com>, <ebiederm@xmission.com>,
	<akpm@linux-foundation.org>, <gaofeng@cn.fujitsu.com>,
	<guz.fnst@cn.fujitsu.com>, <libo.chen@huawei.com>,
	Rui Xiang <rui.xiang@huawei.com>
To: <containers@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45112 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362Ab3HGHiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 03:38:18 -0400
In-Reply-To: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While monitoring embedded devices that provide access
to the console over a serial port, in order to obtain
kernel logs from containers, it is necessary to include
consoles in the syslog_ns.

This patch adds a new interface named ns_console_unlock,
and use syslog ns as a parameter to dispaly logs from
current syslog namespace on cosoles, not just init_
syslog_ns.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 include/linux/console.h |   1 +
 kernel/printk.c         | 116 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 116 insertions(+), 1 deletion(-)

diff --git a/include/linux/console.h b/include/linux/console.h
index 7571a16..4c02fe6 100644
--- a/include/linux/console.h
+++ b/include/linux/console.h
@@ -148,6 +148,7 @@ extern struct console *console_drivers;
 extern void console_lock(void);
 extern int console_trylock(void);
 extern void console_unlock(void);
+extern void ns_console_unlock(struct syslog_namespace *ns);
 extern void console_conditional_schedule(void);
 extern void console_unblank(void);
 extern struct tty_driver *console_device(int *);
diff --git a/kernel/printk.c b/kernel/printk.c
index b60c1d4..39bb9db 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -1684,7 +1684,7 @@ static int ns_vprintk_emit(int facility, int level,
 	 * regardless of whether it actually gets the console semaphore or not.
 	 */
 	if (console_trylock_for_printk(this_cpu, ns))
-		console_unlock();
+		ns_console_unlock(ns);
 
 	lockdep_on();
 out_restore_irqs:
@@ -2135,6 +2135,120 @@ out:
 }
 
 /**
+  * ns_console_unlock - unlock the console system for syslog_namespace
+  *
+  * Releases the console_lock which the caller holds on the console system
+  * and the console driver list.
+  *
+  * While the console_lock was held, console output may have been buffered
+  * by printk().  If this is the case, syslog_console_unlock(); emits
+  * the output prior to releasing the lock.
+  *
+  * If there is output waiting, we wake /dev/kmsg and syslog() users.
+  *
+  * syslog_console_unlock(); may be called from any context.
+  */
+void ns_console_unlock(struct syslog_namespace *ns)
+{
+	static char text[LOG_LINE_MAX + PREFIX_MAX];
+	static u64 seen_seq;
+	unsigned long flags;
+	bool wake_klogd = false;
+	bool retry;
+
+	if (console_suspended) {
+		up(&console_sem);
+		return;
+	}
+
+	console_may_schedule = 0;
+
+	/* flush buffered message fragment immediately to console */
+	console_cont_flush(text, sizeof(text), ns);
+again:
+	for (;;) {
+		struct log *msg;
+		size_t len;
+		int level;
+
+		raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+		if (seen_seq != ns->log_next_seq) {
+			wake_klogd = true;
+			seen_seq = ns->log_next_seq;
+		}
+
+		if (ns->console_seq < ns->log_first_seq) {
+			/* messages are gone, move to first one */
+			ns->console_seq = ns->log_first_seq;
+			ns->console_idx = ns->log_first_idx;
+			console_prev = 0;
+		}
+skip:
+		if (ns->console_seq == ns->log_next_seq)
+			break;
+
+		msg = log_from_idx(ns->console_idx, ns);
+		if (msg->flags & LOG_NOCONS) {
+			/*
+			 * Skip record we have buffered and already printed
+			 * directly to the console when we received it.
+			 */
+			ns->console_idx =
+				log_next(ns->console_idx, ns);
+			ns->console_seq++;
+			/*
+			 * We will get here again when we register a new
+			 * CON_PRINTBUFFER console. Clear the flag so we
+			 * will properly dump everything later.
+			 */
+			msg->flags &= ~LOG_NOCONS;
+			console_prev = msg->flags;
+			goto skip;
+		}
+
+		level = msg->level;
+		len = msg_print_text(msg, console_prev, false,
+						text, sizeof(text));
+		ns->console_idx =
+			log_next(ns->console_idx, ns);
+		ns->console_seq++;
+		console_prev = msg->flags;
+		raw_spin_unlock(&ns->logbuf_lock);
+
+		stop_critical_timings();	/* don't trace print latency */
+		call_console_drivers(level, text, len);
+		start_critical_timings();
+		local_irq_restore(flags);
+	}
+	console_locked = 0;
+
+	/* Release the exclusive_console once it is used */
+	if (unlikely(exclusive_console))
+		exclusive_console = NULL;
+
+	raw_spin_unlock(&ns->logbuf_lock);
+
+	up(&console_sem);
+
+	/*
+	 * Someone could have filled up the buffer again, so re-check if there's
+	 * something to flush. In case we cannot trylock the console_sem again,
+	 * there's a new owner and the console_unlock() from them will do the
+	 * flush, no worries.
+	 */
+	raw_spin_lock(&ns->logbuf_lock);
+	retry = ns->console_seq != ns->log_next_seq;
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
+
+	if (retry && console_trylock())
+		goto again;
+
+	if (wake_klogd)
+		wake_up_klogd();
+}
+EXPORT_SYMBOL(ns_console_unlock);
+
+/**
  * console_unlock - unlock the console system
  *
  * Releases the console_lock which the caller holds on the console system
-- 
1.8.2.2
