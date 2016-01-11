From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 40/53] perf record: Generate tracking events for process forked by perf
Date: Mon, 11 Jan 2016 13:48:31 +0000
Message-ID: <1452520124-2073-41-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 'perf record --switch-output' without -a, record__synthesize() in
record__switch_output() won't generate tracking events because there's
no thread_map in evlist. Which causes newly created perf.data doesn't
contain map and comm information.

This patch creates a fake thread_map and directly call
perf_event__synthesize_thread_map() for those events.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 5305a30..aaf3b0f 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -563,6 +563,23 @@ record__switch_output(struct record *rec, bool at_exit)
 		perf_session__create_kernel_maps(rec->session);
 		perf_session__set_id_hdr_size(rec->session);
 		record__synthesize(rec);
+
+		if (target__none(&rec->opts.target)) {
+			struct {
+				struct thread_map map;
+				struct thread_map_data map_data;
+			} thread_map;
+
+			thread_map.map.nr = 1;
+			thread_map.map.map[0].pid = rec->evlist->workload.pid;
+			thread_map.map.map[0].comm = NULL;
+			perf_event__synthesize_thread_map(&rec->tool,
+					&thread_map.map,
+					process_synthesized_event,
+					&rec->session->machines.host,
+					rec->opts.sample_address,
+					rec->opts.proc_map_timeout);
+		}
 	}
 	return fd;
 }
-- 
1.8.3.4
