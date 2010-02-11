From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v3 2/3] sysctl: add proc_dobitmap
Date: Thu, 11 Feb 2010 04:53:12 +0200
Message-ID: <201002110453.12242.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27874 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754977Ab0BKDAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 22:00:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new function can be used to update bitmaps via /proc. Bits can be
set by writing positive values in the file and cleared by writing
negative values (e.g. 0 2 will set bits 1 and 3, -0 -2 will clear
them). Reading will show only the set bits.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
Cc: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/sysctl.h |    2 +
 kernel/sysctl.c        |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 9f236cd..ba89bf2 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -985,6 +985,8 @@ extern int proc_doulongvec_minmax(struct ctl_table *, int,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
 				      void __user *, size_t *, loff_t *);
+extern int proc_dobitmap(struct ctl_table *, int,
+			 void __user *, size_t *, loff_t *);
 
 /*
  * Register a set of sysctl names by calling register_sysctl_table
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b0f9618..b8959f4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2596,6 +2596,82 @@ static int proc_do_cad_pid(struct ctl_table *table, int write,
 	return 0;
 }
 
+/**
+ * proc_dobitmap - read/write from/to a bitmap
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ * @ppos: file position
+ * @ppos: the current position in the file
+ *
+ * The bitmap is stored at table->data and the bitmap length (in bits)
+ * in table->maxlen. Reading from the proc file will show the set bits.
+ * Writing positive values sets the bits, negative values clears them
+ * (e.g. 0 2 sets the first and 3rd bit, -0 -2 clears them).
+ *
+ * Returns 0 on success.
+ */
+int proc_dobitmap(struct ctl_table *table, int write,
+		  void __user *_buffer, size_t *lenp, loff_t *ppos)
+{
+	bool first = 1;
+	unsigned long *bitmap = (unsigned long *) table->data;
+	unsigned long bitmap_len = table->maxlen;
+	int left = *lenp, err = 0;
+	char __user *buffer = (char __user *) _buffer;
+
+	if (!bitmap_len || !left || (*ppos && !write)) {
+		*lenp = 0;
+		return 0;
+	}
+
+	if (write) {
+		while (left) {
+			unsigned long val;
+			bool neg;
+
+			err = proc_get_next_ulong(&buffer, &left, &val, &neg);
+			if (err)
+				break;
+			if (val >= bitmap_len) {
+				err = -EINVAL;
+				break;
+			}
+			if (neg)
+				clear_bit(val, bitmap);
+			else
+				set_bit(val, bitmap);
+			first = 0;
+		}
+		if (!err)
+			err = proc_skip_wspace(&buffer, &left);
+	} else {
+		unsigned long bit = 0;
+
+		while (left) {
+			bit = find_next_bit(bitmap, bitmap_len, bit);
+			if (bit >= bitmap_len)
+				break;
+			err = proc_put_ulong(&buffer, &left, bit, 0, first);
+			if (err)
+				break;
+			first = 0; bit++;
+		}
+		if (!err)
+			err = proc_put_newline(&buffer, &left);
+	}
+
+	if (first && write && !err)
+		err = -EINVAL;
+	if (err == -EFAULT /* do we really need to check for -EFAULT? */ ||
+	    (write && first))
+		return err ? : -EINVAL;
+	*lenp -= left;
+	*ppos += *lenp;
+	return 0;
+}
+
 #else /* CONFIG_PROC_FS */
 
 int proc_dostring(struct ctl_table *table, int write,
-- 
1.5.6.5

