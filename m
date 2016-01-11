From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 45/53] perf tools: Operate multiple channels
Date: Mon, 11 Jan 2016 13:48:36 +0000
Message-ID: <1452520124-2073-46-git-send-email-wangnan0@huawei.com>
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

Before this patch perf operates on only the first channel. Make perf
mmap and read from multiple channels.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c |  3 ++-
 tools/perf/util/evlist.c    | 55 ++++++++++++++++++++++++++++++++++-----------
 tools/perf/util/evlist.h    |  2 +-
 3 files changed, 45 insertions(+), 15 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 1f9fb6e..fee5fd2 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -458,8 +458,9 @@ static int record__mmap_read_all(struct record *rec)
 	u64 bytes_written = rec->bytes_written;
 	int i;
 	int rc = 0;
+	int total_mmaps = perf_evlist__mmap_nr(rec->evlist);
 
-	for (i = 0; i < rec->evlist->nr_mmaps; i++) {
+	for (i = 0; i < total_mmaps; i++) {
 		struct auxtrace_mmap *mm = &rec->evlist->mmap[i].auxtrace_mmap;
 
 		if (rec->evlist->mmap[i].base) {
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index 5a898be..9187747 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -873,6 +873,21 @@ static void __perf_evlist__munmap(struct perf_evlist *evlist, int idx)
 	auxtrace_mmap__munmap(&evlist->mmap[idx].auxtrace_mmap);
 }
 
+static void
+__perf_evlist__munmap_channels(struct perf_evlist *evlist, int _idx)
+{
+	int _ch;
+
+	for (_ch = 0; _ch < perf_evlist__channel_nr(evlist); _ch++) {
+		int err, idx = _idx, ch = _ch;
+
+		err = perf_evlist__channel_idx(evlist, &ch, &idx);
+		if (err < 0)
+			continue;
+		__perf_evlist__munmap(evlist, idx);
+	}
+}
+
 void perf_evlist__munmap(struct perf_evlist *evlist)
 {
 	int i;
@@ -980,26 +995,38 @@ perf_evlist__channel_complete(struct perf_evlist *evlist)
 	return 0;
 }
 
-static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int idx,
+static int perf_evlist__mmap_per_evsel(struct perf_evlist *evlist, int _idx,
 				       struct mmap_params *mp, int cpu,
-				       int thread, int *output)
+				       int thread, int *outputs)
 {
 	struct perf_evsel *evsel;
 
 	evlist__for_each(evlist, evsel) {
-		int fd;
+		int fd, channel, idx, err;
+
+		channel = perf_evlist__channel_find(evlist, evsel, false);
+		if (channel < 0) {
+			pr_err("ERROR: unable to find suitable channel for %s\n",
+			       evsel->name);
+			return -1;
+		}
+
+		idx = _idx;
+		err = perf_evlist__channel_idx(evlist, &channel, &idx);
+		if (err < 0)
+			return err;
 
 		if (evsel->system_wide && thread)
 			continue;
 
 		fd = FD(evsel, cpu, thread);
 
-		if (*output == -1) {
-			*output = fd;
-			if (__perf_evlist__mmap(evlist, idx, mp, *output) < 0)
+		if (outputs[channel] == -1) {
+			outputs[channel] = fd;
+			if (__perf_evlist__mmap(evlist, idx, mp, outputs[channel]) < 0)
 				return -1;
 		} else {
-			if (ioctl(fd, PERF_EVENT_IOC_SET_OUTPUT, *output) != 0)
+			if (ioctl(fd, PERF_EVENT_IOC_SET_OUTPUT, outputs[channel]) != 0)
 				return -1;
 
 			perf_evlist__mmap_get(evlist, idx);
@@ -1039,14 +1066,15 @@ static int perf_evlist__mmap_per_cpu(struct perf_evlist *evlist,
 
 	pr_debug2("perf event ring buffer mmapped per cpu\n");
 	for (cpu = 0; cpu < nr_cpus; cpu++) {
-		int output = -1;
+		int outputs[PERF_EVLIST__NR_CHANNELS];
 
+		memset(outputs, -1, sizeof(outputs));
 		auxtrace_mmap_params__set_idx(&mp->auxtrace_mp, evlist, cpu,
 					      true);
 
 		for (thread = 0; thread < nr_threads; thread++) {
 			if (perf_evlist__mmap_per_evsel(evlist, cpu, mp, cpu,
-							thread, &output))
+							thread, outputs))
 				goto out_unmap;
 		}
 	}
@@ -1055,7 +1083,7 @@ static int perf_evlist__mmap_per_cpu(struct perf_evlist *evlist,
 
 out_unmap:
 	for (cpu = 0; cpu < nr_cpus; cpu++)
-		__perf_evlist__munmap(evlist, cpu);
+		__perf_evlist__munmap_channels(evlist, cpu);
 	return -1;
 }
 
@@ -1067,13 +1095,14 @@ static int perf_evlist__mmap_per_thread(struct perf_evlist *evlist,
 
 	pr_debug2("perf event ring buffer mmapped per thread\n");
 	for (thread = 0; thread < nr_threads; thread++) {
-		int output = -1;
+		int outputs[PERF_EVLIST__NR_CHANNELS];
 
+		memset(outputs, -1, sizeof(outputs));
 		auxtrace_mmap_params__set_idx(&mp->auxtrace_mp, evlist, thread,
 					      false);
 
 		if (perf_evlist__mmap_per_evsel(evlist, thread, mp, 0, thread,
-						&output))
+						outputs))
 			goto out_unmap;
 	}
 
@@ -1081,7 +1110,7 @@ static int perf_evlist__mmap_per_thread(struct perf_evlist *evlist,
 
 out_unmap:
 	for (thread = 0; thread < nr_threads; thread++)
-		__perf_evlist__munmap(evlist, thread);
+		__perf_evlist__munmap_channels(evlist, thread);
 	return -1;
 }
 
diff --git a/tools/perf/util/evlist.h b/tools/perf/util/evlist.h
index 1812652..b652587 100644
--- a/tools/perf/util/evlist.h
+++ b/tools/perf/util/evlist.h
@@ -20,7 +20,7 @@ struct record_opts;
 #define PERF_EVLIST__HLIST_BITS 8
 #define PERF_EVLIST__HLIST_SIZE (1 << PERF_EVLIST__HLIST_BITS)
 
-#define PERF_EVLIST__NR_CHANNELS	1
+#define PERF_EVLIST__NR_CHANNELS	2
 enum perf_evlist_mmap_flag {
 	PERF_EVLIST__CHANNEL_ENABLED	= 1,
 };
-- 
1.8.3.4
