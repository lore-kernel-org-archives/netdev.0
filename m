From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] bpf: add support for %s specifier to bpf_trace_printk()
Date: Wed, 26 Aug 2015 23:26:59 -0700
Message-ID: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%s specifier makes bpf program and kernel debugging easier.
To make sure that trace_printk won't crash the unsafe string
is copied into stack and unsafe pointer is substituted.
String is also sanitized for printable characters.
The cost of swapping FS in probe_kernel_read is
amortized over 4 chars to improve performance.

Suggested-by: Brendan Gregg <brendan.d.gregg@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
The following C program:
 #include <linux/fs.h>
int foo(struct pt_regs *ctx, struct filename *filename)
{
  void *name = 0;

  bpf_probe_read(&name, sizeof(name), &filename->name);
  bpf_trace_printk("executed %s\\n", name);
  return 0;
}

when attached to kprobe do_execve()
will produce output in /sys/kernel/debug/tracing/trace_pipe :
    make-13492 [002] d..1  3250.997277: : executed /bin/sh
      sh-13493 [004] d..1  3250.998716: : executed /usr/bin/gcc
     gcc-13494 [002] d..1  3250.999822: : executed /usr/lib/gcc/x86_64-linux-gnu/4.7/cc1
     gcc-13495 [002] d..1  3251.006731: : executed /usr/bin/as
     gcc-13496 [002] d..1  3251.011831: : executed /usr/lib/gcc/x86_64-linux-gnu/4.7/collect2
collect2-13497 [000] d..1  3251.012941: : executed /usr/bin/ld

 kernel/trace/bpf_trace.c |   60 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 57 insertions(+), 3 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ef9936df1b04..60d8f95258ed 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -79,13 +79,51 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static bool is_valid_char(char c)
+{
+	return (isprint(c) || isspace(c)) && isascii(c);
+}
+
+/* similar to strncpy_from_user() but with extra checks */
+static void probe_read_string(char *buf, int size, long unsafe_ptr)
+{
+	char dst[4];
+	int i = 0;
+
+	size--;
+	for (;;) {
+		if (probe_kernel_read(dst, (void *) unsafe_ptr, 4))
+			break;
+
+		unsafe_ptr += 4;
+
+		if (dst[0] == 0 || !is_valid_char(dst[0]) || i >= size)
+			break;
+		buf[i++] = dst[0];
+
+		if (dst[1] == 0 || !is_valid_char(dst[1]) || i >= size)
+			break;
+		buf[i++] = dst[1];
+
+		if (dst[2] == 0 || !is_valid_char(dst[2]) || i >= size)
+			break;
+		buf[i++] = dst[2];
+
+		if (dst[3] == 0 || !is_valid_char(dst[3]) || i >= size)
+			break;
+		buf[i++] = dst[3];
+	}
+	buf[i] = 0;
+}
+
 /*
  * limited trace_printk()
- * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
+ * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
  */
 static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 {
 	char *fmt = (char *) (long) r1;
+	char buf[64];
 	int mod[3] = {};
 	int fmt_cnt = 0;
 	int i;
@@ -100,7 +138,7 @@ static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 
 	/* check format string for allowed specifiers */
 	for (i = 0; i < fmt_size; i++) {
-		if ((!isprint(fmt[i]) && !isspace(fmt[i])) || !isascii(fmt[i]))
+		if (!is_valid_char(fmt[i]))
 			return -EINVAL;
 
 		if (fmt[i] != '%')
@@ -114,12 +152,28 @@ static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 		if (fmt[i] == 'l') {
 			mod[fmt_cnt]++;
 			i++;
-		} else if (fmt[i] == 'p') {
+		} else if (fmt[i] == 'p' || fmt[i] == 's') {
 			mod[fmt_cnt]++;
 			i++;
 			if (!isspace(fmt[i]) && !ispunct(fmt[i]) && fmt[i] != 0)
 				return -EINVAL;
 			fmt_cnt++;
+			if (fmt[i - 1] == 's') {
+				switch (fmt_cnt) {
+				case 1:
+					probe_read_string(buf, sizeof(buf), r3);
+					r3 = (long) buf;
+					break;
+				case 2:
+					probe_read_string(buf, sizeof(buf), r4);
+					r4 = (long) buf;
+					break;
+				case 3:
+					probe_read_string(buf, sizeof(buf), r5);
+					r5 = (long) buf;
+					break;
+				}
+			}
 			continue;
 		}
 
-- 
1.7.9.5
