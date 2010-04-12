From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch 2/3] sysctl: add proc_do_large_bitmap
Date: Mon, 12 Apr 2010 06:04:14 -0400
Message-ID: <20100412100804.5302.3154.sendpatchset@localhost.localdomain>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481Ab0DLKEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 06:04:33 -0400
In-Reply-To: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>

The new function can be used to read/write large bitmaps via /proc. A
comma separated range format is used for compact output and input
(e.g. 1,3-4,10-10).

Writing into the file will first reset the bitmap then update it
based on the given input.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---

Index: linux-2.6/include/linux/sysctl.h
===================================================================
--- linux-2.6.orig/include/linux/sysctl.h
+++ linux-2.6/include/linux/sysctl.h
@@ -980,6 +980,8 @@ extern int proc_doulongvec_minmax(struct
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
 				      void __user *, size_t *, loff_t *);
+extern int proc_do_large_bitmap(struct ctl_table *, int,
+				void __user *, size_t *, loff_t *);
 
 /*
  * Register a set of sysctl names by calling register_sysctl_table
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -2072,6 +2072,23 @@ static bool isanyof(char c, const char *
 	return true;
 }
 
+static int proc_skip_anyof(char __user **buf, size_t *size,
+			   const char *v, unsigned len)
+{
+	char c;
+
+	while (*size) {
+		if (get_user(c, *buf))
+			return -EFAULT;
+		if (!isanyof(c, v, len))
+			break;
+		(*size)--;
+		(*buf)++;
+	}
+
+	return 0;
+}
+
 #define TMPBUFLEN 22
 /**
  * proc_get_long - reads an ASCII formated integer from a user buffer
@@ -2663,6 +2680,135 @@ static int proc_do_cad_pid(struct ctl_ta
 	return 0;
 }
 
+/**
+ * proc_do_large_bitmap - read/write from/to a large bitmap
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ * @ppos: file position
+ *
+ * The bitmap is stored at table->data and the bitmap length (in bits)
+ * in table->maxlen.
+ *
+ * We use a range comma separated format (e.g. 1,3-4,10-10) so that
+ * large bitmaps may be represented in a compact manner. Writing into
+ * the file will clear the bitmap then update it with the given input.
+ *
+ * Returns 0 on success.
+ */
+int proc_do_large_bitmap(struct ctl_table *table, int write,
+			 void __user *_buffer, size_t *lenp, loff_t *ppos)
+{
+	int err = 0;
+	bool first = 1;
+	size_t left = *lenp;
+	unsigned long bitmap_len = table->maxlen;
+	char __user *buffer = (char __user *) _buffer;
+	unsigned long *bitmap = (unsigned long *) table->data;
+	unsigned long *tmp_bitmap = NULL;
+	char tr_a[] = { '-', ',', '\n', 0 }, tr_b[] = { ',', '\n', 0 }, c;
+	char tr_end[] = { '\n', 0 };
+
+
+	if (!bitmap_len || !left || (*ppos && !write)) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		tmp_bitmap = kzalloc(BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long),
+				     GFP_KERNEL);
+		if (!tmp_bitmap)
+			return -ENOMEM;
+		err = proc_skip_anyof(&buffer, &left, tr_end, sizeof(tr_end));
+		while (!err && left) {
+			unsigned long val_a, val_b;
+			bool neg;
+
+			err = proc_get_long(&buffer, &left, &val_a, &neg, tr_a,
+					     sizeof(tr_a), &c);
+			if (err)
+				break;
+			if (val_a >= bitmap_len || neg) {
+				err = -EINVAL;
+				break;
+			}
+
+			val_b = val_a;
+			if (left) {
+				buffer++;
+				left--;
+			}
+
+			if (c == '-') {
+				err = proc_get_long(&buffer, &left, &val_b,
+						     &neg, tr_b, sizeof(tr_b),
+						     &c);
+				if (err)
+					break;
+				if (val_b >= bitmap_len || neg ||
+				    val_a > val_b) {
+					err = -EINVAL;
+					break;
+				}
+				if (left) {
+					buffer++;
+					left--;
+				}
+			}
+
+			while (val_a <= val_b)
+				set_bit(val_a++, tmp_bitmap);
+
+			first = 0;
+			err = proc_skip_anyof(&buffer, &left, tr_end,
+					      sizeof(tr_end));
+		}
+	} else {
+		unsigned long bit_a, bit_b = 0;
+
+		while (left) {
+			bit_a = find_next_bit(bitmap, bitmap_len, bit_b);
+			if (bit_a >= bitmap_len)
+				break;
+			bit_b = find_next_zero_bit(bitmap, bitmap_len,
+						   bit_a + 1) - 1;
+
+			err = proc_put_long(&buffer, &left, bit_a, 0, first,
+					     ',');
+			if (err)
+				break;
+			if (bit_a != bit_b) {
+				err = proc_put_char(&buffer, &left, '-');
+				if (err)
+					break;
+				err = proc_put_long(&buffer, &left, bit_b, 0,
+						     1, 0);
+				if (err)
+					break;
+			}
+
+			first = 0; bit_b++;
+		}
+		if (!err)
+			err = proc_put_char(&buffer, &left, '\n');
+	}
+
+	if (!err) {
+		if (write)
+			memcpy(bitmap, tmp_bitmap,
+			       BITS_TO_LONGS(bitmap_len) * sizeof(unsigned long));
+		kfree(tmp_bitmap);
+		*lenp -= left;
+		*ppos += *lenp;
+		return 0;
+	} else {
+		kfree(tmp_bitmap);
+		return err;
+	}
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(struct ctl_table *table, int write,
