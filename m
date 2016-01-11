From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 43/53] perf tools: Add evlist channel helpers
Date: Mon, 11 Jan 2016 13:48:34 +0000
Message-ID: <1452520124-2073-44-git-send-email-wangnan0@huawei.com>
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

In this commit sereval helpers are introduced to support the principle
of channel. Channels hold different groups of evsels which configured
differently. It will be used for overwritable evsels, which allows perf
record some events continuously while capture snapshot for other events
when something happen. Tracking events (mmap, mmap2, fork, exit ...)
are another possible events worth to be put into a separated channel.

Channels are represented by an array with channel flags. Each channel
contains evlist->nr_mmaps mmaps. Channels are configured before
perf_evlist__mmap_ex(). During that function nr_mmaps mmaps for each
channel are allocated together as a big array.
perf_evlist__channel_idx() converts index in the big array and the
channel number. For API functions which accept idx, _ex() versions are
introduced to accept selecting an mmap from a channel.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c |   6 ++
 tools/perf/util/evlist.c    | 132 ++++++++++++++++++++++++++++++++++++++++++--
 tools/perf/util/evlist.h    |  58 +++++++++++++++++++
 3 files changed, 190 insertions(+), 6 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 3f58426..21da64d 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -355,6 +355,12 @@ try_again:
 		goto out;
 	}
 
