From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 28/53] perf tools: Move timestamp creation to util
Date: Mon, 11 Jan 2016 13:48:19 +0000
Message-ID: <1452520124-2073-29-git-send-email-wangnan0@huawei.com>
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

Timestamp generation becomes a public available helper. Which will
be used by 'perf record', help it output to split output file based
on time.

For example:

 perf.data.2015122620363710
 perf.data.2015122620364092
 perf.data.2015122620365423
 ...

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-buildid-cache.c | 14 +-------------
 tools/perf/util/util.c             | 17 +++++++++++++++++
 tools/perf/util/util.h             |  1 +
 3 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/tools/perf/builtin-buildid-cache.c b/tools/perf/builtin-buildid-cache.c
index d93bff7..632efc6 100644
--- a/tools/perf/builtin-buildid-cache.c
+++ b/tools/perf/builtin-buildid-cache.c
@@ -38,19 +38,7 @@ static int build_id_cache__kcore_buildid(const char *proc_dir, char *sbuildid)
 
 static int build_id_cache__kcore_dir(char *dir, size_t sz)
 {
-	struct timeval tv;
-	struct tm tm;
-	char dt[32];
-
-	if (gettimeofday(&tv, NULL) || !localtime_r(&tv.tv_sec, &tm))
-		return -1;
-
-	if (!strftime(dt, sizeof(dt), "%Y%m%d%H%M%S", &tm))
-		return -1;
-
-	scnprintf(dir, sz, "%s%02u", dt, (unsigned)tv.tv_usec / 10000);
-
-	return 0;
+	return fetch_current_timestamp(dir, sz);
 }
 
 static bool same_kallsyms_reloc(const char *from_dir, char *to_dir)
diff --git a/tools/perf/util/util.c b/tools/perf/util/util.c
index 88b8f8d..5b8259b 100644
--- a/tools/perf/util/util.c
+++ b/tools/perf/util/util.c
@@ -690,3 +690,20 @@ out:
 
 	return tip;
 }
+
+int fetch_current_timestamp(char *buf, size_t sz)
+{
+	struct timeval tv;
+	struct tm tm;
+	char dt[32];
+
+	if (gettimeofday(&tv, NULL) || !localtime_r(&tv.tv_sec, &tm))
+		return -1;
+
+	if (!strftime(dt, sizeof(dt), "%Y%m%d%H%M%S", &tm))
+		return -1;
+
+	scnprintf(buf, sz, "%s%02u", dt, (unsigned)tv.tv_usec / 10000);
+
+	return 0;
+}
diff --git a/tools/perf/util/util.h b/tools/perf/util/util.h
index fe915e6..ef97038 100644
--- a/tools/perf/util/util.h
+++ b/tools/perf/util/util.h
@@ -343,5 +343,6 @@ int fetch_kernel_version(unsigned int *puint,
 #define KVER_PARAM(x)	KVER_VERSION(x), KVER_PATCHLEVEL(x), KVER_SUBLEVEL(x)
 
 const char *perf_tip(const char *dirpath);
+int fetch_current_timestamp(char *buf, size_t sz);
 
 #endif /* GIT_COMPAT_UTIL_H */
-- 
1.8.3.4
