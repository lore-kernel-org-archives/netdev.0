From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 09/10] samples/bpf: tracepoint example
Date: Wed, 6 Apr 2016 18:43:30 -0700
Message-ID: <1459993411-2754735-10-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
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
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

modify offwaketime to work with sched/sched_switch tracepoint
instead of kprobe into finish_task_switch

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/offwaketime_kern.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/samples/bpf/offwaketime_kern.c b/samples/bpf/offwaketime_kern.c
index c0aa5a9b9c48..983629a31c79 100644
--- a/samples/bpf/offwaketime_kern.c
+++ b/samples/bpf/offwaketime_kern.c
@@ -73,7 +73,7 @@ int waker(struct pt_regs *ctx)
 	return 0;
 }
 
-static inline int update_counts(struct pt_regs *ctx, u32 pid, u64 delta)
+static inline int update_counts(void *ctx, u32 pid, u64 delta)
 {
 	struct key_t key = {};
 	struct wokeby_t *woke;
@@ -100,15 +100,33 @@ static inline int update_counts(struct pt_regs *ctx, u32 pid, u64 delta)
 	return 0;
 }
 
+#if 1
+/* taken from /sys/kernel/debug/tracing/events/sched/sched_switch/format */
+struct sched_switch_args {
+	unsigned long long pad;
+	char prev_comm[16];
+	int prev_pid;
+	int prev_prio;
+	long long prev_state;
+	char next_comm[16];
+	int next_pid;
+	int next_prio;
+};
+SEC("tracepoint/sched/sched_switch")
+int oncpu(struct sched_switch_args *ctx)
+{
+	/* record previous thread sleep time */
+	u32 pid = ctx->prev_pid;
+#else
 SEC("kprobe/finish_task_switch")
 int oncpu(struct pt_regs *ctx)
 {
 	struct task_struct *p = (void *) PT_REGS_PARM1(ctx);
+	/* record previous thread sleep time */
+	u32 pid = _(p->pid);
+#endif
 	u64 delta, ts, *tsp;
-	u32 pid;
 
-	/* record previous thread sleep time */
-	pid = _(p->pid);
 	ts = bpf_ktime_get_ns();
 	bpf_map_update_elem(&start, &pid, &ts, BPF_ANY);
 
-- 
2.8.0
