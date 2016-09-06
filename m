From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, net-next] perf, bpf: fix conditional call to bpf_overflow_handler
Date: Tue,  6 Sep 2016 15:10:22 +0200
Message-ID: <20160906131033.1784262-1-arnd@arndb.de>
Cc: Alexei Starovoitov <ast@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly added bpf_overflow_handler function is only built of both
CONFIG_EVENT_TRACING and CONFIG_BPF_SYSCALL are enabled, but the caller
only checks the latter:

kernel/events/core.c: In function 'perf_event_alloc':
kernel/events/core.c:9106:27: error: 'bpf_overflow_handler' undeclared (first use in this function)

This changes the caller so we also skip this call if CONFIG_EVENT_TRACING
is disabled entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: aa6a5f3cb2b2 ("perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT programs")
---
 kernel/events/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I'm not entirely sure if this is the correct solution, please check before applying

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 73d0c6ddfd5b..d3f6374326d8 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -9110,7 +9110,7 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
 	if (!overflow_handler && parent_event) {
 		overflow_handler = parent_event->overflow_handler;
 		context = parent_event->overflow_handler_context;
-#ifdef CONFIG_BPF_SYSCALL
+#if defined(CONFIG_BPF_SYSCALL) && defined(CONFIG_EVENT_TRACING)
 		if (overflow_handler == bpf_overflow_handler) {
 			struct bpf_prog *prog = bpf_prog_inc(parent_event->prog);
 
-- 
2.9.0
