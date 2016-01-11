From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 30/53] perf record: Extract synthesize code to record__synthesize()
Date: Mon, 11 Jan 2016 13:48:21 +0000
Message-ID: <1452520124-2073-31-git-send-email-wangnan0@huawei.com>
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

Create record__synthesize(). It can be used to creating tracking events
for each perf.data after perf supporting splitting into multiple
outputs.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 132 +++++++++++++++++++++++++-------------------
 1 file changed, 76 insertions(+), 56 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index bd1692c..10f1349 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -475,6 +475,81 @@ static void workload_exec_failed_signal(int signo __maybe_unused,
 
 static void snapshot_sig_handler(int sig);
 
+static int record__synthesize(struct record *rec)
+{
+	struct perf_session *session = rec->session;
+	struct machine *machine = &session->machines.host;
+	struct perf_data_file *file = &rec->file;
+	struct record_opts *opts = &rec->opts;
+	struct perf_tool *tool = &rec->tool;
+	int fd = perf_data_file__fd(file);
+	int err = 0;
+	static bool warned_kmaps = false, warned_modules = false;
+
+	if (file->is_pipe) {
+		err = perf_event__synthesize_attrs(tool, session,
+						   process_synthesized_event);
+		if (err < 0) {
+			pr_err("Couldn't synthesize attrs.\n");
+			goto out;
+		}
+
+		if (have_tracepoints(&rec->evlist->entries)) {
+			/*
+			 * FIXME err <= 0 here actually means that
+			 * there were no tracepoints so its not really
+			 * an error, just that we don't need to
+			 * synthesize anything.  We really have to
+			 * return this more properly and also
+			 * propagate errors that now are calling die()
+			 */
+			err = perf_event__synthesize_tracing_data(tool,	fd, rec->evlist,
+								  process_synthesized_event);
+			if (err <= 0) {
+				pr_err("Couldn't record tracing data.\n");
+				goto out;
+			}
+			rec->bytes_written += err;
+		}
+	}
+
+	if (rec->opts.full_auxtrace) {
+		err = perf_event__synthesize_auxtrace_info(rec->itr, tool,
+					session, process_synthesized_event);
+		if (err)
+			goto out;
+	}
+
+	err = perf_event__synthesize_kernel_mmap(tool, process_synthesized_event,
+						 machine);
+	if (err < 0 && !warned_kmaps) {
+		warned_kmaps = true;
+		pr_err("Couldn't record kernel reference relocation symbol\n"
+		       "Symbol resolution may be skewed if relocation was used (e.g. kexec).\n"
+		       "Check /proc/kallsyms permission or run as root.\n");
+	}
+
+	err = perf_event__synthesize_modules(tool, process_synthesized_event,
+					     machine);
+	if (err < 0 && !warned_modules) {
+		warned_modules = true;
+		pr_err("Couldn't record kernel module information.\n"
+		       "Symbol resolution may be skewed if relocation was used (e.g. kexec).\n"
+		       "Check /proc/modules permission or run as root.\n");
+	}
+
+	if (perf_guest) {
+		machines__process_guests(&session->machines,
+					 perf_event__synthesize_guest_os, tool);
+	}
+
+	err = __machine__synthesize_threads(machine, tool, &opts->target, rec->evlist->threads,
+					    process_synthesized_event, opts->sample_address,
+					    opts->proc_map_timeout);
+out:
+	return err;
+}
+
 static int __cmd_record(struct record *rec, int argc, const char **argv)
 {
 	int err;
@@ -569,63 +644,8 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 
 	machine = &session->machines.host;
 
-	if (file->is_pipe) {
-		err = perf_event__synthesize_attrs(tool, session,
-						   process_synthesized_event);
-		if (err < 0) {
-			pr_err("Couldn't synthesize attrs.\n");
-			goto out_child;
-		}
-
-		if (have_tracepoints(&rec->evlist->entries)) {
-			/*
-			 * FIXME err <= 0 here actually means that
-			 * there were no tracepoints so its not really
-			 * an error, just that we don't need to
-			 * synthesize anything.  We really have to
-			 * return this more properly and also
-			 * propagate errors that now are calling die()
-			 */
-			err = perf_event__synthesize_tracing_data(tool,	fd, rec->evlist,
-								  process_synthesized_event);
-			if (err <= 0) {
-				pr_err("Couldn't record tracing data.\n");
-				goto out_child;
-			}
-			rec->bytes_written += err;
-		}
-	}
-
-	if (rec->opts.full_auxtrace) {
-		err = perf_event__synthesize_auxtrace_info(rec->itr, tool,
-					session, process_synthesized_event);
-		if (err)
-			goto out_delete_session;
-	}
-
-	err = perf_event__synthesize_kernel_mmap(tool, process_synthesized_event,
-						 machine);
-	if (err < 0)
-		pr_err("Couldn't record kernel reference relocation symbol\n"
-		       "Symbol resolution may be skewed if relocation was used (e.g. kexec).\n"
-		       "Check /proc/kallsyms permission or run as root.\n");
-
-	err = perf_event__synthesize_modules(tool, process_synthesized_event,
-					     machine);
+	err = record__synthesize(rec);
 	if (err < 0)
-		pr_err("Couldn't record kernel module information.\n"
-		       "Symbol resolution may be skewed if relocation was used (e.g. kexec).\n"
-		       "Check /proc/modules permission or run as root.\n");
-
-	if (perf_guest) {
-		machines__process_guests(&session->machines,
-					 perf_event__synthesize_guest_os, tool);
-	}
-
-	err = __machine__synthesize_threads(machine, tool, &opts->target, rec->evlist->threads,
-					    process_synthesized_event, opts->sample_address,
-					    opts->proc_map_timeout);
-	if (err != 0)
 		goto out_child;
 
 	if (rec->realtime_prio) {
-- 
1.8.3.4
