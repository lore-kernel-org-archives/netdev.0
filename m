From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC 3/5] printk: modify printk interface for syslog_namespace
Date: Mon, 19 Nov 2012 16:16:48 +0800
Message-ID: <50A9EAF0.4000902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

We re-implement printk by additional syslog_ns.

The function include printk, /dev/kmsg, do_syslog and kmsg_dump should be modifyed
for syslog_ns. Previous identifier *** such as log_first_seq should be replaced
by syslog_ns->***.

Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/base/core.c    |    4 +-
 include/linux/printk.h |    4 +-
 kernel/printk.c        |  609 +++++++++++++++++++++++++++++-------------------
 3 files changed, 372 insertions(+), 245 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index abea76c..665c2f7 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -26,6 +26,7 @@
 #include <linux/async.h>
 #include <linux/pm_runtime.h>
 #include <linux/netdevice.h>
+#include <linux/syslog_namespace.h>

 #include "base.h"
 #include "power/power.h"
@@ -1922,7 +1923,8 @@ int dev_vprintk_emit(int level, const struct device *dev,

 	hdrlen = create_syslog_header(dev, hdr, sizeof(hdr));

-	return vprintk_emit(0, level, hdrlen ? hdr : NULL, hdrlen, fmt, args);
+	return vprintk_emit(0, level, hdrlen ? hdr : NULL, hdrlen,
+				fmt, args, current_syslog_ns());
 }
 EXPORT_SYMBOL(dev_vprintk_emit);

diff --git a/include/linux/printk.h b/include/linux/printk.h
index 9afc01e..e0c60d9 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -7,6 +7,7 @@
 extern const char linux_banner[];
 extern const char linux_proc_banner[];

+struct syslog_namespace;
 static inline int printk_get_level(const char *buffer)
 {
 	if (buffer[0] == KERN_SOH_ASCII && buffer[1]) {
@@ -105,7 +106,8 @@ extern void printk_tick(void);
 asmlinkage __printf(5, 0)
 int vprintk_emit(int facility, int level,
 		 const char *dict, size_t dictlen,
-		 const char *fmt, va_list args);
+		 const char *fmt, va_list args,
+		 struct syslog_namespace *syslog_ns);

 asmlinkage __printf(1, 0)
 int vprintk(const char *fmt, va_list args);
diff --git a/kernel/printk.c b/kernel/printk.c
index 2d607f4..2ef9c46 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -42,6 +42,7 @@
 #include <linux/notifier.h>
 #include <linux/rculist.h>
 #include <linux/poll.h>
+#include <linux/syslog_namespace.h>

 #include <asm/uaccess.h>

@@ -214,46 +215,14 @@ struct log {
  * The logbuf_lock protects kmsg buffer, indices, counters. It is also
  * used in interesting ways to provide interlocking in console_unlock();
  */
-static DEFINE_RAW_SPINLOCK(logbuf_lock);

 #ifdef CONFIG_PRINTK
-/* the next printk record to read by syslog(READ) or /proc/kmsg */
-static u64 syslog_seq;
-static u32 syslog_idx;
-static enum log_flags syslog_prev;
-static size_t syslog_partial;
-
-/* index and sequence number of the first record stored in the buffer */
-static u64 log_first_seq;
-static u32 log_first_idx;
-
-/* index and sequence number of the next record to store in the buffer */
-static u64 log_next_seq;
-static u32 log_next_idx;

-/* the next printk record to write to the console */
-static u64 console_seq;
-static u32 console_idx;
 static enum log_flags console_prev;

-/* the next printk record to read after the last 'clear' command */
-static u64 clear_seq;
-static u32 clear_idx;
-
 #define PREFIX_MAX		32
 #define LOG_LINE_MAX		1024 - PREFIX_MAX

-/* record buffer */
-#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
-#define LOG_ALIGN 4
-#else
-#define LOG_ALIGN __alignof__(struct log)
-#endif
-#define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
-static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
-static char *log_buf = __log_buf;
-static u32 log_buf_len = __LOG_BUF_LEN;
-
 /* cpu currently holding logbuf_lock */
 static volatile unsigned int logbuf_cpu = UINT_MAX;

@@ -270,23 +239,23 @@ static char *log_dict(const struct log *msg)
 }

 /* get record by index; idx must point to valid msg */
-static struct log *log_from_idx(u32 idx)
+static struct log *log_from_idx(u32 idx, struct syslog_namespace *syslog_ns)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(syslog_ns->log_buf + idx);

 	/*
 	 * A length == 0 record is the end of buffer marker. Wrap around and
 	 * read the message at the start of the buffer.
 	 */
 	if (!msg->len)
-		return (struct log *)log_buf;
+		return (struct log *)syslog_ns->log_buf;
 	return msg;
 }

 /* get next record; idx must point to valid msg */
-static u32 log_next(u32 idx)
+static u32 log_next(u32 idx, struct syslog_namespace *syslog_ns)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(syslog_ns->log_buf + idx);

 	/* length == 0 indicates the end of the buffer; wrap */
 	/*
@@ -295,7 +264,7 @@ static u32 log_next(u32 idx)
 	 * return the one after that.
 	 */
 	if (!msg->len) {
-		msg = (struct log *)log_buf;
+		msg = (struct log *)syslog_ns->log_buf;
 		return msg->len;
 	}
 	return idx + msg->len;
