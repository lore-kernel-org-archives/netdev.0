From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 7/8] samples/bpf: tracepoint example
Date: Mon, 4 Apr 2016 21:52:53 -0700
Message-ID: <1459831974-2891931-8-git-send-email-ast@fb.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57067 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755164AbcDEEw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:52:59 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u354mt0a007390
	for <netdev@vger.kernel.org>; Mon, 4 Apr 2016 21:52:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhcb93d-7
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 21:52:58 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 42e29154faea11e596ad0002c99293a0-6c5e23f0 for <netdev@vger.kernel.org>;	Mon,
 04 Apr 2016 21:52:55 -0700
In-Reply-To: <1459831974-2891931-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