+	perf_evlist__channel_reset(evlist);
+	rc = perf_evlist__channel_add(evlist, 0, true);
+	if (rc < 0)
+		goto out;
+	rc = 0;
+
 	if (perf_evlist__mmap_ex(evlist, opts->mmap_pages, false,
 				 opts->auxtrace_mmap_pages,
 				 opts->auxtrace_snapshot_mode) < 0) {
diff --git a/tools/perf/util/evlist.c b/tools/perf/util/evlist.c
index 890b08b..ff1beac 100644
--- a/tools/perf/util/evlist.c
+++ b/tools/perf/util/evlist.c
@@ -679,14 +679,51 @@ static struct perf_evsel *perf_evlist__event2evsel(struct perf_evlist *evlist,
 	return NULL;
 }
 
-union perf_event *perf_evlist__mmap_read(struct perf_evlist *evlist, int idx)
+int perf_evlist__channel_idx(struct perf_evlist *evlist,
+			     int *p_channel, int *p_idx)
+{
+	int channel = *p_channel;
+	int _idx = *p_idx;
+
+	if (_idx < 0)
+		return -EINVAL;
+	/*
+	 * Negative channel means caller explicitly use real index.
+	 */
+	if (channel < 0) {
+		channel = perf_evlist__idx_channel(evlist, _idx);
+		_idx = _idx % evlist->nr_mmaps;
+	}
+	if (channel < 0)
+		return channel;
+	if (channel >= PERF_EVLIST__NR_CHANNELS)
+		return -E2BIG;
+	if (_idx >= evlist->nr_mmaps)
+		return -E2BIG;
+
+	*p_channel = channel;
+	*p_idx = evlist->nr_mmaps * channel + _idx;
+	return 0;
+}
+
+union perf_event *perf_evlist__mmap_read_ex(struct perf_evlist *evlist,
+					    int channel, int idx)
 {
+	int err = perf_evlist__channel_idx(evlist, &channel, &idx);
 	struct perf_mmap *md = &evlist->mmap[idx];
 	u64 head;
-	u64 old = md->prev;
-	unsigned char *data = md->base + page_size;
+	u64 old;
+	unsigned char *data;
 	union perf_event *event = NULL;
 
+	if (err || !perf_evlist__channel_is_enabled(evlist, channel)) {
+		pr_err("ERROR: invalid mmap index: channel %d, idx: %d\n",
+		       channel, idx);
+		return NULL;
+	}
+	old = md->prev;
+	data = md->base + page_size;
+
 	/*
 	 * Check if event was unmapped due to a POLLHUP/POLLERR.
 	 */
@@ -748,6 +785,11 @@ union perf_event *perf_evlist__mmap_read(struct perf_evlist *evlist, int idx)
 	return event;
 }
 
+union perf_event *perf_evlist__mmap_read(struct perf_evlist *evlist, int idx)
+{
+	return perf_evlist__mmap_read_ex(evlist, -1, idx);
+}
+
 static bool perf_mmap__empty(struct perf_mmap *md)
 {
 	return perf_mmap__read_head(md) == md->prev && !md->auxtrace_mmap.base;
@@ -766,10 +808,18 @@ static void perf_evlist__mmap_put(struct perf_evlist *evlist, int idx)
 		__perf_evlist__munmap(evlist, idx);
 }
 
-void perf_evlist__mmap_consume(struct perf_evlist *evlist, int idx)
+void perf_evlist__mmap_consume_ex(struct perf_evlist *evlist,
+				  int channel, int idx)
 {
+	int err = perf_evlist__channel_idx(evlist, &channel, &idx);
 	struct perf_mmap *md = &evlist->mmap[idx];
 
+	if (err || !perf_evlist__channel_is_enabled(evlist, channel)) {
+		pr_err("ERROR: invalid mmap index: channel %d, idx: %d\n",
+		       channel, idx);
+		return;
+	}
+
 	if (!evlist->overwrite) {
 		u64 old = md->prev;
 
@@ -780,6 +830,11 @@ void perf_evlist__mmap_consume(struct perf_evlist *evlist, int idx)
 		perf_evlist__mmap_put(evlist, idx);
 }
 
+void perf_evlist__mmap_consume(struct perf_evlist *evlist, int idx)
+{
+	perf_evlist__mmap_consume_ex(evlist, -1, idx);
+}
+
 int __weak auxtrace_mmap__mmap(struct auxtrace_mmap *mm __maybe_unused,
 			       struct auxtrace_mmap_params *mp __maybe_unused,
 			       void *userpg __maybe_unused,
@@ -825,7 +880,7 @@ void perf_evlist__munmap(struct perf_evlist *evlist)
 	if (evlist->mmap == NULL)
 		return;
 
-	for (i = 0; i < evlist->nr_mmaps; i++)
+	for (i = 0; i < perf_evlist__mmap_nr(evlist); i++)
 		__perf_evlist__munmap(evlist, i);
 
 	zfree(&evlist->mmap);
@@ -833,10 +888,17 @@ void perf_evlist__munmap(struct perf_evlist *evlist)
 
 static int perf_evlist__alloc_mmap(struct perf_evlist *evlist)
 {
+	int total_mmaps;
+
 	evlist->nr_mmaps = cpu_map__nr(evlist->cpus);
 	if (cpu_map__empty(evlist->cpus))
 		evlist->nr_mmaps = thread_map__nr(evlist->threads);
-	evlist->mmap = zalloc(evlist->nr_mmaps * sizeof(struct perf_mmap));
+
+	total_mmaps = perf_evlist__mmap_nr(evlist);
+	if (!total_mmaps)
+		return -EINVAL;
+
+	evlist->mmap = zalloc(total_mmaps * sizeof(struct perf_mmap));
 	return evlist->mmap != NULL ? 0 : -ENOMEM;
 }
 
@@ -1137,6 +1199,12 @@ int perf_evlist__mmap_ex(struct perf_evlist *evlist, unsigned int pages,
 int perf_evlist__mmap(struct perf_evlist *evlist, unsigned int pages,
 		      bool overwrite)
 {
+	int err;
+
+	perf_evlist__channel_reset(evlist);
+	err = perf_evlist__channel_add(evlist, 0, true);
+	if (err < 0)
+		return err;
 	return perf_evlist__mmap_ex(evlist, pages, overwrite, 0, false);
 }
 
@@ -1739,3 +1807,55 @@ perf_evlist__find_evsel_by_str(struct perf_evlist *evlist,
 
 	return NULL;
 }
+
+int perf_evlist__channel_nr(struct perf_evlist *evlist)
+{
+	int i;
+
+	for (i = PERF_EVLIST__NR_CHANNELS - 1; i >= 0; i--) {
+		unsigned long flags = evlist->channel_flags[i];
+
+		if (flags & PERF_EVLIST__CHANNEL_ENABLED)
+			return i + 1;
+	}
+	return 0;
+}
+
+int perf_evlist__mmap_nr(struct perf_evlist *evlist)
+{
+	return evlist->nr_mmaps * perf_evlist__channel_nr(evlist);
+}
+
+void perf_evlist__channel_reset(struct perf_evlist *evlist)
+{
+	int i;
+
+	BUG_ON(evlist->mmap);
+
+	for (i = 0; i < PERF_EVLIST__NR_CHANNELS; i++)
+		evlist->channel_flags[i] = 0;
+}
+
+int perf_evlist__channel_add(struct perf_evlist *evlist,
+			     unsigned long flag,
+			     bool is_default)
+{
+	int n = perf_evlist__channel_nr(evlist);
+	unsigned long *flags = evlist->channel_flags;
+
+	BUG_ON(evlist->mmap);
+
+	if (n >= PERF_EVLIST__NR_CHANNELS) {
+		pr_debug("ERROR: too many channels. Increase PERF_EVLIST__NR_CHANNELS\n");
+		return -ENOSPC;
+	}
+
+	if (is_default) {
+		memmove(&flags[1], &flags[0],
+			sizeof(evlist->channel_flags) -
+			sizeof(evlist->channel_flags[0]));
+		n = 0;
+	}
+	flags[n] = flag | PERF_EVLIST__CHANNEL_ENABLED;
+	return n;
+}
diff --git a/tools/perf/util/evlist.h b/tools/perf/util/evlist.h
index a0d1522..1812652 100644
--- a/tools/perf/util/evlist.h
+++ b/tools/perf/util/evlist.h
@@ -20,6 +20,11 @@ struct record_opts;
 #define PERF_EVLIST__HLIST_BITS 8
 #define PERF_EVLIST__HLIST_SIZE (1 << PERF_EVLIST__HLIST_BITS)
 
+#define PERF_EVLIST__NR_CHANNELS	1
+enum perf_evlist_mmap_flag {
+	PERF_EVLIST__CHANNEL_ENABLED	= 1,
+};
+
 /**
  * struct perf_mmap - perf's ring buffer mmap details
  *
@@ -52,6 +57,7 @@ struct perf_evlist {
 		pid_t	pid;
 	} workload;
 	struct fdarray	 pollfd;
+	unsigned long channel_flags[PERF_EVLIST__NR_CHANNELS];
 	struct perf_mmap *mmap;
 	struct thread_map *threads;
 	struct cpu_map	  *cpus;
@@ -116,9 +122,61 @@ struct perf_evsel *perf_evlist__id2evsel_strict(struct perf_evlist *evlist,
 
 struct perf_sample_id *perf_evlist__id2sid(struct perf_evlist *evlist, u64 id);
 
+union perf_event *perf_evlist__mmap_read_ex(struct perf_evlist *evlist,
+					    int channel, int idx);
 union perf_event *perf_evlist__mmap_read(struct perf_evlist *evlist, int idx);
 
+void perf_evlist__mmap_consume_ex(struct perf_evlist *evlist,
+				  int channel, int idx);
 void perf_evlist__mmap_consume(struct perf_evlist *evlist, int idx);
+int perf_evlist__mmap_nr(struct perf_evlist *evlist);
+
+int perf_evlist__channel_nr(struct perf_evlist *evlist);
+void perf_evlist__channel_reset(struct perf_evlist *evlist);
+int perf_evlist__channel_add(struct perf_evlist *evlist,
+			     unsigned long flag,
+			     bool is_default);
+
+static inline bool
+__perf_evlist__channel_check(struct perf_evlist *evlist, int channel,
+			     enum perf_evlist_mmap_flag bits)
+{
+	if (channel >= PERF_EVLIST__NR_CHANNELS)
+		return false;
+
+	return (evlist->channel_flags[channel] & bits) ? true : false;
+}
+#define perf_evlist__channel_check(e, c, b) \
+		__perf_evlist__channel_check(e, c, PERF_EVLIST__CHANNEL_##b)
+
+static inline bool
+perf_evlist__channel_is_enabled(struct perf_evlist *evlist, int channel)
+{
+	return perf_evlist__channel_check(evlist, channel, ENABLED);
+}
+
+static inline int
+perf_evlist__idx_channel(struct perf_evlist *evlist, int idx)
+{
+	int channel = idx / evlist->nr_mmaps;
+
+	if (channel >= PERF_EVLIST__NR_CHANNELS)
+		return -E2BIG;
+	return channel;
+}
+
+int perf_evlist__channel_idx(struct perf_evlist *evlist,
+			     int *p_channel, int *p_idx);
+
+static inline struct perf_mmap *
+perf_evlist__get_mmap(struct perf_evlist *evlist,
+		      int channel, int idx)
+{
+	if (perf_evlist__channel_idx(evlist, &channel, &idx))
+		return NULL;
+
+	return &evlist->mmap[idx];
+}
 
 int perf_evlist__open(struct perf_evlist *evlist);
 void perf_evlist__close(struct perf_evlist *evlist);
-- 
1.8.3.4
