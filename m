From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all perf_event types
Date: Thu, 25 May 2017 22:55:47 -0700
Message-ID: <20170526055549.557818-2-ast@fb.com>
References: <20170526055549.557818-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526055549.557818-1-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teng Qin <qinteng@fb.com>

Allow BPF program to attach to all perf_event types supported
by the current bpf and perf code logic, including HW_CACHE, RAW,
and dynamic pmu events.

Also add support for reading these event counters using
bpf_perf_event_read() helper.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/arraymap.c    | 26 +++++++++++---------------
 kernel/events/core.c     |  6 +-----
 kernel/trace/bpf_trace.c |  4 ++--
 3 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5e00b2333c26..55ffa9949128 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -462,26 +462,22 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 
 	event = perf_file->private_data;
 	ee = ERR_PTR(-EINVAL);
+	/* Per-task events are not supported */
+	if (event->attach_state & PERF_ATTACH_TASK)
+		goto err_out;
 
 	attr = perf_event_attrs(event);
 	if (IS_ERR(attr) || attr->inherit)
 		goto err_out;
+	/* TRACEPOINT and BREAKPOINT not supported in perf_event_read_local */
+	if (attr->type == PERF_TYPE_TRACEPOINT ||
+	    attr->type == PERF_TYPE_BREAKPOINT)
+		goto err_out;
 
-	switch (attr->type) {
-	case PERF_TYPE_SOFTWARE:
-		if (attr->config != PERF_COUNT_SW_BPF_OUTPUT)
-			goto err_out;
-		/* fall-through */
-	case PERF_TYPE_RAW:
-	case PERF_TYPE_HARDWARE:
-		ee = bpf_event_entry_gen(perf_file, map_file);
-		if (ee)
-			return ee;
-		ee = ERR_PTR(-ENOMEM);
-		/* fall-through */
-	default:
-		break;
-	}
+	ee = bpf_event_entry_gen(perf_file, map_file);
+	if (ee)
+		return ee;
+	ee = ERR_PTR(-ENOMEM);
 
 err_out:
 	fput(perf_file);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6e75a5c9412d..52f667046599 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8037,12 +8037,8 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	bool is_kprobe, is_tracepoint;
 	struct bpf_prog *prog;
 
-	if (event->attr.type == PERF_TYPE_HARDWARE ||
-	    event->attr.type == PERF_TYPE_SOFTWARE)
-		return perf_event_set_bpf_handler(event, prog_fd);
-
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
-		return -EINVAL;
+		return perf_event_set_bpf_handler(event, prog_fd);
 
 	if (event->tp_event->prog)
 		return -EEXIST;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 460a031c77e5..8425bf193f39 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -248,8 +248,8 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 		return -ENOENT;
 
 	event = ee->event;
-	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
-		     event->attr.type != PERF_TYPE_RAW))
+	if (unlikely(event->attr.type == PERF_TYPE_SOFTWARE &&
+		     event->attr.config == PERF_COUNT_SW_BPF_OUTPUT))
 		return -EINVAL;
 
 	/* make sure event is local and doesn't have pmu::count */
-- 
2.9.3
