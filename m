From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v9 tip 5/9] tracing: allow BPF programs to call bpf_trace_printk()
Date: Fri, 20 Mar 2015 16:30:06 -0700
Message-ID: <1426894210-27441-6-git-send-email-ast@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426894210-27441-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Debugging of BPF programs needs some form of printk from the program,
so let programs call limited trace_printk() with %d %u %x %p modifiers only.

Similar to kernel modules, during program load verifier checks whether program
is calling bpf_trace_printk() and if so, kernel allocates trace_printk buffers
and emits big 'this is debug only' banner.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Reviewed-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 238c6883877b..cc47ef41076a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -166,6 +166,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
 	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
+	BPF_FUNC_trace_printk,    /* int bpf_trace_printk(const char *fmt, int fmt_size, ...) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 96371fa2aad9..60a0741569fe 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -10,6 +10,7 @@
 #include <linux/bpf.h>
 #include <linux/filter.h>
 #include <linux/uaccess.h>
+#include <linux/ctype.h>
 #include "trace.h"
 
 static DEFINE_PER_CPU(int, bpf_prog_active);
@@ -90,6 +91,74 @@ static const struct bpf_func_proto bpf_ktime_get_ns_proto = {
 	.ret_type = RET_INTEGER,
 };
 
+/*
+ * limited trace_printk()
+ * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
+ */
+static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
+{
+	char *fmt = (char *) (long) r1;
+	int mod[3] = {};
+	int fmt_cnt = 0;
+	int i;
+
+	/*
+	 * bpf_check()->check_func_arg()->check_stack_boundary()
+	 * guarantees that fmt points to bpf program stack,
+	 * fmt_size bytes of it were initialized and fmt_size > 0
+	 */
+	if (fmt[--fmt_size] != 0)
+		return -EINVAL;
+
+	/* check format string for allowed specifiers */
+	for (i = 0; i < fmt_size; i++) {
+		if ((!isprint(fmt[i]) && !isspace(fmt[i])) || !isascii(fmt[i]))
+			return -EINVAL;
+
+		if (fmt[i] != '%')
+			continue;
+
+		if (fmt_cnt >= 3)
+			return -EINVAL;
+
+		/* fmt[i] != 0 && fmt[last] == 0, so we can access fmt[i + 1] */
+		i++;
+		if (fmt[i] == 'l') {
+			mod[fmt_cnt]++;
+			i++;
+		} else if (fmt[i] == 'p') {
+			mod[fmt_cnt]++;
+			i++;
+			if (!isspace(fmt[i]) && !ispunct(fmt[i]) && fmt[i] != 0)
+				return -EINVAL;
+			fmt_cnt++;
+			continue;
+		}
+
+		if (fmt[i] == 'l') {
+			mod[fmt_cnt]++;
+			i++;
+		}
+
+		if (fmt[i] != 'd' && fmt[i] != 'u' && fmt[i] != 'x')
+			return -EINVAL;
+		fmt_cnt++;
+	}
+
+	return __trace_printk(1/* fake ip will not be printed */, fmt,
+			      mod[0] == 2 ? r3 : mod[0] == 1 ? (long) r3 : (u32) r3,
+			      mod[1] == 2 ? r4 : mod[1] == 1 ? (long) r4 : (u32) r4,
+			      mod[2] == 2 ? r5 : mod[2] == 1 ? (long) r5 : (u32) r5);
+}
+
+static const struct bpf_func_proto bpf_trace_printk_proto = {
+	.func = bpf_trace_printk,
+	.gpl_only = true,
+	.ret_type = RET_INTEGER,
+	.arg1_type = ARG_PTR_TO_STACK,
+	.arg2_type = ARG_CONST_STACK_SIZE,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -103,6 +172,15 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_probe_read_proto;
 	case BPF_FUNC_ktime_get_ns:
 		return &bpf_ktime_get_ns_proto;
+
+	case BPF_FUNC_trace_printk:
+		/*
+		 * this program might be calling bpf_trace_printk,
+		 * so allocate per-cpu printk buffers
+		 */
+		trace_printk_init_buffers();
+
+		return &bpf_trace_printk_proto;
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
