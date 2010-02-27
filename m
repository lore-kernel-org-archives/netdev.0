From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v6 2/3] sysctl: add proc_do_large_bitmap
Date: Sat, 27 Feb 2010 03:25:51 +0200
Message-ID: <1267233952-5856-3-git-send-email-opurdila@ixiacom.com>
References: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	WANG Cong <amwang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267233952-5856-1-git-send-email-opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new function can be used to read/write large bitmaps via /proc. A
comma separated range format is used for compact output and input
(e.g. 1,3-4,10-10).

Writing into the file will first reset the bitmap then update it
based on the given input.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Cc: WANG Cong <amwang@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h |    2 +
 kernel/sysctl.c        |  140 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 142 insertions(+), 0 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index f66014c..7bb5cb6 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -980,6 +980,8 @@ extern int proc_doulongvec_minmax(struct ctl_table *, int,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
 				      void __user *, size_t *, loff_t *);
+extern int proc_do_large_bitmap(struct ctl_table *, int,
+				void __user *, size_t *, loff_t *);
 
 /*
  * Register a set of sysctl names by calling register_sysctl_table
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0873846..5d599cd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2071,6 +2071,23 @@ static bool isanyof(char c, const char *v, unsigned len)
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
  * proc_get_ulong - reads an ASCII formated integer from a user buffer
@@ -2662,6 +2679,129 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
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
+		err = proc_skip_anyof(&buffer, &left, tr_end, sizeof(tr_end));
+		while (!err && left) {
+			unsigned long val_a, val_b;
+			bool neg;
+
+			err = proc_get_ulong(&buffer, &left, &val_a, &neg, tr_a,
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
+				err = proc_get_ulong(&buffer, &left, &val_b,
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
+			if (first)
+				bitmap_clear(bitmap, 0, bitmap_len);
+
+			while (val_a <= val_b)
+				set_bit(val_a++, bitmap);
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
+			err = proc_put_ulong(&buffer, &left, bit_a, 0, first,
+					     ',');
+			if (err)
+				break;
+			if (bit_a != bit_b) {
+				err = proc_put_char(&buffer, &left, '-');
+				if (err)
+					break;
+				err = proc_put_ulong(&buffer, &left, bit_b, 0,
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
+	if (first) {
+		if (err)
+			return err;
+		bitmap_clear(bitmap, 0, bitmap_len);
+	}
+	*lenp -= left;
+	*ppos += *lenp;
+	return 0;
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(struct ctl_table *table, int write,
-- 
1.5.6.5
