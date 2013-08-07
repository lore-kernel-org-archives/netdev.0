From: Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH v3 04/11] syslog_ns: make syslog handling per namespace
Date: Wed, 7 Aug 2013 15:37:08 +0800
Message-ID: <1375861035-24320-5-git-send-email-rui.xiang@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:44979 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331Ab3HGHiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 03:38:07 -0400
In-Reply-To: <1375861035-24320-1-git-send-email-rui.xiang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes syslog buf and other fields per
namespace.

Here use ns->log_buf(log_buf_len, logbuf_lock,
log_first_seq, logbuf_lock, and so on) fields
instead of global ones to handle syslog.

Syslog interfaces such as /dev/kmsg, /proc/kmsg,
and syslog syscall are all containerized for
container users.

Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
---
 fs/proc/kmsg.c         |  17 +-
 include/linux/printk.h |   1 -
 include/linux/syslog.h |   3 +-
 kernel/printk.c        | 513 +++++++++++++++++++++++++------------------------
 kernel/sysctl.c        |   3 +-
 5 files changed, 273 insertions(+), 264 deletions(-)

diff --git a/fs/proc/kmsg.c b/fs/proc/kmsg.c
index bdfabda..cb98431 100644
--- a/fs/proc/kmsg.c
+++ b/fs/proc/kmsg.c
@@ -13,6 +13,8 @@
 #include <linux/proc_fs.h>
 #include <linux/fs.h>
 #include <linux/syslog.h>
+#include <linux/cred.h>
+#include <linux/user_namespace.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -21,12 +23,14 @@ extern wait_queue_head_t log_wait;
 
 static int kmsg_open(struct inode * inode, struct file * file)
 {
-	return do_syslog(SYSLOG_ACTION_OPEN, NULL, 0, SYSLOG_FROM_PROC);
+	return do_syslog(SYSLOG_ACTION_OPEN, NULL, 0, SYSLOG_FROM_PROC,
+				file->f_cred->user_ns->syslog_ns);
 }
 
 static int kmsg_release(struct inode * inode, struct file * file)
 {
-	(void) do_syslog(SYSLOG_ACTION_CLOSE, NULL, 0, SYSLOG_FROM_PROC);
+	(void) do_syslog(SYSLOG_ACTION_CLOSE, NULL, 0, SYSLOG_FROM_PROC,
+				file->f_cred->user_ns->syslog_ns);
 	return 0;
 }
 
@@ -34,15 +38,18 @@ static ssize_t kmsg_read(struct file *file, char __user *buf,
 			 size_t count, loff_t *ppos)
 {
 	if ((file->f_flags & O_NONBLOCK) &&
-	    !do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_PROC))
+	    !do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_PROC,
+					file->f_cred->user_ns->syslog_ns))
 		return -EAGAIN;
-	return do_syslog(SYSLOG_ACTION_READ, buf, count, SYSLOG_FROM_PROC);
+	return do_syslog(SYSLOG_ACTION_READ, buf, count, SYSLOG_FROM_PROC,
+					file->f_cred->user_ns->syslog_ns);
 }
 
 static unsigned int kmsg_poll(struct file *file, poll_table *wait)
 {
 	poll_wait(file, &log_wait, wait);
-	if (do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_PROC))
+	if (do_syslog(SYSLOG_ACTION_SIZE_UNREAD, NULL, 0, SYSLOG_FROM_PROC,
+					file->f_cred->user_ns->syslog_ns))
 		return POLLIN | POLLRDNORM;
 	return 0;
 }
diff --git a/include/linux/printk.h b/include/linux/printk.h
index 22c7052..29e3f85 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -139,7 +139,6 @@ extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
 				   unsigned int interval_msec);
 
 extern int printk_delay_msec;
-extern int dmesg_restrict;
 extern int kptr_restrict;
 
 extern void wake_up_klogd(void);
diff --git a/include/linux/syslog.h b/include/linux/syslog.h
index 363bc56..fbf0cb6 100644
--- a/include/linux/syslog.h
+++ b/include/linux/syslog.h
@@ -120,7 +120,8 @@ static inline void put_syslog_ns(struct syslog_namespace *ns)
 		kref_put(&ns->kref, free_syslog_ns);
 }
 
-int do_syslog(int type, char __user *buf, int count, bool from_file);
+int do_syslog(int type, char __user *buf, int count, bool from_file,
+				struct syslog_namespace *ns);
 
 extern struct syslog_namespace init_syslog_ns;
 #endif /* _LINUX_SYSLOG_H */
diff --git a/kernel/printk.c b/kernel/printk.c
index f288934..e508ab2 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -205,37 +205,10 @@ struct log {
 	u8 level:3;		/* syslog level */
 };
 
-/*
- * The logbuf_lock protects kmsg buffer, indices, counters. It is also
- * used in interesting ways to provide interlocking in console_unlock();
- */
-static DEFINE_RAW_SPINLOCK(logbuf_lock);
-
 #ifdef CONFIG_PRINTK
 DECLARE_WAIT_QUEUE_HEAD(log_wait);
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
-
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
 
@@ -246,12 +219,8 @@ static u32 clear_idx;
 #define LOG_ALIGN __alignof__(struct log)
 #endif
 #define __LOG_BUF_LEN (1 << CONFIG_LOG_BUF_SHIFT)
+/* this buf only for init_syslog_ns */
 static char __log_buf[__LOG_BUF_LEN] __aligned(LOG_ALIGN);
-static char *log_buf = __log_buf;
-static u32 log_buf_len = __LOG_BUF_LEN;
-
-/* cpu currently holding logbuf_lock */
-static volatile unsigned int logbuf_cpu = UINT_MAX;
 
 struct syslog_namespace init_syslog_ns = {
 	.kref = {
@@ -282,23 +251,23 @@ static char *log_dict(const struct log *msg)
 }
 
 /* get record by index; idx must point to valid msg */
-static struct log *log_from_idx(u32 idx)
+static struct log *log_from_idx(u32 idx, struct syslog_namespace *ns)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(ns->log_buf + idx);
 
 	/*
 	 * A length == 0 record is the end of buffer marker. Wrap around and
 	 * read the message at the start of the buffer.
 	 */
 	if (!msg->len)
-		return (struct log *)log_buf;
+		return (struct log *)ns->log_buf;
 	return msg;
 }
 
 /* get next record; idx must point to valid msg */
