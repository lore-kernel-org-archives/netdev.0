From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 32/53] perf record: Turns auxtrace_snapshot_enable into 3 states
Date: Mon, 11 Jan 2016 13:48:23 +0000
Message-ID: <1452520124-2073-33-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Wang Nan <wangnan0@hauwei.com>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:46456 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933187AbcAKOBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 09:01:46 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

auxtrace_snapshot_enable has only two states (0/1). Turns it into a
triple states enum so SIGUSR2 handler can safely do other works without
triggering auxtrace snapshot.

Signed-off-by: Wang Nan <wangnan0@hauwei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 59 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 49 insertions(+), 10 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 10f1349..318b90f 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -120,7 +120,43 @@ out:
 static volatile int done;
 static volatile int signr = -1;
 static volatile int child_finished;
-static volatile int auxtrace_snapshot_enabled;
+
+static volatile enum {
+	AUXTRACE_SNAPSHOT_OFF = -1,
+	AUXTRACE_SNAPSHOT_DISABLED = 0,
+	AUXTRACE_SNAPSHOT_ENABLED = 1,
+} auxtrace_snapshot_state = AUXTRACE_SNAPSHOT_OFF;
+
+static inline void
+auxtrace_snapshot_on(void)
+{
+	auxtrace_snapshot_state = AUXTRACE_SNAPSHOT_DISABLED;
+}
+
+static inline void
+auxtrace_snapshot_enable(void)
+{
+	if (auxtrace_snapshot_state == AUXTRACE_SNAPSHOT_OFF)
+		return;
+	auxtrace_snapshot_state = AUXTRACE_SNAPSHOT_ENABLED;
+}
+
+static inline void
+auxtrace_snapshot_disable(void)
+{
+	if (auxtrace_snapshot_state == AUXTRACE_SNAPSHOT_OFF)
+		return;
+	auxtrace_snapshot_state = AUXTRACE_SNAPSHOT_DISABLED;
+}
+
+static inline bool
+auxtrace_snapshot_is_enabled(void)
+{
+	if (auxtrace_snapshot_state == AUXTRACE_SNAPSHOT_OFF)
+		return false;
+	return auxtrace_snapshot_state == AUXTRACE_SNAPSHOT_ENABLED;
+}
+
 static volatile int auxtrace_snapshot_err;
 static volatile int auxtrace_record__snapshot_started;
 
@@ -244,7 +280,7 @@ static void record__read_auxtrace_snapshot(struct record *rec)
 	} else {
 		auxtrace_snapshot_err = auxtrace_record__snapshot_finish(rec->itr);
 		if (!auxtrace_snapshot_err)
-			auxtrace_snapshot_enabled = 1;
+			auxtrace_snapshot_enable();
 	}
 }
 
@@ -570,10 +606,13 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 	signal(SIGCHLD, sig_handler);
 	signal(SIGINT, sig_handler);
 	signal(SIGTERM, sig_handler);
-	if (rec->opts.auxtrace_snapshot_mode)
+
+	if (rec->opts.auxtrace_snapshot_mode) {
 		signal(SIGUSR2, snapshot_sig_handler);
-	else
+		auxtrace_snapshot_on();
+	} else {
 		signal(SIGUSR2, SIG_IGN);
+	}
 
 	session = perf_session__new(file, false, tool);
 	if (session == NULL) {
@@ -699,12 +738,12 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 		perf_evlist__enable(rec->evlist);
 	}
 
-	auxtrace_snapshot_enabled = 1;
+	auxtrace_snapshot_enable();
 	for (;;) {
 		unsigned long long hits = rec->samples;
 
 		if (record__mmap_read_all(rec) < 0) {
-			auxtrace_snapshot_enabled = 0;
+			auxtrace_snapshot_disable();
 			err = -1;
 			goto out_child;
 		}
@@ -742,12 +781,12 @@ static int __cmd_record(struct record *rec, int argc, const char **argv)
 		 * disable events in this case.
 		 */
 		if (done && !disabled && !target__none(&opts->target)) {
-			auxtrace_snapshot_enabled = 0;
+			auxtrace_snapshot_disable();
 			perf_evlist__disable(rec->evlist);
 			disabled = true;
 		}
 	}
-	auxtrace_snapshot_enabled = 0;
+	auxtrace_snapshot_disable();
 
 	if (forks && workload_exec_errno) {
 		char msg[STRERR_BUFSIZE];
@@ -1301,9 +1340,9 @@ out_symbol_exit:
 
 static void snapshot_sig_handler(int sig __maybe_unused)
 {
-	if (!auxtrace_snapshot_enabled)
+	if (!auxtrace_snapshot_is_enabled())
 		return;
-	auxtrace_snapshot_enabled = 0;
+	auxtrace_snapshot_disable();
 	auxtrace_snapshot_err = auxtrace_record__snapshot_start(record.itr);
 	auxtrace_record__snapshot_started = 1;
 }
-- 
1.8.3.4
