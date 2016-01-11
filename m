From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 53/53] perf record: Allow generate tracking events at the end of output
Date: Mon, 11 Jan 2016 13:48:44 +0000
Message-ID: <1452520124-2073-54-git-send-email-wangnan0@huawei.com>
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

Before this patch tracking events are generated based on information in
/proc before all samples. However, with the introducing of overwrite
evsel in perf record, it becomes inconvenience: 'perf record' now can
executed as a daemon for sereval hours and only capture the last
snapshot when it receives SIGUSR2. The tracking events generated at
the head of output 'perf.data' becomes too old, but most of tracking
events during 'perf record' running are dropped.

This patch generates tracking events at the end of output. The output
events series would better reflecting status of system when SIGUSR2
received.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 62 +++++++++++++++++++++++++++++++--------------
 1 file changed, 43 insertions(+), 19 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 6ec0529..c1023ce 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -56,6 +56,7 @@ struct record {
 	bool			no_buildid_cache_set;
 	bool			timestamp_filename;
 	bool			switch_output;
+	bool			tail_tracking;
 	bool			tailsize_evt_stopped;
 	unsigned long long	samples;
 };
@@ -639,6 +640,26 @@ record__finish_output(struct record *rec)
 
 static int record__synthesize(struct record *rec);
 
+static void record__synthesize_target(struct record *rec)
+{
+	if (target__none(&rec->opts.target)) {
+		struct {
+			struct thread_map map;
+			struct thread_map_data map_data;
+		} thread_map;
+
+		thread_map.map.nr = 1;
+		thread_map.map.map[0].pid = rec->evlist->workload.pid;
+		thread_map.map.map[0].comm = NULL;
+		perf_event__synthesize_thread_map(&rec->tool,
+				&thread_map.map,
+				process_synthesized_event,
+				&rec->session->machines.host,
+				rec->opts.sample_address,
+				rec->opts.proc_map_timeout);
+	}
+}
+
 static int
 record__switch_output(struct record *rec, bool at_exit)
 {
@@ -648,6 +669,11 @@ record__switch_output(struct record *rec, bool at_exit)
 	/* Same Size:      "2015122520103046"*/
 	char timestamp[] = "InvalidTimestamp";
 
+	if (rec->tail_tracking) {
+		record__synthesize(rec);
+		record__synthesize_target(rec);
+	}
+
 	rec->samples = 0;
 	record__finish_output(rec);
 	err = fetch_current_timestamp(timestamp, sizeof(timestamp));
@@ -674,23 +700,10 @@ record__switch_output(struct record *rec, bool at_exit)
 		machines__init(&rec->session->machines);
 		perf_session__create_kernel_maps(rec->session);
 		perf_session__set_id_hdr_size(rec->session);
-		record__synthesize(rec);
 
-		if (target__none(&rec->opts.target)) {
-			struct {
-				struct thread_map map;
-				struct thread_map_data map_data;
-			} thread_map;
-
-			thread_map.map.nr = 1;
-			thread_map.map.map[0].pid = rec->evlist->workload.pid;
-			thread_map.map.map[0].comm = NULL;
-			perf_event__synthesize_thread_map(&rec->tool,
-					&thread_map.map,
-					process_synthesized_event,
-					&rec->session->machines.host,
-					rec->opts.sample_address,
-					rec->opts.proc_map_timeout);
+		if (!rec->tail_tracking) {
+			record__synthesize(rec);
+			record__synthesize_target(rec);
 		}
 	}
 	return fd;
@@ -886,9 +899,11 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 
 	machine = &session->machines.host;
 
-	err = record__synthesize(rec);
-	if (err < 0)
-		goto out_child;
+	if (!rec->tail_tracking) {
+		err = record__synthesize(rec);
+		if (err < 0)
+			goto out_child;
+	}
 
 	if (rec->realtime_prio) {
 		struct sched_param param;
@@ -1021,6 +1036,13 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 			disabled = true;
 		}
 	}
+
+	if (rec->tail_tracking) {
+		err = record__synthesize(rec);
+		if (err < 0)
+			goto out_child;
+	}
+
 	auxtrace_snapshot_disable();
 
 	if (forks && workload_exec_errno) {
@@ -1446,6 +1468,8 @@ struct option __record_options[] = {
 		    "append timestamp to output filename"),
 	OPT_BOOLEAN(0, "switch-output", &record.switch_output,
 		    "Switch output when receive SIGUSR2"),
+	OPT_BOOLEAN(0, "tail-tracking", &record.tail_tracking,
+		    "Generate tracking events at the end of output"),
 	OPT_END()
 };
 
-- 
1.8.3.4