-static u32 log_next(u32 idx)
+static u32 log_next(u32 idx, struct syslog_namespace *ns)
 {
-	struct log *msg = (struct log *)(log_buf + idx);
+	struct log *msg = (struct log *)(ns->log_buf + idx);
 
 	/* length == 0 indicates the end of the buffer; wrap */
 	/*
@@ -307,7 +276,7 @@ static u32 log_next(u32 idx)
 	 * return the one after that.
 	 */
 	if (!msg->len) {
-		msg = (struct log *)log_buf;
+		msg = (struct log *)ns->log_buf;
 		return msg->len;
 	}
 	return idx + msg->len;
@@ -317,7 +286,8 @@ static u32 log_next(u32 idx)
 static void log_store(int facility, int level,
 		      enum log_flags flags, u64 ts_nsec,
 		      const char *dict, u16 dict_len,
-		      const char *text, u16 text_len)
+		      const char *text, u16 text_len,
+			struct syslog_namespace *ns)
 {
 	struct log *msg;
 	u32 size, pad_len;
@@ -327,34 +297,40 @@ static void log_store(int facility, int level,
 	pad_len = (-size) & (LOG_ALIGN - 1);
 	size += pad_len;
 
-	while (log_first_seq < log_next_seq) {
+	while (ns->log_first_seq < ns->log_next_seq) {
 		u32 free;
 
-		if (log_next_idx > log_first_idx)
-			free = max(log_buf_len - log_next_idx, log_first_idx);
+		if (ns->log_next_idx > ns->log_first_idx)
+			free = max(ns->log_buf_len -
+				ns->log_next_idx,
+				ns->log_first_idx);
 		else
-			free = log_first_idx - log_next_idx;
+			free = ns->log_first_idx -
+				ns->log_next_idx;
 
 		if (free > size + sizeof(struct log))
 			break;
 
 		/* drop old messages until we have enough contiuous space */
-		log_first_idx = log_next(log_first_idx);
-		log_first_seq++;
+		ns->log_first_idx =
+			log_next(ns->log_first_idx, ns);
+		ns->log_first_seq++;
 	}
 
-	if (log_next_idx + size + sizeof(struct log) >= log_buf_len) {
+	if (ns->log_next_idx + size + sizeof(struct log) >=
+				ns->log_buf_len) {
 		/*
 		 * This message + an additional empty header does not fit
 		 * at the end of the buffer. Add an empty header with len == 0
 		 * to signify a wrap around.
 		 */
-		memset(log_buf + log_next_idx, 0, sizeof(struct log));
-		log_next_idx = 0;
+		memset(ns->log_buf + ns->log_next_idx,
+				0, sizeof(struct log));
+		ns->log_next_idx = 0;
 	}
 
 	/* fill message */
-	msg = (struct log *)(log_buf + log_next_idx);
+	msg = (struct log *)(ns->log_buf + ns->log_next_idx);
 	memcpy(log_text(msg), text, text_len);
 	msg->text_len = text_len;
 	memcpy(log_dict(msg), dict, dict_len);
@@ -370,19 +346,14 @@ static void log_store(int facility, int level,
 	msg->len = sizeof(struct log) + text_len + dict_len + pad_len;
 
 	/* insert message */
-	log_next_idx += msg->len;
-	log_next_seq++;
+	ns->log_next_idx += msg->len;
+	ns->log_next_seq++;
 }
 
-#ifdef CONFIG_SECURITY_DMESG_RESTRICT
-int dmesg_restrict = 1;
-#else
-int dmesg_restrict;
-#endif
-
-static int syslog_action_restricted(int type)
+static int syslog_action_restricted(int type,
+			struct syslog_namespace *ns)
 {
-	if (dmesg_restrict)
+	if (ns->dmesg_restrict)
 		return 1;
 	/*
 	 * Unless restricted, we allow "read all" and "get buffer size"
@@ -392,7 +363,8 @@ static int syslog_action_restricted(int type)
 	       type != SYSLOG_ACTION_SIZE_BUFFER;
 }
 
-static int check_syslog_permissions(int type, bool from_file)
+static int check_syslog_permissions(int type, bool from_file,
+			struct syslog_namespace *ns)
 {
 	/*
 	 * If this is from /proc/kmsg and we've already opened it, then we've
@@ -401,7 +373,7 @@ static int check_syslog_permissions(int type, bool from_file)
 	if (from_file && type != SYSLOG_ACTION_OPEN)
 		return 0;
 
-	if (syslog_action_restricted(type)) {
+	if (syslog_action_restricted(type, ns)) {
 		if (capable(CAP_SYSLOG))
 			return 0;
 		/*
@@ -496,6 +468,8 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	char cont = '-';
 	size_t len;
 	ssize_t ret;
+	struct syslog_namespace *ns =
+			file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return -EBADF;
@@ -503,32 +477,32 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	ret = mutex_lock_interruptible(&user->lock);
 	if (ret)
 		return ret;
-	raw_spin_lock_irq(&logbuf_lock);
-	while (user->seq == log_next_seq) {
+	raw_spin_lock_irq(&ns->logbuf_lock);
+	while (user->seq == ns->log_next_seq) {
 		if (file->f_flags & O_NONBLOCK) {
 			ret = -EAGAIN;
-			raw_spin_unlock_irq(&logbuf_lock);
+			raw_spin_unlock_irq(&ns->logbuf_lock);
 			goto out;
 		}
 
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&ns->logbuf_lock);
 		ret = wait_event_interruptible(log_wait,
-					       user->seq != log_next_seq);
+				user->seq != ns->log_next_seq);
 		if (ret)
 			goto out;
-		raw_spin_lock_irq(&logbuf_lock);
+		raw_spin_lock_irq(&ns->logbuf_lock);
 	}
 
-	if (user->seq < log_first_seq) {
+	if (user->seq < ns->log_first_seq) {
 		/* our last seen message is gone, return error and reset */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = ns->log_first_idx;
+		user->seq = ns->log_first_seq;
 		ret = -EPIPE;
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&ns->logbuf_lock);
 		goto out;
 	}
 
-	msg = log_from_idx(user->idx);
+	msg = log_from_idx(user->idx, ns);
 	ts_usec = msg->ts_nsec;
 	do_div(ts_usec, 1000);
 
@@ -589,9 +563,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 		user->buf[len++] = '\n';
 	}
 
-	user->idx = log_next(user->idx);
+	user->idx = log_next(user->idx, ns);
 	user->seq++;
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&ns->logbuf_lock);
 
 	if (len > count) {
 		ret = -EINVAL;
@@ -612,18 +586,19 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct devkmsg_user *user = file->private_data;
 	loff_t ret = 0;
+	struct syslog_namespace *ns = file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return -EBADF;
 	if (offset)
 		return -ESPIPE;
 
-	raw_spin_lock_irq(&logbuf_lock);
+	raw_spin_lock_irq(&ns->logbuf_lock);
 	switch (whence) {
 	case SEEK_SET:
 		/* the first record */
-		user->idx = log_first_idx;
-		user->seq = log_first_seq;
+		user->idx = ns->log_first_idx;
+		user->seq = ns->log_first_seq;
 		break;
 	case SEEK_DATA:
 		/*
@@ -631,18 +606,18 @@ static loff_t devkmsg_llseek(struct file *file, loff_t offset, int whence)
 		 * like issued by 'dmesg -c'. Reading /dev/kmsg itself
 		 * changes no global state, and does not clear anything.
 		 */
-		user->idx = clear_idx;
-		user->seq = clear_seq;
+		user->idx = ns->clear_idx;
+		user->seq = ns->clear_seq;
 		break;
 	case SEEK_END:
 		/* after the last record */
-		user->idx = log_next_idx;
-		user->seq = log_next_seq;
+		user->idx = ns->log_next_idx;
+		user->seq = ns->log_next_seq;
 		break;
 	default:
 		ret = -EINVAL;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&ns->logbuf_lock);
 	return ret;
 }
 
@@ -650,21 +625,22 @@ static unsigned int devkmsg_poll(struct file *file, poll_table *wait)
 {
 	struct devkmsg_user *user = file->private_data;
 	int ret = 0;
+	struct syslog_namespace *ns = file->f_cred->user_ns->syslog_ns;
 
 	if (!user)
 		return POLLERR|POLLNVAL;
 
 	poll_wait(file, &log_wait, wait);
 
-	raw_spin_lock_irq(&logbuf_lock);
-	if (user->seq < log_next_seq) {
+	raw_spin_lock_irq(&ns->logbuf_lock);
+	if (user->seq < ns->log_next_seq) {
 		/* return error when data has vanished underneath us */
-		if (user->seq < log_first_seq)
+		if (user->seq < ns->log_first_seq)
 			ret = POLLIN|POLLRDNORM|POLLERR|POLLPRI;
 		else
 			ret = POLLIN|POLLRDNORM;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&ns->logbuf_lock);
 
 	return ret;
 }
@@ -673,13 +649,14 @@ static int devkmsg_open(struct inode *inode, struct file *file)
 {
 	struct devkmsg_user *user;
 	int err;
+	struct syslog_namespace *ns = file->f_cred->user_ns->syslog_ns;
 
 	/* write-only does not need any file context */
 	if ((file->f_flags & O_ACCMODE) == O_WRONLY)
 		return 0;
 
 	err = check_syslog_permissions(SYSLOG_ACTION_READ_ALL,
-				       SYSLOG_FROM_READER);
+				       SYSLOG_FROM_READER, ns);
 	if (err)
 		return err;
 
@@ -689,10 +666,10 @@ static int devkmsg_open(struct inode *inode, struct file *file)
 
 	mutex_init(&user->lock);
 
-	raw_spin_lock_irq(&logbuf_lock);
-	user->idx = log_first_idx;
-	user->seq = log_first_seq;
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_lock_irq(&ns->logbuf_lock);
+	user->idx = ns->log_first_idx;
+	user->seq = ns->log_first_seq;
+	raw_spin_unlock_irq(&ns->logbuf_lock);
 
 	file->private_data = user;
 	return 0;
@@ -730,10 +707,11 @@ const struct file_operations kmsg_fops = {
  */
 void log_buf_kexec_setup(void)
 {
-	VMCOREINFO_SYMBOL(log_buf);
-	VMCOREINFO_SYMBOL(log_buf_len);
-	VMCOREINFO_SYMBOL(log_first_idx);
-	VMCOREINFO_SYMBOL(log_next_idx);
+	struct syslog_namespace *ns = &init_syslog_ns;
+	VMCOREINFO_SYMBOL(ns->log_buf);
+	VMCOREINFO_SYMBOL(ns->log_buf_len);
+	VMCOREINFO_SYMBOL(ns->log_first_idx);
+	VMCOREINFO_SYMBOL(ns->log_next_idx);
 	/*
 	 * Export struct log size and field offsets. User space tools can
 	 * parse it and detect any changes to structure down the line.
@@ -753,10 +731,11 @@ static unsigned long __initdata new_log_buf_len;
 static int __init log_buf_len_setup(char *str)
 {
 	unsigned size = memparse(str, &str);
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if (size)
 		size = roundup_pow_of_two(size);
-	if (size > log_buf_len)
+	if (size > ns->log_buf_len)
 		new_log_buf_len = size;
 
 	return 0;
@@ -768,6 +747,7 @@ void __init setup_log_buf(int early)
 	unsigned long flags;
 	char *new_log_buf;
 	int free;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if (!new_log_buf_len)
 		return;
@@ -789,15 +769,15 @@ void __init setup_log_buf(int early)
 		return;
 	}
 
-	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	log_buf_len = new_log_buf_len;
-	log_buf = new_log_buf;
+	raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+	memcpy(new_log_buf, ns->log_buf, __LOG_BUF_LEN);
+	ns->log_buf_len = new_log_buf_len;
+	ns->log_buf = new_log_buf;
 	new_log_buf_len = 0;
-	free = __LOG_BUF_LEN - log_next_idx;
-	memcpy(log_buf, __log_buf, __LOG_BUF_LEN);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	free = __LOG_BUF_LEN - ns->log_next_idx;
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 
-	pr_info("log_buf_len: %d\n", log_buf_len);
+	pr_info("log_buf_len: %d\n", ns->log_buf_len);
 	pr_info("early log buf free: %d(%d%%)\n",
 		free, (free * 100) / __LOG_BUF_LEN);
 }
@@ -977,7 +957,8 @@ static size_t msg_print_text(const struct log *msg, enum log_flags prev,
 	return len;
 }
 
-static int syslog_print(char __user *buf, int size)
+static int syslog_print(char __user *buf, int size,
+		struct syslog_namespace *ns)
 {
 	char *text;
 	struct log *msg;
@@ -991,37 +972,38 @@ static int syslog_print(char __user *buf, int size)
 		size_t n;
 		size_t skip;
 
-		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		raw_spin_lock_irq(&ns->logbuf_lock);
+		if (ns->syslog_seq < ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			ns->syslog_seq = ns->log_first_seq;
+			ns->syslog_idx = ns->log_first_idx;
+			ns->syslog_prev = 0;
+			ns->syslog_partial = 0;
 		}
-		if (syslog_seq == log_next_seq) {
-			raw_spin_unlock_irq(&logbuf_lock);
+		if (ns->syslog_seq == ns->log_next_seq) {
+			raw_spin_unlock_irq(&ns->logbuf_lock);
 			break;
 		}
 
-		skip = syslog_partial;
-		msg = log_from_idx(syslog_idx);
-		n = msg_print_text(msg, syslog_prev, true, text,
+		skip = ns->syslog_partial;
+		msg = log_from_idx(ns->syslog_idx, ns);
+		n = msg_print_text(msg, ns->syslog_prev, true, text,
 				   LOG_LINE_MAX + PREFIX_MAX);
-		if (n - syslog_partial <= size) {
+		if (n - ns->syslog_partial <= size) {
 			/* message fits into buffer, move forward */
-			syslog_idx = log_next(syslog_idx);
-			syslog_seq++;
-			syslog_prev = msg->flags;
-			n -= syslog_partial;
-			syslog_partial = 0;
+			ns->syslog_idx =
+				log_next(ns->syslog_idx, ns);
+			ns->syslog_seq++;
+			ns->syslog_prev = msg->flags;
+			n -= ns->syslog_partial;
+			ns->syslog_partial = 0;
 		} else if (!len){
 			/* partial read(), remember position */
 			n = size;
-			syslog_partial += n;
+			ns->syslog_partial += n;
 		} else
 			n = 0;
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&ns->logbuf_lock);
 
 		if (!n)
 			break;
@@ -1041,7 +1023,8 @@ static int syslog_print(char __user *buf, int size)
 	return len;
 }
 
-static int syslog_print_all(char __user *buf, int size, bool clear)
+static int syslog_print_all(char __user *buf, int size, bool clear,
+		struct syslog_namespace *ns)
 {
 	char *text;
 	int len = 0;
@@ -1050,55 +1033,55 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 	if (!text)
 		return -ENOMEM;
 
-	raw_spin_lock_irq(&logbuf_lock);
+	raw_spin_lock_irq(&ns->logbuf_lock);
 	if (buf) {
 		u64 next_seq;
 		u64 seq;
 		u32 idx;
 		enum log_flags prev;
 
-		if (clear_seq < log_first_seq) {
+		if (ns->clear_seq < ns->log_first_seq) {
 			/* messages are gone, move to first available one */
-			clear_seq = log_first_seq;
-			clear_idx = log_first_idx;
+			ns->clear_seq = ns->log_first_seq;
+			ns->clear_idx = ns->log_first_idx;
 		}
 
 		/*
 		 * Find first record that fits, including all following records,
 		 * into the user-provided buffer for this dump.
 		 */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = ns->clear_seq;
+		idx = ns->clear_idx;
 		prev = 0;
-		while (seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (seq < ns->log_next_seq) {
+			struct log *msg = log_from_idx(idx, ns);
 
 			len += msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(idx, ns);
 			seq++;
 		}
 
 		/* move first record forward until length fits into the buffer */
-		seq = clear_seq;
-		idx = clear_idx;
+		seq = ns->clear_seq;
+		idx = ns->clear_idx;
 		prev = 0;
-		while (len > size && seq < log_next_seq) {
-			struct log *msg = log_from_idx(idx);
+		while (len > size && seq < ns->log_next_seq) {
+			struct log *msg = log_from_idx(idx, ns);
 
 			len -= msg_print_text(msg, prev, true, NULL, 0);
 			prev = msg->flags;
-			idx = log_next(idx);
+			idx = log_next(idx, ns);
 			seq++;
 		}
 
 		/* last message fitting into this dump */
-		next_seq = log_next_seq;
+		next_seq = ns->log_next_seq;
 
 		len = 0;
 		prev = 0;
 		while (len >= 0 && seq < next_seq) {
-			struct log *msg = log_from_idx(idx);
+			struct log *msg = log_from_idx(idx, ns);
 			int textlen;
 
 			textlen = msg_print_text(msg, prev, true, text,
@@ -1107,43 +1090,44 @@ static int syslog_print_all(char __user *buf, int size, bool clear)
 				len = textlen;
 				break;
 			}
-			idx = log_next(idx);
+			idx = log_next(idx, ns);
 			seq++;
 			prev = msg->flags;
 
-			raw_spin_unlock_irq(&logbuf_lock);
+			raw_spin_unlock_irq(&ns->logbuf_lock);
 			if (copy_to_user(buf + len, text, textlen))
 				len = -EFAULT;
 			else
 				len += textlen;
-			raw_spin_lock_irq(&logbuf_lock);
+			raw_spin_lock_irq(&ns->logbuf_lock);
 
-			if (seq < log_first_seq) {
+			if (seq < ns->log_first_seq) {
 				/* messages are gone, move to next one */
-				seq = log_first_seq;
-				idx = log_first_idx;
+				seq = ns->log_first_seq;
+				idx = ns->log_first_idx;
 				prev = 0;
 			}
 		}
 	}
 
 	if (clear) {
-		clear_seq = log_next_seq;
-		clear_idx = log_next_idx;
+		ns->clear_seq = ns->log_next_seq;
+		ns->clear_idx = ns->log_next_idx;
 	}
-	raw_spin_unlock_irq(&logbuf_lock);
+	raw_spin_unlock_irq(&ns->logbuf_lock);
 
 	kfree(text);
 	return len;
 }
 
-int do_syslog(int type, char __user *buf, int len, bool from_file)
+int do_syslog(int type, char __user *buf, int len, bool from_file,
+		struct syslog_namespace *ns)
 {
 	bool clear = false;
 	static int saved_console_loglevel = -1;
 	int error;
 
-	error = check_syslog_permissions(type, from_file);
+	error = check_syslog_permissions(type, from_file, ns);
 	if (error)
 		goto out;
 
@@ -1168,10 +1152,10 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			goto out;
 		}
 		error = wait_event_interruptible(log_wait,
-						 syslog_seq != log_next_seq);
+			ns->syslog_seq != ns->log_next_seq);
 		if (error)
 			goto out;
-		error = syslog_print(buf, len);
+		error = syslog_print(buf, len, ns);
 		break;
 	/* Read/clear last kernel messages */
 	case SYSLOG_ACTION_READ_CLEAR:
@@ -1189,11 +1173,11 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			error = -EFAULT;
 			goto out;
 		}
-		error = syslog_print_all(buf, len, clear);
+		error = syslog_print_all(buf, len, clear, ns);
 		break;
 	/* Clear ring buffer */
 	case SYSLOG_ACTION_CLEAR:
-		syslog_print_all(NULL, 0, true);
+		syslog_print_all(NULL, 0, true, ns);
 		break;
 	/* Disable logging to console */
 	case SYSLOG_ACTION_CONSOLE_OFF:
@@ -1222,13 +1206,13 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 		break;
 	/* Number of chars in the log buffer */
 	case SYSLOG_ACTION_SIZE_UNREAD:
-		raw_spin_lock_irq(&logbuf_lock);
-		if (syslog_seq < log_first_seq) {
+		raw_spin_lock_irq(&ns->logbuf_lock);
+		if (ns->syslog_seq < ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			syslog_seq = log_first_seq;
-			syslog_idx = log_first_idx;
-			syslog_prev = 0;
-			syslog_partial = 0;
+			ns->syslog_seq = ns->log_first_seq;
+			ns->syslog_idx = ns->log_first_idx;
+			ns->syslog_prev = 0;
+			ns->syslog_partial = 0;
 		}
 		if (from_file) {
 			/*
@@ -1236,28 +1220,28 @@ int do_syslog(int type, char __user *buf, int len, bool from_file)
 			 * for pending data, not the size; return the count of
 			 * records, not the length.
 			 */
-			error = log_next_idx - syslog_idx;
+			error = ns->log_next_idx - ns->syslog_idx;
 		} else {
-			u64 seq = syslog_seq;
-			u32 idx = syslog_idx;
-			enum log_flags prev = syslog_prev;
+			u64 seq = ns->syslog_seq;
+			u32 idx = ns->syslog_idx;
+			enum log_flags prev = ns->syslog_prev;
 
 			error = 0;
-			while (seq < log_next_seq) {
-				struct log *msg = log_from_idx(idx);
+			while (seq < ns->log_next_seq) {
+				struct log *msg = log_from_idx(idx, ns);
 
 				error += msg_print_text(msg, prev, true, NULL, 0);
-				idx = log_next(idx);
+				idx = log_next(idx, ns);
 				seq++;
 				prev = msg->flags;
 			}
-			error -= syslog_partial;
+			error -= ns->syslog_partial;
 		}
-		raw_spin_unlock_irq(&logbuf_lock);
+		raw_spin_unlock_irq(&ns->logbuf_lock);
 		break;
 	/* Size of the log buffer */
 	case SYSLOG_ACTION_SIZE_BUFFER:
-		error = log_buf_len;
+		error = ns->log_buf_len;
 		break;
 	default:
 		error = -EINVAL;
@@ -1269,7 +1253,8 @@ out:
 
 SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
 {
-	return do_syslog(type, buf, len, SYSLOG_FROM_READER);
+	return do_syslog(type, buf, len, SYSLOG_FROM_READER,
+			current_user_ns()->syslog_ns);
 }
 
 /*
@@ -1307,7 +1292,7 @@ static void call_console_drivers(int level, const char *text, size_t len)
  * every 10 seconds, to leave time for slow consoles to print a
  * full oops.
  */
-static void zap_locks(void)
+static void zap_locks(struct syslog_namespace *ns)
 {
 	static unsigned long oops_timestamp;
 
@@ -1319,7 +1304,7 @@ static void zap_locks(void)
 
 	debug_locks_off();
 	/* If a crash is occurring, make sure we can't deadlock */
-	raw_spin_lock_init(&logbuf_lock);
+	raw_spin_lock_init(&ns->logbuf_lock);
 	/* And make sure that we print immediately */
 	sema_init(&console_sem, 1);
 }
@@ -1359,8 +1344,9 @@ static inline int can_use_console(unsigned int cpu)
  * interrupts disabled. It should return with 'lockbuf_lock'
  * released but interrupts still disabled.
  */
-static int console_trylock_for_printk(unsigned int cpu)
-	__releases(&logbuf_lock)
+static int console_trylock_for_printk(unsigned int cpu,
+		struct syslog_namespace *ns)
+	__releases(&ns->logbuf_lock)
 {
 	int retval = 0, wake = 0;
 
@@ -1379,8 +1365,8 @@ static int console_trylock_for_printk(unsigned int cpu)
 			retval = 0;
 		}
 	}
-	logbuf_cpu = UINT_MAX;
-	raw_spin_unlock(&logbuf_lock);
+	ns->logbuf_cpu = UINT_MAX;
+	raw_spin_unlock(&ns->logbuf_lock);
 	if (wake)
 		up(&console_sem);
 	return retval;
@@ -1418,7 +1404,7 @@ static struct cont {
 	bool flushed:1;			/* buffer sealed and committed */
 } cont;
 
-static void cont_flush(enum log_flags flags)
+static void cont_flush(enum log_flags flags, struct syslog_namespace *ns)
 {
 	if (cont.flushed)
 		return;
@@ -1432,7 +1418,7 @@ static void cont_flush(enum log_flags flags)
 		 * line. LOG_NOCONS suppresses a duplicated output.
 		 */
 		log_store(cont.facility, cont.level, flags | LOG_NOCONS,
-			  cont.ts_nsec, NULL, 0, cont.buf, cont.len);
+			  cont.ts_nsec, NULL, 0, cont.buf, cont.len, ns);
 		cont.flags = flags;
 		cont.flushed = true;
 	} else {
@@ -1441,19 +1427,20 @@ static void cont_flush(enum log_flags flags)
 		 * just submit it to the store and free the buffer.
 		 */
 		log_store(cont.facility, cont.level, flags, 0,
-			  NULL, 0, cont.buf, cont.len);
+			  NULL, 0, cont.buf, cont.len, ns);
 		cont.len = 0;
 	}
 }
 
-static bool cont_add(int facility, int level, const char *text, size_t len)
+static bool cont_add(int facility, int level, const char *text, size_t len,
+				struct syslog_namespace *ns)
 {
 	if (cont.len && cont.flushed)
 		return false;
 
 	if (cont.len + len > sizeof(cont.buf)) {
 		/* the line gets too long, split it up in separate records */
-		cont_flush(LOG_CONT);
+		cont_flush(LOG_CONT, ns);
 		return false;
 	}
 
@@ -1471,7 +1458,7 @@ static bool cont_add(int facility, int level, const char *text, size_t len)
 	cont.len += len;
 
 	if (cont.len > (sizeof(cont.buf) * 80) / 100)
-		cont_flush(LOG_CONT);
+		cont_flush(LOG_CONT, ns);
 
 	return true;
 }
@@ -1516,6 +1503,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 	unsigned long flags;
 	int this_cpu;
 	int printed_len = 0;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	boot_delay_msec(level);
 	printk_delay();
@@ -1527,7 +1515,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 	/*
 	 * Ouch, printk recursed into itself!
 	 */
-	if (unlikely(logbuf_cpu == this_cpu)) {
+	if (unlikely(ns->logbuf_cpu == this_cpu)) {
 		/*
 		 * If a crash is occurring during printk() on this CPU,
 		 * then try to get the crash message out but make sure
@@ -1539,12 +1527,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 			recursion_bug = 1;
 			goto out_restore_irqs;
 		}
-		zap_locks();
+		zap_locks(ns);
 	}
 
 	lockdep_off();
-	raw_spin_lock(&logbuf_lock);
-	logbuf_cpu = this_cpu;
+	raw_spin_lock(&ns->logbuf_lock);
+	ns->logbuf_cpu = this_cpu;
 
 	if (recursion_bug) {
 		static const char recursion_msg[] =
@@ -1554,7 +1542,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 		printed_len += strlen(recursion_msg);
 		/* emit KERN_CRIT message */
 		log_store(0, 2, LOG_PREFIX|LOG_NEWLINE, 0,
-			  NULL, 0, recursion_msg, printed_len);
+			  NULL, 0, recursion_msg, printed_len, ns);
 	}
 
 	/*
@@ -1601,12 +1589,12 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 * or another task also prints continuation lines.
 		 */
 		if (cont.len && (lflags & LOG_PREFIX || cont.owner != current))
-			cont_flush(LOG_NEWLINE);
+			cont_flush(LOG_NEWLINE, ns);
 
 		/* buffer line if possible, otherwise store it right away */
-		if (!cont_add(facility, level, text, text_len))
+		if (!cont_add(facility, level, text, text_len, ns))
 			log_store(facility, level, lflags | LOG_CONT, 0,
-				  dict, dictlen, text, text_len);
+				  dict, dictlen, text, text_len, ns);
 	} else {
 		bool stored = false;
 
@@ -1618,13 +1606,14 @@ asmlinkage int vprintk_emit(int facility, int level,
 		 */
 		if (cont.len && cont.owner == current) {
 			if (!(lflags & LOG_PREFIX))
-				stored = cont_add(facility, level, text, text_len);
-			cont_flush(LOG_NEWLINE);
+				stored = cont_add(facility, level, text,
+								text_len, ns);
+			cont_flush(LOG_NEWLINE, ns);
 		}
 
 		if (!stored)
 			log_store(facility, level, lflags, 0,
-				  dict, dictlen, text, text_len);
+				  dict, dictlen, text, text_len, ns);
 	}
 	printed_len += text_len;
 
