From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, REPORT] bpf_trace: build error without PERF_EVENTS
Date: Tue, 10 Nov 2015 13:55:33 +0100
Message-ID: <4525348.Aq9YoXkChv@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In my ARM randconfig tests, I'm getting a build error for
newly added code in bpf_perf_event_read and bpf_perf_event_output
whenever CONFIG_PERF_EVENTS is disabled:

kernel/trace/bpf_trace.c: In function 'bpf_perf_event_read':
kernel/trace/bpf_trace.c:203:11: error: 'struct perf_event' has no member named 'oncpu'
if (event->oncpu != smp_processor_id() ||
         ^
kernel/trace/bpf_trace.c:204:11: error: 'struct perf_event' has no member named 'pmu'
      event->pmu->count)

This can happen when UPROBE_EVENT is enabled but KPROBE_EVENT
is disabled. I'm not sure if that is a configuration we care
about, otherwise we could prevent this case from occuring by
adding Kconfig dependencies.

Simply hiding the broken code inside #ifdef CONFIG_PERF_EVENTS
as this patch does seems to reliably fix the error as well,
I have built thousands of randconfig kernels since I started
seeing this and added the workaround.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 62544ce8e01c ("bpf: fix bpf_perf_event_read() helper")
Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
---
I suspect my patch is not the right answer, but could someone please
fix this?

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4228fd3682c3..82e0bc9d002a 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -186,6 +186,7 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
 	return &bpf_trace_printk_proto;
 }
 
+#if IS_ENABLED(CONFIG_PERF_EVENTS)
 static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
 {
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
@@ -263,6 +264,7 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.arg4_type	= ARG_PTR_TO_STACK,
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
+#endif
 
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
@@ -289,10 +291,12 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return bpf_get_trace_printk_proto();
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
+#if IS_ENABLED(CONFIG_PERF_EVENTS)
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
 	case BPF_FUNC_perf_event_output:
 		return &bpf_perf_event_output_proto;
+#endif
 	default:
 		return NULL;
 	}
