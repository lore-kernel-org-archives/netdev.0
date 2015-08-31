From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] lib: move strncpy_from_unsafe() into mm/maccess.c
Date: Mon, 31 Aug 2015 08:57:10 -0700
Message-ID: <1441036630-10124-1-git-send-email-ast@plumgrid.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34991 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbbHaP50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 11:57:26 -0400
Received: by pacdd16 with SMTP id dd16so143344864pac.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 08:57:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To fix build errors:
kernel/built-in.o: In function `bpf_trace_printk':
bpf_trace.c:(.text+0x11a254): undefined reference to `strncpy_from_unsafe'
kernel/built-in.o: In function `fetch_memory_string':
trace_kprobe.c:(.text+0x11acf8): undefined reference to `strncpy_from_unsafe'

move strncpy_from_unsafe() next to probe_kernel_read/write()
which use the same memory access style.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Reported-by: Guenter Roeck <linux@roeck-us.net>
Fixes: 1a6877b9c0c2 ("lib: introduce strncpy_from_unsafe()")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
For configs without kprobes and bpf the cost of this unused function is
~200 bytes which I think is a better trade off vs creating
new Kconfig selector just for this single function.
Another alternative is to move it to kernel/trace/trace_kprobe.c,
but then it will lose generality and probably should be removed
from include/linux/uaccess.h, so mm/maccess.c looks the best.

 lib/strncpy_from_user.c |   41 -----------------------------------------
 mm/maccess.c            |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index ead8c4a068d1..e0af6ff73d14 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -112,44 +112,3 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 	return -EFAULT;
 }
 EXPORT_SYMBOL(strncpy_from_user);
-
-/**
- * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
- * @dst:   Destination address, in kernel space.  This buffer must be at
- *         least @count bytes long.
- * @src:   Unsafe address.
- * @count: Maximum number of bytes to copy, including the trailing NUL.
- *
- * Copies a NUL-terminated string from unsafe address to kernel buffer.
- *
- * On success, returns the length of the string INCLUDING the trailing NUL.
- *
- * If access fails, returns -EFAULT (some data may have been copied
- * and the trailing NUL added).
- *
- * If @count is smaller than the length of the string, copies @count-1 bytes,
- * sets the last byte of @dst buffer to NUL and returns @count.
- */
-long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count)
-{
-	mm_segment_t old_fs = get_fs();
-	const void *src = unsafe_addr;
-	long ret;
-
-	if (unlikely(count <= 0))
-		return 0;
-
-	set_fs(KERNEL_DS);
-	pagefault_disable();
-
-	do {
-		ret = __copy_from_user_inatomic(dst++,
-						(const void __user __force *)src++, 1);
-	} while (dst[-1] && ret == 0 && src - unsafe_addr < count);
-
-	dst[-1] = '\0';
-	pagefault_enable();
-	set_fs(old_fs);
-
-	return ret < 0 ? ret : src - unsafe_addr;
-}
diff --git a/mm/maccess.c b/mm/maccess.c
index d53adf9ba84b..34fe24759ed1 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -60,3 +60,44 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
 	return ret ? -EFAULT : 0;
 }
 EXPORT_SYMBOL_GPL(probe_kernel_write);
+
+/**
+ * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
+ * @dst:   Destination address, in kernel space.  This buffer must be at
+ *         least @count bytes long.
+ * @src:   Unsafe address.
+ * @count: Maximum number of bytes to copy, including the trailing NUL.
+ *
+ * Copies a NUL-terminated string from unsafe address to kernel buffer.
+ *
+ * On success, returns the length of the string INCLUDING the trailing NUL.
+ *
+ * If access fails, returns -EFAULT (some data may have been copied
+ * and the trailing NUL added).
+ *
+ * If @count is smaller than the length of the string, copies @count-1 bytes,
+ * sets the last byte of @dst buffer to NUL and returns @count.
+ */
+long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count)
+{
+	mm_segment_t old_fs = get_fs();
+	const void *src = unsafe_addr;
+	long ret;
+
+	if (unlikely(count <= 0))
+		return 0;
+
+	set_fs(KERNEL_DS);
+	pagefault_disable();
+
+	do {
+		ret = __copy_from_user_inatomic(dst++,
+						(const void __user __force *)src++, 1);
+	} while (dst[-1] && ret == 0 && src - unsafe_addr < count);
+
+	dst[-1] = '\0';
+	pagefault_enable();
+	set_fs(old_fs);
+
+	return ret < 0 ? ret : src - unsafe_addr;
+}
-- 
1.7.9.5
