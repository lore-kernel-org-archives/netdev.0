From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH] tracing: bpf: Hide bpf trace events when they are not used
Date: Thu, 12 Oct 2017 18:40:02 -0400
Message-ID: <20171012184002.0661a867@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt (VMware) <rostedt@goodmis.org>

All the trace events defined in include/trace/events/bpf.h are only
used when CONFIG_BPF_SYSCALL is defined. But this file gets included by
include/linux/bpf_trace.h which is included by the networking code with
CREATE_TRACE_POINTS defined.

If a trace event is created but not used it still has data structures
and functions created for its use, even though nothing is using them.
To not waste space, do not define the BPF trace events in bpf.h unless
CONFIG_BPF_SYSCALL is defined.

Signed-off-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
---
Index: linux-trace.git/include/trace/events/bpf.h
===================================================================
--- linux-trace.git.orig/include/trace/events/bpf.h
+++ linux-trace.git/include/trace/events/bpf.h
@@ -4,6 +4,9 @@
 #if !defined(_TRACE_BPF_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_BPF_H
 
+/* These are only used within the BPF_SYSCALL code */
+#ifdef CONFIG_BPF_SYSCALL
+
 #include <linux/filter.h>
 #include <linux/bpf.h>
 #include <linux/fs.h>
@@ -345,7 +348,7 @@ TRACE_EVENT(bpf_map_next_key,
 		  __print_hex(__get_dynamic_array(nxt), __entry->key_len),
 		  __entry->key_trunc ? " ..." : "")
 );
-
+#endif /* CONFIG_BPF_SYSCALL */
 #endif /* _TRACE_BPF_H */
 
 #include <trace/define_trace.h>
Index: linux-trace.git/kernel/bpf/core.c
===================================================================
--- linux-trace.git.orig/kernel/bpf/core.c
+++ linux-trace.git/kernel/bpf/core.c
@@ -1498,5 +1498,8 @@ int __weak skb_copy_bits(const struct sk
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(xdp_exception);
 
+/* These are only used within the BPF_SYSCALL code */
+#ifdef CONFIG_BPF_SYSCALL
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_get_type);
 EXPORT_TRACEPOINT_SYMBOL_GPL(bpf_prog_put_rcu);
+#endif
