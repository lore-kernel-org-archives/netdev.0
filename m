From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 52/53] perf record: Toggle tailsize ring buffer for reading
Date: Mon, 11 Jan 2016 13:48:43 +0000
Message-ID: <1452520124-2073-53-git-send-email-wangnan0@huawei.com>
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

Toggel tailsize_evt_stopped director after receiving done or switch
output. After this patch it is possible to trigger a dump use SIGUSR2
when something happen.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 6c8905b..6ec0529 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -591,6 +591,26 @@ static void record__init_features(struct record *rec)
 }
 
 static void
+record__toggle_tailsize_evsels(struct record *rec, bool stop)
+{
+	struct perf_evsel *pos;
+	struct perf_evlist *evlist = rec->evlist;
+
+	evlist__for_each(evlist, pos) {
+		if (!pos->tailsize)
+			continue;
+		if (!pos->overwrite)
+			continue;
+		if (stop)
+			perf_evsel__disable(pos);
+		else
+			perf_evsel__enable(pos);
+	}
+
+	rec->tailsize_evt_stopped = stop;
+}
+
+static void
 record__finish_output(struct record *rec)
 {
 	struct perf_data_file *file = &rec->file;
@@ -925,6 +945,9 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 	for (;;) {
 		unsigned long long hits = rec->samples;
 
+		if (switch_output_started || done)
+			record__toggle_tailsize_evsels(rec, true);
+
 		if (record__mmap_read_all(rec) < 0) {
 			auxtrace_snapshot_disable();
 			err = -1;
@@ -943,7 +966,20 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 		}
 
 		if (switch_output_started) {
+			/*
+			 * SIGUSR2 raise after or during record__mmap_read_all().
+			 * continue to read again.
+			 */
+			if (!rec->tailsize_evt_stopped)
+				continue;
+
 			switch_output_started = 0;
+			/* 
+			 * Reenable events in tailsize ring buffer after
+			 * record__mmap_read_all(): we have collected
+			 * data from it.
+			 */
+			record__toggle_tailsize_evsels(rec, false);
 
 			if (!quiet)
 				fprintf(stderr, "[ perf record: dump data: Woken up %ld times ]\n",
-- 
1.8.3.4