@@ -1636,7 +1625,7 @@ asmlinkage int vprintk_emit(int facility, int level,
 	 * The console_trylock_for_printk() function will release 'logbuf_lock'
 	 * regardless of whether it actually gets the console semaphore or not.
 	 */
-	if (console_trylock_for_printk(this_cpu))
+	if (console_trylock_for_printk(this_cpu, ns))
 		console_unlock();
 
 	lockdep_on();
@@ -1995,12 +1984,13 @@ int is_console_locked(void)
 	return console_locked;
 }
 
-static void console_cont_flush(char *text, size_t size)
+static void console_cont_flush(char *text, size_t size,
+			struct syslog_namespace *ns)
 {
 	unsigned long flags;
 	size_t len;
 
-	raw_spin_lock_irqsave(&logbuf_lock, flags);
+	raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
 
 	if (!cont.len)
 		goto out;
@@ -2010,18 +2000,18 @@ static void console_cont_flush(char *text, size_t size)
 	 * busy. The earlier ones need to be printed before this one, we
 	 * did not flush any fragment so far, so just let it queue up.
 	 */
-	if (console_seq < log_next_seq && !cont.cons)
+	if (ns->console_seq < ns->log_next_seq && !cont.cons)
 		goto out;
 
 	len = cont_print_text(text, size);
-	raw_spin_unlock(&logbuf_lock);
+	raw_spin_unlock(&ns->logbuf_lock);
 	stop_critical_timings();
 	call_console_drivers(cont.level, text, len);
 	start_critical_timings();
 	local_irq_restore(flags);
 	return;
 out:
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 }
 
 /**
@@ -2045,6 +2035,7 @@ void console_unlock(void)
 	unsigned long flags;
 	bool wake_klogd = false;
 	bool retry;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if (console_suspended) {
 		up(&console_sem);
@@ -2054,37 +2045,38 @@ void console_unlock(void)
 	console_may_schedule = 0;
 
 	/* flush buffered message fragment immediately to console */
