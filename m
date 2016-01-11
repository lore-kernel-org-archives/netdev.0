From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 38/53] perf record: Disable buildid cache options by default in switch output mode
Date: Mon, 11 Jan 2016 13:48:29 +0000
Message-ID: <1452520124-2073-39-git-send-email-wangnan0@huawei.com>
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

Cost of buildid cache processing is high: read all events in output
perf.data, open elf files to read buildid then copy them into
~/.debug directory. In switch output mode, causes perf stop receiving
from perf events for too long.

Enable no-buildid and no-buildid-cache by default if --switch-output
is provided. Still allow user use --no-no-buildid to explicitly enable
buildid in this case.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index d32facd..790361b 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -1371,8 +1371,36 @@ int cmd_record(int argc, const char **argv, const char *prefix __maybe_unused)
 "If some relocation was applied (e.g. kexec) symbols may be misresolved\n"
 "even with a suitable vmlinux or kallsyms file.\n\n");
 
-	if (rec->no_buildid_cache || rec->no_buildid)
+	if (rec->no_buildid_cache || rec->no_buildid) {
 		disable_buildid_cache();
+	} else if (rec->switch_output) {
+		/*
+		 * In 'perf record --switch-output', disable buildid
+		 * generation by default to reduce data file switching
+		 * overhead. Still generate buildid if they are required
+		 * explicitly using
+		 *
+		 *  perf record --signal-trigger --no-no-buildid \
+		 *              --no-no-buildid-cache
+		 *
+		 * Equals to:
+		 *
+                 * if ((rec->no_buildid || !rec->no_buildid_set) &&
+		 *     (rec->no_buildid_cache || !rec->no_buildid_cache_set))
+		 *         disable_buildid_cache();
+		 */
+		bool disable = true;
+
+		if (rec->no_buildid_set && !rec->no_buildid)
+			disable = false;
+		if (rec->no_buildid_cache_set && !rec->no_buildid_cache)
+			disable = false;
+		if (disable) {
+			rec->no_buildid = true;
+			rec->no_buildid_cache = true;
+			disable_buildid_cache();
+		}
+	}
 
 	if (rec->evlist->nr_entries == 0 &&
 	    perf_evlist__add_default(rec->evlist) < 0) {
-- 
1.8.3.4
