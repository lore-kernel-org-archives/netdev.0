From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/3] printk: guard the amount written per line by devkmsg_read()
Date: Wed, 29 Apr 2015 10:45:02 -0400
Message-ID: <1430318704-32374-2-git-send-email-tj@kernel.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Kay Sievers <kay@vrfy.org>
To: pmladek@suse.cz, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430318704-32374-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

devkmsg_read() uses 8k buffer and assumes that the formatted output
message won't overrun which seems safe given LOG_LINE_MAX, the current
use of dict and the escaping method being used; however, we're
planning to use devkmsg formatting wider and accounting for the buffer
size properly isn't that complicated.

This patch defines CONSOLE_EXT_LOG_MAX as 8192 and updates
devkmsg_read() so that it limits output accordingly.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Petr Mladek <pmladek@suse.cz>
---
 include/linux/printk.h |  2 ++
 kernel/printk/printk.c | 34 ++++++++++++++++++++++------------
 2 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index 9b30871..58b1fec 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -30,6 +30,8 @@ static inline const char *printk_skip_level(const char *buffer)
 	return buffer;
 }
 
+#define CONSOLE_EXT_LOG_MAX	8192
+
 /* printk's without a loglevel use this.. */
 #define MESSAGE_LOGLEVEL_DEFAULT CONFIG_MESSAGE_LOGLEVEL_DEFAULT
 
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index c099b08..a115490 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -505,6 +505,11 @@ int check_syslog_permissions(int type, bool from_file)
 	return security_syslog(type);
 }
 
+static void append_char(char **pp, char *e, char c)
+{
+	if (*pp < e)
+		*(*pp)++ = c;
+}
 
 /* /dev/kmsg - userspace message inject/listen interface */
 struct devkmsg_user {
@@ -512,7 +517,7 @@ struct devkmsg_user {
 	u32 idx;
 	enum log_flags prev;
 	struct mutex lock;
-	char buf[8192];
+	char buf[CONSOLE_EXT_LOG_MAX];
 };
 
 static ssize_t devkmsg_write(struct kiocb *iocb, struct iov_iter *from)
@@ -570,6 +575,7 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 {
 	struct devkmsg_user *user = file->private_data;
 	struct printk_log *msg;
+	char *p, *e;
 	u64 ts_usec;
 	size_t i;
 	char cont = '-';
@@ -579,6 +585,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	if (!user)
 		return -EBADF;
 
+	p = user->buf;
+	e = user->buf + sizeof(user->buf);
+
 	ret = mutex_lock_interruptible(&user->lock);
 	if (ret)
 		return ret;
@@ -625,9 +634,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 		 ((user->prev & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
 		cont = '+';
 
-	len = sprintf(user->buf, "%u,%llu,%llu,%c;",
-		      (msg->facility << 3) | msg->level,
-		      user->seq, ts_usec, cont);
+	p += scnprintf(p, e - p, "%u,%llu,%llu,%c;",
+		       (msg->facility << 3) | msg->level,
+		       user->seq, ts_usec, cont);
 	user->prev = msg->flags;
 
 	/* escape non-printable characters */
@@ -635,11 +644,11 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 		unsigned char c = log_text(msg)[i];
 
 		if (c < ' ' || c >= 127 || c == '\\')
-			len += sprintf(user->buf + len, "\\x%02x", c);
+			p += scnprintf(p, e - p, "\\x%02x", c);
 		else
-			user->buf[len++] = c;
+			append_char(&p, e, c);
 	}
-	user->buf[len++] = '\n';
+	append_char(&p, e, '\n');
 
 	if (msg->dict_len) {
 		bool line = true;
@@ -648,30 +657,31 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 			unsigned char c = log_dict(msg)[i];
 
 			if (line) {
-				user->buf[len++] = ' ';
+				append_char(&p, e, ' ');
 				line = false;
 			}
 
 			if (c == '\0') {
-				user->buf[len++] = '\n';
+				append_char(&p, e, '\n');
 				line = true;
 				continue;
 			}
 
 			if (c < ' ' || c >= 127 || c == '\\') {
-				len += sprintf(user->buf + len, "\\x%02x", c);
+				p += scnprintf(p, e - p, "\\x%02x", c);
 				continue;
 			}
 
-			user->buf[len++] = c;
+			append_char(&p, e, c);
 		}
-		user->buf[len++] = '\n';
+		append_char(&p, e, '\n');
 	}
 
 	user->idx = log_next(user->idx);
 	user->seq++;
 	raw_spin_unlock_irq(&logbuf_lock);
 
+	len = p - user->buf;
 	if (len > count) {
 		ret = -EINVAL;
 		goto out;
-- 
2.1.0