-	console_cont_flush(text, sizeof(text));
+	console_cont_flush(text, sizeof(text), ns);
 again:
 	for (;;) {
 		struct log *msg;
 		size_t len;
 		int level;
 
-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		if (seen_seq != log_next_seq) {
+		raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+		if (seen_seq != ns->log_next_seq) {
 			wake_klogd = true;
-			seen_seq = log_next_seq;
+			seen_seq = ns->log_next_seq;
 		}
 
-		if (console_seq < log_first_seq) {
+		if (ns->console_seq < ns->log_first_seq) {
 			/* messages are gone, move to first one */
-			console_seq = log_first_seq;
-			console_idx = log_first_idx;
+			ns->console_seq = ns->log_first_seq;
+			ns->console_idx = ns->log_first_idx;
 			console_prev = 0;
 		}
 skip:
-		if (console_seq == log_next_seq)
+		if (ns->console_seq == ns->log_next_seq)
 			break;
 
-		msg = log_from_idx(console_idx);
+		msg = log_from_idx(ns->console_idx, ns);
 		if (msg->flags & LOG_NOCONS) {
 			/*
 			 * Skip record we have buffered and already printed
 			 * directly to the console when we received it.
 			 */
-			console_idx = log_next(console_idx);
-			console_seq++;
+			ns->console_idx =
+				log_next(ns->console_idx, ns);
+			ns->console_seq++;
 			/*
 			 * We will get here again when we register a new
 			 * CON_PRINTBUFFER console. Clear the flag so we
@@ -2098,10 +2090,11 @@ skip:
 		level = msg->level;
 		len = msg_print_text(msg, console_prev, false,
 				     text, sizeof(text));
-		console_idx = log_next(console_idx);
-		console_seq++;
+		ns->console_idx =
+			log_next(ns->console_idx, ns);
+		ns->console_seq++;
 		console_prev = msg->flags;
-		raw_spin_unlock(&logbuf_lock);
+		raw_spin_unlock(&ns->logbuf_lock);
 
 		stop_critical_timings();	/* don't trace print latency */
 		call_console_drivers(level, text, len);
@@ -2115,7 +2108,7 @@ skip:
 	if (unlikely(exclusive_console))
 		exclusive_console = NULL;
 
-	raw_spin_unlock(&logbuf_lock);
+	raw_spin_unlock(&ns->logbuf_lock);
 
 	up(&console_sem);
 
@@ -2125,9 +2118,9 @@ skip:
 	 * there's a new owner and the console_unlock() from them will do the
 	 * flush, no worries.
 	 */
-	raw_spin_lock(&logbuf_lock);
-	retry = console_seq != log_next_seq;
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_lock(&ns->logbuf_lock);
+	retry = ns->console_seq != ns->log_next_seq;
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 
 	if (retry && console_trylock())
 		goto again;
@@ -2252,6 +2245,7 @@ void register_console(struct console *newcon)
 	int i;
 	unsigned long flags;
 	struct console *bcon = NULL;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	/*
 	 * before we register a new CON_BOOT console, make sure we don't
@@ -2361,11 +2355,11 @@ void register_console(struct console *newcon)
 		 * console_unlock(); will print out the buffered messages
 		 * for us.
 		 */
-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		console_seq = syslog_seq;
-		console_idx = syslog_idx;
-		console_prev = syslog_prev;
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+		ns->console_seq = ns->syslog_seq;
+		ns->console_idx = ns->syslog_idx;
+		console_prev = ns->syslog_prev;
+		raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 		/*
 		 * We're about to replay the log buffer.  Only do this to the
 		 * just-registered console to avoid excessive message spam to
@@ -2627,6 +2621,7 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 {
 	struct kmsg_dumper *dumper;
 	unsigned long flags;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if ((reason > KMSG_DUMP_OOPS) && !always_kmsg_dump)
 		return;
@@ -2639,12 +2634,12 @@ void kmsg_dump(enum kmsg_dump_reason reason)
 		/* initialize iterator with data about the stored records */
 		dumper->active = true;
 
-		raw_spin_lock_irqsave(&logbuf_lock, flags);
-		dumper->cur_seq = clear_seq;
-		dumper->cur_idx = clear_idx;
-		dumper->next_seq = log_next_seq;
-		dumper->next_idx = log_next_idx;
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+		dumper->cur_seq = ns->clear_seq;
+		dumper->cur_idx = ns->clear_idx;
+		dumper->next_seq = ns->log_next_seq;
+		dumper->next_idx = ns->log_next_idx;
+		raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 
 		/* invoke dumper which will iterate over records */
 		dumper->dump(dumper, reason);
@@ -2680,24 +2675,25 @@ bool kmsg_dump_get_line_nolock(struct kmsg_dumper *dumper, bool syslog,
 	struct log *msg;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if (!dumper->active)
 		goto out;
 
-	if (dumper->cur_seq < log_first_seq) {
+	if (dumper->cur_seq < ns->log_first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = ns->log_first_seq;
+		dumper->cur_idx = ns->log_first_idx;
 	}
 
 	/* last entry */
-	if (dumper->cur_seq >= log_next_seq)
+	if (dumper->cur_seq >= ns->log_next_seq)
 		goto out;
 
-	msg = log_from_idx(dumper->cur_idx);
+	msg = log_from_idx(dumper->cur_idx, ns);
 	l = msg_print_text(msg, 0, syslog, line, size);
 
-	dumper->cur_idx = log_next(dumper->cur_idx);
+	dumper->cur_idx = log_next(dumper->cur_idx, ns);
 	dumper->cur_seq++;
 	ret = true;
 out:
@@ -2728,10 +2724,11 @@ bool kmsg_dump_get_line(struct kmsg_dumper *dumper, bool syslog,
 {
 	unsigned long flags;
 	bool ret;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
-	raw_spin_lock_irqsave(&logbuf_lock, flags);
+	raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
 	ret = kmsg_dump_get_line_nolock(dumper, syslog, line, size, len);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 
 	return ret;
 }
@@ -2767,20 +2764,21 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	enum log_flags prev;
 	size_t l = 0;
 	bool ret = false;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
 	if (!dumper->active)
 		goto out;
 
-	raw_spin_lock_irqsave(&logbuf_lock, flags);
-	if (dumper->cur_seq < log_first_seq) {
+	raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
+	if (dumper->cur_seq < ns->log_first_seq) {
 		/* messages are gone, move to first available one */
-		dumper->cur_seq = log_first_seq;
-		dumper->cur_idx = log_first_idx;
+		dumper->cur_seq = ns->log_first_seq;
+		dumper->cur_idx = ns->log_first_idx;
 	}
 
 	/* last entry */
 	if (dumper->cur_seq >= dumper->next_seq) {
-		raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+		raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 		goto out;
 	}
 
@@ -2789,10 +2787,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, ns);
 
 		l += msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(idx, ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2802,10 +2800,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	idx = dumper->cur_idx;
 	prev = 0;
 	while (l > size && seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, ns);
 
 		l -= msg_print_text(msg, prev, true, NULL, 0);
-		idx = log_next(idx);
+		idx = log_next(idx, ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2817,10 +2815,10 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	l = 0;
 	prev = 0;
 	while (seq < dumper->next_seq) {
-		struct log *msg = log_from_idx(idx);
+		struct log *msg = log_from_idx(idx, ns);
 
 		l += msg_print_text(msg, prev, syslog, buf + l, size - l);
-		idx = log_next(idx);
+		idx = log_next(idx, ns);
 		seq++;
 		prev = msg->flags;
 	}
@@ -2828,7 +2826,7 @@ bool kmsg_dump_get_buffer(struct kmsg_dumper *dumper, bool syslog,
 	dumper->next_seq = next_seq;
 	dumper->next_idx = next_idx;
 	ret = true;
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 out:
 	if (len)
 		*len = l;
@@ -2848,10 +2846,12 @@ EXPORT_SYMBOL_GPL(kmsg_dump_get_buffer);
  */
 void kmsg_dump_rewind_nolock(struct kmsg_dumper *dumper)
 {
-	dumper->cur_seq = clear_seq;
-	dumper->cur_idx = clear_idx;
-	dumper->next_seq = log_next_seq;
-	dumper->next_idx = log_next_idx;
+	struct syslog_namespace *ns = &init_syslog_ns;
+
+	dumper->cur_seq = ns->clear_seq;
+	dumper->cur_idx = ns->clear_idx;
+	dumper->next_seq = ns->log_next_seq;
+	dumper->next_idx = ns->log_next_idx;
 }
 
 /**
@@ -2865,10 +2865,11 @@ void kmsg_dump_rewind_nolock(struct kmsg_dumper *dumper)
 void kmsg_dump_rewind(struct kmsg_dumper *dumper)
 {
 	unsigned long flags;
+	struct syslog_namespace *ns = &init_syslog_ns;
 
-	raw_spin_lock_irqsave(&logbuf_lock, flags);
+	raw_spin_lock_irqsave(&ns->logbuf_lock, flags);
 	kmsg_dump_rewind_nolock(dumper);
-	raw_spin_unlock_irqrestore(&logbuf_lock, flags);
+	raw_spin_unlock_irqrestore(&ns->logbuf_lock, flags);
 }
 EXPORT_SYMBOL_GPL(kmsg_dump_rewind);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ac09d98..0954b09 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -62,6 +62,7 @@
 #include <linux/capability.h>
 #include <linux/binfmts.h>
 #include <linux/sched/sysctl.h>
+#include <linux/syslog.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -773,7 +774,7 @@ static struct ctl_table kern_table[] = {
 	},
 	{
 		.procname	= "dmesg_restrict",
-		.data		= &dmesg_restrict,
+		.data		= &init_syslog_ns.dmesg_restrict,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax_sysadmin,
-- 
1.8.2.2
