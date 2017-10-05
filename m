From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v7 1/5] bpf: perf event change needed for subsequent bpf helpers
Date: Thu, 5 Oct 2017 09:19:19 -0700
Message-ID: <20171005161923.332790-2-yhs@fb.com>
References: <20171005161923.332790-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39022 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751554AbdJEQUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 12:20:01 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v95GGauV006901
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 09:20:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2ddk53ser2-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 09:20:00 -0700
In-Reply-To: <20171005161923.332790-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does not impact existing functionalities.
It contains the changes in perf event area needed for
subsequent bpf_perf_event_read_value and
bpf_perf_prog_read_value helpers.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/perf_event.h |  7 +++++--
 kernel/bpf/arraymap.c      |  2 +-
 kernel/events/core.c       | 15 +++++++++++++--
 kernel/trace/bpf_trace.c   |  2 +-
 4 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 8e22f24..79b18a2 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -806,6 +806,7 @@ struct perf_output_handle {
 struct bpf_perf_event_data_kern {
 	struct pt_regs *regs;
 	struct perf_sample_data *data;
+	struct perf_event *event;
 };
 
 #ifdef CONFIG_CGROUP_PERF
@@ -884,7 +885,8 @@ perf_event_create_kernel_counter(struct perf_event_attr *attr,
 				void *context);
 extern void perf_pmu_migrate_context(struct pmu *pmu,
 				int src_cpu, int dst_cpu);
-int perf_event_read_local(struct perf_event *event, u64 *value);
+int perf_event_read_local(struct perf_event *event, u64 *value,
+			  u64 *enabled, u64 *running);
 extern u64 perf_event_read_value(struct perf_event *event,
 				 u64 *enabled, u64 *running);
 
@@ -1286,7 +1288,8 @@ static inline const struct perf_event_attr *perf_event_attrs(struct perf_event *
 {
 	return ERR_PTR(-EINVAL);
 }
-static inline int perf_event_read_local(struct perf_event *event, u64 *value)
+static inline int perf_event_read_local(struct perf_event *event, u64 *value,
+					u64 *enabled, u64 *running)
 {
 	return -EINVAL;
 }
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 98c0f00..68d8666 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -492,7 +492,7 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
 
 	ee = ERR_PTR(-EOPNOTSUPP);
 	event = perf_file->private_data;
-	if (perf_event_read_local(event, &value) == -EOPNOTSUPP)
+	if (perf_event_read_local(event, &value, NULL, NULL) == -EOPNOTSUPP)
 		goto err_out;
 
 	ee = bpf_event_entry_gen(perf_file, map_file);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 6bc21e2..902149f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3684,10 +3684,12 @@ static inline u64 perf_event_count(struct perf_event *event)
  *     will not be local and we cannot read them atomically
  *   - must not have a pmu::count method
  */
-int perf_event_read_local(struct perf_event *event, u64 *value)
+int perf_event_read_local(struct perf_event *event, u64 *value,
+			  u64 *enabled, u64 *running)
 {
 	unsigned long flags;
 	int ret = 0;
+	u64 now;
 
 	/*
 	 * Disabling interrupts avoids all counter scheduling (context
@@ -3718,13 +3720,21 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
 		goto out;
 	}
 
+	now = event->shadow_ctx_time + perf_clock();
+	if (enabled)
+		*enabled = now - event->tstamp_enabled;
 	/*
 	 * If the event is currently on this CPU, its either a per-task event,
 	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
 	 * oncpu == -1).
 	 */
-	if (event->oncpu == smp_processor_id())
+	if (event->oncpu == smp_processor_id()) {
 		event->pmu->read(event);
+		if (running)
+			*running = now - event->tstamp_running;
+	} else if (running) {
+		*running = event->total_time_running;
+	}
 
 	*value = local64_read(&event->count);
 out:
@@ -8072,6 +8082,7 @@ static void bpf_overflow_handler(struct perf_event *event,
 	struct bpf_perf_event_data_kern ctx = {
 		.data = data,
 		.regs = regs,
+		.event = event,
 	};
 	int ret = 0;
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index dc498b6..95888ae 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -275,7 +275,7 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
 	if (!ee)
 		return -ENOENT;
 
-	err = perf_event_read_local(ee->event, &value);
+	err = perf_event_read_local(ee->event, &value, NULL, NULL);
 	/*
 	 * this api is ugly since we miss [-22..-2] range of valid
 	 * counter values, but that's uapi
-- 
2.9.5
