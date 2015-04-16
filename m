From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 01/16] printk: guard the amount written per line by devkmsg_read()
Date: Thu, 16 Apr 2015 19:03:38 -0400
Message-ID: <1429225433-11946-2-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Kay Sievers <kay@vrfy.org>,
	Petr Mladek <pmladek@suse.cz>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:33518 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbbDPXEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:20 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 kernel/printk/printk.c | 35 +++++++++++++++++++++++------------
 2 files changed, 25 insertions(+), 12 deletions(-)

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
index 879edfc..b6e24af 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -512,7 +512,7 @@ struct devkmsg_user {
 	u32 idx;
 	enum log_flags prev;
 	struct mutex lock;
-	char buf[8192];
+	char buf[CONSOLE_EXT_LOG_MAX];
 };
 
 static ssize_t devkmsg_write(struct kiocb *iocb, struct iov_iter *from)
@@ -565,11 +565,18 @@ static ssize_t devkmsg_write(struct kiocb *iocb, struct iov_iter *from)
 	return ret;
 }
 
+static void append_char(char **pp, char *e, char c)
+{
+	if (*pp < e)
+		*(*pp)++ = c;
+}
+
 static ssize_t devkmsg_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
 	struct devkmsg_user *user = file->private_data;
 	struct printk_log *msg;
+	char *p, *e;
 	u64 ts_usec;
 	size_t i;
 	char cont = '-';
@@ -579,6 +586,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	if (!user)
 		return -EBADF;
 
+	p = user->buf;
+	e = user->buf + sizeof(user->buf);
+
 	ret = mutex_lock_interruptible(&user->lock);
 	if (ret)
 		return ret;
@@ -625,9 +635,9 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
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
@@ -635,11 +645,11 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
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
@@ -648,30 +658,31 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
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
