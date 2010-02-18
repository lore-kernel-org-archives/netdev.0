From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Fri, 19 Feb 2010 00:32:26 +0200
Message-ID: <1266532346-11604-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	WANG Cong <amwang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
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
 kernel/sysctl.c        |  122 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 124 insertions(+), 0 deletions(-)

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
index 5259727..ef2c13d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2635,6 +2635,128 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
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
+	bool first = 1;
+	unsigned long *bitmap = (unsigned long *) table->data;
+	unsigned long bitmap_len = table->maxlen;
+	int left = *lenp, err = 0;
+	char __user *buffer = (char __user *) _buffer;
+	char tr_a[] = { '-', ',', 0 }, tr_b[] = { ',', 0 }, c;
+
+
+	if (!bitmap_len || !left || (*ppos && !write)) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		bitmap_clear(bitmap, 0, bitmap_len);
+		err = proc_skip_wspace(&buffer, &left);
+		while (!err && left) {
+			unsigned long val_a, val_b;
+			bool neg;
+
+			err = proc_get_ulong(&buffer, &left, tr_a,
+					     &val_a, &neg, &c);
+			if (err)
+				break;
+
+			if (val_a >= bitmap_len || neg) {
+				err = -EINVAL;
+				break;
+			}
+
+			if (!left || c != '-') {
+				if (c == ',') {
+					buffer++;
+					left--;
+				}
+				val_b = val_a;
+				goto update;
+			}
+
+			/* skip the - */
+			buffer++; left--;
+
+			err = proc_get_ulong(&buffer, &left, tr_b,
+					     &val_b, &neg, &c);
+			if (err)
+				break;
+
+			if (val_b >= bitmap_len || neg || val_a > val_b) {
+				err = -EINVAL;
+				break;
+			}
+
+			if (left && c == ',') {
+				buffer++;
+				left--;
+			}
+
+update:
+			while (val_a <= val_b)
+				set_bit(val_a++, bitmap);
+
+			first = 0; val_b++;
+		}
+		if (!err)
+			err = proc_skip_wspace(&buffer, &left);
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
+	if (write && first)
+		return err;
+	*lenp -= left;
+	*ppos += *lenp;
+	return 0;
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(struct ctl_table *table, int write,
-- 
1.5.6.5