@@ -305,7 +274,8 @@ static u32 log_next(u32 idx)
 static void log_store(int facility, int level,
 		      enum log_flags flags, u64 ts_nsec,
 		      const char *dict, u16 dict_len,
-		      const char *text, u16 text_len)
+		      const char *text, u16 text_len,
+		      struct syslog_namespace *syslog_ns)
 {
 	struct log *msg;
 	u32 size, pad_len;
@@ -315,34 +285,40 @@ static void log_store(int facility, int level,
 	pad_len = (-size) & (LOG_ALIGN - 1);
 	size += pad_len;

-	while (log_first_seq < log_next_seq) {
+	while (syslog_ns->log_first_seq < syslog_ns->log_next_seq) {
 		u32 free;

-		if (log_next_idx > log_first_idx)
-			free = max(log_buf_len - log_next_idx, log_first_idx);
+		if (syslog_ns->log_next_idx > syslog_ns->log_first_idx)
+			free = max(syslog_ns->log_buf_len -
+				 syslog_ns->log_next_idx,
+				 syslog_ns->log_first_idx);
 		else
-			free = log_first_idx - log_next_idx;
+			free = syslog_ns->log_first_idx -
+					 syslog_ns->log_next_idx;

 		if (free > size + sizeof(struct log))
 			break;

 		/* drop old messages until we have enough contiuous space */
-		log_first_idx = log_next(log_first_idx);
-		log_first_seq++;
+		syslog_ns->log_first_idx =
+				log_next(syslog_ns->log_first_idx, syslog_ns);
+		syslog_ns->log_first_seq++;
 	}

-	if (log_next_idx + size + sizeof(struct log) >= log_buf_len) {
+	if (syslog_ns->log_next_idx + size + sizeof(struct log) >=
+						 syslog_ns->log_buf_len) {
 		/*
 		 * This message + an additional empty header does not fit
 		 * at the end of the buffer. Add an empty header with len == 0
 		 * to signify a wrap around.
 		 */
-		memset(log_buf + log_next_idx, 0, sizeof(struct log));
-		log_next_idx = 0;
+		memset(syslog_ns->log_buf + syslog_ns->log_next_idx,
+						 0, sizeof(struct log));
+		syslog_ns->log_next_idx = 0;
 	}

 	/* fill message */
-	msg = (struct log *)(log_buf + log_next_idx);
+	msg = (struct log *)(syslog_ns->log_buf + syslog_ns->log_next_idx);
 	memcpy(log_text(msg), text, text_len);
 	msg->text_len = text_len;
 	memcpy(log_dict(msg), dict, dict_len);
@@ -358,8 +334,8 @@ static void log_store(int facility, int level,
 	msg->len = sizeof(struct log) + text_len + dict_len + pad_len;

 	/* insert message */
-	log_next_idx += msg->len;
-	log_next_seq++;
+	syslog_ns->log_next_idx += msg->len;
+	syslog_ns->log_next_seq++;
 }

 /* /dev/kmsg - userspace message inject/listen interface */
@@ -368,6 +344,7 @@ struct devkmsg_user {
 	u32 idx;
 	enum log_flags prev;
 	struct mutex lock;
+	struct syslog_namespace *syslog_ns;
 	char buf[8192];
 };

@@ -431,6 +408,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
 	struct devkmsg_user *user = file->private_data;
+	struct syslog_namespace *syslog_ns = user->syslog_ns;
 	struct log *msg;
 	u64 ts_usec;
 	size_t i;
@@ -444,32 +422,32 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	ret = mutex_lock_interruptible(&user->lock);
 	if (ret)
 		return ret;
-	raw_spin_lock_irq(&logbuf_lock);
-	while (user->seq == log_next_seq) {
+	raw_spin_lock_irq(&syslog_ns->logbuf_lock);
+	while (user->seq == syslog_ns->log_next_seq) {
 		if (file->f_flags & O_NONBLOCK) {
 			ret = -EAGAIN;
-			raw_spin_unlock_irq(&logbuf_lock);
+			raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 			goto out;
 		}

-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 		ret = wait_event_interruptible(log_wait,
-					       user->seq != log_next_seq);
+				user->seq != syslog_ns->log_next_seq);
 		if (ret)
 			goto out;
-		raw_spin_lock_irq(&logbuf_lock);
+		raw_spin_lock_irq(&syslog_ns->logbuf_lock);
 	}

-	if (user->seq < log_first_seq) {
+	if (user->seq < syslog_ns->log_first_seq) {
 		/* our last seen message is gone, return error and reset */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = syslog_ns->log_first_idx;
+		user->seq = syslog_ns->log_first_seq;
 		ret = -EPIPE;
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 		goto out;
 	}

-	msg = log_from_idx(user->idx);
+	msg = log_from_idx(user->idx, syslog_ns);
 	ts_usec = msg->ts_nsec;
 	do_div(ts_usec, 1000);

@@ -530,9 +508,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 		user->buf[len++] = '\n';
 	}

-	user->idx = log_next(user->idx);
+	user->idx = log_next(user->idx, syslog_ns);
 	user->seq++;
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&syslog_ns->logbuf_lock);

 	if (len > count) {
 		ret = -EINVAL;
@@ -552,6 +530,7 @@ out:
 static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct devkmsg_user *user = file->private_data;
+	struct syslog_namespace *syslog_ns = user->syslog_ns;
 	loff_t ret = 0;

 	if (!user)
@@ -559,12 +538,12 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 	if (offset)
 		return -ESPIPE;

-	raw_spin_lock_irq(&logbuf_lock);
+	raw_spin_lock_irq(&syslog_ns->logbuf_lock);
 	switch (whence) {
 	case SEEK_SET:
 		/* the first record */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = syslog_ns->log_first_idx;
+		user->seq = syslog_ns->log_first_seq;
 		break;
 	case SEEK_DATA:
 		/*
@@ -572,24 +551,25 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 		 * like issued by 'dmesg -c'. Reading /dev/kmsg itself
 		 * changes no global state, and does not clear anything.
 		 */
-		user->idx = clear_idx;
-		user->seq = clear_seq;
+		user->idx = syslog_ns->clear_idx;
+		user->seq = syslog_ns->clear_seq;
 		break;
 	case SEEK_END:
 		/* after the last record */
-		user->idx = log_next_idx;
-		user->seq = log_next_seq;
+		user->idx = syslog_ns->log_next_idx;
+		user->seq = syslog_ns->log_next_seq;
 		break;
 	default:
 		ret = -EINVAL;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 	return ret;
 }

 static unsigned int devkmsg_poll(struct file *file, poll_table *wait)
 {
 	struct devkmsg_user *user = file->private_data;
+	struct syslog_namespace *syslog_ns = user->syslog_ns;
 	int ret = 0;

 	if (!user)
@@ -597,20 +577,21 @@ static unsigned int devkmsg_poll(struct file *file, poll_table *wait)

 	poll_wait(file, &log_wait, wait);

-	raw_spin_lock_irq(&logbuf_lock);
-	if (user->seq < log_next_seq) {
+	raw_spin_lock_irq(&syslog_ns->logbuf_lock);
+	if (user->seq < syslog_ns->log_next_seq) {
 		/* return error when data has vanished underneath us */
-		if (user->seq < log_first_seq)
+		if (user->seq < syslog_ns->log_first_seq)
 			ret = POLLIN|POLLRDNORM|POLLERR|POLLPRI;
 		ret = POLLIN|POLLRDNORM;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&syslog_ns->logbuf_lock);

 	return ret;
 }

 static int devkmsg_open(struct inode *inode, struct file *file)
 {
+	struct syslog_namespace *syslog_ns;
 	struct devkmsg_user *user;
 	int err;

@@ -628,10 +609,11 @@ static int devkmsg_open(struct inode *inode, struct file *file)

 	mutex_init(&user->lock);

-	raw_spin_lock_irq(&logbuf_lock);
-	user->idx = log_first_idx;
-	user->seq = log_first_seq;
-	raw_spin_unlock_irq(&logbuf_lock);
+	user->syslog_ns = current_syslog_ns();
+	raw_spin_lock_irq(&syslog_ns->logbuf_lock);
+	user->idx = syslog_ns->log_first_idx;
+	user->seq = syslog_ns->log_first_seq;
+	raw_spin_unlock_irq(&syslog_ns->logbuf_lock);

 	file->private_data = user;
 	return 0;
@@ -669,10 +651,12 @@ const struct file_operations kmsg_fops = {
  */
 void log_buf_kexec_setup(void)
 {
-	VMCOREINFO_SYMBOL(log_buf);
-	VMCOREINFO_SYMBOL(log_buf_len);
-	VMCOREINFO_SYMBOL(log_first_idx);
-	VMCOREINFO_SYMBOL(log_next_idx);
+	struct syslog_namespace *syslog_ns = current_syslog_ns();
+
+	VMCOREINFO_SYMBOL(syslog_ns->log_buf);
+	VMCOREINFO_SYMBOL(syslog_ns->log_buf_len);
+	VMCOREINFO_SYMBOL(syslog_ns->log_first_idx);
+	VMCOREINFO_SYMBOL(syslog_ns->log_next_idx);
 	/*
 	 * Export struct log size and field offsets. User space tools can
 	 * parse it and detect any changes to structure down the line.
@@ -692,10 +676,11 @@ static unsigned long __initdata new_log_buf_len;
 static int __init log_buf_len_setup(char *str)
 {
 	unsigned size = memparse(str, &str);
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	if (size)
 		size = roundup_pow_of_two(size);
-	if (size > log_buf_len)
+	if (size > syslog_ns->log_buf_len)
 		new_log_buf_len = size;

 	return 0;
@@ -707,6 +692,7 @@ void __init setup_log_buf(int early)
 	unsigned long flags;
 	char *new_log_buf;
 	int free;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	if (!new_log_buf_len)
 		return;
@@ -728,15 +714,15 @@ void __init setup_log_buf(int early)
 		return;
 	}

-	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	log_buf_len = new_log_buf_len;
-	log_buf = new_log_buf;
+	raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+	memcpy(new_log_buf, syslog_ns->log_buf, __LOG_BUF_LEN);
+	syslog_ns->log_buf_len = new_log_buf_len;
+	syslog_ns->log_buf = new_log_buf;
 	new_log_buf_len = 0;
-	free = __LOG_BUF_LEN - log_next_idx;
-	memcpy(log_buf, __log_buf, __LOG_BUF_LEN);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	free = __LOG_BUF_LEN - syslog_ns->log_next_idx;
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);

-	pr_info("log_buf_len: %d\n", log_buf_len);
+	pr_info("log_buf_len: %d\n", syslog_ns->log_buf_len);
 	pr_info("early log buf free: %d(%d%%)\n",
 		free, (free * 100) / __LOG_BUF_LEN);
 }
@@ -937,7 +923,8 @@ static size_t msg_print_text(const struct log *msg, enum log_flags prev,
 	return len;
 }

-static int syslog_print(char __user *buf, int size)
+static int syslog_print(char __user *buf, int size,
+			 struct syslog_namespace *syslog_ns)
 {
 	char *text;
 	struct log *msg;
@@ -951,37 +938,38 @@ static int syslog_print(char __user *buf, int size)
 		size_t n;
 		size_t skip;

-		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		raw_spin_lock_irq(&syslog_ns->logbuf_lock);
+		if (syslog_ns->syslog_seq < syslog_ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			syslog_ns->syslog_seq = syslog_ns->log_first_seq;
+			syslog_ns->syslog_idx = syslog_ns->log_first_idx;
+			syslog_ns->syslog_prev = 0;
+			syslog_ns->syslog_partial = 0;
 		}
-		if (syslog_seq == log_next_seq) {
-			raw_spin_unlock_irq(&logbuf_lock);
+		if (syslog_ns->syslog_seq == syslog_ns->log_next_seq) {
+			raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 			break;
 		}

-		skip = syslog_partial;
-		msg = log_from_idx(syslog_idx);
-		n = msg_print_text(msg, syslog_prev, true, text,
+		skip = syslog_ns->syslog_partial;
+		msg = log_from_idx(syslog_ns->syslog_idx, syslog_ns);
+		n = msg_print_text(msg, syslog_ns->syslog_prev, true, text,
 				   LOG_LINE_MAX + PREFIX_MAX);
-		if (n - syslog_partial <= size) {
+		if (n - syslog_ns->syslog_partial <= size) {
 			/* message fits into buffer, move forward */
-			syslog_idx = log_next(syslog_idx);
-			syslog_seq++;
-			syslog_prev = msg->flags;
-			n -= syslog_partial;
-			syslog_partial = 0;
+			syslog_ns->syslog_idx =
+				log_next(syslog_ns->syslog_idx, syslog_ns);
+			syslog_ns->syslog_seq++;
+			syslog_ns->syslog_prev = msg->flags;
+			n -= syslog_ns->syslog_partial;
+			syslog_ns->syslog_partial = 0;
 		} else if (!len){
 			/* partial read(), remember position */
 			n = size;
-			syslog_partial += n;
+			syslog_ns->syslog_partial += n;
 		} else
 			n = 0;
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&syslog_ns->logbuf_lock);

 		if (!n)
 			break;
@@ -1001,7 +989,8 @@ static int syslog_print(char __user *buf, int size)
 	return len;
 }

-static int syslog_print_all(char __user *buf, int size, bool clear)
+static int syslog_print_all(char __user *buf, int size, bool clear,
+				struct syslog_namespace *syslog_ns)
 {
 	char *text;
 	int len = 0;
@@ -1010,55 +999,55 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 	if (!text)
 		return -ENOMEM;

-	raw_spin_lock_irq(&logbuf_lock);
+	raw_spin_lock_irq(&syslog_ns->logbuf_lock);
 	if (buf) {
 		u64 next_seq;
 		u64 seq;
 		u32 idx;
 		enum log_flags prev;

-		if (clear_seq < log_first_seq) {
+		if (syslog_ns->clear_seq < syslog_ns->log_first_seq) {
 			/* messages are gone, move to first available one */
-			clear_seq = log_first_seq;
-			clear_idx = log_first_idx;
+			syslog_ns->clear_seq = syslog_ns->log_first_seq;
+			syslog_ns->clear_idx = syslog_ns->log_first_idx;
 		}

 		/*
 		 * Find first record that fits, including all following records,
 		 * into the user-provided buffer for this dump.
 		 */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = syslog_ns->clear_seq;
+		idx = syslog_ns->clear_idx;
 		prev = 0;
-		while (seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (seq < syslog_ns->log_next_seq) {
+			struct log *msg = log_from_idx(idx, syslog_ns);

 			len += msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(idx, syslog_ns);
 			seq++;
 		}

 		/* move first record forward until length fits into the buffer */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = syslog_ns->clear_seq;
+		idx = syslog_ns->clear_idx;
 		prev = 0;
-		while (len > size && seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (len > size && seq < syslog_ns->log_next_seq) {
+			struct log *msg = log_from_idx(idx, syslog_ns);

 			len -= msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(idx, syslog_ns);
 			seq++;
 		}

 		/* last message fitting into this dump */
-		next_seq = log_next_seq;
+		next_seq = syslog_ns->log_next_seq;

 		len = 0;
 		prev = 0;
 		while (len >= 0 && seq < next_seq) {
-			struct log *msg = log_from_idx(idx);
+			struct log *msg = log_from_idx(idx, syslog_ns);
 			int textlen;

 			textlen = msg_print_text(msg, prev, true, text,
@@ -1067,31 +1056,31 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 				len = textlen;
 				break;
 			}
-			idx = log_next(idx);
+			idx = log_next(idx, syslog_ns);
 			seq++;
 			prev = msg->flags;

-			raw_spin_unlock_irq(&logbuf_lock);
+			raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 			if (copy_to_user(buf + len, text, textlen))
 				len = -EFAULT;
 			else
 				len += textlen;
-			raw_spin_lock_irq(&logbuf_lock);
+			raw_spin_lock_irq(&syslog_ns->logbuf_lock);

-			if (seq < log_first_seq) {
+			if (seq < syslog_ns->log_first_seq) {
 				/* messages are gone, move to next one */
-				seq = log_first_seq;
-				idx = log_first_idx;
+				seq = syslog_ns->log_first_seq;
+				idx = syslog_ns->log_first_idx;
 				prev = 0;
 			}
 		}
 	}

 	if (clear) {
-		clear_seq = log_next_seq;
-		clear_idx = log_next_idx;
+		syslog_ns->clear_seq = syslog_ns->log_next_seq;
+		syslog_ns->clear_idx = syslog_ns->log_next_idx;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&syslog_ns->logbuf_lock);

 	kfree(text);
 	return len;
@@ -1102,6 +1091,7 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 	bool clear = false;
 	static int saved_console_loglevel = -1;
 	int error;
+	struct syslog_namespace *syslog_ns = current_syslog_ns();

 	error = check_syslog_permissions(type, from_file);
 	if (error)
@@ -1128,10 +1118,10 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			goto out;
 		}
 		error = wait_event_interruptible(log_wait,
-						 syslog_seq != log_next_seq);
+			syslog_ns->syslog_seq != syslog_ns->log_next_seq);
 		if (error)
 			goto out;
-		error = syslog_print(buf, len);
+		error = syslog_print(buf, len, syslog_ns);
 		break;
 	/* Read/clear last kernel messages */
 	case SYSLOG_ACTION_READ_CLEAR:
@@ -1149,11 +1139,11 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			error = -EFAULT;
 			goto out;
 		}
-		error = syslog_print_all(buf, len, clear);
+		error = syslog_print_all(buf, len, clear, syslog_ns);
 		break;
 	/* Clear ring buffer */
 	case SYSLOG_ACTION_CLEAR:
-		syslog_print_all(NULL, 0, true);
+		syslog_print_all(NULL, 0, true, syslog_ns);
 		break;
 	/* Disable logging to console */
 	case SYSLOG_ACTION_CONSOLE_OFF:
@@ -1182,13 +1172,13 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 		break;
 	/* Number of chars in the log buffer */
 	case SYSLOG_ACTION_SIZE_UNREAD:
-		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		raw_spin_lock_irq(&syslog_ns->logbuf_lock);
+		if (syslog_ns->syslog_seq < syslog_ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			syslog_ns->syslog_seq = syslog_ns->log_first_seq;
+			syslog_ns->syslog_idx = syslog_ns->log_first_idx;
+			syslog_ns->syslog_prev = 0;
+			syslog_ns->syslog_partial = 0;
 		}
 		if (from_file) {
 			/*
@@ -1196,28 +1186,28 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			 * for pending data, not the size; return the count of
 			 * records, not the length.
 			 */
-			error = log_next_idx - syslog_idx;
+			error = syslog_ns->log_next_idx - syslog_ns->syslog_idx;
 		} else {
-			u64 seq = syslog_seq;
-			u32 idx = syslog_idx;
-			enum log_flags prev = syslog_prev;
+			u64 seq = syslog_ns->syslog_seq;
+			u32 idx = syslog_ns->syslog_idx;
+			enum log_flags prev = syslog_ns->syslog_prev;

 			error = 0;
-			while (seq < log_next_seq) {
-				struct log *msg = log_from_idx(idx);
+			while (seq < syslog_ns->log_next_seq) {
+				struct log *msg = log_from_idx(idx, syslog_ns);

 				error += msg_print_text(msg, prev, true, NULL, 0);
-				idx = log_next(idx);
+				idx = log_next(idx, syslog_ns);
 				seq++;
 				prev = msg->flags;
 			}
-			error -= syslog_partial;
+			error -= syslog_ns->syslog_partial;
 		}
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&syslog_ns->logbuf_lock);
 		break;
 	/* Size of the log buffer */
 	case SYSLOG_ACTION_SIZE_BUFFER:
-		error = log_buf_len;
+		error = syslog_ns->log_buf_len;
 		break;
 	default:
 		error = -EINVAL;
@@ -1282,7 +1272,7 @@ static void call_console_drivers(int level, const char *text, size_t len)
  * every 10 seconds, to leave time for slow consoles to print a
  * full oops.
  */
-static void zap_locks(void)
+static void zap_locks(struct syslog_namespace *syslog_ns)
 {
 	static unsigned long oops_timestamp;

@@ -1294,7 +1284,7 @@ static void zap_locks(void)

 	debug_locks_off();
 	/* If a crash is occurring, make sure we can't deadlock */
-	raw_spin_lock_init(&logbuf_lock);
+	raw_spin_lock_init(&syslog_ns->logbuf_lock);
 	/* And make sure that we print immediately */
 	sema_init(&console_sem, 1);
 }
@@ -1334,8 +1324,9 @@ static inline int can_use_console(unsigned int cpu)
  * interrupts disabled. It should return with 'lockbuf_lock'
  * released but interrupts still disabled.
  */
-static int console_trylock_for_printk(unsigned int cpu)
-	__releases(&logbuf_lock)
+static int console_trylock_for_printk(unsigned int cpu,
+			 struct syslog_namespace *syslog_ns)
+	__releases(&syslog_ns->logbuf_lock)
 {
 	int retval = 0, wake = 0;

@@ -1357,7 +1348,7 @@ static int console_trylock_for_printk(unsigned int cpu)
 	logbuf_cpu = UINT_MAX;
 	if (wake)
 		up(&console_sem);
-	raw_spin_unlock(&logbuf_lock);
+	raw_spin_unlock(&syslog_ns->logbuf_lock);
 	return retval;
 }

@@ -1393,7 +1384,7 @@ static struct cont {
 	bool flushed:1;			/* buffer sealed and committed */
 } cont;

-static void cont_flush(enum log_flags flags)
+static void cont_flush(enum log_flags flags, struct syslog_namespace *syslog_ns)
 {
 	if (cont.flushed)
 		return;
@@ -1407,7 +1398,7 @@ static void cont_flush(enum log_flags flags)
 		 * line. LOG_NOCONS suppresses a duplicated output.
 		 */
 		log_store(cont.facility, cont.level, flags | LOG_NOCONS,
-			  cont.ts_nsec, NULL, 0, cont.buf, cont.len);
+			  cont.ts_nsec, NULL, 0, cont.buf, cont.len, syslog_ns);
 		cont.flags = flags;
 		cont.flushed = true;
 	} else {
@@ -1416,19 +1407,20 @@ static void cont_flush(enum log_flags flags)
 		 * just submit it to the store and free the buffer.
 		 */
 		log_store(cont.facility, cont.level, flags, 0,
-			  NULL, 0, cont.buf, cont.len);
+			  NULL, 0, cont.buf, cont.len, syslog_ns);
 		cont.len = 0;
 	}
 }

-static bool cont_add(int facility, int level, const char *text, size_t len)
+static bool cont_add(int facility, int level, const char *text, size_t len,
+					struct syslog_namespace *syslog_ns)
 {
 	if (cont.len && cont.flushed)
 		return false;

 	if (cont.len + len > sizeof(cont.buf)) {
 		/* the line gets too long, split it up in separate records */
-		cont_flush(LOG_CONT);
+		cont_flush(LOG_CONT, syslog_ns);
 		return false;
 	}

@@ -1446,7 +1438,7 @@ static bool cont_add(int facility, int level, const char *text, size_t len)
 	cont.len += len;

 	if (cont.len > (sizeof(cont.buf) * 80) / 100)
-		cont_flush(LOG_CONT);
+		cont_flush(LOG_CONT, syslog_ns);

 	return true;
 }
@@ -1481,7 +1473,8 @@ static size_t cont_print_text(char *text, size_t size)

 asmlinkage int vprintk_emit(int facility, int level,
 			    const char *dict, size_t dictlen,
-			    const char *fmt, va_list args)
+			    const char *fmt, va_list args,
+			    struct syslog_namespace *syslog_ns)
 {
 	static int recursion_bug;
 	static char textbuf[LOG_LINE_MAX];
@@ -1514,11 +1507,11 @@ asmlinkage int vprintk_emit(int facility, int level,
 			recursion_bug = 1;
 			goto out_restore_irqs;
 		}
-		zap_locks();
+		zap_locks(syslog_ns);
 	}

 	lockdep_off();
-	raw_spin_lock(&logbuf_lock);
+	raw_spin_lock(&syslog_ns->logbuf_lock);
 	logbuf_cpu = this_cpu;

 	if (recursion_bug) {
@@ -1529,7 +1522,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 		printed_len += strlen(recursion_msg);
 		/* emit KERN_CRIT message */
 		log_store(0, 2, LOG_PREFIX|LOG_NEWLINE, 0,
-			  NULL, 0, recursion_msg, printed_len);
+			  NULL, 0, recursion_msg, printed_len, syslog_ns);
 	}

 	/*
@@ -1576,12 +1569,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 * or another task also prints continuation lines.
 		 */
 		if (cont.len && (lflags & LOG_PREFIX || cont.owner != current))
-			cont_flush(LOG_NEWLINE);
+			cont_flush(LOG_NEWLINE, syslog_ns);

 		/* buffer line if possible, otherwise store it right away */
-		if (!cont_add(facility, level, text, text_len))
+		if (!cont_add(facility, level, text, text_len, syslog_ns))
 			log_store(facility, level, lflags | LOG_CONT, 0,
-				  dict, dictlen, text, text_len);
+				  dict, dictlen, text, text_len, syslog_ns);
 	} else {
 		bool stored = false;

@@ -1593,13 +1586,14 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (cont.len && cont.owner == current) {
 			if (!(lflags & LOG_PREFIX))
-				stored = cont_add(facility, level, text, text_len);
-			cont_flush(LOG_NEWLINE);
+				stored = cont_add(facility, level, text,
+							 text_len, syslog_ns);
+			cont_flush(LOG_NEWLINE, syslog_ns);
 		}

 		if (!stored)
 			log_store(facility, level, lflags, 0,
-				  dict, dictlen, text, text_len);
+				  dict, dictlen, text, text_len, syslog_ns);
 	}
 	printed_len += text_len;

