From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 33/53] perf record: Introduce record__finish_output() to finish a perf.data
Date: Mon, 11 Jan 2016 13:48:24 +0000
Message-ID: <1452520124-2073-34-git-send-email-wangnan0@huawei.com>
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

Move code for finalizing 'perf.data' to record__finish_output(). It
will be used by following commits to split output to multiple files.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 45 +++++++++++++++++++++++++++++----------------
 1 file changed, 29 insertions(+), 16 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 318b90f..91bf4b1 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -493,6 +493,33 @@ static void record__init_features(struct record *rec)
 	perf_header__clear_feat(&session->header, HEADER_STAT);
 }
 
+static void
+record__finish_output(struct record *rec)
+{
+	struct perf_data_file *file = &rec->file;
+	int fd = perf_data_file__fd(file);
+
+	if (file->is_pipe)
+		return;
+
+	rec->session->header.data_size += rec->bytes_written;
+	file->size = lseek(perf_data_file__fd(file), 0, SEEK_CUR);
+
+	if (!rec->no_buildid) {
+		process_buildids(rec);
+		/*
+		 * We take all buildids when the file contains
+		 * AUX area tracing data because we do not decode the
+		 * trace because it would take too long.
+		 */
+		if (rec->opts.full_auxtrace)
+			dsos__hit_all(rec->session);
+	}
+	perf_session__write_header(rec->session, rec->evlist, fd, true);
+
+	return;
+}
+
 static volatile int workload_exec_errno;
 
 /*
@@ -820,22 +847,8 @@ out_child:
 	/* this will be recalculated during process_buildids() */
 	rec->samples = 0;
 
-	if (!err && !file->is_pipe) {
-		rec->session->header.data_size += rec->bytes_written;
-		file->size = lseek(perf_data_file__fd(file), 0, SEEK_CUR);
-
-		if (!rec->no_buildid) {
-			process_buildids(rec);
-			/*
-			 * We take all buildids when the file contains
-			 * AUX area tracing data because we do not decode the
-			 * trace because it would take too long.
-			 */
-			if (rec->opts.full_auxtrace)
-				dsos__hit_all(rec->session);
-		}
-		perf_session__write_header(rec->session, rec->evlist, fd, true);
-	}
+	if (!err)
+		record__finish_output(rec);
 
 	if (!err && !quiet) {
 		char samples[128];
-- 
1.8.3.4
