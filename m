From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 20/29] tracing: allow eBPF programs to be attached to kprobe/kretprobe
Date: Sun, 24 Aug 2014 13:21:21 -0700
Message-ID: <1408911690-7598-21-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/trace/trace_kprobe.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 282f6e4e5539..b6db92207c99 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -19,6 +19,7 @@
 
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <trace/bpf_trace.h>
 
 #include "trace_probe.h"
 
@@ -930,6 +931,22 @@ __kprobe_trace_func(struct trace_kprobe *tk, struct pt_regs *regs,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (call->flags & TRACE_EVENT_FL_BPF) {
+		struct bpf_context ctx = {};
+		unsigned long args[3];
+		/* get first 3 arguments of the function. x64 syscall ABI uses
+		 * the same 3 registers as x64 calling convention.
+		 * todo: implement it cleanly via arch specific
+		 * regs_get_argument_nth() helper
+		 */
+		syscall_get_arguments(current, regs, 0, 3, args);
+		ctx.arg1 = args[0];
+		ctx.arg2 = args[1];
+		ctx.arg3 = args[2];
+		trace_filter_call_bpf(ftrace_file->filter, &ctx);
+		return;
+	}
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
@@ -978,6 +995,17 @@ __kretprobe_trace_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (call->flags & TRACE_EVENT_FL_BPF) {
+		struct bpf_context ctx = {};
+		/* assume that register used to return a value from syscall is
+		 * the same as register used to return a value from a function
+		 * todo: provide arch specific helper
+		 */
+		ctx.ret = syscall_get_return_value(current, regs);
+		trace_filter_call_bpf(ftrace_file->filter, &ctx);
+		return;
+	}
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
-- 
1.7.9.5