@@ -1611,7 +1605,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 	 * The console_trylock_for_printk() function will release 'logbuf_lock'
 	 * regardless of whether it actually gets the console semaphore or not.
 	 */
-	if (console_trylock_for_printk(this_cpu))
+	if (console_trylock_for_printk(this_cpu, syslog_ns))
 		console_unlock();

 	lockdep_on();
@@ -1624,7 +1618,8 @@ EXPORT_SYMBOL(vprintk_emit);

 asmlinkage int vprintk(const char *fmt, va_list args)
 {
-	return vprintk_emit(0, -1, NULL, 0, fmt, args);
+	return vprintk_emit(0, -1, NULL, 0, fmt, args,
+				current_syslog_ns());
 }
 EXPORT_SYMBOL(vprintk);

@@ -1636,7 +1631,8 @@ asmlinkage int printk_emit(int facility, int level,
 	int r;

 	va_start(args, fmt);
-	r = vprintk_emit(facility, level, dict, dictlen, fmt, args);
+	r = vprintk_emit(facility, level, dict, dictlen, fmt, args,
+						current_syslog_ns());
 	va_end(args);

 	return r;
@@ -1678,7 +1674,7 @@ asmlinkage int printk(const char *fmt, ...)
 	}
 #endif
 	va_start(args, fmt);
