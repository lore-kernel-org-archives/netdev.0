From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 44/53] perf tools: Automatically add new channel according to evlist
Date: Mon, 11 Jan 2016 13:48:35 +0000
Message-ID: <1452520124-2073-45-git-send-email-wangnan0@huawei.com>
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

perf_evlist__channel_find() can be used to find a proper channel based
on propreties of a evsel. If the channel doesn't exist, it can create
new one for it. After this patch there's no need to create default
channel explicitly.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c |  5 -----
 tools/perf/util/evlist.c    | 47 ++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 21da64d..1f9fb6e 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -356,11 +356,6 @@ try_again:
 	}
 
 	perf_evlist__channel_reset(evlist);
-	rc = perf_evlist__channel_add(evlist, 0, true);
-	if (rc < 0)
-		goto out;
-	rc = 0;
-
 	if (perf_evlist__mmap_ex(evlist, opts->mmap_pages, false,
 				 opts->auxtrace_mmap_pages,
 				 opts->auxtrace_snapshot_mode) < 0) {
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index ff1beac..5a898be 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -943,6 +943,43 @@ static int __perf_evlist__mmap(struct perf_evlist *evlist, int idx,
 	return 0;
 }
 
+static unsigned long
+perf_evlist__channel_for_evsel(struct perf_evsel *evsel __maybe_unused)
+{
+	return 0;
+}
+
+static int
+perf_evlist__channel_find(struct perf_evlist *evlist,
+			  struct perf_evsel *evsel,
+			  bool add_new)
+{
+	unsigned long flag = perf_evlist__channel_for_evsel(evsel);
+	int i;
+
+	flag |= PERF_EVLIST__CHANNEL_ENABLED;
+	for (i = 0; i < perf_evlist__channel_nr(evlist); i++)
+		if (evlist->channel_flags[i] == flag)
+			return i;
+	if (add_new)
+		return perf_evlist__channel_add(evlist, flag, false);
+	return -ENOENT;
+}
+
+static int
+perf_evlist__channel_complete(struct perf_evlist *evlist)
+{
+	struct perf_evsel *evsel;
+	int err;
+
+	evlist__for_each(evlist, evsel) {
+		err = perf_evlist__channel_find(evlist, evsel, true);
+		if (err < 0)
+			return err;
+	}
+	return 0;
+}
+
 static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int idx,
 				       struct mmap_params *mp, int cpu,
 				       int thread, int *output)
@@ -1162,6 +1199,7 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 			 bool overwrite, unsigned int auxtrace_pages,
 			 bool auxtrace_overwrite)
 {
+	int err;
 	struct perf_evsel *evsel;
 	const struct cpu_map *cpus = evlist->cpus;
 	const struct thread_map *threads = evlist->threads;
@@ -1169,6 +1207,10 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 		.prot = PROT_READ | (overwrite ? 0 : PROT_WRITE),
 	};
 
+	err = perf_evlist__channel_complete(evlist);
+	if (err)
+		return err;
+
 	if (evlist->mmap == NULL && perf_evlist__alloc_mmap(evlist) < 0)
 		return -ENOMEM;
 
@@ -1199,12 +1241,7 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 int perf_evlist__mmap(struct perf_evlist *evlist, unsigned int pages,
 		      bool overwrite)
 {
-	int err;
-
 	perf_evlist__channel_reset(evlist);
-	err = perf_evlist__channel_add(evlist, 0, true);
-	if (err < 0)
-		return err;
 	return perf_evlist__mmap_ex(evlist, pages, overwrite, 0, false);
 }
 
-- 
1.8.3.4
