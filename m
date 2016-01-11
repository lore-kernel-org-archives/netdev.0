From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 35/53] perf record: Add '--timestamp-filename' option to append timestamp to output filename
Date: Mon, 11 Jan 2016 13:48:26 +0000
Message-ID: <1452520124-2073-36-git-send-email-wangnan0@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:56171 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932267AbcAKO0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 09:26:34 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This options append current timestamp to output. For example:

 # perf record -a --timestamp-filename
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Dump perf.data.2015122622265847 ]
 [ perf record: Captured and wrote 0.742 MB perf.data (90 samples) ]
 # ls
 perf.data.201512262226584

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 47 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 7a26cb5..605cccc 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -53,6 +53,7 @@ struct record {
 	bool			no_buildid_set;
 	bool			no_buildid_cache;
 	bool			no_buildid_cache_set;
+	bool			timestamp_filename;
 	unsigned long long	samples;
 };
 
@@ -522,6 +523,37 @@ record__finish_output(struct record *rec)
 	return;
 }
 
+static int
+record__switch_output(struct record *rec, bool at_exit)
+{
+	struct perf_data_file *file = &rec->file;
+	int fd, err;
+
+	/* Same Size:      "2015122520103046"*/
+	char timestamp[] = "InvalidTimestamp";
+
+	rec->samples = 0;
+	record__finish_output(rec);
+	err = fetch_current_timestamp(timestamp, sizeof(timestamp));
+	if (err) {
+		pr_err("Failed to get current timestamp\n");
+		return -EINVAL;
+	}
+
+	fd = perf_data_file__switch(file, timestamp,
+				    rec->session->header.data_offset,
+				    at_exit);
+	if (fd >= 0 && !at_exit) {
+		rec->bytes_written = 0;
+		rec->session->header.data_size = 0;
+	}
+
+	if (!quiet)
+		fprintf(stderr, "[ perf record: Dump %s.%s ]\n",
+			file->path, timestamp);
+	return fd;
+}
+
 static volatile int workload_exec_errno;
 
 /*
@@ -849,8 +881,17 @@ out_child:
 	/* this will be recalculated during process_buildids() */
 	rec->samples = 0;
 
-	if (!err)
-		record__finish_output(rec);
+	if (!err) {
+		if (!rec->timestamp_filename) {
+			record__finish_output(rec);
+		} else {
+			fd = record__switch_output(rec, true);
+			if (fd < 0) {
+				status = fd;
+				goto out_delete_session;
+			}
+		}
+	}
 
 	if (!err && !quiet) {
 		char samples[128];
@@ -1225,6 +1266,8 @@ struct option __record_options[] = {
 		   "options passed to clang when compiling BPF scriptlets"),
 	OPT_STRING(0, "vmlinux", &symbol_conf.vmlinux_name,
 		   "file", "vmlinux pathname"),
+	OPT_BOOLEAN(0, "timestamp-filename", &record.timestamp_filename,
+		    "append timestamp to output filename"),
 	OPT_END()
 };
 
-- 
1.8.3.4
