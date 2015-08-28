From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/2] lib: introduce strncpy_from_unsafe()
Date: Fri, 28 Aug 2015 12:51:48 -0700
Message-ID: <1440791509-5450-2-git-send-email-ast@plumgrid.com>
References: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440791509-5450-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

generalize FETCH_FUNC_NAME(memory, string) into
strncpy_from_unsafe() and fix sparse warnings that were
present in original implementation.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/uaccess.h     |    2 ++
 kernel/trace/trace_kprobe.c |   20 ++++----------------
 lib/strncpy_from_user.c     |   41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
index ae572c138607..d6f2c2c5b043 100644
--- a/include/linux/uaccess.h
+++ b/include/linux/uaccess.h
@@ -129,4 +129,6 @@ extern long __probe_kernel_read(void *dst, const void *src, size_t size);
 extern long notrace probe_kernel_write(void *dst, const void *src, size_t size);
 extern long notrace __probe_kernel_write(void *dst, const void *src, size_t size);
 
+extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
+
 #endif		/* __LINUX_UACCESS_H__ */
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index b7d0cdd9906c..c9956440d0e6 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -165,11 +165,9 @@ DEFINE_BASIC_FETCH_FUNCS(memory)
 static void FETCH_FUNC_NAME(memory, string)(struct pt_regs *regs,
 					    void *addr, void *dest)
 {
-	long ret;
 	int maxlen = get_rloc_len(*(u32 *)dest);
 	u8 *dst = get_rloc_data(dest);
-	u8 *src = addr;
-	mm_segment_t old_fs = get_fs();
+	long ret;
 
 	if (!maxlen)
 		return;
@@ -178,23 +176,13 @@ static void FETCH_FUNC_NAME(memory, string)(struct pt_regs *regs,
 	 * Try to get string again, since the string can be changed while
 	 * probing.
 	 */
-	set_fs(KERNEL_DS);
-	pagefault_disable();
-
-	do
-		ret = __copy_from_user_inatomic(dst++, src++, 1);
-	while (dst[-1] && ret == 0 && src - (u8 *)addr < maxlen);
-
-	dst[-1] = '\0';
-	pagefault_enable();
-	set_fs(old_fs);
+	ret = strncpy_from_unsafe(dst, addr, maxlen);
 
 	if (ret < 0) {	/* Failed to fetch string */
-		((u8 *)get_rloc_data(dest))[0] = '\0';
+		dst[0] = '\0';
 		*(u32 *)dest = make_data_rloc(0, get_rloc_offs(*(u32 *)dest));
 	} else {
-		*(u32 *)dest = make_data_rloc(src - (u8 *)addr,
-					      get_rloc_offs(*(u32 *)dest));
+		*(u32 *)dest = make_data_rloc(ret, get_rloc_offs(*(u32 *)dest));
 	}
 }
 NOKPROBE_SYMBOL(FETCH_FUNC_NAME(memory, string));
diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index e0af6ff73d14..89dce35ee6cf 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -112,3 +112,44 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 	return -EFAULT;
 }
 EXPORT_SYMBOL(strncpy_from_user);
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
+ * On success, returns the length of the string (not including the trailing
+ * NUL).
+ *
+ * If access fails, returns -EFAULT (some data may have been copied).
+ *
+ * If @count is smaller than the length of the string, copies @count bytes
+ * and returns @count.
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
