From: Kaixu Xia <xiakaixu@huawei.com>
Subject: [PATCH V3 2/2] bpf: control all the perf events stored in PERF_EVENT_ARRAY maps
Date: Fri, 16 Oct 2015 07:42:13 +0000
Message-ID: <1444981333-70429-3-git-send-email-xiakaixu@huawei.com>
References: <1444981333-70429-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiakaixu@huawei.com>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: <ast@plumgrid.com>, <davem@davemloft.net>, <acme@kernel.org>,
	<mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444981333-70429-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the function that controlling all the perf
events stored in PERF_EVENT_ARRAY maps by setting the parameter
'index' to maps max_entries.

Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>
---
 kernel/trace/bpf_trace.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3175600..4b385863 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -229,13 +229,30 @@ static u64 bpf_perf_event_dump_control(u64 r1, u64 index, u64 flag, u64 r4, u64
 	struct bpf_map *map = (struct bpf_map *) (unsigned long) r1;
 	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct perf_event *event;
+	int i;
 
-	if (unlikely(index >= array->map.max_entries))
+	if (unlikely(index > array->map.max_entries))
 		return -E2BIG;
 
 	if (flag & BIT_FLAG_CHECK)
 		return -EINVAL;
 
+	if (index == array->map.max_entries) {
+		bool dump_control = flag & BIT_DUMP_CTL;
+
+		for (i = 0; i < array->map.max_entries; i++) {
+			event = (struct perf_event *)array->ptrs[i];
+			if (!event)
+				continue;
+
+			if (dump_control)
+				atomic_dec_if_positive(&event->dump_enable);
+			else
+				atomic_inc_unless_negative(&event->dump_enable);
+		}
+		return 0;
+	}
+
 	event = (struct perf_event *)array->ptrs[index];
 	if (!event)
 		return -ENOENT;
@@ -244,7 +261,6 @@ static u64 bpf_perf_event_dump_control(u64 r1, u64 index, u64 flag, u64 r4, u64
 		atomic_dec_if_positive(&event->dump_enable);
 	else
 		atomic_inc_unless_negative(&event->dump_enable);
-
 	return 0;
 }
 
-- 
1.8.3.4
