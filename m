From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 tip 4/7] tracing: allow BPF programs to call bpf_trace_printk()
Date: Fri, 27 Feb 2015 16:08:52 -0800
Message-ID: <1425082135-11967-5-git-send-email-ast@plumgrid.com>
References: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Debugging of BPF programs needs some form of printk from the program,
so let programs call limited trace_printk() with %d %u %x %p modifiers only.

Similar to kernel modules, during program load verifier checks whether program
is calling bpf_trace_printk() and if so, kernel allocates trace_printk buffers
and emits big 'this is debug only' banner.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 101e509d1001..4095f3d9a716 100644
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
index 64b918488607..bed16b6925bb 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -41,6 +41,60 @@ static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return ktime_get_ns();
 }
 
+/* limited trace_printk()
+ * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
+ */
+static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
+{
+	char *fmt = (char *) (long) r1;
+	int fmt_cnt = 0;
+	bool mod_l[3] = {};
+	int i;
+
+	/* bpf_check() guarantees that fmt points to bpf program stack and
+	 * fmt_size bytes of it were initialized by bpf program
+	 */
+	if (fmt[fmt_size - 1] != 0)
+		return -EINVAL;
+
+	/* check format string for allowed specifiers */
+	for (i = 0; i < fmt_size; i++)
+		if (fmt[i] == '%') {
+			if (fmt_cnt >= 3)
+				return -EINVAL;
+			i++;
+			if (i >= fmt_size)
+				return -EINVAL;
+
+			if (fmt[i] == 'l') {
+				mod_l[fmt_cnt] = true;
+				i++;
+				if (i >= fmt_size)
+					return -EINVAL;
+			} else if (fmt[i] == 'p') {
+				mod_l[fmt_cnt] = true;
+				fmt_cnt++;
+				continue;
+			}
+
+			if (fmt[i] == 'l') {
+				mod_l[fmt_cnt] = true;
+				i++;
+				if (i >= fmt_size)
+					return -EINVAL;
+			}
+
+			if (fmt[i] != 'd' && fmt[i] != 'u' && fmt[i] != 'x')
+				return -EINVAL;
+			fmt_cnt++;
+		}
+
+	return __trace_printk(1/* fake ip will not be printed */, fmt,
+			      mod_l[0] ? r3 : (u32) r3,
+			      mod_l[1] ? r4 : (u32) r4,
+			      mod_l[2] ? r5 : (u32) r5);
+}
+
 static struct bpf_func_proto kprobe_prog_funcs[] = {
 	[BPF_FUNC_probe_read] = {
 		.func = bpf_probe_read,
@@ -55,6 +109,13 @@ static struct bpf_func_proto kprobe_prog_funcs[] = {
 		.gpl_only = true,
 		.ret_type = RET_INTEGER,
 	},
+	[BPF_FUNC_trace_printk] = {
+		.func = bpf_trace_printk,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_PTR_TO_STACK,
+		.arg2_type = ARG_CONST_STACK_SIZE,
+	},
 };
 
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
@@ -69,6 +130,13 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 	default:
 		if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
 			return NULL;
+
+		if (func_id == BPF_FUNC_trace_printk)
+			/* this program might be calling bpf_trace_printk,
+			 * so allocate per-cpu printk buffers
+			 */
+			trace_printk_init_buffers();
+
 		return &kprobe_prog_funcs[func_id];
 	}
 }
-- 
1.7.9.5