-	r = vprintk_emit(0, -1, NULL, 0, fmt, args);
+	r = vprintk_emit(0, -1, NULL, 0, fmt, args, current_syslog_ns());
 	va_end(args);

 	return r;
@@ -1981,12 +1977,13 @@ void wake_up_klogd(void)
 		this_cpu_or(printk_pending, PRINTK_PENDING_WAKEUP);
 }

-static void console_cont_flush(char *text, size_t size)
+static void console_cont_flush(char *text, size_t size,
+			 struct syslog_namespace *syslog_ns)
 {
 	unsigned long flags;
 	size_t len;

-	raw_spin_lock_irqsave(&logbuf_lock, flags);
+	raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);

 	if (!cont.len)
 		goto out;
@@ -1996,18 +1993,131 @@ static void console_cont_flush(char *text, size_t size)
 	 * busy. The earlier ones need to be printed before this one, we
 	 * did not flush any fragment so far, so just let it queue up.
 	 */
-	if (console_seq < log_next_seq && !cont.cons)
+	if (syslog_ns->console_seq < syslog_ns->log_next_seq && !cont.cons)
 		goto out;

 	len = cont_print_text(text, size);
-	raw_spin_unlock(&logbuf_lock);
+	raw_spin_unlock(&syslog_ns->logbuf_lock);
 	stop_critical_timings();
 	call_console_drivers(cont.level, text, len);
 	start_critical_timings();
 	local_irq_restore(flags);
 	return;
 out:
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
+}
+
+/**
+ * syslog_console_unlock - unlock the console system for syslog_namespace
+ *
+ * Releases the console_lock which the caller holds on the console system
+ * and the console driver list.
+ *
+ * While the console_lock was held, console output may have been buffered
+ * by printk().  If this is the case, syslog_console_unlock(); emits
+ * the output prior to releasing the lock.
+ *
+ * If there is output waiting, we wake /dev/kmsg and syslog() users.
+ *
+ * syslog_console_unlock(); may be called from any context.
+ */
+void syslog_console_unlock(struct syslog_namespace *syslog_ns)
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
+	console_cont_flush(text, sizeof(text), syslog_ns);
+again:
+	for (;;) {
+		struct log *msg;
+		size_t len;
+		int level;
+
+		raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+		if (seen_seq != syslog_ns->log_next_seq) {
+			wake_klogd = true;
+			seen_seq = syslog_ns->log_next_seq;
+		}
+
+		if (syslog_ns->console_seq < syslog_ns->log_first_seq) {
+			/* messages are gone, move to first one */
+			syslog_ns->console_seq = syslog_ns->log_first_seq;
+			syslog_ns->console_idx = syslog_ns->log_first_idx;
+			console_prev = 0;
+		}
+skip:
+		if (syslog_ns->console_seq == syslog_ns->log_next_seq)
+			break;
+
+		msg = log_from_idx(syslog_ns->console_idx, syslog_ns);
+		if (msg->flags & LOG_NOCONS) {
+			/*
+			 * Skip record we have buffered and already printed
+			 * directly to the console when we received it.
+			 */
+			syslog_ns->console_idx =
+				log_next(syslog_ns->console_idx, syslog_ns);
+			syslog_ns->console_seq++;
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
+				     text, sizeof(text));
+		syslog_ns->console_idx =
+			 log_next(syslog_ns->console_idx, syslog_ns);
+		syslog_ns->console_seq++;
+		console_prev = msg->flags;
+		raw_spin_unlock(&syslog_ns->logbuf_lock);
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
+	raw_spin_unlock(&syslog_ns->logbuf_lock);
+
+	up(&console_sem);
+
+	/*
+	 * Someone could have filled up the buffer again, so re-check if there's
+	 * something to flush. In case we cannot trylock the console_sem again,
+	 * there's a new owner and the console_unlock() from them will do the
+	 * flush, no worries.
+	 */
+	raw_spin_lock(&syslog_ns->logbuf_lock);
+	retry = syslog_ns->console_seq != syslog_ns->log_next_seq;
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
+
+	if (retry && console_trylock())
+		goto again;
+
+	if (wake_klogd)
+		wake_up_klogd();
 }

 /**
@@ -2027,6 +2137,7 @@ out:
 void console_unlock(void)
 {
 	static char text[LOG_LINE_MAX + PREFIX_MAX];
+	struct syslog_namespace *syslog_ns = current_syslog_ns();
 	static u64 seen_seq;
 	unsigned long flags;
 	bool wake_klogd = false;
@@ -2040,37 +2151,38 @@ void console_unlock(void)
 	console_may_schedule = 0;

 	/* flush buffered message fragment immediately to console */
