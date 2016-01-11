From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 47/53] perf record: Don't read from and poll overwrite channel
Date: Mon, 11 Jan 2016 13:48:38 +0000
Message-ID: <1452520124-2073-48-git-send-email-wangnan0@huawei.com>
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

Read from overwritable ring buffer is unreliable. Also, there's
no need to poll on a overwritable channel because we don't need
consuming data from it. Only select PULLHUP and PULLERR events.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 15 ++++++++++++++-
 tools/perf/util/evlist.c    | 27 +++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index fafcee7..e55a23f 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -453,6 +453,19 @@ static struct perf_event_header finished_round_event = {
 	.type = PERF_RECORD_FINISHED_ROUND,
 };
 
+static bool record__mmap_should_read(struct record *rec, int idx)
+{
+	int channel = -1;
+
+	if (!rec->evlist->mmap[idx].base)
+		return false;
+	if (perf_evlist__channel_idx(rec->evlist, &channel, &idx))
+		return false;
+	if (perf_evlist__channel_check(rec->evlist, channel, RDONLY))
+		return false;
+	return true;
+}
+
 static int record__mmap_read_all(struct record *rec)
 {
 	u64 bytes_written = rec->bytes_written;
@@ -463,7 +476,7 @@ static int record__mmap_read_all(struct record *rec)
 	for (i = 0; i < total_mmaps; i++) {
 		struct auxtrace_mmap *mm = &rec->evlist->mmap[i].auxtrace_mmap;
 
-		if (rec->evlist->mmap[i].base) {
+		if (record__mmap_should_read(rec, i)) {
 			if (record__mmap_read(rec, i) != 0) {
 				rc = -1;
 				goto out;
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index dc00840..0511fd2 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -461,9 +461,9 @@ int perf_evlist__alloc_pollfd(struct perf_evlist *evlist)
 	return 0;
 }
 
-static int __perf_evlist__add_pollfd(struct perf_evlist *evlist, int fd, int idx)
+static int __perf_evlist__add_pollfd(struct perf_evlist *evlist, int fd, int idx, short revent)
 {
-	int pos = fdarray__add(&evlist->pollfd, fd, POLLIN | POLLERR | POLLHUP);
+	int pos = fdarray__add(&evlist->pollfd, fd, revent | POLLERR | POLLHUP);
 	/*
 	 * Save the idx so that when we filter out fds POLLHUP'ed we can
 	 * close the associated evlist->mmap[] entry.
@@ -479,7 +479,7 @@ static int __perf_evlist__add_pollfd(struct perf_evlist *evlist, int fd, int idx
 
 int perf_evlist__add_pollfd(struct perf_evlist *evlist, int fd)
 {
-	return __perf_evlist__add_pollfd(evlist, fd, -1);
+	return __perf_evlist__add_pollfd(evlist, fd, -1, POLLIN);
 }
 
 static void perf_evlist__munmap_filtered(struct fdarray *fda, int fd)
@@ -1007,6 +1007,22 @@ perf_evlist__channel_complete(struct perf_evlist *evlist)
 	return 0;
 }
 
+static bool
+perf_evlist__should_poll(struct perf_evlist *evlist,
+			 struct perf_evsel *evsel,
+			 int channel, int idx)
+{
+	int err = perf_evlist__channel_idx(evlist, &channel, &idx);
+
+	if (err)
+		return false;
+	if (evsel->system_wide)
+		return false;
+	if (perf_evlist__channel_check(evlist, channel, RDONLY))
+		return false;
+	return true;
+}
+
 static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int _idx,
 				       struct mmap_params *mp, int cpu,
 				       int thread, int *outputs)
@@ -1015,6 +1031,7 @@ static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int _idx,
 
 	evlist__for_each(evlist, evsel) {
 		int fd, channel, idx, err;
+		short revent = POLLIN;
 
 		channel = perf_evlist__channel_find(evlist, evsel, false);
 		if (channel < 0) {
@@ -1044,6 +1061,8 @@ static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int _idx,
 			perf_evlist__mmap_get(evlist, idx);
 		}
 
+		if (!perf_evlist__should_poll(evlist, evsel, channel, idx))
+			revent = 0;
 		/*
 		 * The system_wide flag causes a selected event to be opened
 		 * always without a pid.  Consequently it will never get a
@@ -1052,7 +1071,7 @@ static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int _idx,
 		 * Therefore don't add it for polling.
 		 */
 		if (!evsel->system_wide &&
-		    __perf_evlist__add_pollfd(evlist, fd, idx) < 0) {
+		    __perf_evlist__add_pollfd(evlist, fd, idx, revent) < 0) {
 			perf_evlist__mmap_put(evlist, idx);
 			return -1;
 		}
-- 
1.8.3.4
