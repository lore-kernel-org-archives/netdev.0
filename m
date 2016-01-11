From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 36/53] perf record: Split output into multiple files via '--switch-output'
Date: Mon, 11 Jan 2016 13:48:27 +0000
Message-ID: <1452520124-2073-37-git-send-email-wangnan0@huawei.com>
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
Received: from lhrrgout.huawei.com ([194.213.3.17]:16573 "EHLO
	lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760115AbcAKOBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 09:01:31 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow 'perf record' splits its output into multiple files.

For example:

 # ~/perf record -a --timestamp-filename --switch-output &
 [1] 10763
 # kill -s SIGUSR2 10763
 [ perf record: dump data: Woken up 1 times ]
 # [ perf record: Dump perf.data.2015122622314468 ]

 # kill -s SIGUSR2 10763
 [ perf record: dump data: Woken up 1 times ]
 # [ perf record: Dump perf.data.2015122622314762 ]

 # kill -s SIGUSR2 10763
 [ perf record: dump data: Woken up 1 times ]
 #[ perf record: Dump perf.data.2015122622315171 ]

 # fg
 perf record -a --timestamp-filename --switch-output
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Dump perf.data.2015122622315513 ]
 [ perf record: Captured and wrote 0.014 MB perf.data (296 samples) ]

 # ls -l
 total 920
 -rw------- 1 root root 797692 Dec 26 22:31 perf.data.2015122622314468
 -rw------- 1 root root  59960 Dec 26 22:31 perf.data.2015122622314762
 -rw------- 1 root root  59912 Dec 26 22:31 perf.data.2015122622315171
 -rw------- 1 root root  19220 Dec 26 22:31 perf.data.2015122622315513

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 605cccc..e8f930c 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -54,6 +54,7 @@ struct record {
 	bool			no_buildid_cache;
 	bool			no_buildid_cache_set;
 	bool			timestamp_filename;
+	bool			switch_output;
 	unsigned long long	samples;
 };
 
@@ -162,6 +163,7 @@ auxtrace_snapshot_is_enabled(void)
 
 static volatile int auxtrace_snapshot_err;
 static volatile int auxtrace_record__snapshot_started;
+static volatile int switch_output_started;
 
 static void sig_handler(int sig)
 {
@@ -668,7 +670,7 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 	signal(SIGINT, sig_handler);
 	signal(SIGTERM, sig_handler);
 
-	if (rec->opts.auxtrace_snapshot_mode) {
+	if (rec->opts.auxtrace_snapshot_mode || rec->switch_output) {
 		signal(SIGUSR2, snapshot_sig_handler);
 		auxtrace_snapshot_on();
 	} else {
@@ -820,9 +822,25 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 			}
 		}
 
+		if (switch_output_started) {
+			switch_output_started = 0;
+
+			if (!quiet)
+				fprintf(stderr, "[ perf record: dump data: Woken up %ld times ]\n",
+					waking);
+			waking = 0;
+			fd = record__switch_output(rec, false);
+			if (fd < 0) {
+				pr_err("Failed to switch to new file\n");
+				err = fd;
+				goto out_child;
+			}
+		}
+
 		if (hits == rec->samples) {
 			if (done || draining)
 				break;
+
 			err = perf_evlist__poll(rec->evlist, -1);
 			/*
 			 * Propagate error, only if there's any. Ignore positive
@@ -1268,6 +1286,8 @@ struct option __record_options[] = {
 		   "file", "vmlinux pathname"),
 	OPT_BOOLEAN(0, "timestamp-filename", &record.timestamp_filename,
 		    "append timestamp to output filename"),
+	OPT_BOOLEAN(0, "switch-output", &record.switch_output,
+		    "Switch output when receive SIGUSR2"),
 	OPT_END()
 };
 
@@ -1400,9 +1420,11 @@ out_symbol_exit:
 
 static void snapshot_sig_handler(int sig __maybe_unused)
 {
-	if (!auxtrace_snapshot_is_enabled())
-		return;
-	auxtrace_snapshot_disable();
-	auxtrace_snapshot_err = auxtrace_record__snapshot_start(record.itr);
-	auxtrace_record__snapshot_started = 1;
+	if (auxtrace_snapshot_is_enabled()) {
+		auxtrace_snapshot_disable();
+		auxtrace_snapshot_err = auxtrace_record__snapshot_start(record.itr);
+		auxtrace_record__snapshot_started = 1;
+	}
+
+	switch_output_started = 1;
 }
-- 
1.8.3.4
