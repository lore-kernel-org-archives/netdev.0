From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 46/53] perf tools: Squash overwrite setting into channel
Date: Mon, 11 Jan 2016 13:48:37 +0000
Message-ID: <1452520124-2073-47-git-send-email-wangnan0@huawei.com>
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

Make 'overwrite' a channel configuration other than a evlist global
option. With this setting an evlist can have two channels, one is
normal channel, another is overwritable channel.
perf_evlist__channel_for_evsel() ensures events with 'overwrite'
configuration inserted to overwritable channel.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c |  2 +-
 tools/perf/util/evlist.c    | 42 +++++++++++++++++++++++++++---------------
 tools/perf/util/evlist.h    |  5 ++---
 tools/perf/util/evsel.h     |  1 +
 4 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index fee5fd2..fafcee7 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -356,7 +356,7 @@ try_again:
 	}
 
 	perf_evlist__channel_reset(evlist);
-	if (perf_evlist__mmap_ex(evlist, opts->mmap_pages, false,
+	if (perf_evlist__mmap_ex(evlist, opts->mmap_pages,
 				 opts->auxtrace_mmap_pages,
 				 opts->auxtrace_snapshot_mode) < 0) {
 		if (errno == EPERM) {
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index 9187747..dc00840 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -731,7 +731,7 @@ union perf_event *perf_evlist__mmap_read_ex(struct perf_evlist *evlist,
 		return NULL;
 
 	head = perf_mmap__read_head(md);
-	if (evlist->overwrite) {
+	if (perf_evlist__channel_check(evlist, channel, RDONLY)) {
 		/*
 		 * If we're further behind than half the buffer, there's a chance
 		 * the writer will bite our tail and mess up the samples under us.
@@ -820,7 +820,7 @@ void perf_evlist__mmap_consume_ex(struct perf_evlist *evlist,
 		return;
 	}
 
-	if (!evlist->overwrite) {
+	if (!perf_evlist__channel_check(evlist, channel, RDONLY)) {
 		u64 old = md->prev;
 
 		perf_mmap__write_tail(md, old);
@@ -918,7 +918,6 @@ static int perf_evlist__alloc_mmap(struct perf_evlist *evlist)
 }
 
 struct mmap_params {
-	int prot;
 	int mask;
 	struct auxtrace_mmap_params auxtrace_mp;
 };
@@ -926,6 +925,15 @@ struct mmap_params {
 static int __perf_evlist__mmap(struct perf_evlist *evlist, int idx,
 			       struct mmap_params *mp, int fd)
 {
+	int channel = perf_evlist__idx_channel(evlist, idx);
+	int prot = PROT_READ;
+
+	if (channel < 0)
+		return -1;
+
+	if (!perf_evlist__channel_check(evlist, channel, RDONLY))
+		prot |= PROT_WRITE;
+
 	/*
 	 * The last one will be done at perf_evlist__mmap_consume(), so that we
 	 * make sure we don't prevent tools from consuming every last event in
@@ -942,7 +950,7 @@ static int __perf_evlist__mmap(struct perf_evlist *evlist, int idx,
 	atomic_set(&evlist->mmap[idx].refcnt, 2);
 	evlist->mmap[idx].prev = 0;
 	evlist->mmap[idx].mask = mp->mask;
-	evlist->mmap[idx].base = mmap(NULL, evlist->mmap_len, mp->prot,
+	evlist->mmap[idx].base = mmap(NULL, evlist->mmap_len, prot,
 				      MAP_SHARED, fd, 0);
 	if (evlist->mmap[idx].base == MAP_FAILED) {
 		pr_debug2("failed to mmap perf event ring buffer, error %d\n",
@@ -959,9 +967,13 @@ static int __perf_evlist__mmap(struct perf_evlist *evlist, int idx,
 }
 
 static unsigned long
-perf_evlist__channel_for_evsel(struct perf_evsel *evsel __maybe_unused)
+perf_evlist__channel_for_evsel(struct perf_evsel *evsel)
 {
-	return 0;
+	unsigned long flag = 0;
+
+	if (evsel->overwrite)
+		flag |= PERF_EVLIST__CHANNEL_RDONLY;
+	return flag;
 }
 
 static int
@@ -1211,11 +1223,10 @@ int perf_evlist__parse_mmap_pages(const struct option *opt, const char *str,
  * perf_evlist__mmap_ex - Create mmaps to receive events.
  * @evlist: list of events
  * @pages: map length in pages
- * @overwrite: overwrite older events?
  * @auxtrace_pages - auxtrace map length in pages
  * @auxtrace_overwrite - overwrite older auxtrace data?
  *
- * If @overwrite is %false the user needs to signal event consumption using
+ * For writable channel, the user needs to signal event consumption using
  * perf_mmap__write_tail().  Using perf_evlist__mmap_read() does this
  * automatically.
  *
@@ -1225,16 +1236,13 @@ int perf_evlist__parse_mmap_pages(const struct option *opt, const char *str,
  * Return: %0 on success, negative error code otherwise.
  */
 int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
-			 bool overwrite, unsigned int auxtrace_pages,
-			 bool auxtrace_overwrite)
+			 unsigned int auxtrace_pages, bool auxtrace_overwrite)
 {
 	int err;
 	struct perf_evsel *evsel;
 	const struct cpu_map *cpus = evlist->cpus;
 	const struct thread_map *threads = evlist->threads;
-	struct mmap_params mp = {
-		.prot = PROT_READ | (overwrite ? 0 : PROT_WRITE),
-	};
+	struct mmap_params mp;
 
 	err = perf_evlist__channel_complete(evlist);
 	if (err)
@@ -1246,7 +1254,6 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 	if (evlist->pollfd.entries == NULL && perf_evlist__alloc_pollfd(evlist) < 0)
 		return -ENOMEM;
 
-	evlist->overwrite = overwrite;
 	evlist->mmap_len = perf_evlist__mmap_size(pages);
 	pr_debug("mmap size %zuB\n", evlist->mmap_len);
 	mp.mask = evlist->mmap_len - page_size - 1;
@@ -1270,8 +1277,13 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 int perf_evlist__mmap(struct perf_evlist *evlist, unsigned int pages,
 		      bool overwrite)
 {
+	struct perf_evsel *evsel;
+
 	perf_evlist__channel_reset(evlist);
-	return perf_evlist__mmap_ex(evlist, pages, overwrite, 0, false);
+	evlist__for_each(evlist, evsel)
+		evsel->overwrite = overwrite;
+
+	return perf_evlist__mmap_ex(evlist, pages, 0, false);
 }
 
 int perf_evlist__create_maps(struct perf_evlist *evlist, struct target *target)
diff --git a/tools/perf/util/evlist.h b/tools/perf/util/evlist.h
index b652587..21a8b85 100644
--- a/tools/perf/util/evlist.h
+++ b/tools/perf/util/evlist.h
@@ -23,6 +23,7 @@ struct record_opts;
 #define PERF_EVLIST__NR_CHANNELS	2
 enum perf_evlist_mmap_flag {
 	PERF_EVLIST__CHANNEL_ENABLED	= 1,
+	PERF_EVLIST__CHANNEL_RDONLY	= 2,
 };
 
 /**
@@ -45,7 +46,6 @@ struct perf_evlist {
 	int		 nr_entries;
 	int		 nr_groups;
 	int		 nr_mmaps;
-	bool		 overwrite;
 	bool		 enabled;
 	bool		 has_user_cpus;
 	size_t		 mmap_len;
@@ -203,8 +203,7 @@ int perf_evlist__parse_mmap_pages(const struct option *opt,
 				  int unset);
 
 int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
-			 bool overwrite, unsigned int auxtrace_pages,
-			 bool auxtrace_overwrite);
+			 unsigned int auxtrace_pages, bool auxtrace_overwrite);
 int perf_evlist__mmap(struct perf_evlist *evlist, unsigned int pages,
 		      bool overwrite);
 void perf_evlist__munmap(struct perf_evlist *evlist);
diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
index 022fcff..8932a5c 100644
--- a/tools/perf/util/evsel.h
+++ b/tools/perf/util/evsel.h
@@ -115,6 +115,7 @@ struct perf_evsel {
 	bool			tracking;
 	bool			per_pkg;
 	bool			precise_max;
+	bool			overwrite;
 	/* parse modifier helper */
 	int			exclude_GH;
 	int			nr_members;
-- 
1.8.3.4
