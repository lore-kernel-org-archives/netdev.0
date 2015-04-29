From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/3] printk: factor out message formatting from devkmsg_read()
Date: Wed, 29 Apr 2015 10:45:03 -0400
Message-ID: <1430318704-32374-3-git-send-email-tj@kernel.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Kay Sievers <kay@vrfy.org>
To: pmladek@suse.cz, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430318704-32374-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The extended message formatting used for /dev/kmsg will be used
implement extended consoles.  Factor out msg_print_ext_header() and
msg_print_ext_body() from devkmsg_read().

This is pure restructuring.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Kay Sievers <kay@vrfy.org>
Cc: Petr Mladek <pmladek@suse.cz>
---
 kernel/printk/printk.c | 146 +++++++++++++++++++++++++++----------------------
 1 file changed, 80 insertions(+), 66 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index a115490..51ce4f1 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -511,6 +511,81 @@ static void append_char(char **pp, char *e, char c)
 		*(*pp)++ = c;
 }
 
+static ssize_t msg_print_ext_header(char *buf, size_t size,
+				    struct printk_log *msg, u64 seq,
+				    enum log_flags prev_flags)
+{
+	u64 ts_usec = msg->ts_nsec;
+	char cont = '-';
+
+	do_div(ts_usec, 1000);
+
+	/*
+	 * If we couldn't merge continuation line fragments during the print,
+	 * export the stored flags to allow an optional external merge of the
+	 * records. Merging the records isn't always neccessarily correct, like
+	 * when we hit a race during printing. In most cases though, it produces
+	 * better readable output. 'c' in the record flags mark the first
+	 * fragment of a line, '+' the following.
+	 */
+	if (msg->flags & LOG_CONT && !(prev_flags & LOG_CONT))
+		cont = 'c';
+	else if ((msg->flags & LOG_CONT) ||
+		 ((prev_flags & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
+		cont = '+';
+
+	return scnprintf(buf, size, "%u,%llu,%llu,%c;",
+		       (msg->facility << 3) | msg->level, seq, ts_usec, cont);
+}
+
+static ssize_t msg_print_ext_body(char *buf, size_t size,
+				  char *dict, size_t dict_len,
+				  char *text, size_t text_len)
+{
+	char *p = buf, *e = buf + size;
+	size_t i;
+
+	/* escape non-printable characters */
+	for (i = 0; i < text_len; i++) {
+		unsigned char c = text[i];
+
+		if (c < ' ' || c >= 127 || c == '\\')
+			p += scnprintf(p, e - p, "\\x%02x", c);
+		else
+			append_char(&p, e, c);
+	}
+	append_char(&p, e, '\n');
+
+	if (dict_len) {
+		bool line = true;
+
+		for (i = 0; i < dict_len; i++) {
+			unsigned char c = dict[i];
+
+			if (line) {
+				append_char(&p, e, ' ');
+				line = false;
+			}
+
+			if (c == '\0') {
+				append_char(&p, e, '\n');
+				line = true;
+				continue;
+			}
+
+			if (c < ' ' || c >= 127 || c == '\\') {
+				p += scnprintf(p, e - p, "\\x%02x", c);
+				continue;
+			}
+
+			append_char(&p, e, c);
+		}
+		append_char(&p, e, '\n');
+	}
+
+	return p - buf;
+}
+
 /* /dev/kmsg - userspace message inject/listen interface */
 struct devkmsg_user {
 	u64 seq;
@@ -575,19 +650,12 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 {
 	struct devkmsg_user *user = file->private_data;
 	struct printk_log *msg;
-	char *p, *e;
-	u64 ts_usec;
-	size_t i;
-	char cont = '-';
 	size_t len;
 	ssize_t ret;
 
 	if (!user)
 		return -EBADF;
 
-	p = user->buf;
-	e = user->buf + sizeof(user->buf);
-
 	ret = mutex_lock_interruptible(&user->lock);
 	if (ret)
 		return ret;
@@ -617,71 +685,17 @@ static ssize_t devkmsg_read(struct file *file, char __user *buf,
 	}
 
 	msg = log_from_idx(user->idx);
-	ts_usec = msg->ts_nsec;
-	do_div(ts_usec, 1000);
+	len = msg_print_ext_header(user->buf, sizeof(user->buf),
+				   msg, user->seq, user->prev);
+	len += msg_print_ext_body(user->buf + len, sizeof(user->buf) - len,
+				  log_dict(msg), msg->dict_len,
+				  log_text(msg), msg->text_len);
 
-	/*
-	 * If we couldn't merge continuation line fragments during the print,
-	 * export the stored flags to allow an optional external merge of the
-	 * records. Merging the records isn't always neccessarily correct, like
-	 * when we hit a race during printing. In most cases though, it produces
-	 * better readable output. 'c' in the record flags mark the first
-	 * fragment of a line, '+' the following.
-	 */
-	if (msg->flags & LOG_CONT && !(user->prev & LOG_CONT))
-		cont = 'c';
-	else if ((msg->flags & LOG_CONT) ||
-		 ((user->prev & LOG_CONT) && !(msg->flags & LOG_PREFIX)))
-		cont = '+';
-
-	p += scnprintf(p, e - p, "%u,%llu,%llu,%c;",
-		       (msg->facility << 3) | msg->level,
-		       user->seq, ts_usec, cont);
 	user->prev = msg->flags;
-
-	/* escape non-printable characters */
-	for (i = 0; i < msg->text_len; i++) {
-		unsigned char c = log_text(msg)[i];
-
-		if (c < ' ' || c >= 127 || c == '\\')
-			p += scnprintf(p, e - p, "\\x%02x", c);
-		else
-			append_char(&p, e, c);
-	}
-	append_char(&p, e, '\n');
-
-	if (msg->dict_len) {
-		bool line = true;
-
-		for (i = 0; i < msg->dict_len; i++) {
-			unsigned char c = log_dict(msg)[i];
-
-			if (line) {
-				append_char(&p, e, ' ');
-				line = false;
-			}
-
-			if (c == '\0') {
-				append_char(&p, e, '\n');
-				line = true;
-				continue;
-			}
-
-			if (c < ' ' || c >= 127 || c == '\\') {
-				p += scnprintf(p, e - p, "\\x%02x", c);
-				continue;
-			}
-
-			append_char(&p, e, c);
-		}
-		append_char(&p, e, '\n');
-	}
-
 	user->idx = log_next(user->idx);
 	user->seq++;
 	raw_spin_unlock_irq(&logbuf_lock);
 
-	len = p - user->buf;
 	if (len > count) {
 		ret = -EINVAL;
 		goto out;
-- 
2.1.0
