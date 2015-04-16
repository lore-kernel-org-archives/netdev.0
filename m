From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 05/16] printk: implement log_seq_range() and ext_log_from_seq()
Date: Thu, 16 Apr 2015 19:03:42 -0400
Message-ID: <1429225433-11946-6-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Kay Sievers <kay@vrfy.org>,
	Petr Mladek <pmladek@suse.cz>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement two functions to access log messages by their sequence
numbers.

* log_seq_range() determines the currently available sequence number
  range.

* ext_log_from_seq() outputs log message identified by a given
  sequence number in the extended format.

These will be used to implement reliable netconsole.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Petr Mladek <pmladek@suse.cz>
---
 include/linux/printk.h | 14 ++++++++
 kernel/printk/printk.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index 58b1fec..4fd3bb4 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -6,6 +6,7 @@
 #include <linux/kern_levels.h>
 #include <linux/linkage.h>
 #include <linux/cache.h>
+#include <linux/errno.h>
 
 extern const char linux_banner[];
 extern const char linux_proc_banner[];
@@ -169,6 +170,8 @@ void __init setup_log_buf(int early);
 void dump_stack_set_arch_desc(const char *fmt, ...);
 void dump_stack_print_info(const char *log_lvl);
 void show_regs_print_info(const char *log_lvl);
+void log_seq_range(u64 *beginp, u64 *endp);
+ssize_t ext_log_from_seq(char *buf, size_t size, u64 log_seq);
 #else
 static inline __printf(1, 0)
 int vprintk(const char *s, va_list args)
@@ -228,6 +231,17 @@ static inline void dump_stack_print_info(const char *log_lvl)
 static inline void show_regs_print_info(const char *log_lvl)
 {
 }
+
+static inline void log_seq_range(u64 *begin_seqp, u64 *end_seqp)
+{
+	*begin_seqp = 0;
+	*end_seqp = 0;
+}
+
+static inline ssize_t ext_log_from_seq(char *buf, size_t size, u64 log_seq)
+{
+	return -ERANGE;
+}
 #endif
 
 extern asmlinkage void dump_stack(void) __cold;
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 349a37b..904413e 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -617,6 +617,102 @@ static ssize_t msg_print_ext_body(char *buf, size_t size,
 	return p - buf;
 }
 
+/**
+ * log_seq_range - get the range of available log sequence numbers
+ * @begin_seqp: output parameter for the begin of the range
+ * @end_seqp: output parameter for the end of the range
+ *
+ * Returns the log sequence number range [*@begin_seqp, *@ends_seqp) which
+ * is currently available to be retrieved using ext_log_from_seq().  Note
+ * that the range may shift anytime.
+ */
+void log_seq_range(u64 *begin_seqp, u64 *end_seqp)
+{
+	unsigned long flags;
+
+	raw_spin_lock_irqsave(&logbuf_lock, flags);
+	*begin_seqp = log_first_seq;
+	*end_seqp = log_next_seq;
+	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+}
+EXPORT_SYMBOL_GPL(log_seq_range);
+
+/**
+ * ext_log_from_seq - obtain log message in extended format from its seq number
+ * @buf: output buffer
+ * @size: size of @buf
+ * @log_seq: target log sequence number
+ *
+ * Print the log message with @log_seq as its sequence number into @buf
+ * using the extended format.  On success, returns the length of formatted
+ * output excluding the terminating '\0'.  If @log_seq doesn't match any
+ * message, -ERANGE is returned.
+ *
+ * Due to the way messages are stored, accessing @log_seq requires seeking
+ * the log buffer sequentially.  As the last looked up position is cached,
+ * accessing messages in ascending sequence order is recommended.
+ */
+ssize_t ext_log_from_seq(char *buf, size_t size, u64 log_seq)
+{
+	static u64 seq_hint;
+	static u32 idx_hint;
+	static enum log_flags prev_flags_hint;
+	struct printk_log *msg;
+	enum log_flags prev_flags = 0;
+	unsigned long flags;
+	ssize_t len;
+	u32 seq;
+	u32 prev_idx, idx;
+
+	raw_spin_lock_irqsave(&logbuf_lock, flags);
+
+	if (log_seq < log_first_seq || log_seq >= log_next_seq) {
+		len = -ERANGE;
+		goto out_unlock;
+	}
+
+	/*
+	 * Seek to @log_seq to determine its index. The last looked up seq
+	 * and index are cached to accelerate in-order accesses.  For now,
+	 * @prev_flags is best effort.  It'd be better to restructure it so
+	 * that the current entry carries all the relevant information
+	 * without depending on the previous one.
+	 */
+	seq = log_first_seq;
+	idx = log_first_idx;
+
+	if (seq < seq_hint && seq_hint <= log_seq) {
+		seq = seq_hint;
+		idx = idx_hint;
+		prev_flags = prev_flags_hint;
+	}
+
+	prev_idx = idx;
+	while (seq < log_seq) {
+		seq++;
+		prev_idx = idx;
+		idx = log_next(idx);
+	}
+
+	if (prev_idx != idx)
+		prev_flags = log_from_idx(prev_idx)->flags;
+	msg = log_from_idx(idx);
+
+	/* entry located, format it */
+	len = msg_print_ext_header(buf, size, msg, seq, prev_flags);
+	len += msg_print_ext_body(buf + len, size - len,
+				  log_dict(msg), msg->dict_len,
+				  log_text(msg), msg->text_len);
+
+	seq_hint = seq;
+	idx_hint = idx;
+	prev_flags_hint = prev_flags;
+out_unlock:
+	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	return len;
+}
+EXPORT_SYMBOL_GPL(ext_log_from_seq);
+
 /* /dev/kmsg - userspace message inject/listen interface */
 struct devkmsg_user {
 	u64 seq;
-- 
2.1.0
