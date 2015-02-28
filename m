From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 tip 3/7] tracing: allow BPF programs to call ktime_get_ns()
Date: Fri, 27 Feb 2015 16:08:51 -0800
Message-ID: <1425082135-11967-4-git-send-email-ast@plumgrid.com>
References: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425082135-11967-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

bpf_ktime_get_ns() is used by programs to compue time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4486d36d2e9e..101e509d1001 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -165,6 +165,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
+	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index bcce9b238dad..64b918488607 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -36,6 +36,11 @@ static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return probe_kernel_read(dst, unsafe_ptr, size);
 }
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return ktime_get_ns();
+}
+
 static struct bpf_func_proto kprobe_prog_funcs[] = {
 	[BPF_FUNC_probe_read] = {
 		.func = bpf_probe_read,
@@ -45,6 +50,11 @@ static struct bpf_func_proto kprobe_prog_funcs[] = {
 		.arg2_type = ARG_CONST_STACK_SIZE,
 		.arg3_type = ARG_ANYTHING,
 	},
+	[BPF_FUNC_ktime_get_ns] = {
+		.func = bpf_ktime_get_ns,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+	},
 };
 
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
-- 
1.7.9.5