-	console_cont_flush(text, sizeof(text));
+	console_cont_flush(text, sizeof(text), syslog_ns);
 again:
 	for (;;) {
 		struct log *msg;
 		size_t len;
 		int level;

-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		if (seen_seq != log_next_seq) {
+		raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+		if (seen_seq != syslog_ns->log_next_seq) {
 			wake_klogd = true;
-			seen_seq = log_next_seq;
+			seen_seq = syslog_ns->log_next_seq;
 		}

-		if (console_seq < log_first_seq) {
+		if (syslog_ns->console_seq < syslog_ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			console_seq = log_first_seq;
-			console_idx = log_first_idx;
+			syslog_ns->console_seq = syslog_ns->log_first_seq;
+			syslog_ns->console_idx = syslog_ns->log_first_idx;
 			console_prev = 0;
 		}
 skip:
-		if (console_seq == log_next_seq)
+		if (syslog_ns->console_seq == syslog_ns->log_next_seq)
 			break;

-		msg = log_from_idx(console_idx);
+		msg = log_from_idx(syslog_ns->console_idx, syslog_ns);
 		if (msg->flags & LOG_NOCONS) {
 			/*
 			 * Skip record we have buffered and already printed
 			 * directly to the console when we received it.
 			 */
-			console_idx = log_next(console_idx);
-			console_seq++;
+			syslog_ns->console_idx =
+				 log_next(syslog_ns->console_idx, syslog_ns);
+			syslog_ns->console_seq++;
 			/*
 			 * We will get here again when we register a new
 			 * CON_PRINTBUFFER console. Clear the flag so we
@@ -2084,10 +2196,11 @@ skip:
 		level = msg->level;
 		len = msg_print_text(msg, console_prev, false,
 				     text, sizeof(text));
-		console_idx = log_next(console_idx);
-		console_seq++;
+		syslog_ns->console_idx =
+			 log_next(syslog_ns->console_idx, syslog_ns);
+		syslog_ns->console_seq++;
 		console_prev = msg->flags;
-		raw_spin_unlock(&logbuf_lock);
+		raw_spin_unlock(&syslog_ns->logbuf_lock);

 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(level, text, len);
@@ -2100,7 +2213,7 @@ skip:
 	if (unlikely(exclusive_console))
 		exclusive_console = NULL;

-	raw_spin_unlock(&logbuf_lock);
+	raw_spin_unlock(&syslog_ns->logbuf_lock);

 	up(&console_sem);

@@ -2110,9 +2223,9 @@ skip:
 	 * there's a new owner and the console_unlock() from them will do the
 	 * flush, no worries.
 	 */
-	raw_spin_lock(&logbuf_lock);
-	retry = console_seq != log_next_seq;
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_lock(&syslog_ns->logbuf_lock);
+	retry = syslog_ns->console_seq != syslog_ns->log_next_seq;
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);

 	if (retry && console_trylock())
 		goto again;
@@ -2237,6 +2350,7 @@ void register_console(struct console *newcon)
 	int i;
 	unsigned long flags;
 	struct console *bcon = NULL;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	/*
 	 * before we register a new CON_BOOT console, make sure we don't
@@ -2346,11 +2460,11 @@ void register_console(struct console *newcon)
 		 * console_unlock(); will print out the buffered messages
 		 * for us.
 		 */
-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		console_seq = syslog_seq;
-		console_idx = syslog_idx;
-		console_prev = syslog_prev;
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+		syslog_ns->console_seq = syslog_ns->syslog_seq;
+		syslog_ns->console_idx = syslog_ns->syslog_idx;
+		console_prev = syslog_ns->syslog_prev;
+		raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
 		/*
 		 * We're about to replay the log buffer.  Only do this to the
 		 * just-registered console to avoid excessive message spam to
@@ -2573,6 +2687,7 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 {
 	struct kmsg_dumper *dumper;
 	unsigned long flags;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	if ((reason > KMSG_DUMP_OOPS) && !always_kmsg_dump)
 		return;
@@ -2585,12 +2700,12 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 		/* initialize iterator with data about the stored records */
 		dumper->active = true;

-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		dumper->cur_seq = clear_seq;
-		dumper->cur_idx = clear_idx;
-		dumper->next_seq = log_next_seq;
-		dumper->next_idx = log_next_idx;
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+		dumper->cur_seq = syslog_ns->clear_seq;
+		dumper->cur_idx = syslog_ns->clear_idx;
+		dumper->next_seq = syslog_ns->log_next_seq;
+		dumper->next_idx = syslog_ns->log_next_idx;
+		raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);

 		/* invoke dumper which will iterate over records */
 		dumper->dump(dumper, reason);
@@ -2626,24 +2741,25 @@ bool kmsg_dump_get_line_nolock(struct kmsg_dumper *dumper, bool syslog,
 	struct log *msg;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	if (!dumper->active)
 		goto out;

-	if (dumper->cur_seq < log_first_seq) {
+	if (dumper->cur_seq < syslog_ns->log_first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = syslog_ns->log_first_seq;
+		dumper->cur_idx = syslog_ns->log_first_idx;
 	}

 	/* last entry */
-	if (dumper->cur_seq >= log_next_seq)
+	if (dumper->cur_seq >= syslog_ns->log_next_seq)
 		goto out;

-	msg = log_from_idx(dumper->cur_idx);
+	msg = log_from_idx(dumper->cur_idx, syslog_ns);
 	l = msg_print_text(msg, 0, syslog, line, size);

-	dumper->cur_idx = log_next(dumper->cur_idx);
+	dumper->cur_idx = log_next(dumper->cur_idx, syslog_ns);
 	dumper->cur_seq++;
 	ret = true;
 out:
@@ -2674,10 +2790,12 @@ bool kmsg_dump_get_line(struct kmsg_dumper *dumper, bool syslog,
 {
 	unsigned long flags;
 	bool ret;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;
+
+	raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);

-	raw_spin_lock_irqsave(&logbuf_lock, flags);
 	ret = kmsg_dump_get_line_nolock(dumper, syslog, line, size, len);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);

 	return ret;
 }
@@ -2713,20 +2831,21 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	enum log_flags prev;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;

 	if (!dumper->active)
 		goto out;

-	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	if (dumper->cur_seq < log_first_seq) {
+	raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);
+	if (dumper->cur_seq < syslog_ns->log_first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = syslog_ns->log_first_seq;
+		dumper->cur_idx = syslog_ns->log_first_idx;
 	}

 	/* last entry */
 	if (dumper->cur_seq >= dumper->next_seq) {
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
 		goto out;
 	}

@@ -2735,10 +2854,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, syslog_ns);

 		l += msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(idx, syslog_ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2748,10 +2867,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (l > size && seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, syslog_ns);

 		l -= msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(idx, syslog_ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2763,10 +2882,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	l = 0;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, syslog_ns);

 		l += msg_print_text(msg, prev, syslog, buf + l, size - l);
-		idx = log_next(idx);
+		idx = log_next(idx, syslog_ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2774,7 +2893,7 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	dumper->next_seq = next_seq;
 	dumper->next_idx = next_idx;
 	ret = true;
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
 out:
 	if (len)
 		*len = l;
@@ -2794,10 +2913,12 @@ EXPORT_SYMBOL_GPL(kmsg_dump_get_buffer);
  */
 void kmsg_dump_rewind_nolock(struct kmsg_dumper *dumper)
 {
-	dumper->cur_seq = clear_seq;
-	dumper->cur_idx = clear_idx;
-	dumper->next_seq = log_next_seq;
-	dumper->next_idx = log_next_idx;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;
+
+	dumper->cur_seq = syslog_ns->clear_seq;
+	dumper->cur_idx = syslog_ns->clear_idx;
+	dumper->next_seq = syslog_ns->log_next_seq;
+	dumper->next_idx = syslog_ns->log_next_idx;
 }

 /**
@@ -2811,10 +2932,12 @@ void kmsg_dump_rewind_nolock(struct kmsg_dumper *dumper)
 void kmsg_dump_rewind(struct kmsg_dumper *dumper)
 {
 	unsigned long flags;
+	struct syslog_namespace *syslog_ns = &init_syslog_ns;
+
+	raw_spin_lock_irqsave(&syslog_ns->logbuf_lock, flags);

-	raw_spin_lock_irqsave(&logbuf_lock, flags);
 	kmsg_dump_rewind_nolock(dumper);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&syslog_ns->logbuf_lock, flags);
 }
 EXPORT_SYMBOL_GPL(kmsg_dump_rewind);
 #endif
-- 
1.7.1
