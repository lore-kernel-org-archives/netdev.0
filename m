From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/8] perf: optimize perf_fetch_caller_regs
Date: Mon, 4 Apr 2016 21:52:47 -0700
Message-ID: <1459831974-2891931-2-git-send-email-ast@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459831974-2891931-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

avoid memset in perf_fetch_caller_regs, since it's the critical path of all tracepoints.
It's called from perf_sw_event_sched, perf_event_task_sched_in and all of perf_trace_##call
with this_cpu_ptr(&__perf_regs[..]) which are zero initialized by perpcu_alloc and
subsequent call to perf_arch_fetch_caller_regs initializes the same fields on all archs,
so we can safely drop memset from all of the above cases and move it into
perf_ftrace_function_call that calls it with stack allocated pt_regs.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/perf_event.h      | 2 --
 kernel/trace/trace_event_perf.c | 1 +
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index f291275ffd71..e89f7199c223 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -882,8 +882,6 @@ static inline void perf_arch_fetch_caller_regs(struct pt_regs *regs, unsigned lo
  */
 static inline void perf_fetch_caller_regs(struct pt_regs *regs)
 {
-	memset(regs, 0, sizeof(*regs));
-
 	perf_arch_fetch_caller_regs(regs, CALLER_ADDR0);
 }
 
diff --git a/kernel/trace/trace_event_perf.c b/kernel/trace/trace_event_perf.c
index 00df25fd86ef..7a68afca8249 100644
--- a/kernel/trace/trace_event_perf.c
+++ b/kernel/trace/trace_event_perf.c
@@ -316,6 +316,7 @@ perf_ftrace_function_call(unsigned long ip, unsigned long parent_ip,
 
 	BUILD_BUG_ON(ENTRY_SIZE > PERF_MAX_TRACE_SIZE);
 
+	memset(&regs, 0, sizeof(regs));
 	perf_fetch_caller_regs(&regs);
 
 	entry = perf_trace_buf_prepare(ENTRY_SIZE, TRACE_FN, NULL, &rctx);
-- 
2.8.0
