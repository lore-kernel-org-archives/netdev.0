From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/2] perf, bpf: add support for HW_CACHE and RAW events
Date: Mon, 22 May 2017 15:48:39 -0700
Message-ID: <20170522224840.810121-2-ast@fb.com>
References: <20170522224840.810121-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522224840.810121-1-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teng Qin <qinteng@fb.com>

This commit adds support for attach BPF program to RAW and HW_CACHE type
events, and support for read HW_CACHE type event counters in BPF
program. Existing code logic already supports them, so this commit is
just update Enum value checks.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/arraymap.c    | 1 +
 kernel/events/core.c     | 4 +++-
 kernel/trace/bpf_trace.c | 1 +
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 5e00b2333c26..f32affe8c335 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -473,6 +473,7 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 			goto err_out;
 		/* fall-through */
 	case PERF_TYPE_RAW:
+	case PERF_TYPE_HW_CACHE:
 	case PERF_TYPE_HARDWARE:
 		ee = bpf_event_entry_gen(perf_file, map_file);
 		if (ee)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6e75a5c9412d..1b68cb751c03 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8038,7 +8038,9 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	struct bpf_prog *prog;
 
 	if (event->attr.type == PERF_TYPE_HARDWARE ||
-	    event->attr.type == PERF_TYPE_SOFTWARE)
+	    event->attr.type == PERF_TYPE_SOFTWARE ||
+	    event->attr.type == PERF_TYPE_HW_CACHE ||
+	    event->attr.type == PERF_TYPE_RAW)
 		return perf_event_set_bpf_handler(event, prog_fd);
 
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 460a031c77e5..5cbda7962a32 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -249,6 +249,7 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 
 	event = ee->event;
 	if (unlikely(event->attr.type != PERF_TYPE_HARDWARE &&
+		     event->attr.type != PERF_TYPE_HW_CACHE &&
 		     event->attr.type != PERF_TYPE_RAW))
 		return -EINVAL;
 
-- 
2.9.3
